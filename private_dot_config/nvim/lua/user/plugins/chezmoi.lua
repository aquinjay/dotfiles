-- lua/user/plugins/chezmoi.lua
-- Dotfiles integration via chezmoi.nvim:
--   • Auto-applies files on save when editing inside ~/.local/share/chezmoi
--   • Telescope picker (<leader>fc) for all chezmoi-managed files
--   • <leader>pc re-adds the current live file back into chezmoi

---@type LazyPluginSpec
return {
  "xvzc/chezmoi.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-telescope/telescope.nvim",
  },
  cmd = { "ChezmoiEdit", "ChezmoiList" },
  keys = {
    {
      "<leader>fc",
      function()
        require("telescope").extensions.chezmoi.find_files()
      end,
      desc = "Find chezmoi dotfiles",
    },
    {
      "<leader>pc",
      function()
        local file = vim.api.nvim_buf_get_name(0)
        if file == "" then
          vim.notify("Buffer has no file path", vim.log.levels.WARN, { title = "Chezmoi" })
          return
        end
        vim.system({ "chezmoi", "re-add", file }, { text = true }, function(res)
          vim.schedule(function()
            if res.code == 0 then
              vim.notify("Synced to chezmoi: " .. vim.fn.fnamemodify(file, ":~"), vim.log.levels.INFO, {
                title = "Chezmoi",
              })
            else
              vim.notify(
                "chezmoi re-add failed: " .. (res.stderr ~= "" and res.stderr or ("exit " .. res.code)),
                vim.log.levels.ERROR,
                { title = "Chezmoi" }
              )
            end
          end)
        end)
      end,
      desc = "Chezmoi re-add current file",
    },
  },
  init = function()
    -- Auto-watch files opened directly inside the chezmoi source tree.
    vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
      group = vim.api.nvim_create_augroup("user_chezmoi_watch", { clear = true }),
      pattern = { vim.fn.expand("~") .. "/.local/share/chezmoi/*" },
      callback = function(ev)
        local ok, edit = pcall(require, "chezmoi.commands.__edit")
        if ok and type(edit.watch) == "function" then
          vim.schedule(function()
            edit.watch(ev.buf)
          end)
        end
      end,
    })
  end,
  opts = {
    edit = {
      watch = true,
      force = false,
    },
    notification = {
      on_open = true,
      on_apply = true,
      on_watch = false,
    },
    telescope = {
      select = { "<CR>" },
    },
  },
  config = function(_, opts)
    require("chezmoi").setup(opts)
    local ok_tel, telescope = pcall(require, "telescope")
    if ok_tel then
      pcall(telescope.load_extension, "chezmoi")
    end
  end,
}

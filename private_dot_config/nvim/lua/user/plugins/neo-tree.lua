-- lua/user/plugins/neo-tree.lua
---@type LazyPluginSpec
return {
  "nvim-neo-tree/neo-tree.nvim",
  branch = "v3.x",
  cmd = "Neotree",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-tree/nvim-web-devicons",
    "MunifTanjim/nui.nvim",
  },

  keys = {
    { "<leader>oe", "<cmd>Neotree toggle left<CR>", desc = "Explorer" },
    { "<leader>of", "<cmd>Neotree reveal left<CR>", desc = "Reveal file in explorer" },
  },

  opts = {
    close_if_last_window = true,
    popup_border_style = "rounded",
    enable_git_status = true,
    enable_diagnostics = true,

    default_component_configs = {
      indent = {
        padding = 1,
      },
      icon = {
        folder_closed = "",
        folder_open = "",
        folder_empty = "󰜌",
      },
      modified = {
        symbol = "●",
      },
      git_status = {
        symbols = {
          added = "A",
          modified = "M",
          deleted = "D",
          renamed = "R",
          untracked = "U",
          ignored = "◌",
          unstaged = "",
          staged = "S",
          conflict = "",
        },
      },
      diagnostics = {
        symbols = {
          hint = "",
          info = "",
          warn = "",
          error = "",
        },
      },
    },

    window = {
      position = "left",
      width = 32,
      mappings = {
        ["<space>"] = "toggle_node",
        ["<CR>"] = "open",
        ["l"] = "open",
        ["h"] = "close_node",
        ["q"] = "close_window",
        ["<C-r>"] = "refresh",

        ["a"] = {
          "add",
          config = { show_path = "relative" },
        },
        ["d"] = "delete",
        ["r"] = "rename",
        ["y"] = "copy_to_clipboard",
        ["p"] = "paste_from_clipboard",
      },
    },

    filesystem = {
      hijack_netrw_behavior = "open_default",
      bind_to_cwd = true,
      follow_current_file = {
        enabled = true,
        leave_dirs_open = false,
      },
      use_libuv_file_watcher = true,

      filtered_items = {
        visible = true,
        hide_dotfiles = false,
        hide_gitignored = true,
        hide_by_name = {
          "node_modules",
        },
      },
    },

    buffers = {
      follow_current_file = {
        enabled = true,
      },
      group_empty_dirs = true,
      show_unloaded = true,
    },

    git_status = {
      window = {
        position = "float",
      },
    },

    source_selector = {
      winbar = false,
      statusline = false,
    },
  },

  config = function(_, opts)
    local ok_icons, icons = pcall(require, "user.core.icons")
    if ok_icons and icons.ui then
      opts.default_component_configs.icon.folder_closed =
        icons.ui.Folder or opts.default_component_configs.icon.folder_closed
      opts.default_component_configs.icon.folder_open =
        icons.ui.FolderOpen or opts.default_component_configs.icon.folder_open
    end

    require("neo-tree").setup(opts)

    -- Open Neo-tree automatically if Neovim starts with a directory.
    vim.api.nvim_create_autocmd("VimEnter", {
      callback = function(data)
        if data.file and vim.fn.isdirectory(data.file) == 1 then
          vim.cmd("Neotree left")
        end
      end,
    })
  end,
}

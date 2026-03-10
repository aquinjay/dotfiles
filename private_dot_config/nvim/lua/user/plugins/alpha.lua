return {
  "goolord/alpha-nvim",
  event = "VimEnter",
  dependencies = { "nvim-tree/nvim-web-devicons" },

  config = function()
    local alpha = require("alpha")
    local dashboard = require("alpha.themes.dashboard")

    -- Seed randomness once per startup so a new header is chosen each launch
    math.randomseed(vim.loop.hrtime())

    -- Rotating headers
    local headers = {
      -- Math
      {
        " ",
        "             ds² = gᵢⱼ dθⁱ dθʲ",
        "            gᵢⱼ = ∂ᵢ∂ⱼ ψ",
        " ",
        "        φ*(η) = sup_θ { ⟨η, θ⟩ − φ(θ) }",
        " ",
        "    ({x, y}, {x, z}) → ({x, z}, {x, w}, {y, w}, {z, w})",
        " ",
      },

      -- NVIM
      {
        " ",
        "███╗   ██╗██╗   ██╗██╗███╗   ███╗",
        "████╗  ██║██║   ██║██║████╗ ████║",
        "██╔██╗ ██║██║   ██║██║██╔████╔██║",
        "██║╚██╗██║╚██╗ ██╔╝██║██║╚██╔╝██║",
        "██║ ╚████║ ╚████╔╝ ██║██║ ╚═╝ ██║",
        "╚═╝  ╚═══╝  ╚═══╝  ╚═╝╚═╝     ╚═╝",
        " ",
      },

      -- Linux penguin
      {
        " ",
        "      .--.",
        "     |o_o |",
        "     |:_/ |",
        "    //   \\ \\",
        "   (|     | )",
        "  /'\\_   _/`\\",
        "  \\___)=(___/",
        " ",
      },
    }

    dashboard.section.header.val = headers[math.random(#headers)]
    dashboard.section.header.opts = { position = "center" }

    -- Simple starter buttons
    dashboard.section.buttons.val = {
      dashboard.button("e", "  New file", "<cmd>ene<CR>"),
      dashboard.button("f", "󰱼  Find file", "<cmd>Telescope find_files<CR>"),
      dashboard.button("r", "󰈙  Recent files", "<cmd>Telescope oldfiles<CR>"),
      dashboard.button("q", "󰗼  Quit", "<cmd>qa<CR>"),
    }

    for _, button in ipairs(dashboard.section.buttons.val) do
      button.opts.hl_shortcut = "Keyword"
    end

    -- Footer with runtime stats
    local v = vim.version()
    local footer = {
      " ",
      string.format("NVIM %d.%d.%d", v.major, v.minor, v.patch),
    }

    local ok, lazy = pcall(require, "lazy")
    if ok then
      local stats = lazy.stats()
      footer[2] = string.format(
        "NVIM %d.%d.%d  |  %d plugins  |  %.2f ms",
        v.major,
        v.minor,
        v.patch,
        stats.loaded,
        stats.startuptime
      )
    end

    dashboard.section.footer.val = footer
    dashboard.section.footer.opts = { position = "center" }

    dashboard.config.layout = {
      { type = "padding", val = 2 },
      dashboard.section.header,
      { type = "padding", val = 2 },
      dashboard.section.buttons,
      { type = "padding", val = 1 },
      dashboard.section.footer,
    }

    alpha.setup(dashboard.config)
  end,
}

-- NOTE: load order does matter. Lazy_init needs to stay after all spec functions run.
-- ^. Run required core files first.

require "user.core.options"
require "user.core.keymaps"
local lazy_helper = require "user.core.lazy_helper"

lazy_helper.spec "user.plugins.tip"
lazy_helper.spec "user.plugins.colorscheme"
lazy_helper.spec "user.plugins.cmp"
lazy_helper.spec "user.plugins.autopairs"
lazy_helper.spec "user.plugins.lualine"
lazy_helper.spec "user.plugins.devicons"
lazy_helper.spec "user.plugins.todo_comments"
lazy_helper.spec "user.plugins.hardtime"
lazy_helper.spec "user.plugins.whichkey"
lazy_helper.spec "user.plugins.lspconfig"
lazy_helper.spec "user.plugins.mason"
lazy_helper.spec "user.plugins.none-ls"
-- Nerd Font picker powered by Telescope / Nerdy.nvim.
lazy_helper.spec "user.plugins.nerdy"
lazy_helper.spec "user.plugins.treesitter"
lazy_helper.spec "user.plugins.neovim_project"
lazy_helper.spec "user.plugins.telescope"
lazy_helper.spec "user.plugins.illuminate"
lazy_helper.spec "user.plugins.indentline"
lazy_helper.spec "user.plugins.comment"
lazy_helper.spec "user.plugins.neo-tree"

require "user.lazy_init"

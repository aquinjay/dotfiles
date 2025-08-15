-- NOTE: load order does matter. Lazy_init needs to stay after all spec functions run.
-- ^. Run required core files first.

require "user.core.options"
require "user.core.keymaps"
require "user.core.lazy_helper"

spec "user.plugins.tip"
spec "user.plugins.colorscheme"
spec "user.plugins.cmp"
spec "user.plugins.autopairs"
spec "user.plugins.lualine"
spec "user.plugins.devicons"
spec "user.plugins.todo_comments"
spec "user.plugins.hardtime"
-- spec "user.plugins.whichkey"
spec "user.plugins.lspconfig" -- may not be needed at all now
spec "user.plugins.mason"
-- spec "user.plugins.none-ls"
spec "user.plugins.nerdy"
spec "user.plugins.treesitter"
-- spec "user.plugins.telescope"
spec "user.plugins.illuminate"
spec "user.plugins.indentline"
-- spec "user.plugins.comment" -- vim 0.10 makes has native functionality for this now

require "user.lazy_init"

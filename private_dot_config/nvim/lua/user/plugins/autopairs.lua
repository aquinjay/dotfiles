-- Plugin spec for nvim-autopairs.  We keep the module lean and rely on
-- annotations in here instead of referring back to docs when tweaking things.
local M = {
  "windwp/nvim-autopairs",
}

M.config = function()
  -- `check_ts` enables Treesitter-aware pairing so conditions/strings are
  -- respected.  `disable_filetype` prevents insertion in prompt-like buffers
  -- where typed characters should be left untouched.
  require("nvim-autopairs").setup {
    check_ts = true,
    disable_filetype = { "TelescopePrompt", "spectre_panel" },
  }
end

return M

local colorscheme = "tokyonight-night"

local status_ok, err = pcall(vim.cmd.colorscheme, "colorscheme " .. colorscheme)

if not status_ok then
        vim.notify("colorscheme " ..err, vim.log.levels.WARN) -- .. = string concatonate
        return
end

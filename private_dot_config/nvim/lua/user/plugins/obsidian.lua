-- lua/user/plugins/obsidian.lua
-- ============================================================================
-- 🧭 QUICK REFERENCE — obsidian.nvim (community fork)
--
-- What this does
--   • Makes Neovim understand the Obsidian vaults: follow [[links]], backlinks,
--     tags, daily notes, templates, image paste, rename with link updates.
--   • Completes [[note names]], [[##headings]] and #tags through its own
--     in-process LSP, so it shows up in nvim-cmp like any other LSP source.
--   • Rendering (callouts, tables, headings) is done by render-markdown.nvim,
--     so this plugin's own UI is turned off.
--
-- Safety (vaults use Obsidian Sync)
--   • frontmatter.enabled = false → never rewrites a note's YAML header on save.
--     (The default regenerates it: adds `id`, re-sorts keys, reformats YAML.)
--   • Settings below mirror each vault's .obsidian/*.json so files land where
--     the Obsidian app would put them.
--
-- Keys (in a vault note)
--   • <CR>       follow link / toggle checkbox / fold heading (smart action)
--   • ]o / [o    next / previous link
--   • gd, grr    go to note / list backlinks (LSP)   • grn  rename + update links
--   • <leader>n… see the "Notes" which-key group (works from anywhere)
--
-- Quick checks
--   • :Obsidian check     → vault + plugin sanity check
--   • :checkhealth obsidian
-- ============================================================================

-- Obsidian names files after the note title ("My Note.md"); keep that instead of
-- the plugin's default random IDs. Untitled notes fall back to a timestamp ID.
local function note_id(title)
  if title ~= nil and vim.trim(title) ~= "" then
    return vim.trim(title)
  end
  return require("obsidian.builtin").zettel_id()
end

local vaults = require "user.core.vaults"

-- Template dates, matching the Obsidian app (moment.js, en locale: weeks start on
-- Sunday, week 1 is the week containing Jan 1). The plugin's formatter has no
-- `gggg` (week-year) and its `ww` restarts at Jan 1, so both are resolved here.
-- Used by the Daily Template's `up: "[[{{date:gggg-[W]ww}}]]"` → [[2026-W45]].
local DAY = 24 * 60 * 60

local function format_date(time, fmt)
  -- Saturday that ends this week decides the week-year and week number.
  local saturday = os.date("*t", time + (6 - tonumber(os.date("%w", time))) * DAY)
  local week = math.floor((saturday.yday - 1) / 7) + 1
  fmt = fmt:gsub("gggg", "[" .. saturday.year .. "]"):gsub("ww", ("[%02d]"):format(week))
  return require("obsidian.date").format(time, fmt)
end

-- `{{sunday:FMT}}` / `{{saturday:FMT}}` (Weekly Template): that day of the current week.
local function weekday_substitution(wday)
  return function(_, suffix)
    local time = os.time()
    time = time + (wday - tonumber(os.date("%w", time))) * DAY
    return format_date(time, suffix or "YYYY-MM-DD")
  end
end

-- Shared by both vaults (from .obsidian/app.json + templates.json).
local function vault_overrides(daily_notes)
  return {
    notes_subdir = "+ Encounters", -- newFileFolderPath
    new_notes_location = "notes_subdir",
    attachments = { folder = "Extras" }, -- attachmentFolderPath
    templates = {
      folder = "Extras/Templates",
      substitutions = {
        date = function(_, suffix)
          return format_date(os.time(), suffix or "YYYY-MM-DD")
        end,
        sunday = weekday_substitution(0),
        saturday = weekday_substitution(6),
      },
    },
    daily_notes = daily_notes,
  }
end

---@type LazyPluginSpec
return {
  "obsidian-nvim/obsidian.nvim",
  version = "*", -- latest release; main may document unreleased features
  ft = "markdown",
  cmd = "Obsidian",
  dependencies = { "nvim-telescope/telescope.nvim" },

  keys = {
    { "<leader>nf", "<cmd>Obsidian quick_switch<cr>", desc = "Find note" },
    { "<leader>ns", "<cmd>Obsidian search<cr>", desc = "Search notes (text)" },
    { "<leader>nt", "<cmd>Obsidian tags<cr>", desc = "Tags" },
    { "<leader>nd", "<cmd>Obsidian today<cr>", desc = "Today's daily note" },
    { "<leader>nD", "<cmd>Obsidian dailies<cr>", desc = "Daily notes list" },
    { "<leader>nn", "<cmd>Obsidian new<cr>", desc = "New note" },
    { "<leader>nN", "<cmd>Obsidian new_from_template<cr>", desc = "New note from template" },
    { "<leader>nw", "<cmd>Obsidian workspace<cr>", desc = "Switch vault" },
    -- current-note commands
    { "<leader>no", "<cmd>Obsidian open<cr>", desc = "Open in Obsidian app" },
    { "<leader>nb", "<cmd>Obsidian backlinks<cr>", desc = "Backlinks" },
    { "<leader>nl", "<cmd>Obsidian links<cr>", desc = "Links in note" },
    { "<leader>nc", "<cmd>Obsidian toc<cr>", desc = "Table of contents" },
    { "<leader>ni", "<cmd>Obsidian template<cr>", desc = "Insert template" },
    { "<leader>nr", "<cmd>Obsidian rename<cr>", desc = "Rename note (updates links)" },
    { "<leader>np", "<cmd>Obsidian paste_img<cr>", desc = "Paste image" },
  },

  ---@module 'obsidian'
  ---@type obsidian.config
  opts = {
    legacy_commands = false, -- only `:Obsidian <sub>` (old :ObsidianX goes away in 4.0)

    workspaces = {
      {
        name = vaults[1].name,
        path = vaults[1].path,
        overrides = vault_overrides {
          folder = "Calendar/Logs/Journal",
          template = "Daily Template.md",
          date_format = "YYYY-MM-DD",
          default_tags = {},
          workdays_only = false,
        },
      },
      {
        name = vaults[2].name,
        path = vaults[2].path,
        overrides = vault_overrides {
          -- daily notes not configured in this vault → Obsidian's defaults (vault root)
          date_format = "YYYY-MM-DD",
          default_tags = {},
          workdays_only = false,
        },
      },
    },

    note_id_func = note_id,
    frontmatter = { enabled = false },

    -- Obsidian's default "shortest path" wikilinks
    link = { style = "wiki", format = "shortest" },

    -- userIgnoreFilters in the Thinking vault
    file = { ignore_filters = { "Extras/Backups/" } },

    picker = { name = "telescope.nvim" },

    -- render-markdown.nvim draws the note; only one plugin should own the UI.
    ui = { enable = false },

    -- Obsidian Sync stays with the Obsidian app.
    sync = { enabled = false },
  },
}

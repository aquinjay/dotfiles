-- Direct Lua replacement generated from your CachyOS Hyprland config.
-- This is the live config: Hyprland loads hyprland.lua and ignores hyprland.conf.
-- The old .conf files were moved to ~/.config/hypr.legacy-conf-20261008/.

local mainMod = "SUPER"

-- Programs / defaults
local filemanager = "thunar"
local applauncher = "wofi"
local terminal = "alacritty"
local idlehandler = "hypridle" -- settings in ~/.config/hypr/hypridle.conf

-- Screenshots
local shot_region = "grimblast copy area"
local shot_window = "grimblast copy active"
local shot_screen = "grimblast copy output"

-- Colors
local cachylgreen = "rgba(82dcccff)"
local cachymgreen = "rgba(00aa84ff)"
local cachydgreen = "rgba(007d6fff)"
local cachylblue  = "rgba(01ccffff)"
local cachymblue  = "rgba(182545ff)"
local cachydblue  = "rgba(111826ff)"
local cachywhite  = "rgba(ffffffff)"
local cachygrey   = "rgba(ddddddff)"
local cachygray   = "rgba(798bb2ff)"

-- Monitor
hl.monitor({
  output = "",
  mode = "preferred",
  position = "auto",
  scale = 1,
})

-- Environment
hl.env("HYPRCURSOR_SIZE", "24")
hl.env("XCURSOR_SIZE", "24")
hl.env("QT_CURSOR_SIZE", "24")
hl.env("ELECTRON_OZONE_PLATFORM_HINT", "auto")

-- Autostart
hl.on("hyprland.start", function()
  hl.exec_cmd([[swaybg -o \* -i /usr/share/wallpapers/cachyos-wallpapers/Skyscraper.png -m fill]])
  hl.exec_cmd([[waybar &]])
  hl.exec_cmd([[fcitx5 -d &]])
  hl.exec_cmd([[mako &]])
  hl.exec_cmd([[nm-applet --indicator &]])
  hl.exec_cmd([[bash -c "mkfifo /tmp/$HYPRLAND_INSTANCE_SIGNATURE.wob && tail -f /tmp/$HYPRLAND_INSTANCE_SIGNATURE.wob | wob & disown" &]])
  hl.exec_cmd([[/usr/lib/polkit-kde-authentication-agent-1 &]])

  -- Slow app launch fix
  hl.exec_cmd([[systemctl --user import-environment &]])
  hl.exec_cmd([[hash dbus-update-activation-environment 2>/dev/null &]])
  hl.exec_cmd([[dbus-update-activation-environment --systemd &]])

  -- Idle configuration
  hl.exec_cmd(idlehandler)
end)

-- General config
hl.config({
  general = {
    gaps_in = 3,
    gaps_out = 5,
    border_size = 3,
    col = {
      active_border = cachylgreen,
      inactive_border = cachymblue,
    },
    layout = "dwindle",
    snap = {
      enabled = true,
    },
  },

  decoration = {
    active_opacity = 1,
    rounding = 4,
    blur = {
      size = 15,
      passes = 2,
      xray = true,
    },
    shadow = {
      enabled = false,
    },
  },

  input = {
    follow_mouse = 2,
    float_switch_override_focus = 2,
  },

  group = {
    col = {
      border_active = cachydgreen,
      border_inactive = cachylgreen,
      border_locked_active = cachymgreen,
      border_locked_inactive = cachydblue,
    },
    groupbar = {
      font_family = "Fira Sans",
      text_color = cachydblue,
      col = {
        active = cachydgreen,
        inactive = cachylgreen,
        locked_active = cachymgreen,
        locked_inactive = cachydblue,
      },
    },
  },

  misc = {
    font_family = "Fira Sans",
    splash_font_family = "Fira Sans",
    disable_hyprland_logo = true,
    col = {
      splash = cachylgreen,
    },
    background_color = cachydblue,
    enable_swallow = true,
    swallow_regex = [[^(nautilus|nemo|thunar|btrfs-assistant.)$]],
    focus_on_activate = true,
    vrr = 2,
  },

  render = {
    direct_scanout = true,
  },

  dwindle = {
    special_scale_factor = 0.8,
    preserve_split = true,
  },

  master = {
    new_status = "master",
    special_scale_factor = 0.8,
  },

  binds = {
    allow_workspace_cycles = true,
    workspace_back_and_forth = true,
    workspace_center_on = true,
    movefocus_cycles_fullscreen = true,
    window_direction_monitor_fallback = true,
  },
})

-- Animations
hl.curve("overshot", {
  type = "bezier",
  points = { { 0.13, 0.99 }, { 0.29, 1.1 } },
})

hl.animation({ leaf = "windowsIn", enabled = true, speed = 4, bezier = "overshot", style = "slide" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 5, bezier = "default", style = "popin 80%" })
hl.animation({ leaf = "border", enabled = true, speed = 5, bezier = "default" })
hl.animation({ leaf = "workspacesIn", enabled = true, speed = 6, bezier = "overshot", style = "slide" })
hl.animation({ leaf = "workspacesOut", enabled = true, speed = 6, bezier = "overshot", style = "slidefade 80%" })

-- Gestures
hl.gesture({ fingers = 4, direction = "horizontal", action = "workspace" })
-- 3-finger swipe down used to close the window; removed (too easy to trigger by accident)
hl.gesture({ fingers = 3, direction = "up", action = "fullscreen" })
hl.gesture({ fingers = 3, direction = "left", action = "float" })

-- Helpers
local function bind(keys, dispatcher, flags)
  hl.bind(keys, dispatcher, flags or {})
end

local function exec(keys, command, flags)
  bind(keys, hl.dsp.exec_cmd(command), flags)
end

local function focus_workspace(keys, workspace)
  bind(keys, hl.dsp.focus({ workspace = workspace }))
end

local function move_to_workspace(keys, workspace, follow)
  bind(keys, hl.dsp.window.move({ workspace = workspace, follow = follow }))
end

local function move_focus(keys, direction)
  bind(keys, hl.dsp.focus({ direction = direction }))
end

local function move_window(keys, direction)
  bind(keys, hl.dsp.window.move({ direction = direction }))
end

local function resize_window(keys, x, y)
  bind(keys, hl.dsp.window.resize({ x = x, y = y, relative = true }))
end

-- Keybinds: apps / session
exec(mainMod .. " + RETURN", terminal)
if filemanager ~= "" then
  exec(mainMod .. " + E", filemanager)
  exec(mainMod .. " + SHIFT + E", terminal .. " -e yazi")
else
  bind(mainMod .. " + E", hl.dsp.no_op())
end
bind(mainMod .. " + Q", hl.dsp.window.close())
exec(mainMod .. " + SHIFT + M", [[loginctl terminate-user ""]])
bind(mainMod .. " + V", hl.dsp.window.float({ action = "toggle" }))
exec(mainMod .. " + SPACE", applauncher)
bind(mainMod .. " + F", hl.dsp.window.fullscreen({ action = "toggle" }))
bind(mainMod .. " + Y", hl.dsp.window.pin())
bind(mainMod .. " + J", hl.dsp.layout("togglesplit"))

-- Screenshots
exec("Print", shot_region)
exec("CTRL + Print", shot_window)
exec("ALT + Print", shot_screen)

-- Grouping
bind(mainMod .. " + K", hl.dsp.group.toggle())
bind(mainMod .. " + Tab", hl.dsp.group.next())

-- Toggle gaps
exec(mainMod .. " + SHIFT + G", [[hyprctl --batch "keyword general:gaps_out 5;keyword general:gaps_in 3"]])
exec(mainMod .. " + G", [[hyprctl --batch "keyword general:gaps_out 0;keyword general:gaps_in 0"]])

-- Volume control
exec("XF86AudioRaiseVolume", [[pactl set-sink-volume @DEFAULT_SINK@ +5% && pactl get-sink-volume @DEFAULT_SINK@ | grep -oP '\d+(?=%)' | awk '{if($1>100) system("pactl set-sink-volume @DEFAULT_SINK@ 100%")}' && pactl get-sink-volume @DEFAULT_SINK@ | grep -oP '\d+(?=%)' | awk '{print $1}' | head -1 > /tmp/$HYPRLAND_INSTANCE_SIGNATURE.wob]], { locked = true, repeating = true })
exec("XF86AudioLowerVolume", [[pactl set-sink-volume @DEFAULT_SINK@ -5% && pactl get-sink-volume @DEFAULT_SINK@ | grep -oP '\d+(?=%)' | awk '{print $1}' | head -1 > /tmp/$HYPRLAND_INSTANCE_SIGNATURE.wob]], { locked = true, repeating = true })
exec("XF86AudioMute", [[amixer sset Master toggle | sed -En '/\[on\]/ s/.*\[([0-9]+)%\].*/\1/ p; /\[off\]/ s/.*/0/p' | head -1 > /tmp/$HYPRLAND_INSTANCE_SIGNATURE.wob]], { locked = true, repeating = true })

-- Playback control
exec("XF86AudioPlay", [[playerctl play-pause]])
exec("XF86AudioNext", [[playerctl next]])
exec("XF86AudioPrev", [[playerctl previous]])

-- Screen brightness / lock / waybar
exec("XF86MonBrightnessUp", [[brightnessctl s +5%]], { locked = true, repeating = true })
exec("XF86MonBrightnessDown", [[brightnessctl s 5%-]], { locked = true, repeating = true })
exec(mainMod .. " + L", [[loginctl lock-session]]) -- hypridle runs hyprlock
exec(mainMod .. " + O", [[killall -SIGUSR2 waybar]])
exec(mainMod .. " + B", [[killall -SIGUSR1 waybar]])

-- Window actions
bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
move_window(mainMod .. " + SHIFT + left", "l")
move_window(mainMod .. " + SHIFT + right", "r")
move_window(mainMod .. " + SHIFT + up", "u")
move_window(mainMod .. " + SHIFT + down", "d")
move_focus(mainMod .. " + left", "l")
move_focus(mainMod .. " + right", "r")
move_focus(mainMod .. " + up", "u")
move_focus(mainMod .. " + down", "d")

-- Resize submap
bind(mainMod .. " + R", hl.dsp.submap("resize"))
hl.define_submap("resize", function()
  resize_window("right", 15, 0)
  resize_window("left", -15, 0)
  resize_window("up", 0, -15)
  resize_window("down", 0, 15)
  resize_window("l", 15, 0)
  resize_window("h", -15, 0)
  resize_window("k", 0, -15)
  resize_window("j", 0, 15)
  bind("escape", hl.dsp.submap("reset"))
end)

-- Quick resize
resize_window(mainMod .. " + CTRL + SHIFT + right", 15, 0)
resize_window(mainMod .. " + CTRL + SHIFT + left", -15, 0)
resize_window(mainMod .. " + CTRL + SHIFT + up", 0, -15)
resize_window(mainMod .. " + CTRL + SHIFT + down", 0, 15)
resize_window(mainMod .. " + CTRL + SHIFT + l", 15, 0)
resize_window(mainMod .. " + CTRL + SHIFT + h", -15, 0)
resize_window(mainMod .. " + CTRL + SHIFT + k", 0, -15)
resize_window(mainMod .. " + CTRL + SHIFT + j", 0, 15)
bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })
bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })

-- Move active window to workspace and follow
for i = 1, 9 do
  local n = tostring(i)
  move_to_workspace(mainMod .. " + CTRL + " .. n, n, true)
end
move_to_workspace(mainMod .. " + CTRL + 0", "10", true)
move_to_workspace(mainMod .. " + CTRL + left", "-1", true)
move_to_workspace(mainMod .. " + CTRL + right", "+1", true)

-- Move active window to workspace silently
for i = 1, 9 do
  local n = tostring(i)
  move_to_workspace(mainMod .. " + SHIFT + " .. n, n, false)
end
move_to_workspace(mainMod .. " + SHIFT + 0", "10", false)

-- Switch workspaces
for i = 1, 9 do
  local n = tostring(i)
  focus_workspace(mainMod .. " + " .. n, n)
end
focus_workspace(mainMod .. " + 0", "10")
focus_workspace(mainMod .. " + PERIOD", "e+1")
focus_workspace(mainMod .. " + COMMA", "e-1")
focus_workspace(mainMod .. " + mouse_down", "e+1")
focus_workspace(mainMod .. " + mouse_up", "e-1")
focus_workspace(mainMod .. " + slash", "previous")

-- Special workspaces
move_to_workspace(mainMod .. " + minus", "special", true)
bind(mainMod .. " + equal", hl.dsp.workspace.toggle_special("special"))
bind(mainMod .. " + F1", hl.dsp.workspace.toggle_special("scratchpad"))
move_to_workspace(mainMod .. " + ALT + SHIFT + F1", "special:scratchpad", false)

-- Window rules
hl.window_rule({ name = "float-pavucontrol", match = { class = [[^(org\.pulseaudio\.pavucontrol)$]] }, float = true })
hl.window_rule({ name = "float-picture-in-picture-empty-class", match = { class = [[^()$]], title = [[^(Picture in picture)$]] }, float = true })
hl.window_rule({ name = "float-save-file", match = { class = [[^()$]], title = [[^(Save File)$]] }, float = true })
hl.window_rule({ name = "float-open-file", match = { class = [[^()$]], title = [[^(Open File)$]] }, float = true })
hl.window_rule({ name = "float-librewolf-pip", match = { class = [[^(LibreWolf)$]], title = [[^(Picture-in-Picture)$]] }, float = true })
hl.window_rule({ name = "float-blueman", match = { class = [[^(blueman-manager)$]] }, float = true })
hl.window_rule({ name = "float-xdg-portals", match = { class = [[^(xdg-desktop-portal-gtk|xdg-desktop-portal-kde|xdg-desktop-portal-hyprland)(.*)$]] }, float = true })
hl.window_rule({ name = "float-polkit", match = { class = [[^(polkit-gnome-authentication-agent-1|hyprpolkitagent|org.org.kde.polkit-kde-authentication-agent-1)(.*)$]] }, float = true })
hl.window_rule({ name = "float-cachyoshello", match = { class = [[^(CachyOSHello)$]] }, float = true })
hl.window_rule({ name = "float-zenity", match = { class = [[^(zenity)$]] }, float = true })
hl.window_rule({ name = "float-steam-self-updater", match = { class = [[^()$]], title = [[^(Steam - Self Updater)$]] }, float = true })

hl.window_rule({ name = "opacity-filemanagers", match = { class = [[^(thunar|nemo)$]] }, opacity = "0.92" })
hl.window_rule({ name = "opacity-discord", match = { class = [[^(discord|armcord|webcord)$]] }, opacity = "0.96" })
hl.window_rule({ name = "opacity-qq-telegram", match = { title = [[^(QQ|Telegram)$]] }, opacity = "0.95" })
hl.window_rule({ name = "opacity-netease", match = { title = [[^(NetEase Cloud Music Gtk4)$]] }, opacity = "0.95" })

hl.window_rule({ name = "pip-float", match = { title = [[^(Picture-in-Picture)$]] }, float = true })
hl.window_rule({ name = "pip-size", match = { title = [[^(Picture-in-Picture)$]] }, size = "960 540" })
hl.window_rule({ name = "pip-move", match = { title = [[^(Picture-in-Picture)$]] }, move = "25% 25%" })

hl.window_rule({ name = "helper-float", match = { title = [[^(imv|mpv|danmufloat|termfloat|nemo|ncmpcpp)$]] }, float = true })
hl.window_rule({ name = "helper-move", match = { title = [[^(imv|mpv|danmufloat|termfloat|nemo|ncmpcpp)$]] }, move = "25% 25%" })
hl.window_rule({ name = "helper-size", match = { title = [[^(imv|mpv|danmufloat|termfloat|nemo|ncmpcpp)$]] }, size = "960 540" })
hl.window_rule({ name = "pin-danmufloat", match = { title = [[^(danmufloat)$]] }, pin = true })
hl.window_rule({ name = "round-floaters", match = { title = [[^(danmufloat|termfloat)$]] }, rounding = 5 })
hl.window_rule({ name = "terminal-animation", match = { class = [[^(kitty|Alacritty)$]] }, animation = "slide right" })

-- Workspace rules
hl.workspace_rule({ workspace = "w[tv1-10]", gaps_out = 5, gaps_in = 3 })
hl.workspace_rule({ workspace = "f[1]", gaps_out = 5, gaps_in = 3 })

-- Layer rules
hl.layer_rule({ name = "logout-dialog-animation", match = { namespace = "logout_dialog" }, animation = "slide top" })
hl.layer_rule({ name = "waybar-animation", match = { namespace = "waybar" }, animation = "slide down" })
hl.layer_rule({ name = "wallpaper-animation", match = { namespace = "wallpaper" }, animation = "fade 50%" })

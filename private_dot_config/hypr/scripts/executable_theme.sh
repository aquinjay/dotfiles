#!/usr/bin/env bash
# Switch the desktop theme. Bound to SUPER + SHIFT + T (menu).
#
#   theme.sh                    rofi menu: wallpaper colors or a preset
#   theme.sh wallpaper [IMAGE]  colors generated from IMAGE (default: last wallpaper-mode image)
#   theme.sh preset NAME        fixed palette + style from ~/.config/matugen/presets/NAME.json
#
# Both modes render the same templates in ~/.config/matugen/templates/ via matugen,
# so Hyprland, waybar, rofi, swaync, hyprlock and alacritty always match.
set -euo pipefail

cfg="$HOME/.config/matugen"
presets="$cfg/presets"
cache="${XDG_CACHE_HOME:-$HOME/.cache}/theme"
wall_link="$HOME/.config/hypr/wallpaper"            # what swaybg shows
matugen_link="$HOME/.config/hypr/wallpaper-matugen" # last image used in wallpaper mode
state="$HOME/.config/hypr/theme-current"
mkdir -p "$cache"

set_wallpaper() {
  ln -sfn "$1" "$wall_link"
  local old
  old=$(pgrep -x swaybg || true)
  setsid swaybg -o '*' -i "$wall_link" -m fill >/dev/null 2>&1 &
  sleep 0.4
  [[ -n $old ]] && kill $old 2>/dev/null || true
}

# Prints the style JSON with "font" swapped for "font_fallback" when the font isn't installed.
style_json() {
  python3 - "$1" <<'EOF'
import json, subprocess, sys
src = json.load(open(sys.argv[1]))
style = src.get("style", src)
if subprocess.run(["fc-list", "-q", style["font"]]).returncode != 0:
    style["font"] = style["font_fallback"]
print(json.dumps({"style": style}))
EOF
}

apply_wallpaper() {
  local img=${1:-}
  if [[ -z $img ]]; then
    img=$(readlink -f "$matugen_link" 2>/dev/null || readlink -f "$wall_link")
  fi
  img=$(realpath "$img")
  [[ -f $img ]] || { notify-send "Theme" "Not a file: $img"; exit 1; }
  ln -sfn "$img" "$matugen_link"
  set_wallpaper "$img"
  matugen image "$img" --prefer saturation -q \
    --import-json-string "$(style_json "$cfg/style-wallpaper.json")"
  echo "wallpaper" > "$state"
  notify-send -i "$img" "Theme: wallpaper colors" "$(basename "$img")"
}

apply_preset() {
  local file="$presets/$1.json"
  [[ -f $file ]] || { notify-send "Theme" "No preset: $1"; exit 1; }
  # Expand the preset's plain hex colors into matugen's JSON format.
  python3 - "$file" "$cache/preset.json" <<'EOF'
import json, sys
p = json.load(open(sys.argv[1]))
wrap = lambda hexes: {k: {m: {"color": v} for m in ("dark", "default", "light")} for k, v in hexes.items()}
json.dump({"mode": "dark", "is_dark_mode": True,
           "colors": wrap(p["colors"]), "base16": wrap(p["base16"])}, open(sys.argv[2], "w"))
EOF
  local wall name
  wall=$(python3 -c 'import json,os,sys; print(os.path.expanduser(json.load(open(sys.argv[1]))["wallpaper"]))' "$file")
  name=$(python3 -c 'import json,sys; print(json.load(open(sys.argv[1]))["name"])' "$file")
  [[ -f $wall ]] && set_wallpaper "$wall"
  matugen json "$cache/preset.json" -q --import-json-string "$(style_json "$file")"
  echo "preset:$1" > "$state"
  notify-send -i "$wall" "Theme: $name" "SUPER + SHIFT + T to switch"
}

menu() {
  local current entries=() ids=() choice f
  current=$(cat "$state" 2>/dev/null || echo wallpaper)
  entries+=("󰸉  Wallpaper colors"); ids+=("wallpaper")
  for f in "$presets"/*.json; do
    entries+=("󰏘  $(python3 -c 'import json,sys; print(json.load(open(sys.argv[1]))["name"])' "$f")")
    ids+=("preset:$(basename "$f" .json)")
  done
  choice=$(printf '%s\n' "${entries[@]}" | rofi -dmenu -i -format i -p "󰏘 theme" \
    -mesg "current: $current" -theme-str 'listview { lines: 5; }') || exit 0
  case ${ids[$choice]} in
    wallpaper) apply_wallpaper ;;
    preset:*)  apply_preset "${ids[$choice]#preset:}" ;;
  esac
}

case ${1:-menu} in
  menu)      menu ;;
  wallpaper) apply_wallpaper "${2:-}" ;;
  preset)    apply_preset "${2:?preset name required}" ;;
  *)         echo "usage: theme.sh [menu | wallpaper [IMAGE] | preset NAME]" >&2; exit 2 ;;
esac

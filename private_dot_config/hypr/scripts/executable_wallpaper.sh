#!/usr/bin/env bash
# Pick a wallpaper (thumbnail grid in rofi), or pass an image path as $1.
# Sets it, then has matugen re-theme Hyprland, waybar, rofi, swaync, hyprlock and alacritty.
# Bound to SUPER + SHIFT + W. Add your own wallpapers to ~/Pictures/Wallpapers.
set -euo pipefail

dirs=("$HOME/Pictures/Wallpapers" "/usr/share/wallpapers/cachyos-wallpapers")
link="$HOME/.config/hypr/wallpaper"

if [[ $# -ge 1 ]]; then
  img=$(realpath "$1")
else
  mapfile -t files < <(find "${dirs[@]}" -maxdepth 1 -type f \
    \( -iname '*.png' -o -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.webp' \) 2>/dev/null | sort)
  [[ ${#files[@]} -gt 0 ]] || { notify-send "Wallpaper" "No images found in ${dirs[*]}"; exit 1; }

  choice=$(
    for f in "${files[@]}"; do printf '%s\0icon\x1f%s\n' "$(basename "${f%.*}")" "$f"; done |
      rofi -dmenu -i -show-icons -format i -p "󰸉 wallpaper" \
        -theme-str 'window { width: 960px; }
                    listview { columns: 4; lines: 3; }
                    element { orientation: vertical; padding: 8px; }
                    element-icon { size: 180px; }
                    element-text { horizontal-align: 0.5; }'
  ) || exit 0   # Escape pressed
  img=${files[$choice]}
fi

[[ -f $img ]] || { notify-send "Wallpaper" "Not a file: $img"; exit 1; }

ln -sfn "$img" "$link"

# Start the new wallpaper before stopping the old one, to avoid a flash.
old=$(pgrep -x swaybg || true)
setsid swaybg -o '*' -i "$link" -m fill >/dev/null 2>&1 &
sleep 0.4
[[ -n $old ]] && kill $old 2>/dev/null || true

# Generate colors; matugen's post-hooks reload Hyprland, waybar and swaync.
matugen image "$img" --prefer saturation -q

notify-send -i "$img" "Theme updated" "$(basename "$img")"

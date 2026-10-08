#!/usr/bin/env bash
# Pick a wallpaper (thumbnail grid in rofi), or pass an image path as $1.
# Sets it, then has matugen re-theme everything from it (see theme.sh).
# Bound to SUPER + SHIFT + W. Add your own wallpapers to ~/Pictures/Wallpapers.
set -euo pipefail

dirs=("$HOME/Pictures/Wallpapers" "/usr/share/wallpapers/cachyos-wallpapers")

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

# Set it and re-theme everything from it (switches to wallpaper-colors mode).
exec "$HOME/.config/hypr/scripts/theme.sh" wallpaper "$img"

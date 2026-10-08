#!/usr/bin/env python3
"""Generate the wallpapers used by the Deus Ex and Cyberpunk theme presets.

Writes SVGs and renders them to PNG with rsvg-convert:
    ~/Pictures/Wallpapers/themes/deus-ex.png
    ~/Pictures/Wallpapers/themes/cyberpunk.png

Usage: gen-theme-wallpapers.py [WIDTH HEIGHT]   (default 1920 1080)
Re-run with a fixed seed, so the output is the same every time.
"""
import math
import os
import random
import subprocess
import sys

W, H = (int(sys.argv[1]), int(sys.argv[2])) if len(sys.argv) == 3 else (1920, 1080)
OUT = os.path.expanduser("~/Pictures/Wallpapers/themes")


def scanlines(opacity):
    return f"""
  <pattern id="scan" width="4" height="4" patternUnits="userSpaceOnUse">
    <rect width="4" height="1" fill="#000" opacity="{opacity}"/>
  </pattern>"""


def hexagon(cx, cy, r):
    pts = [(cx + r * math.cos(math.radians(60 * i)), cy + r * math.sin(math.radians(60 * i))) for i in range(6)]
    return " ".join(f"{x:.1f},{y:.1f}" for x, y in pts)


def deus_ex():
    rnd = random.Random(7)
    r = 46                                  # hex radius
    dx, dy = r * 1.5, r * math.sqrt(3)
    cx0, cy0 = W * 0.62, H * 0.42           # light source
    hexes, lit = [], []
    for col in range(int(W / dx) + 2):
        for row in range(int(H / dy) + 2):
            x = col * dx
            y = row * dy + (dy / 2 if col % 2 else 0)
            d = math.hypot(x - cx0, y - cy0) / math.hypot(W, H)
            op = max(0.0, 0.55 - d * 1.1)
            if op <= 0.02:
                continue
            hexes.append(f'<polygon points="{hexagon(x, y, r - 3)}" opacity="{op:.2f}"/>')
            if rnd.random() < 0.05 * (1 - d):
                lit.append(f'<polygon points="{hexagon(x, y, r - 3)}" opacity="{op * 0.5:.2f}"/>')
    beams = []
    for i in range(5):
        x = cx0 + rnd.uniform(-500, 300)
        w = rnd.uniform(40, 160)
        beams.append(f'<polygon points="{x:.0f},-50 {x + w:.0f},-50 {x - 700 + w:.0f},{H + 50} {x - 700:.0f},{H + 50}" '
                     f'fill="url(#beam)" opacity="{rnd.uniform(0.08, 0.22):.2f}"/>')
    return f"""<svg xmlns="http://www.w3.org/2000/svg" width="{W}" height="{H}">
<defs>
  <radialGradient id="bg" cx="{cx0 / W:.2f}" cy="{cy0 / H:.2f}" r="0.9">
    <stop offset="0" stop-color="#3a2400"/><stop offset="0.35" stop-color="#140c02"/><stop offset="1" stop-color="#030302"/>
  </radialGradient>
  <linearGradient id="beam" x1="0" y1="0" x2="0" y2="1">
    <stop offset="0" stop-color="#ffcf5a"/><stop offset="1" stop-color="#ffcf5a" stop-opacity="0"/>
  </linearGradient>
  <radialGradient id="vig" cx="0.5" cy="0.5" r="0.75">
    <stop offset="0.55" stop-color="#000" stop-opacity="0"/><stop offset="1" stop-color="#000" stop-opacity="0.85"/>
  </radialGradient>
  <filter id="glow" x="-20%" y="-20%" width="140%" height="140%"><feGaussianBlur stdDeviation="3"/></filter>
  {scanlines(0.35)}
</defs>
<rect width="100%" height="100%" fill="url(#bg)"/>
{''.join(beams)}
<g fill="#f2a900" filter="url(#glow)">{''.join(lit)}</g>
<g fill="none" stroke="#f2a900" stroke-width="1.6" filter="url(#glow)" opacity="0.7">{''.join(hexes)}</g>
<g fill="none" stroke="#ffd27f" stroke-width="1">{''.join(hexes)}</g>
<rect width="100%" height="100%" fill="url(#vig)"/>
<rect width="100%" height="100%" fill="url(#scan)"/>
</svg>"""


def cyberpunk():
    rnd = random.Random(2077)
    horizon = H * 0.62
    # perspective grid floor
    grid = []
    vx = W / 2
    for i in range(-90, 91):
        grid.append(f'<line x1="{vx:.0f}" y1="{horizon:.0f}" x2="{vx + i * 160:.0f}" y2="{H}"/>')
    for k in range(1, 22):
        y = horizon + (H - horizon) * (k / 21) ** 2.2
        grid.append(f'<line x1="0" y1="{y:.1f}" x2="{W}" y2="{y:.1f}" opacity="{0.25 + 0.75 * k / 21:.2f}"/>')
    # two layers of skyline with lit windows
    layers = []
    for depth, (fill, hmin, hmax, wmin, wmax) in enumerate([("#120a24", 120, 380, 50, 130), ("#07070f", 60, 300, 40, 110)]):
        x, rects, wins = -20, [], []
        while x < W + 20:
            bw = rnd.uniform(wmin, wmax)
            bh = rnd.uniform(hmin, hmax) * (1.6 if rnd.random() < 0.08 else 1)
            top = horizon - bh
            rects.append(f'<rect x="{x:.0f}" y="{top:.0f}" width="{bw:.0f}" height="{bh + 2:.0f}"/>')
            for wy in range(int(top) + 10, int(horizon) - 8, 14):
                for wx in range(int(x) + 6, int(x + bw) - 6, 11):
                    if rnd.random() < 0.18:
                        c = rnd.choice(["#00f0ff", "#00f0ff", "#ff2a6d", "#fcee0a"])
                        wins.append(f'<rect x="{wx}" y="{wy}" width="5" height="3" fill="{c}" opacity="{rnd.uniform(0.35, 0.95) * (0.6 if depth == 0 else 1):.2f}"/>')
            x += bw + rnd.uniform(0, 12)
        layers.append(f'<g fill="{fill}">{"".join(rects)}</g><g>{"".join(wins)}</g>')
    # glitch bars
    glitch = []
    for _ in range(9):
        y = rnd.uniform(0, H)
        glitch.append(f'<rect x="{rnd.uniform(-200, W * 0.7):.0f}" y="{y:.0f}" width="{rnd.uniform(150, 700):.0f}" '
                      f'height="{rnd.uniform(1, 4):.0f}" fill="{rnd.choice(["#00f0ff", "#ff2a6d"])}" opacity="{rnd.uniform(0.15, 0.5):.2f}"/>')
    return f"""<svg xmlns="http://www.w3.org/2000/svg" width="{W}" height="{H}">
<defs>
  <linearGradient id="sky" x1="0" y1="0" x2="0" y2="1">
    <stop offset="0" stop-color="#05050b"/><stop offset="0.45" stop-color="#140828"/>
    <stop offset="0.62" stop-color="#3a0a3a"/><stop offset="1" stop-color="#05050b"/>
  </linearGradient>
  <radialGradient id="haze" cx="0.5" cy="{horizon / H:.2f}" r="0.55">
    <stop offset="0" stop-color="#ff2a6d" stop-opacity="0.55"/><stop offset="1" stop-color="#ff2a6d" stop-opacity="0"/>
  </radialGradient>
  <linearGradient id="floorfade" x1="0" y1="0" x2="0" y2="1">
    <stop offset="0" stop-color="#05050b" stop-opacity="0.9"/><stop offset="0.5" stop-color="#05050b" stop-opacity="0"/>
  </linearGradient>
  <filter id="glow" x="-10%" y="-10%" width="120%" height="120%"><feGaussianBlur stdDeviation="2.5"/></filter>
  <filter id="bigglow" x="-50%" y="-50%" width="200%" height="200%"><feGaussianBlur stdDeviation="12"/></filter>
  {scanlines(0.4)}
</defs>
<rect width="100%" height="100%" fill="url(#sky)"/>
<rect width="100%" height="100%" fill="url(#haze)"/>
{layers[0]}
<g stroke="#00f0ff" stroke-width="2" filter="url(#glow)" opacity="0.8">{''.join(grid)}</g>
<g stroke="#7ffaff" stroke-width="1">{''.join(grid)}</g>
<rect x="0" y="{horizon:.0f}" width="{W}" height="{H - horizon:.0f}" fill="url(#floorfade)"/>
{layers[1]}
<rect x="0" y="{horizon - 2:.0f}" width="{W}" height="5" fill="#ff2a6d" filter="url(#bigglow)"/>
<rect x="0" y="{horizon - 1:.0f}" width="{W}" height="2" fill="#ff6a9a"/>
{''.join(glitch)}
<rect width="100%" height="100%" fill="url(#scan)"/>
</svg>"""


def render(name, svg):
    os.makedirs(OUT, exist_ok=True)
    svg_path = os.path.join(OUT, name + ".svg")
    with open(svg_path, "w") as f:
        f.write(svg)
    subprocess.run(["rsvg-convert", "-w", str(W), "-h", str(H), "-o", os.path.join(OUT, name + ".png"), svg_path], check=True)
    os.remove(svg_path)
    print("wrote", os.path.join(OUT, name + ".png"))


render("deus-ex", deus_ex())
render("cyberpunk", cyberpunk())

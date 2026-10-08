#!/usr/bin/env python3
"""Generate the wallpapers used by the theme presets.

Writes SVGs and renders them to PNG with rsvg-convert, into ~/Pictures/Wallpapers/themes/:
    deus-ex.png        black faceted geometry, gold edges
    samurai.png        hi-tech samurai mask in red neon, circuits and HUD (black / red / chrome)
    fallout.png        green CRT terminal showing live system info and a keybind reference
    fallout-plain.png  the same CRT screen with no text

Usage: gen-theme-wallpapers.py [NAME ...] [--size WIDTHxHEIGHT]
    NAME is deus-ex, samurai or fallout (default: all). The size defaults to the
    focused monitor's resolution. Fixed seeds, so the art is the same every run;
    fallout.png picks up fresh system info each time (theme.sh re-runs it on apply).
"""
import getpass
import json
import math
import os
import platform
import pwd
import random
import shutil
import socket
import subprocess
import sys
import time


def monitor_size():
    try:
        mons = json.loads(subprocess.run(["hyprctl", "monitors", "-j"], capture_output=True, text=True).stdout)
        m = next((m for m in mons if m.get("focused")), mons[0])
        return int(m["width"]), int(m["height"])
    except Exception:
        return 1920, 1080


args = sys.argv[1:]
if "--size" in args:
    i = args.index("--size")
    W, H = (int(v) for v in args[i + 1].lower().split("x"))
    del args[i:i + 2]
else:
    W, H = monitor_size()
NAMES = args or ["deus-ex", "samurai", "fallout"]
OUT = os.path.expanduser("~/Pictures/Wallpapers/themes")


def esc(t):
    return t.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;")


def pts(points):
    return " ".join(f"{x:.1f},{y:.1f}" for x, y in points)


def scanlines(opacity, step=4):
    return f"""
  <pattern id="scan" width="{step}" height="{step}" patternUnits="userSpaceOnUse">
    <rect width="{step}" height="1" fill="#000" opacity="{opacity}"/>
  </pattern>"""


def vignette(strength):
    return f"""
  <radialGradient id="vig" cx="0.5" cy="0.5" r="0.75">
    <stop offset="0.5" stop-color="#000" stop-opacity="0"/><stop offset="1" stop-color="#000" stop-opacity="{strength}"/>
  </radialGradient>"""


def deus_ex():
    """Faceted black glass: a jittered triangle mesh lit from the upper right, with sparse gold edges."""
    rnd = random.Random(7)
    cell = 120
    cols, rows = W // cell + 3, H // cell + 3
    pts = [[(c * cell - cell + rnd.uniform(-0.38, 0.38) * cell,
             r * cell - cell + rnd.uniform(-0.38, 0.38) * cell) for c in range(cols)] for r in range(rows)]
    lx, ly = W * 0.78, H * 0.18                       # light source
    faces, edges, shards = [], [], []
    for r in range(rows - 1):
        for c in range(cols - 1):
            a, b, d, e = pts[r][c], pts[r][c + 1], pts[r + 1][c], pts[r + 1][c + 1]
            for tri in ((a, b, e), (a, e, d)) if (r + c) % 2 else ((a, b, d), (b, e, d)):
                cx = sum(p[0] for p in tri) / 3
                cy = sum(p[1] for p in tri) / 3
                dist = math.hypot(cx - lx, cy - ly) / math.hypot(W, H)
                facet = rnd.uniform(0.0, 1.0)            # fake surface angle
                v = int(4 + 22 * facet * max(0.0, 1 - dist * 1.4))
                pts_s = " ".join(f"{x:.1f},{y:.1f}" for x, y in tri)
                faces.append(f'<polygon points="{pts_s}" fill="rgb({v + 3},{v + 2},{v})"/>')
                if rnd.random() < 0.10 * max(0.15, 1 - dist * 1.6):
                    i = rnd.randrange(3)
                    p, q = tri[i], tri[(i + 1) % 3]
                    edges.append(f'<line x1="{p[0]:.1f}" y1="{p[1]:.1f}" x2="{q[0]:.1f}" y2="{q[1]:.1f}" '
                                 f'opacity="{max(0.25, 1 - dist * 1.5):.2f}"/>')
                if rnd.random() < 0.012 * max(0.0, 1 - dist * 2):
                    shards.append(f'<polygon points="{pts_s}" opacity="{rnd.uniform(0.25, 0.6):.2f}"/>')
    return f"""<svg xmlns="http://www.w3.org/2000/svg" width="{W}" height="{H}">
<defs>
  <radialGradient id="light" cx="{lx / W:.2f}" cy="{ly / H:.2f}" r="0.6">
    <stop offset="0" stop-color="#f2a900" stop-opacity="0.16"/><stop offset="1" stop-color="#f2a900" stop-opacity="0"/>
  </radialGradient>
  <filter id="glow" x="-20%" y="-20%" width="140%" height="140%"><feGaussianBlur stdDeviation="2.5"/></filter>
  {vignette(0.9)}
  {scanlines(0.25)}
</defs>
<rect width="100%" height="100%" fill="#030303"/>
<g stroke="#000" stroke-width="0.6">{''.join(faces)}</g>
<rect width="100%" height="100%" fill="url(#light)"/>
<g fill="#f2a900" filter="url(#glow)">{''.join(shards)}</g>
<g stroke="#f2a900" stroke-width="2.2" filter="url(#glow)">{''.join(edges)}</g>
<g stroke="#ffd27f" stroke-width="1">{''.join(edges)}</g>
<rect width="100%" height="100%" fill="url(#vig)"/>
<rect width="100%" height="100%" fill="url(#scan)"/>
</svg>"""


def samurai():
    """Hi-tech samurai: an angular kabuto + menpo mask outlined in red neon, circuit traces, HUD, glitch."""
    rnd = random.Random(2023)
    RED, DEEP, CHROME, STEEL = "#ff1f3d", "#8a0f1f", "#d6dbe4", "#5d6b7e"
    cx, cy, sc = W * 0.66, H * 0.53, H / 1080

    def T(points):                                   # local mask coords -> screen
        return [(cx + x * sc, cy + y * sc) for x, y in points]

    def sym(right):                                  # right half -> full symmetric outline
        return right + [(-x, y) for x, y in reversed(right)]

    def mirror(points):
        return [(-x, y) for x, y in points]

    blade = [(10, -165), (60, -232), (150, -335), (275, -440), (205, -322), (112, -222), (40, -160)]
    bowl = sym([(0, -168), (70, -162), (135, -136), (182, -94), (204, -42), (210, -8)])
    brim = [(-236, -12), (236, -12), (256, 22), (-256, 22)]
    flap = [(208, -36), (305, -78), (338, 6), (254, 62), (218, 22)]
    menpo = sym([(0, 32), (82, 34), (152, 52), (178, 98), (168, 152), (132, 208), (82, 248), (30, 266)])
    eye = [(30, 92), (70, 74), (156, 58), (146, 84), (62, 102)]
    mouth = [(-96, 196), (96, 196), (80, 236), (-80, 236)]
    gem = [(0, -238), (28, -192), (0, -150), (-28, -192)]

    solids, lines = [], []
    for poly in (bowl, menpo):
        solids.append(f'<polygon points="{pts(T(poly))}"/>')
    for poly in (blade, mirror(blade), flap, mirror(flap), brim, gem, mouth):
        solids.append(f'<polygon points="{pts(T(poly))}"/>')
    for i in range(4):                               # shikoro: lamellar neck guard
        band = [(214 + i * 10, 40 + i * 38), (330 + i * 20, 30 + i * 46), (342 + i * 20, 62 + i * 46), (219 + i * 10, 72 + i * 38)]
        solids.append(f'<polygon points="{pts(T(band))}"/>')
        solids.append(f'<polygon points="{pts(T(mirror(band)))}"/>')
    for x in range(-60, 61, 20):                     # mouth guard teeth
        lines.append(T([(x, 200), (x * 0.86, 232)]))
    lines += [T([(0, 104), (0, 172)]), T([(0, 172), (26, 184)]), T([(0, 172), (-26, 184)])]
    for side in (1, -1):                             # tech lines on the cheeks and helmet
        lines.append(T([(side * 150, 112), (side * 112, 132), (side * 112, 176), (side * 92, 190)]))
        lines.append(T([(side * 60, -140), (side * 120, -112), (side * 150, -70)]))
        lines.append(T([(side * 20, -60), (side * 90, -60), (side * 120, -30)]))
    for k in range(3):
        lines.append(T([(-34, 248 + k * 6), (34, 248 + k * 6)]))
    line_svg = "".join(f'<polyline points="{pts(l)}" fill="none"/>' for l in lines)
    eyes = "".join(f'<polygon points="{pts(T(p))}"/>' for p in (eye, mirror(eye)))

    # circuit traces running out from the mask
    traces, pads = [], []
    for _ in range(46):
        a = rnd.uniform(0, 2 * math.pi)
        x, y = cx + math.cos(a) * 260 * sc, cy + math.sin(a) * 300 * sc
        path = [(x, y)]
        for _ in range(rnd.randint(2, 5)):
            d = rnd.choice([0, 45, 90, 135, 180, 225, 270, 315])
            # bias outward
            out = math.degrees(math.atan2(y - cy, x - cx))
            d = d if abs((d - out + 180) % 360 - 180) < 100 else (d + 180) % 360
            step = rnd.uniform(40, 160) * sc
            x += math.cos(math.radians(d)) * step
            y += math.sin(math.radians(d)) * step
            path.append((x, y))
        op = rnd.uniform(0.18, 0.5)
        traces.append(f'<polyline points="{pts(path)}" opacity="{op:.2f}"/>')
        pads.append(f'<circle cx="{x:.0f}" cy="{y:.0f}" r="{3 * sc:.1f}" opacity="{op + 0.2:.2f}"/>')

    # glitch: horizontal slices of the mask shifted sideways
    glitch_defs, glitch_use = [], []
    for i in range(6):
        y0 = cy + rnd.uniform(-420, 260) * sc
        hgt = rnd.uniform(4, 18) * sc
        dx = rnd.choice([-1, 1]) * rnd.uniform(12, 46) * sc
        glitch_defs.append(f'<clipPath id="g{i}"><rect x="0" y="{y0:.0f}" width="{W}" height="{hgt:.0f}"/></clipPath>')
        glitch_use.append(f'<use href="#mask" clip-path="url(#g{i})" transform="translate({dx:.0f} 0)" opacity="0.85"/>')

    m = 60 * sc                                      # HUD corner brackets
    br = 70 * sc
    brackets = "".join(f'<polyline points="{pts(p)}" fill="none"/>' for p in (
        [(m, m + br), (m, m), (m + br, m)], [(W - m - br, m), (W - m, m), (W - m, m + br)],
        [(m, H - m - br), (m, H - m), (m + br, H - m)], [(W - m - br, H - m), (W - m, H - m), (W - m, H - m - br)]))
    mono = "MesloLGS Nerd Font Mono"
    hud = f"""
<g font-family="{mono}" font-size="{15 * sc:.0f}" fill="{CHROME}" opacity="0.55">
  <text x="{m + 20 * sc:.0f}" y="{m + 34 * sc:.0f}">侍 // SAMURAI.SYS  ONLINE</text>
  <text x="{m + 20 * sc:.0f}" y="{m + 56 * sc:.0f}" fill="{STEEL}">NEURAL LINK ........ STABLE</text>
  <text x="{m + 20 * sc:.0f}" y="{m + 78 * sc:.0f}" fill="{STEEL}">CYBERWARE .......... 87%</text>
  <text x="{W - m - 20 * sc:.0f}" y="{H - m - 22 * sc:.0f}" text-anchor="end">35.6762 N  139.6503 E</text>
  <text x="{W - m - 20 * sc:.0f}" y="{H - m - 44 * sc:.0f}" text-anchor="end" fill="{RED}">// WAKE UP. WE HAVE A CITY TO BURN</text>
</g>"""
    return f"""<svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" width="{W}" height="{H}">
<defs>
  <radialGradient id="halo" cx="{cx / W:.2f}" cy="{(cy - 80 * sc) / H:.2f}" r="0.45">
    <stop offset="0" stop-color="{DEEP}" stop-opacity="0.55"/><stop offset="1" stop-color="{DEEP}" stop-opacity="0"/>
  </radialGradient>
  <linearGradient id="armor" x1="0" y1="0" x2="0" y2="1">
    <stop offset="0" stop-color="#17171c"/><stop offset="1" stop-color="#09090b"/>
  </linearGradient>
  <filter id="glow" x="-30%" y="-30%" width="160%" height="160%"><feGaussianBlur stdDeviation="{5 * sc:.1f}"/></filter>
  <filter id="soft" x="-30%" y="-30%" width="160%" height="160%"><feGaussianBlur stdDeviation="{1.6 * sc:.1f}"/></filter>
  {''.join(glitch_defs)}
  <g id="mask">
    <g fill="url(#armor)" stroke="{RED}" stroke-width="{2.6 * sc:.1f}" stroke-linejoin="miter">{''.join(solids)}</g>
    <g stroke="{RED}" stroke-width="{1.6 * sc:.1f}" opacity="0.8">{line_svg}</g>
    <g fill="#ff3b55">{eyes}</g>
    <g fill="#fff4f5" filter="url(#soft)" opacity="0.8">{eyes}</g>
  </g>
  {vignette(0.8)}
  {scanlines(0.3)}
</defs>
<rect width="100%" height="100%" fill="#08080a"/>
<rect width="100%" height="100%" fill="url(#halo)"/>
<g stroke="{RED}" stroke-width="{1.4 * sc:.1f}" fill="none">{''.join(traces)}</g>
<g fill="{RED}">{''.join(pads)}</g>
<text x="{W * 0.1:.0f}" y="{H * 0.18:.0f}" font-family="Noto Sans CJK JP" font-weight="900" font-size="{150 * sc:.0f}"
      fill="{RED}" opacity="0.16" writing-mode="tb">サムライ</text>
<g stroke="{RED}" stroke-width="{6 * sc:.1f}" filter="url(#glow)" opacity="0.55" fill="none">
  <use href="#mask"/>
</g>
<use href="#mask"/>
{''.join(glitch_use)}
<g stroke="{CHROME}" stroke-width="{1.5 * sc:.1f}" opacity="0.5">{brackets}</g>
{hud}
<rect width="100%" height="100%" fill="url(#vig)"/>
<rect width="100%" height="100%" fill="url(#scan)"/>
</svg>"""


def system_info():
    def read(path):
        try:
            with open(path) as f:
                return f.read()
        except OSError:
            return ""

    osrel = dict(l.split("=", 1) for l in read("/etc/os-release").splitlines() if "=" in l)
    cpu = next((l.split(":", 1)[1].strip() for l in read("/proc/cpuinfo").splitlines() if l.startswith("model name")), "unknown")
    mem_kb = next((int(l.split()[1]) for l in read("/proc/meminfo").splitlines() if l.startswith("MemTotal")), 0)
    du = shutil.disk_usage("/")
    try:
        hypr = json.loads(subprocess.run(["hyprctl", "version", "-j"], capture_output=True, text=True).stdout).get("tag", "?")
    except Exception:
        hypr = "?"
    return [
        ("OPERATOR", f"{getpass.getuser()}@{socket.gethostname()}"),
        ("SYSTEM", osrel.get("PRETTY_NAME", "Linux").strip('"')),
        ("KERNEL", platform.release()),
        ("COMPOSITOR", f"Hyprland {hypr}"),
        ("PROCESSOR", " ".join(cpu.split())[:38]),
        ("MEMORY", f"{mem_kb / 1048576:.1f} GB"),
        ("STORAGE /", f"{du.used / 1e9:.0f} / {du.total / 1e9:.0f} GB used"),
        ("SHELL", os.path.basename(pwd.getpwuid(os.getuid()).pw_shell)),
        ("LAST SYNC", time.strftime("%Y-%m-%d %H:%M")),
    ]


KEYS = [
    ("TERMINAL", "SUPER+ENTER"), ("LAUNCHER", "SUPER+SPACE"), ("WINDOWS", "ALT+TAB"),
    ("CLOSE", "SUPER+Q"), ("FULLSCREEN", "SUPER+F"), ("FLOAT", "SUPER+V"),
    ("FOCUS", "SUPER+H/J/K/L"), ("TOGGLE BAR", "SUPER+B"), ("NOTIFICATIONS", "SUPER+N"),
    ("CLIPBOARD", "SUPER+SHIFT+V"), ("SCREENSHOT", "SUPER+SHIFT+S"), ("FILES", "SUPER+E"),
    ("THEMES", "SUPER+SHIFT+T"), ("WALLPAPER", "SUPER+SHIFT+W"), ("LOCK", "SUPER+ESC"),
]


def fallout(with_text=True):
    """Green phosphor CRT. With text: live system info and a keybind reference, terminal style."""
    green, dim, faint = "#1aff80", "#12a356", "#0b5c31"
    sc = H / 1080
    fs, lh = 25 * sc, 38 * sc
    cw = fs * 0.6                                    # monospace cell width
    x0, y0 = W * 0.07, H * 0.12
    out = []

    def line(x, y, text, color=green):
        out.append(f'<text x="{x:.0f}" y="{y:.0f}" fill="{color}" xml:space="preserve">{esc(text)}</text>')

    if with_text:
        line(x0, y0, "ROBCO INDUSTRIES (TM) TERMLINK PROTOCOL")
        line(x0, y0 + lh, f"WELCOME, {getpass.getuser().upper()}")
        col2 = x0 + cw * 58
        y = y0 + lh * 3
        line(x0, y, "> SYSTEM STATUS")
        line(col2, y, "> COMMAND REFERENCE")
        line(x0, y + lh * 0.55, "-" * 48, faint)
        line(col2, y + lh * 0.55, "-" * 36, faint)
        y += lh * 1.4
        for i, (k, v) in enumerate(system_info()):
            line(x0, y + i * lh, f"{k:<12}", dim)
            line(x0 + cw * 13, y + i * lh, v)
        for i, (k, v) in enumerate(KEYS):
            line(col2, y + i * lh, f"{k} {'.' * (20 - len(k))} ", dim)
            line(col2 + cw * 22, y + i * lh, v)
        py = y + max(len(KEYS), 9) * lh + lh * 0.6
        line(x0, py, ">")
        out.append(f'<rect x="{x0 + cw * 1.5:.0f}" y="{py - fs + 4 * sc:.0f}" width="{cw:.0f}" height="{fs:.0f}" fill="{green}"/>')
    body = "".join(out)
    mono = "MesloLGS Nerd Font Mono"
    return f"""<svg xmlns="http://www.w3.org/2000/svg" width="{W}" height="{H}">
<defs>
  <radialGradient id="screen" cx="0.5" cy="0.48" r="0.8">
    <stop offset="0" stop-color="#06301a"/><stop offset="0.6" stop-color="#03170b"/><stop offset="1" stop-color="#010603"/>
  </radialGradient>
  <filter id="glow" x="-5%" y="-20%" width="110%" height="140%"><feGaussianBlur stdDeviation="{3.5 * sc:.1f}"/></filter>
  {vignette(0.95)}
  {scanlines(0.45, 3)}
</defs>
<rect width="100%" height="100%" fill="url(#screen)"/>
<g font-family="{mono}" font-size="{fs:.0f}" filter="url(#glow)" opacity="0.85">{body}</g>
<g font-family="{mono}" font-size="{fs:.0f}">{body}</g>
<rect width="100%" height="100%" fill="url(#scan)"/>
<rect width="100%" height="100%" fill="url(#vig)"/>
</svg>"""


def render(name, svg):
    os.makedirs(OUT, exist_ok=True)
    svg_path = os.path.join(OUT, name + ".svg")
    with open(svg_path, "w") as f:
        f.write(svg)
    subprocess.run(["rsvg-convert", "-w", str(W), "-h", str(H), "-o", os.path.join(OUT, name + ".png"), svg_path], check=True)
    os.remove(svg_path)
    print("wrote", os.path.join(OUT, name + ".png"))


for name in NAMES:
    if name == "deus-ex":
        render("deus-ex", deus_ex())
    elif name == "samurai":
        render("samurai", samurai())
    elif name == "fallout":
        render("fallout", fallout())
        render("fallout-plain", fallout(with_text=False))
    else:
        sys.exit(f"unknown wallpaper: {name}")

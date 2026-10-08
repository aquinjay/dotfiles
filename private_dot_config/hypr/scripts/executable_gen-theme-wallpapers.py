#!/usr/bin/env python3
"""Generate the wallpapers used by the theme presets.

Writes SVGs and renders them to PNG with rsvg-convert, into ~/Pictures/Wallpapers/themes/:
    deus-ex.png        black faceted geometry, gold edges
    samurai.png        red circuits, HUD and katakana on black; puts your Samurai logo in the middle
                       if themes/samurai-logo.png (or .jpg/.webp/.svg) exists
    fallout.png        green CRT terminal showing live system info and a keybind reference
    fallout-plain.png  the same CRT screen with no text

Usage: gen-theme-wallpapers.py [NAME ...] [--size WIDTHxHEIGHT]
    NAME is deus-ex, samurai or fallout (default: all). The size defaults to the
    focused monitor's resolution. Fixed seeds, so the art is the same every run;
    fallout.png picks up fresh system info each time (theme.sh re-runs it on apply).
"""
import base64
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
    """Hi-tech samurai background: circuit traces, HUD, katakana and glitch slices around a central emblem.

    The emblem is your own image: drop the Samurai logo at themes/samurai-logo.{png,jpg,webp,svg}.
    Without it the centre is left empty."""
    rnd = random.Random(2023)
    RED, DEEP, CHROME, STEEL = "#ff1f3d", "#8a0f1f", "#d6dbe4", "#5d6b7e"
    cx, cy, sc = W * 0.66, H * 0.53, H / 1080

    emblem, emblem_glow = "", ""
    logo = next((os.path.join(OUT, "samurai-logo." + ext) for ext in ("png", "jpg", "jpeg", "webp", "svg")
                 if os.path.exists(os.path.join(OUT, "samurai-logo." + ext))), None)
    if logo:
        mime = {"svg": "image/svg+xml", "jpg": "image/jpeg", "jpeg": "image/jpeg"}.get(logo.rsplit(".", 1)[1], "image/" + logo.rsplit(".", 1)[1])
        with open(logo, "rb") as f:
            data = base64.b64encode(f.read()).decode()
        bw, bh = W * 0.42, H * 0.66                  # box the logo is fitted into
        emblem = (f'<image href="data:{mime};base64,{data}" x="{cx - bw / 2:.0f}" y="{cy - 40 * sc - bh / 2:.0f}" '
                  f'width="{bw:.0f}" height="{bh:.0f}" preserveAspectRatio="xMidYMid meet"/>')
        emblem_glow = '<use href="#mask" filter="url(#redglow)" opacity="0.55"/>'

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
    for i in range(4):
        y0 = cy + rnd.uniform(-420, 260) * sc
        hgt = rnd.uniform(3, 10) * sc
        dx = rnd.choice([-1, 1]) * rnd.uniform(6, 22) * sc
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
  <text x="{m + 20 * sc:.0f}" y="{m + 56 * sc:.0f}" fill="{RED}">NEURAL LINK ........ UNSTABLE</text>
  <text x="{m + 20 * sc:.0f}" y="{m + 78 * sc:.0f}" fill="{STEEL}">RELIC INTEGRITY .... 13%</text>
  <text x="{m + 20 * sc:.0f}" y="{m + 100 * sc:.0f}" fill="{STEEL}">CYBERPSYCHOSIS ..... ELEVATED</text>
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
  <filter id="redglow" x="-30%" y="-30%" width="160%" height="160%">
    <feGaussianBlur stdDeviation="{14 * sc:.1f}"/>
    <feColorMatrix type="matrix" values="0 0 0 0 1  0 0 0 0 0.12  0 0 0 0 0.24  0 0 0 0.9 0"/>
  </filter>
  {''.join(glitch_defs)}
  <g id="mask">{emblem}
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
{emblem_glow}
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
    green, dim, faint = "#1aff80", "#3fd884", "#1f7a45"
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
    <stop offset="0" stop-color="#0f4d2a"/><stop offset="0.6" stop-color="#0a321b"/><stop offset="1" stop-color="#04170b"/>
  </radialGradient>
  <filter id="glow" x="-5%" y="-20%" width="110%" height="140%"><feGaussianBlur stdDeviation="{3.5 * sc:.1f}"/></filter>
  {vignette(0.75)}
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

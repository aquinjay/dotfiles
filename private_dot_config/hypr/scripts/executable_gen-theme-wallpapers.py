#!/usr/bin/env python3
"""Generate the wallpapers used by the theme presets.

Writes SVGs and renders them to PNG with rsvg-convert:
    ~/Pictures/Wallpapers/themes/deus-ex.png    black faceted geometry, gold edges
    ~/Pictures/Wallpapers/themes/samurai.png    ink black, split red sun, hanko seal
    ~/Pictures/Wallpapers/themes/fallout.png    green phosphor CRT terminal

Usage: gen-theme-wallpapers.py [WIDTH HEIGHT]   (default 1920 1080)
Uses fixed seeds, so the output is the same every time.
"""
import math
import os
import random
import subprocess
import sys

W, H = (int(sys.argv[1]), int(sys.argv[2])) if len(sys.argv) == 3 else (1920, 1080)
OUT = os.path.expanduser("~/Pictures/Wallpapers/themes")


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
    """Ink-black paper, a red sun cut in two by a sword stroke, a hanko seal and a bushido column."""
    rnd = random.Random(1600)
    sx, sy, sr = W * 0.64, H * 0.44, H * 0.30       # sun
    # the cut: a line through the sun at ~-28 degrees; the two halves slide apart along it
    ang = math.radians(-28)
    ux, uy = math.cos(ang), math.sin(ang)
    off = 9
    big = 4000
    half_a = f"{sx - ux * big:.0f},{sy - uy * big:.0f} {sx + ux * big:.0f},{sy + uy * big:.0f} {sx + ux * big - uy * big:.0f},{sy + uy * big + ux * big:.0f} {sx - ux * big - uy * big:.0f},{sy - uy * big + ux * big:.0f}"
    half_b = f"{sx - ux * big:.0f},{sy - uy * big:.0f} {sx + ux * big:.0f},{sy + uy * big:.0f} {sx + ux * big + uy * big:.0f},{sy + uy * big - ux * big:.0f} {sx - ux * big + uy * big:.0f},{sy - uy * big - ux * big:.0f}"
    petals = []
    for _ in range(14):
        x, y = rnd.uniform(W * 0.05, W * 0.98), rnd.uniform(H * 0.05, H * 0.95)
        s = rnd.uniform(5, 11)
        petals.append(f'<ellipse cx="{x:.0f}" cy="{y:.0f}" rx="{s:.1f}" ry="{s * 0.55:.1f}" '
                      f'transform="rotate({rnd.uniform(0, 180):.0f} {x:.0f} {y:.0f})" opacity="{rnd.uniform(0.35, 0.8):.2f}"/>')
    kx, ky = W * 0.12, H * 0.72                     # seal position
    return f"""<svg xmlns="http://www.w3.org/2000/svg" width="{W}" height="{H}">
<defs>
  <filter id="paper" x="0" y="0" width="100%" height="100%">
    <feTurbulence type="fractalNoise" baseFrequency="0.9" numOctaves="2" seed="3" result="n"/>
    <feColorMatrix in="n" type="matrix" values="0 0 0 0 0.08  0 0 0 0 0.06  0 0 0 0 0.05  0 0 0 0.9 0"/>
  </filter>
  <filter id="brush" x="-10%" y="-10%" width="120%" height="120%">
    <feTurbulence type="fractalNoise" baseFrequency="0.035" numOctaves="3" seed="9" result="t"/>
    <feDisplacementMap in="SourceGraphic" in2="t" scale="22" xChannelSelector="R" yChannelSelector="G"/>
  </filter>
  <filter id="glow" x="-50%" y="-50%" width="200%" height="200%"><feGaussianBlur stdDeviation="6"/></filter>
  <filter id="haze" x="-60%" y="-60%" width="220%" height="220%"><feGaussianBlur stdDeviation="70"/></filter>
  <radialGradient id="sun" cx="0.45" cy="0.4" r="0.7">
    <stop offset="0" stop-color="#ff3a4c"/><stop offset="1" stop-color="#a50f1f"/>
  </radialGradient>
  <clipPath id="ca"><polygon points="{half_a}"/></clipPath>
  <clipPath id="cb"><polygon points="{half_b}"/></clipPath>
  {vignette(0.85)}
</defs>
<rect width="100%" height="100%" fill="#0b0909"/>
<rect width="100%" height="100%" filter="url(#paper)"/>
<circle cx="{sx:.0f}" cy="{sy:.0f}" r="{sr * 1.05:.0f}" fill="#e0243a" opacity="0.22" filter="url(#haze)"/>
<g filter="url(#brush)">
  <g transform="translate({-uy * off - ux * 16:.1f} {ux * off - uy * 16:.1f})">
    <circle cx="{sx:.0f}" cy="{sy:.0f}" r="{sr:.0f}" fill="url(#sun)" clip-path="url(#ca)"/>
  </g>
  <g transform="translate({uy * off + ux * 16:.1f} {-ux * off + uy * 16:.1f})">
    <circle cx="{sx:.0f}" cy="{sy:.0f}" r="{sr:.0f}" fill="url(#sun)" clip-path="url(#cb)"/>
  </g>
</g>
<line x1="{sx - ux * W:.0f}" y1="{sy - uy * W:.0f}" x2="{sx + ux * W:.0f}" y2="{sy + uy * W:.0f}"
      stroke="#f4ece0" stroke-width="5" opacity="0.55" filter="url(#glow)"/>
<line x1="{sx - ux * W:.0f}" y1="{sy - uy * W:.0f}" x2="{sx + ux * W:.0f}" y2="{sy + uy * W:.0f}"
      stroke="#fffaf2" stroke-width="1.6"/>
<g fill="#e0243a">{''.join(petals)}</g>
<text x="{W * 0.9:.0f}" y="{H * 0.16:.0f}" font-family="AR PL New Kai" font-size="64" fill="#e8dcc4" opacity="0.28"
      writing-mode="tb" letter-spacing="18">武士道</text>
<g transform="translate({kx:.0f} {ky:.0f}) rotate(-4)">
  <rect x="-62" y="-62" width="124" height="124" rx="10" fill="#c8102e" filter="url(#brush)" opacity="0.92"/>
  <text x="0" y="40" text-anchor="middle" font-family="AR PL New Kai" font-size="112" fill="#0b0909">侍</text>
</g>
<rect width="100%" height="100%" fill="url(#vig)"/>
</svg>"""


def fallout():
    """Green phosphor CRT showing a terminal hacking screen."""
    rnd = random.Random(2287)
    green, dim = "#1aff80", "#12a356"
    fs, lh = 24, 32
    x0, y0 = W * 0.09, H * 0.13
    lines = [
        ("ROBCO INDUSTRIES (TM) TERMLINK PROTOCOL", green),
        ("ENTER PASSWORD NOW", green),
        ("", green),
        ("4 ATTEMPT(S) LEFT:  █ █ █ █", green),
        ("", green),
    ]
    junk = "!@#$%^&*()-_=+[]{}<>/\\|;:'\",.?"
    words = ["VAULT", "STEEL", "PIPES", "ATOMS", "RADIO", "BUNKR", "TERMS", "OVERS", "NUKES", "POWER"]
    addr = 0xF4A0
    rows = []
    for i in range(16):
        cols = []
        for half in range(2):
            s = "".join(rnd.choice(junk) for _ in range(12))
            if rnd.random() < 0.35:
                w = rnd.choice(words)
                p = rnd.randrange(0, 12 - len(w))
                s = s[:p] + w + s[p + len(w):]
            cols.append(f"0x{addr + (half * 16 + i) * 12:04X} {s}")
        rows.append("   ".join(cols))
    side = [">" + rnd.choice(words), ">Entry denied", ">1/5 correct.", ">" + rnd.choice(words),
            ">Entry denied", ">3/5 correct.", ">", ">"]
    texts = []
    y = y0
    for t, c in lines:
        texts.append(f'<text x="{x0:.0f}" y="{y:.0f}" fill="{c}">{t}</text>')
        y += lh
    for i, row in enumerate(rows):
        texts.append(f'<text x="{x0:.0f}" y="{y + i * lh:.0f}" fill="{green}" xml:space="preserve">'
                     f'{row.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;")}</text>')
    sx = x0 + fs * 0.6 * 44
    for i, t in enumerate(side):
        texts.append(f'<text x="{sx:.0f}" y="{y + (len(rows) - len(side) + i) * lh:.0f}" fill="{dim}">'
                     f'{t.replace(">", "&gt;")}</text>')
    cy = y + (len(rows) - 1) * lh
    cursor = f'<rect x="{sx + fs * 0.6 * 1.2:.0f}" y="{cy - fs + 4:.0f}" width="{fs * 0.6:.0f}" height="{fs:.0f}" fill="{green}"/>'
    return f"""<svg xmlns="http://www.w3.org/2000/svg" width="{W}" height="{H}">
<defs>
  <radialGradient id="screen" cx="0.5" cy="0.48" r="0.8">
    <stop offset="0" stop-color="#06301a"/><stop offset="0.6" stop-color="#03170b"/><stop offset="1" stop-color="#010603"/>
  </radialGradient>
  <filter id="glow" x="-5%" y="-20%" width="110%" height="140%"><feGaussianBlur stdDeviation="3.5"/></filter>
  {vignette(0.95)}
  {scanlines(0.45, 3)}
</defs>
<rect width="100%" height="100%" fill="url(#screen)"/>
<g font-family="MesloLGS Nerd Font Mono" font-size="{fs}" filter="url(#glow)" opacity="0.9">{''.join(texts)}{cursor}</g>
<g font-family="MesloLGS Nerd Font Mono" font-size="{fs}">{''.join(texts)}{cursor}</g>
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


render("deus-ex", deus_ex())
render("samurai", samurai())
render("fallout", fallout())

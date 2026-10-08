# Hyprland Workflow + Keybindings Guide

This README focuses on how to actually **use** the Hyprland setup day to day.

It assumes your main modifier key is:

```text
SUPER = Windows key / Command key
```

---

## Core Mental Model

Hyprland is a tiling window manager.

That means:

```text
open app → Hyprland places it automatically
```

You mostly control:

- which workspace you are on
- whether a window is tiled, floating, fullscreen, pinned, or hidden
- where windows go
- how windows resize
- which temporary tools live in hidden workspaces

---

## Daily Driver Keybinds

These are the keybinds to learn first.

| Keybind | Action | Use Case |
|---|---|---|
| `SUPER + Enter` | Open terminal | Start almost anything |
| `SUPER + Space` | Open app launcher | Launch apps by name |
| `SUPER + Q` | Close active window | Quit/remove current window |
| `SUPER + F` | Toggle fullscreen | Focus on one app |
| `SUPER + V` | Toggle floating | Free-position a window |
| `SUPER + Y` | Pin active floating window | Make a floating window follow all workspaces |
| `SUPER + Escape` | Lock screen (hyprlock) | Step away safely |
| `SUPER + B` | Show/hide the top bar | Check time, battery, etc. |
| `SUPER + E` | File manager (thunar) | Browse files |
| `SUPER + Shift + E` | Terminal file manager (yazi) | Fast keyboard file browsing |

---

## Opening Apps

### Open a terminal

```text
SUPER + Enter
```

### Open app launcher

```text
SUPER + Space
```

Then type the app name, such as:

```text
firefox
alacritty
thunar
pavucontrol
```

### Open another window in current workspace

Just launch another app. Hyprland will tile it automatically.

Example:

```text
SUPER + Enter
```

opens another terminal in the same workspace.

---

## Workspaces

Workspaces are your main organization tool.

| Keybind | Action |
|---|---|
| `SUPER + 1` | Go to workspace 1 |
| `SUPER + 2` | Go to workspace 2 |
| `SUPER + 3` | Go to workspace 3 |
| `SUPER + 0` | Go to workspace 10 |
| `SUPER + ,` | Previous workspace |
| `SUPER + .` | Next workspace |
| `SUPER + Mouse Wheel` | Cycle workspaces |
| `SUPER + /` | Go to previous workspace |

### Suggested workspace pattern

Use a simple convention:

| Workspace | Suggested Use |
|---|---|
| 1 | Terminal / system |
| 2 | Browser |
| 3 | Code / editor |
| 4 | Notes / Obsidian |
| 5 | Communication |
| 6–10 | Temporary project spaces |

The exact numbers matter less than consistency.

---

## Moving Windows Between Workspaces

### Move window silently

```text
SUPER + Shift + 1
```

Moves the active window to workspace 1 but keeps you where you are.

### Move window and follow it

```text
SUPER + Ctrl + 1
```

Moves the active window to workspace 1 and takes you there.

### Practical difference

| Bind Type | Meaning |
|---|---|
| `SUPER + Shift + number` | Send it away |
| `SUPER + Ctrl + number` | Take it with me |

---

## Fullscreen vs Floating vs Pinning

These are different concepts.

| Keybind | Mode | Meaning |
|---|---|---|
| `SUPER + F` | Fullscreen | Window takes over the workspace |
| `SUPER + V` | Floating | Window leaves the tiled layout |
| `SUPER + Y` | Pinned | Floating window appears across workspaces |

### Fullscreen

Use this when you want one thing to dominate your attention.

```text
SUPER + F
```

Good for:

- browser reading
- videos
- coding focus
- dashboards

### Floating

Use this when the window should behave more like a normal draggable window.

```text
SUPER + V
```

Good for:

- calculators
- settings panels
- temporary terminals
- music players
- small notes

Move a floating window:

```text
SUPER + left mouse drag
```

Resize a floating window:

```text
SUPER + right mouse drag
```

### Pinning

Pinning works best with floating windows.

```text
SUPER + V
SUPER + Y
```

That makes the current floating window follow you across workspaces.

Good for:

- small terminal
- timer
- music controls
- reference note

To unpin:

```text
SUPER + Y
```

---

## Special Workspace

You have a hidden special workspace.

| Keybind | Action |
|---|---|
| `SUPER + =` | Show/hide special workspace |
| `SUPER + -` | Move active window into special workspace |

### How to use it

1. Focus a window.
2. Move it into the hidden special workspace:

```text
SUPER + -
```

3. Show or hide it:

```text
SUPER + =
```

### Take a window back out

While the special workspace is visible and the window is focused:

```text
SUPER + Ctrl + 1
```

That moves it back to workspace 1 and follows it there.

### Good uses

- temporary terminal
- system monitor
- music player
- notes
- anything you want hidden but quickly accessible

---

## Scratchpad

You also have a second hidden workspace named:

```text
scratchpad
```

| Keybind | Action |
|---|---|
| `SUPER + F1` | Show/hide scratchpad |
| `SUPER + Alt + Shift + F1` | Move active window into scratchpad |

### How to use it

1. Focus a window.
2. Move it into scratchpad:

```text
SUPER + Alt + Shift + F1
```

3. Toggle scratchpad:

```text
SUPER + F1
```

### Take a window back out

Show scratchpad, focus the window, then:

```text
SUPER + Ctrl + 1
```

### Difference from special workspace

| Feature | Toggle | Move Window In |
|---|---|---|
| Special workspace | `SUPER + =` | `SUPER + -` |
| Scratchpad | `SUPER + F1` | `SUPER + Alt + Shift + F1` |

They are similar. The scratchpad is just a named hidden workspace.

Use one for terminals and the other for notes/tools if you want separation.

---

## Resizing Windows

You have two resize workflows.

### Resize mode

Enter resize mode:

```text
SUPER + R
```

Then resize with:

```text
h / j / k / l
```

or:

```text
Arrow keys
```

Exit resize mode:

```text
Escape
```

### Direct resize

Without entering resize mode:

```text
SUPER + Ctrl + Shift + h
SUPER + Ctrl + Shift + j
SUPER + Ctrl + Shift + k
SUPER + Ctrl + Shift + l
```

or use arrow keys with the same modifier combo.

### When to use each

| Method | Best For |
|---|---|
| `SUPER + R` resize mode | Careful layout adjustment |
| Direct resize binds | Quick one-off fixes |
| Mouse resize | Floating windows |

---

## Gaps

| Keybind | Action |
|---|---|
| `SUPER + G` | Remove gaps |
| `SUPER + Shift + G` | Restore gaps |

### Why this matters

Removing gaps gives you maximum screen space.

Restoring gaps gives you the normal aesthetic layout again.

Good for:

- small laptop screens
- spreadsheets
- dashboards
- dense terminal work

---

## Vim-Style Focus

| Keybind | Action |
|---|---|
| `SUPER + h / j / k / l` | Focus window left / down / up / right |
| `SUPER + Shift + h / j / k / l` | Move window left / down / up / right |

Arrow keys still work for both. Resize stays on `SUPER + Ctrl + Shift + h/j/k/l`.

Keys moved to make room: lock is now `SUPER + Escape` (was `L`), split toggle is `SUPER + T`
(was `J`), and window grouping is `SUPER + W` (was `K`).

---

## Split Direction

```text
SUPER + T
```

This toggles the split direction for the next tiled window.

Use it when Hyprland places windows in a way that does not match what you want.

Simple mental model:

```text
SUPER + T → change how the next split behaves
```

---

## Touchpad Gestures

Your config includes gestures.

| Gesture | Action |
|---|---|
| 4-finger horizontal swipe | Switch workspace |
| 3-finger up | Fullscreen |
| 3-finger left | Toggle floating |

The old 3-finger-down "close window" gesture was removed because it was too easy to trigger by accident.

---

## Practical Workflows

### Focus workflow

Use when you want deep work.

```text
SUPER + 3      # go to coding/workspace
SUPER + Space  # launch editor/app
SUPER + F      # fullscreen if needed
```

### Utility terminal workflow

Use when you want a terminal available everywhere.

```text
SUPER + Enter  # open terminal
SUPER + V      # make floating
SUPER + Y      # pin it
```

Now it follows you across workspaces.

### Hidden terminal workflow

Use when you want a terminal hidden until needed.

```text
SUPER + Enter  # open terminal
SUPER + -      # move to special workspace
SUPER + =      # show/hide it
```

### Scratchpad notes workflow

Use for notes, calculator, or temporary references.

```text
open notes/calculator
SUPER + Alt + Shift + F1
SUPER + F1
```

Now the tool lives in the scratchpad.

### Send clutter away

Use when a window is useful but not needed right now.

```text
SUPER + Shift + 5
```

That sends the active window to workspace 5 without following it.

### Bring work with you

Use when a window belongs somewhere else and you want to go there too.

```text
SUPER + Ctrl + 4
```

That moves the active window to workspace 4 and follows it.

---

## Recovery Patterns

### Window is stuck in special workspace

```text
SUPER + =
focus window
SUPER + Ctrl + 1
```

### Window is stuck in scratchpad

```text
SUPER + F1
focus window
SUPER + Ctrl + 1
```

### Window follows you everywhere

It is probably pinned.

Focus it and press:

```text
SUPER + Y
```

### Window is floating and you want it tiled again

```text
SUPER + V
```

### Screen is dimmed but nothing shows

You probably opened an empty special workspace or scratchpad.

Press the same toggle again:

```text
SUPER + =
```

or:

```text
SUPER + F1
```

---

## Recommended Learning Order

Learn the config in this order:

1. `SUPER + Enter`
2. `SUPER + Space`
3. `SUPER + 1–0`
4. `SUPER + Shift + number`
5. `SUPER + Ctrl + number`
6. `SUPER + F`
7. `SUPER + V`
8. `SUPER + Y`
9. `SUPER + =` and `SUPER + -`
10. `SUPER + F1` scratchpad
11. `SUPER + R` resize mode

Do not try to memorize everything at once.

---

## Cheat Sheet

```text
SUPER + Enter          terminal
SUPER + Space          launcher
SUPER + Q              close window
SUPER + F              fullscreen
SUPER + V              float/tile
SUPER + Y              pin/unpin floating window
SUPER + Escape         lock
SUPER + h/j/k/l        focus left/down/up/right
SUPER + Shift + h/j/k/l  move window left/down/up/right
SUPER + T              toggle split direction
SUPER + W              toggle window group
SUPER + B              show/hide bar
SUPER + E              thunar
SUPER + Shift + E      yazi

SUPER + 1-9/0          switch workspace
SUPER + Shift + 1-9/0  move window silently
SUPER + Ctrl + 1-9/0   move window and follow

SUPER + =              toggle special workspace
SUPER + -              move window to special workspace

SUPER + F1             toggle scratchpad
SUPER + Alt+Shift+F1   move window to scratchpad

SUPER + R              resize mode
Escape                 exit resize mode

SUPER + G              remove gaps
SUPER + Shift + G      restore gaps

SUPER + left drag      move floating window
SUPER + right drag     resize floating window
```

---

## Best Default Workflow

A simple daily setup:

```text
Workspace 1 → terminal/system
Workspace 2 → browser
Workspace 3 → code
Workspace 4 → notes
Special workspace → hidden utility terminal
Scratchpad → temporary notes/calculator
Pinned floating window → tool you need everywhere
```

The goal is not to use every feature.

The goal is to make window movement cheap enough that your desktop stops getting in the way.

---

## Idle and Lock

Handled by `hypridle` (settings in `hypridle.conf`, lock screen in `hyprlock.conf`):

| Idle time | What happens |
|---|---|
| 4 min | Screen dims |
| 5 min | Locks |
| 5.5 min | Screen turns off |
| Lid close / sleep | Locks first |

This config is Lua (`hyprland.lua`), so `hyprctl dispatch` commands use Lua syntax, e.g.
`hyprctl dispatch 'hl.dsp.dpms({ action = "off" })'` — not the `dispatch dpms off` form most guides show.

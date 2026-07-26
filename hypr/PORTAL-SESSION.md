# Portal / systemd session integration

## TL;DR

Hyprland is launched bare from a TTY (via greetd), which never brings up the
systemd `graphical-session.target`. `xdg-desktop-portal` **refuses to start**
without that target, so portal-based **screen sharing** (Firefox/Chromium/OBS
`ScreenCast`) and Flatpak file pickers silently fail. We fix it with a minimal
`hyprland-session.target` systemd user unit that pulls the target up, plus an
env push, both driven from `hypr/autostart`.

Plain screenshots via `grim`/`slurp` (our keybinds) do **not** use the portal
and worked fine without this — this is specifically about the portal path.

## The problem

`xdg-desktop-portal.service` (Fedora) is configured with:

```
PartOf=graphical-session.target
Requisite=graphical-session.target   # <-- refuses to start unless target is ALREADY active
After=graphical-session.target
```

Its D-Bus name `org.freedesktop.portal.Desktop` is activated *through* systemd
(`SystemdService=xdg-desktop-portal.service`), so if the unit can't start, even
lazy D-Bus activation fails with:

```
Could not activate remote peer 'org.freedesktop.portal.Desktop': startup job failed
```

`graphical-session.target` is a passive target: it has
`RefuseManualStart=yes` and only becomes active when a *session unit* pulls it
in via `BindsTo`. Desktop environments ship such a unit (`gnome-session.target`,
`sway-session.target`, …). A hand-rolled bare-TTY Hyprland launch has none, so
the target is never reached.

Two secondary symptoms, same root cause:
- The Wayland session env (`WAYLAND_DISPLAY`, `XDG_CURRENT_DESKTOP`,
  `XDG_SESSION_TYPE`) was not in the systemd/D-Bus activation environment, so
  even a manually-started portal picked the wrong backend / couldn't reach the
  compositor.

## Decision: manual session target (not uwsm)

Two standard fixes exist:

| Option | What it is | Verdict |
|--------|-----------|---------|
| **A. Manual `hyprland-session.target`** | A ~8-line user unit that `BindsTo` graphical-session.target, started from `autostart` after an env push. | **Chosen.** |
| B. `uwsm` (Universal Wayland Session Manager) | Launch Hyprland *through* uwsm, which creates the session target + imports env + orders units automatically. Hyprland's officially recommended path. | Rejected for now. |

**Why A over B:** this dotfiles setup is a deliberate, hand-tuned bare-TTY launch
(greetd → Hyprland) with a custom fish `autostart`. Option A slots into that with
a few tracked lines and is fully reversible without changing how Hyprland is
launched. uwsm is the cleaner long-term answer if we ever want a fully
systemd-managed session, but it changes the launch entrypoint and would fight the
existing manual env plumbing. Revisit uwsm if we add more units that need proper
`graphical-session.target` ordering/teardown.

## What was changed

1. **`hypr/systemd/hyprland-session.target`** (new, tracked) — the session unit
   that `BindsTo=graphical-session.target`.
2. **`init.sh` → `init_portal_session()`** — symlinks that unit into
   `~/.config/systemd/user/` and runs `daemon-reload`. Idempotent; part of the
   normal bootstrap so **new machines get it automatically** (no manual steps).
3. **`hypr/autostart`** — before the tmux early-exits, pushes the session env
   into systemd + D-Bus (`dbus-update-activation-environment --systemd --all`)
   then `systemctl --user start hyprland-session.target`.
   - Note: this block was also moved above the `tmux has-session … exit 0`
     early-exits, which previously skipped all env setup when a `default` tmux
     session already existed — the original reason the env was missing.

## Verifying on a machine

```fish
# 1. target active?
systemctl --user is-active graphical-session.target        # -> active
systemctl --user is-active hyprland-session.target         # -> active

# 2. env present in the activation environment?
systemctl --user show-environment | grep -E 'WAYLAND_DISPLAY|XDG_CURRENT_DESKTOP'

# 3. portal frontend activates over D-Bus?
busctl --user introspect org.freedesktop.portal.Desktop \
    /org/freedesktop/portal/desktop org.freedesktop.portal.Screenshot
#   -> lists the Screenshot interface (no "startup job failed")

# 4. hyprland backend connected to the compositor?
journalctl --user -u xdg-desktop-portal-hyprland.service | grep -i screencopy
#   -> "[screencopy] init successful"
```

## Notes

- Portal backend routing is already correct system-wide via
  `/usr/share/xdg-desktop-portal/hyprland-portals.conf` (`default=hyprland;gtk`).
  No user `~/.config/xdg-desktop-portal/portals.conf` is needed.
- Requires the `xdg-desktop-portal-hyprland` package (installed on the current
  machine as of writing).

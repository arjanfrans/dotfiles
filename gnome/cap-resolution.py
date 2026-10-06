#!/usr/bin/python3
from gi.repository import Gio, GLib

MAX_WIDTH = 2000
PERSISTENT = 2

proxy = Gio.DBusProxy.new_for_bus_sync(
    Gio.BusType.SESSION, Gio.DBusProxyFlags.NONE, None,
    "org.gnome.Mutter.DisplayConfig",
    "/org/gnome/Mutter/DisplayConfig",
    "org.gnome.Mutter.DisplayConfig",
    None,
)
serial, monitors, logical_monitors, _ = proxy.call_sync(
    "GetCurrentState", None, Gio.DBusCallFlags.NONE, -1, None
).unpack()


def find_mode(modes, prop):
    return next(m for m in modes if m[6].get(prop))


def best_fitting_mode(modes):
    native = find_mode(modes, "is-preferred")
    same_aspect = [m for m in modes if m[1] * native[2] == m[2] * native[1] and m[1] <= MAX_WIDTH]
    return max(same_aspect, key=lambda m: (m[1], m[3]), default=None)


modes_by_connector = {spec[0]: modes for spec, modes, _ in monitors}
config = []
resized = []

for x, y, scale, transform, primary, specs, _ in logical_monitors:
    new_scale = scale
    entries = []
    for spec in specs:
        modes = modes_by_connector[spec[0]]
        mode = find_mode(modes, "is-current")
        if spec[0].startswith("eDP") and mode[1] > MAX_WIDTH and (fitting := best_fitting_mode(modes)):
            old_size = (round(mode[1] / scale), round(mode[2] / scale))
            mode, new_scale = fitting, 1.0
            new_size = (round(mode[1] / new_scale), round(mode[2] / new_scale))
            resized.append((x, y, old_size, new_size))
            print(f"{spec[0]}: {mode[0]} @ scale {new_scale:.2f}")
        entries.append((spec[0], mode[0], {}))
    config.append([x, y, new_scale, transform, primary, entries])

if not resized:
    raise SystemExit(0)

for x0, y0, (old_w, old_h), (new_w, new_h) in resized:
    for lm in config:
        if lm[0] >= x0 + old_w:
            lm[0] += new_w - old_w
        if lm[1] >= y0 + old_h:
            lm[1] += new_h - old_h

proxy.call_sync(
    "ApplyMonitorsConfig",
    GLib.Variant("(uua(iiduba(ssa{sv}))a{sv})", (serial, PERSISTENT, [tuple(lm) for lm in config], {})),
    Gio.DBusCallFlags.NONE, -1, None,
)

#!/usr/bin/python3
import sys

from gi.repository import Gio, GLib

MAX_WIDTH = 2000
PERSISTENT = 2
SETTLE_MS = 1000

proxy = Gio.DBusProxy.new_for_bus_sync(
    Gio.BusType.SESSION, Gio.DBusProxyFlags.NONE, None,
    "org.gnome.Mutter.DisplayConfig",
    "/org/gnome/Mutter/DisplayConfig",
    "org.gnome.Mutter.DisplayConfig",
    None,
)


def find_mode(modes, prop):
    return next(m for m in modes if m[6].get(prop))


def best_fitting_mode(modes):
    native = find_mode(modes, "is-preferred")
    same_aspect = [m for m in modes if m[1] * native[2] == m[2] * native[1] and m[1] <= MAX_WIDTH]
    return max(same_aspect, key=lambda m: (m[1], m[3]), default=None)


def target_mode_and_scale(modes):
    native = find_mode(modes, "is-preferred")
    if native[1] <= MAX_WIDTH:
        return None
    integer_scales = [s for s in native[5] if s.is_integer() and native[1] / s <= MAX_WIDTH]
    if integer_scales:
        return native, min(integer_scales)
    fitting = best_fitting_mode(modes)
    return (fitting, 1.0) if fitting else None


def cap_resolution():
    serial, monitors, logical_monitors, _ = proxy.call_sync(
        "GetCurrentState", None, Gio.DBusCallFlags.NONE, -1, None
    ).unpack()

    modes_by_connector = {spec[0]: modes for spec, modes, _ in monitors}
    config = []
    resized = []

    for x, y, scale, transform, primary, specs, _ in logical_monitors:
        new_scale = scale
        entries = []
        for spec in specs:
            modes = modes_by_connector[spec[0]]
            mode = find_mode(modes, "is-current")
            target = target_mode_and_scale(modes) if spec[0].startswith("eDP") else None
            if target and (target[0][0], target[1]) != (mode[0], scale):
                old_size = (round(mode[1] / scale), round(mode[2] / scale))
                mode, new_scale = target
                new_size = (round(mode[1] / new_scale), round(mode[2] / new_scale))
                resized.append((x, y, old_size, new_size))
                print(f"{spec[0]}: {mode[0]} @ scale {new_scale:.2f}", flush=True)
            entries.append((spec[0], mode[0], {}))
        config.append([x, y, new_scale, transform, primary, entries])

    if not resized:
        return

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


def watch():
    pending = None

    def run_settled():
        nonlocal pending
        pending = None
        try:
            cap_resolution()
        except GLib.Error as e:
            print(e.message, file=sys.stderr, flush=True)
        return GLib.SOURCE_REMOVE

    def on_signal(_proxy, _sender, signal, _params):
        nonlocal pending
        if signal != "MonitorsChanged":
            return
        if pending:
            GLib.source_remove(pending)
        pending = GLib.timeout_add(SETTLE_MS, run_settled)

    proxy.connect("g-signal", on_signal)
    GLib.MainLoop().run()


cap_resolution()
if "--watch" in sys.argv:
    watch()

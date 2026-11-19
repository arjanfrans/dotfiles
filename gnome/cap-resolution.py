#!/usr/bin/python3
import json
import sys
from pathlib import Path

from gi.repository import Gio, GLib

MAX_WIDTH = 2000
PERSISTENT = 2
SETTLE_MS = 1000
LAYOUTS_FILE = Path(GLib.get_user_state_dir()) / "cap-resolution" / "layouts.json"

last_layout_key = None

proxy = Gio.DBusProxy.new_for_bus_sync(
    Gio.BusType.SESSION, Gio.DBusProxyFlags.NONE, None,
    "org.gnome.Mutter.DisplayConfig",
    "/org/gnome/Mutter/DisplayConfig",
    "org.gnome.Mutter.DisplayConfig",
    None,
)


def find_mode(modes, prop):
    return next(m for m in modes if m[6].get(prop))


def largest_fitting_mode(modes, native):
    same_aspect = [m for m in modes if m[1] * native[2] == m[2] * native[1] and m[1] <= MAX_WIDTH]
    return max(same_aspect, key=lambda m: (m[1], m[3]), default=None)


def capped_mode(modes):
    native = find_mode(modes, "is-preferred")
    return largest_fitting_mode(modes, native) if native[1] > MAX_WIDTH else None


def is_builtin(logical_monitor):
    return any(entry[0].startswith("eDP") for entry in logical_monitor[5])


def preferred_primary(config):
    if len(config) >= 3:
        return sorted(config, key=lambda lm: (lm[0], lm[1]))[len(config) // 2]
    externals = [lm for lm in config if not is_builtin(lm)]
    return externals[0] if len(config) == 2 and len(externals) == 1 else None


def load_layouts():
    try:
        return json.loads(LAYOUTS_FILE.read_text())
    except (OSError, ValueError):
        return {}


def save_layout(key, layout):
    layouts = load_layouts()
    if layouts.get(key) == layout:
        return
    layouts[key] = layout
    LAYOUTS_FILE.parent.mkdir(parents=True, exist_ok=True)
    LAYOUTS_FILE.write_text(json.dumps(layouts, indent=2))


def logical_monitor_id(lm, ids_by_connector):
    return ",".join(sorted(ids_by_connector[entry[0]] for entry in lm[5]))


def effective_primary(config):
    primaries = [lm for lm in config if lm[4]]
    return next((lm for lm in primaries if not is_builtin(lm)), primaries[0] if primaries else None)


def current_layout(config, ids_by_connector):
    primary = effective_primary(config)
    return {logical_monitor_id(lm, ids_by_connector): [lm[0], lm[1], lm is primary] for lm in config}


def restore_layout(config, saved, ids_by_connector):
    changed = False
    for lm in config:
        x, y, primary = saved[logical_monitor_id(lm, ids_by_connector)]
        if [lm[0], lm[1]] != [x, y] or (primary and not lm[4]):
            changed = True
        lm[0], lm[1], lm[4] = x, y, primary
    if changed:
        print("restored saved layout", flush=True)
    return changed


def cap_resolution():
    serial, monitors, logical_monitors, _ = proxy.call_sync(
        "GetCurrentState", None, Gio.DBusCallFlags.NONE, -1, None
    ).unpack()

    modes_by_connector = {spec[0]: modes for spec, modes, _ in monitors}
    ids_by_connector = {spec[0]: ":".join(spec[1:4]) for spec, _, _ in monitors}
    config = []
    resized = []

    for x, y, scale, transform, primary, specs, _ in logical_monitors:
        mirrored = len(specs) > 1
        entries = []
        for spec in specs:
            modes = modes_by_connector[spec[0]]
            current = find_mode(modes, "is-current")
            mode = current if mirrored else capped_mode(modes) or current
            entries.append((spec[0], mode[0], {}))
        if mode is not current or scale != 1.0:
            old_size = (round(current[1] / scale), round(current[2] / scale))
            resized.append((x, y, old_size, (mode[1], mode[2])))
            print(f"{', '.join(spec[0] for spec in specs)}: {mode[0]} @ scale 1", flush=True)
        config.append([x, y, 1.0, transform, primary, entries])

    for x0, y0, (old_w, old_h), (new_w, new_h) in resized:
        for lm in config:
            if lm[0] >= x0 + old_w:
                lm[0] += new_w - old_w
            if lm[1] >= y0 + old_h:
                lm[1] += new_h - old_h

    global last_layout_key
    key = "|".join(sorted(logical_monitor_id(lm, ids_by_connector) for lm in config))
    monitors_changed = key != last_layout_key
    last_layout_key = key
    saved = load_layouts().get(key)
    layout_changed = False

    if monitors_changed and saved and set(saved) == set(current_layout(config, ids_by_connector)):
        layout_changed = restore_layout(config, saved, ids_by_connector)
    elif monitors_changed:
        primary = preferred_primary(config)
        layout_changed = primary is not None and not primary[4]
        if layout_changed:
            for lm in config:
                lm[4] = lm is primary
            print(f"primary: {primary[5][0][0]}", flush=True)

    save_layout(key, current_layout(config, ids_by_connector))

    if not resized and not layout_changed:
        return

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

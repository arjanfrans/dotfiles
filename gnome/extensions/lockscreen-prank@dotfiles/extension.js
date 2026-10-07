import Clutter from 'gi://Clutter';
import Gio from 'gi://Gio';
import GLib from 'gi://GLib';
import {Extension} from 'resource:///org/gnome/shell/extensions/extension.js';
import * as Main from 'resource:///org/gnome/shell/ui/main.js';
import {PrankOverlay} from './prankOverlay.js';

const ASSETS_DIR = GLib.build_filenamev([GLib.get_home_dir(), '.dotfiles/private/lockscreen-prank']);
const FALLBACK_SCREENSHOT = GLib.build_filenamev([ASSETS_DIR, 'desktop.png']);
const MONITOR_SCREENSHOT_PATTERN = /^desktop-(.+)\.png$/;
const MIDDLE_FINGER = GLib.build_filenamev([ASSETS_DIR, 'middle-finger.gif']);
const HOTKEY_KEYVALS = [Clutter.KEY_p, Clutter.KEY_P];
const HOTKEY_MODIFIERS = Clutter.ModifierType.CONTROL_MASK | Clutter.ModifierType.MOD1_MASK;
const RELEVANT_MODIFIERS = HOTKEY_MODIFIERS | Clutter.ModifierType.SHIFT_MASK | Clutter.ModifierType.SUPER_MASK;

function isHotkey(event) {
    return event.type() === Clutter.EventType.KEY_PRESS &&
        HOTKEY_KEYVALS.includes(event.get_key_symbol()) &&
        (event.get_state() & RELEVANT_MODIFIERS) === HOTKEY_MODIFIERS;
}

function isIntruderInput(event) {
    const type = event.type();
    return type === Clutter.EventType.KEY_PRESS || type === Clutter.EventType.MOTION;
}

function screenshotsByMonitorIndex() {
    const monitorManager = global.backend.get_monitor_manager();
    const screenshots = new Map();
    const enumerator = Gio.File.new_for_path(ASSETS_DIR).enumerate_children('standard::name', Gio.FileQueryInfoFlags.NONE, null);
    for (const info of enumerator) {
        const connector = info.get_name().match(MONITOR_SCREENSHOT_PATTERN)?.[1];
        const index = connector ? monitorManager.get_monitor_for_connector(connector) : -1;
        if (index >= 0)
            screenshots.set(index, GLib.build_filenamev([ASSETS_DIR, info.get_name()]));
    }
    return screenshots;
}

export default class LockscreenPrankExtension extends Extension {
    enable() {
        this._lockDialogGroup = Main.screenShield._lockDialogGroup;
        this._eventId = this._lockDialogGroup.connect('captured-event', (_, event) => this._onEvent(event));
        this._lockedId = Main.screenShield.connect('locked-changed', () => {
            if (!Main.screenShield.locked)
                this._stopPrank();
        });
    }

    disable() {
        this._lockDialogGroup.disconnect(this._eventId);
        Main.screenShield.disconnect(this._lockedId);
        this._stopPrank();
        this._lockDialogGroup = null;
    }

    _onEvent(event) {
        if (isHotkey(event)) {
            if (this._overlay)
                this._stopPrank();
            else
                this._startPrank();
            return Clutter.EVENT_STOP;
        }

        if (!this._overlay)
            return Clutter.EVENT_PROPAGATE;

        if (isIntruderInput(event))
            this._overlay.onIntruderInput();
        return Clutter.EVENT_STOP;
    }

    _startPrank() {
        const screenshots = screenshotsByMonitorIndex();
        this._overlay = new PrankOverlay(index => screenshots.get(index) ?? FALLBACK_SCREENSHOT, MIDDLE_FINGER);
        this._overlay.add_constraint(new Clutter.BindConstraint({
            source: this._lockDialogGroup,
            coordinate: Clutter.BindCoordinate.SIZE,
        }));
        this._lockDialogGroup.add_child(this._overlay);
    }

    _stopPrank() {
        this._overlay?.destroy();
        this._overlay = null;
    }
}

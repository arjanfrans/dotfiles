import Clutter from 'gi://Clutter';
import GLib from 'gi://GLib';
import {Extension} from 'resource:///org/gnome/shell/extensions/extension.js';
import * as Main from 'resource:///org/gnome/shell/ui/main.js';
import {PrankOverlay} from './prankOverlay.js';

const ASSETS_DIR = GLib.build_filenamev([GLib.get_home_dir(), '.dotfiles/private/lockscreen-prank']);
const SCREENSHOT = GLib.build_filenamev([ASSETS_DIR, 'desktop.png']);
const MIDDLE_FINGER = GLib.build_filenamev([ASSETS_DIR, 'middle-finger.gif']);
const HOTKEY_KEYVALS = [Clutter.KEY_p, Clutter.KEY_P];
const HOTKEY_MODIFIERS = Clutter.ModifierType.CONTROL_MASK | Clutter.ModifierType.MOD1_MASK;
const RELEVANT_MODIFIERS = HOTKEY_MODIFIERS | Clutter.ModifierType.SHIFT_MASK | Clutter.ModifierType.SUPER_MASK;

function isHotkey(event) {
    return event.type() === Clutter.EventType.KEY_PRESS &&
        HOTKEY_KEYVALS.includes(event.get_key_symbol()) &&
        (event.get_state() & RELEVANT_MODIFIERS) === HOTKEY_MODIFIERS;
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

        if (event.type() === Clutter.EventType.KEY_PRESS)
            this._overlay.onKeyPress();
        return Clutter.EVENT_STOP;
    }

    _startPrank() {
        this._overlay = new PrankOverlay(SCREENSHOT, MIDDLE_FINGER);
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

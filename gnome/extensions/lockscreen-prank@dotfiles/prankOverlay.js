import GLib from 'gi://GLib';
import GObject from 'gi://GObject';
import St from 'gi://St';
import * as Main from 'resource:///org/gnome/shell/ui/main.js';
import {PrankScreen} from './prankScreen.js';

const FINGER_VISIBLE_MS = 12500;
const ARM_DELAY_MS = 2000;

export const PrankOverlay = GObject.registerClass(
class PrankOverlay extends St.Widget {
    _init(screenshotForMonitor, fingerPath) {
        super._init({reactive: true});

        this._screens = Main.layoutManager.monitors.map(monitor =>
            new PrankScreen(monitor, screenshotForMonitor(monitor.index), fingerPath));
        for (const screen of this._screens)
            this.add_child(screen);

        this._armed = false;
        this._armTimeoutId = GLib.timeout_add(GLib.PRIORITY_DEFAULT, ARM_DELAY_MS, () => {
            this._armTimeoutId = 0;
            this._armed = true;
            return GLib.SOURCE_REMOVE;
        });
        this._hideTimeoutId = 0;
        this.connect('destroy', () => this._clearTimeouts());
    }

    onIntruderInput() {
        if (!this._armed)
            return;

        for (const screen of this._screens)
            screen.showFinger();
        this._scheduleHideFingers();
    }

    _scheduleHideFingers() {
        if (this._hideTimeoutId)
            GLib.source_remove(this._hideTimeoutId);
        this._hideTimeoutId = GLib.timeout_add(GLib.PRIORITY_DEFAULT, FINGER_VISIBLE_MS, () => {
            this._hideTimeoutId = 0;
            for (const screen of this._screens)
                screen.hideFinger();
            return GLib.SOURCE_REMOVE;
        });
    }

    _clearTimeouts() {
        if (this._armTimeoutId)
            GLib.source_remove(this._armTimeoutId);
        if (this._hideTimeoutId)
            GLib.source_remove(this._hideTimeoutId);
        this._armTimeoutId = 0;
        this._hideTimeoutId = 0;
    }
});

import Clutter from 'gi://Clutter';
import GLib from 'gi://GLib';
import GObject from 'gi://GObject';
import St from 'gi://St';
import * as Main from 'resource:///org/gnome/shell/ui/main.js';
import {AnimatedImage} from './animatedImage.js';

const SLIDE_UP_DURATION = 2000;
const SLIDE_DOWN_DURATION = 400;
const FINGER_VISIBLE_MS = 10000;
const ARM_DELAY_MS = 2000;
const FINGER_HEIGHT_RATIO = 0.6;

export const PrankOverlay = GObject.registerClass(
class PrankOverlay extends St.Widget {
    _init(screenshotPath, fingerPath) {
        super._init({
            reactive: true,
            style: `background-image: url("file://${screenshotPath}"); background-size: cover;`,
        });

        const monitor = Main.layoutManager.primaryMonitor;
        this._fingerArea = new St.Widget({
            x: monitor.x,
            y: monitor.y,
            width: monitor.width,
            height: monitor.height,
            clip_to_allocation: true,
            layout_manager: new Clutter.BinLayout(),
        });
        this._finger = new AnimatedImage(fingerPath, {
            x_align: Clutter.ActorAlign.CENTER,
            y_align: Clutter.ActorAlign.END,
            translation_y: monitor.height,
        });
        this._finger.height = monitor.height * FINGER_HEIGHT_RATIO;
        this._finger.width = this._finger.height * this._finger.aspectRatio;
        this._fingerArea.add_child(this._finger);
        this.add_child(this._fingerArea);

        this._armed = false;
        this._armTimeoutId = GLib.timeout_add(GLib.PRIORITY_DEFAULT, ARM_DELAY_MS, () => {
            this._armTimeoutId = 0;
            this._armed = true;
            return GLib.SOURCE_REMOVE;
        });
        this._hideTimeoutId = 0;
        this.connect('destroy', () => this._clearTimeouts());
    }

    onKeyPress() {
        if (this._armed)
            this._showFinger();
    }

    _showFinger() {
        if (!this._finger.playing)
            this._finger.play();

        this._finger.remove_all_transitions();
        this._finger.ease({
            translation_y: 0,
            duration: SLIDE_UP_DURATION,
            mode: Clutter.AnimationMode.EASE_OUT_BACK,
        });
        this._scheduleHideFinger();
    }

    _hideFinger() {
        this._finger.ease({
            translation_y: this._fingerArea.height,
            duration: SLIDE_DOWN_DURATION,
            mode: Clutter.AnimationMode.EASE_IN_QUAD,
            onComplete: () => this._finger.stop(),
        });
    }

    _scheduleHideFinger() {
        if (this._hideTimeoutId)
            GLib.source_remove(this._hideTimeoutId);
        this._hideTimeoutId = GLib.timeout_add(GLib.PRIORITY_DEFAULT, FINGER_VISIBLE_MS, () => {
            this._hideTimeoutId = 0;
            this._hideFinger();
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

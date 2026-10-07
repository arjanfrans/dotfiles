import GLib from 'gi://GLib';
import GObject from 'gi://GObject';
import St from 'gi://St';
import * as Main from 'resource:///org/gnome/shell/ui/main.js';
import {PrankScreen, SLIDE_UP_DURATION} from './prankScreen.js';
import {ReactionRecorder} from './reactionRecorder.js';

const FINGER_VISIBLE_MS = 12500;
const ARM_DELAY_MS = 2000;
const RECORD_DELAY_MS = SLIDE_UP_DURATION / 2;
const RECORD_DURATION_MS = 5000;

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
        this._fingersShown = false;
        this._recorder = null;
        this._recordTimeoutId = 0;
        this._recordStopTimeoutId = 0;
        this._hideTimeoutId = 0;
        this.connect('destroy', () => {
            this._clearTimeouts();
            this._discardRecording();
        });
    }

    onIntruderInput() {
        if (!this._armed)
            return;

        if (!this._fingersShown)
            this._showFingers();
        this._scheduleHideFingers();
    }

    _showFingers() {
        this._fingersShown = true;
        for (const screen of this._screens)
            screen.showFinger();
        this._recordTimeoutId = GLib.timeout_add(GLib.PRIORITY_DEFAULT, RECORD_DELAY_MS, () => {
            this._recordTimeoutId = 0;
            this._startRecording();
            return GLib.SOURCE_REMOVE;
        });
    }

    _startRecording() {
        this._recorder = new ReactionRecorder();
        this._recordStopTimeoutId = GLib.timeout_add(GLib.PRIORITY_DEFAULT, RECORD_DURATION_MS, () => {
            this._recordStopTimeoutId = 0;
            this._recorder.stop(frames => this._playReaction(frames));
            return GLib.SOURCE_REMOVE;
        });
    }

    _playReaction(frames) {
        if (frames.length === 0)
            return;

        for (const screen of this._screens)
            screen.playReaction(frames);
    }

    _hideFingers() {
        this._fingersShown = false;
        this._clearFingerTimeouts();
        for (const screen of this._screens)
            screen.hideFinger();
        this._discardRecording();
    }

    _discardRecording() {
        this._recorder?.discard();
        this._recorder = null;
    }

    _scheduleHideFingers() {
        if (this._hideTimeoutId)
            GLib.source_remove(this._hideTimeoutId);
        this._hideTimeoutId = GLib.timeout_add(GLib.PRIORITY_DEFAULT, FINGER_VISIBLE_MS, () => {
            this._hideTimeoutId = 0;
            this._hideFingers();
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
        this._clearFingerTimeouts();
    }

    _clearFingerTimeouts() {
        if (this._recordTimeoutId)
            GLib.source_remove(this._recordTimeoutId);
        if (this._recordStopTimeoutId)
            GLib.source_remove(this._recordStopTimeoutId);
        this._recordTimeoutId = 0;
        this._recordStopTimeoutId = 0;
    }
});

import Clutter from 'gi://Clutter';
import Gio from 'gi://Gio';
import {Extension} from 'resource:///org/gnome/shell/extensions/extension.js';
import * as Main from 'resource:///org/gnome/shell/ui/main.js';
import * as MessageTray from 'resource:///org/gnome/shell/ui/messageTray.js';
import {UnlockDialog} from 'resource:///org/gnome/shell/ui/unlockDialog.js';

const BRIGHTNESS = 0.65;
const BACKDROP_STYLE_CLASS = 'lockscreen-backdrop';

function addBackdrop(dialog) {
    dialog._stack.add_style_class_name(BACKDROP_STYLE_CLASS);
    dialog._clock.y_align = Clutter.ActorAlign.CENTER;
    dialog._promptBox.y_align = Clutter.ActorAlign.CENTER;
}

function removeBackdrop(dialog) {
    dialog._stack.remove_style_class_name(BACKDROP_STYLE_CLASS);
    dialog._clock.y_align = Clutter.ActorAlign.FILL;
    dialog._promptBox.y_align = Clutter.ActorAlign.FILL;
}

function showLockScreenWithoutBlanking(screenShield) {
    screenShield._hidePointerUntilMotion();
    screenShield._lockScreenState = MessageTray.State.SHOWN;
    screenShield.emit('lock-screen-shown');
}

export default class LockscreenUnblurExtension extends Extension {
    enable() {
        this._delayScreenBlank(Main.screenShield);
        this._original = {
            updateBackgroundEffects: UnlockDialog.prototype._updateBackgroundEffects,
            showClock: UnlockDialog.prototype._showClock,
        };
        const {showClock} = this._original;

        UnlockDialog.prototype._updateBackgroundEffects = function () {
            for (const widget of this._backgroundGroup)
                widget.get_effect('blur')?.set({brightness: BRIGHTNESS, radius: 0});
        };
        UnlockDialog.prototype._showClock = function () {
            showClock.call(this);
            addBackdrop(this);
        };

        const dialog = Main.screenShield._dialog;
        if (dialog) {
            dialog._updateBackgroundEffects();
            addBackdrop(dialog);
        }
    }

    disable() {
        this._restoreScreenBlank(Main.screenShield);
        UnlockDialog.prototype._updateBackgroundEffects = this._original.updateBackgroundEffects;
        UnlockDialog.prototype._showClock = this._original.showClock;
        this._original = null;

        const dialog = Main.screenShield._dialog;
        if (dialog) {
            dialog._updateBackgroundEffects();
            removeBackdrop(dialog);
        }
    }

    _delayScreenBlank(screenShield) {
        screenShield._lockScreenShown = () => {
            showLockScreenWithoutBlanking(screenShield);
            this._blankWhenIdle(screenShield);
        };
        this._lockedId = screenShield.connect('locked-changed', () => {
            if (!screenShield.locked)
                this._removeBlankWatch(screenShield);
        });
    }

    _restoreScreenBlank(screenShield) {
        delete screenShield._lockScreenShown;
        screenShield.disconnect(this._lockedId);
        this._removeBlankWatch(screenShield);
    }

    _blankWhenIdle(screenShield) {
        this._removeBlankWatch(screenShield);
        const idleDelaySeconds = new Gio.Settings({schema_id: 'org.gnome.desktop.session'}).get_uint('idle-delay');
        if (idleDelaySeconds === 0)
            return;

        this._blankWatchId = screenShield.idleMonitor.add_idle_watch(idleDelaySeconds * 1000, () => {
            if (screenShield.locked)
                screenShield._setActive(true);
        });
    }

    _removeBlankWatch(screenShield) {
        if (this._blankWatchId)
            screenShield.idleMonitor.remove_watch(this._blankWatchId);
        this._blankWatchId = 0;
    }
}

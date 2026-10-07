import Clutter from 'gi://Clutter';
import {Extension} from 'resource:///org/gnome/shell/extensions/extension.js';
import * as Main from 'resource:///org/gnome/shell/ui/main.js';
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

function disableFadeToBlack(screenShield) {
    const original = Object.getPrototypeOf(screenShield)._lockScreenShown;
    screenShield._lockScreenShown = function (params) {
        original.call(this, {...params, fadeToBlack: false});
    };
}

function restoreFadeToBlack(screenShield) {
    delete screenShield._lockScreenShown;
}

export default class LockscreenUnblurExtension extends Extension {
    enable() {
        disableFadeToBlack(Main.screenShield);
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
        restoreFadeToBlack(Main.screenShield);
        UnlockDialog.prototype._updateBackgroundEffects = this._original.updateBackgroundEffects;
        UnlockDialog.prototype._showClock = this._original.showClock;
        this._original = null;

        const dialog = Main.screenShield._dialog;
        if (dialog) {
            dialog._updateBackgroundEffects();
            removeBackdrop(dialog);
        }
    }
}

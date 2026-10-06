import {Extension} from 'resource:///org/gnome/shell/extensions/extension.js';
import * as Main from 'resource:///org/gnome/shell/ui/main.js';
import {UnlockDialog} from 'resource:///org/gnome/shell/ui/unlockDialog.js';

const BRIGHTNESS = 0.65;
// Album cover width drawn by gnome/player-wallpaper.sh (640px art at 130%)
const COVER_WIDTH = 832;
const MIN_MARGIN = 48;

function moveColumnLeftOfCover(dialog) {
    const column = [dialog._stack, dialog._notificationsBox];
    const freeWidth = (dialog.width - COVER_WIDTH) / 2;
    const targetX = Math.max(MIN_MARGIN, (freeWidth - dialog._stack.width) / 2);
    for (const actor of column)
        actor.translation_x = targetX - dialog._stack.x;
}

function resetColumn(dialog) {
    if (!dialog._moveLeftId)
        return;
    dialog._stack.disconnect(dialog._moveLeftId);
    dialog._moveLeftId = 0;
    dialog._stack.translation_x = 0;
    dialog._notificationsBox.translation_x = 0;
}

export default class LockscreenUnblurExtension extends Extension {
    enable() {
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
            if (!this._moveLeftId)
                this._moveLeftId = this._stack.connect('notify::allocation', () => moveColumnLeftOfCover(this));
        };

        Main.screenShield._dialog?._updateBackgroundEffects();
    }

    disable() {
        UnlockDialog.prototype._updateBackgroundEffects = this._original.updateBackgroundEffects;
        UnlockDialog.prototype._showClock = this._original.showClock;
        this._original = null;

        const dialog = Main.screenShield._dialog;
        if (dialog) {
            dialog._updateBackgroundEffects();
            resetColumn(dialog);
        }
    }
}

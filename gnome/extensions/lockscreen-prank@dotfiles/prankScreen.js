import Clutter from 'gi://Clutter';
import GObject from 'gi://GObject';
import St from 'gi://St';
import {AnimatedImage} from './animatedImage.js';
import {ReactionPlayer} from './reactionPlayer.js';

export const SLIDE_UP_DURATION = 4500;
const SLIDE_DOWN_DURATION = 400;
const FINGER_HEIGHT_RATIO = 0.6;
const REACTION_HEIGHT_RATIO = 0.22;
const REACTION_MARGIN = 24;
const REACTION_FADE_DURATION = 300;

export const PrankScreen = GObject.registerClass(
class PrankScreen extends St.Widget {
    _init(monitor, screenshotPath, fingerPath) {
        super._init({
            x: monitor.x,
            y: monitor.y,
            width: monitor.width,
            height: monitor.height,
            clip_to_allocation: true,
            layout_manager: new Clutter.BinLayout(),
            style: `background-image: url("file://${screenshotPath}"); background-size: cover;`,
        });

        this._finger = new AnimatedImage(fingerPath, {
            x_align: Clutter.ActorAlign.CENTER,
            y_align: Clutter.ActorAlign.END,
            translation_y: monitor.height,
        });
        this._finger.height = monitor.height * FINGER_HEIGHT_RATIO;
        this._finger.width = this._finger.height * this._finger.aspectRatio;
        this.add_child(this._finger);
        this._fingerShown = false;

        this._reaction = new ReactionPlayer({
            x_align: Clutter.ActorAlign.END,
            y_align: Clutter.ActorAlign.START,
            margin_top: REACTION_MARGIN,
            margin_right: REACTION_MARGIN,
            height: monitor.height * REACTION_HEIGHT_RATIO,
            visible: false,
        });
        this.add_child(this._reaction);
    }

    showFinger() {
        if (this._fingerShown)
            return;

        this._fingerShown = true;
        this._finger.play();
        this._finger.remove_all_transitions();
        this._finger.ease({
            translation_y: 0,
            duration: SLIDE_UP_DURATION,
            mode: Clutter.AnimationMode.EASE_IN_OUT_SINE,
        });
    }

    playReaction(frames) {
        this._reaction.play(frames);
        this._reaction.opacity = 0;
        this._reaction.show();
        this._reaction.ease({
            opacity: 255,
            duration: REACTION_FADE_DURATION,
            mode: Clutter.AnimationMode.EASE_OUT_QUAD,
        });
    }

    hideFinger() {
        this._fingerShown = false;
        this._reaction.stop();
        this._reaction.hide();
        this._finger.ease({
            translation_y: this.height,
            duration: SLIDE_DOWN_DURATION,
            mode: Clutter.AnimationMode.EASE_IN_QUAD,
            onComplete: () => this._finger.stop(),
        });
    }
});

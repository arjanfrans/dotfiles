import Clutter from 'gi://Clutter';
import GdkPixbuf from 'gi://GdkPixbuf';
import GLib from 'gi://GLib';
import GObject from 'gi://GObject';
import St from 'gi://St';
import {setContentPixbuf} from './pixbufContent.js';

const MIN_FRAME_DELAY_MS = 20;

export const AnimatedImage = GObject.registerClass(
class AnimatedImage extends St.Widget {
    _init(path, params) {
        super._init(params);
        this._animation = GdkPixbuf.PixbufAnimation.new_from_file(path);
        this._content = St.ImageContent.new_with_preferred_size(
            this._animation.get_width(), this._animation.get_height());
        this.set_content(this._content);
        this.content_gravity = Clutter.ContentGravity.RESIZE_ASPECT;

        this._iter = null;
        this._frameTimeoutId = 0;
        this.connect('destroy', () => this.stop());
    }

    get aspectRatio() {
        return this._animation.get_width() / this._animation.get_height();
    }

    play() {
        this.stop();
        this._iter = this._animation.get_iter(null);
        this._showCurrentFrame();
    }

    stop() {
        if (this._frameTimeoutId)
            GLib.source_remove(this._frameTimeoutId);
        this._frameTimeoutId = 0;
    }

    _showCurrentFrame() {
        setContentPixbuf(this._content, this._iter.get_pixbuf());

        const delay = this._iter.get_delay_time();
        if (delay < 0)
            return;

        this._frameTimeoutId = GLib.timeout_add(GLib.PRIORITY_DEFAULT, Math.max(delay, MIN_FRAME_DELAY_MS), () => {
            this._frameTimeoutId = 0;
            this._iter.advance(null);
            this._showCurrentFrame();
            return GLib.SOURCE_REMOVE;
        });
    }
});

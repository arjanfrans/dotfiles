import Clutter from 'gi://Clutter';
import GdkPixbuf from 'gi://GdkPixbuf';
import GLib from 'gi://GLib';
import GObject from 'gi://GObject';
import St from 'gi://St';
import {setContentPixbuf} from './pixbufContent.js';
import {FRAME_RATE} from './reactionRecorder.js';

const FRAME_DELAY_MS = Math.round(1000 / FRAME_RATE);

export const ReactionPlayer = GObject.registerClass(
class ReactionPlayer extends St.Widget {
    _init(params) {
        super._init(params);
        this.content_gravity = Clutter.ContentGravity.RESIZE_ASPECT;
        this._frames = [];
        this._index = 0;
        this._frameTimeoutId = 0;
        this.connect('destroy', () => this.stop());
    }

    play(frames) {
        this.stop();
        const [, width, height] = GdkPixbuf.Pixbuf.get_file_info(frames[0]);
        this._content = St.ImageContent.new_with_preferred_size(width, height);
        this.set_content(this._content);
        this.width = this.height * width / height;

        this._frames = frames;
        this._index = 0;
        this._showNextFrame();
        this._frameTimeoutId = GLib.timeout_add(GLib.PRIORITY_DEFAULT, FRAME_DELAY_MS, () => {
            this._showNextFrame();
            return GLib.SOURCE_CONTINUE;
        });
    }

    stop() {
        if (this._frameTimeoutId)
            GLib.source_remove(this._frameTimeoutId);
        this._frameTimeoutId = 0;
    }

    _showNextFrame() {
        const path = this._frames[this._index];
        this._index = (this._index + 1) % this._frames.length;
        try {
            setContentPixbuf(this._content, GdkPixbuf.Pixbuf.new_from_file(path));
        } catch {
        }
    }
});

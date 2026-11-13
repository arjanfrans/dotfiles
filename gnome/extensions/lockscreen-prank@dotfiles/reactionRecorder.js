import Gio from 'gi://Gio';
import GLib from 'gi://GLib';

export const FRAME_RATE = 15;
const FRAME_WIDTH = 640;
const SIGINT = 2;

function deleteDirectory(path) {
    const dir = Gio.File.new_for_path(path);
    for (const info of dir.enumerate_children('standard::name', Gio.FileQueryInfoFlags.NONE, null))
        dir.get_child(info.get_name()).delete(null);
    dir.delete(null);
}

function newVideoPath() {
    const videosDir = GLib.get_user_special_dir(GLib.UserDirectory.DIRECTORY_VIDEOS) ??
        GLib.build_filenamev([GLib.get_home_dir(), 'Videos']);
    const prankDir = GLib.build_filenamev([videosDir, 'Prank']);
    GLib.mkdir_with_parents(prankDir, 0o755);
    const timestamp = GLib.DateTime.new_now_local().format('%Y-%m-%d_%H-%M-%S');
    return GLib.build_filenamev([prankDir, `${timestamp}.mp4`]);
}

export class ReactionRecorder {
    constructor() {
        this._dir = GLib.dir_make_tmp('lockscreen-prank-XXXXXX');
        this._videoPath = newVideoPath();
        this._discarded = false;
        this._stopped = false;
        this._process = Gio.Subprocess.new([
            'gst-launch-1.0', '-q', '-e',
            'v4l2src', '!', 'videoconvert', '!', 'videoflip', 'method=horizontal-flip', '!',
            'videorate', '!', 'videoscale', '!',
            `video/x-raw,framerate=${FRAME_RATE}/1,width=${FRAME_WIDTH},pixel-aspect-ratio=1/1`, '!',
            'tee', 'name=t',
            't.', '!', 'queue', '!', 'jpegenc', '!', 'multifilesink', `location=${this._dir}/%05d.jpg`,
            't.', '!', 'queue', '!', 'videoconvert', '!', 'video/x-raw,format=I420', '!',
            'x264enc', 'tune=zerolatency', '!', 'mp4mux', '!', 'filesink', `location=${this._videoPath}`,
        ], Gio.SubprocessFlags.STDOUT_SILENCE | Gio.SubprocessFlags.STDERR_SILENCE);
    }

    stop(onFrames) {
        this._stopped = true;
        this._process.send_signal(SIGINT);
        this._process.wait_async(null, () => {
            if (!this._discarded)
                onFrames(this._framePaths());
        });
    }

    discard() {
        this._discarded = true;
        if (!this._stopped)
            this._process.force_exit();
        this._process.wait_async(null, () => {
            deleteDirectory(this._dir);
            if (!this._stopped)
                this._deleteVideo();
        });
    }

    _deleteVideo() {
        try {
            Gio.File.new_for_path(this._videoPath).delete(null);
        } catch {
        }
    }

    _framePaths() {
        const dir = Gio.File.new_for_path(this._dir);
        return [...dir.enumerate_children('standard::name', Gio.FileQueryInfoFlags.NONE, null)]
            .map(info => info.get_name())
            .sort()
            .map(name => GLib.build_filenamev([this._dir, name]));
    }
}

import Cogl from 'gi://Cogl';

export function setContentPixbuf(content, pixbuf) {
    content.set_bytes(
        global.stage.context.get_backend().get_cogl_context(),
        pixbuf.read_pixel_bytes(),
        pixbuf.has_alpha ? Cogl.PixelFormat.RGBA_8888 : Cogl.PixelFormat.RGB_888,
        pixbuf.width,
        pixbuf.height,
        pixbuf.rowstride);
}

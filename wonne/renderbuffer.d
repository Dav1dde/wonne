module wonne.renderbuffer;

private {
    import wonne.awesomium;

    import wonne.exception;
    import wonne.util : awe_call;

    import std.exception : enforceEx;
}


struct Renderbuffer {
    const(awe_renderbuffer)* renderbuffer;
    alias renderbuffer this;

    this(const(awe_renderbuffer)* renderbuffer) {
        enforceEx!WebviewException(renderbuffer !is null, "renderbuffer is null, most likely the webview crashed");
        this.renderbuffer = renderbuffer;
    }

    @property int width() {
        return awe_call!awe_renderbuffer_get_width(renderbuffer);
    }

    @property int height() {
        return awe_call!awe_renderbuffer_get_height(renderbuffer);
    }

    @property int rowspan() {
        return awe_call!awe_renderbuffer_get_rowspan(renderbuffer);
    }

    @property const(ubyte)* buffer() {
        return awe_call!awe_renderbuffer_get_buffer(renderbuffer);
    }

    void copy_to(ubyte* dest_buffer, int dest_rowspan, int dest_depth, bool convert_to_rgba, bool flip_y) {
        awe_call!awe_renderbuffer_copy_to(renderbuffer, dest_buffer, dest_rowspan, dest_depth, convert_to_rgba, flip_y);
    }

    void copy_to_float(float* dest_buffer) {
        awe_call!awe_renderbuffer_copy_to_float(renderbuffer, dest_buffer);
    }

    bool save_to_png(string file_path, bool preserve_transparency) {
        return awe_call!awe_renderbuffer_save_to_png(renderbuffer, file_path, preserve_transparency);
    }

    bool save_to_jpeg(string file_path, int quality) {
        return awe_call!awe_renderbuffer_save_to_jpeg(renderbuffer, file_path, quality);
    }

    ubyte get_alpha_at_point(int x, int y) {
        return awe_call!awe_renderbuffer_get_alpha_at_point(renderbuffer, x, y);
    }

    void flush_alpha() {
        awe_call!awe_renderbuffer_flush_alpha(renderbuffer);
    }
}
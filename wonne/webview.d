module wonne.webview;

private {
    import deimos.awesomium.awesomium;
}


class Webview {
    private awe_webview* webview;

    this(int width, int height, bool view_source=false) {
        this.webview = awe_webcore_create_webview(width, height, view_source);
    }

    this(awe_webview* webview) {
        this.webview = webview;
    }

    ~this() {
        awe_webview_destroy(webview);
    }
}
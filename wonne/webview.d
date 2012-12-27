module wonne.webview;

private {
    import deimos.awesomium.awesomium;
}


class Webview {
    awe_webview* webview;

    this(awe_webview* webview) {
        this.webview = webview;
    }
}
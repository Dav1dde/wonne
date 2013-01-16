module wonne.ext.glfw;

private {
    import wonne.awesomium;
    import wonne.webview : Webview;

    import glwtf.glfw;
}


// TODO
// A helper module to forward glfw keycodes to an awesomium webview

// std.functional.curry is your friend!

void mouse_pos(Webview webview, int x, int y) {
    webview.inject_mouse_move(x, y);
}

private void mouse_button(Webview webview, int button, bool down) {
    awe_mousebutton mb;

    switch(button) {
        case GLFW_MOUSE_BUTTON_LEFT: mb = awe_mousebutton.AWE_MB_LEFT; break;
        case GLFW_MOUSE_BUTTON_MIDDLE: mb = awe_mousebutton.AWE_MB_MIDDLE; break;
        case GLFW_MOUSE_BUTTON_RIGHT: mb = awe_mousebutton.AWE_MB_RIGHT; break;
        default: return;
    }

    if(down) {
        webview.inject_mouse_down(mb);
    } else {
        webview.inject_mouse_up(mb);
    }
}

void mouse_button_down(Webview webview, int button) {
    mouse_button(webview, button, true);
}

void mouse_button_up(Webview webview, int button) {
    mouse_button(webview, button, false);
}

void mouse_scroll(int mult = 70)(Webview webview, double x, double y) {
    webview.inject_mouse_wheel(cast(int)y*70, cast(int)x*70);
}
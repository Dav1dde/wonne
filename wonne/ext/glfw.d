module wonne.ext.glfw;

private {
    import wonne.awesomium;
    import wonne.webview : Webview;

    import glwtf.glfw;
}


// No idea why I need that, but using awe_webkeyboardevent directly
// results in a linker error
extern(C) struct webkeyboardevent {
    awe_webkey_type type;
    int modifiers;
    int virtual_key_code;
    int native_key_code;
    wchar[4] text = [0, 0, 0, 0];
    wchar[4] unmodified_text = [0, 0, 0, 0];
    bool is_system_key;
}

// TODO
// A helper module to forward glfw keycodes to an awesomium webview

// std.functional.curry is your friend!

static const int[] GLFW_FUNCTION_KEYS_TO_AWE_KEYS = [
    0x1B, // GLFW_KEY_ESCAPE
    0x0D, // GLFW_KEY_ENTER
    0x09, // GLFW_KEY_TAB
    0x08, // GLFW_KEY_BACKSPACE
    0x2D, // GLFW_KEY_INSERT
    0x2E, // GLFE_KEY_DELETE
    0x27, // GLFW_KEY_RIGHT
    0x25, // GLFW_KEY_LEFT
    0x28, // GLFW_KEY_DOWN
    0x26, // GLFW_KEY_UP
    0x21, // GLFW_KEY_PAGE_UP
    0x22, // GLFW_KEY_PAGE_DOWN
    0x24, // GLFW_KEY_HOME
    0x23, // GLFW_KEY_END

    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    
    0x14, // GLFW_KEY_CAPS_LOCK
    0x91, // GLFW_KEY_SCROLL_LOCK
    0x90, // GLFW_KEY_NUM_LOCK
    0x2A, // GLFW_KEY_PRINT_SCREEN
    0x13, // GLFW_KEY_PAUSE

    0x00, 0x00, 0x00, 0x00, 0x00, 
    
    0x70, // GLFW_KEY_F1
    0x71, // GLFW_KEY_F2
    0x72, // GLFW_KEY_F3
    0x73, // GLFW_KEY_F4
    0x74, // GLFW_KEY_F5
    0x75, // GLFW_KEY_F6
    0x76, // GLFW_KEY_F7
    0x77, // GLFW_KEY_F8
    0x78, // GLFW_KEY_F9
    0x79, // GLFW_KEY_F10
    0x7A, // GLFW_KEY_F11
    0x7B, // GLFW_KEY_F12
    0x7C, // GLFW_KEY_F13
    0x7D, // GLFW_KEY_F14
    0x7E, // GLFW_KEY_F15
    0x7F, // GLFW_KEY_F16
    0x80, // GLFW_KEY_F17
    0x81, // GLFW_KEY_F18
    0x82, // GLFW_KEY_F19
    0x83, // GLFW_KEY_F20
    0x84, // GLFW_KEY_F21
    0x85, // GLFW_KEY_F22
    0x86, // GLFW_KEY_F23
    0x87, // GLFW_KEY_F24
    0x00, // GLFW_KEY_F25 -- No awe equivalent

    0x00, 0x00, 0x00, 0x00, 0x00,
    
    0x60, // GLFW_KEY_KP_0
    0x61, // GLFW_KEY_KP_1
    0x62, // GLFW_KEY_KP_2
    0x63, // GLFW_KEY_KP_3
    0x64, // GLFW_KEY_KP_4
    0x65, // GLFW_KEY_KP_5
    0x66, // GLFW_KEY_KP_6
    0x67, // GLFW_KEY_KP_7
    0x68, // GLFW_KEY_KP_8
    0x69, // GLFW_KEY_KP_9
    0x6E, // GLFW_KEY_KP_DECIMAL
    0x6F, // GLFW_KEY_KP_DIVIDE
    0x6A, // GLFW_KEY_KP_MULTIPLY
    0x6D, // GLFW_KEY_KP_SUBTRACT
    0x6B, // GLFW_KEY_KP_ADD
    0x0D, // GLFW_KEY_KP_ENTER
    0x00, // GLFW_KEY_KP_EQUAL -- No awe equivalent

    0x00, 0x00, 0x00,
    
    0xA0, // GLFW_KEY_LEFT_SHIFT
    0xA2, // GLFW_KEY_LEFT_CONTROL
    0xA4, // GLFW_KEY_LEFT_ALT
    0x5B, // GLFW_KEY_LEFT_SUPER
    0xA1, // GLFW_KEY_RIGHT_SHIFT
    0xA3, // GLFW_KEY_RIGHT_CONTROL
    0xA5, // GLFW_KEY_RIGHT_ALT
    0x5C, // GLFW_KEY_RIGHT_SUPER
    0x12  // GLFW_KEY_MENU
];


static assert(GLFW_FUNCTION_KEYS_TO_AWE_KEYS[GLFW_KEY_MENU-GLFW_KEY_ESCAPE] == 0x12);
static assert(GLFW_FUNCTION_KEYS_TO_AWE_KEYS.length == (GLFW_KEY_MENU-GLFW_KEY_ESCAPE+1));

int glfw_key_to_awe_key(int key) {
    switch(key) {
        case GLFW_KEY_SPACE: return 0x20;
        case GLFW_KEY_APOSTROPHE: return 0xBA;
        case GLFW_KEY_COMMA: return 0xBC;
        case GLFW_KEY_MINUS: return 0xBD;
        case GLFW_KEY_PERIOD: return 0xBE;
        case GLFW_KEY_SLASH: return 0xBF;
        case GLFW_KEY_0: ..
            case GLFW_KEY_9: return key;
        case GLFW_KEY_SEMICOLON: return 0x00;
        case GLFW_KEY_EQUAL: return 0x00;
        case GLFW_KEY_A: ..
            case GLFW_KEY_Z: return key;
        case GLFW_KEY_LEFT_BRACKET: return 0x00;
        case GLFW_KEY_BACKSLASH: return 0x00;
        case GLFW_KEY_RIGHT_BRACKET: return 0x00;
        case GLFW_KEY_GRAVE_ACCENT: return 0x00;
        case GLFW_KEY_WORLD_1: return 0x00;
        case GLFW_KEY_WORLD_2: return 0x00;
        case GLFW_KEY_ESCAPE: ..
            case GLFW_KEY_MENU: return GLFW_FUNCTION_KEYS_TO_AWE_KEYS[key - GLFW_KEY_ESCAPE];
        default: throw new Exception("invalid GLFW key");
    }
}


void inject_mouse_pos(Webview webview, int x, int y) {
    webview.inject_mouse_move(x, y);
}

private void inject_mouse_button(Webview webview, int button, bool down) {
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

void inject_mouse_button_down(Webview webview, int button) {
    inject_mouse_button(webview, button, true);
}

void inject_mouse_button_up(Webview webview, int button) {
    inject_mouse_button(webview, button, false);
}

void inject_mouse_scroll(int mult = 70)(Webview webview, double x, double y) {
    webview.inject_mouse_wheel(cast(int)y*70, cast(int)x*70);
}

void inject_char(Webview webview, dchar c) {
    wchar[] wc = (cast(wchar*)&c)[0..2];

    webkeyboardevent keyevent;
    keyevent.type = awe_webkey_type.AWE_WKT_CHAR;
    keyevent.modifiers = 0;
    keyevent.virtual_key_code = cast(int)c;
    keyevent.native_key_code = 0;
    keyevent.text[0..2] = wc;

    webview.inject_keyboard_event(cast(awe_webkeyboardevent)keyevent);
}

private void inject_key(Webview webview, int key, bool down) {
    int key_awe = glfw_key_to_awe_key(key);

    webkeyboardevent keyevent;
    keyevent.type = down ? awe_webkey_type.AWE_WKT_KEYDOWN : awe_webkey_type.AWE_WKT_KEYUP;
    keyevent.modifiers = 0;
    keyevent.virtual_key_code = key_awe;
    keyevent.native_key_code = key;

    webview.inject_keyboard_event(cast(awe_webkeyboardevent)keyevent);
}

void inject_key_down(Webview webview, int key) {
    inject_key(webview, key, true);
}

void inject_key_up(Webview webview, int key) {
    inject_key(webview, key, false);
}

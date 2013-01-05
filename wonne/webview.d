module wonne.webview;

private {
    import wonne.awesomium;

    import wonne.renderbuffer : Renderbuffer;
    import wonne.util : awe_call, isInstanceOf;
    import wonne.resource;
    import wonne.javascript;
    import wonne.string;

    import std.signals;
    import std.conv : to;
    import std.array : join;
    import std.string : xformat;
    import std.algorithm : canFind;
    import std.typetuple : staticMap;
    import std.traits : ParameterTypeTuple, fullyQualifiedName;
}


string make_fake_cb(string cbreg, string[] args...) {
    string signal_name = cbreg[25..$]; // "awe_webview_set_callback_".length = 25

    string[] tmp;
    string[] tmp2;
    foreach(i, arg; args) {
        tmp ~= "%s arg%d".xformat(arg, i);
        if(arg.canFind("awe_string")) {
            tmp2 ~= "arg%d.to!string()".xformat(i);
        } else if(arg.canFind("awe_jsarray")) {
            tmp2 ~= "JSArray(cast(awe_jsarray*)arg%d)".xformat(i);
        } else if(arg.canFind("awe_resource_request")) {
            tmp2 ~= "ResourceRequest(arg%d)".xformat(i);
        } else {
            tmp2 ~= "arg%d".xformat(i);
        }
    }
    string fargs = tmp.join(", ");
    string fargs2 = (tmp2[1..$]).join(", ");

    string func = "
    #line 3000
    extern(C) static auto fake_cb(%s) {
        auto W = Webview.from_awe_webview(arg0);
        W.on_%s.emit(W, %s);
    }".xformat(fargs, signal_name, fargs2);

    return func;
}

struct SSignal(alias cbreg, T...) {
    Webview webview;

    alias ParameterTypeTuple!(ParameterTypeTuple!(cbreg)[1]) cbreg_Args;

    private template to_string(T) {
        enum to_string = T.stringof;
    }

    alias staticMap!(to_string, cbreg_Args) cbreg_SArgs;
    enum fake_cb_mixin = make_fake_cb(__traits(identifier, cbreg), cbreg_SArgs);
    //pragma(msg, make_fake_cb(__traits(identifier, cbreg), cbreg_SArgs));
    mixin(fake_cb_mixin);

    mixin Signal!(T) hidden;
    alias hidden this;

    void connect(slot_t slot) {
        // register the webview/slot only once:
        if(slots.length == 0) { // 0 means, the first slot to be added
            cbreg(webview.webview, &fake_cb); // fake_cb is generated above: mixin()
        }
        hidden.connect(slot);
    }
}


class Webview {
    package awe_webview* webview;

    private static Webview[awe_webview*] webviews;

    this(int width, int height, bool view_source=false) {
        this.webview = awe_webcore_create_webview(width, height, view_source);
        webviews[webview] = this;
        init_signals();
    }

    static Webview from_awe_webview(awe_webview* webview) {
        if(auto W = webview in webviews) {
            return *W;
        }

        return new Webview(webview, true);
    }
    
    private this(awe_webview* webview, bool other_ctor) {
        this.webview = webview;
        webviews[webview] = this;
        init_signals();
    }

    ~this() {
        awe_call!awe_webview_destroy(webview);
        webviews.remove(webview);
    }

    SSignal!(awe_webview_set_callback_begin_navigation, Webview, string, string) on_begin_navigation;
    SSignal!(awe_webview_set_callback_begin_loading, Webview, string, string, int, string) on_begin_loading;
    SSignal!(awe_webview_set_callback_finish_loading, Webview) on_finish_loading;
    SSignal!(awe_webview_set_callback_js_callback, Webview, string, string, JSArray) on_js_callback;
    SSignal!(awe_webview_set_callback_receive_title, Webview, string, string) on_receive_title;
    SSignal!(awe_webview_set_callback_change_tooltip, Webview, string) on_change_tooltip;
    SSignal!(awe_webview_set_callback_change_cursor, Webview, awe_cursor_type) on_change_cursor;
    SSignal!(awe_webview_set_callback_change_keyboard_focus, Webview, bool) on_change_keyboard_focus;
    SSignal!(awe_webview_set_callback_change_target_url, Webview, string) on_change_target_url;
    SSignal!(awe_webview_set_callback_open_external_link, Webview, string, string) on_open_external_link;
    SSignal!(awe_webview_set_callback_request_download, Webview, string) on_request_download;
    SSignal!(awe_webview_set_callback_web_view_crashed, Webview) on_web_view_crashed;
    SSignal!(awe_webview_set_callback_request_move, Webview, int, int) on_request_move;
    SSignal!(awe_webview_set_callback_get_page_contents, Webview, string, string) on_get_page_contents;
    SSignal!(awe_webview_set_callback_dom_ready, Webview) on_dom_ready;
    SSignal!(awe_webview_set_callback_request_file_chooser, Webview, bool, string, string) on_request_file_chooser;
    SSignal!(awe_webview_set_callback_get_scroll_data, Webview, int, int, int, int, int) on_get_scroll_data;
    SSignal!(awe_webview_set_callback_js_console_message, Webview, string, int, string) on_js_console_message;
    SSignal!(awe_webview_set_callback_get_find_results, Webview, int, int, awe_rect, int, bool) on_get_find_results;
    SSignal!(awe_webview_set_callback_update_ime, Webview, awe_ime_state, awe_rect) on_update_ime;
    SSignal!(awe_webview_set_callback_show_context_menu, Webview, int, int, awe_media_type, int,
                                                         string, string, string, string, string,
                                                         bool, int) on_show_context_menu;
    SSignal!(awe_webview_set_callback_request_login, Webview, int, string, bool, string, string, string) on_request_login;
    SSignal!(awe_webview_set_callback_change_history, Webview, int, int) on_change_history;
    SSignal!(awe_webview_set_callback_finish_resize, Webview, int, int) on_finish_resize;
    SSignal!(awe_webview_set_callback_show_javascript_dialog, Webview, int, int, string, string, string) on_show_javascript_dialog;
    SSignal!(awe_webview_set_callback_resource_response, Webview, string, int, bool, long, long, long, string) on_resource_response;

    private void init_signals() {
        foreach(member; __traits(allMembers, typeof(this))) {
            static if(__traits(compiles, typeof(mixin(member)))) {
                alias typeof(mixin(member)) MType;
                static if(isInstanceOf!(SSignal, MType)) {
                    mixin("%s.webview = this;".xformat(member));
                }
            }
        }
    }

    package ResourceResponse delegate(Webview, ResourceRequest) _on_resource_request;
    void set_resource_request_callback(ResourceResponse delegate(Webview, ResourceRequest) dg) {
        _on_resource_request = dg;
        
        static extern(C) awe_resource_response* fake_cb(awe_webview* arg0, awe_resource_request* arg1) {
            auto W = Webview.from_awe_webview(arg0);
            return W._on_resource_request(W, ResourceRequest(arg1));
        }

        awe_webview_set_callback_resource_request(webview, &fake_cb);

    }

    void load_url(string url, string frame_name="", string username="", string password="") {
        awe_call!awe_webview_load_url(webview, url, frame_name, username, password);
    }

    void load_html(string html, string frame_name="") {
        awe_call!awe_webview_load_html(webview, html, frame_name);
    }

    void load_file(string file, string frame_name="") {
        awe_call!awe_webview_load_file(webview, file, frame_name);
    }

    string get_url() {
        return awe_call!awe_webview_get_url(webview);
    }

    void go_to_history_offset(int offset) {
        awe_call!awe_webview_go_to_history_offset(webview, offset);
    }

    int get_history_back_count() {
        return awe_call!awe_webview_get_history_back_count(webview);
    }

    int get_history_forward_count() {
        return awe_call!awe_webview_get_history_forward_count(webview);
    }

    void stop() {
        awe_call!awe_webview_stop(webview);
    }

    void reload() {
        awe_call!awe_webview_reload(webview);
    }

    void execute_javascript(string javascript, string frame_name="") {
        awe_call!awe_webview_execute_javascript(webview, javascript, frame_name);
    }

    JSValue execute_javascript_with_result(string javascript, string frame_name="", int timeout_ms=0) {
        return awe_call!awe_webview_execute_javascript_with_result(webview, javascript, frame_name, timeout_ms);
    }

    void call_javascript_function(string object, string function_, const(awe_jsarray)* arguments, string frame_name="") {
        awe_call!awe_webview_call_javascript_function(webview, object, function_, arguments, frame_name);
    }

    void create_object(string object_name) {
        awe_call!awe_webview_create_object(webview, object_name);
    }

    void destroy_object(string object_name) {
        awe_call!awe_webview_destroy_object(webview, object_name);
    }

    // TODO: jsvalue
    void set_object_property(string object_name, string property_name, const(awe_jsvalue)* value) {
        awe_call!awe_webview_set_object_property(webview, object_name, property_name, value);
    }

    void set_object_callback(string object_name, string callback_name) {
        awe_call!awe_webview_set_object_callback(webview, object_name, callback_name);
    }

    bool is_loading_page() {
        return awe_call!awe_webview_is_loading_page(webview);
    }

    bool is_dirty() {
        return awe_call!awe_webview_is_dirty(webview);
    }

    // TODO: awe_rect?
    awe_rect get_dirty_bounds() {
        return awe_call!awe_webview_get_dirty_bounds(webview);
    }

    Renderbuffer render() {
        return awe_call!awe_webview_render(webview);
    }

    void pause_rendering() {
        awe_call!awe_webview_pause_rendering(webview);
    }

    void resume_rendering() {
        awe_call!awe_webview_resume_rendering(webview);
    }

    void inject_mouse_move(int x, int y) {
        awe_call!awe_webview_inject_mouse_move(webview, x, y);
    }

    void inject_mouse_down(awe_mousebutton mouse_button) {
        awe_call!awe_webview_inject_mouse_down(webview, mouse_button);
    }

    void inject_mouse_up(awe_mousebutton mouse_button) {
        awe_call!awe_webview_inject_mouse_up(webview, mouse_button);
    }

    void inject_mouse_wheel(int scroll_amount_vert, int scroll_amount_horz) {
        awe_call!awe_webview_inject_mouse_wheel(webview, scroll_amount_vert, scroll_amount_horz);
    }

    // TODO: webkeyboardevent
    void inject_keyboard_event(awe_webkeyboardevent key_event) {
        awe_call!awe_webview_inject_keyboard_event(webview, key_event);
    }

    void cut() {
        awe_call!awe_webview_cut(webview);
    }

    void copy() {
        awe_call!awe_webview_copy(webview);
    }

    void paste() {
        awe_call!awe_webview_paste(webview);
    }

    void select_all() {
        awe_call!awe_webview_select_all(webview);
    }

    void copy_image_at(int x, int y) {
        awe_call!awe_webview_copy_image_at(webview, x, y);
    }

    void set_zoom(int zoom_percent) {
        awe_call!awe_webview_set_zoom(webview, zoom_percent);
    }

    void reset_zoom(int reset_zoom) {
        awe_call!awe_webview_reset_zoom(webview);
    }

    int get_zoom() {
        return awe_call!awe_webview_get_zoom(webview);
    }

    @property int zoom() { return get_zoom(); }
    @property void zoom(int zoom_percent) { set_zoom(zoom_percent); }

    int get_zoom_for_host(string host) {
        return awe_call!awe_webview_get_zoom_for_host(webview, host);
    }

    bool resize(int width, int height, bool wait_for_repaint, int repaint_timeout_ms) {
        return awe_call!awe_webview_resize(webview, width, height, wait_for_repaint, repaint_timeout_ms);
    }

    bool is_resizing() {
        return awe_call!awe_webview_is_resizing(webview);
    }

    void unfocus() {
        awe_call!awe_webview_unfocus(webview);
    }

    void focus() {
        awe_call!awe_webview_focus(webview);
    }

    void set_transparent(bool is_transparent) {
        awe_call!awe_webview_set_transparent(webview, is_transparent);
    }

    bool is_transparent() {
        return awe_call!awe_webview_is_transparent(webview);
    }

    void set_url_filtering_mode(awe_url_filtering_mode mode) {
        awe_call!awe_webview_set_url_filtering_mode(webview, mode);
    }

    void add_url_filter(string filter) {
        awe_call!awe_webview_add_url_filter(webview, filter);
    }

    void clear_all_url_filters() {
        awe_call!awe_webview_clear_all_url_filters(webview);
    }

    void set_header_definition(string name, string[] field_names, string[] field_values)
        in { assert(field_names.length == field_values.length, "field_names.length doesn't match field_values.length"); }
        body {
            awe_call!awe_webview_set_header_definition(webview, name, field_names.length, field_names, field_values);
        }

    void add_header_rewrite_rule(string rule, string name) {
        awe_call!awe_webview_add_header_rewrite_rule(webview, rule, name);
    }

    void remove_header_rewrite_rule(string rule) {
        awe_call!awe_webview_remove_header_rewrite_rule(webview, rule);
    }

    void remove_header_rewrite_rules_by_definition_name(string name) {
        awe_call!awe_webview_remove_header_rewrite_rules_by_definition_name(webview, name);
    }

    void choose_file(string file_path) {
        awe_call!awe_webview_choose_file(webview, file_path);
    }

    void print() {
        awe_call!awe_webview_print(webview);
    }

    void request_scroll_data(string frame_name="") {
        awe_call!awe_webview_request_scroll_data(webview, frame_name);
    }

    void find(int request_id, string search_string, bool forward, bool case_sensitive, bool find_next) {
        awe_call!awe_webview_find(webview, request_id, search_string, forward, case_sensitive, find_next);
    }

    void stop_find(bool clear_selection) {
        awe_call!awe_webview_stop_find(webview, clear_selection);
    }

    void translate_page(string source_language, string target_language) {
        awe_call!awe_webview_translate_page(webview, source_language, target_language);
    }

    void activate_ime(bool activate) {
        awe_call!awe_webview_activate_ime(webview, activate);
    }

    void set_ime_composition(string input_string, int cursor_pos, int target_start, int target_end) {
        awe_call!awe_webview_set_ime_composition(webview, input_string, cursor_pos, target_start, target_end);
    }

    void confirm_ime_composition(string input_string) {
        awe_call!awe_webview_confirm_ime_composition(webview, input_string);
    }

    void cancel_ime_composition() {
        awe_call!awe_webview_cancel_ime_composition(webview);
    }

    void login(int request_id, string username, string password) {
        awe_call!awe_webview_login(webview, request_id, username, password);
    }

    void cancel_login(int request_id) {
        awe_call!awe_webview_cancel_login(webview, request_id);
    }

    void close_javascript_dialog(int request_id, bool was_cancelled, string prompt_text) {
        awe_call!awe_webview_close_javascript_dialog(webview, request_id, was_cancelled, prompt_text);
    }
}
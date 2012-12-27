module wonne.webview;

private {
    import deimos.awesomium.awesomium;

    import wonne.util : awe_call;
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
        awe_webview_go_to_history_offset(webview, offset);
    }

    int get_history_back_count() {
        return awe_call!awe_webview_get_history_back_count(webview);
    }

    int get_history_forward_count() {
        return awe_call!awe_webview_get_history_forward_count(webview);
    }

    void stop() {
        awe_webview_stop(webview);
    }

    void reload() {
        awe_webview_reload(webview);
    }

    void execute_javascript(string javascript, string frame_name="") {
        awe_call!awe_webview_execute_javascript(webview, javascript, frame_name);
    }

    // TODO: returnvale
    auto execute_javascript_with_result(string javascript, string frame_name="", int timeout_ms=0) {
        awe_call!awe_webview_execute_javascript_with_result(webview, javascript, frame_name, timeout_ms);
    }

    // TODO: jsarray
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

    // TODO: renderbuffer
    const(awe_renderbuffer)* render() {
        return awe_call!awe_webview_render(webview);
    }

    void pause_rendering() {
        awe_webview_pause_rendering(webview);
    }

    void resume_rendering() {
        awe_webview_resume_rendering(webview);
    }

    void inject_mouse_move(int x, int y) {
        awe_webview_inject_mouse_move(webview, x, y);
    }

    void inject_mouse_down(awe_mousebutton mouse_button) {
        awe_webview_inject_mouse_down(webview, mouse_button);
    }

    void inject_mouse_up(awe_mousebutton mouse_button) {
        awe_webview_inject_mouse_up(webview, mouse_button);
    }

    void inject_mouse_wheel(int scroll_amount_vert, int scroll_amount_horz) {
        awe_webview_inject_mouse_wheel(webview, scroll_amount_vert, scroll_amount_horz);
    }

    // TODO: webkeyboardevent
    void inject_keyboard_event(awe_webkeyboardevent key_event) {
        awe_webview_inject_keyboard_event(webview, key_event);
    }

    void cut() {
        awe_webview_cut(webview);
    }

    void copy() {
        awe_webview_copy(webview);
    }

    void paste() {
        awe_webview_paste(webview);
    }

    void select_all() {
        awe_webview_select_all(webview);
    }

    void copy_image_at(int x, int y) {
        awe_webview_copy_image_at(webview, x, y);
    }

    void set_zoom(int zoom_percent) {
        awe_webview_set_zoom(webview, zoom_percent);
    }

    void reset_zoom(int reset_zoom) {
        awe_webview_reset_zoom(webview);
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
        awe_webview_unfocus(webview);
    }

    void focus() {
        awe_webview_focus(webview);
    }

    void set_transparent(bool is_transparent) {
        awe_webview_set_transparent(webview, is_transparent);
    }

    bool is_transparent() {
        return awe_call!awe_webview_is_transparent(webview);
    }

    void set_url_filtering_mode(awe_url_filtering_mode mode) {
        awe_webview_set_url_filtering_mode(webview, mode);
    }

    void add_url_filter(string filter) {
        awe_call!awe_webview_add_url_filter(webview, filter);
    }

    void clear_all_url_filters() {
        awe_webview_clear_all_url_filters(webview);
    }

    // TODO: fix string arrays
//     void set_header_definition(string name, size_t num_fields, string[] field_names, string[] field_values) {
//         awe_call!awe_webview_set_header_definition(webview, name, num_fields, field_names, field_values);
//     }

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
        awe_webview_print(webview);
    }

    void request_scroll_data(string frame_name="") {
        awe_call!awe_webview_request_scroll_data(webview, frame_name);
    }

    void find(int request_id, string search_string, bool forward, bool case_sensitive, bool find_next) {
        awe_call!awe_webview_find(webview, request_id, search_string, forward, case_sensitive, find_next);
    }

    void stop_find(bool clear_selection) {
        awe_webview_stop_find(webview, clear_selection);
    }

    void translate_page(string source_language, string target_language) {
        awe_call!awe_webview_translate_page(webview, source_language, target_language);
    }

    void activate_ime(bool activate) {
        awe_webview_activate_ime(webview, activate);
    }

    void set_ime_composition(string input_string, int cursor_pos, int target_start, int target_end) {
        awe_call!awe_webview_set_ime_composition(webview, input_string, cursor_pos, target_start, target_end);
    }

    void confirm_ime_composition(string input_string) {
        awe_call!awe_webview_confirm_ime_composition(webview, input_string);
    }

    void cancel_ime_composition() {
        awe_webview_cancel_ime_composition(webview);
    }

    void login(int request_id, string username, string password) {
        awe_call!awe_webview_login(webview, request_id, username, password);
    }

    void cancel_login(int request_id) {
        awe_webview_cancel_login(webview, request_id);
    }

    void close_javascript_dialog(int request_id, bool was_cancelled, string prompt_text) {
        awe_call!awe_webview_close_javascript_dialog(webview, request_id, was_cancelled, prompt_text);
    }

    // TODO: callback stuff

    
}
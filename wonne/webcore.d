module wonne.webcore;


private {
    import wonne.awesomium;

    import wonne.string;
    import wonne.history;
    import wonne.webview;
    import wonne.util : awe_call, is_awe_string;

    import std.conv : to;
}


void initialize(bool enable_plugins, bool enable_javascript, bool enable_databases,
                string package_path, string locale_path, string user_data_path, string plugin_path,
                string log_path, awe_loglevel loglevel, bool force_single_process,
                string child_process_path, bool enable_autodetect_encoding,
                string accept_language_override, string default_charset_override,
                string user_agent_override, string proxy_server, string proxy_config_script,
                string auth_server_whitelist, bool save_cache_and_cookies, int max_cache_size,
                bool disable_same_origin_policy, bool disable_win_message_pump, string custom_css) {
    awe_call!awe_webcore_initialize(enable_plugins, enable_javascript, enable_databases,
                                    package_path, locale_path, user_data_path, plugin_path,
                                    log_path, loglevel, force_single_process,
                                    child_process_path, enable_autodetect_encoding,
                                    accept_language_override, default_charset_override,
                                    user_agent_override, proxy_server, proxy_config_script,
                                    auth_server_whitelist, save_cache_and_cookies, max_cache_size,
                                    disable_same_origin_policy, disable_win_message_pump, custom_css);
}

//alias awe_webcore_initialize_default initialize_default;
void initialize_default() {
    awe_call!awe_webcore_initialize_default();
}

//alias awe_webcore_shutdown shutdown;
void shutdown() {
    awe_call!awe_webcore_shutdown();
}

void set_base_directory(string base_dir_path) {
    awe_call!awe_webcore_set_base_directory(base_dir_path);
}

Webview create_webview(int width, int height, bool view_source) {
    return awe_call!awe_webcore_create_webview(width, height, view_source);
}

void set_custom_response_page(int status_code, string file_path) {
    awe_call!awe_webcore_set_custom_response_page(status_code, file_path);
}

//alias awe_webcore_update update;
void update() {
    awe_call!awe_webcore_update();
}


string get_base_directory() {
    return awe_call!awe_webcore_get_base_directory();
}

//alias awe_webcore_are_plugins_enabled are_plugins_enabled;
bool are_plugins_enabled() {
    return awe_call!awe_webcore_are_plugins_enabled();
}

//alias awe_webcore_clear_cache clear_cache;
void clear_cache() {
    awe_call!awe_webcore_clear_cache();
}

//alias awe_webcore_clear_cookies clear_cookies;
void clear_cookies() {
    awe_call!awe_webcore_clear_cookies();
}

void set_cookie(string url, string cookie_string, bool is_http_only, bool force_session_cookie) {
    awe_call!awe_webcore_set_cookie(url, cookie_string, is_http_only, force_session_cookie);
}

string get_cookies(string url, bool execute_http_only) {
    return awe_call!awe_webcore_get_cookies(url, execute_http_only);
}

void delete_cookie(T, S)(string url, string cookie_name) {
    awe_call!awe_webcore_delete_cookie(url, cookie_name);
}

void set_suppress_printer_dialog(bool suppress) {
    awe_call!awe_webcore_set_suppress_printer_dialog(suppress);
}

HistoryQueryResult query_history(string full_text_query, int num_days_ago, int max_count) {
    return awe_call!awe_webcore_query_history(full_text_query, num_days_ago, max_count);
}

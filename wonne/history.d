module wonne.history;

private {
    import wonne.awesomium;

    import wonne.util : awe_call;
}



struct HistoryQueryResult {
    awe_history_query_result* history_query_result;
    alias history_query_result this;

    this(awe_history_query_result* history_query_result) {
        this.history_query_result = history_query_result;
    }

    void destroy() {
        awe_call!awe_history_query_result_destroy(history_query_result);
    }

    @property size_t size() {
        return awe_call!awe_history_query_result_get_size(history_query_result);
    }

    HistoryEntry get_entry_at_index(size_t idx) {
        return awe_call!awe_history_query_result_get_entry_at_index(history_query_result, idx);
    }

    HistoryEntry opIndex(size_t idx) {
        return awe_call!awe_history_query_result_get_entry_at_index(history_query_result, idx);
    }
}


struct HistoryEntry {
    awe_history_entry* history_entry;
    alias history_entry this;

    this(awe_history_entry* history_entry) {
        this.history_entry = history_entry;
    }

    void destroy() {
        awe_call!awe_history_entry_destroy(history_entry);
    }

    @property string url() {
        return awe_call!awe_history_entry_get_url(history_entry);
    }

    @property string title() {
        return awe_call!awe_history_entry_get_title(history_entry);
    }

    @property double visit_time() {
        return awe_call!awe_history_entry_get_visit_time(history_entry);
    }

    @property int visit_count() {
        return awe_call!awe_history_entry_get_visit_count(history_entry);
    }
}
module wonne.resource;

private {
    import wonne.awesomium;

    import wonne.string;
    import wonne.util : awe_call;
}


struct Response {
    awe_resource_response* response;

    this(ubyte[] buffer, string mime_type) {
        auto mime_type_awe = AWEString(mime_type);
        scope(exit) mime_type_awe.destroy();
        response = awe_resource_response_create(buffer.length, buffer.ptr, mime_type_awe);
    }

    this(string file_path) {
        response = awe_call!awe_resource_response_create_from_file(file_path);
    }
}


struct Request {
    awe_resource_request* request;
    alias request this;

    this(awe_resource_request* request) {
        this.request = request;
    }

    void cancel() {
        awe_call!awe_resource_request_cancel(request);
    }

    @property string url() {
        return awe_call!awe_resource_request_get_url(request);
    }

    @property string method() {
        return awe_call!awe_resource_request_get_method(request);
    }
    @property void method(string method) {
        awe_call!awe_resource_request_set_method(request, method);
    }

    @property string referrer() {
        return awe_call!awe_resource_request_get_referrer(request);
    }
    @property void referrer(string referrer) {
        awe_call!awe_resource_request_set_referrer(request, referrer);
    }

    @property string extra_headers() {
        return awe_call!awe_resource_request_get_extra_headers(request);
    }
    @property void extra_headers(string extra_headers) {
        awe_call!awe_resource_request_set_extra_headers(request, extra_headers);
    }

    void append_extra_header(string name, string value) {
        awe_call!awe_resource_request_append_extra_header(request, name, value);
    }

    @property size_t num_upload_elements() {
        return awe_call!awe_resource_request_get_num_upload_elements(request);
    }

    UploadElement get_upload_element(size_t idx) {
        return awe_call!awe_resource_request_get_upload_element(request, idx);
    }

    void clear_upload_elements() {
        awe_call!awe_resource_request_clear_upload_elements(request);
    }

    void append_upload_file_path(string file_path) {
        awe_call!awe_resource_request_append_upload_file_path(request, file_path);
    }

    void append_upload_bytes(string bytes) {
        awe_call!awe_resource_request_append_upload_bytes(request, bytes);
    }   
}

struct UploadElement {
    const(awe_upload_element)* element;
    alias element this;

    this(const(awe_upload_element)* element) {
        this.element = element;
    }

    @property bool is_file_path() {
        return awe_call!awe_upload_element_is_file_path(element);
    }

    @property bool is_bytes() {
        return awe_call!awe_upload_element_is_bytes(element);
    }

    @property string bytes() {
        return awe_call!awe_upload_element_get_bytes(element);
    }

    @property string file_path() {
        return awe_call!awe_upload_element_get_file_path(element);
    }
}
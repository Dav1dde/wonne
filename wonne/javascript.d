module wonne.javascript;

private {
    import wonne.awesomium;

    import wonne.string : AWEString;
    import wonne.util : awe_call;
}


struct JSValue {
    awe_jsvalue* jsvalue;
    alias jsvalue this;

    this(typeof(null) n) {
        jsvalue = awe_jsvalue_create_null_value();
    }

    this(awe_jsvalue* value) {
        jsvalue = value;
    }

    this(bool value) {
        jsvalue = awe_jsvalue_create_bool_value(value);
    }

    this(int value) {
        jsvalue = awe_jsvalue_create_integer_value(value);
    }

    this(double value) {
        jsvalue = awe_jsvalue_create_double_value(value);
    }

    this(string value) {
        auto awe_value = AWEString(value);
        scope(exit) awe_value.destroy();
        jsvalue = awe_jsvalue_create_string_value(awe_value);
    }

    this(const(awe_jsobject)* value) {
        jsvalue = awe_jsvalue_create_object_value(value);
    }

    this(const(awe_jsarray)* value) {
        jsvalue = awe_jsvalue_create_array_value(value);
    }

    void destroy() {
        awe_jsvalue_destroy(jsvalue);
    }

    // TODO:awe_jsvalue_type
    awe_jsvalue_type get_type() const {
        return awe_jsvalue_get_type(jsvalue);
    }

    string opCast(T : string)() const {
        return awe_call!awe_jsvalue_to_string(jsvalue);
    }

    int opCast(T : int)() const {
        return awe_call!awe_jsvalue_to_int(jsvalue);
    }

    double opCast(T : double)() const {
        return awe_call!awe_jsvalue_to_double(jsvalue);
    }

    bool opCast(T : bool)() const {
        return awe_call!awe_jsvalue_to_bool(jsvalue);
    }

    const(JSObject) opCast(T : awe_jsobject*)() {
        return awe_call!awe_jsvalue_get_object(jsvalue);
    }

    const(JSArray) opCast(T : awe_jsarray*)() {
        return awe_call!awe_jsvalue_get_jsarray(jsvalue);
    }
}


struct JSArray {
    awe_jsarray* jsarray;
    alias jsarray this;

    this(awe_jsarray* array) {
        jsarray = array;
    }

    this(JSValue[] jsvalue_array) {
        awe_jsvalue*[] awe_jsa;
        awe_jsa.length = jsvalue_array.length;
        foreach(i, jsv; jsvalue_array) {
            awe_jsa[i] = jsv.jsvalue;
        }
        
        jsarray = awe_jsarray_create(awe_jsa.ptr, awe_jsa.length);
    }

    void destroy() {
        awe_jsarray_destroy(jsarray);
    }

    @property size_t size() {
        return awe_call!awe_jsarray_get_size(jsarray);
    }

    const(JSValue) get_element(size_t index) {
        return awe_call!awe_jsarray_get_element(jsarray, index);
    }

    const(JSValue) opIndex(size_t index) {
        return awe_call!awe_jsarray_get_element(jsarray, index);
    }
}

struct JSObject {
    awe_jsobject* jsobject;
    alias jsobject this;

    this(awe_jsobject* object) {
        jsobject = object;
    }

    static JSObject opCall() {
        return awe_call!awe_jsobject_create();
    }

    void destroy() {
        awe_jsobject_destroy(jsobject);
    }

    bool has_property(string property_name) {
        return awe_call!awe_jsobject_has_property(jsobject, property_name);
    }

    JSValue get_property(string property_name) {
        return awe_call!awe_jsobject_get_property(jsobject, property_name);
    }

    void set_property(string property_name, awe_jsvalue* value) {
        awe_call!awe_jsobject_set_property(jsobject, property_name, value);
    }

    @property size_t size() {
        return awe_call!awe_jsobject_get_size(jsobject);
    }

    @property JSArray keys() {
        return awe_call!awe_jsobject_get_keys(jsobject);
    }
}
        
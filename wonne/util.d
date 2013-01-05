module wonne.util;

private {
    import wonne.awesomium;
    
    import wonne.string;
    import wonne.webview;
    import wonne.history;
    import wonne.resource;
    import wonne.javascript;
    import wonne.renderbuffer;
    
    import std.typetuple : TypeTuple, allSatisfy, anySatisfy;
    import std.traits : ReturnType, Unqual;
    import std.conv : to;
}


template is_awe_string(T...) if(T.length == 1) {
    enum is_awe_string = (is(T[0] == string) || is(T[0] == wstring) || is(T[0] == AWEString) || is(T[0] == awe_string*));
}

template is_awe_string(T...) if(T.length > 1) {
    alias allSatisfy!(is_awe_string, T) is_awe_string;
}

template is_awe_d_string(T) {
    enum is_awe_d_string = (is(T == string) || is(T == wstring));
}

/// Automatically converts a string for wstring into an AWEString and frees it after calling func.
/// It also converts the returntype of the function into a wonne abstraction or a d-type.
auto awe_call(alias func, Args...)(Args args) {
    static if(anySatisfy!(is_awe_d_string, Args)) {
        alias convert_args!(Args) NewArgs;

        NewArgs new_args;

        foreach(i, arg; args) {
            static if(is(typeof(arg) == string) || is(typeof(arg) == wstring)) {
                new_args[i] = AWEString(arg);
            } else static if(is(typeof(arg) == string[]) || is(typeof(arg) == wstring[])) {
                awe_string*[] awe_string_array;
                awe_string_array.length = arg.length;
                foreach(ii, element; arg) {
                    awe_string_array[ii] = AWEString(element);
                }
                new_args[i] = awe_string_array.ptr;
            } else {
                new_args[i] = arg;
            }
        }

        scope(exit) {
            foreach(i, arg; args) {
                static if(is(typeof(arg) == string) || is(typeof(arg) == wstring)) {
                    new_args[i].destroy();
                } else static if(is(typeof(arg) == string[]) || is(typeof(arg) == wstring[])) {
                    for(int ii=0; ii < arg.length; ii++) {
                        awe_string_destroy(new_args[i][ii]);
                    }
                }
            }
        }
    } else {
        alias args new_args;
    }

    alias ReturnType!func RetType;

    static if(is(RetType == void)) {
        return func(new_args);
    } else {
        auto ret = func(new_args);

        // TODO: constness
        static if(is(RetType : const(awe_string)*)) {
            // There is no need to free an awe_string* coming from awesomium if it's const!
            auto s = AWEString(cast(awe_string*)ret);
            static if(is(RetType == const(awe_string)*)) {
                scope(exit) s.destroy();
            }
            
            return s.to!string();
        } else static if(is(RetType : awe_webview*)) {
            return Webview.from_awe_webview(ret);
        } else static if(is(RetType : const(awe_renderbuffer)*)) {
            return Renderbuffer(ret);
        } else static if(is(RetType : const(awe_jsvalue)*)) {
            return JSValue(cast(awe_jsvalue*)ret);
        } else static if(is(RetType : const(awe_jsarray)*)) {
            return JSArray(cast(awe_jsarray*)ret);
        } else static if(is(RetType : const(awe_jsobject)*)) {
            return JSObject(cast(awe_jsobject*)ret);
        } else static if(is(RetType : const(awe_upload_element)*)) {
            return UploadElement(ret);
        } else static if(is(RetType : awe_history_query_result*)) {
            return HistoryQueryResult(ret);
        } else static if(is(RetType : awe_history_entry*)) {
            return HistoryEntry(ret);
        } else {
            return ret;
        }
    }
}

template convert_args(T...) {
    alias convert_args_impl!(T[0..$]) convert_args;
}

template convert_args_impl(T...) {
    static if(T.length == 0) {
        alias TypeTuple!() convert_args_impl;
    } else static if(is(T[0] == string) || is(T[0] == wstring)) {
        alias TypeTuple!(AWEString, convert_args_impl!(T[1..$])) convert_args_impl;
    } else static if(is(T[0] == string[]) || is(T[0] == wstring[])) {
        alias TypeTuple!(awe_string**, convert_args_impl!(T[1..$])) convert_args_impl;
    } else {
        alias TypeTuple!(T[0], convert_args_impl!(T[1..$])) convert_args_impl;
    }
}

template isInstanceOf(alias S, T)
{
    static if (is(T x == S!Args, Args...))
        enum bool isInstanceOf = true;
    else
        enum bool isInstanceOf = false;
}
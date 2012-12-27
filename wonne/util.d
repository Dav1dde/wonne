module wonne.util;

private {
    import deimos.awesomium.awesomium;
    
    import wonne.string;
    import wonne.webview;
    
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
        alias convert_strings!(Args) NewArgs;        

        NewArgs new_args;

        foreach(i, arg; args) {
            static if(is(typeof(arg) == string) || is(typeof(arg) == wstring)) {
                new_args[i] = AWEString(arg);
            } else {
                new_args[i] = arg;
            }
        }

        scope(exit) {
            foreach(i, arg; args) {
                static if(is(typeof(arg) == string) || is(typeof(arg) == wstring)) {
                    new_args[i].free();
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

        static if(is(RetType : const(awe_string)*)) {
            // There is no need to free an awe_string* coming from awesomium!
            return to!string(AWEString(cast(awe_string*)ret)); // awe_ functions return const(awe_string)*
        } else static if(is(RetType : awe_webview*)) {
            return new Webview(ret);
        } else {
            return ret;
        }
    }
}

template convert_strings(T...) {
    alias convert_strings_impl!(T[0..$]) convert_strings;
}

template convert_strings_impl(T...) {
    static if(T.length == 0) {
        alias TypeTuple!() convert_strings_impl;
    } else static if(is(T[0] == string) || is(T[0] == wstring)) {
        alias TypeTuple!(AWEString, convert_strings_impl!(T[1..$])) convert_strings_impl;
    } else {
        alias TypeTuple!(T[0], convert_strings_impl!(T[1..$])) convert_strings_impl;
    }
}
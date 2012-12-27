module wonne.util;

private {
    import deimos.awesomium.awesomium;
    
    import wonne.string;
    import wonne.webview;
    
    import std.typetuple : TypeTuple, allSatisfy;
    import std.traits : ReturnType, Unqual;
    import std.conv : to;
}


template is_awe_string(T...) if(T.length == 1) {
    enum is_awe_string = (is(T == string) || is(T == wstring) || is(T == AWEString) || is(T == awe_string*));
}

template is_awe_string(T...) if(T.length > 1) {
    alias allSatisfy!(is_awe_string, T);
}

/// Automatically converts a string for wstring into an AWEString and frees it after calling func.
/// It also converts the returntype of the function into a wonne abstraction or a d-type.
auto awe_call(alias func, Args...)(Args args) {
    alias convert_strings!(Args) NewArgs;

    NewArgs new_args;
    size_t[] to_free;

    foreach(i, arg; args) {
        static if(is(typeof(arg) == string) || is(typeof(arg) == wstring)) {
            new_args[i] = AWEString(arg);
            to_free ~= i;
        } else {
            new_args[i] = arg;
        }
    }

    scope(exit) {
        foreach(i; to_free) {
            new_args[i].free();
        }
    }

    auto ret = func(new_args);

    static if(is(typeof(Unqual!ret) == awe_string*)) {
        return to!string(AWEString(cast()ret)) // awe_ functions return const(awe_string)*
    } else static if(is(typeof(ret) == awe_webview*)) {
        return new Webview(awe_webview);
    } else {
        return ret;
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
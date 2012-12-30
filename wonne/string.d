module wonne.string;

private {
    import wonne.awesomium;

    import std.string : toStringz;
    import std.utf : toUTF16z;
    import std.conv : to;
}


string opCast(T : string)(const(awe_string)* value) {
    auto tmp = AWEString(value);
    return tmp.to!string();
}

struct AWEString {
    /// Holds the internal awe_string*
    awe_string* raw;
    ///
    alias raw this;

    /// Creates an AWEString from an awe_string.
    this(awe_string* inp) {
        raw = inp;
    }

    /// Creates an AWEString from a string. Keep a reference to the original string!
    this(string inp) {
        raw = awe_string_create_from_utf8(inp.toStringz(), inp.length);
    }

    /// Creates an AWEString from a wstring. Keep a reference to the original string!
    this(wstring inp) {
        raw = awe_string_create_from_utf16(inp.toUTF16z(), inp.length);
    }

    /// Returns an empty awe_string*, which is only a convenience function to pass the result
    /// to an awe-function directly. Do $(B not) free this string.
    static const(awe_string)* empty() {
        return awe_string_empty();
    }

    /// Returns the length of the internal awe_string*.
    @property size_t length() {
        return awe_string_get_length(raw);
    }

    /// Returns the length of the internal awe_string* if converted to UTF-8.
    @property size_t utf8_length() {
        return awe_string_to_utf8(raw, null, 0);
    }

    /// Returns the length of the internal awe_string* if converted to UTF-16.
    @property size_t utf16_length() {
        return awe_string_to_wide(raw, null, 0);
    }

    /// Frees the internal awe_string*.
    void destroy() {
        awe_string_destroy(raw);
    }

    /// Converts the internal awe_string* into a string.
    T opCast(T : string)() {
        char[] buf = new char[this.utf8_length];
        awe_string_to_utf8(raw, buf.ptr, buf.length);

        return buf.idup;
    }

    /// Converts the internal awe_string* into a wstring.
    T opCast(T : wstring)() {
        wchar[] buf = new wchar[this.utf16_length];
        awe_string_to_wide(raw, buf.ptr, buf.length);

        return buf.idup;
    }
}
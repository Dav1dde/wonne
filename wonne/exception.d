module wonne.exception;

class AwesomiumException : Exception {
    this(string s, string f=__FILE__, size_t l=__LINE__) {
        super(s, f, l);
    }
}

class WebviewException : AwesomiumException {
    this(string s, string f=__FILE__, size_t l=__LINE__) {
        super(s, f, l);
    }
}
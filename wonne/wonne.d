module wonne.wonne;


private {
    static import wonne.awesomium;

    static import std.algorithm;
    static import std.traits;
    static import core.runtime;

    version(Windows) {
        static import core.sys.windows.windows;
    }
}



mixin template AWESingleProcessMain(alias real_main) {
    int main() {
        version(Windows) {
            auto handle = core.sys.windows.windows.GetModuleHandleA(null);
            if(wonne.awesomium.awe_is_child_process(handle)) {
                debug writefln("Lanching awesomium child: %s", handle);
                return wonne.awesomium.awe_child_process_main(handle);
            }
        } else {
            if(std.algorithm.countUntil!(`a.length > 6 && a[0..6] == "--type"`)(core.runtime.Runtime.args) >= 0) {
                debug writefln("Lanching awesomium child: %s", core.runtime.Runtime.args);
                return wonne.awesomium.awe_child_process_main(core.runtime.Runtime.cArgs.argc,
                                                              core.runtime.Runtime.cArgs.argv);
            }
        }

        static if(is(std.traits.ReturnType!real_main : int)) {
            return real_main();
        } else {
            real_main();
        }

        return 0;
    }
}
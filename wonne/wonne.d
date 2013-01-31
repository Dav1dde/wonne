module wonne.wonne;


private {
    import wonne.awesomium : awe_is_child_process, awe_child_process_main;

    import std.algorithm : countUntil, startsWith;
    import std.traits : ReturnType;
    import core.runtime : Runtime;

    version(Windows) {
        import core.sys.windows.windows : GetModuleHandleA;
    }
}



mixin template AWESingleProcessMain(alias real_main) {
    int main() {
        version(Windows) {
            auto handle = GetModuleHandleA(null);
            if(awe_is_child_process(handle)) {
                debug writefln("Lanching awesomium child: %s", handle);
                return awe_child_process_main(handle);
            }
        } else {
            if(Runtime.args.countUntil!(x => x.startsWith("--type")) >= 0) {
                debug writefln("Lanching awesomium child: %s", Runtime.args);
                return awe_child_process_main(Runtime.cArgs.argc, Runtime.cArgs.argv);
            }
        }

        static if(is(ReturnType!real_main : int)) {
            return real_main();
        } else {
            real_main();
        }

        return 0;
    }
}
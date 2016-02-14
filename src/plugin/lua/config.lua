return {
    cocos2d = {
        ["2d"] = {
            src = { "./" }
        };

        ["3d"] = {
            src = { "./" };
            dependencies = { "bullet" }
        };

        audio = {
            include = { "./include" }
            src = {
                "./";
                android     = {"./android","./adnroid/jni"};
                mac         = {"./apple","./mac"};
                ios         = {"./apple","./ios"};
                linux       = {"./linux"};
                win32       = {"./win32"};
            }
        };

        base = {
            src = { "./", "./allocator" }
        };

        math = {};

        navmesh = {};

        physics = {};

        physics3d = {};

        platform = {
            src = {
                "./";
                android     = { "./android" ,"./android/jni" };
                mac         = { "./desktop","./apple","./mac" };
                ios         = { "./apple","./ios" };
                linux       = { "./desktop","./linux" };
                win32       = { "./desktop","./win32" };
            }
        };

        renderer = {};

        ["scripting/js-bindings"] = {
            src = { "auto","manual" }
        };

        ["scripting/lua-bindings"] = {
            src = { "auto","manual" }
        };

        storage = {
            src = {
                android = {"./local-storage"}
            }
        };

        ui = {
            src = {
                "./";
                ios = { "./UIEditBox/iOS" }
            };

            srcfiles = {
                "./UIEditBox/UIEditBoxImpl.h"
                "./UIEditBox/UIEditBox.h";
                "./UIEditBox/UIEditBox.cpp";
                "./UIEditBox/UIEditBoxImpl-common.h";
                "./UIEditBox/UIEditBoxImpl-common.cpp";
                "./UIEditBox/UIEditBoxImpl-stub.cpp";

                android = {
                    "./UIEditBox/UIEditBoxImpl-android.h";
                    "./UIEditBox/UIEditBoxImpl-android.cpp";
                };

                ios = {
                    "./UIEditBox/UIEditBoxImpl-ios.h";
                    "./UIEditBox/UIEditBoxImpl-ios.mm";
                };

                mac = {
                    "./UIEditBox/UIEditBoxImpl-mac.h";
                    "./UIEditBox/UIEditBoxImpl-mac.mm";
                };

                win32 = {
                    "./UIEditBox/UIEditBoxImpl-win32.h";
                    "./UIEditBox/UIEditBoxImpl-win32.mm";
                };

                winrt = {
                    "./UIEditBox/UIEditBoxImpl-winrt.h";
                    "./UIEditBox/UIEditBoxImpl-winrt.mm";
                };
            }
        };
    };
}

return {
    cocos2d = {
        srcfiles = {
            "./cocos2d.cpp";
            "./cocos2d.h";
        };

        dependencies = {
            "unzip";
            "clipper";
            "ConvertUTF";
            "edtaa3func";
            "poly2tri";
            "tinyxml2";
            "xxhash";
            "freetype2";
            "glfw3";
            "png";
            "jpeg";
            "tiff";
            "webp";
            "recast";
            "curl";
            win32 = { "win32-specific" };
        };

        modules = {
            ["2d"] = {
                src = { "./" };
                dependencies = { "Box2D","chipmunk" }
            };

            ["3d"] = {
                src = { "./" };
                dependencies = { "bullet" }
            };

            audio = {
                includes = { "./include" };
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

            deprecated = {};

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

            storage = {
                src = {
                    android = {"./local-storage"}
                }
            };

            ["editor-support/cocostudio"] = {
                includes = {"../"};

                src = {
                    "./", "./ActionTimeline",
                    "./WidgetReader",
                    "./WidgetReader/ArmatureNodeReader",
                    "./WidgetReader/ButtonReader",
                    "./WidgetReader/CheckBoxReader",
                    "./WidgetReader/ComAudioReader",
                    "./WidgetReader/GameMapReader",
                    "./WidgetReader/GameNode3DReader",
                    "./WidgetReader/ImageViewReader",
                    "./WidgetReader/LayoutReader",
                    "./WidgetReader/Light3DReader",
                    "./WidgetReader/ListViewReader",
                    "./WidgetReader/LoadingBarReader",
                    "./WidgetReader/Node3DReader",
                    "./WidgetReader/NodeReader",
                    "./WidgetReader/PageViewReader",
                    "./WidgetReader/Particle3DReader",
                    "./WidgetReader/ParticleReader",
                    "./WidgetReader/ProjectNodeReader",
                    "./WidgetReader/ScrollViewReader",
                    "./WidgetReader/SingleNodeReader",
                    "./WidgetReader/SkeletonReader",
                    "./WidgetReader/SliderReader",
                    "./WidgetReader/Sprite3DReader",
                    "./WidgetReader/SpriteReader",
                    "./WidgetReader/TextAtlasReader",
                    "./WidgetReader/TextBMFontReader",
                    "./WidgetReader/TextFieldReader",
                    "./WidgetReader/TextReader",
                    "./WidgetReader/UserCameraReader"
                }
            };

            ui = {
                src = {
                    "./";
                    ios = { "./UIEditBox/iOS" }
                };

                srcfiles = {
                    "./UIEditBox/UIEditBoxImpl.h";
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
                        "./UIEditBox/UIEditBoxImpl-win32.cpp";
                    };

                    winrt = {
                        "./UIEditBox/UIEditBoxImpl-winrt.h";
                        "./UIEditBox/UIEditBoxImpl-winrt.cpp";
                    };
                }
            };
        }
    };

    extra = {
        ["win32-specific"] = {
            prebuilt = true;
            modules  = {
                ["gles"] = {
                    includes = {"./include/OGLES"}
                },
                "icon","MP3decoder","OggDecoder","OpenalSoft","zlib"
            }
        };

        ["unzip"] = {
            includes = {
                ".";
                win32 = {"../win32-specific/zlib/include"}
            }
        };

        ["clipper"] = {};

        ["ConvertUTF"] = {};

        ["edtaa3func"] = {};

        ["poly2tri"] = {
            includes = {".",".."};
            src = { "./common","./sweep" }
        };

        ["tinyxml2"] = {};

        ["xxhash"] = {};

        ["png"] = {
            prebuilt = true;
        };

        ["jpeg"] = {
            prebuilt = true;
        };

        ["json"] = {
            prebuilt = true;
        };

        ["freetype2"] = {
            prebuilt = true;
            includes = {
                win32 = {"./include/win32/","./include/win32/freetype2"};
                ios = {"./include/ios/","./include/ios/freetype2"};
                mac = {"./include/mac/","./include/mac/freetype2"};
                linux = {"./include/linux/","./include/linux/freetype2"};
            }
        };

        ["tiff"] = {
            prebuilt = true;
        };

        ["webp"] = {
            prebuilt = true;
        };

        ["glfw3"] = {
            prebuilt = true;
            vslibtrack = true;
        };

        ["curl"] = {
            prebuilt = true;
        };

        ["chipmunk"] = {
            includes = {"./include","./include/chipmunk"};
            prebuilt = true;
            vslibtrack = true;
        };

        ["Box2D"] = {
            includes = {".."};
            src = {
                "./Collision","./Common","./Dynamics",
                "./Rope"
            }
        };

        ["bullet"] = {
            includes = {"..","./MiniCL"};
            src = {
                "./BulletCollision/BroadphaseCollision",
                "./BulletCollision/CollisionDispatch",
                "./BulletCollision/CollisionShapes","./BulletCollision/Gimpact",
                "./BulletCollision/NarrowPhaseCollision",
                "./BulletDynamics","./BulletDynamics/Character","./BulletDynamics/ConstraintSolver","./BulletDynamics/Dynamics",
                "./BulletDynamics/Featherstone","./BulletDynamics/MLCPSolvers","./BulletDynamics/Vehicle",
                "./BulletMultiThreaded","./BulletMultiThreaded/GpuSoftBodySolvers","./BulletMultiThreaded/SpuNarrowPhaseCollisionTask","./BulletMultiThreaded/SpuSampleTask",
                "./BulletSoftBody",
                "./LinearMath",
                "./MiniCL","./MiniCL/MiniCLTask"
            }
        };

        ["recast"] = {
            includes = {".."};
            src = {
                "./DebugUtils","./Detour","./DetourCrowd",
                "./DetourTileCache","./fastlz","./Recast"
            }
        }
    };

    libsimulator = {
        includes = {
            "./lib";
            "./lib/protobuf-lite";
            win32 = {"./proj.win32"}
        };
        src = {
            "./lib",
            "./lib/network",
            "./lib/ProjectConfig",
            "./lib/runtime",

            win32 = {
                "./lib/platform/win32";
                "./proj.win32";
            },
            mac   = {
                "./lib/platform/mac"
            }
        }
    };
}

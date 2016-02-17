cmake_minimum_required(VERSION 3.2)
set_property(GLOBAL PROPERTY USE_FOLDERS ON)

project(@{{name}})

@{{ if targethost == "Windows" then }}
foreach(flag_var CMAKE_C_FLAGS
        CMAKE_CXX_FLAGS CMAKE_C_FLAGS_DEBUG CMAKE_CXX_FLAGS_DEBUG
        CMAKE_C_FLAGS_RELEASE CMAKE_CXX_FLAGS_RELEASE CMAKE_C_FLAGS_MINSIZEREL
        CMAKE_CXX_FLAGS_MINSIZEREL CMAKE_C_FLAGS_RELWITHDEBINFO
        CMAKE_CXX_FLAGS_RELWITHDEBINFO)
    string(REGEX REPLACE "/W3" "/W4" ${flag_var} "${${flag_var}}")
endforeach(flag_var)
@{{ else }}
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++14")
@{{ end }}


add_subdirectory(cocos2d)


@{{ for _,ext in pairs(externals) do }}
add_subdirectory(@{{ext}})
@{{ end }}

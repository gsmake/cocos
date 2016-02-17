set(
header_files

@{{ for _,src in ipairs(headerfiles) do }}
@{{src}}

@{{ end }}
)

set(
src_files

@{{ for _,src in ipairs(srcfiles) do }}
@{{src}}

@{{ end }}
)

foreach(FILE ${header_files})
    get_filename_component(FILE_NAME ${FILE} NAME)
    string(REPLACE ${FILE_NAME} "" DIRECTORY ${FILE})

    file(RELATIVE_PATH DIRECTORY @{{srcroot}} ${DIRECTORY})

    file(TO_NATIVE_PATH "${DIRECTORY}" DIRECTORY)

    source_group("include\\${DIRECTORY}" FILES ${FILE})
endforeach()

foreach(FILE ${src_files})
    get_filename_component(FILE_NAME ${FILE} NAME)
    string(REPLACE ${FILE_NAME} "" DIRECTORY ${FILE})

    file(RELATIVE_PATH DIRECTORY @{{srcroot}} ${DIRECTORY})

    file(TO_NATIVE_PATH "${DIRECTORY}" DIRECTORY)

    source_group("sources\\${DIRECTORY}" FILES ${FILE})
endforeach()

include_directories(@{{srcroot}})

include_directories(
@{{ for _,src in ipairs(includes) do }}
@{{src}}

@{{ end }}
)

@{{ if targethost == "Windows" then }}
add_definitions(
    /DSTRICT
    /DGLFW_EXPOSE_NATIVE_WIN32
    /DGLFW_EXPOSE_NATIVE_WGL
    /D_SILENCE_STDEXT_HASH_DEPRECATION_WARNINGS
    /D_SCL_SECURE_NO_WARNINGS_DEBUG
    /D_USRLIBSIMSTATIC
    /D_UNICODE
    /D_USRDLL /D_CRT_SECURE_NO_WARNINGS /wd4100 /wd4244 /wd4701 /wd4819
    /wd4458 /wd4101 /wd4359 /wd4437 /wd4457 /wd4473 /wd4459
    /wd4189 /wd4389 /wd4706 /wd4245 /wd4267 /wd4018 /wd4702 /wd4310 /wd4316 /wd4305 /wd4127 /wd4463
    /wd4018 /wd4804 /wd4996 /wd4456 /wd4099 /wd4611 /wd4800 /wd4505 /wd4477 /wd4703 /wd4251)
@{{ else }}
add_definitions(-DCC_STATIC)
@{{ end }}

add_library(
@{{name}}

STATIC

${header_files}
${src_files}
)

target_link_libraries(
@{{name}}

@{{ for _,dep in ipairs(libs) do }}
@{{dep}}

@{{ end }}

@{{ if TargetHost == "Linux" then}}
pthread dl
@{{end}}

)

add_dependencies(
@{{name}}

cocos2d
)

set_target_properties(
        @{{name}}
        PROPERTIES
        RUNTIME_OUTPUT_DIRECTORY @{{outputdir}}/bin/
        RUNTIME_OUTPUT_DIRECTORY_DEBUG @{{outputdir}}/bin/
        RUNTIME_OUTPUT_DIRECTORY_RELEASE @{{outputdir}}/bin/)

set_target_properties(
        @{{name}}
        PROPERTIES
        ARCHIVE_OUTPUT_DIRECTORY  @{{outputdir}}/lib/
        ARCHIVE_OUTPUT_DIRECTORY_DEBUG @{{outputdir}}/lib/
        ARCHIVE_OUTPUT_DIRECTORY_RELEASE @{{outputdir}}/lib/)
set_target_properties(
        @{{name}}
        PROPERTIES
        LIBRARY_OUTPUT_DIRECTORY  @{{outputdir}}/lib/
        LIBRARY_OUTPUT_DIRECTORY_DEBUG @{{outputdir}}/lib/
        LIBRARY_OUTPUT_DIRECTORY_RELEASE @{{outputdir}}/lib/)

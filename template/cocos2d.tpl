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
    /D_USRDLL /DCOCOS2DXWIN32_EXPORTS /D_SCL_SECURE_NO_WARNINGS /DUNICODE
    /D_USE3DDLL
    /D_EXPORT_DLL_
    /D_USRSTUDIODLL
    /D_USREXDLL
    /D_USEGUIDLL
    /DCC_ENABLE_CHIPMUNK_INTEGRATION=1
    /D_UNICODE /D_CRT_SECURE_NO_WARNINGS /wd4100 /wd4244 /wd4701 /wd4302
    /wd4189 /wd4389 /wd4706 /wd4245 /wd4267 /wd4018 /wd4702 /wd4310
    /wd4018 /wd4804 /wd4996 /wd4456 /wd4099 /wd4611 /wd4800 /wd4505 /wd4477 /wd4703 /wd4251)
@{{ else }}
add_definitions(-DCC_STATIC)
@{{ end }}

link_directories(
@{{ for _,src in ipairs(linkdirs) do }}
@{{src}}

@{{ end }}
)

add_library(
@{{name}}

@{{ if targethost == "Windows" then}}
SHARED
@{{ else }}
STATIC
@{{ end }}

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

@{{ for _,src in ipairs(deps) do }}
@{{src}}

@{{ end }}
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

# Provides the `qmltui_ptyview_libvterm` target for QmlTui::PtyView: system
# libvterm via pkg-config when QMLTUI_PTYVIEW_USE_SYSTEM_LIBVTERM is enabled,
# otherwise the pinned 0.3.3 release tarball compiled as a static C99 library.
#
# A macro, not a function: enable_language() must run at directory scope.

macro(qmltui_ptyview_provide_libvterm)
    if(TARGET qmltui_ptyview_libvterm)
        # already provided
    elseif(QMLTUI_PTYVIEW_USE_SYSTEM_LIBVTERM)
        find_package(PkgConfig REQUIRED)
        if(NOT TARGET PkgConfig::libvterm)
            pkg_check_modules(libvterm REQUIRED IMPORTED_TARGET GLOBAL vterm>=0.3)
        endif()
        add_library(qmltui_ptyview_libvterm ALIAS PkgConfig::libvterm)
    else()
        enable_language(C)
        _qmltui_ptyview_fetch_libvterm()
    endif()
endmacro()

function(_qmltui_ptyview_fetch_libvterm)
    include(FetchContent)
    FetchContent_Declare(libvterm
        URL https://www.leonerd.org.uk/code/libvterm/libvterm-0.3.3.tar.gz
        URL_HASH SHA256=09156f43dd2128bd347cbeebe50d9a571d32c64e0cf18d211197946aff7226e0
        DOWNLOAD_EXTRACT_TIMESTAMP TRUE
    )
    FetchContent_MakeAvailable(libvterm)

    # The tarball has no CMake project of its own; list its sources here.
    add_library(qmltui_ptyview_libvterm STATIC
        ${libvterm_SOURCE_DIR}/src/encoding.c
        ${libvterm_SOURCE_DIR}/src/keyboard.c
        ${libvterm_SOURCE_DIR}/src/mouse.c
        ${libvterm_SOURCE_DIR}/src/parser.c
        ${libvterm_SOURCE_DIR}/src/pen.c
        ${libvterm_SOURCE_DIR}/src/screen.c
        ${libvterm_SOURCE_DIR}/src/state.c
        ${libvterm_SOURCE_DIR}/src/unicode.c
        ${libvterm_SOURCE_DIR}/src/vterm.c
    )
    target_compile_features(qmltui_ptyview_libvterm PRIVATE c_std_99)
    target_include_directories(qmltui_ptyview_libvterm PUBLIC $<BUILD_INTERFACE:${libvterm_SOURCE_DIR}/include>)
    set_target_properties(qmltui_ptyview_libvterm PROPERTIES
        AUTOMOC OFF
        AUTOUIC OFF
        AUTORCC OFF
        POSITION_INDEPENDENT_CODE ON
        C_VISIBILITY_PRESET hidden
    )
endfunction()

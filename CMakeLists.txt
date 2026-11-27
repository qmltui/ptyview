cmake_minimum_required(VERSION 3.21)
project(QmlTuiPtyView VERSION 0.6.0 LANGUAGES CXX)

if(NOT CMAKE_SYSTEM_NAME MATCHES "Linux|Darwin")
    message(FATAL_ERROR "QmlTui.PtyView currently supports only Linux and macOS")
endif()

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

if(CMAKE_SOURCE_DIR STREQUAL CMAKE_CURRENT_SOURCE_DIR)
    set(_ptyview_is_top_level ON)
else()
    set(_ptyview_is_top_level OFF)
endif()

set(_ptyview_default_tests ${_ptyview_is_top_level})
if(EMSCRIPTEN)
    set(_ptyview_default_tests OFF)
endif()

option(QMLTUI_PTYVIEW_BUILD_TESTS "Build QmlTui.PtyView unit and scenario tests" ${_ptyview_default_tests})
option(QMLTUI_PTYVIEW_BUILD_EXAMPLES "Build QmlTui.PtyView example apps" ${_ptyview_is_top_level})
option(QMLTUI_USE_INSTALLED "Consume an installed QmlTui 0.6 package instead of FetchContent" OFF)
option(QMLTUI_PTYVIEW_USE_SYSTEM_LIBVTERM "Use system libvterm via pkg-config instead of FetchContent" OFF)

if(_ptyview_is_top_level)
    if(QMLTUI_PTYVIEW_BUILD_TESTS)
        include(CTest)
    endif()
    if(NOT TARGET QmlTui::Core)
        if(QMLTUI_USE_INSTALLED)
            find_package(Qt6 6.8 REQUIRED COMPONENTS Core Qml)
            qt_standard_project_setup(REQUIRES 6.8)
            find_package(QmlTui 0.6 REQUIRED COMPONENTS Core Controls OPTIONAL_COMPONENTS Runner)
        else()
            include(FetchContent)
            set(QMLTUI_BUILD_EXAMPLES OFF CACHE BOOL "" FORCE)
            set(QMLTUI_BUILD_TESTS OFF CACHE BOOL "" FORCE)
            set(QMLTUI_BUILD_BENCHMARKS OFF CACHE BOOL "" FORCE)
            FetchContent_Declare(
                qmltui
                GIT_REPOSITORY https://github.com/qmltui/qmltui.git
                GIT_TAG main
                GIT_SHALLOW TRUE
            )
            FetchContent_MakeAvailable(qmltui)
            find_package(Qt6 6.8 REQUIRED COMPONENTS Core Qml)
            qt_standard_project_setup(REQUIRES 6.8)
        endif()
    endif()
    if(QMLTUI_PTYVIEW_BUILD_TESTS)
        find_package(Qt6 6.8 REQUIRED COMPONENTS Test)
    endif()
    set(QMLTUI_RECORD_DIR "${PROJECT_SOURCE_DIR}/docs/assets/casts")
    file(MAKE_DIRECTORY "${QMLTUI_RECORD_DIR}")
    find_program(QMLTUI_AGG_EXECUTABLE NAMES agg HINTS "$ENV{HOME}/.cargo/bin")
    if(QMLTUI_AGG_EXECUTABLE)
        set(QMLTUI_RECORD_POST_COMMAND
            "${QMLTUI_AGG_EXECUTABLE}"
            --theme asciinema
            --text-font-family "JetBrains Mono,Fira Code,SF Mono,Menlo,Consolas,Adwaita Mono,JetBrainsMono Nerd Font,Noto Sans Symbols 2,DejaVu Sans Mono,Liberation Mono"
            --quiet
            "<CAST>"
            "<CAST_STEM>.gif"
        )
    endif()
endif()

include("${CMAKE_CURRENT_SOURCE_DIR}/cmake/QmlTuiPtyViewLibvterm.cmake")
qmltui_ptyview_provide_libvterm()

if(NOT QT_QML_OUTPUT_DIRECTORY)
    set(QT_QML_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/qml" CACHE PATH
        "Build-tree location for generated QML modules")
endif()

set(_ptyview_module_deps
    DEPENDENCIES
        QtQml
)
get_target_property(_qmltui_is_imported QmlTui::Core IMPORTED)
if(_qmltui_is_imported)
    if(QmlTui_QML_IMPORT_PATH)
        list(APPEND _ptyview_module_deps IMPORT_PATH "${QmlTui_QML_IMPORT_PATH}")
    endif()
else()
    list(APPEND _ptyview_module_deps
        TARGET QmlTui::Core
    )
endif()

qt_add_qml_module(QmlTuiPtyView
    URI QmlTui.PtyView
    STATIC
    OUTPUT_DIRECTORY "${QT_QML_OUTPUT_DIRECTORY}/QmlTui/PtyView"
    SOURCES
        src/PtyView.h
        src/PtyView.cpp
        src/VTermAdapter.h
        src/VTermAdapter.cpp
        src/UnixPtySession.h
        src/UnixPtySession.cpp
    ${_ptyview_module_deps}
)

target_include_directories(QmlTuiPtyView
    PUBLIC "${CMAKE_CURRENT_SOURCE_DIR}/src"
    PRIVATE "${CMAKE_CURRENT_SOURCE_DIR}"
)

target_link_libraries(QmlTuiPtyView
    PUBLIC
        Qt6::Core
        Qt6::Qml
        QmlTui::Core
    PRIVATE
        qmltui_ptyview_libvterm
    INTERFACE
        QmlTuiPtyViewplugin
)

if(CMAKE_SYSTEM_NAME STREQUAL "Linux")
    target_link_libraries(QmlTuiPtyView PRIVATE util)
endif()

if(NOT TARGET QmlTui::PtyView)
    add_library(QmlTui::PtyView ALIAS QmlTuiPtyView)
endif()

if(QMLTUI_PTYVIEW_BUILD_TESTS)
    qt_add_executable(tst_ptyview
        tests/tst_ptyview.cpp
    )
    target_link_libraries(tst_ptyview PRIVATE
        Qt6::Core
        Qt6::Qml
        Qt6::Test
        QmlTui::Core
        QmlTui::PtyView
        qmltui_ptyview_libvterm
    )
    add_test(NAME tst_ptyview COMMAND tst_ptyview)
    set_tests_properties(tst_ptyview PROPERTIES
        ENVIRONMENT "QML2_IMPORT_PATH=${QT_QML_OUTPUT_DIRECTORY};QML_IMPORT_PATH=${QT_QML_OUTPUT_DIRECTORY}"
        LABELS "Unit"
    )
endif()

if(QMLTUI_PTYVIEW_BUILD_EXAMPLES)
    add_subdirectory(examples/hello_ptyview)
endif()

if(_ptyview_is_top_level AND COMMAND qmltui_scenario_editor_support)
    qmltui_scenario_editor_support()
endif()

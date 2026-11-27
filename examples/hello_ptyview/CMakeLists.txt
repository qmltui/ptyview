if(TARGET QmlTui::Core)
    set(_ex_core QmlTui::Core)
    set(_ex_controls QmlTui::Controls)
else()
    set(_ex_core qmltui::core)
    set(_ex_controls qmltui::controls)
endif()

if(TARGET QmlTui::Runner)
    set(_ex_runner QmlTui::Runner)
elseif(TARGET qmltui::runner)
    set(_ex_runner qmltui::runner)
else()
    set(_ex_runner "")
endif()

set(_hello_deps
    DEPENDENCIES
        TARGET QmlTuiPtyView
)
get_target_property(_core_imported ${_ex_core} IMPORTED)
if(_core_imported)
    if(QmlTui_QML_IMPORT_PATH)
        list(APPEND _hello_deps IMPORT_PATH "${QmlTui_QML_IMPORT_PATH}")
    endif()
else()
    list(APPEND _hello_deps
        TARGET ${_ex_core}
        TARGET ${_ex_controls}
    )
endif()

qt_add_executable(ptyview_hello
    main.cpp
)

qt_add_qml_module(ptyview_hello
    URI PtyViewHelloExample
    QML_FILES
        Main.qml
    ${_hello_deps}
)

target_link_libraries(ptyview_hello PRIVATE
    Qt6::Core
    Qt6::Qml
    ${_ex_core}
    ${_ex_controls}
    QmlTui::PtyView
)

if(QMLTUI_PTYVIEW_BUILD_TESTS AND _ex_runner)
    target_link_libraries(ptyview_hello PRIVATE ${_ex_runner})
    qmltui_add_scenario(
        NAME test_runner_ptyview_hello
        TARGET ptyview_hello
        SCRIPT "${CMAKE_CURRENT_SOURCE_DIR}/smoke.js"
        COLUMNS 84
        ROWS 20
        CLOCK REAL
    )
    if(QMLTUI_RECORD_DIR)
        qmltui_add_scenario(
            NAME ptyview_hello_demo
            TARGET ptyview_hello
            SCRIPT "${CMAKE_CURRENT_SOURCE_DIR}/demo.js"
            COLUMNS 84
            ROWS 20
            CLOCK REAL
            RECORD hello_ptyview.cast
            LABELS Demo
        )
    endif()
endif()

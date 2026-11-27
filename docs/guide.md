# Embedded PTY Shells (`QmlTui.PtyView`)

`QmlTui.PtyView` provides [`PtyView`](reference.md), an embedded terminal emulator backed by a Unix pseudo-terminal (PTY) and `libvterm`. Use it when a QmlTui application needs to host an interactive shell, SSH session, or external CLI process inside a layout pane on Linux or macOS.

If your application only needs to stream its own output into the parent terminal's scrollback while keeping a live prompt at the bottom, use QmlTui's cross-platform `Terminal.Inline` and `Scrollback` instead; inline mode works on all platforms and does not require a PTY.

## Adding `QmlTui.PtyView` in CMake

`QmlTui.PtyView` is supported on Linux and macOS. By default, CMake fetches a pinned copy of `libvterm` (`0.3.3`); pass `-DQMLTUI_PTYVIEW_USE_SYSTEM_LIBVTERM=ON` to link a system-installed `libvterm` (`vterm >= 0.3` via `pkg-config`):

```cmake
include(FetchContent)
FetchContent_Declare(
    qmltui_ptyview
    GIT_REPOSITORY https://github.com/qmltui/ptyview.git
    GIT_TAG main
    GIT_SHALLOW TRUE
)
FetchContent_MakeAvailable(qmltui_ptyview)

qt_add_qml_module(my_app
    URI MyApp
    QML_FILES Main.qml
    DEPENDENCIES
        TARGET QmlTuiPtyView
)
target_link_libraries(my_app PRIVATE Qt6::Core Qt6::Qml QmlTui::Core QmlTui::PtyView)
```

## Process Configuration

`PtyView` launches `program` and `arguments` directly via `QProcess::start()` without invoking an intermediate shell or expanding shell metacharacters. As a convenience for interactive command strings, when `arguments` is empty and `program` does not match an existing file path or an executable on `PATH`, `PtyView::start()` falls back to `QProcess::splitCommand(program)` and populates `arguments` from the remaining tokens. When explicit `arguments` are supplied, `program` is never split; pass an explicit executable path or `PATH` command name in `program` and put flags in `arguments` whenever strict argv separation is required:

- `program` and `arguments`: executable path/name and argument list. Call `pty.defaultUserShell()` to query the current user's login shell.
- `workingDirectory`: initial working directory for the child process.
- `environment` and `inheritEnvironment`: map of extra environment variables (`{ "MY_VAR": "1" }`), merged with the parent process environment when `inheritEnvironment: true` (default).
- `terminalType`: sets `TERM` inside the PTY (defaults to `"xterm-256color"`, along with `COLORTERM=truecolor` and `TERM_PROGRAM=qmltui`).
- `autoStart`: starts the child process automatically when the QML component completes, or call `start()`, `terminate()` (`SIGTERM`), and `kill()` (`SIGKILL`) explicitly.

## Key Interception, Focus Escape, `sendText()`, and Scrollback

While running and focused, `PtyView` forwards `Tab`, printable keys (`Q`), `Escape`, arrow keys, `Ctrl+C`, and SGR mouse events (when requested by the child) directly to the child PTY so interactive programs inside the shell work naturally. Built-in `Shift+PageUp`, `Shift+PageDown`, `Shift+Up`, `Shift+Down`, and `Shift+Wheel` bindings navigate `PtyView`'s local scrollback (`scrollBarVisible: true` reserves the rightmost column in `TIOCSWINSZ` once scrollback history exists). Always provide a host `Shortcut` (such as `Shortcut { sequence: "Ctrl+Q"; ... }` or a focus-switching chord) or attach `Keys.priority: Keys.BeforeItem` so keyboard users can move focus out of `PtyView` or exit the host application:

```qml
pragma ComponentBehavior: Bound
import QtQml
import QmlTui
import QmlTui.PtyView

Terminal {
    id: root

    ColumnLayout {
        anchors.fill: parent
        spacing: 1

        Text {
            text: "PID: " + pty.processId + " | State: " + (pty.running ? "Running" : "Stopped (" + pty.exitCode + ")")
                  + " | Title: " + (pty.title || "shell")
            color: "cyan"
            bold: true
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            border {
                style: pty.activeFocus ? Border.Double : Border.Single
                color: pty.activeFocus ? "cyan" : "gray"
            }

            PtyView {
                id: pty
                anchors.fill: parent
                focus: true
                program: defaultUserShell()
                arguments: ["-l"]
                autoStart: true

                Keys.priority: Keys.BeforeItem
                Keys.onPressed: event => {
                    if ((event.modifiers & Qt.ControlModifier) && event.key === Qt.Key_Q) {
                        pty.terminate();
                        Qt.quit();
                        event.accepted = true;
                    } else if (event.key === Qt.Key_F1) {
                        pty.sendText("echo 'Hello from QmlTui'\n");
                        event.accepted = true;
                    } else if (event.key === Qt.Key_PageUp) {
                        pty.scrollOffset = Math.min(pty.scrollbackSize, pty.scrollOffset + 5);
                        event.accepted = true;
                    } else if (event.key === Qt.Key_Escape && pty.scrollOffset > 0) {
                        pty.scrollToBottom();
                        event.accepted = true;
                    }
                }

                onFinished: exitCode => Qt.quit()
            }
        }
    }
}
```

## Security Defaults and OSC Permissions

Child processes can emit Operating System Command (OSC) sequences. `PtyView` gates side-effecting sequences by default:

| Property | Default | Behavior |
| :--- | :--- | :--- |
| `allowTitleChanges` | `true` | Updates the read-only `title` property when the child emits OSC 0 / OSC 2 window title sequences. |
| `allowClipboardWrite` | `false` | When enabled, OSC 52 clipboard requests emit `clipboardWriteRequested(string text)` rather than writing to the host clipboard directly. |
| `allowNotifications` | `false` | When enabled, OSC 9 / OSC 777 notification requests emit `notificationRequested(string title, string message)`. |

## Testing `PtyView` with `Runner`

`PtyView` renders its internal `libvterm` screen and scrollback rows directly into the host `TextGridBuffer` during paint. Because `PtyView` spawns a real OS child process, register scenarios exercising `PtyView` on `CLOCK REAL` and synchronize on shell output with `app.waitForText("...", timeoutMs)`, `app.frameText()`, or `app.item("shellView")` scoped assertions.

See the [API Reference](reference.md), [`examples/hello_ptyview/`](../examples/hello_ptyview/), and the integrated shell drawer in [`file_manager`](https://github.com/qmltui/apps/tree/main/apps/file_manager) (`qmltui/apps`).

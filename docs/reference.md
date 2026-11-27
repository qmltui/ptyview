# `PtyView` Reference

`qmltui::PtyView` is an embedded terminal emulator item that spawns a child process inside a Unix pseudo-terminal (PTY) and decodes its VT output stream into the QmlTui cell grid using `libvterm`.

- **QML Import**: `import QmlTui.PtyView`
- **C++ Header**: `"PtyView.h"` (`qmltui::PtyView`)
- **Inherits**: `qmltui::Item`, `QQmlParserStatus`
- **CMake Target**: `QmlTui::PtyView` (Linux and macOS)

## Properties

| Property | QML Type | C++ Type | Default | Description |
| :--- | :--- | :--- | :--- | :--- |
| `program` | `string` | `QString` | `PtyView.defaultUserShell()` | Executable path or command name to launch in the PTY (defaults to `$SHELL`, `getpwuid`, or `"/bin/sh"`). |
| `arguments` | `list<string>` | `QStringList` | `[]` | Arguments passed directly via `QProcess::start()` without shell expansion. |
| `workingDirectory` | `string` | `QString` | `""` | Initial working directory for the child process. |
| `environment` | `var` | `QVariantMap` | `{}` | Extra custom environment variables merged into the child process environment. |
| `inheritEnvironment` | `bool` | `bool` | `true` | Whether the child inherits the parent process environment. |
| `terminalType` | `string` | `QString` | `"xterm-256color"` | Value assigned to `TERM` inside the PTY. |
| `autoStart` | `bool` | `bool` | `false` | Starts the child process automatically once `componentComplete()` runs. |
| `processState` | `ProcessState` | `ProcessState` | `PtyView.NotRunning` | Read-only lifecycle state: `NotRunning`, `Starting`, `Running`, or `Stopping`. |
| `running` | `bool` | `bool` | `false` | Read-only; `true` while `processState === PtyView.Running`. |
| `processId` | `qlonglong` | `qint64` | `0` | Read-only OS PID of the child process, or `0` when not running. |
| `exitCode` | `int` | `int` | `-1` | Read-only exit status of the last terminated child (`-1` before exit). |
| `errorString` | `string` | `QString` | `""` | Read-only diagnostic message from the last PTY or spawn error. |
| `title` | `string` | `QString` | `""` | Read-only dynamic terminal title requested via OSC 0 / OSC 2 when `allowTitleChanges` is `true`. |
| `textColor` | `color` | `qmltui::Color` | `QmlTui.defaultColor` | Default foreground text color (terminal ink when unset). |
| `backgroundColor` | `color` | `qmltui::Color` | `"transparent"` | Default background color (transparent by default so parent backgrounds show through). |
| `palette` | `list<color>` | `QList<qmltui::Color>` | `[]` | Optional 16-entry ANSI color palette override. |
| `scrollbackLimit` | `int` | `int` | `10000` | Maximum number of scrollback lines retained in history. |
| `scrollOffset` | `int` | `int` | `0` | Current scroll offset into scrollback history (`0` shows the live screen). |
| `scrollbackSize` | `int` | `int` | `0` | Read-only count of lines currently stored in scrollback. |
| `scrollBarVisible` | `bool` | `bool` | `true` | Draws a 1-column scrollbar and reserves `width - 1` child PTY columns once scrollback history exists. |
| `allowTitleChanges` | `bool` | `bool` | `true` | Allows child OSC 0/2 sequences to update `title`. |
| `allowClipboardWrite` | `bool` | `bool` | `false` | Allows child OSC 52 sequences to emit `clipboardWriteRequested(text)`. |
| `allowNotifications` | `bool` | `bool` | `false` | Allows child OSC 9/777 sequences to emit `notificationRequested(title, message)`. |

## Signals

| Signal | Description |
| :--- | :--- |
| `started()` | Emitted when the child process has launched. |
| `finished(int exitCode)` | Emitted when the child process exits, providing its exit status. |
| `errorOccurred(string error)` | Emitted when PTY creation or process launch fails. |
| `bell()` | Emitted when the child writes `BEL` (`\a`). |
| `clipboardWriteRequested(string text)` | Emitted when `allowClipboardWrite` is `true` and the child sends an OSC 52 write request. |
| `notificationRequested(string title, string message)` | Emitted when `allowNotifications` is `true` and the child sends an OSC 9 or OSC 777 notification. |

## Methods (`Q_INVOKABLE`)

| Method | Description |
| :--- | :--- |
| `string defaultUserShell()` | Static helper returning the current user's login shell from `$SHELL`, `getpwuid()`, or `"/bin/sh"`. |
| `void start()` | Spawns `program` (or `defaultUserShell()`) in a fresh PTY sized to the item's cell geometry. |
| `void terminate()` | Sends `SIGTERM` to the child process group. |
| `void kill()` | Sends `SIGKILL` to the child process group. |
| `void sendText(string text)` | Writes UTF-8 `text` directly to the PTY master descriptor. |
| `void clearScrollback()` | Clears retained scrollback lines and resets `scrollOffset` to `0`. |
| `void scrollToBottom()` | Resets `scrollOffset` to `0`. |

## Enumeration `PtyView.ProcessState`

| Value | Description |
| :--- | :--- |
| `PtyView.NotRunning` | No child process is running. |
| `PtyView.Starting` | The PTY session and child process are initializing. |
| `PtyView.Running` | The child process is active inside the PTY. |
| `PtyView.Stopping` | Termination has been requested (`terminate()` or `kill()`). |

## C++ Example

```cpp
#include "PtyView.h"

auto* view = new qmltui::PtyView(parentItem);
view->setWidth(80);
view->setHeight(24);
view->setProgram(qmltui::PtyView::defaultUserShell());
view->setArguments({QStringLiteral("-l")});
view->setFocus(true);
view->start();
```

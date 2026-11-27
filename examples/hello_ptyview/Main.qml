pragma ComponentBehavior: Bound

import QtQml
import QmlTui
import QmlTui.Controls
import QmlTui.PtyView

Terminal {
    id: root

    property string statusText: "Ready"

    function sendCommand() {
        const cmd = cmdInput.text.trim();
        if (cmd.length === 0)
            return;
        shellView.sendText(cmd + "\n");
        root.statusText = "Sent: " + cmd;
    }

    title: shellView.title || "QmlTui.PtyView"

    Component.onDestruction: shellView.kill()

    // Unmodified single-key shortcut is suppressed while TextInput or a running
    // PtyView holds active focus; Ctrl+Q and Escape always remain reachable.
    Shortcut {
        sequence: Qt.Key_Q
        onActivated: Qt.quit()
    }

    Shortcut {
        sequence: "Ctrl+Q"
        onActivated: {
            shellView.terminate();
            Qt.quit();
        }
    }

    Keys.onPressed: event => {
        if (event.key === Qt.Key_Escape) {
            shellView.terminate();
            Qt.quit();
            event.accepted = true;
        }
    }

    ColumnLayout {
        anchors {
            fill: parent
            margins: 1
        }
        spacing: 1

        RowLayout {
            Layout.fillWidth: true
            spacing: 2

            Text {
                text: shellView.running ? "[RUNNING]" : "[STOPPED]"
                color: shellView.running ? "#a6e3a1" : "#f87171"
                bold: true
            }

            Text {
                Layout.fillWidth: true
                clip: true
                text: "PID: " + shellView.processId + "  ·  " + root.statusText
                color: "#8b949e"
            }

            Text {
                text: "[Ctrl+Q / Esc] Quit"
                color: "#8b949e"
                dim: true
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: "#161b22"
            border {
                style: shellView.activeFocus ? Border.Double : Border.Single
                color: shellView.activeFocus ? "#58a6ff" : "#30363d"
            }

            PtyView {
                id: shellView
                objectName: "shellView"
                anchors {
                    fill: parent
                    margins: 1
                }
                program: defaultUserShell()
                arguments: ["-l"]
                autoStart: true

                Keys.priority: Keys.BeforeItem
                Keys.onPressed: event => {
                    if (event.key === Qt.Key_Escape) {
                        shellView.terminate();
                        Qt.quit();
                        event.accepted = true;
                    }
                }
            }
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 1

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 1
                color: "#161b22"

                TextInput {
                    id: cmdInput
                    objectName: "cmdInput"
                    anchors.fill: parent
                    focus: true
                    text: "echo 'Hello from PtyView!'"
                    color: "#f8fafc"
                    onAccepted: root.sendCommand()
                }
            }

            Button {
                text: "Send"
                onClicked: root.sendCommand()
            }

            Button {
                text: "Clear"
                onClicked: shellView.clearScrollback()
            }
        }
    }
}

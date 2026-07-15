import Quickshell
import Quickshell.Io
import QtQuick

Item {
    id: root

    property var barWindow: null
    property string iconNotification: "@notifier-icon-notification@"
    property string iconDnd: "@notifier-icon-dnd@"
    property string qsBin: "@quickshell-bin@"
    property string notifierShellPath: "@notifier-shell-path@"

    property int notifCount: 0
    property bool dndActive: false

    function parseStatus(text) {
        var parts = text.trim().split("|");
        if (parts.length >= 2) {
            root.notifCount = parseInt(parts[0]) || 0;
            root.dndActive = parts[1] === "1";
        }
    }

    function ipcCall(fn) {
        var proc = ipcProc;
        proc.command = ["sh", "-c", root.qsBin + " -p '" + root.notifierShellPath + "' ipc call notifier " + fn + " 2>/dev/null"];
        proc.running = true;
    }

    Component.onCompleted: {
        statusProc.running = true;
        listenProc.running = true;
    }

    Process {
        id: listenProc
        command: ["sh", "-c", root.qsBin + " -p '" + root.notifierShellPath + "' ipc listen notifier statusChanged 2>/dev/null"]
        stdout: SplitParser {
            onRead: msg => root.parseStatus(msg)
        }
        onExited: {
            listenProc.running = true;
        }
    }

    Process {
        id: statusProc
        command: ["sh", "-c", root.qsBin + " -p '" + root.notifierShellPath + "' ipc call notifier getStatus 2>/dev/null"]
        stdout: StdioCollector {
            onStreamFinished: root.parseStatus(this.text)
        }
    }

    Process {
        id: ipcProc
        stdout: StdioCollector {
            onStreamFinished: root.parseStatus(this.text)
        }
    }

    implicitWidth: notifyText.implicitWidth + Base.margin * 2
    implicitHeight: Base.height + Base.padTop + Base.padBottom

    Rectangle {
        anchors.fill: parent
        anchors.topMargin: Base.padTop
        anchors.bottomMargin: Base.padBottom
        color: Base.bg
        radius: Base.radius

        Text {
            id: notifyText
            anchors.fill: parent
            anchors.leftMargin: Base.margin
            anchors.rightMargin: Base.margin
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
            text: {
                var icon = root.dndActive ? root.iconDnd : root.iconNotification;
                if (root.notifCount > 0) {
                    return icon + " " + root.notifCount;
                }
                return icon;
            }
            color: root.dndActive ? Base.urgent : Base.text
            font.pixelSize: Base.fontSize
            font.family: Base.fontName
        }

        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.LeftButton | Qt.MiddleButton | Qt.RightButton
            onClicked: mouse => {
                if (mouse.button === Qt.LeftButton) {
                    root.ipcCall("toggle");
                } else if (mouse.button === Qt.MiddleButton) {
                    restartProc.running = true;
                } else if (mouse.button === Qt.RightButton) {
                    root.ipcCall("toggleDnd");
                }
            }
        }
    }

    Process {
        id: restartProc
        command: ["systemctl", "--user", "restart", "mtshell-notifier"]
        stdout: StdioCollector {}
        onRunningChanged: {
            if (!running)
                statusProc.running = true;
        }
    }
}

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

    // One controller owns the cross-process center, even with several bars.
    property bool destroying: false
    property bool centerVisible: false
    property bool reportedVisible: false
    property real seenRevision: -1
    property string pendingCenter: ""
    property bool pendingDnd: false
    property string currentCommand: ""
    property string commandResponse: ""

    function reconcileCenter() {
        if (Base.notifierController !== root || pendingCenter !== ""
                || currentCommand === "show" || currentCommand === "hide")
            return;
        root.centerVisible = root.reportedVisible;
        if (root.centerVisible)
            Base.claimPopup(root);
        else
            Base.releasePopup(root);
    }

    function parseStatus(text) {
        var parts = text.trim().split("|");
        if (parts.length >= 2) {
            root.notifCount = parseInt(parts[0]) || 0;
            root.dndActive = parts[1] === "1";
        }
        if (parts.length >= 4) {
            var revision = Number(parts[3]);
            if (isFinite(revision) && revision > root.seenRevision) {
                root.seenRevision = revision;
                root.reportedVisible = parts[2] === "1";
                root.reconcileCenter();
            }
        }
    }

    function runNextCommand() {
        if (ipcProc.running || currentCommand !== "")
            return;
        if (pendingCenter !== "") {
            root.currentCommand = root.pendingCenter;
            root.pendingCenter = "";
        } else if (pendingDnd) {
            root.currentCommand = "toggleDnd";
            root.pendingDnd = false;
        } else {
            return;
        }
        root.commandResponse = "";
        ipcProc.command = [root.qsBin, "-p", root.notifierShellPath,
            "ipc", "call", "--", "notifier", root.currentCommand];
        ipcProc.running = true;
    }

    function closePopup() {
        root.centerVisible = false;
        root.pendingCenter = "hide";
        Base.releasePopup(root);
        root.runNextCommand();
    }

    function ipcCall(fn) {
        var controller = Base.notifierController;
        if (!controller)
            return;
        if (controller !== root) {
            controller.ipcCall(fn);
            return;
        }
        if (fn === "toggle") {
            root.centerVisible = !root.centerVisible;
            root.pendingCenter = root.centerVisible ? "show" : "hide";
            if (root.centerVisible)
                Base.claimPopup(root);
            else
                Base.releasePopup(root);
        } else if (fn === "toggleDnd") {
            root.pendingDnd = !root.pendingDnd;
        }
        root.runNextCommand();
    }

    function electController() {
        if (!root.destroying && !Base.notifierController) {
            Base.notifierController = root;
            root.reconcileCenter();
            statusProc.running = true;
        }
    }

    Connections {
        target: Base
        function onNotifierControllerChanged() { root.electController(); }
    }

    Component.onCompleted: {
        root.electController();
        statusProc.running = true;
        listenProc.running = true;
    }
    Component.onDestruction: {
        root.destroying = true;
        Base.releasePopup(root);
        if (Base.notifierController === root)
            Base.notifierController = null;
    }

    Timer {
        id: reconnectTimer
        interval: 1000
        onTriggered: {
            listenProc.running = true;
            statusProc.running = true;
        }
    }

    Process {
        id: listenProc
        command: [root.qsBin, "-p", root.notifierShellPath,
            "ipc", "listen", "--", "notifier", "statusChanged"]
        stdout: SplitParser {
            onRead: msg => root.parseStatus(msg)
        }
        onExited: {
            root.seenRevision = -1;
            root.reportedVisible = false;
            root.centerVisible = false;
            Base.releasePopup(root);
            reconnectTimer.restart();
        }
    }

    Process {
        id: statusProc
        command: [root.qsBin, "-p", root.notifierShellPath,
            "ipc", "call", "--", "notifier", "getStatus"]
        stdout: StdioCollector {
            onStreamFinished: root.parseStatus(this.text)
        }
    }

    Process {
        id: ipcProc
        stdout: StdioCollector {
            onStreamFinished: root.commandResponse = this.text
        }
        onExited: (exitCode, exitStatus) => {
            root.currentCommand = "";
            if (exitCode === 0) {
                root.parseStatus(root.commandResponse);
            } else {
                root.reportedVisible = false;
                Base.releasePopup(root);
            }
            root.reconcileCenter();
            root.runNextCommand();
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

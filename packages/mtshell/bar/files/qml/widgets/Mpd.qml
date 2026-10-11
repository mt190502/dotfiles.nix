import Quickshell
import Quickshell.Io
import QtQuick

Item {
    id: root

    property bool connected: false
    property string playState: "stopped"
    property int elapsedSecs: 0
    property int totalSecs: 0
    property bool repeat: false
    property bool random: false
    property bool single: false
    property bool consume: false
    property string mpc: "@mpc-bin@"

    function refresh() {
        mpcProc.running = true;
    }

    function timeToSecs(t) {
        var parts = t.split(":");
        return parseInt(parts[0]) * 60 + parseInt(parts[1]);
    }

    function secsToTime(s) {
        var m = Math.floor(s / 60);
        var sec = s % 60;
        return m + ":" + (sec < 10 ? "0" : "") + sec;
    }

    function parseOutput(text) {
        var trimmed = text.trim();
        if (trimmed.length === 0) {
            root.connected = false;
            return;
        }
        root.connected = true;
        var lines = trimmed.split("\n");
        var stateLine = null;
        var toggleLine = null;
        for (var i = 0; i < lines.length; i++) {
            if (/^\[\w+\]/.test(lines[i]))
                stateLine = lines[i];
            if (/volume:/.test(lines[i]))
                toggleLine = lines[i];
        }

        if (stateLine) {
            var stateMatch = stateLine.match(/^\[(\w+)\]/);
            root.playState = stateMatch[1];
            var timeMatch = stateLine.match(/(\d+:\d+)\/(\d+:\d+)/);
            if (timeMatch) {
                root.elapsedSecs = timeToSecs(timeMatch[1]);
                root.totalSecs = timeToSecs(timeMatch[2]);
            }
        } else {
            root.playState = "stopped";
            root.elapsedSecs = 0;
            root.totalSecs = 0;
        }

        if (toggleLine) {
            root.repeat = /repeat: on/.test(toggleLine);
            root.random = /random: on/.test(toggleLine);
            root.single = /single: on/.test(toggleLine);
            root.consume = /consume: on/.test(toggleLine);
        }
    }

    Component.onCompleted: {
        root.refresh();
        idleProc.running = true;
    }

    Timer {
        id: elapsedTimer
        interval: 1000
        repeat: true
        running: root.playState === "playing"
        onTriggered: {
            if (root.elapsedSecs < root.totalSecs)
                root.elapsedSecs++;
            else
                root.refresh();
        }
    }

    Process {
        id: idleProc
        command: ["sh", "-c", root.mpc + " idle player options 2>/dev/null"]
        stdout: SplitParser {
            onRead: msg => root.refresh()
        }
        onExited: {
            idleProc.running = true;
        }
    }

    Process {
        id: mpcProc
        command: ["sh", "-c", root.mpc + " status 2>/dev/null"]
        stdout: StdioCollector {
            onStreamFinished: root.parseOutput(this.text)
        }
    }

    Process {
        id: mpcCmd
        stdout: StdioCollector {}
    }

    function execMpc(args) {
        mpcCmd.command = ["sh", "-c", root.mpc + " " + args];
        mpcCmd.running = true;
    }

    implicitWidth: contentText.implicitWidth + Base.margin * 2
    implicitHeight: Base.height + Base.padTop + Base.padBottom

    Rectangle {
        anchors.fill: parent
        anchors.topMargin: Base.padTop
        anchors.bottomMargin: Base.padBottom
        color: Base.bg
        radius: Base.radius

        Text {
            id: contentText
            anchors.fill: parent
            anchors.leftMargin: Base.margin
            anchors.rightMargin: Base.margin
            verticalAlignment: Text.AlignVCenter
            text: {
                if (!root.connected)
                    return "@mpd-disconnected-text@";
                var stateIcon = root.playState === "playing" ? "@mpd-icon-playing@" : root.playState === "paused" ? "@mpd-icon-paused@" : "@mpd-icon-stopped@";
                var toggles = "";
                if (root.consume)
                    toggles += "@mpd-icon-consume@";
                if (root.random)
                    toggles += "@mpd-icon-random@";
                if (root.repeat)
                    toggles += "@mpd-icon-repeat@";
                if (root.single)
                    toggles += "@mpd-icon-single@";
                var time = root.totalSecs > 0 ? root.secsToTime(root.elapsedSecs) + "/" + root.secsToTime(root.totalSecs) : "";
                var parts = [stateIcon];
                if (time.length > 0)
                    parts.push(time);
                if (toggles.length > 0)
                    parts.push(toggles);
                return parts.join(" | ");
            }
            color: Base.text
            font.pixelSize: Base.fontSize
            font.family: Base.fontName
        }

        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.LeftButton | Qt.MiddleButton | Qt.RightButton
            onClicked: mouse => {
                if (mouse.button === Qt.LeftButton) {
                    root.execMpc("toggle");
                } else if (mouse.button === Qt.MiddleButton) {
                    root.execMpc("stop");
                } else if (mouse.button === Qt.RightButton) {
                    var scriptPath = "@mpd-right-click-script@";
                    if (scriptPath.length > 0) {
                        Quickshell.execDetached(["sh", "-c", scriptPath]);
                    }
                }
            }
            onWheel: wheel => {
                if (wheel.angleDelta.y > 0)
                    root.execMpc("volume +5");
                else
                    root.execMpc("volume -5");
            }
        }
    }
}

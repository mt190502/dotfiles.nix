import Quickshell
import Quickshell.Io
import QtQuick

Item {
    id: root

    property string deviceName: "@backlight-device@"
    property var icons: ["@backlight-icon-0@", "@backlight-icon-1@", "@backlight-icon-2@", "@backlight-icon-3@", "@backlight-icon-4@"]
    property string scrollUpCmd: '@backlight-scroll-up-cmd@'
    property string scrollDownCmd: '@backlight-scroll-down-cmd@'
    property string inotifywait: "@inotifywait-bin@"

    property bool hasBacklight: false
    property int brightness: 0
    property int maxBrightness: 1
    visible: hasBacklight
    implicitWidth: hasBacklight ? (backText.implicitWidth + Base.margin * 2) : 0
    implicitHeight: hasBacklight ? (Base.height + Base.padTop + Base.padBottom) : 0

    function updateText() {
        backText.text = (root.icons[root.iconIndex] || "") + " " + root.percent + "%";
    }

    Process {
        id: checkProc
        command: ["sh", "-c", "test -d /sys/class/backlight/" + root.deviceName + " && echo yes || echo no"]
        stdout: StdioCollector {
            onStreamFinished: {
                root.hasBacklight = this.text.trim() === "yes";
                if (root.hasBacklight) {
                    maxProc.running = true;
                    root.refresh();
                    watchProc.running = true;
                }
            }
        }
    }

    Component.onCompleted: checkProc.running = true

    Process {
        id: watchProc
        command: ["sh", "-c", root.inotifywait + " -m -e modify -e attrib /sys/class/backlight/" + root.deviceName + "/brightness 2>/dev/null"]
        stdout: SplitParser {
            onRead: msg => root.refresh()
        }
        onExited: {
            if (root.hasBacklight)
                watchProc.running = true;
        }
    }

    function refresh() {
        if (!root.hasBacklight)
            return;
        brightProc.running = true;
    }

    Process {
        id: maxProc
        command: ["sh", "-c", "cat /sys/class/backlight/" + root.deviceName + "/max_brightness 2>/dev/null"]
        stdout: StdioCollector {
            onStreamFinished: {
                var val = parseInt(this.text.trim());
                if (!isNaN(val) && val > 0)
                    root.maxBrightness = val;
            }
        }
    }

    Process {
        id: brightProc
        command: ["sh", "-c", "cat /sys/class/backlight/" + root.deviceName + "/brightness 2>/dev/null"]
        stdout: StdioCollector {
            onStreamFinished: {
                var val = parseInt(this.text.trim());
                if (!isNaN(val)) {
                    root.brightness = val;
                    root.updateText();
                }
            }
        }
    }

    Process {
        id: actionProc
        stdout: StdioCollector {}
        onRunningChanged: {
            if (!running)
                root.refresh();
        }
    }

    function execAction(cmd) {
        actionProc.command = ["sh", "-c", cmd];
        actionProc.running = true;
    }

    readonly property int percent: Math.round(brightness / maxBrightness * 100)

    readonly property int iconIndex: {
        if (percent >= 80)
            return 4;
        if (percent >= 60)
            return 3;
        if (percent >= 40)
            return 2;
        if (percent >= 20)
            return 1;
        return 0;
    }

    Rectangle {
        anchors.fill: parent
        anchors.topMargin: Base.padTop
        anchors.bottomMargin: Base.padBottom
        color: Base.bg
        radius: Base.radius

        Text {
            id: backText
            anchors.fill: parent
            anchors.leftMargin: Base.margin
            anchors.rightMargin: Base.margin
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
            text: ""
            color: Base.text
            font.pixelSize: Base.fontSize
            font.family: Base.fontName
        }

        MouseArea {
            anchors.fill: parent
            onWheel: wheel => {
                if (wheel.angleDelta.y > 0) {
                    if (root.scrollUpCmd.length > 0)
                        root.execAction(root.scrollUpCmd);
                } else {
                    if (root.scrollDownCmd.length > 0)
                        root.execAction(root.scrollDownCmd);
                }
            }
        }
    }
}

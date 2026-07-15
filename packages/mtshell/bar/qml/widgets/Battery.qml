import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: root

    property string deviceName: "@battery-device@"
    property var icons: ["@battery-icon-0@", "@battery-icon-1@", "@battery-icon-2@", "@battery-icon-3@", "@battery-icon-4@"]
    property int warningThreshold: @battery-warning@
    property int criticalThreshold: @battery-critical@
    property string inotifywait: "@inotifywait-bin@"
    property bool hasBattery: false
    property int capacity: 0
    property string status: "Unknown"
    readonly property int iconIndex: {
        if (capacity >= 90)
            return 4;
        if (capacity >= 70)
            return 3;
        if (capacity >= 40)
            return 2;
        if (capacity >= 20)
            return 1;
        return 0;
    }
    readonly property bool isCritical: capacity <= criticalThreshold
    readonly property bool isWarning: capacity <= warningThreshold && !isCritical

    function updateText() {
        batText.text = (root.icons[root.iconIndex] || "") + " " + root.capacity + "%";
    }

    function refresh() {
        if (!root.hasBattery)
            return ;
        capProc.running = true;
        statusProc.running = true;
    }

    visible: hasBattery
    implicitWidth: hasBattery ? (batText.implicitWidth + Base.margin * 2) : 0
    implicitHeight: hasBattery ? (Base.height + Base.padTop + Base.padBottom) : 0
    Component.onCompleted: checkProc.running = true

    Process {
        id: checkProc
        command: ["sh", "-c", "test -d /sys/class/power_supply/" + root.deviceName + " && echo yes || echo no"]
        stdout: StdioCollector {
            onStreamFinished: {
                root.hasBattery = this.text.trim() === "yes";
                if (root.hasBattery) {
                    root.refresh();
                    watchProc.running = true;
                }
            }
        }
    }

    Process {
        id: watchProc
        command: ["sh", "-c", root.inotifywait + " -m -e modify /sys/class/power_supply/" + root.deviceName + "/capacity /sys/class/power_supply/" + root.deviceName + "/status 2>/dev/null"]
        onExited: {
            if (root.hasBattery)
                watchProc.running = true;

        }
        stdout: SplitParser {
            onRead: (msg) => {
                return root.refresh();
            }
        }
    }

    Process {
        id: capProc
        command: ["sh", "-c", "cat /sys/class/power_supply/" + root.deviceName + "/capacity 2>/dev/null"]
        stdout: StdioCollector {
            onStreamFinished: {
                var val = parseInt(this.text.trim());
                if (!isNaN(val)) {
                    root.capacity = val;
                    root.updateText();
                }
            }
        }
    }

    Process {
        id: statusProc
        command: ["sh", "-c", "cat /sys/class/power_supply/" + root.deviceName + "/status 2>/dev/null"]
        stdout: StdioCollector {
            onStreamFinished: root.status = this.text.trim() || "Unknown"
        }
    }

    Rectangle {
        anchors.fill: parent
        anchors.topMargin: Base.padTop
        anchors.bottomMargin: Base.padBottom
        color: Base.bg
        radius: Base.radius

        Text {
            id: batText
            anchors.fill: parent
            anchors.leftMargin: Base.margin
            anchors.rightMargin: Base.margin
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
            text: ""
            color: root.isCritical ? Base.urgent : root.isWarning ? Base.active : Base.text
            font.pixelSize: Base.fontSize
            font.family: Base.fontName
        }
    }
}
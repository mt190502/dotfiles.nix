import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: root

    property string deviceName: "@battery-device@"
    property string chargingIcon: "@battery-charging-icon@"
    property string chargingBackground: "@battery-charging-background@"
    property string criticalBackground: "@battery-critical-background@"
    property var icons: ["@battery-icon-0@", "@battery-icon-1@", "@battery-icon-2@", "@battery-icon-3@", "@battery-icon-4@"]
    property int warningThreshold: @battery-warning@
    property int criticalThreshold: @battery-critical@
    property string upower: "@upower-bin@"
    property bool laptopDetected: false
    property bool hasBattery: false
    property int capacity: 0
    property string status: "Unknown"
    property bool remainingVisible: false
    property string remainingTime: ""
    readonly property int iconIndex: {
        if (capacity >= 80)
            return 4;
        if (capacity >= 60)
            return 3;
        if (capacity >= 40)
            return 2;
        if (capacity >= 20)
            return 1;
        return 0;
    }
    readonly property bool isCharging: status === "Charging"
    readonly property bool isCritical: capacity < criticalThreshold
    readonly property bool isWarning: capacity <= warningThreshold && !isCritical

    function updateText() {
        var icon = root.isCharging ? root.chargingIcon : (root.icons[root.iconIndex] || "");
        var remaining = root.remainingVisible && !root.isCharging && root.remainingTime.length > 0
            ? " (" + root.remainingTime + ")"
            : "";
        batText.text = icon + " " + root.capacity + "%" + remaining;
    }

    function refresh() {
        if (!root.hasBattery)
            return ;
        capProc.running = true;
        statusProc.running = true;
        estimateProc.running = true;
    }

    visible: laptopDetected && hasBattery
    implicitWidth: visible ? (batText.implicitWidth + Base.margin * 2) : 0
    implicitHeight: visible ? (Base.height + Base.padTop + Base.padBottom) : 0
    Component.onCompleted: if (root.laptopDetected) checkProc.running = true
    onLaptopDetectedChanged: if (root.laptopDetected) checkProc.running = true

    Process {
        id: checkProc
        command: ["sh", "-c", "device='" + root.deviceName + "'; if [ -n \"$device\" ] && [ -d /sys/class/power_supply/\"$device\" ]; then printf '%s\\n' \"$device\"; else for path in /sys/class/power_supply/*; do if [ -f \"$path/capacity\" ]; then basename \"$path\"; break; fi; done; fi"]
            stdout: StdioCollector {
            onStreamFinished: {
                root.deviceName = this.text.trim();
                root.hasBattery = root.deviceName.length > 0;
                if (root.hasBattery) {
                    root.refresh();
                    watchProc.running = true;
                }
            }
        }
    }

    Process {
        id: watchProc
        command: [root.upower, "--monitor-detail"]
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
            onStreamFinished: {
                root.status = this.text.trim() || "Unknown";
                root.updateText();
            }
        }
    }

    Process {
        id: estimateProc
        command: ["sh", "-c", "base=/sys/class/power_supply/" + root.deviceName + "; status=$(cat \"$base/status\" 2>/dev/null); if [ \"$status\" = Discharging ]; then if [ -r \"$base/time_to_empty_now\" ]; then seconds=$(cat \"$base/time_to_empty_now\"); elif [ -r \"$base/energy_now\" ] && [ -r \"$base/power_now\" ]; then energy=$(cat \"$base/energy_now\"); power=$(cat \"$base/power_now\"); [ \"$power\" -gt 0 ] && seconds=$((energy * 3600 / power)); fi; if [ -n \"$seconds\" ] && [ \"$seconds\" -ge 0 ]; then printf '%sh %02dm\\n' $((seconds / 3600)) $(((seconds % 3600) / 60)); fi; fi"]
        stdout: StdioCollector {
            onStreamFinished: {
                root.remainingTime = this.text.trim();
                root.updateText();
            }
        }
    }

        Rectangle {
            anchors.fill: parent
            anchors.topMargin: Base.padTop
            anchors.bottomMargin: Base.padBottom
            color: root.isCritical ? root.criticalBackground : root.isCharging ? root.chargingBackground : Base.bg
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

        MouseArea {
            anchors.fill: parent
            onClicked: {
                root.remainingVisible = !root.remainingVisible;
                root.updateText();
            }
        }
    }
}

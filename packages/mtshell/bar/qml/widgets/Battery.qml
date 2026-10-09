import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: root

    required property var barWindow
    property string cpupower: "@cpupower-bin@"
    property var availableProfiles: []
    property string activeProfile: ""
    property string profileError: ""
    property string currentGovernors: ""
    property string balancedGovernor: ""
    property bool tlpActive: false
    readonly property bool profileBusy: profilesProc.running || setProfileProc.running

    function refreshProfiles() {
        if (!tlpStatusProc.running)
            tlpStatusProc.running = true;
        if (!root.profileBusy)
            profilesProc.running = true;
    }

    function selectProfile(profile) {
        if (root.profileBusy || root.activeProfile === profile || root.availableProfiles.indexOf(profile) < 0)
            return;
        root.profileError = "";
        powerPopup.visible = false;
        var governor = profile === "performance" ? "performance" : profile === "power-saver" ? "powersave" : root.balancedGovernor;
        if (["performance", "powersave", "schedutil", "ondemand"].indexOf(governor) < 0)
            return;
        setProfileProc.command = ["pkexec", root.cpupower, "--cpu", "all", "frequency-set", "--governor", governor];
        setProfileProc.running = true;
    }

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
        var remaining = root.remainingVisible && !root.isCharging && root.remainingTime.length > 0 ? " (" + root.remainingTime + ")" : "";
        batText.text = icon + " " + root.capacity + "%" + remaining;
    }

    function refresh() {
        if (!root.hasBattery)
            return;
        capProc.running = true;
        statusProc.running = true;
        estimateProc.running = true;
    }

    visible: laptopDetected && hasBattery
    implicitWidth: visible ? (batText.implicitWidth + Base.margin * 2) : 0
    implicitHeight: visible ? (Base.height + Base.padTop + Base.padBottom) : 0
    Component.onCompleted: if (root.laptopDetected)
        checkProc.running = true
    onLaptopDetectedChanged: if (root.laptopDetected)
        checkProc.running = true

    Timer {
        interval: 3000
        repeat: true
        running: powerPopup.visible
        onTriggered: root.refreshProfiles()
    }

    Process {
        id: tlpStatusProc
        command: ["@systemctl-bin@", "is-active", "--quiet", "tlp.service"]
        stdout: StdioCollector {}
        stderr: StdioCollector {}
        onExited: (exitCode, exitStatus) => root.tlpActive = exitCode === 0 && exitStatus === 0
    }

    Process {
        id: profilesProc
        command: ["sh", "-c", "found=0; for policy in /sys/devices/system/cpu/cpufreq/policy[0-9]*; do [ -d \"$policy\" ] || continue; IFS= read -r available < \"$policy/scaling_available_governors\" || exit 1; IFS= read -r current < \"$policy/scaling_governor\" || exit 1; printf '%s|%s\\n' \"$available\" \"$current\"; found=1; done; [ \"$found\" = 1 ]"]
        stdout: StdioCollector { id: profilesOutput }
        stderr: StdioCollector { id: profilesError }
        onExited: (exitCode, exitStatus) => {
            var common = [];
            var governors = [];
            var valid = exitCode === 0 && exitStatus === 0 && profilesOutput.text.trim().length > 0;
            if (valid) {
                var lines = profilesOutput.text.trim().split("\n");
                for (var i = 0; i < lines.length; i++) {
                    var fields = lines[i].split("|");
                    if (fields.length !== 2 || !fields[0].trim() || !fields[1].trim()) {
                        valid = false;
                        break;
                    }
                    var available = fields[0].trim().split(/\s+/);
                    common = i === 0 ? available : common.filter(value => available.indexOf(value) >= 0);
                    var current = fields[1].trim();
                    if (governors.indexOf(current) < 0)
                        governors.push(current);
                }
            }
            if (!valid) {
                common = [];
                governors = [];
            }
            var balanced = common.indexOf("schedutil") >= 0 ? "schedutil" : common.indexOf("ondemand") >= 0 ? "ondemand" : "";
            var mapping = { performance: "performance", balanced: balanced, "power-saver": "powersave" };
            var profiles = ["performance", "balanced", "power-saver"].filter(profile => mapping[profile] && common.indexOf(mapping[profile]) >= 0);
            root.availableProfiles = profiles;
            root.activeProfile = governors.length === 1 ? profiles.find(profile => mapping[profile] === governors[0]) || "" : "";
            root.currentGovernors = governors.join(", ");
            root.balancedGovernor = balanced;
            if (!valid)
                root.profileError = "CPU governors unavailable.\n" + profilesError.text.trim();
            else if (root.profileError.indexOf("CPU governors unavailable.") === 0)
                root.profileError = "";
        }
    }

    Process {
        id: setProfileProc
        stdout: StdioCollector {}
        stderr: StdioCollector { id: setProfileError }
        onExited: (exitCode, exitStatus) => {
            if (exitCode !== 0 || exitStatus !== 0)
                root.profileError = "Could not change CPU governor. Authorization may have been denied or cancelled.\n" + setProfileError.text.trim();
            profilesProc.running = true;
            powerPopup.visible = true;
        }
    }

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
            onRead: msg => {
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
            acceptedButtons: Qt.LeftButton | Qt.RightButton
            onClicked: mouse => {
                if (mouse.button === Qt.LeftButton) {
                    powerPopup.visible = !powerPopup.visible;
                } else {
                    root.remainingVisible = !root.remainingVisible;
                    root.updateText();
                }
            }
        }
    }

    OverlayPopup {
        id: powerPopup
        anchorItem: root
        visible: false
        screen: root.barWindow.screen
        cardWidth: 280
        cardHeight: popupContent.implicitHeight + 24

        onVisibleChanged: {
            if (visible) {
                root.refresh();
                root.refreshProfiles();
            }
        }

        Column {
            id: popupContent
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.margins: 12
            spacing: 8

            Text {
                text: "Battery · " + root.capacity + "%"
                color: Base.text
                font.pixelSize: Base.fontSize
                font.family: Base.fontName
                font.bold: true
            }

            Text {
                width: parent.width
                text: root.status + (root.remainingTime ? " · " + root.remainingTime + " remaining" : "")
                color: Base.text
                font.pixelSize: Base.fontSize - 1
                font.family: Base.fontName
                wrapMode: Text.WordWrap
            }

            Repeater {
                model: [
                    { profile: "performance", label: "Performance" },
                    { profile: "balanced", label: "Balanced" },
                    { profile: "power-saver", label: "Powersave" }
                ]

                delegate: Rectangle {
                    id: profileRow
                    required property var modelData
                    readonly property bool supported: root.availableProfiles.indexOf(modelData.profile) >= 0
                    readonly property bool selected: supported && root.activeProfile === modelData.profile
                    width: popupContent.width
                    height: 38
                    color: selected || profileMouse.containsMouse ? Base.inactive : "transparent"
                    border.color: selected ? Base.active : Base.border
                    border.width: selected ? 2 : 1
                    opacity: supported ? 1 : 0.45

                    Text {
                        anchors.fill: parent
                        anchors.margins: 8
                        verticalAlignment: Text.AlignVCenter
                        text: (profileRow.selected ? "● " : "○ ") + profileRow.modelData.label + (!profileRow.supported ? " (unavailable)" : "")
                        color: Base.text
                        font.pixelSize: Base.fontSize
                        font.family: Base.fontName
                        elide: Text.ElideRight
                    }

                    MouseArea {
                        id: profileMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        enabled: profileRow.supported && !root.profileBusy
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.selectProfile(profileRow.modelData.profile)
                    }
                }
            }

            Text {
                width: parent.width
                text: "Current: " + (root.currentGovernors || "Unknown") + (root.availableProfiles.indexOf("balanced") < 0 ? "\nBalanced requires schedutil or ondemand." : "\nBalanced: " + root.balancedGovernor)
                color: Base.active
                font.pixelSize: Base.fontSize - 1
                font.family: Base.fontName
                wrapMode: Text.Wrap
            }

            Text {
                width: parent.width
                visible: root.profileError.length > 0
                text: root.profileError
                textFormat: Text.PlainText
                color: Base.urgent
                font.pixelSize: Base.fontSize - 1
                font.family: Base.fontName
                wrapMode: Text.Wrap
                maximumLineCount: 5
                elide: Text.ElideRight
            }

            Text {
                width: parent.width
                visible: root.tlpActive
                text: "TLP is active; power-source changes may reset this setting."
                color: Base.inactive
                font.pixelSize: Math.max(9, Base.fontSize - 2)
                font.family: Base.fontName
                wrapMode: Text.WordWrap
            }
        }
    }
}

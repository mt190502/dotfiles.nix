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
    property string osdIpc: "@osd-ipc@"
    property string screenName: ""
    property bool laptopDetected: false

    property bool hasBacklight: false
    property var brightnessReading: ({ brightness: 0, maximum: 1 })
    readonly property real brightness: brightnessReading.brightness
    readonly property real maxBrightness: brightnessReading.maximum
    property bool osdPending: false
    property bool keyboardOsdPending: false
    visible: laptopDetected && hasBacklight
    implicitWidth: visible ? (backText.implicitWidth + Base.margin * 2) : 0
    implicitHeight: visible ? (Base.height + Base.padTop + Base.padBottom) : 0

    Component.onCompleted: {
        if (root.laptopDetected) {
            checkProc.running = true;
            keyboardWatch.running = true;
        }
    }
    onLaptopDetectedChanged: {
        if (root.laptopDetected) {
            checkProc.running = true;
            keyboardWatch.running = true;
        }
    }

    function parseReading(text) {
        const values = text.trim().split(/\s+/);
        if (values.length !== 2 || !/^\d+$/.test(values[0]) || !/^\d+$/.test(values[1]))
            return null;
        const current = Number(values[0]);
        const maximum = Number(values[1]);
        if (!isFinite(current) || !isFinite(maximum) || maximum <= 0)
            return null;
        return { brightness: current, maximum: maximum };
    }

    function boundedPercent(current, maximum) {
        if (!isFinite(current) || !isFinite(maximum) || maximum <= 0)
            return 0;
        return Math.round(Math.max(0, Math.min(1, current / maximum)) * 100);
    }

    Process {
        id: checkProc
        command: ["sh", "-c", "device='" + root.deviceName + "'; if [ -n \"$device\" ] && [ -d /sys/class/backlight/\"$device\" ]; then printf '%s\\n' \"$device\"; else for path in /sys/class/backlight/*; do if [ -d \"$path\" ]; then basename \"$path\"; break; fi; done; fi"]
        stdout: StdioCollector {
            onStreamFinished: {
                root.deviceName = this.text.trim();
                root.hasBacklight = root.deviceName.length > 0;
                if (root.hasBacklight) {
                    root.refresh();
                    watchProc.running = true;
                }
            }
        }
    }

    Process {
        id: watchProc
        command: ["sh", "-c", root.inotifywait + " -m -e modify -e attrib /sys/class/backlight/" + root.deviceName + "/brightness 2>/dev/null"]
        stdout: SplitParser {
            onRead: msg => {
                root.osdPending = true;
                root.refresh();
            }
        }
        onExited: {
            if (root.hasBacklight)
                watchProc.running = true;
        }
    }

    Process {
        id: keyboardWatch
        command: ["sh", "-c", "for path in /sys/class/leds/*kbd_backlight; do [ -r \"$path/brightness\" ] || continue; read -r last < \"$path/brightness\"; while sleep 0.2; do read -r value < \"$path/brightness\"; if [ \"$value\" != \"$last\" ]; then printf '%s\\n' \"$value\"; last=\"$value\"; fi; done; done"]
        stdout: SplitParser {
            onRead: msg => {
                root.keyboardOsdPending = true;
                keyboardBrightProc.running = true;
            }
        }
        onExited: if (root.hasBacklight)
            keyboardWatch.running = true
    }

    function refresh() {
        if (!root.hasBacklight)
            return;
        brightProc.running = true;
    }

    Process {
        id: osdProc
        stdout: StdioCollector {}
    }

    Process {
        id: keyboardBrightProc
        command: ["sh", "-c", "for path in /sys/class/leds/*kbd_backlight; do [ -r \"$path/brightness\" ] && [ -r \"$path/max_brightness\" ] || continue; cat \"$path/brightness\" \"$path/max_brightness\"; break; done"]
        stdout: StdioCollector {
            onStreamFinished: {
                const reading = root.parseReading(this.text);
                if (reading && root.keyboardOsdPending) {
                    root.keyboardOsdPending = false;
                    const percent = root.boundedPercent(reading.brightness, reading.maximum);
                    if (root.osdIpc.length > 0) {
                        osdProc.command = ["sh", "-c", root.osdIpc + " keyboard-brightness " + percent + " false '" + root.screenName + "'"];
                        osdProc.running = true;
                    }
                }
            }
        }
    }

    Process {
        id: brightProc
        command: ["cat", "/sys/class/backlight/" + root.deviceName + "/brightness", "/sys/class/backlight/" + root.deviceName + "/max_brightness"]
        stdout: StdioCollector {
            onStreamFinished: {
                const reading = root.parseReading(this.text);
                if (reading) {
                    root.brightnessReading = reading;
                    if (root.osdPending && root.osdIpc.length > 0) {
                        root.osdPending = false;
                        osdProc.command = ["sh", "-c", root.osdIpc + " brightness " + root.percent + " false '" + root.screenName + "'"];
                        osdProc.running = true;
                    }
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

    readonly property int percent: boundedPercent(brightnessReading.brightness, brightnessReading.maximum)

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
            text: (root.icons[root.iconIndex] || "") + " " + root.percent + "%"
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

import Quickshell
import Quickshell.Io
import QtQuick

Item {
    id: root

    property var iconVolume: ["@pulseaudio-icon-volume-0@", "@pulseaudio-icon-volume-1@", "@pulseaudio-icon-volume-2@"]
    property string iconMuted: "@pulseaudio-icon-muted@"
    property string iconMic: "@pulseaudio-icon-mic@"
    property string iconMicMuted: "@pulseaudio-icon-mic-muted@"
    property string clickCmd: '@pulseaudio-click-cmd@'
    property string middleClickCmd: '@pulseaudio-middle-click-cmd@'
    property string rightClickCmd: '@pulseaudio-right-click-cmd@'
    property string scrollUpCmd: '@pulseaudio-scroll-up-cmd@'
    property string scrollDownCmd: '@pulseaudio-scroll-down-cmd@'
    property string wpctl: "@wpctl-bin@"
    property string pactl: "@pactl-bin@"
    property string osdIpc: "@osd-ipc@"
    property string screenName: ""

    property int sinkVolume: 0
    property bool sinkMuted: false
    property int sourceVolume: 0
    property bool sourceMuted: false
    property bool rightButtonHeld: false
    property bool rightWheelUsed: false
    property bool osdPending: false
    property int lastOsdVolume: -1
    property bool lastOsdMuted: false
    property bool hasOsdBaseline: false

    readonly property int volumeIconIndex: {
        if (sinkVolume >= 67)
            return 2;
        if (sinkVolume >= 34)
            return 1;
        return 0;
    }

    function updateText() {
        var s = root.sinkMuted ? root.iconMuted : (root.iconVolume[root.volumeIconIndex] + " " + root.sinkVolume + "%");
        var m = root.sourceMuted ? root.iconMicMuted : (root.iconMic + " " + root.sourceVolume + "%");
        pulseText.text = s + "  " + m;
    }

    function refresh() {
        sinkProc.running = true;
        sourceProc.running = true;
    }

    function showOsd() {
        if (root.osdIpc.length > 0) {
            osdProc.command = ["sh", "-c", root.osdIpc + " volume " + root.sinkVolume + " " + root.sinkMuted + " '" + root.screenName + "'"];
            osdProc.running = true;
        }
    }

    Component.onCompleted: {
        root.refresh();
        watchProc.running = true;
    }

    Process {
        id: watchProc
        command: ["sh", "-c", root.pactl + " subscribe 2>/dev/null"]
        stdout: SplitParser {
            onRead: msg => {
                if (msg.indexOf("Event 'change' on sink") >= 0) {
                    root.refresh();
                    root.osdPending = true;
                }
            }
        }
        onExited: {
            watchProc.running = true;
        }
    }

    Process {
        id: osdProc
        stdout: StdioCollector {}
    }

    Process {
        id: sinkProc
        command: ["sh", "-c", root.wpctl + " get-volume @DEFAULT_AUDIO_SINK@ 2>/dev/null"]
        stdout: StdioCollector {
            onStreamFinished: {
                var text = this.text;
                var volMatch = text.match(/Volume:\s*([\d.]+)/);
                if (volMatch)
                    root.sinkVolume = Math.round(parseFloat(volMatch[1]) * 100);
                root.sinkMuted = text.indexOf("[MUTED]") >= 0;
                root.updateText();
                if (root.osdPending) {
                    root.osdPending = false;
                    if (!root.hasOsdBaseline || root.sinkVolume !== root.lastOsdVolume || root.sinkMuted !== root.lastOsdMuted)
                        root.showOsd();
                }
                root.lastOsdVolume = root.sinkVolume;
                root.lastOsdMuted = root.sinkMuted;
                root.hasOsdBaseline = true;
            }
        }
    }

    Process {
        id: sourceProc
        command: ["sh", "-c", root.wpctl + " get-volume @DEFAULT_AUDIO_SOURCE@ 2>/dev/null"]
        stdout: StdioCollector {
            onStreamFinished: {
                var text = this.text;
                var volMatch = text.match(/Volume:\s*([\d.]+)/);
                if (volMatch)
                    root.sourceVolume = Math.round(parseFloat(volMatch[1]) * 100);
                root.sourceMuted = text.indexOf("[MUTED]") >= 0;
                root.updateText();
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

    function scrollVolume(delta, source) {
        var device = source ? "@DEFAULT_AUDIO_SOURCE@" : "@DEFAULT_AUDIO_SINK@";
        var amount = delta > 0 ? "5%+" : "5%-";
        root.execAction(root.wpctl + " set-volume " + device + " " + amount);
    }

    implicitWidth: pulseText.implicitWidth + Base.margin * 2
    implicitHeight: Base.height + Base.padTop + Base.padBottom

    Rectangle {
        anchors.fill: parent
        anchors.topMargin: Base.padTop
        anchors.bottomMargin: Base.padBottom
        color: Base.bg
        radius: Base.radius

        Text {
            id: pulseText
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
            acceptedButtons: Qt.LeftButton | Qt.MiddleButton | Qt.RightButton
            onPressed: mouse => {
                if (mouse.button === Qt.RightButton) {
                    root.rightButtonHeld = true;
                    root.rightWheelUsed = false;
                }
            }
            onReleased: mouse => {
                if (mouse.button === Qt.RightButton)
                    root.rightButtonHeld = false;
            }
            onClicked: mouse => {
                if (mouse.button === Qt.LeftButton) {
                    if (root.clickCmd.length > 0)
                        root.execAction(root.clickCmd);
                } else if (mouse.button === Qt.MiddleButton) {
                    if (root.middleClickCmd.length > 0)
                        root.execAction(root.middleClickCmd);
                } else if (mouse.button === Qt.RightButton) {
                    if (!root.rightWheelUsed && root.rightClickCmd.length > 0)
                        root.execAction(root.rightClickCmd);
                }
            }
            onWheel: wheel => {
                wheel.accepted = true;
                var delta = wheel.angleDelta.y !== 0 ? wheel.angleDelta.y : wheel.angleDelta.x;
                if (root.rightButtonHeld) {
                    root.rightWheelUsed = true;
                    root.scrollVolume(delta, true);
                } else if (delta > 0 && root.scrollUpCmd.length > 0) {
                    root.execAction(root.scrollUpCmd);
                } else if (delta < 0 && root.scrollDownCmd.length > 0) {
                    root.execAction(root.scrollDownCmd);
                }
            }
        }
    }
}

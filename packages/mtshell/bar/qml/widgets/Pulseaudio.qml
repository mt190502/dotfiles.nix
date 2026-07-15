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

    property int sinkVolume: 0
    property bool sinkMuted: false
    property int sourceVolume: 0
    property bool sourceMuted: false

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

    Component.onCompleted: {
        root.refresh();
        watchProc.running = true;
    }

    Process {
        id: watchProc
        command: ["sh", "-c", root.pactl + " subscribe 2>/dev/null"]
        stdout: SplitParser {
            onRead: msg => {
                if (msg.indexOf("Event 'change' on sink") >= 0 || msg.indexOf("Event 'change' on source") >= 0 || msg.indexOf("Event 'change' on card") >= 0) {
                    root.refresh();
                }
            }
        }
        onExited: {
            watchProc.running = true;
        }
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
            onClicked: mouse => {
                if (mouse.button === Qt.LeftButton) {
                    if (root.clickCmd.length > 0)
                        root.execAction(root.clickCmd);
                } else if (mouse.button === Qt.MiddleButton) {
                    if (root.middleClickCmd.length > 0)
                        root.execAction(root.middleClickCmd);
                } else if (mouse.button === Qt.RightButton) {
                    if (root.rightClickCmd.length > 0)
                        root.execAction(root.rightClickCmd);
                }
            }
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

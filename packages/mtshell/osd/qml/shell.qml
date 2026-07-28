//@ pragma StateDir $BASE/mtshell/osd

import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import QtQuick

Scope {
    id: root

    property string kind: ""
    property string output: ""
    property string swaymsg: "@osd-swaymsg@"
    property int value: 0
    property string label: ""
    property bool extra: false
    property bool active: false
    property string pendingKind: ""
    property string pendingValue: ""
    property bool pendingMuted: false
    property var volumeIcons: ["@volume-icon-0@", "@volume-icon-1@", "@volume-icon-2@", "@volume-icon-3@", "@volume-icon-4@"]
    property string volumeMutedIcon: "@volume-muted-icon@"
    property var brightnessIcons: ["@brightness-icon-0@", "@brightness-icon-1@", "@brightness-icon-2@", "@brightness-icon-3@", "@brightness-icon-4@"]
    property string keyboardIcon: "@keyboard-icon@"

    readonly property string icon: {
        if (root.kind === "volume") {
            if (root.extra)
                return root.volumeMutedIcon;
            return root.levelIcon(root.volumeIcons);
        }
        if (root.kind === "brightness")
            return root.levelIcon(root.brightnessIcons);
        return root.keyboardIcon;
    }

    function levelIcon(icons) {
        if (root.value >= 80)
            return icons[4];
        if (root.value >= 60)
            return icons[3];
        if (root.value >= 40)
            return icons[2];
        if (root.value >= 20)
            return icons[1];
        return icons[0];
    }

    function show(kind, value, muted, output) {
        root.pendingKind = kind;
        root.pendingValue = value;
        root.pendingMuted = muted;
        focusProc.running = true;
    }

    function showOnFocusedOutput(text) {
        try {
            const outputs = JSON.parse(text);
            for (let i = 0; i < outputs.length; i++) {
                if (outputs[i].focused) {
                    root.kind = root.pendingKind;
                    root.label = root.pendingValue;
                    root.value = Number(root.pendingValue) || 0;
                    root.extra = root.pendingMuted;
                    root.output = outputs[i].name;
                    root.active = true;
                    hideTimer.restart();
                    return;
                }
            }
        } catch (error) {
            // Ignore resume-time Sway IPC output while outputs reconnect.
        }
    }

    IpcHandler {
        target: "osd"

        function show(kind: string, value: string, muted: bool, output: string): void {
            root.show(kind, value, muted, output);
        }
    }

    Process {
        id: focusProc
        command: [root.swaymsg, "-t", "get_outputs"]
        stdout: StdioCollector {
            onStreamFinished: root.showOnFocusedOutput(this.text)
        }
    }

    Timer {
        id: hideTimer
        interval: 1500
        onTriggered: root.active = false
    }

    Variants {
        model: Quickshell.screens

        delegate: PanelWindow {
            id: osdWindow
            required property var modelData
            screen: modelData
            visible: root.active && modelData.name === root.output
            color: "transparent"
            implicitHeight: 162
            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.exclusiveZone: 0

            anchors {
                left: true
                right: true
                bottom: true
            }

            Rectangle {
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 80
                width: 320
                height: 82
                radius: 18
                color: "@osd-bg@"
                border.color: "@osd-border@"
                border.width: 1

                Row {
                    anchors.centerIn: parent
                    width: parent.width - 36
                    spacing: 16

                    Text {
                        width: 36
                        anchors.verticalCenter: parent.verticalCenter
                        text: root.icon
                        color: "@osd-text@"
                        font.pixelSize: 30
                        font.family: "@osd-font-name@"
                        horizontalAlignment: Text.AlignHCenter
                    }

                    Column {
                        width: parent.width - 52
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 8

                        Text {
                            text: root.kind === "layout" ? root.label : root.value + "%"
                            color: "@osd-text@"
                            font.pixelSize: 16
                            font.family: "@osd-font-name@"
                        }

                        Rectangle {
                            width: parent.width
                            height: 6
                            radius: 3
                            color: "@osd-border@"
                            opacity: 0.35
                            visible: root.kind !== "layout"

                            Rectangle {
                                width: parent.width * Math.max(0, Math.min(100, root.value)) / (root.kind === "volume" ? 150 : 100)
                                height: parent.height
                                radius: parent.radius
                                color: root.kind === "volume" ? "@osd-text@" : "@osd-accent@"
                            }

                            Rectangle {
                                visible: root.kind === "volume" && root.value > 100
                                x: parent.width * 100 / 150
                                width: parent.width * Math.max(0, Math.min(150, root.value) - 100) / 150
                                height: parent.height
                                radius: parent.radius
                                color: "@osd-urgent@"
                            }
                        }
                    }
                }
            }
        }
    }
}

import Quickshell
import Quickshell.Io
import QtQuick

Item {
    id: root

    property string onClickCmd: '@keyboard-on-click@'
    property string format: '@keyboard-format@'
    property string swaymsg: "@swaymsg-bin@"
    property string osdIpc: "@osd-ipc@"
    property string screenName: ""
    property bool osdPending: false

    implicitWidth: layoutText.implicitWidth + Base.margin * 2
    implicitHeight: Base.height + Base.padTop + Base.padBottom

    Rectangle {
        anchors.fill: parent
        anchors.topMargin: Base.padTop
        anchors.bottomMargin: Base.padBottom
        color: Base.bg
        radius: Base.radius

        Text {
            id: layoutText
            anchors.fill: parent
            anchors.leftMargin: Base.margin
            anchors.rightMargin: Base.margin
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
            text: "--"
            color: Base.text
            font.pixelSize: Base.fontSize
            font.family: Base.fontName
        }

        MouseArea {
            anchors.fill: parent
            onClicked: {
                if (root.onClickCmd.length > 0) {
                    clickProc.running = true;
                }
            }
        }
    }

    Process {
        id: clickProc
        command: ["sh", "-c", root.onClickCmd]
        onRunningChanged: {
            if (!running) {
                root.refresh();
            }
        }
    }

    function formatLayout(name) {
        if (root.format !== "short") {
            return name;
        }
        const match = name.match(/\(([^)]+)\)/);
        if (match) {
            return match[1].toUpperCase();
        }
        const known = {
            "Turkish": "TR",
            "Arabic": "AR",
            "Russian": "RU",
            "German": "DE",
            "French": "FR",
            "Spanish": "ES",
            "Italian": "IT",
            "Portuguese": "PT",
            "Polish": "PL",
            "Ukrainian": "UA",
            "Greek": "GR",
            "Hebrew": "IL",
            "Japanese": "JP",
            "Korean": "KR",
            "Chinese": "CN"
        };
        if (known[name]) {
            return known[name];
        }
        return name.substring(0, 2).toUpperCase();
    }

    function parseLayout(output) {
        try {
            const inputs = JSON.parse(output);
            for (let i = 0; i < inputs.length; i++) {
                if (inputs[i].type === "keyboard" && inputs[i].xkb_active_layout_name) {
                    const layout = root.formatLayout(inputs[i].xkb_active_layout_name);
                    layoutText.text = layout;
                    if (root.osdPending && root.osdIpc.length > 0) {
                        root.osdPending = false;
                        osdProc.command = ["sh", "-c", root.osdIpc + " layout '" + layout + "' false '" + root.screenName + "'"];
                        osdProc.running = true;
                    }
                    return;
                }
            }
        } catch (e) {}
    }

    Process {
        id: layoutProc
        command: ["sh", "-c", root.swaymsg + " -t get_inputs 2>/dev/null"]
        stdout: StdioCollector {
            onStreamFinished: root.parseLayout(this.text)
        }
    }

    Process {
        id: subscribeProc
        command: ["sh", "-c", root.swaymsg + " -m -t subscribe '[\"input\"]' 2>/dev/null"]
        stdout: SplitParser {
            onRead: msg => root.refresh(true)
        }
        onExited: {
            subscribeProc.running = true;
        }
    }

    function refresh(showOsd) {
        root.osdPending = showOsd === true;
        layoutProc.running = true;
    }

    Process {
        id: osdProc
        stdout: StdioCollector {}
    }

    Component.onCompleted: {
        root.refresh();
        subscribeProc.running = true;
    }
}

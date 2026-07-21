import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: root

    property string icon: "@memory-icon@"
    property int interval: @memory-interval@
    property string onClickCmd: "@memory-on-click@"

    function parseMem(output) {
        let total = 0;
        let available = 0;
        const lines = output.split("\n");
        for (let i = 0; i < lines.length; i++) {
            if (lines[i].startsWith("MemTotal:"))
                total = parseInt(lines[i].split(/\s+/)[1]);
            else if (lines[i].startsWith("MemAvailable:"))
                available = parseInt(lines[i].split(/\s+/)[1]);
        }
        if (total === 0)
            return;

        const usedKB = total - available;
        const usedGB = usedKB / 1024 / 1024;
        const totalGB = total / 1024 / 1024;
        memText.text = root.icon + " " + usedGB.toFixed(2) + " / " + totalGB.toFixed(0) + " GB";
    }

    function refresh() {
        memProc.running = true;
    }

    implicitWidth: memText.implicitWidth + Base.margin * 2
    implicitHeight: Base.height + Base.padTop + Base.padBottom
    Component.onCompleted: root.refresh()

    Rectangle {
        anchors.fill: parent
        anchors.topMargin: Base.padTop
        anchors.bottomMargin: Base.padBottom
        color: Base.bg
        radius: Base.radius

        Text {
            id: memText
            anchors.fill: parent
            anchors.leftMargin: Base.margin
            anchors.rightMargin: Base.margin
            verticalAlignment: Text.AlignVCenter
            text: root.icon + " --"
            color: Base.text
            font.pixelSize: Base.fontSize
            font.family: Base.fontName
        }

        MouseArea {
            anchors.fill: parent
            onClicked: {
                if (root.onClickCmd.length > 0)
                    Quickshell.execDetached(["sh", "-c", root.onClickCmd]);
            }
        }
    }

    Process {
        id: memProc
        command: ["cat", "/proc/meminfo"]
        stdout: StdioCollector {
            id: memStdout
            onStreamFinished: root.parseMem(memStdout.text)
        }
    }

    Timer {
        interval: root.interval * 1000
        running: true
        repeat: true
        onTriggered: root.refresh()
    }
}

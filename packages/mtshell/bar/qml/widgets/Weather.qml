import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: root

    property string location: "@weather-location@"
    property int interval: @weather-interval@

    function refresh() {
        if (root.location.length > 0)
            weatherProc.exec(["sh", "-c", "@weather-cmd@"]);
    }

    visible: location.length > 0
    implicitWidth: visible ? weatherText.implicitWidth + Base.margin * 2 : 0
    implicitHeight: Base.height + Base.padTop + Base.padBottom
    Component.onCompleted: root.refresh()

    Rectangle {
        anchors.fill: parent
        anchors.topMargin: Base.padTop
        anchors.bottomMargin: Base.padBottom
        color: Base.bg
        radius: Base.radius

        Text {
            id: weatherText
            anchors.fill: parent
            anchors.leftMargin: Base.margin
            anchors.rightMargin: Base.margin
            verticalAlignment: Text.AlignVCenter
            text: ""
            color: Base.text
            font.pixelSize: Base.fontSize
            font.family: Base.fontName
        }

        MouseArea {
            anchors.fill: parent
            onClicked: {
                const scriptPath = "@weather-click-script@";
                if (scriptPath.length > 0)
                    Quickshell.execDetached(["sh", "-c", scriptPath]);
            }
        }
    }

    Process {
        id: weatherProc
        stdout: StdioCollector {
            id: weatherStdout
            onStreamFinished: {
                const output = weatherStdout.text.trim();
                if (output.length > 0)
                    weatherText.text = output;
            }
        }
    }

    Timer {
        interval: root.interval * 1000
        running: root.location.length > 0
        repeat: true
        onTriggered: root.refresh()
    }
}

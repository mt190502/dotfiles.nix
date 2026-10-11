import Quickshell
import Quickshell.Wayland
import QtQuick

Item {
    id: root

    property var barWindow: null
    property string iconActivated: "@idle-icon-activated@"
    property string iconDeactivated: "@idle-icon-deactivated@"

    IdleInhibitor {
        window: root.barWindow
        enabled: Base.idleInhibited
    }

    implicitWidth: inhibitText.implicitWidth + Base.margin * 2
    implicitHeight: Base.height + Base.padTop + Base.padBottom

    Rectangle {
        anchors.fill: parent
        anchors.topMargin: Base.padTop
        anchors.bottomMargin: Base.padBottom
        color: Base.bg
        radius: Base.radius

        Text {
            id: inhibitText
            anchors.fill: parent
            anchors.leftMargin: Base.margin
            anchors.rightMargin: Base.margin
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
            text: Base.idleInhibited ? root.iconActivated : root.iconDeactivated
            color: Base.text
            font.pixelSize: Base.fontSize
            font.family: Base.fontName
        }

        MouseArea {
            anchors.fill: parent
            onClicked: Base.idleInhibited = !Base.idleInhibited
        }
    }
}

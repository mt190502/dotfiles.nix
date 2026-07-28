import Quickshell
import Quickshell.Wayland
import QtQuick

PanelWindow {
    id: root

    required property var anchorItem
    property int cardWidth: 280
    property int cardHeight: 180
    default property alias contentData: card.data

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.exclusiveZone: 0
    color: "transparent"

    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }

    MouseArea {
        anchors.fill: parent
        onClicked: root.visible = false
    }

    Rectangle {
        id: card
        width: root.cardWidth
        height: root.cardHeight
        x: Math.max(8, Math.min(parent.width - width - 8, root.anchorItem.mapToItem(null, root.anchorItem.width, root.anchorItem.height).x - width))
        y: 5
        color: Base.bg
        border.color: Base.border
        border.width: 3
        radius: 0

        MouseArea {
            anchors.fill: parent
            onClicked: mouse => {}
        }
    }
}

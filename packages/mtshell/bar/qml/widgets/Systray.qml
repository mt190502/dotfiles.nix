import QtQuick
import Quickshell
import Quickshell.Services.SystemTray
import Quickshell.Widgets

Item {
    id: root

    property bool compact: @systray-compact@
    property string expandIcon: "@systray-expand-icon@"
    readonly property bool hasItems: SystemTray.items.values.length > 0
    readonly property int itemSize: Base.height
    readonly property int expandedWidth: trayRow.implicitWidth + Base.margin * 2
    readonly property int collapsedWidth: Base.fontSize + Base.margin * 2
    property bool hovered: false

    visible: hasItems
    implicitWidth: compact ? (hovered ? expandedWidth : collapsedWidth) : expandedWidth
    implicitHeight: Base.height + Base.padTop + Base.padBottom
    clip: compact

    Rectangle {
        anchors.fill: parent
        anchors.topMargin: Base.padTop
        anchors.bottomMargin: Base.padBottom
        color: Base.bg
        radius: Base.radius

        HoverHandler {
            id: hoverHandler
            onHoveredChanged: root.hovered = hovered
        }

        Row {
            id: trayRow
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.leftMargin: Base.margin
            anchors.rightMargin: Base.margin
            spacing: 0
            clip: root.compact

            Item {
                width: root.compact && root.expandIcon.length > 0 && !root.hovered ? Base.fontSize : 0
                height: root.itemSize
                visible: root.compact && root.expandIcon.length > 0

                Text {
                    anchors.centerIn: parent
                    text: root.expandIcon
                    color: Base.text
                    font.pixelSize: Base.fontSize
                    font.family: Base.fontName
                }
            }

            Repeater {
                model: SystemTray.items

                delegate: MouseArea {
                    id: trayItem
                    required property SystemTrayItem modelData

                    width: root.itemSize
                    height: root.itemSize
                    acceptedButtons: Qt.LeftButton | Qt.RightButton
                    hoverEnabled: true
                    onClicked: (mouse) => {
                        if (mouse.button === Qt.LeftButton && !modelData.onlyMenu)
                            modelData.activate();
                        else if (modelData.hasMenu)
                            trayMenu.open();
                        else if (mouse.button === Qt.RightButton)
                            modelData.secondaryActivate();
                    }

                    IconImage {
                        anchors.centerIn: parent
                        source: trayItem.modelData.icon
                        implicitSize: root.itemSize - 4
                        mipmap: false
                        backer.sourceSize.width: root.itemSize - 4
                        backer.sourceSize.height: root.itemSize - 4
                    }

                    QsMenuAnchor {
                        id: trayMenu
                        menu: trayItem.modelData.menu
                        anchor.item: trayItem
                        anchor.edges: Edges.Bottom
                        anchor.gravity: Edges.Bottom
                    }
                }
            }
        }
    }

    Behavior on implicitWidth {
        enabled: root.compact
        NumberAnimation {
            duration: 160
            easing.type: Easing.OutQuad
        }
    }
}

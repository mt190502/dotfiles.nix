import Quickshell
import QtQuick

Item {
    id: root

    property var barWindow: null
    property string icon: "@powermenu-icon@"
    property string cmdLock: "@powermenu-cmd-lock@"
    property string cmdLogout: "@powermenu-cmd-logout@"
    property string cmdSuspend: "@powermenu-cmd-suspend@"
    property string cmdHibernate: "@powermenu-cmd-hibernate@"
    property string cmdShutdown: "@powermenu-cmd-shutdown@"
    property string cmdReboot: "@powermenu-cmd-reboot@"

    property var menuItems: []
    property int selectedIndex: -1
    property string iconLock: "@powermenu-icon-lock@"
    property string iconLogout: "@powermenu-icon-logout@"
    property string iconSuspend: "@powermenu-icon-suspend@"
    property string iconHibernate: "@powermenu-icon-hibernate@"
    property string iconShutdown: "@powermenu-icon-shutdown@"
    property string iconReboot: "@powermenu-icon-reboot@"
    property string textLock: "@powermenu-text-lock@"
    property string textLogout: "@powermenu-text-logout@"
    property string textSuspend: "@powermenu-text-suspend@"
    property string textHibernate: "@powermenu-text-hibernate@"
    property string textShutdown: "@powermenu-text-shutdown@"
    property string textReboot: "@powermenu-text-reboot@"

    Component.onCompleted: {
        var items = [];
        if (root.cmdLock.length > 0)
            items.push({
                icon: root.iconLock,
                text: root.textLock,
                cmd: root.cmdLock
            });
        if (root.cmdLogout.length > 0)
            items.push({
                icon: root.iconLogout,
                text: root.textLogout,
                cmd: root.cmdLogout
            });
        if (root.cmdSuspend.length > 0)
            items.push({
                icon: root.iconSuspend,
                text: root.textSuspend,
                cmd: root.cmdSuspend
            });
        if (root.cmdHibernate.length > 0)
            items.push({
                icon: root.iconHibernate,
                text: root.textHibernate,
                cmd: root.cmdHibernate
            });
        if (root.cmdShutdown.length > 0)
            items.push({
                icon: root.iconShutdown,
                text: root.textShutdown,
                cmd: root.cmdShutdown
            });
        if (root.cmdReboot.length > 0)
            items.push({
                icon: root.iconReboot,
                text: root.textReboot,
                cmd: root.cmdReboot
            });
        root.menuItems = items;
    }

    implicitWidth: powerText.implicitWidth + Base.margin * 2
    implicitHeight: Base.height + Base.padTop + Base.padBottom

    Rectangle {
        anchors.fill: parent
        anchors.topMargin: Base.padTop
        anchors.bottomMargin: Base.padBottom
        color: Base.bg
        radius: Base.radius

        Text {
            id: powerText
            anchors.fill: parent
            anchors.leftMargin: Base.margin
            anchors.rightMargin: Base.margin
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
            text: root.icon
            color: Base.text
            font.pixelSize: Base.fontSize
            font.family: Base.fontName
        }

        MouseArea {
            anchors.fill: parent
            onClicked: powerPopup.visible = !powerPopup.visible
        }
    }

    PopupWindow {
        id: powerPopup
        anchor.item: root
        anchor.edges: Edges.Bottom
        anchor.gravity: Edges.Bottom
        implicitWidth: 180
        implicitHeight: Math.min(popupContent.implicitHeight + 16, 400)
        visible: false
        grabFocus: true
        color: Base.bg

        onVisibleChanged: {
            if (!visible)
                root.selectedIndex = -1;
        }

        Column {
            id: popupContent
            anchors.fill: parent
            anchors.margins: 8
            spacing: 4

            Repeater {
                model: root.menuItems
                delegate: Rectangle {
                    required property var modelData
                    required property int index
                    width: popupContent.width
                    height: 36
                    color: root.selectedIndex === index ? Base.urgent : mouseArea.containsMouse ? Base.active : "transparent"
                    radius: Base.radius

                    Text {
                        anchors.fill: parent
                        anchors.leftMargin: 8
                        verticalAlignment: Text.AlignVCenter
                        text: modelData.icon + "  " + modelData.text
                        color: root.selectedIndex === index || mouseArea.containsMouse ? Base.bg : Base.text
                        font.pixelSize: Base.fontSize
                        font.family: Base.fontName
                    }

                    MouseArea {
                        id: mouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: {
                            if (root.selectedIndex === index) {
                                Quickshell.execDetached(["sh", "-c", modelData.cmd]);
                                root.selectedIndex = -1;
                                powerPopup.visible = false;
                            } else {
                                root.selectedIndex = index;
                            }
                        }
                    }
                }
            }
        }
    }
}

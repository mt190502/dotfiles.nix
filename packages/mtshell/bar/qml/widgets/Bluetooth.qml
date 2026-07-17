import Quickshell
import Quickshell.Bluetooth
import QtQuick

Item {
    id: root

    property string iconConnected: "@bluetooth-icon-connected@"
    property string iconDisconnected: "@bluetooth-icon-disconnected@"
    property string onClickCmd: '@bluetooth-on-click@'

    readonly property var adapter: Bluetooth.defaultAdapter
    readonly property bool adapterEnabled: adapter ? adapter.enabled : false
    readonly property var connectedDevices: {
        if (!adapter || !adapter.devices)
            return [];
        return [...adapter.devices.values].filter(d => d.connected);
    }
    readonly property bool hasConnected: connectedDevices.length > 0
    readonly property var connectedDevice: hasConnected ? connectedDevices[0] : null
    readonly property bool hasBattery: connectedDevice ? connectedDevice.batteryAvailable : false
    readonly property int batteryPercent: hasBattery ? Math.round(connectedDevice.battery * 100) : 0

    implicitWidth: btText.implicitWidth + Base.margin * 2
    implicitHeight: Base.height + Base.padTop + Base.padBottom

    Rectangle {
        anchors.fill: parent
        anchors.topMargin: Base.padTop
        anchors.bottomMargin: Base.padBottom
        color: Base.bg
        radius: Base.radius

        Text {
            id: btText
            anchors.fill: parent
            anchors.leftMargin: Base.margin
            anchors.rightMargin: Base.margin
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
            text: root.hasConnected
                ? root.iconConnected + (root.hasBattery ? " " + root.batteryPercent + "%" : "")
                : root.iconDisconnected
            color: root.adapterEnabled ? Base.text : Base.inactive
            font.pixelSize: Base.fontSize
            font.family: Base.fontName
        }

        MouseArea {
            anchors.fill: parent
            onClicked: {
                if (root.onClickCmd.length > 0) {
                    Quickshell.execDetached(["sh", "-c", root.onClickCmd]);
                }
            }
        }
    }
}

import Quickshell
import Quickshell.Networking
import QtQuick

Item {
    id: root

    property var barWindow: null
    property string iconWifi: "@network-icon-wifi@"
    property string iconEthernet: "@network-icon-ethernet@"
    property string iconDisconnected: "@network-icon-disconnected@"
    property string textDisconnected: "@network-text-disconnected@"
    property string onClickCmd: '@network-on-click@'

    readonly property var wifiDevice: {
        for (const dev of Networking.devices.values) {
            if (dev.type === DeviceType.Wifi)
                return dev;
        }
        return null;
    }

    readonly property var wiredDevice: {
        for (const dev of Networking.devices.values) {
            if (dev.type === DeviceType.Wired)
                return dev;
        }
        return null;
    }

    readonly property bool wifiConnected: wifiDevice ? wifiDevice.connected : false
    readonly property bool wiredConnected: wiredDevice ? wiredDevice.connected : false
    readonly property int wiredSpeed: wiredDevice && wiredDevice.linkSpeed ? wiredDevice.linkSpeed : 0

    readonly property var activeNetwork: {
        if (wifiDevice && wifiDevice.networks) {
            for (const net of wifiDevice.networks.values) {
                if (net.connected)
                    return net;
            }
        }
        return null;
    }

    property var sortedNetworks: []

    function refreshNetworks() {
        if (!wifiDevice || !wifiDevice.networks) {
            root.sortedNetworks = [];
            return;
        }
        root.sortedNetworks = [...wifiDevice.networks.values].sort((a, b) => {
            if (a.connected !== b.connected)
                return b.connected - a.connected;
            return b.signalStrength - a.signalStrength;
        });
    }

    function formatSpeed(mbps) {
        if (mbps >= 1000) {
            return (mbps / 1000).toFixed(1) + " Gbps";
        }
        return mbps + " Mbps";
    }

    implicitWidth: netText.implicitWidth + Base.margin * 2
    implicitHeight: Base.height + Base.padTop + Base.padBottom

    Rectangle {
        anchors.fill: parent
        anchors.topMargin: Base.padTop
        anchors.bottomMargin: Base.padBottom
        color: Base.bg
        radius: Base.radius

        Text {
            id: netText
            anchors.fill: parent
            anchors.leftMargin: Base.margin
            anchors.rightMargin: Base.margin
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
            text: {
                if (root.wifiConnected)
                    return root.iconWifi;
                if (root.wiredConnected)
                    return root.iconEthernet;
                return root.iconDisconnected + " " + root.textDisconnected;
            }
            color: Base.text
            font.pixelSize: Base.fontSize
            font.family: Base.fontName
        }

        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.LeftButton | Qt.RightButton
            onClicked: mouse => {
                if (mouse.button === Qt.LeftButton) {
                    if (root.onClickCmd.length > 0) {
                        Quickshell.execDetached(["sh", "-c", root.onClickCmd]);
                    }
                } else if (mouse.button === Qt.RightButton) {
                    networkPopup.visible = !networkPopup.visible;
                }
            }
        }
    }

    PopupWindow {
        id: networkPopup
        anchor.item: root
        anchor.edges: Edges.Bottom
        anchor.gravity: Edges.Bottom
        implicitWidth: 250
        implicitHeight: Math.min(popupContent.implicitHeight + 16, 400)
        visible: false
        grabFocus: true
        color: Base.bg

        onVisibleChanged: {
            if (root.wifiDevice) {
                root.wifiDevice.scannerEnabled = visible;
            }
            if (visible) {
                root.refreshNetworks();
            }
        }

        Connections {
            target: root.wifiDevice
            ignoreUnknownSignals: true
            function onScannerEnabledChanged() {
                if (networkPopup.visible) {
                    root.refreshNetworks();
                }
            }
        }

        Column {
            id: popupContent
            anchors.fill: parent
            anchors.margins: 8
            spacing: 4

            Text {
                text: root.wiredConnected ? "Ethernet" : root.wifiDevice ? "WiFi Networks" : "Network"
                color: Base.text
                font.pixelSize: Base.fontSize
                font.family: Base.fontName
                font.bold: true
                bottomPadding: 4
                width: parent.width
            }

            Rectangle {
                width: parent.width
                height: 32
                visible: root.wiredConnected
                color: Base.active
                radius: Base.radius

                Text {
                    anchors.fill: parent
                    anchors.leftMargin: 8
                    verticalAlignment: Text.AlignVCenter
                    text: root.wiredDevice ? root.wiredDevice.name + "  " + root.formatSpeed(root.wiredSpeed) : "Connected"
                    color: Base.text
                    font.pixelSize: Base.fontSize
                    font.family: Base.fontName
                }
            }

            ListView {
                id: networkList
                width: parent.width
                height: contentHeight
                interactive: false
                visible: root.sortedNetworks.length > 0
                model: root.sortedNetworks
                delegate: Rectangle {
                    required property var modelData
                    width: networkList.width
                    height: 32
                    color: modelData.connected ? Base.active : "transparent"
                    radius: Base.radius

                    Text {
                        anchors.fill: parent
                        anchors.leftMargin: 8
                        verticalAlignment: Text.AlignVCenter
                        text: modelData.name
                        color: Base.text
                        font.pixelSize: Base.fontSize
                        font.family: Base.fontName
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            if (!modelData.connected) {
                                modelData.connect();
                            }
                            networkPopup.visible = false;
                        }
                    }
                }
            }

            Text {
                text: "No networks found"
                visible: root.wifiDevice && root.sortedNetworks.length === 0 && !root.wiredConnected
                color: Base.inactive
                font.pixelSize: Base.fontSize
                font.family: Base.fontName
                width: parent.width
            }

            Text {
                text: "No WiFi device"
                visible: !root.wifiDevice && !root.wiredConnected
                color: Base.inactive
                font.pixelSize: Base.fontSize
                font.family: Base.fontName
                width: parent.width
            }
        }
    }
}

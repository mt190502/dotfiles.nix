import Quickshell
import Quickshell.Networking
import Quickshell.Wayland
import QtQuick

Item {
    id: root

    property var barWindow: null
    property string iconWifi: "@network-icon-wifi@"
    property string iconEthernet: "@network-icon-ethernet@"
    property string iconDisconnected: "@network-icon-disconnected@"
    property string textDisconnected: "@network-text-disconnected@"
    property string onClickCmd: '@network-on-click@'
    property var pendingNetwork: null
    property bool passwordPromptVisible: false
    property string password: ""

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
                if (root.passwordPromptVisible) {
                    root.passwordPromptVisible = false;
                    return;
                }
                if (mouse.button === Qt.LeftButton) {
                    networkPopup.visible = !networkPopup.visible;
                } else if (mouse.button === Qt.RightButton) {
                    if (root.onClickCmd.length > 0)
                        Quickshell.execDetached(["sh", "-c", root.onClickCmd]);
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
        implicitHeight: root.passwordPromptVisible ? 140 : Math.min(popupContent.implicitHeight + 16, 400)
        visible: false
        grabFocus: true
        color: Base.bg

        onVisibleChanged: {
            if (root.wifiDevice) {
                root.wifiDevice.scannerEnabled = visible;
            }
            if (visible) {
                root.refreshNetworks();
                if (root.passwordPromptVisible)
                    passwordFocusTimer.start();
            }
        }

        Timer {
            id: passwordFocusTimer
            interval: 80
            repeat: false
            onTriggered: passwordPanelInput.forceActiveFocus()
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

        Connections {
            target: root.pendingNetwork
            ignoreUnknownSignals: true
            function onConnectionFailed(reason) {
                if (reason === ConnectionFailReason.NoSecrets) {
                    root.openPasswordPrompt(root.pendingNetwork);
                }
            }
        }

        Column {
            id: popupContent
            anchors.fill: parent
            anchors.margins: 8
            spacing: 4

            Text {
                text: root.passwordPromptVisible ? "Connect to " + (root.pendingNetwork ? root.pendingNetwork.name : "WiFi") : root.wiredConnected ? "Ethernet" : root.wifiDevice ? "WiFi Networks" : "Network"
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
                visible: root.sortedNetworks.length > 0 && !root.passwordPromptVisible
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
                        onClicked: connectNetwork()

                        function connectNetwork() {
                            root.pendingNetwork = modelData;
                            if (!modelData.connected)
                                root.openPasswordPrompt(modelData);
                        }
                    }
                }
            }

            Column {
                width: parent.width
                spacing: 4
                visible: false

                Text {
                    width: parent.width
                    text: "Password"
                    color: Base.text
                    font.pixelSize: Base.fontSize
                    font.family: Base.fontName
                }

                Rectangle {
                    width: parent.width
                    height: 32
                    color: Base.inactive
                    radius: Base.radius

                    TextInput {
                        id: passwordInput
                        anchors.fill: parent
                        anchors.leftMargin: 8
                        anchors.rightMargin: 8
                        focus: root.passwordPromptVisible
                        onActiveFocusChanged: {
                            if (root.passwordPromptVisible && !activeFocus)
                                forceActiveFocus();
                        }
                        activeFocusOnPress: true
                        verticalAlignment: TextInput.AlignVCenter
                        color: Base.text
                        font.pixelSize: Base.fontSize
                        font.family: Base.fontName
                        echoMode: TextInput.Password
                        selectByMouse: true
                        text: root.password
                        onTextChanged: root.password = text
                        onAccepted: root.submitPassword()
                    }
                }

                Rectangle {
                    width: parent.width
                    height: 32
                    color: Base.active
                    radius: Base.radius

                    Text {
                        anchors.fill: parent
                        verticalAlignment: Text.AlignVCenter
                        horizontalAlignment: Text.AlignHCenter
                        text: "Connect"
                        color: Base.text
                        font.pixelSize: Base.fontSize
                        font.family: Base.fontName
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: root.submitPassword()
                    }
                }
            }

            Text {
                text: "No networks found"
                visible: !root.passwordPromptVisible && root.wifiDevice && root.sortedNetworks.length === 0 && !root.wiredConnected
                color: Base.inactive
                font.pixelSize: Base.fontSize
                font.family: Base.fontName
                width: parent.width
            }

            Text {
                text: "No WiFi device"
                visible: !root.passwordPromptVisible && !root.wifiDevice && !root.wiredConnected
                color: Base.inactive
                font.pixelSize: Base.fontSize
                font.family: Base.fontName
                width: parent.width
            }
        }
    }

    PanelWindow {
        id: passwordPanel
        screen: root.barWindow ? root.barWindow.screen : null
        visible: root.passwordPromptVisible
        focusable: true
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand
        WlrLayershell.exclusiveZone: 0
        color: "transparent"

        anchors {
            top: true
            left: true
            right: true
            bottom: true
        }

        MouseArea {
            anchors.fill: parent
            onClicked: root.passwordPromptVisible = false
        }

        Rectangle {
            id: passwordCard
            x: root.parent ? root.parent.x + root.x + root.width - width : 0
            y: root.barWindow ? root.barWindow.height : 0
            width: 280
            height: 120
            color: Base.bg
            radius: Base.radius

            Column {
                anchors.fill: parent
                anchors.margins: 8
                spacing: 4

                Text {
                    width: parent.width
                    text: "Password for " + (root.pendingNetwork ? root.pendingNetwork.name : "WiFi")
                    color: Base.text
                    font.pixelSize: Base.fontSize
                    font.family: Base.fontName
                }

                Rectangle {
                    width: parent.width
                    height: 32
                    color: Base.inactive
                    radius: Base.radius

                    TextInput {
                        id: passwordPanelInput
                        anchors.fill: parent
                        anchors.leftMargin: 8
                        anchors.rightMargin: 8
                        focus: root.passwordPromptVisible
                        activeFocusOnPress: true
                        verticalAlignment: TextInput.AlignVCenter
                        color: Base.text
                        font.pixelSize: Base.fontSize
                        font.family: Base.fontName
                        echoMode: TextInput.Password
                        text: root.password
                        onTextChanged: root.password = text
                        onAccepted: root.submitPassword()
                    }
                }

                Rectangle {
                    width: parent.width
                    height: 32
                    color: Base.active
                    radius: Base.radius

                    Text {
                        anchors.fill: parent
                        verticalAlignment: Text.AlignVCenter
                        horizontalAlignment: Text.AlignHCenter
                        text: "Connect"
                        color: Base.text
                        font.pixelSize: Base.fontSize
                        font.family: Base.fontName
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: root.submitPassword()
                    }
                }
            }
        }
    }

    function submitPassword() {
        if (!root.pendingNetwork)
            return;
        if (root.isPasswordNetwork(root.pendingNetwork)) {
            if (root.password.length === 0)
                return;
            root.pendingNetwork.connectWithPsk(root.password);
        } else {
            root.pendingNetwork.connect();
        }
        root.password = "";
        root.passwordPromptVisible = false;
    }

    function isPasswordNetwork(network) {
        return network.security === WifiSecurityType.WpaPsk || network.security === WifiSecurityType.Wpa2Psk || network.security === WifiSecurityType.Sae;
    }

    function openPasswordPrompt(network) {
        root.pendingNetwork = network;
        root.password = "";
        root.passwordPromptVisible = true;
        networkPopup.visible = false;
        Qt.callLater(() => passwordPanelInput.forceActiveFocus());
    }
}

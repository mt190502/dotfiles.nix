import Quickshell
import Quickshell.Io
import QtQuick

Item {
    id: root

    property var iconVolume: ["@pulseaudio-icon-volume-0@", "@pulseaudio-icon-volume-1@", "@pulseaudio-icon-volume-2@"]
    property string iconMuted: "@pulseaudio-icon-muted@"
    property string iconMic: "@pulseaudio-icon-mic@"
    property string iconMicMuted: "@pulseaudio-icon-mic-muted@"
    property string middleClickCmd: '@pulseaudio-middle-click-cmd@'
    property string rightClickCmd: '@pulseaudio-right-click-cmd@'
    property string scrollUpCmd: '@pulseaudio-scroll-up-cmd@'
    property string scrollDownCmd: '@pulseaudio-scroll-down-cmd@'
    property string wpctl: "@wpctl-bin@"
    property string pactl: "@pactl-bin@"
    property var barWindow: null
    property string osdIpc: "@osd-ipc@"
    property string screenName: ""

    property int sinkVolume: 0
    property bool sinkMuted: false
    property int sourceVolume: 0
    property bool sourceMuted: false
    property bool rightButtonHeld: false
    property bool rightWheelUsed: false
    property bool osdPending: false
    property int lastOsdVolume: -1
    property bool lastOsdMuted: false
    property bool hasOsdBaseline: false

    property bool mixerPopupVisible: false
    property var mixerSinks: []
    property var mixerApps: []
    property string defaultSinkName: ""
    property var mixerSources: []
    property var mixerInputApps: []
    property string defaultSourceName: ""
    property string pendingVolumeCommand: ""
    property bool sliderDragging: false

    readonly property int volumeIconIndex: {
        if (sinkVolume >= 67)
            return 2;
        if (sinkVolume >= 34)
            return 1;
        return 0;
    }

    function volumeIconIndexFor(percent) {
        if (percent >= 67)
            return 2;
        if (percent >= 34)
            return 1;
        return 0;
    }

    function sliderPercent(x, width) {
        return Math.max(0, Math.min(150, Math.round(x / width * 150)));
    }

    function pctOfVolume(volume) {
        if (!volume)
            return 0;
        var keys = Object.keys(volume);
        for (var i = 0; i < keys.length; i++) {
            var channel = volume[keys[i]];
            if (channel && channel.value_percent)
                return parseInt(channel.value_percent) || 0;
        }
        return 0;
    }

    function updateText() {
        var s = root.sinkMuted ? root.iconMuted : (root.iconVolume[root.volumeIconIndex] + " " + root.sinkVolume + "%");
        var m = root.sourceMuted ? root.iconMicMuted : (root.iconMic + " " + root.sourceVolume + "%");
        pulseText.text = s + "  " + m;
    }

    function refresh() {
        sinkProc.running = true;
        sourceProc.running = true;
    }

    function refreshMixer() {
        defaultSinkProc.running = true;
        defaultSourceProc.running = true;
    }

    function showOsd() {
        if (root.osdIpc.length > 0) {
            osdProc.command = ["sh", "-c", root.osdIpc + " volume " + root.sinkVolume + " " + root.sinkMuted + " '" + root.screenName + "'"];
            osdProc.running = true;
        }
    }

    function parseSinks(text) {
        try {
            var data = JSON.parse(text);
            var sinks = [];
            for (var i = 0; i < data.length; i++) {
                var s = data[i];
                var pct = root.pctOfVolume(s.volume);
                sinks.push({
                    index: s.index,
                    name: s.name,
                    description: s.description || s.name,
                    volume: pct || 0,
                    muted: s.mute,
                    isDefault: s.name === root.defaultSinkName
                });
            }
            root.mixerSinks = sinks;
            root.refreshMixerApps();
        } catch (e) {}
    }

    function refreshMixerApps() {
        if (root.mixerPopupVisible)
            mixerAppsProc.running = true;
    }

    function parseApps(text) {
        try {
            var data = JSON.parse(text);
            var defaultSink = null;
            for (var i = 0; i < root.mixerSinks.length; i++) {
                if (root.mixerSinks[i].isDefault) {
                    defaultSink = root.mixerSinks[i];
                    break;
                }
            }
            if (!defaultSink) {
                root.mixerApps = [];
                return;
            }
            var apps = [];
            for (var j = 0; j < data.length; j++) {
                var a = data[j];
                if (a.sink !== defaultSink.index)
                    continue;
                var pct = root.pctOfVolume(a.volume);
                var name = "Audio";
                if (a.properties) {
                    if (a.properties["application.name"])
                        name = a.properties["application.name"];
                    else if (a.properties["media.name"])
                        name = a.properties["media.name"];
                }
                apps.push({
                    index: a.index,
                    name: name,
                    volume: pct || 0,
                    muted: a.mute
                });
            }
            root.mixerApps = apps;
        } catch (e) {}
    }

    function setSinkVolume(index, percent) {
        percent = Math.max(0, Math.min(150, percent));
        root.queueVolumeCommand(root.pactl + " set-sink-volume " + index + " " + percent + "%");
    }

    function toggleSinkMute(index) {
        actionProc.command = ["sh", "-c", root.pactl + " set-sink-mute " + index + " toggle"];
        actionProc.running = true;
    }

    function setDefaultSink(name) {
        actionProc.command = ["sh", "-c", root.pactl + " set-default-sink '" + name + "'"];
        actionProc.running = true;
    }

    function setAppVolume(index, percent) {
        percent = Math.max(0, Math.min(150, percent));
        root.queueVolumeCommand(root.pactl + " set-sink-input-volume " + index + " " + percent + "%");
    }

    function toggleAppMute(index) {
        actionProc.command = ["sh", "-c", root.pactl + " set-sink-input-mute " + index + " toggle"];
        actionProc.running = true;
    }

    function parseSources(text) {
        try {
            var data = JSON.parse(text);
            var sources = [];
            for (var i = 0; i < data.length; i++) {
                var s = data[i];
                if (s.name && s.name.indexOf(".monitor") >= 0)
                    continue;
                var pct = root.pctOfVolume(s.volume);
                sources.push({
                    index: s.index,
                    name: s.name,
                    description: s.description || s.name,
                    volume: pct,
                    muted: s.mute,
                    isDefault: s.name === root.defaultSourceName
                });
            }
            root.mixerSources = sources;
            root.refreshMixerInputApps();
        } catch (e) {}
    }

    function refreshMixerInputApps() {
        if (root.mixerPopupVisible)
            mixerInputAppsProc.running = true;
    }

    function parseInputApps(text) {
        try {
            var data = JSON.parse(text);
            var defaultSource = null;
            for (var i = 0; i < root.mixerSources.length; i++) {
                if (root.mixerSources[i].isDefault) {
                    defaultSource = root.mixerSources[i];
                    break;
                }
            }
            if (!defaultSource) {
                root.mixerInputApps = [];
                return;
            }
            var apps = [];
            for (var j = 0; j < data.length; j++) {
                var a = data[j];
                if (a.source !== defaultSource.index)
                    continue;
                var pct = root.pctOfVolume(a.volume);
                var name = "Audio";
                if (a.properties) {
                    if (a.properties["application.name"])
                        name = a.properties["application.name"];
                    else if (a.properties["media.name"])
                        name = a.properties["media.name"];
                }
                apps.push({
                    index: a.index,
                    name: name,
                    volume: pct,
                    muted: a.mute
                });
            }
            root.mixerInputApps = apps;
        } catch (e) {}
    }

    function setSourceVolume(index, percent) {
        percent = Math.max(0, Math.min(150, percent));
        root.queueVolumeCommand(root.pactl + " set-source-volume " + index + " " + percent + "%");
    }

    function toggleSourceMute(index) {
        actionProc.command = ["sh", "-c", root.pactl + " set-source-mute " + index + " toggle"];
        actionProc.running = true;
    }

    function setDefaultSource(name) {
        actionProc.command = ["sh", "-c", root.pactl + " set-default-source '" + name + "'"];
        actionProc.running = true;
    }

    function setInputAppVolume(index, percent) {
        percent = Math.max(0, Math.min(150, percent));
        root.queueVolumeCommand(root.pactl + " set-source-output-volume " + index + " " + percent + "%");
    }

    function queueVolumeCommand(command) {
        root.pendingVolumeCommand = command;
        if (volumeProc.running)
            return;
        volumeProc.command = ["sh", "-c", root.pendingVolumeCommand];
        root.pendingVolumeCommand = "";
        volumeProc.running = true;
    }

    function toggleInputAppMute(index) {
        actionProc.command = ["sh", "-c", root.pactl + " set-source-output-mute " + index + " toggle"];
        actionProc.running = true;
    }

    Component.onCompleted: {
        root.refresh();
        watchProc.running = true;
    }

    Process {
        id: watchProc
        command: ["sh", "-c", root.pactl + " subscribe 2>/dev/null"]
        stdout: SplitParser {
            onRead: msg => {
                if (msg.indexOf("Event 'change' on sink") >= 0 || msg.indexOf("Event 'change' on sink-input") >= 0 || msg.indexOf("Event 'change' on source") >= 0 || msg.indexOf("Event 'change' on source-output") >= 0 || msg.indexOf("Event 'change' on server") >= 0) {
                    root.refresh();
                    if (root.mixerPopupVisible && !root.sliderDragging)
                        root.refreshMixer();
                    root.osdPending = true;
                }
            }
        }
        onExited: {
            watchProc.running = true;
        }
    }

    Process {
        id: osdProc
        stdout: StdioCollector {}
    }

    Process {
        id: sinkProc
        command: ["sh", "-c", root.wpctl + " get-volume @DEFAULT_AUDIO_SINK@ 2>/dev/null"]
        stdout: StdioCollector {
            onStreamFinished: {
                var text = this.text;
                var volMatch = text.match(/Volume:\s*([\d.]+)/);
                if (volMatch)
                    root.sinkVolume = Math.round(parseFloat(volMatch[1]) * 100);
                root.sinkMuted = text.indexOf("[MUTED]") >= 0;
                root.updateText();
                if (root.osdPending) {
                    root.osdPending = false;
                    if (!root.hasOsdBaseline || root.sinkVolume !== root.lastOsdVolume || root.sinkMuted !== root.lastOsdMuted)
                        root.showOsd();
                }
                root.lastOsdVolume = root.sinkVolume;
                root.lastOsdMuted = root.sinkMuted;
                root.hasOsdBaseline = true;
            }
        }
    }

    Process {
        id: sourceProc
        command: ["sh", "-c", root.wpctl + " get-volume @DEFAULT_AUDIO_SOURCE@ 2>/dev/null"]
        stdout: StdioCollector {
            onStreamFinished: {
                var text = this.text;
                var volMatch = text.match(/Volume:\s*([\d.]+)/);
                if (volMatch)
                    root.sourceVolume = Math.round(parseFloat(volMatch[1]) * 100);
                root.sourceMuted = text.indexOf("[MUTED]") >= 0;
                root.updateText();
            }
        }
    }

    Process {
        id: defaultSinkProc
        command: ["sh", "-c", root.pactl + " get-default-sink 2>/dev/null"]
        stdout: StdioCollector {
            onStreamFinished: {
                root.defaultSinkName = this.text.trim();
                mixerSinksProc.running = true;
            }
        }
    }

    Process {
        id: mixerSinksProc
        command: ["sh", "-c", root.pactl + " --format=json list sinks 2>/dev/null"]
        stdout: StdioCollector {
            onStreamFinished: root.parseSinks(this.text)
        }
    }

    Process {
        id: mixerAppsProc
        command: ["sh", "-c", root.pactl + " --format=json list sink-inputs 2>/dev/null"]
        stdout: StdioCollector {
            onStreamFinished: root.parseApps(this.text)
        }
    }

    Process {
        id: defaultSourceProc
        command: ["sh", "-c", root.pactl + " get-default-source 2>/dev/null"]
        stdout: StdioCollector {
            onStreamFinished: {
                root.defaultSourceName = this.text.trim();
                mixerSourcesProc.running = true;
            }
        }
    }

    Process {
        id: mixerSourcesProc
        command: ["sh", "-c", root.pactl + " --format=json list sources 2>/dev/null"]
        stdout: StdioCollector {
            onStreamFinished: root.parseSources(this.text)
        }
    }

    Process {
        id: mixerInputAppsProc
        command: ["sh", "-c", root.pactl + " --format=json list source-outputs 2>/dev/null"]
        stdout: StdioCollector {
            onStreamFinished: root.parseInputApps(this.text)
        }
    }

    Process {
        id: actionProc
        stdout: StdioCollector {}
        onRunningChanged: {
            if (!running) {
                root.refresh();
                if (root.mixerPopupVisible)
                    root.refreshMixer();
            }
        }
    }

    Process {
        id: volumeProc
        stdout: StdioCollector {}
        onRunningChanged: {
            if (running)
                return;
            if (root.pendingVolumeCommand.length > 0) {
                volumeProc.command = ["sh", "-c", root.pendingVolumeCommand];
                root.pendingVolumeCommand = "";
                volumeProc.running = true;
                return;
            }
            root.refresh();
            if (root.mixerPopupVisible && !root.sliderDragging)
                root.refreshMixer();
        }
    }

    function execAction(cmd) {
        actionProc.command = ["sh", "-c", cmd];
        actionProc.running = true;
    }

    function scrollVolume(delta, source) {
        var device = source ? "@DEFAULT_AUDIO_SOURCE@" : "@DEFAULT_AUDIO_SINK@";
        var amount = delta > 0 ? "5%+" : "5%-";
        root.execAction(root.wpctl + " set-volume " + device + " " + amount);
    }

    implicitWidth: pulseText.implicitWidth + Base.margin * 2
    implicitHeight: Base.height + Base.padTop + Base.padBottom

    Rectangle {
        anchors.fill: parent
        anchors.topMargin: Base.padTop
        anchors.bottomMargin: Base.padBottom
        color: Base.bg
        radius: Base.radius

        Text {
            id: pulseText
            anchors.fill: parent
            anchors.leftMargin: Base.margin
            anchors.rightMargin: Base.margin
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
            text: ""
            color: Base.text
            font.pixelSize: Base.fontSize
            font.family: Base.fontName
        }

        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.LeftButton | Qt.MiddleButton | Qt.RightButton
            onPressed: mouse => {
                if (mouse.button === Qt.RightButton) {
                    root.rightButtonHeld = true;
                    root.rightWheelUsed = false;
                }
            }
            onReleased: mouse => {
                if (mouse.button === Qt.RightButton)
                    root.rightButtonHeld = false;
            }
            onClicked: mouse => {
                if (mouse.button === Qt.LeftButton) {
                    mixerPopup.visible = !mixerPopup.visible;
                } else if (mouse.button === Qt.MiddleButton) {
                    if (root.middleClickCmd.length > 0)
                        root.execAction(root.middleClickCmd);
                } else if (mouse.button === Qt.RightButton) {
                    if (!root.rightWheelUsed && root.rightClickCmd.length > 0)
                        root.execAction(root.rightClickCmd);
                }
            }
            onWheel: wheel => {
                wheel.accepted = true;
                var delta = wheel.angleDelta.y !== 0 ? wheel.angleDelta.y : wheel.angleDelta.x;
                if (root.rightButtonHeld) {
                    root.rightWheelUsed = true;
                    root.scrollVolume(delta, true);
                } else if (delta > 0 && root.scrollUpCmd.length > 0) {
                    root.execAction(root.scrollUpCmd);
                } else if (delta < 0 && root.scrollDownCmd.length > 0) {
                    root.execAction(root.scrollDownCmd);
                }
            }
        }
    }

    OverlayPopup {
        id: mixerPopup
        anchorItem: root
        visible: false
        screen: root.barWindow.screen
        cardWidth: 280
        cardHeight: Math.min(Math.max(popupContent.implicitHeight + 16, 180), 600)

        onVisibleChanged: {
            root.mixerPopupVisible = visible;
            if (visible)
                root.refreshMixer();
        }

        WheelHandler {
            target: null
            acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
            onWheel: event => {
                var delta = event.pixelDelta.y !== 0 ? event.pixelDelta.y : event.angleDelta.y / 120 * 40;
                var maxY = Math.max(0, popupScroll.contentHeight - popupScroll.height);
                popupScroll.contentY = Math.max(0, Math.min(maxY, popupScroll.contentY - delta));
                event.accepted = true;
            }
        }

        Flickable {
            id: popupScroll
            anchors.fill: parent
            anchors.margins: 8
            clip: true
            contentWidth: popupContent.width
            contentHeight: popupContent.implicitHeight
            interactive: false

            Column {
                id: popupContent
                width: popupScroll.width
                spacing: 6

                    Text {
                        text: "Audio Mixer"
                        color: Base.text
                        font.pixelSize: Base.fontSize
                        font.family: Base.fontName
                        font.bold: true
                        bottomPadding: 4
                        width: parent.width
                    }

                    Text {
                        text: "Output Devices"
                        color: Base.inactive
                        font.pixelSize: Base.fontSize - 1
                        font.family: Base.fontName
                        width: parent.width
                    }

                    Repeater {
                        model: root.mixerSinks

                        delegate: Rectangle {
                            width: parent ? parent.width : 0
                            height: 54
                            color: modelData.isDefault ? Base.inactive : "transparent"
                            border.color: modelData.isDefault ? Base.active : Base.border
                            border.width: modelData.isDefault ? 2 : 1
                            radius: 0

                            MouseArea {
                                anchors.fill: parent
                                hoverEnabled: true
                                onClicked: root.setDefaultSink(modelData.name)
                            }

                            Column {
                                anchors.fill: parent
                                anchors.margins: 4
                                spacing: 2

                                Text {
                                    text: modelData.description
                                    color: Base.text
                                    font.pixelSize: Base.fontSize
                                    font.family: Base.fontName
                                    elide: Text.ElideRight
                                    width: parent.width
                                }

                                Row {
                                    width: parent.width
                                    spacing: 4

                                    Rectangle {
                                        width: 22
                                        height: 22
                                        color: modelData.muted ? Base.urgent : (muteSinkArea.containsMouse ? Base.inactive : "transparent")
                                        border.color: Base.border
                                        border.width: 2
                                        radius: 0

                                        Text {
                                            anchors.centerIn: parent
                                            text: modelData.muted ? root.iconMuted : root.iconVolume[root.volumeIconIndexFor(modelData.volume)]
                                            color: modelData.muted ? Base.bg : Base.text
                                            font.pixelSize: Base.fontSize - 1
                                            font.family: Base.fontName
                                        }

                                        MouseArea {
                                            id: muteSinkArea
                                            anchors.fill: parent
                                            hoverEnabled: true
                                            onClicked: root.toggleSinkMute(modelData.index)
                                        }
                                    }

                                    Rectangle {
                                        width: parent.width - 26
                                        height: 22
                                        color: Base.inactive
                                        radius: 0
                                        border.color: Base.border
                                        border.width: 1

                                        Rectangle {
                                            width: Math.min(parent.width * Math.min(modelData.muted ? 0 : sinkSlider.previewVolume, 100) / 150, parent.width)
                                            height: parent.height
                                            color: modelData.isDefault ? Base.active : Base.text
                                            radius: 0
                                        }

                                        Rectangle {
                                            visible: !modelData.muted && sinkSlider.previewVolume > 100
                                            x: parent.width * 100 / 150
                                            width: Math.min(parent.width * (sinkSlider.previewVolume - 100) / 150, parent.width - parent.width * 100 / 150)
                                            height: parent.height
                                            color: Base.urgent
                                            radius: 0
                                        }

                                        Text {
                                            anchors.centerIn: parent
                                            text: sinkSlider.previewVolume + "%"
                                            color: modelData.muted || sinkSlider.previewVolume < 75 ? Base.text : Base.bg
                                            font.pixelSize: Base.fontSize - 2
                                            font.family: Base.fontName
                                            z: 1
                                        }

                                        MouseArea {
                                            id: sinkSlider
                                            anchors.fill: parent
                                            preventStealing: true
                                            hoverEnabled: true
                                            property int previewVolume: modelData.volume
                                            onPressed: mouse => {
                                                root.sliderDragging = true;
                                                var pct = root.sliderPercent(mouse.x, width);
                                                previewVolume = pct;
                                                root.setSinkVolume(modelData.index, pct);
                                            }
                                            onReleased: {
                                                root.sliderDragging = false;
                                                root.refreshMixer();
                                            }
                                            onPositionChanged: mouse => {
                                                if (pressed) {
                                                    var pct = root.sliderPercent(mouse.x, width);
                                                    previewVolume = pct;
                                                    root.setSinkVolume(modelData.index, pct);
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }

                    Text {
                        text: "Input Devices"
                        color: Base.inactive
                        font.pixelSize: Base.fontSize - 1
                        font.family: Base.fontName
                        topPadding: 4
                        width: parent.width
                        visible: root.mixerSources.length > 0
                    }

                    Repeater {
                        model: root.mixerSources

                        delegate: Rectangle {
                            width: parent ? parent.width : 0
                            height: 54
                            color: modelData.isDefault ? Base.inactive : "transparent"
                            border.color: modelData.isDefault ? Base.active : Base.border
                            border.width: modelData.isDefault ? 2 : 1
                            radius: 0

                            MouseArea {
                                anchors.fill: parent
                                hoverEnabled: true
                                onClicked: root.setDefaultSource(modelData.name)
                            }

                            Column {
                                anchors.fill: parent
                                anchors.margins: 4
                                spacing: 2

                                Text {
                                    text: modelData.description
                                    color: Base.text
                                    font.pixelSize: Base.fontSize
                                    font.family: Base.fontName
                                    elide: Text.ElideRight
                                    width: parent.width
                                }

                                Row {
                                    width: parent.width
                                    spacing: 4

                                    Rectangle {
                                        width: 22
                                        height: 22
                                        color: modelData.muted ? Base.urgent : (muteSrcArea.containsMouse ? Base.inactive : "transparent")
                                        border.color: Base.border
                                        border.width: 2
                                        radius: 0

                                        Text {
                                            anchors.centerIn: parent
                                            text: modelData.muted ? root.iconMicMuted : root.iconMic
                                            color: modelData.muted ? Base.bg : Base.text
                                            font.pixelSize: Base.fontSize - 1
                                            font.family: Base.fontName
                                        }

                                        MouseArea {
                                            id: muteSrcArea
                                            anchors.fill: parent
                                            hoverEnabled: true
                                            onClicked: root.toggleSourceMute(modelData.index)
                                        }
                                    }

                                    Rectangle {
                                        width: parent.width - 26
                                        height: 22
                                        color: Base.inactive
                                        radius: 0
                                        border.color: Base.border
                                        border.width: 1

                                        Rectangle {
                                            width: Math.min(parent.width * Math.min(modelData.muted ? 0 : sourceSlider.previewVolume, 100) / 150, parent.width)
                                            height: parent.height
                                            color: modelData.isDefault ? Base.active : Base.text
                                            radius: 0
                                        }

                                        Rectangle {
                                            visible: !modelData.muted && sourceSlider.previewVolume > 100
                                            x: parent.width * 100 / 150
                                            width: Math.min(parent.width * (sourceSlider.previewVolume - 100) / 150, parent.width - parent.width * 100 / 150)
                                            height: parent.height
                                            color: Base.urgent
                                            radius: 0
                                        }

                                        Text {
                                            anchors.centerIn: parent
                                            text: sourceSlider.previewVolume + "%"
                                            color: modelData.muted || sourceSlider.previewVolume < 75 ? Base.text : Base.bg
                                            font.pixelSize: Base.fontSize - 2
                                            font.family: Base.fontName
                                            z: 1
                                        }

                                        MouseArea {
                                            id: sourceSlider
                                            anchors.fill: parent
                                            preventStealing: true
                                            hoverEnabled: true
                                            property int previewVolume: modelData.volume
                                            onPressed: mouse => {
                                                root.sliderDragging = true;
                                                var pct = root.sliderPercent(mouse.x, width);
                                                previewVolume = pct;
                                                root.setSourceVolume(modelData.index, pct);
                                            }
                                            onReleased: {
                                                root.sliderDragging = false;
                                                root.refreshMixer();
                                            }
                                            onPositionChanged: mouse => {
                                                if (pressed) {
                                                    var pct = root.sliderPercent(mouse.x, width);
                                                    previewVolume = pct;
                                                    root.setSourceVolume(modelData.index, pct);
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }

                    Text {
                        text: "Applications"
                        color: Base.inactive
                        font.pixelSize: Base.fontSize - 1
                        font.family: Base.fontName
                        topPadding: 8
                        width: parent.width
                        visible: root.mixerApps.length > 0
                    }

                    Repeater {
                        model: root.mixerApps

                        delegate: Rectangle {
                            width: parent ? parent.width : 0
                            height: 54
                            color: "transparent"
                            border.color: Base.border
                            border.width: 1
                            radius: 0

                            Column {
                                anchors.fill: parent
                                anchors.margins: 4
                                spacing: 2

                                Text {
                                    text: modelData.name
                                    color: Base.text
                                    font.pixelSize: Base.fontSize - 1
                                    font.family: Base.fontName
                                    elide: Text.ElideRight
                                    width: parent.width
                                }

                                Row {
                                    width: parent.width
                                    spacing: 4

                                    Rectangle {
                                        width: 22
                                        height: 22
                                        color: modelData.muted ? Base.urgent : (muteAppArea.containsMouse ? Base.inactive : "transparent")
                                        border.color: Base.border
                                        border.width: 2
                                        radius: 0

                                        Text {
                                            anchors.centerIn: parent
                                            text: modelData.muted ? root.iconMuted : root.iconVolume[root.volumeIconIndexFor(modelData.volume)]
                                            color: modelData.muted ? Base.bg : Base.text
                                            font.pixelSize: Base.fontSize - 1
                                            font.family: Base.fontName
                                        }

                                        MouseArea {
                                            id: muteAppArea
                                            anchors.fill: parent
                                            hoverEnabled: true
                                            onClicked: root.toggleAppMute(modelData.index)
                                        }
                                    }

                                    Rectangle {
                                        width: parent.width - 26
                                        height: 22
                                        color: Base.inactive
                                        radius: 0
                                        border.color: Base.border
                                        border.width: 1

                                        Rectangle {
                                            width: Math.min(parent.width * Math.min(modelData.muted ? 0 : appSlider.previewVolume, 100) / 150, parent.width)
                                            height: parent.height
                                            color: Base.text
                                            radius: 0
                                        }

                                        Rectangle {
                                            visible: !modelData.muted && appSlider.previewVolume > 100
                                            x: parent.width * 100 / 150
                                            width: Math.min(parent.width * (appSlider.previewVolume - 100) / 150, parent.width - parent.width * 100 / 150)
                                            height: parent.height
                                            color: Base.urgent
                                            radius: 0
                                        }

                                        Text {
                                            anchors.centerIn: parent
                                            text: appSlider.previewVolume + "%"
                                            color: modelData.muted || appSlider.previewVolume < 75 ? Base.text : Base.bg
                                            font.pixelSize: Base.fontSize - 2
                                            font.family: Base.fontName
                                            z: 1
                                        }

                                        MouseArea {
                                            id: appSlider
                                            anchors.fill: parent
                                            preventStealing: true
                                            hoverEnabled: true
                                            property int previewVolume: modelData.volume
                                            onPressed: mouse => {
                                                root.sliderDragging = true;
                                                var pct = root.sliderPercent(mouse.x, width);
                                                previewVolume = pct;
                                                root.setAppVolume(modelData.index, pct);
                                            }
                                            onReleased: {
                                                root.sliderDragging = false;
                                                root.refreshMixer();
                                            }
                                            onPositionChanged: mouse => {
                                                if (pressed) {
                                                    var pct = root.sliderPercent(mouse.x, width);
                                                    previewVolume = pct;
                                                    root.setAppVolume(modelData.index, pct);
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }

                    Text {
                        text: "No applications"
                        color: Base.inactive
                        font.pixelSize: Base.fontSize - 1
                        font.family: Base.fontName
                        topPadding: 4
                        width: parent.width
                        visible: root.mixerApps.length === 0 && root.mixerSinks.length > 0
                    }

                    Text {
                        text: "Input Applications"
                        color: Base.inactive
                        font.pixelSize: Base.fontSize - 1
                        font.family: Base.fontName
                        topPadding: 4
                        width: parent.width
                        visible: root.mixerInputApps.length > 0
                    }

                    Repeater {
                        model: root.mixerInputApps

                        delegate: Rectangle {
                            width: parent ? parent.width : 0
                            height: 54
                            color: "transparent"
                            border.color: Base.border
                            border.width: 1
                            radius: 0

                            Column {
                                anchors.fill: parent
                                anchors.margins: 4
                                spacing: 2

                                Text {
                                    text: modelData.name
                                    color: Base.text
                                    font.pixelSize: Base.fontSize - 1
                                    font.family: Base.fontName
                                    elide: Text.ElideRight
                                    width: parent.width
                                }

                                Row {
                                    width: parent.width
                                    spacing: 4

                                    Rectangle {
                                        width: 22
                                        height: 22
                                        color: modelData.muted ? Base.urgent : (muteInAppArea.containsMouse ? Base.inactive : "transparent")
                                        border.color: Base.border
                                        border.width: 2
                                        radius: 0

                                        Text {
                                            anchors.centerIn: parent
                                            text: modelData.muted ? root.iconMicMuted : root.iconMic
                                            color: modelData.muted ? Base.bg : Base.text
                                            font.pixelSize: Base.fontSize - 1
                                            font.family: Base.fontName
                                        }

                                        MouseArea {
                                            id: muteInAppArea
                                            anchors.fill: parent
                                            hoverEnabled: true
                                            onClicked: root.toggleInputAppMute(modelData.index)
                                        }
                                    }

                                    Rectangle {
                                        width: parent.width - 26
                                        height: 22
                                        color: Base.inactive
                                        radius: 0
                                        border.color: Base.border
                                        border.width: 1

                                        Rectangle {
                                            width: Math.min(parent.width * Math.min(modelData.muted ? 0 : inputAppSlider.previewVolume, 100) / 150, parent.width)
                                            height: parent.height
                                            color: Base.text
                                            radius: 0
                                        }

                                        Rectangle {
                                            visible: !modelData.muted && inputAppSlider.previewVolume > 100
                                            x: parent.width * 100 / 150
                                            width: Math.min(parent.width * (inputAppSlider.previewVolume - 100) / 150, parent.width - parent.width * 100 / 150)
                                            height: parent.height
                                            color: Base.urgent
                                            radius: 0
                                        }

                                        Text {
                                            anchors.centerIn: parent
                                            text: inputAppSlider.previewVolume + "%"
                                            color: modelData.muted || inputAppSlider.previewVolume < 75 ? Base.text : Base.bg
                                            font.pixelSize: Base.fontSize - 2
                                            font.family: Base.fontName
                                            z: 1
                                        }

                                        MouseArea {
                                            id: inputAppSlider
                                            anchors.fill: parent
                                            preventStealing: true
                                            hoverEnabled: true
                                            property int previewVolume: modelData.volume
                                            onPressed: mouse => {
                                                root.sliderDragging = true;
                                                var pct = root.sliderPercent(mouse.x, width);
                                                previewVolume = pct;
                                                root.setInputAppVolume(modelData.index, pct);
                                            }
                                            onReleased: {
                                                root.sliderDragging = false;
                                                root.refreshMixer();
                                            }
                                            onPositionChanged: mouse => {
                                                if (pressed) {
                                                    var pct = root.sliderPercent(mouse.x, width);
                                                    previewVolume = pct;
                                                    root.setInputAppVolume(modelData.index, pct);
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
    }
}

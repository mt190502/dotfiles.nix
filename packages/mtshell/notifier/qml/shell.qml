//@ pragma UseQApplication
//@ pragma StateDir $BASE/mtshell/notifier

import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Services.Notifications
import Quickshell.Services.Mpris
import QtQml
import QtQuick

Scope {
    id: root

    property bool dnd: false
    property bool ccVisible: false
    property int selectedPlayer: 0
    property string wlCopy: "@wl-copy-bin@"

    // Incremented periodically so relative notification-age labels re-evaluate
    property int timeTick: 0

    function formatBody(notif) {
        if (notif.appName === "Music Player Daemon" || notif.appName === "mpd" || notif.desktopEntry === "mpd") {
            var stripped = (notif.body || "").replace(/<\/?b>/g, "");
            var lines = stripped.split("\n").map(s => s.trim()).filter(s => s.length > 0);
            if (lines.length >= 3)
                return "<b>" + lines[0] + " (" + lines[2] + ")</b><br>" + lines[1];
        }
        return notif.body || "";
    }

    function notificationActions(notif) {
        return (notif.actions || []).filter(action => action.identifier !== "default");
    }

    function verificationCode(notif) {
        var text = (notif.summary || "") + " " + root.formatBody(notif);
        var match = text.match(/(?:^|[^0-9])([0-9]{4,6})(?![0-9])/);
        return match ? match[1] : "";
    }

    function notificationButtons(notif) {
        var buttons = notificationActions(notif).map(action => ({
                    "action": action,
                    "code": ""
                }));
        var code = verificationCode(notif);
        if (code.length > 0)
            buttons.push({
                "action": null,
                "code": code
            });
        return buttons;
    }

    // Reading root.timeTick inside the function makes every label binding that
    // calls it depend on the tick timer, so ages refresh without imperative
    // text assignment (same stale-binding problem Clock.qml works around).
    function formatNotifTime(epochMs) {
        var tick = root.timeTick;
        if (!epochMs || epochMs <= 0)
            return "";
        var age = Date.now() - epochMs;
        if (age < 0)
            age = 0;
        if (age < 30000)
            return "Just now";
        if (age < 60000)
            return Math.floor(age / 1000) + "s ago";
        if (age < 3600000)
            return Math.floor(age / 60000) + "m ago";
        if (age < 86400000)
            return Math.floor(age / 3600000) + "h ago";
        return Math.floor(age / 86400000) + "d ago";
    }

    function copyVerificationCode(code) {
        copyProc.command = ["sh", "-c", "printf '%s' \"$1\" | " + root.wlCopy, "copy-code", code];
        copyProc.running = true;
    }

    Process {
        id: copyProc
        stdout: StdioCollector {}
    }

    // Persisted notification arrival times, keyed by "<id>|<appName>"
    // (notification ids are client-local and collide across apps).
    FileView {
        id: receiptStore
        path: Quickshell.statePath("notification-times.json")
        blockLoading: true
        watchChanges: true
        printErrors: false
        onFileChanged: reload()
        onAdapterUpdated: saveTimer.restart()

        JsonAdapter {
            id: timesAdapter
            property var times: ({})
        }
    }

    Timer {
        id: saveTimer
        interval: 250
        onTriggered: receiptStore.writeAdapter()
    }

    // Adaptive tick: one-shot, re-armed to fire exactly when the closest age
    // boundary across all tracked notifications is crossed. Intervals grow
    // with age: 1s in the seconds bucket, then per minute, per hour, per day.
    // updateTickTimer() keeps it alive only while age labels are on screen.
    Timer {
        id: timeTickTimer
        interval: 1000
        repeat: false
        onTriggered: {
            root.timeTick++;
            root.scheduleNextTick();
        }
    }

    readonly property int notifCount: server.trackedNotifications.values.length
    readonly property var notifications: {
        var arr = server.trackedNotifications.values.slice();
        arr.reverse();
        return arr;
    }

    function dismissNotif(id) {
        var notifs = server.trackedNotifications.values;
        for (var i = 0; i < notifs.length; i++) {
            if (notifs[i].id === id) {
                notifs[i].dismiss();
                break;
            }
        }
    }

    // Drop stored arrival times for dismissed notifications and entries older
    // than a week; gated on the store being loaded so an async startup load
    // cannot be overwritten with an empty map.
    function pruneTimes() {
        if (!receiptStore.loaded)
            return;
        var keep = {};
        var now = Date.now();
        var tracked = server.trackedNotifications.values;
        for (var i = 0; i < tracked.length; i++) {
            var key = tracked[i].id + "|" + tracked[i].appName;
            var t = timesAdapter.times[key];
            if (t !== undefined && now - t < 604800000)
                keep[key] = t;
        }
        timesAdapter.times = keep;
    }

    // Arm the tick timer exactly at the next label boundary across all
    // tracked notifications; with nothing to update, leave it stopped.
    function scheduleNextTick() {
        var now = Date.now();
        var next = Infinity;
        var tracked = server.trackedNotifications.values;
        for (var i = 0; i < tracked.length; i++) {
            var e = timesAdapter.times[tracked[i].id + "|" + tracked[i].appName];
            if (e === undefined)
                e = now;
            var age = now - e;
            var boundary;
            if (age < 30000)
                boundary = e + 30000;
            else if (age < 60000)
                boundary = e + (Math.floor(age / 1000) + 1) * 1000;
            else if (age < 3600000)
                boundary = e + (Math.floor(age / 60000) + 1) * 60000;
            else if (age < 86400000)
                boundary = e + (Math.floor(age / 3600000) + 1) * 3600000;
            else
                boundary = e + (Math.floor(age / 86400000) + 1) * 86400000;
            if (boundary < next)
                next = boundary;
        }
        if (!isFinite(next)) {
            timeTickTimer.stop();
            return;
        }
        timeTickTimer.interval = Math.max(50, next - now + 50);
        timeTickTimer.restart();
    }

    // Start the adaptive tick only when age labels are visible (CC or popups).
    function updateTickTimer() {
        if (root.ccVisible || activePopups.count > 0)
            root.scheduleNextTick();
        else
            timeTickTimer.stop();
    }

    onNotifCountChanged: {
        ipc.statusChanged(root.notifCount + "|" + (root.dnd ? "1" : "0"));
        root.pruneTimes();
        root.updateTickTimer();
    }
    onDndChanged: ipc.statusChanged(root.notifCount + "|" + (root.dnd ? "1" : "0"))

    IpcHandler {
        id: ipc
        target: "notifier"

        function toggle(): void {
            root.ccVisible = !root.ccVisible;
        }
        function toggleDnd(): void {
            root.dnd = !root.dnd;
            if (root.dnd) {
                activePopups.clear();
                popupQueue = [];
            }
            root.updateTickTimer();
        }
        function clearAll(): void {
            var notifs = server.trackedNotifications.values.slice();
            for (var i = 0; i < notifs.length; i++)
                notifs[i].dismiss();
        }
        function dismiss(id: int): void {
            root.dismissNotif(id);
        }
        function getStatus(): string {
            return root.notifCount + "|" + (root.dnd ? "1" : "0");
        }

        signal statusChanged(status: string)
    }

    NotificationServer {
        id: server
        keepOnReload: true
        actionsSupported: true
        bodySupported: true
        imageSupported: true
        bodyMarkupSupported: true

        onNotification: notif => {
            notif.tracked = true;

            var arrivalKey = notif.id + "|" + notif.appName;
            if (!(notif.lastGeneration && timesAdapter.times[arrivalKey] !== undefined)) {
                var stamped = Object.assign({}, timesAdapter.times);
                stamped[arrivalKey] = Date.now();
                timesAdapter.times = stamped;
            }

            if (!root.dnd) {
                var replaced = false;
                for (var i = 0; i < activePopups.count; i++) {
                    var existing = activePopups.get(i);
                    var sameKey = existing.notif.appName === notif.appName && existing.notif.summary === notif.summary;
                    var sameId = existing.notif.id === notif.id;
                    if (sameId || sameKey) {
                        activePopups.remove(i);
                        popupQueue.unshift(notif);
                        popupQueue = popupQueue;
                        showNextPopup();
                        replaced = true;
                        break;
                    }
                }
                if (!replaced) {
                    popupQueue.push(notif);
                    popupQueue = popupQueue;
                    showNextPopup();
                }
            }
        }
    }

    property var popupQueue: []
    ListModel {
        id: activePopups
    }

    Repeater {
        model: server.trackedNotifications

        delegate: Item {
            required property var modelData
            Connections {
                target: modelData
                function onBodyChanged() {
                    if (root.dnd || root.ccVisible)
                        return;
                    var inPopup = false;
                    for (var i = 0; i < activePopups.count; i++) {
                        if (activePopups.get(i).notif.id === modelData.id) {
                            inPopup = true;
                            break;
                        }
                    }
                    if (!inPopup) {
                        popupQueue.push(modelData);
                        popupQueue = popupQueue;
                        showNextPopup();
                    }
                }
            }
        }
    }

    function showNextPopup() {
        if (popupQueue.length > 0 && activePopups.count < @popup-max@) {
            var n = popupQueue.shift();
            popupQueue = popupQueue;
            activePopups.insert(0, {
                notif: n
            });
        }
        root.updateTickTimer();
    }

    function dismissPopup(idx) {
        activePopups.remove(idx);
        showNextPopup();
    }

    onCcVisibleChanged: {
        if (ccVisible) {
            activePopups.clear();
            popupQueue = [];
        }
        root.updateTickTimer();
    }

    function popupIconSource(data) {
        var ai = data.appIcon || "";
        var di = data.desktopEntry || "";
        var img = data.image || "";
        var fallback = "applications-system";
        if (img.length > 0)
            return img;
        if (ai.length > 0) {
            if (ai.startsWith("/"))
                return ai;
            return Quickshell.iconPath(ai, fallback);
        }
        if (di.length > 0)
            return Quickshell.iconPath(di, fallback);
        return Quickshell.iconPath(fallback);
    }

    PanelWindow {
        id: popupWindow
        visible: activePopups.count > 0 && !root.ccVisible
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.exclusiveZone: 0
        color: "transparent"

        anchors {
            top: true
            right: true
        }

        implicitWidth: @popup-width@
        implicitHeight: popupColumn.implicitHeight + @popup-margin@

        Column {
            id: popupColumn
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.topMargin: @popup-margin@
            spacing: @popup-margin@

            Repeater {
                model: activePopups

                delegate: Rectangle {
                    id: popupRoot
                    required property var notif
                    required property int index
                    property bool hovered: false
                    // real (64-bit) on purpose: Date.now() overflows a 32-bit int
                    property real createdMs: Date.now()
                    readonly property real notifEpoch: notif ? (timesAdapter.times[notif.id + "|" + notif.appName] || createdMs) : 0
                    readonly property var actions: notif ? root.notificationActions(notif) : []
                    readonly property string code: notif ? root.verificationCode(notif) : ""
                    readonly property var buttons: notif ? root.notificationButtons(notif) : []

                    onNotifChanged: {
                        popupTimer.restart();
                        progressAnim.stop();
                        progressBar.width = @popup-width@ - @popup-margin@ * 2 - 6;
                        progressAnim.start();
                    }

                    Connections {
                        target: notif
                        function onBodyChanged() {
                            popupTimer.restart();
                            progressAnim.stop();
                            progressBar.width = @popup-width@ - @popup-margin@ * 2 - 6;
                            progressAnim.start();
                        }
                    }

                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.leftMargin: @popup-margin@
                    anchors.rightMargin: @popup-margin@
                    color: "@cc-bg@"
                    border.color: "@cc-border@"
                    border.width: 3
                    radius: 0
                    implicitHeight: Math.max(popupTextCol.implicitHeight + 4, popupIcon.height + 4) + (popupActions.visible ? popupActions.implicitHeight + 6 : 0) + 8 + 6

                    MouseArea {
                        anchors.fill: parent
                        acceptedButtons: Qt.LeftButton | Qt.RightButton
                        hoverEnabled: true
                        onEntered: {
                            popupRoot.hovered = true;
                            popupTimer.stop();
                            progressAnim.stop();
                            progressBar.width = @popup-width@ - @popup-margin@ * 2 - 6;
                        }
                        onExited: {
                            popupRoot.hovered = false;
                            progressBar.width = @popup-width@ - @popup-margin@ * 2 - 6;
                            popupTimer.start();
                            progressAnim.start();
                        }
                        onClicked: mouse => {
                            if (mouse.button === Qt.RightButton) {
                                root.dismissPopup(index);
                                return;
                            }
                            if (notif) {
                                var acts = notif.actions || [];
                                var invoked = false;
                                for (var i = 0; i < acts.length; i++) {
                                    if (acts[i].identifier === "default") {
                                        acts[i].invoke();
                                        invoked = true;
                                        break;
                                    }
                                }
                                if (!invoked && acts.length > 0) {
                                    acts[0].invoke();
                                }
                            }
                            root.dismissPopup(index);
                        }
                    }

                    Image {
                        id: popupIcon
                        source: notif ? root.popupIconSource(notif) : ""
                        width: @popup-icon-size@
                        height: @popup-icon-size@
                        fillMode: Image.PreserveAspectCrop
                        sourceSize.width: @popup-icon-size@
                        sourceSize.height: @popup-icon-size@
                        anchors.left: parent.left
                        anchors.leftMargin: 8
                        anchors.top: parent.top
                        anchors.topMargin: 8
                    }

                    Column {
                        id: popupTextCol
                        anchors.left: popupIcon.right
                        anchors.leftMargin: 8
                        anchors.top: parent.top
                        anchors.topMargin: 8
                        spacing: 2
                        width: @popup-width@ - @popup-margin@ * 2 - 6 - 8 - @popup-icon-size@ - 16

                        Text {
                            width: popupTextCol.width - 48
                            text: notif ? (notif.appName + " - " + notif.summary) : ""
                            color: "@cc-text@"
                            font.pixelSize: @cc-font-size@
                            font.family: "@cc-font-name@"
                            font.bold: true
                            elide: Text.ElideRight
                        }

                        Text {
                            width: popupTextCol.width
                            text: notif ? root.formatBody(notif).substring(0, 1500) + (root.formatBody(notif).length > 1500 ? "..." : "") : ""
                            color: "@cc-subtext@"
                            font.pixelSize: @cc-font-size@ - 1
                            font.family: "@cc-font-name@"
                            wrapMode: Text.Wrap
                            textFormat: Text.RichText
                            visible: notif ? (root.formatBody(notif).length > 0) : false
                        }
                    }

                    Column {
                        id: popupActions
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.top: parent.top
                        anchors.leftMargin: 8
                        anchors.rightMargin: 8
                        anchors.topMargin: Math.max(popupTextCol.y + popupTextCol.height, popupIcon.y + popupIcon.height) + 6
                        spacing: 4
                        visible: popupRoot.buttons.length > 0

                        Repeater {
                            model: Math.ceil(popupRoot.buttons.length / 5)

                            delegate: Row {
                                required property int index
                                property var rowButtons: popupRoot.buttons.slice(index * 5, index * 5 + 5)
                                width: popupActions.width
                                spacing: 4

                                Repeater {
                                    model: rowButtons

                                    delegate: Rectangle {
                                        required property var modelData
                                        width: (parent.width - parent.spacing * (parent.rowButtons.length - 1)) / parent.rowButtons.length
                                        height: 24
                                        color: "@cc-bg@"
                                        border.color: "@cc-active@"
                                        border.width: 2
                                        radius: 0

                                        Text {
                                            anchors.fill: parent
                                            anchors.leftMargin: 5
                                            anchors.rightMargin: 5
                                            text: modelData.action ? (modelData.action.text || modelData.action.label || modelData.action.identifier) : "Copy \"" + modelData.code + "\""
                                            color: buttonArea.containsMouse ? "@cc-active@" : "@cc-text@"
                                            font.pixelSize: @cc-font-size@ - 2
                                            font.family: "@cc-font-name@"
                                            elide: Text.ElideRight
                                            verticalAlignment: Text.AlignVCenter
                                            horizontalAlignment: Text.AlignHCenter
                                        }

                                        MouseArea {
                                            id: buttonArea
                                            anchors.fill: parent
                                            hoverEnabled: true
                                            onClicked: {
                                                if (modelData.action) {
                                                    modelData.action.invoke();
                                                    root.dismissPopup(popupRoot.index);
                                                } else {
                                                    root.copyVerificationCode(modelData.code);
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }

                    Text {
                        anchors.top: parent.top
                        anchors.right: parent.right
                        anchors.topMargin: 8
                        anchors.rightMargin: 11
                        text: notif ? root.formatNotifTime(popupRoot.notifEpoch) : ""
                        color: "@cc-subtext@"
                        font.pixelSize: @cc-font-size@ - 2
                        font.family: "@cc-font-name@"
                    }

                    Rectangle {
                        id: progressBar
                        anchors.left: parent.left
                        anchors.bottom: parent.bottom
                        anchors.leftMargin: 3
                        anchors.bottomMargin: 3
                        height: 3
                        width: @popup-width@ - @popup-margin@ * 2 - 6
                        color: "@cc-active@"
                        radius: 1

                        NumberAnimation {
                            id: progressAnim
                            target: progressBar
                            property: "width"
                            from: @popup-width@ - @popup-margin@ * 2 - 6
                            to: 0
                            duration: @popup-duration@ * 1000
                            loops: 1
                        }

                        Component.onCompleted: progressAnim.start()
                    }

                    Timer {
                        id: popupTimer
                        interval: @popup-duration@ * 1000
                        repeat: false
                        onTriggered: root.dismissPopup(index)
                        Component.onCompleted: popupTimer.start()
                    }
                }
            }
        }
    }

    PanelWindow {
        id: controlCenter
        visible: root.ccVisible

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
            onClicked: mouse => root.ccVisible = false
        }

        Rectangle {
            id: ccRoot

            MouseArea {
                anchors.fill: parent
                onClicked: mouse => {}
            }
            width: @cc-width@
            height: @cc-height@
            anchors.right: parent.right
            anchors.rightMargin: @cc-margin-right@
            anchors.top: parent.top
            anchors.topMargin: @cc-margin-top@
            color: "@cc-bg@"
            border.color: "@cc-border@"
            border.width: 5
            radius: 0

            Column {
                id: ccContent
                anchors.fill: parent
                anchors.margins: 10
                spacing: 8

                Row {
                    id: titleRow
                    width: parent.width
                    height: 36
                    spacing: 0

                    Text {
                        id: titleText
                        text: "Notifications"
                        color: "@cc-text@"
                        font.pixelSize: @cc-font-size@
                        font.family: "@cc-font-name@"
                        font.bold: true
                        verticalAlignment: Text.AlignVCenter
                        topPadding: 10
                    }

                    Item {
                        width: parent.width - titleText.width - 80 - 4 - 32 - 4
                        height: 1
                    }

                    Rectangle {
                        width: 32
                        height: 32
                        color: dndBtnArea.containsMouse ? "@cc-active@" : (root.dnd ? "@cc-border@" : "@cc-bg@")
                        border.color: "@cc-border@"
                        border.width: 3
                        radius: 0

                        Text {
                            anchors.centerIn: parent
                            text: root.dnd ? "@cc-icon-dnd-active@" : "@cc-icon-dnd@"
                            color: dndBtnArea.containsMouse ? "@cc-bg@" : "@cc-text@"
                            font.pixelSize: @cc-font-size@
                            font.family: "@cc-font-name@"
                        }

                        MouseArea {
                            id: dndBtnArea
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: ipc.toggleDnd()
                        }
                    }

                    Item {
                        width: 4
                        height: 1
                    }

                    Rectangle {
                        width: 80
                        height: 32
                        color: clearBtnArea.containsMouse ? "@cc-active@" : "@cc-bg@"
                        border.color: "@cc-border@"
                        border.width: 3
                        radius: 0

                        Text {
                            anchors.centerIn: parent
                            text: "Clear"
                            color: clearBtnArea.containsMouse ? "@cc-bg@" : "@cc-text@"
                            font.pixelSize: @cc-font-size@
                            font.family: "@cc-font-name@"
                        }

                        MouseArea {
                            id: clearBtnArea
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: ipc.clearAll()
                        }
                    }
                }

                Column {
                    id: mprisSection
                    width: parent.width
                    spacing: 8

                    Flickable {
                        width: parent.width
                        height: 24
                        clip: true
                        contentWidth: mprisTabs.implicitWidth
                        contentHeight: mprisTabs.height
                        boundsBehavior: Flickable.StopAtBounds
                        visible: Mpris.players.values.length > 1

                        Row {
                            id: mprisTabs
                            spacing: 4

                            Repeater {
                                model: Mpris.players

                                delegate: Rectangle {
                                    required property var modelData
                                    required property int index
                                    width: tabText.implicitWidth + 12
                                    height: 24
                                    color: index === root.selectedPlayer ? "@cc-active@" : "@cc-bg@"
                                    border.color: "@cc-border@"
                                    border.width: 2
                                    radius: 0

                                    Text {
                                        id: tabText
                                        anchors.centerIn: parent
                                        text: modelData.identity || "?"
                                        color: index === root.selectedPlayer ? "@cc-bg@" : "@cc-text@"
                                        font.pixelSize: @cc-font-size@ - 2
                                        font.family: "@cc-font-name@"
                                        elide: Text.ElideRight
                                    }

                                    MouseArea {
                                        anchors.fill: parent
                                        onClicked: root.selectedPlayer = index
                                    }
                                }
                            }
                        }
                    }

                    Rectangle {
                        id: mprisCard
                        width: parent.width
                        height: Mpris.players.values.length > 0 ? (@mpris-image-size@ + 16) : 0
                        color: "@cc-bg@"
                        border.color: "@cc-border@"
                        border.width: 3
                        radius: 0
                        visible: Mpris.players.values.length > 0

                        property var player: Mpris.players.values.length > 0 ? Mpris.players.values[Math.min(root.selectedPlayer, Mpris.players.values.length - 1)] : null

                        Row {
                            anchors.fill: parent
                            anchors.margins: 8
                            spacing: 8

                            Image {
                                id: albumArt
                                source: mprisCard.player ? mprisCard.player.trackArtUrl : ""
                                width: @mpris-image-size@
                                height: @mpris-image-size@
                                fillMode: Image.PreserveAspectCrop
                                sourceSize.width: @mpris-image-size@
                                sourceSize.height: @mpris-image-size@

                                Rectangle {
                                    anchors.fill: parent
                                    color: "@cc-border@"
                                    border.color: "@cc-border@"
                                    border.width: 3
                                    radius: 0
                                    visible: albumArt.status !== Image.Ready

                                    Text {
                                        anchors.centerIn: parent
                                        text: mprisCard.player ? mprisCard.player.identity : ""
                                        color: "@cc-text@"
                                        font.pixelSize: @cc-font-size@
                                        font.family: "@cc-font-name@"
                                        horizontalAlignment: Text.AlignHCenter
                                        verticalAlignment: Text.AlignVCenter
                                        width: parent.width - 8
                                        wrapMode: Text.Wrap
                                    }
                                }
                            }

                            Column {
                                width: parent.width - @mpris-image-size@ - 8
                                anchors.verticalCenter: parent.verticalCenter
                                spacing: 4

                                Text {
                                    width: parent.width
                                    text: mprisCard.player ? (mprisCard.player.trackTitle || "Unknown Title") : ""
                                    color: "@cc-text@"
                                    font.pixelSize: @cc-font-size@
                                    font.family: "@cc-font-name@"
                                    font.bold: true
                                    elide: Text.ElideRight
                                }

                                Text {
                                    width: parent.width
                                    text: mprisCard.player ? (mprisCard.player.trackArtist || "Unknown Artist") : ""
                                    color: "@cc-subtext@"
                                    font.pixelSize: @cc-font-size@ - 1
                                    font.family: "@cc-font-name@"
                                    elide: Text.ElideRight
                                }

                                Row {
                                    spacing: 6
                                    topPadding: 4

                                    Rectangle {
                                        width: 28
                                        height: 28
                                        color: shuffleBtnArea.containsMouse ? "@cc-active@" : (mprisCard.player && mprisCard.player.shuffle ? "@cc-border@" : "@cc-bg@")
                                        border.color: "@cc-border@"
                                        border.width: 3
                                        radius: 0

                                        Text {
                                            anchors.centerIn: parent
                                            text: mprisCard.player ? (mprisCard.player.shuffle ? "@mpris-icon-shuffle-active@" : "@mpris-icon-shuffle@") : ""
                                            color: shuffleBtnArea.containsMouse ? "@cc-bg@" : "@cc-text@"
                                            font.pixelSize: @cc-font-size@
                                            font.family: "@cc-font-name@"
                                        }

                                        MouseArea {
                                            id: shuffleBtnArea
                                            anchors.fill: parent
                                            hoverEnabled: true
                                            onClicked: if (mprisCard.player)
                                                mprisCard.player.shuffle = !mprisCard.player.shuffle
                                        }
                                    }

                                    Rectangle {
                                        width: 28
                                        height: 28
                                        color: prevBtnArea.containsMouse ? "@cc-active@" : "@cc-bg@"
                                        border.color: "@cc-border@"
                                        border.width: 3
                                        radius: 0

                                        Text {
                                            anchors.centerIn: parent
                                            text: "@mpris-icon-previous@"
                                            color: prevBtnArea.containsMouse ? "@cc-bg@" : "@cc-text@"
                                            font.pixelSize: @cc-font-size@
                                            font.family: "@cc-font-name@"
                                        }

                                        MouseArea {
                                            id: prevBtnArea
                                            anchors.fill: parent
                                            hoverEnabled: true
                                            onClicked: if (mprisCard.player)
                                                mprisCard.player.previous()
                                        }
                                    }

                                    Rectangle {
                                        width: 28
                                        height: 28
                                        color: playBtnArea.containsMouse ? "@cc-active@" : "@cc-bg@"
                                        border.color: "@cc-border@"
                                        border.width: 3
                                        radius: 0

                                        Text {
                                            anchors.centerIn: parent
                                            text: mprisCard.player ? (mprisCard.player.isPlaying ? "@mpris-icon-pause@" : "@mpris-icon-play@") : ""
                                            color: playBtnArea.containsMouse ? "@cc-bg@" : "@cc-text@"
                                            font.pixelSize: @cc-font-size@
                                            font.family: "@cc-font-name@"
                                        }

                                        MouseArea {
                                            id: playBtnArea
                                            anchors.fill: parent
                                            hoverEnabled: true
                                            onClicked: if (mprisCard.player)
                                                mprisCard.player.togglePlaying()
                                        }
                                    }

                                    Rectangle {
                                        width: 28
                                        height: 28
                                        color: nextBtnArea.containsMouse ? "@cc-active@" : "@cc-bg@"
                                        border.color: "@cc-border@"
                                        border.width: 3
                                        radius: 0

                                        Text {
                                            anchors.centerIn: parent
                                            text: "@mpris-icon-next@"
                                            color: nextBtnArea.containsMouse ? "@cc-bg@" : "@cc-text@"
                                            font.pixelSize: @cc-font-size@
                                            font.family: "@cc-font-name@"
                                        }

                                        MouseArea {
                                            id: nextBtnArea
                                            anchors.fill: parent
                                            hoverEnabled: true
                                            onClicked: if (mprisCard.player)
                                                mprisCard.player.next()
                                        }
                                    }

                                    Rectangle {
                                        width: 28
                                        height: 28
                                        color: repeatBtnArea.containsMouse ? "@cc-active@" : (mprisCard.player && mprisCard.player.loopState === MprisLoopState.None ? "@cc-bg@" : "@cc-border@")
                                        border.color: "@cc-border@"
                                        border.width: 3
                                        radius: 0

                                        Text {
                                            anchors.centerIn: parent
                                            text: mprisCard.player ? (mprisCard.player.loopState === MprisLoopState.Track ? "@mpris-icon-repeat-one@" : (mprisCard.player.loopState === MprisLoopState.Playlist ? "@mpris-icon-repeat-active@" : "@mpris-icon-repeat@")) : ""
                                            color: repeatBtnArea.containsMouse ? "@cc-bg@" : "@cc-text@"
                                            font.pixelSize: @cc-font-size@
                                            font.family: "@cc-font-name@"
                                        }

                                        MouseArea {
                                            id: repeatBtnArea
                                            anchors.fill: parent
                                            hoverEnabled: true
                                            onClicked: {
                                                if (!mprisCard.player)
                                                    return;
                                                if (mprisCard.player.loopState === MprisLoopState.None)
                                                    mprisCard.player.loopState = MprisLoopState.Playlist;
                                                else if (mprisCard.player.loopState === MprisLoopState.Playlist)
                                                    mprisCard.player.loopState = MprisLoopState.Track;
                                                else
                                                    mprisCard.player.loopState = MprisLoopState.None;
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }

                Item {
                    width: parent.width
                    height: 5
                }

                ListView {
                    id: notifList
                    width: parent.width
                    height: Math.max(0, ccContent.height - titleRow.height - mprisSection.height - ccContent.spacing * 3 - 5)
                    clip: true
                    model: root.notifications
                    spacing: 5
                    boundsBehavior: Flickable.StopAtBounds

                    delegate: Rectangle {
                        id: notifRoot
                        required property var modelData
                        readonly property var notification: modelData
                        // real (64-bit) on purpose: Date.now() overflows a 32-bit int
                        property real createdMs: Date.now()
                        readonly property real notifEpoch: modelData ? (timesAdapter.times[modelData.id + "|" + modelData.appName] || createdMs) : 0
                        readonly property var actions: root.notificationActions(notification)
                        readonly property string code: root.verificationCode(notification)
                        readonly property var buttons: root.notificationButtons(notification)
                        width: notifList.width
                        implicitHeight: notifInner.implicitHeight + (notifActions.visible ? notifActions.implicitHeight + 6 : 0) + 16
                        color: "@cc-border@"
                        border.color: "@cc-border@"
                        border.width: 3
                        radius: 0

                        Rectangle {
                            id: notifCard
                            z: 1
                            anchors.fill: parent
                            anchors.margins: 3
                            color: "@cc-bg@"
                            border.color: "@cc-bg@"
                            border.width: 3
                            radius: 0

                            Row {
                                id: notifInner
                                anchors.left: parent.left
                                anchors.right: parent.right
                                anchors.top: parent.top
                                anchors.margins: 6
                                spacing: 8

                                Image {
                                    id: notifIcon
                                    source: {
                                        var ai = modelData.appIcon || "";
                                        var di = modelData.desktopEntry || "";
                                        var img = modelData.image || "";
                                        var fallback = "applications-system";
                                        if (img.length > 0)
                                            return img;
                                        if (ai.length > 0) {
                                            if (ai.startsWith("/"))
                                                return ai;
                                            return Quickshell.iconPath(ai, fallback);
                                        }
                                        if (di.length > 0)
                                            return Quickshell.iconPath(di, fallback);
                                        return Quickshell.iconPath(fallback);
                                    }
                                    width: @notif-icon-size@
                                    height: @notif-icon-size@
                                    fillMode: Image.PreserveAspectCrop
                                    sourceSize.width: @notif-icon-size@
                                    sourceSize.height: @notif-icon-size@
                                    anchors.verticalCenter: parent.verticalCenter
                                }

                                Column {
                                    width: parent.width - notifIcon.width - 8
                                    anchors.verticalCenter: parent.verticalCenter
                                    spacing: 2

                                    Text {
                                        width: parent.width - 56
                                        text: modelData.appName + " - " + modelData.summary
                                        color: "@cc-text@"
                                        font.pixelSize: @cc-font-size@
                                        font.family: "@cc-font-name@"
                                        font.bold: true
                                        elide: Text.ElideRight
                                    }

                                    Text {
                                        width: parent.width
                                        text: root.formatBody(modelData).substring(0, 1500) + (root.formatBody(modelData).length > 1500 ? "..." : "")
                                        color: "@cc-subtext@"
                                        font.pixelSize: @cc-font-size@ - 1
                                        font.family: "@cc-font-name@"
                                        wrapMode: Text.Wrap
                                        textFormat: Text.RichText
                                        visible: root.formatBody(modelData).length > 0
                                    }
                                }
                            }

                            Text {
                                anchors.top: parent.top
                                anchors.right: parent.right
                                anchors.topMargin: 6
                                anchors.rightMargin: 6
                                text: root.formatNotifTime(notifRoot.notifEpoch)
                                color: "@cc-subtext@"
                                font.pixelSize: @cc-font-size@ - 2
                                font.family: "@cc-font-name@"
                            }

                            Column {
                                id: notifActions
                                anchors.left: parent.left
                                anchors.right: parent.right
                                anchors.top: notifInner.bottom
                                anchors.leftMargin: 6
                                anchors.rightMargin: 6
                                anchors.topMargin: 6
                                spacing: 4
                                visible: notifRoot.buttons.length > 0

                                Repeater {
                                    model: Math.ceil(notifRoot.buttons.length / 5)

                                    delegate: Row {
                                        required property int index
                                        property var rowButtons: notifRoot.buttons.slice(index * 5, index * 5 + 5)
                                        width: notifActions.width
                                        spacing: 4

                                        Repeater {
                                            model: rowButtons

                                            delegate: Rectangle {
                                                required property var modelData
                                                width: (parent.width - parent.spacing * (parent.rowButtons.length - 1)) / parent.rowButtons.length
                                                height: 24
                                                color: "@cc-bg@"
                                                border.color: "@cc-active@"
                                                border.width: 2
                                                radius: 0

                                                Text {
                                                    anchors.fill: parent
                                                    anchors.leftMargin: 5
                                                    anchors.rightMargin: 5
                                                    text: modelData.action ? (modelData.action.text || modelData.action.label || modelData.action.identifier) : "Copy \"" + modelData.code + "\""
                                                    color: buttonArea.containsMouse ? "@cc-active@" : "@cc-text@"
                                                    font.pixelSize: @cc-font-size@ - 2
                                                    font.family: "@cc-font-name@"
                                                    elide: Text.ElideRight
                                                    verticalAlignment: Text.AlignVCenter
                                                    horizontalAlignment: Text.AlignHCenter
                                                }

                                                MouseArea {
                                                    id: buttonArea
                                                    anchors.fill: parent
                                                    hoverEnabled: true
                                                    onClicked: {
                                                        if (modelData.action) {
                                                            modelData.action.invoke();
                                                            root.dismissNotif(notifRoot.notification.id);
                                                        } else {
                                                            root.copyVerificationCode(modelData.code);
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            z: 0
                            acceptedButtons: Qt.LeftButton | Qt.RightButton
                            onClicked: mouse => {
                                if (mouse.button === Qt.RightButton) {
                                    root.dismissNotif(modelData.id);
                                    return;
                                }
                                var acts = modelData.actions || [];
                                var invoked = false;
                                for (var i = 0; i < acts.length; i++) {
                                    if (acts[i].identifier === "default") {
                                        acts[i].invoke();
                                        invoked = true;
                                        break;
                                    }
                                }
                                if (!invoked && acts.length > 0) {
                                    acts[0].invoke();
                                }
                                root.dismissNotif(modelData.id);
                            }
                        }
                    }

                    Item {
                        width: parent.width
                        height: notifList.height
                        visible: root.notifCount === 0

                        Text {
                            anchors.centerIn: parent
                            text: "No notifications"
                            color: "@cc-subtext@"
                            font.pixelSize: @cc-font-size@
                            font.family: "@cc-font-name@"
                            horizontalAlignment: Text.AlignHCenter
                        }
                    }
                }
            }
        }
    }
}

//@ pragma UseQApplication
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

  readonly property int notifCount: server.trackedNotifications.values.length
  readonly property var notifications: {
      var arr = server.trackedNotifications.values.slice();
      arr.reverse();
      return arr;
    }

  function dismissNotif(id) {
    var notifs = server.trackedNotifications.values
    for (var i = 0; i < notifs.length; i++) {
      if (notifs[i].id === id) { notifs[i].dismiss(); break }
    }
  }

  onNotifCountChanged: ipc.statusChanged(root.notifCount + "|" + (root.dnd ? "1" : "0"))
  onDndChanged: ipc.statusChanged(root.notifCount + "|" + (root.dnd ? "1" : "0"))

  IpcHandler {
    id: ipc
    target: "notifier"

    function toggle(): void { root.ccVisible = !root.ccVisible }
    function toggleDnd(): void { root.dnd = !root.dnd; if (root.dnd) { activePopups.clear(); popupQueue = [] } }
    function clearAll(): void {
      var notifs = server.trackedNotifications.values.slice()
      for (var i = 0; i < notifs.length; i++) notifs[i].dismiss()
    }
    function dismiss(id: int): void {
      root.dismissNotif(id)
    }
    function getStatus(): string { return root.notifCount + "|" + (root.dnd ? "1" : "0") }

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
      notif.tracked = true

      if (notif.appName === "mpd" || notif.desktopEntry === "mpd") {
        var p = (notif.body || "").split(" - ")
        if (p.length >= 3) {
          notif.body = p[1] + " (" + p[2] + ") - " + p[0]
        }
      }

      if (!root.dnd) {
        var replaced = false
        for (var i = 0; i < activePopups.count; i++) {
          var existing = activePopups.get(i)
          var sameKey = existing.notif.appName === notif.appName && existing.notif.summary === notif.summary
          var sameId = existing.notif.id === notif.id
          if (sameId || sameKey) {
            activePopups.remove(i)
            popupQueue.unshift(notif)
            popupQueue = popupQueue
            showNextPopup()
            replaced = true
            break
          }
        }
        if (!replaced) {
          popupQueue.push(notif)
          popupQueue = popupQueue
          showNextPopup()
        }
      }
    }
  }

  property var popupQueue: []
  ListModel { id: activePopups }

  Repeater {
    model: server.trackedNotifications

    delegate: Item {
      required property var modelData
      Connections {
        target: modelData
        function onBodyChanged() {
          if (root.dnd || root.ccVisible) return
          var inPopup = false
          for (var i = 0; i < activePopups.count; i++) {
            if (activePopups.get(i).notif.id === modelData.id) { inPopup = true; break }
          }
          if (!inPopup) {
            popupQueue.push(modelData)
            popupQueue = popupQueue
            showNextPopup()
          }
        }
      }
    }
  }

  function showNextPopup() {
    if (popupQueue.length > 0 && activePopups.count < @popup-max@) {
      var n = popupQueue.shift()
      popupQueue = popupQueue
      activePopups.insert(0, {notif: n})
    }
  }

  function dismissPopup(idx) {
    activePopups.remove(idx)
    showNextPopup()
  }

  onCcVisibleChanged: {
    if (ccVisible) {
      activePopups.clear()
      popupQueue = []
    }
  }

  function popupIconSource(data) {
    var ai = data.appIcon || "";
    var di = data.desktopEntry || "";
    var img = data.image || "";
    var fallback = "applications-system";
    if (img.length > 0) return img;
    if (ai.length > 0) {
      if (ai.startsWith("/")) return ai;
      return Quickshell.iconPath(ai, fallback);
    }
    if (di.length > 0) return Quickshell.iconPath(di, fallback);
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

          onNotifChanged: {
            popupTimer.restart()
            progressAnim.stop()
            progressBar.width = @popup-width@ - @popup-margin@ * 2 - 6
            progressAnim.start()
          }

          Connections {
            target: notif
            function onBodyChanged() {
              popupTimer.restart()
              progressAnim.stop()
              progressBar.width = @popup-width@ - @popup-margin@ * 2 - 6
              progressAnim.start()
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
          implicitHeight: Math.max(popupTextCol.implicitHeight + 4, popupIcon.height + 4) + 8 + 6

          MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.LeftButton | Qt.RightButton
            hoverEnabled: true
            onEntered: {
              popupRoot.hovered = true
              popupTimer.stop()
              progressAnim.stop()
              progressBar.width = @popup-width@ - @popup-margin@ * 2 - 6
            }
            onExited: {
              popupRoot.hovered = false
              progressBar.width = @popup-width@ - @popup-margin@ * 2 - 6
              popupTimer.start()
              progressAnim.start()
            }
            onClicked: mouse => {
              if (mouse.button === Qt.RightButton) {
                root.dismissPopup(index)
                return
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
              root.dismissPopup(index)
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
              width: popupTextCol.width
              text: notif ? (notif.appName + " - " + notif.summary) : ""
              color: "@cc-text@"
              font.pixelSize: @cc-font-size@
              font.family: "@cc-font-name@"
              font.bold: true
              elide: Text.ElideRight
            }

            Text {
              width: popupTextCol.width
              text: notif ? (notif.body || "").substring(0, 1500) + ((notif.body || "").length > 1500 ? "..." : "") : ""
              color: "@cc-subtext@"
              font.pixelSize: @cc-font-size@ - 1
              font.family: "@cc-font-name@"
              wrapMode: Text.Wrap
              visible: notif ? (notif.body ? notif.body.length > 0 : false) : false
            }
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

          Item { width: parent.width - titleText.width - 80 - 4 - 32 - 4; height: 1 }

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

          Item { width: 4; height: 1 }

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

          Row {
            width: parent.width
            spacing: 4
            visible: Mpris.players.values.length > 1

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
                      onClicked: if (mprisCard.player) mprisCard.player.shuffle = !mprisCard.player.shuffle
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
                      onClicked: if (mprisCard.player) mprisCard.player.previous()
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
                      onClicked: if (mprisCard.player) mprisCard.player.togglePlaying()
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
                      onClicked: if (mprisCard.player) mprisCard.player.next()
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
                        if (!mprisCard.player) return
                        if (mprisCard.player.loopState === MprisLoopState.None)
                          mprisCard.player.loopState = MprisLoopState.Playlist
                        else if (mprisCard.player.loopState === MprisLoopState.Playlist)
                          mprisCard.player.loopState = MprisLoopState.Track
                        else
                          mprisCard.player.loopState = MprisLoopState.None
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
            height: ccContent.height - titleRow.height - mprisSection.height - ccContent.spacing * 3 - 5
            clip: true
            model: root.notifications
            spacing: 5
            boundsBehavior: Flickable.StopAtBounds

            delegate: Rectangle {
              required property var modelData
              width: notifList.width
              implicitHeight: notifInner.implicitHeight + 16
              color: "@cc-border@"
              border.color: "@cc-border@"
              border.width: 3
              radius: 0

              Rectangle {
                anchors.fill: parent
                anchors.margins: 3
                color: "@cc-bg@"
                border.color: "@cc-bg@"
                border.width: 3
                radius: 0

                Row {
                  id: notifInner
                  anchors.fill: parent
                  anchors.margins: 6
                  spacing: 8

                  Image {
                    id: notifIcon
                    source: {
                      var ai = modelData.appIcon || "";
                      var di = modelData.desktopEntry || "";
                      var img = modelData.image || "";
                      var fallback = "applications-system";
                      if (img.length > 0) return img;
                      if (ai.length > 0) {
                        if (ai.startsWith("/")) return ai;
                        return Quickshell.iconPath(ai, fallback);
                      }
                      if (di.length > 0) return Quickshell.iconPath(di, fallback);
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
                      width: parent.width
                      text: modelData.appName + " - " + modelData.summary
                      color: "@cc-text@"
                      font.pixelSize: @cc-font-size@
                      font.family: "@cc-font-name@"
                      font.bold: true
                      elide: Text.ElideRight
                    }

                    Text {
                      width: parent.width
                      text: (modelData.body || "").substring(0, 1500) + ((modelData.body || "").length > 1500 ? "..." : "")
                      color: "@cc-subtext@"
                      font.pixelSize: @cc-font-size@ - 1
                      font.family: "@cc-font-name@"
                      wrapMode: Text.Wrap
                      visible: modelData.body.length > 0
                    }
                  }
                }
              }

              MouseArea {
                anchors.fill: parent
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
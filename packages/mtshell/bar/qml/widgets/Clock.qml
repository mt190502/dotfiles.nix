import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland

Item {
    id: root

    property var barWindow: null
    property string format: "@clock-format@"
    property int interval: @clock-interval@
    property bool calendarEnabled: @calendar-enabled@
    property string calEventsCommand: "@calendar-events-command@"
    property string calOpenCommand: "@calendar-open-command@"
    property var eventDays: []
    property var eventCache: ({})
    property var calendarOptions: []
    property string selectedCalendar: persisted.selectedCalendar
    property string eventsRequestKey: ""
    property string eventsProcessKey: ""
    property int eventsRevision: 0
    property string calBg: "@calendar-bg@"
    property string calText: "@calendar-text@"
    property string calBorder: "@calendar-border@"
    property string calActive: "@calendar-active@"
    property string calSubtext: "@calendar-subtext@"
    property string calFontName: "@calendar-font-name@"
    property int calFontSize: @calendar-font-size@
    property int calWidth: @calendar-width@
    property int calHeight: @calendar-height@
    property int calPad: @calendar-pad@
    property bool calendarAboveBar: @calendar-above-bar@
    property bool hovered: false
    property bool popupHovered: false
    property real mouseX: 0
    property date currentDate: new Date()
    property int displayMonth: currentDate.getMonth()
    property int displayYear: currentDate.getFullYear()

    PersistentProperties {
        id: persisted
        reloadableId: "calendar-selection"
        property string selectedCalendar: ""
    }

    FileView {
        id: calendarState
        path: Quickshell.statePath("mtshell-calendar.json")
        blockLoading: true
        watchChanges: true
        printErrors: false
        onFileChanged: reload()
        onLoadedChanged: {
            if (loaded)
                root.loadSelectedCalendar();
        }
    }

    function loadSelectedCalendar() {
        try {
            var saved = JSON.parse(calendarState.text());
            var uid = saved.uid || "";
            if (uid !== root.selectedCalendar) {
                root.selectedCalendar = uid;
                root.refreshEvents();
            }
        } catch (error) {
            // Keep the current selection when the state file is unavailable.
        }
    }

    function daysInMonth(year, month) {
    return new Date(year, month + 1, 0).getDate();
    }

    function firstDayOfWeek(year, month) {
    var d = new Date(year, month, 1).getDay();
    return d === 0 ? 6 : d - 1;
    }

    function changeMonth(delta) {
        var m = root.displayMonth + delta;
        var y = root.displayYear;
        if (m < 0) {
            m = 11;
            y--;
        }
        if (m > 11) {
            m = 0;
            y++;
        }
        root.displayMonth = m;
        root.displayYear = y;
        root.refreshEvents();
    }

    function goToday() {
        var now = new Date();
        root.displayMonth = now.getMonth();
        root.displayYear = now.getFullYear();
        root.refreshEvents();
    }

    function dateString(year, month, day) {
        return year.toString().padStart(4, "0") + "-" + (month + 1).toString().padStart(2, "0") + "-" + day.toString().padStart(2, "0");
    }

    function refreshEvents() {
        if (!root.calendarEnabled || root.calEventsCommand.length === 0)
            return;
        var start = root.dateString(root.displayYear, root.displayMonth, 1);
        var end = root.dateString(root.displayYear, root.displayMonth, root.daysInMonth(root.displayYear, root.displayMonth));
        var key = root.selectedCalendar + "|" + start;
        root.eventsRequestKey = key;
        if (root.eventCache[key] !== undefined) {
            root.eventDays = root.eventCache[key];
            root.eventsRevision++;
        }
        root.eventsProcessKey = key;
        eventsProc.command = ["sh", "-c", root.calEventsCommand + " \"$1\" \"$2\" \"$3\"", "calendar", start, end, root.selectedCalendar];
        eventsProc.running = true;
    }

    function selectCalendar(uid) {
        root.selectedCalendar = uid;
        persisted.selectedCalendar = uid;
        calendarState.setText(JSON.stringify({ "uid": uid }));
        root.refreshEvents();
    }

    function openDate(year, month, day) {
        if (root.calOpenCommand.length === 0)
            return;
        Quickshell.execDetached(["sh", "-c", root.calOpenCommand + " \"$1\"", "calendar", root.dateString(year, month, day)]);
    }

    implicitWidth: clockText.implicitWidth + Base.margin * 2
    implicitHeight: Base.height + Base.padTop + Base.padBottom
    Component.onCompleted: {
        root.loadSelectedCalendar();
        root.refreshEvents();
    }

    Rectangle {
        anchors.fill: parent
        anchors.topMargin: Base.padTop
        anchors.bottomMargin: Base.padBottom
        color: Base.bg
        radius: Base.radius

        Text {
            id: clockText
            anchors.fill: parent
            anchors.leftMargin: Base.margin
            anchors.rightMargin: Base.margin
            verticalAlignment: Text.AlignVCenter
            text: Qt.formatDateTime(new Date(), root.format)
            color: Base.text
            font.pixelSize: Base.fontSize
            font.family: Base.fontName
        }

        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            onPositionChanged: (m) => {
                return root.mouseX = m.x;
            }
            onEntered: {
              exitTimer.stop();
              root.hovered = true;
            }
            onExited: {
              exitTimer.restart();
            }
            propagateComposedEvents: true
        }
    }

    PopupWindow {
        id: calendarPopup
        visible: root.calendarEnabled && (root.hovered || root.popupHovered) && root.barWindow !== null
        color: "transparent"
        implicitWidth: root.calWidth
        implicitHeight: root.calHeight
        onVisibleChanged: {
            if (visible)
                root.refreshEvents();
        }
        anchor.item: root
        anchor.edges: Edges.Bottom
        anchor.gravity: Edges.Bottom
        anchor.rect.x: (implicitWidth - root.width) / 2
        anchor.rect.y: root.height + 4

        Rectangle {
            id: calendarRoot
            width: root.calWidth
            height: root.calHeight
            color: root.calBg
            border.color: root.calBorder
            border.width: 3
            radius: 0

            HoverHandler {
                onHoveredChanged: {
                    root.popupHovered = hovered;
                    if (hovered)
                        exitTimer.stop();
                    else
                        exitTimer.restart();
                }
            }

            Column {
                anchors.fill: parent
                anchors.margins: root.calPad
                spacing: 6

                Row {
                    width: parent.width
                    height: 28
                    spacing: 0

                    Rectangle {
                        width: 28
                        height: 28
                        color: prevMonthArea.containsMouse ? root.calActive : root.calBg
                        border.color: root.calBorder
                        border.width: 2
                        radius: 0

                        Text {
                            anchors.centerIn: parent
                            text: "◀"
                            color: prevMonthArea.containsMouse ? root.calBg : root.calText
                            font.pixelSize: root.calFontSize
                            font.family: root.calFontName
                        }

                        MouseArea {
                            id: prevMonthArea
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: root.changeMonth(-1)
                        }
                    }

                        Text {
                            width: parent.width - 116
                        height: parent.height
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        text: {
                            var months = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"];
                            return months[root.displayMonth] + " " + root.displayYear;
                        }
                        color: root.calText
                        font.pixelSize: root.calFontSize
                        font.family: root.calFontName
                            font.bold: true
                        }

                        Rectangle {
                            width: 56
                            height: 28
                            color: todayArea.containsMouse ? root.calActive : root.calBg
                            border.color: root.calBorder
                            border.width: 2
                            radius: 0

                            Text {
                                anchors.centerIn: parent
                                text: "Today"
                                color: todayArea.containsMouse ? root.calBg : root.calText
                                font.pixelSize: root.calFontSize - 2
                                font.family: root.calFontName
                            }

                            MouseArea {
                                id: todayArea
                                anchors.fill: parent
                                hoverEnabled: true
                                onClicked: root.goToday()
                            }
                        }

                        Item {
                            width: 4
                            height: 1
                        }

                        Rectangle {
                            width: 28
                        height: 28
                        color: nextMonthArea.containsMouse ? root.calActive : root.calBg
                        border.color: root.calBorder
                        border.width: 2
                        radius: 0

                        Text {
                            anchors.centerIn: parent
                            text: "▶"
                            color: nextMonthArea.containsMouse ? root.calBg : root.calText
                            font.pixelSize: root.calFontSize
                            font.family: root.calFontName
                        }

                        MouseArea {
                            id: nextMonthArea
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: root.changeMonth(1)
                        }
                    }
                }

                ListView {
                    id: calendarList
                    width: parent.width
                    height: root.calendarOptions.length > 1 ? 22 : 0
                    visible: root.calendarOptions.length > 1
                    orientation: ListView.Horizontal
                    spacing: 3
                    clip: true
                    interactive: true
                    boundsBehavior: Flickable.StopAtBounds

                    model: root.calendarOptions
                    delegate: Rectangle {
                        required property var modelData
                        width: Math.min(calendarName.implicitWidth + 14, 110)
                        height: 20
                        color: root.selectedCalendar === modelData.uid ? root.calActive : root.calBg
                        border.color: root.calBorder
                        border.width: 1

                        Text {
                            id: calendarName
                            anchors.fill: parent
                            anchors.leftMargin: 6
                            anchors.rightMargin: 6
                            text: modelData.name
                            elide: Text.ElideRight
                            verticalAlignment: Text.AlignVCenter
                            color: root.selectedCalendar === modelData.uid ? root.calBg : root.calSubtext
                            font.pixelSize: root.calFontSize - 3
                            font.family: root.calFontName
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: root.selectCalendar(modelData.uid)
                        }
                    }

                    WheelHandler {
                        target: null
                        acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
                        onWheel: wheel => {
                            wheel.accepted = true;
                            var delta = wheel.angleDelta.y !== 0 ? wheel.angleDelta.y : wheel.angleDelta.x;
                            calendarList.contentX = Math.max(0, Math.min(calendarList.contentWidth - calendarList.width, calendarList.contentX - delta));
                        }
                    }
                }

                Row {
                    width: parent.width
                    height: 20
                    spacing: 0

                    Repeater {
                        model: ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
                        delegate: Text {
                            required property var modelData
                            width: parent.width / 7
                            height: 20
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            text: modelData
                            color: root.calSubtext
                            font.pixelSize: root.calFontSize - 2
                            font.family: root.calFontName
                            font.bold: true
                        }
                    }
                }

                Grid {
                    id: dayGrid
                    width: parent.width
                    height: parent.height - 28 - 20 - 22 - 12
                    columns: 7
                    rowSpacing: 2
                    columnSpacing: 2

                    Repeater {
                        model: {
                            var revision = root.eventsRevision;
                            var days = [];
                            var offset = root.firstDayOfWeek(root.displayYear, root.displayMonth);
                            var total = root.daysInMonth(root.displayYear, root.displayMonth);
                            var prevTotal = root.daysInMonth(root.displayMonth === 0 ? root.displayYear - 1 : root.displayYear, root.displayMonth === 0 ? 11 : root.displayMonth - 1);
                            for (var i = 0; i < offset; i++) days.push({
                                "day": prevTotal - offset + i + 1,
                                "current": false
                            })
                            for (var i = 1; i <= total; i++) days.push({
                                "day": i,
                                "current": true
                            })
                            var next = 42 - days.length;
                            for (var i = 1; i <= next; i++) days.push({
                                "day": i,
                                "current": false
                            })
                            return days;
                        }

                        delegate: Rectangle {
                            required property var modelData
                            property string cellDate: modelData.current ? root.dateString(root.displayYear, root.displayMonth, modelData.day) : ""
                            property bool hasEvent: root.eventsRevision >= 0 && cellDate.length > 0 && root.eventDays.indexOf(cellDate) >= 0
                            width: (dayGrid.width - 12) / 7
                            height: (dayGrid.height - 10) / 6
                            color: {
                                var today = new Date();
                                if (modelData.current && modelData.day === today.getDate() && root.displayMonth === today.getMonth() && root.displayYear === today.getFullYear())
                                    return root.calActive;
                                return dayCellArea.containsMouse ? root.calBorder : root.calBg;
                            }
                            border.color: {
                                var today = new Date();
                                if (modelData.current && modelData.day === today.getDate() && root.displayMonth === today.getMonth() && root.displayYear === today.getFullYear())
                                    return root.calBorder;
                                return "transparent";
                            }
                            border.width: 2
                            radius: 0

                            Text {
                                anchors.centerIn: parent
                                text: modelData.day
                                color: {
                                    var today = new Date();
                                    if (modelData.current && modelData.day === today.getDate() && root.displayMonth === today.getMonth() && root.displayYear === today.getFullYear())
                                        return root.calBg;
                                    return modelData.current ? root.calText : root.calSubtext;
                                }
                                font.pixelSize: root.calFontSize
                                font.family: root.calFontName
                                opacity: modelData.current ? 1 : 0.4
                            }

                            Rectangle {
                                visible: hasEvent
                                width: 4
                                height: 4
                                radius: 2
                                color: root.calActive
                                anchors.horizontalCenter: parent.horizontalCenter
                                anchors.bottom: parent.bottom
                                anchors.bottomMargin: 2
                            }

                            MouseArea {
                                id: dayCellArea
                                anchors.fill: parent
                                hoverEnabled: true
                                onDoubleClicked: root.openDate(root.displayYear, root.displayMonth, modelData.day)
                            }
                        }
                    }
                }
            }
        }
    }

    Process {
        id: eventsProc
        stdout: StdioCollector {
            onStreamFinished: {
                if (this.text.trim().length === 0)
                    return;
                try {
                    var parsed = JSON.parse(this.text.trim());
                    var days = Array.isArray(parsed) ? parsed : (Array.isArray(parsed.days) ? parsed.days : []);
                    var calendars = Array.isArray(parsed) ? [] : (Array.isArray(parsed.calendars) ? parsed.calendars : []);
                    var key = root.eventsProcessKey;
                    var cache = root.eventCache;
                    cache[key] = days;
                    root.eventCache = cache;
                    if (calendars.length > 0)
                        root.calendarOptions = [{ "uid": "", "name": "All" }].concat(calendars);
                    if (calendars.length > 0 && root.selectedCalendar !== ""
                        && !calendars.some(calendar => calendar.uid === root.selectedCalendar)) {
                        root.selectedCalendar = "";
                        persisted.selectedCalendar = "";
                        calendarState.setText(JSON.stringify({ "uid": "" }));
                        root.refreshEvents();
                    }
                    if (key === root.selectedCalendar + "|" + root.dateString(root.displayYear, root.displayMonth, 1))
                        root.eventDays = days;
                    root.eventsRevision++;
                } catch (error) {
                    // Keep the last valid event set when a calendar query fails.
                }
            }
        }
    }

    Timer {
        interval: root.interval
        running: true
        repeat: true
        onTriggered: {
            var now = new Date();
            clockText.text = Qt.formatDateTime(now, root.format);
            root.currentDate = now;
        }
    }

    Timer {
        id: exitTimer
        interval: 500
        repeat: false
        onTriggered: {
            if (!root.popupHovered)
                root.hovered = false;
        }
    }
}

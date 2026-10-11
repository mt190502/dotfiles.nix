import Quickshell
import Quickshell.I3
import Quickshell.Io
import QtQuick

Item {
    id: root
    readonly property int maxLength: 64
    property string title: ""

    visible: title.length > 0
    implicitWidth: visible ? windowText.implicitWidth + Base.margin * 2 : 0
    implicitHeight: Base.height + Base.padTop + Base.padBottom

    Rectangle {
        anchors.fill: parent
        anchors.topMargin: Base.padTop
        anchors.bottomMargin: Base.padBottom
        color: Base.bg
        radius: Base.radius

        Text {
            id: windowText
            anchors.fill: parent
            anchors.leftMargin: Base.margin
            anchors.rightMargin: Base.margin
            verticalAlignment: Text.AlignVCenter
            text: root.title.length > root.maxLength ? root.title.substring(0, root.maxLength - 1) + "…" : root.title
            color: Base.text
            font.pixelSize: Base.fontSize
            font.family: Base.fontName
        }
    }

    I3IpcListener {
        subscriptions: ["window", "workspace"]
        onIpcEvent: event => {
            try {
                const data = JSON.parse(event.data);
                if (event.type === "window") {
                    if (data.change === "focus") {
                        root.title = data.container?.name || "";
                    } else if (data.change === "title" && data.container?.focused) {
                        root.title = data.container?.name || "";
                    } else if (data.change === "close") {
                        initTitleProc.exec(["swaymsg", "-t", "get_tree"]);
                    }
                } else if (event.type === "workspace") {
                    if (data.change === "focus") {
                        initTitleProc.exec(["swaymsg", "-t", "get_tree"]);
                    }
                }
            } catch (e) {}
        }
    }

    function findFocused(node) {
        if (!node)
            return null;
        if (node.focused && (node.type === "con" || node.type === "floating_con")) {
            return node;
        }
        if (node.nodes) {
            for (var i = 0; i < node.nodes.length; i++) {
                var found = findFocused(node.nodes[i]);
                if (found)
                    return found;
            }
        }
        if (node.floating_nodes) {
            for (var j = 0; j < node.floating_nodes.length; j++) {
                var foundFloat = findFocused(node.floating_nodes[j]);
                if (foundFloat)
                    return foundFloat;
            }
        }
        return null;
    }

    Process {
        id: initTitleProc
        stdout: StdioCollector {
            id: initTitleStdout
            onStreamFinished: {
                try {
                    const tree = JSON.parse(initTitleStdout.text);
                    const focusedNode = findFocused(tree);
                    root.title = focusedNode ? (focusedNode.name || "") : "";
                } catch (e) {}
            }
        }
    }

    Component.onCompleted: {
        initTitleProc.exec(["swaymsg", "-t", "get_tree"]);
    }
}

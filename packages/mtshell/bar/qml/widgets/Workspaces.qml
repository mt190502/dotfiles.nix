import QtQuick
import Quickshell
import Quickshell.I3

Item {
    id: root
    required property var barScreen

    implicitWidth: contentRow.width + Base.margin * 2 + 4
    implicitHeight: Base.height + Base.padTop + Base.padBottom

    Rectangle {
        anchors.fill: parent
        anchors.topMargin: Base.padTop
        anchors.bottomMargin: Base.padBottom
        color: Base.bg
        radius: Base.radius

        MouseArea {
            anchors.fill: parent
            onWheel: (wheel) => {
                if (wheel.angleDelta.y > 0)
                    I3.dispatch("workspace prev_on_output");
                else
                    I3.dispatch("workspace next_on_output");
            }
        }

        Row {
            id: contentRow
            anchors.centerIn: parent
            anchors.leftMargin: 2
            anchors.rightMargin: 2
            spacing: @ws-spacing@

            Repeater {
                model: I3.workspaces

                delegate: Text {
                    required property var modelData
                    property bool onScreen: modelData.monitor.name === root.barScreen.name
                    visible: onScreen
                    width: visible ? implicitWidth : 0
                    text: {
                      var icon = modelData.focused ? "@ws-icon-focused@" : modelData.active ? "@ws-icon-active@" : "@ws-icon-inactive@"
                      return icon.length > 0 ? icon : modelData.name
                    }
                    color: modelData.focused ? "@ws-text-focused@" : modelData.active ? "@ws-text-active@" : "@ws-text-inactive@"
                    font.pixelSize: Base.fontSize
                    font.family: Base.fontName

                    MouseArea {
                        anchors.fill: parent
                        onClicked: I3.dispatch(`workspace ${modelData.name}`)
                    }
                }
            }
        }
    }
}

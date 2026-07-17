import Quickshell
import Quickshell.Io
import QtQuick
import "widgets"

Variants {
  model: Quickshell.screens

  delegate: PanelWindow {
    id: barWindow
    required property var modelData
    screen: modelData
    property bool isLaptop: false

    Component.onCompleted: laptopCheck.running = true

    Process {
      id: laptopCheck
      command: ["sh", "-c", "case $(cat /sys/class/dmi/id/chassis_type 2>/dev/null) in 8|9|10|14) printf yes;; esac"]
      stdout: StdioCollector {
        onStreamFinished: barWindow.isLaptop = this.text.trim() === "yes"
      }
    }

    color: "@bar-color@"
    surfaceFormat.opaque: @bar-opaque@

    anchors {
      left: true
      @position@: true
      right: true
    }

    implicitHeight: @height@

    Item {
      anchors.fill: parent

      Row {
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        spacing: @margin@

        Separator { size: 4 }
        Workspaces { barScreen: modelData }
        Window {}
      }

      Row {
        anchors.centerIn: parent
        spacing: @margin@

        Mpd {}
        Clock { barWindow: barWindow }
        Weather {}
      }

      Row {
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        spacing: @margin@

        Separator { size: 5 }
        Systray {}
        Memory {}
        IdleInhibitor { barWindow: barWindow }
        KeyboardLayout {}
        Network { barWindow: barWindow }
        Bluetooth {}
        Battery { laptopDetected: barWindow.isLaptop }
        Backlight { laptopDetected: barWindow.isLaptop }
        Pulseaudio {}
        Notifier { barWindow: barWindow }
        Powermenu { barWindow: barWindow }
        Separator { size: 4 }
      }
    }
  }
}

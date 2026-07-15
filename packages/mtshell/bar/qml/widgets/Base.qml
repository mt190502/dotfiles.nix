pragma Singleton
import QtQuick

QtObject {
  readonly property string bg: "@base-bg@"
  readonly property string text: "@base-text@"
  readonly property string active: "@base-active@"
  readonly property string inactive: "@base-inactive@"
  readonly property string urgent: "@base-urgent@"
  readonly property string border: "@base-border@"
  readonly property string fontName: "@base-font-name@"
  readonly property int fontSize: @base-font-size@
  readonly property string iconTheme: "@base-icon-theme@"
  readonly property int margin: @base-margin@
  readonly property int radius: @base-radius@
  readonly property int height: @base-height@
  readonly property int padTop: @base-pad-top@
  readonly property int padBottom: @base-pad-bottom@
  property bool idleInhibited: false
}

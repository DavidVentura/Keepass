import QtQuick 2.0
import Ubuntu.Components 1.3 as UITK

Column {
    property alias placeholder: label.text
    property bool placeholderVisible
    property alias control: loader.sourceComponent

    spacing: units.gu(0.1)
    Text {
        id: label
        anchors.leftMargin: units.gu(0.5)
        anchors.left: parent.left
        anchors.right: parent.right
        font.pixelSize: units.gu(1.2)
        color: placeholderVisible ? '#999' : 'transparent'
    }
    Loader {
        id: loader
    }
}

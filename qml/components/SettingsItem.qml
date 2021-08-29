import QtQuick 2.0

Row {
    property string title
    property string description
    property alias control: loader.sourceComponent

    anchors.left: parent.left
    anchors.right: parent.right
    anchors.leftMargin: units.gu(2)
    anchors.rightMargin: units.gu(2)
    spacing: units.gu(2)

    Column {
        spacing: units.gu(0.2)
        width: parent.width - loader.width - parent.spacing
        anchors.verticalCenter: parent.verticalCenter
        Text {
            anchors.left: parent.left
            anchors.right: parent.right
            text: title
        }
        Text {
            visible: description !== ''
            anchors.left: parent.left
            anchors.right: parent.right
            text: description
            color: '#999'
            wrapMode: Text.WordWrap
            font.pixelSize: units.gu(1.4)
        }
    }
    Loader {
        anchors.verticalCenter: parent.verticalCenter
        width: units.gu(6)
        id: loader
    }
}

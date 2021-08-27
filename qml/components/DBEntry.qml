import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import Ubuntu.Components 1.3 as UITK

Item {
    property bool passwordVisible: false
    height: units.gu(12)
    anchors.leftMargin: units.gu(2)
    anchors.rightMargin: units.gu(2)

    anchors.left: parent.left
    anchors.right: parent.right
    RowLayout {
        anchors.fill: parent
        spacing: units.gu(2)
        UITK.Icon {
            source: 'file://' + icon_path
            width: units.gu(5)
            y: parent.height / 2 - height / 2
        }
        ColumnLayout {
            spacing: units.gu(0.5)
            Text {
                text: title
                font.pointSize: units.gu(1.8)
            }

            Text {
                color: '#666'
                Layout.fillWidth: true
                text: username
            }

            Text {
                text: passwordVisible ? password : 'Tap to reveal'
            }
        }
        Row {
            spacing: units.gu(2)
            Image {
                height: units.gu(4)
                y: parent.height / 2 - height / 2

                source: "../../assets/copy.png"
                fillMode: Image.PreserveAspectFit
            }
            Image {
                height: units.gu(4)
                y: parent.height / 2 - height / 2

                source: "../../assets/visibility.png"
                fillMode: Image.PreserveAspectFit
                MouseArea {
                    anchors.fill: parent
                    onPressed: passwordVisible = pressed
                    onReleased: timer.restart()
                }
            }
            Timer {
                id: timer
                repeat: false
                interval: 500
                onTriggered: passwordVisible = false
            }
        }
    }
}

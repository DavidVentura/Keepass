import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import Ubuntu.Components 1.3 as UITK

RowLayout {
    property bool passwordVisible: false
    Column {
        Text {
            text: title
            font.pointSize: units.gu(1.8)
        }

        RowLayout {
            UITK.Icon {
                name: "account"
                height: units.gu(3)
            }

            Text {
                Layout.fillWidth: true
                text: username
            }
        }

        Row {
            Image {
                source: "../../assets/web.png"
                height: units.gu(3)
                fillMode: Image.PreserveAspectFit
            }
            Text {
                Layout.fillWidth: true
                text: url
            }
        }
        Text {
            text: passwordVisible ? password : 'Tap to reveal'
        }
    }
    RowLayout {
        height: parent.height
        Image {
            source: "../../assets/copy.png"
            height: units.gu(3)
            fillMode: Image.PreserveAspectFit
        }
        Image {
            source: "../../assets/visibility.png"
            height: units.gu(3)
            fillMode: Image.PreserveAspectFit
            MouseArea {
                anchors.fill: parent
                onPressed: passwordVisible = pressed
                onReleased: passwordVisible = pressed
            }
        }
    }
}

import QtQuick 2.12
import QtQuick.Layouts 1.12
import Ubuntu.Components 1.3 as UITK

Column {
    property bool passwordVisible: false
    Text {
        text: title
        font.pointSize: units.gu(1.8)
    }

    RowLayout {
        UITK.Icon {
            name: "contact"
            height: units.gu(2)
        }

        Text {
            Layout.fillWidth: true
            text: username
        }
    }
    RowLayout {
        UITK.Icon {
            name: "settings"
            height: units.gu(2)
        }
        Text {
            Layout.fillWidth: true
            text: passwordVisible ? password : 'Tap to reveal'
        }
        UITK.Button {
            width: units.gu(5)

            iconName: "undo"
        }
        UITK.Button {
            width: units.gu(5)
            iconName: "close"
        }
    }
    RowLayout {
        UITK.Icon {
            name: "undo"
            height: units.gu(2)
        }
        Text {
            Layout.fillWidth: true
            text: url
        }
    }
    RowLayout {
        UITK.Icon {
            name: "undo"
            height: units.gu(2)
        }
        Text {
            Layout.fillWidth: true
            text: group
        }
    }
}

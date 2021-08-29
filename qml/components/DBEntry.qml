import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import Ubuntu.Components 1.3 as UITK
import QtGraphicalEffects 1.0

UITK.ListItem {
    property bool passwordVisible: false
    height: units.gu(10)
    anchors.left: parent.left
    anchors.right: parent.right

    id: entireItem
    trailingActions: UITK.ListItemActions {
        actions: [

            UITK.Action {
                visible: username
                iconSource: "../../assets/person.png"
                onTriggered: {
                    UITK.Clipboard.push(username)
                    toast.show("Username copied to clipboard")
                }
            },
            UITK.Action {
                visible: url
                iconSource: "../../assets/web.png"
                onTriggered: {
                    if (url.indexOf('//') === -1) {
                        Qt.openUrlExternally('http://' + url)
                        return
                    }

                    Qt.openUrlExternally(url)
                }
            }
        ]
    }
    Rectangle {
        anchors.fill: parent
        color: 'white'
    }

    Row {
        anchors.fill: parent
        anchors.leftMargin: units.gu(2)
        anchors.rightMargin: units.gu(2)
        anchors.topMargin: units.gu(1)
        anchors.bottomMargin: units.gu(1)
        spacing: units.gu(1)
        Image {
            id: entryImg
            fillMode: Image.PreserveAspectFit
            source: 'file://' + icon_path
            width: units.gu(5)
            height: parent.height
            y: parent.height / 2 - height / 2
        }
        Column {
            id: detailsColumn
            spacing: units.gu(0.5)
            width: parent.width - copyIcon.width - entryImg.width - parent.spacing * 2
            Text {
                width: parent.width
                elide: Text.ElideRight
                text: title
                font.pointSize: units.gu(1.5)
            }

            Text {
                width: parent.width
                elide: Text.ElideRight
                color: '#666'
                text: username
            }

            Text {
                text: passwordVisible ? password : '••••••••'
            }
        }
        UITK.Button {
            id: copyIcon
            width: units.gu(4)
            height: parent.height
            iconSource: "../../assets/copy.png"
            strokeColor: 'white'

            onClicked: {
                UITK.Clipboard.push(password)
                toast.show("Password copied to clipboard")
            }
        }
    }
    Rectangle {
        x: parent.x
        width: parent.width
        y: parent.height - height
        height: units.gu(0.1)
        color: '#ddd'
    }
    MouseArea {
        x: parent.x
        width: entryImg.width + detailsColumn.width
        height: parent.height
        onClicked: {
            passwordVisible = true
            timer.restart()
        }
    }
    Timer {
        id: timer
        repeat: false
        interval: 1500
        onTriggered: passwordVisible = false
    }
}

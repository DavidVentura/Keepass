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
    leadingActions: UITK.ListItemActions {
        actions: [
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
    trailingActions: UITK.ListItemActions {
        actions: [

            UITK.Action {
                visible: username
                iconSource: "../../assets/user.svg"
                onTriggered: {
                    UITK.Clipboard.push(username)
                    toast.show("Username copied to clipboard")
                }
            },
            UITK.Action {
                visible: username
                iconSource: "../../assets/key.svg"
                onTriggered: {
                    UITK.Clipboard.push(password)
                    toast.show("Password copied to clipboard")
                }
            }
        ]
    }
    Rectangle {
        anchors.fill: parent
        color: 'white'
    }

    Row {
        anchors.leftMargin: units.gu(2)
        anchors.rightMargin: units.gu(2)
        anchors.topMargin: units.gu(1)
        anchors.bottomMargin: units.gu(1)
        anchors.fill: parent

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
            width: parent.width - parent.spacing - units.gu(6)
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
            if (!settings.tapToReveal) {
                return
            }

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

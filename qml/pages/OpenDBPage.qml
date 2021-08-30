import Ubuntu.Components 1.3 as UITK
import Ubuntu.Content 1.3 as ContentHub
import QtQuick 2.12
import QtQuick.Layouts 1.12
import io.thp.pyotherside 1.3
import Qt.labs.settings 1.0
import "../components"

UITK.Page {
    property bool loadedKp: false
    property bool pickingDB
    property bool busy
    property string errorMsg
    property double lastHeartbeat: 0

    anchors.fill: parent

    header: UITK.PageHeader {
        id: header
        title: "Keepass"
        trailingActionBar.actions: [
            UITK.Action {
                iconName: "settings"
                onTriggered: {
                    stack.push(settingsPage)
                }
            }
        ]
    }
    Settings {
        id: settings
        property string lastKey
        property string lastDB
        property int autoCloseInterval: 15
    }

    ContentHub.ContentPeerPicker {
        id: peerPicker
        visible: false
        showTitle: true
        handler: ContentHub.ContentHandler.Source
        contentType: ContentHub.ContentType.Documents

        onPeerSelected: {
            peer.selectionType = ContentHub.ContentTransfer.Single
            signalConnections.target = peer.request()
        }
        onCancelPressed: stack.pop()
    }

    Connections {
        id: signalConnections
        onStateChanged: {
            var done = (target.state === ContentHub.ContentTransfer.Charged)

            if (!done) {
                return
            }
            if (target.items.length === 0) {
                return
            }
            const filePath = String(target.items[0].url).replace('file://', '')

            python.call('kp.set_file', [filePath, pickingDB], function (path) {
                if (pickingDB) {
                    settings.lastDB = path
                } else {
                    settings.lastKey = path
                }
                stack.pop()
            })
        }
    }

    Timer {
        interval: 1000
        running: settings.autoCloseInterval > 0
        repeat: true
        onTriggered: {
            const now = new Date().getTime()
            if (lastHeartbeat === 0) {
                lastHeartbeat = now
            }

            const delta = now - lastHeartbeat
            lastHeartbeat = now
            if (delta >= settings.autoCloseInterval * 60 * 1000) {
                stack.pop(null)
            }
        }
    }

    ColumnLayout {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.leftMargin: units.gu(2)
        anchors.rightMargin: units.gu(2)
        anchors.centerIn: parent

        spacing: units.gu(1)

        RowLayout {
            Layout.fillWidth: true
            UITK.TextField {
                enabled: false
                text: settings.lastDB
                Layout.fillWidth: true
                onTextChanged: settings.lastDB = text
            }

            UITK.Button {
                id: pickDB
                text: "Pick DB"
                onClicked: {
                    pickingDB = true
                    errorMsg = ''
                    busy = false
                    stack.push(peerPicker)
                }
            }
        }
        RowLayout {
            UITK.TextField {
                enabled: false
                text: settings.lastKey
                Layout.fillWidth: true
                onTextChanged: settings.lastKey = text
            }

            UITK.Button {
                visible: !settings.lastKey
                text: "Pick Key"
                onClicked: {
                    pickingDB = false
                    stack.push(peerPicker)
                    busy = false
                    errorMsg = ''
                }
            }
            UITK.Button {
                visible: settings.lastKey
                text: "Clear Key"
                onClicked: {
                    settings.lastKey = ''
                }
            }
        }

        UITK.TextField {
            id: password
            enabled: true
            text: ''
            placeholderText: "Password"
            echoMode: TextInput.Password
            Layout.fillWidth: true
            Keys.onReturnPressed: open_db()

            onTextChanged: {
                errorMsg = ''
            }
        }
        UITK.Button {
            Layout.fillWidth: true
            enabled: loadedKp && settings.lastDB && (settings.lastKey
                                                     || password.text)
            text: "Open DB"
            onClicked: open_db()
        }
        UITK.ActivityIndicator {
            Layout.fillWidth: true
            running: busy
            visible: busy
        }
        UITK.Label {
            text: errorMsg
        }
    }

    function open_db() {

        busy = true
        python.call('kp.open_db',
                    [settings.lastDB, settings.lastKey, password.text])
    }

    Python {
        id: python
        Component.onCompleted: {
            addImportPath(Qt.resolvedUrl('../../src/'))

            setHandler('db_open_fail', function (reason) {
                busy = false
                errorMsg = reason
            })
            setHandler('db_open', function () {
                busy = false
                root.push_entries()
            })
            importModule('kp', function () {
                loadedKp = true
            })
        }
    }
}

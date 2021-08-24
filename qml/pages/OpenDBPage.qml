import Ubuntu.Components 1.3 as UITK
import Ubuntu.Content 1.3 as ContentHub
import QtQuick 2.12
import QtQuick.Layouts 1.12
import io.thp.pyotherside 1.3

UITK.Page {
    property bool pickingDB
    property variant settings: {

    }
    function fileReady(filePath) {
        python.call("kp.set_file", [filePath, pickingDB])
    }
    ContentHub.ContentPeerPicker {
        id: peerPicker
        visible: false
        showTitle: false
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

            fileReady(filePath)
            peerPicker.visible = false
        }
    }

    ColumnLayout {
        anchors.centerIn: parent
        spacing: units.gu(1)
        RowLayout {
            UITK.TextField {
                id: labelDB
                enabled: false
                text: settings.db_path
                Layout.fillWidth: true
            }

            UITK.Button {
                id: pickDB
                text: "Pick DB"
                onClicked: {
                    peerPicker.visible = true
                    pickingDB = true
                    // stack push
                }
            }
        }
        RowLayout {
            UITK.TextField {
                id: labelKey
                enabled: false
                text: settings.key_path
                Layout.fillWidth: true
            }

            UITK.Button {

                id: pickKey
                text: "Pick Key"
                onClicked: {
                    pickingDB = false
                    peerPicker.visible = true
                    // stack push
                }
            }
        }

        UITK.TextField {
            id: password
            enabled: true
            text: 'somePassw0rd'
            placeholderText: "Password"
            echoMode: TextInput.Password
            Layout.fillWidth: true
        }
        UITK.Button {
            Layout.fillWidth: true
            id: openDB
            enabled: false
            text: "Open DB"
            onClicked: {
                python.call('kp.open_db', [password.text])
            }
        }
    }
    Python {
        id: python
        Component.onCompleted: {
            addImportPath(Qt.resolvedUrl('../../src/'))
            setHandler('config', function (config) {
                settings = config
                console.log('New config', JSON.stringify(config, null, 2))
                // FIXME:
                python.call('kp.open_db', [password.text])
            })
            setHandler('db_open', function () {
                page.push_entries()
            })
            importModule('kp', function () {
                openDB.enabled = true
            })
        }
    }
}

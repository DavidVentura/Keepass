import Ubuntu.Components 1.3 as UITK
import Ubuntu.Components.Popups 1.3 as UC
import Ubuntu.Content 1.3 as ContentHub
import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12
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
        property bool showSlowDBWarning: true
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
                    const is_armv7 = python.call_sync('kp.is_armv7')
                    const is_db_v3 = python.call_sync('kp.is_db_v3', [filePath])
                    if (is_armv7 && is_db_v3 && settings.value(
                                'showSlowDBWarning', true)) {
                        PopupUtils.open(cpu_version_component)
                    }
                } else {
                    settings.lastKey = path
                }
                stack.pop()
            })
        }
    }

    Timer {
        interval: 2000
        running: settings.autoCloseInterval > 0
        repeat: true
        onTriggered: {
            const now = new Date().getTime()
            if (lastHeartbeat === 0) {
                lastHeartbeat = now
            }

            const delta = now - lastHeartbeat
            lastHeartbeat = now
            if (stack.depth > 1
                    && delta >= settings.autoCloseInterval * 60 * 1000) {
                stack.pop(null)
            }
        }
    }

    ColumnLayout {
        anchors.left: parent.left
        anchors.right: parent.right

        anchors.leftMargin: units.gu(7)
        anchors.rightMargin: units.gu(7)
        anchors.verticalCenter: parent.verticalCenter
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
                // TRANSLATORS: DB is the abbreviation for database
                text: i18n.tr("Pick DB")
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
                text: i18n.tr("Pick Key")
                onClicked: {
                    pickingDB = false
                    stack.push(peerPicker)
                    busy = false
                    errorMsg = ''
                }
            }
            UITK.Button {
                visible: settings.lastKey
                text: i18n.tr("Clear Key")
                onClicked: {
                    settings.lastKey = ''
                }
            }
        }

        UITK.TextField {
            id: password
            enabled: true
            text: ''
            placeholderText: i18n.tr("Password")
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
            // TRANSLATORS: DB is the abbreviation for database
            text: i18n.tr("Open DB")
            onClicked: open_db()
        }
        UITK.ActivityIndicator {
            Layout.fillWidth: true
            running: busy
            visible: busy
        }
        UITK.Label {
            Layout.fillWidth: true
            text: parseErrorMessages(errorMsg)
            wrapMode: Text.WordWrap
        }
    }

    Component {
        id: cpu_version_component
        UC.Dialog {
            id: cpu_version_popup
            title: "Database version compatibility"
            modal: true
            text: i18n.tr(
                      "You are running on an ARMv7 device in which databases version 3 (kdbx3) are <b>extremely</b> slow.<br/>For your sanity, make sure your database is version 4 (kdbx4)")

            UITK.Button {
                text: "Ok"
                onClicked: {
                    PopupUtils.close(cpu_version_popup)
                }
            }
        }
    }

    function open_db() {

        busy = true
        python.call('kp.open_db',
                    [settings.lastDB, settings.lastKey, password.text])
    }

    //try to give a userfriendly feedback if a known error message does occur
    function parseErrorMessages(message) {
        // error message for wrong password, first string for KDBX3.1 version, second string for KDBX4.0 version
        if (message === "KDBX error: Database integrity error: Cryptography error: BlockMode { e: BlockModeError }" || message === "KDBX error: Incorrect key specified") {
            message = i18n.ctr("error message when wrong password is entered","wrong password, please try again")
        }
        return message
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

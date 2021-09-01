import QtQuick 2.0
import Ubuntu.Components 1.3 as UITK
import "../components"
import Qt.labs.settings 1.0

UITK.Page {

    header: UITK.PageHeader {
        id: header
        title: "Settings"
    }
    Flickable {
        id: flick
        anchors.top: header.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.topMargin: units.gu(2)
        contentHeight: col.height
        contentWidth: width
        Column {
            Settings {
                id: settings
                property bool fetchOnOpen: false
                property int autoCloseInterval: 15
                property bool tapToReveal: true
            }
            id: col
            anchors.fill: parent
            spacing: units.gu(2)
            SettingsItem {
                title: 'Download icons'
                description: 'Download page icons on database open'
                control: UITK.Switch {
                    onCheckedChanged: settings.fetchOnOpen = checked
                    checked: settings.fetchOnOpen
                }
            }
            SettingsItem {
                title: 'Tap on entries to reveal password'
                description: 'They will stay on screen for one second'
                control: UITK.Switch {
                    onCheckedChanged: settings.tapToReveal = checked
                    checked: settings.tapToReveal
                }
            }

            SettingsItem {
                title: 'Auto-close db after inactivity'
                description: 'In minutes. 0 for disabled.'
                control: UITK.TextField {
                    inputMethodHints: Qt.ImhDigitsOnly
                    text: settings.autoCloseInterval
                    onTextChanged: {
                        if (isNaN(parseInt(text))) {
                            text = 1
                        }
                        if (parseInt(text) < 0) {
                            text = 1
                        }
                        if (parseInt(text) > 100) {
                            text = 100
                        }

                        settings.autoCloseInterval = parseInt(text)
                    }
                    hasClearButton: false
                    validator: IntValidator {
                        bottom: 0
                        top: 100
                    }
                }
            }
        }
    }
}

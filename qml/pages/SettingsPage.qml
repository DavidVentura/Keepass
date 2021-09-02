import QtQuick 2.0
import Ubuntu.Components 1.3 as UITK
import "../components"
import Qt.labs.settings 1.0

UITK.Page {

    header: UITK.PageHeader {
        id: header
        title: i18n.ctr("page header", "Settings")
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
                property bool showRecycleBin: false
                property bool changeGroupOnSearch: true
            }
            id: col
            anchors.fill: parent
            spacing: units.gu(2)
            SettingsItem {
                title: i18n.ctr("download icon setting", "Download icons")
                description: i18n.ctr("description for icon download setting",
                                      "Download page icons on database open")
                control: UITK.Switch {
                    onCheckedChanged: settings.fetchOnOpen = checked
                    checked: settings.fetchOnOpen
                }
            }
            SettingsItem {
                title: i18n.ctr("tap to reveal passwort setting",
                                "Tap on entries to reveal password")
                description: i18n.ctr(
                                 "description for tap to reveal passwort setting",
                                 "They will stay on screen for one second")
                control: UITK.Switch {
                    onCheckedChanged: settings.tapToReveal = checked
                    checked: settings.tapToReveal
                }
            }

            SettingsItem {
                // TRANSLATORS: DB is the abbreviation for database
                title: i18n.ctr("auto-close time for database setting",
                                "Auto-close db after inactivity")
                description: i18n.ctr("description for auto-close setting",
                                      "In minutes. 0 for disabled.")
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
            SettingsItem {
                title: i18n.ctr("show recycle-bin setting",
                                'Show the "Recycle bin" group')
                description: i18n.ctr(
                                 "description for show recycle-bin setting",
                                 'This group contains all the deleted entries')
                control: UITK.Switch {
                    onCheckedChanged: settings.showRecycleBin = checked
                    checked: settings.showRecycleBin
                }
            }
            SettingsItem {
                title: i18n.ctr("change section on search setting",
                                'Change section on search')
                description: i18n.ctr(
                                 "description for change section on search setting",
                                 'Change section automatically if there are no results for the \
search value in the current section, and there are results in another section')
                control: UITK.Switch {
                    onCheckedChanged: settings.changeGroupOnSearch = checked
                    checked: settings.changeGroupOnSearch
                }
            }
        }
    }
}

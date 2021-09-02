import QtQuick 2.12
import QtQuick.Controls 2.12
import io.thp.pyotherside 1.3
import Ubuntu.Components 1.3 as UITK
import Qt.labs.settings 1.0

import "../components"

UITK.Page {
    Settings {
        id: settings
        property bool fetchOnOpen: false
        property bool tapToReveal: true
        property bool showRecycleBin: false
    }
    property bool searchMode: false
    header: UITK.PageHeader {
        id: header
        z: 2
        contents: Item {
            anchors.fill: parent

            UITK.TextField {
                visible: searchMode
                id: searchField
                placeholderText: i18n.ctr("text for search placeholder",
                                          "Search")
                anchors.fill: parent
                anchors.topMargin: units.gu(1)
                anchors.bottomMargin: units.gu(1)
                text: ''
                Keys.onReturnPressed: {
                    get_entries()
                }
                onTextChanged: {
                    searchTimer.restart()
                }
            }
            UITK.Label {
                visible: !searchMode
                anchors.fill: parent
                verticalAlignment: Qt.AlignVCenter
                text: i18n.tr("Passwords")
            }
            Timer {
                id: searchTimer
                interval: 100
                repeat: false
                onTriggered: {
                    get_entries()
                }
            }
        }
        trailingActionBar.actions: [
            UITK.Action {
                iconName: "find"
                text: i18n.tr("Search")
                onTriggered: {
                    if (searchMode) {
                        get_entries()
                    } else {
                        searchField.forceActiveFocus()
                    }

                    searchMode = !searchMode
                }
            }
        ]
    }

    id: sectionFlickable
    UITK.Sections {
        z: 3
        anchors.top: header.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        id: sections
        model: []
        onSelectedIndexChanged: {
            get_entries()
        }

        onImplicitWidthChanged: {

            // Can't get this to center without screwing up for longer content
            //            if (implicitWidth >= parent.width) {
            //                anchors.left = parent.left
            //                anchors.right = parent.right
            //            } else {
            //                anchors.left = undefined
            //                anchors.right = undefined
            //                x = parent.width / 2 - implicitWidth / 2
            //            }
        }
    }
    Rectangle {
        z: 2
        anchors.top: sections.top
        anchors.bottom: sections.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        color: theme.palette.normal.background
    }

    ListView {
        z: 1
        anchors.top: sections.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        spacing: units.gu(0.1)

        id: lv
        model: ListModel {
            id: listmodel
        }

        delegate: DBEntry {}
    }
    Popup {
        id: toast
        padding: units.dp(12)

        x: parent.width / 2 - width / 2
        y: parent.height - height - units.dp(20)

        background: Rectangle {
            color: "#111111"
            opacity: 0.7
            radius: units.dp(10)
        }

        Text {
            id: popupLabel
            anchors.fill: parent
            horizontalAlignment: Text.AlignHCenter
            color: "#ffffff"
            font.pixelSize: units.dp(14)
        }

        Timer {
            id: popupTimer
            interval: 2000
            running: true
            onTriggered: {
                toast.close()
            }
        }

        function show(text) {
            popupLabel.text = text
            open()
            popupTimer.start()
        }
    }

    function populate() {
        python.call('kp.get_groups', [settings.showRecycleBin],
                    function (_groups) {
                        sections.model = _groups
                        const crappy_data = ["ea", "nostrud", "qui", "incididunt", "qui", "nulla", "adipisicing", "irure", "mollit", "do", "id", "nostrud", "do", "ea", "occaecat", "amet", "do"]
                        //            sections.model = crappy_data
                        get_entries()
                    })
    }
    function get_entries() {
        const group = sections.model[sections.selectedIndex]
        python.call('kp.get_entries', [group, searchField.text || ''],
                    function (items) {
                        listmodel.clear()
                        for (var i = 0; i < items.length; i++) {
                            const item = items[i]
                            listmodel.append(item)
                        }
                    })
    }

    Python {
        id: python
        Component.onCompleted: {
            addImportPath(Qt.resolvedUrl('../../src/'))
            importModule('kp', function () {
                if (settings.fetchOnOpen) {
                    python.call('kp.fetch_all_icons')
                }
            })
        }
    }
    Component.onCompleted: populate()
}

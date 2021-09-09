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
        property bool changeGroupOnSearch: true
    }
    property bool searchMode: true
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
                inputMethodHints: Qt.ImhNoPredictiveText
                onTextChanged: {
                    get_entries()
                }
            }
            UITK.Label {
                visible: !searchMode
                anchors.fill: parent
                verticalAlignment: Qt.AlignVCenter
                text: i18n.tr("Passwords")
            }
        }
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
        python.call('kp.get_entries', [searchField.text || ''],
                    function (items) {
                        listmodel.clear()
                        let entries = items[group] || []

                        if (settings.changeGroupOnSearch && !entries.length) {
                            const keys = Object.keys(items)
                            if (keys.length) {
                                sections.selectedIndex = sections.model.indexOf(
                                            keys[0])
                                return
                            }
                        }

                        for (var i = 0; i < entries.length; i++) {
                            const item = entries[i]
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

import QtQuick 2.12
import QtQuick.Controls 2.12
import io.thp.pyotherside 1.3
import Ubuntu.Components 1.3 as UITK

import "../components"

UITK.Page {
    Flickable {
        leftMargin: (parent.width / 2 - sections.width / 2)
                    > 0 ? (parent.width / 2 - sections.width / 2) : 0
        width: parent.width
        height: sections.height
        contentWidth: sections.width
        contentHeight: sections.height
        boundsBehavior: Flickable.StopAtBounds
        id: sectionFlickable
        UITK.Sections {
            anchors.top: parent.top
            x: parent.width / 2 - width / 2
            id: sections
            model: []
            onSelectedIndexChanged: {
                get_entries(model[selectedIndex])
            }
        }
    }

    ListView {
        anchors.top: sectionFlickable.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        spacing: units.gu(1)

        id: lv
        model: ListModel {
            id: listmodel
        }

        delegate: DBEntry {}
    }

    function populate() {
        python.call('kp.get_groups', [], function (_groups) {
            sections.model = _groups
            const crappy_data = ["ea", "nostrud", "qui", "incididunt", "qui", "nulla", "adipisicing", "irure", "mollit", "do", "id", "nostrud", "do", "ea", "occaecat", "amet", "do"]
            //            sections.model = crappy_data
            get_entries(_groups[0])
        })
    }
    function get_entries(group) {
        python.call('kp.get_entries', [group], function (items) {
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
            //            importModule('kp', function () {})
        }
    }
    Component.onCompleted: populate()
}

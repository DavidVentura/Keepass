import QtQuick 2.0
import io.thp.pyotherside 1.3
import "../components"

Item {
    anchors.fill: parent
    ListView {
        spacing: units.gu(1)

        id: lv
        model: ListModel {
            id: listmodel
        }

        anchors.fill: parent
        delegate: DBEntry {}
    }

    function populate() {
        python.call('kp.get_entries', [], function (items) {
            for (var i = 0; i < items.length; i++) {
                const item = items[i]
                console.log(JSON.stringify(item, null, 2))
                listmodel.append(item)
            }
        })
    }

    Python {
        id: python
        Component.onCompleted: {
            addImportPath(Qt.resolvedUrl('../../src/'))
            importModule('kp', function () {})
        }
    }
}

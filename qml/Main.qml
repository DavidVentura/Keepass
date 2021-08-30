

/*
 * Copyright (C) 2021  David Ventura
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; version 3.
 *
 * Keepass is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */
import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.3
import Ubuntu.Components 1.3 as UITK

import "./pages"

UITK.MainView {
    id: root
    objectName: 'mainView'
    applicationName: 'keepass.davidv.dev'
    automaticOrientation: true

    width: units.gu(45)
    height: units.gu(75)
    OpenDBPage {
        visible: false
        id: opendbPage
    }
    UITK.PageStack {
        id: stack
    }

    SettingsPage {
        visible: false
        id: settingsPage
    }

    function push_entries() {
        stack.push(Qt.resolvedUrl("pages/EntriesPage.qml"))
    }
    Component.onCompleted: stack.push(opendbPage)
}

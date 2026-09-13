/*
    Astryon / Stratara System Settings frontend.
    Based on KDE System Settings QML frontend.
    SPDX-License-Identifier: LGPL-2.0-or-later
*/

import QtQuick
import org.kde.kirigami as Kirigami

Item {
    id: root

    readonly property real headerHeight: sideBar.headerHeight

    implicitHeight: sideBar.implicitHeight
    implicitWidth: sideBar.implicitWidth + separator.implicitWidth

    Rectangle {
        anchors.fill: parent
        color: "#000000"
    }

    SideBarItem {
        id: sideBar
        anchors.fill: parent
        anchors.rightMargin: separator.width
    }

    Rectangle {
        id: separator
        anchors {
            top: parent.top
            right: parent.right
            bottom: parent.bottom
        }
        width: 1
        color: "#2b2b31"
        opacity: 0.85
    }

    Rectangle {
        anchors {
            top: parent.top
            right: separator.left
            left: parent.left
        }
        height: sideBar.headerHeight
        color: "#09090d"
        opacity: 0.98
        z: -1
    }
}

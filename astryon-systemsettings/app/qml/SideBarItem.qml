/*
    Astryon / Stratara System Settings frontend.
    SPDX-License-Identifier: LGPL-2.0-or-later
*/

import QtQuick
import org.kde.kirigami as Kirigami

Kirigami.ApplicationItem {
    id: root

    implicitWidth: wideScreen
        ? Kirigami.Units.gridUnit * 34
        : Kirigami.Units.gridUnit * 24

    wideScreen: pageStack.depth > 1
        && systemsettings.width > Kirigami.Units.gridUnit * 70

    pageStack.initialPage: mainColumn
    pageStack.defaultColumnWidth: wideScreen ? root.width / 2 : root.width

    property alias searchMode: mainColumn.searchMode
    readonly property real headerHeight: mainColumn.header.height

    Kirigami.Theme.colorSet: Kirigami.Theme.View
    Kirigami.Theme.inherit: false
    Kirigami.Theme.backgroundColor: "#000000"
    Kirigami.Theme.textColor: "#f4f4f5"
    Kirigami.Theme.disabledTextColor: "#6f7078"
    Kirigami.Theme.highlightColor: "#ffffff"
    Kirigami.Theme.highlightedTextColor: "#050507"

    CategoriesPage {
        id: mainColumn
        focus: true
    }

    SubCategoryPage {
        id: subCategoryColumn
        enabled: pageStack.visibleItems.includes(subCategoryColumn)
    }
}

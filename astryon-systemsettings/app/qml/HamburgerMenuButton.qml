/*
    Astryon / Stratara System Settings frontend.
    SPDX-License-Identifier: LGPL-2.0-or-later
*/

import QtQuick
import QtQuick.Controls as QQC2
import org.kde.kirigami as Kirigami
import org.kde.systemsettings

QQC2.ToolButton {
    icon.name: "application-menu"
    checkable: true
    checked: systemsettings.actionMenuVisible
    visible: false

    onToggled: {
        if (checked) {
            systemsettings.showActionMenu(mapToGlobal(0, height));
        }
    }

    Accessible.role: Accessible.ButtonMenu
    Accessible.name: i18n("Show menu")
}

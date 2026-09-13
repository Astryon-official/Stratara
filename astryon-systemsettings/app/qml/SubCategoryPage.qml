/*
    Astryon / Stratara System Settings frontend.
    SPDX-License-Identifier: LGPL-2.0-or-later
*/

pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts

import org.kde.kirigami as Kirigami
import org.kde.systemsettings

Kirigami.ScrollablePage {
    id: subCategoryColumn

    title: systemsettings.subCategoryModel.title

    background: Rectangle {
        color: "#000000"
    }

    header: Item {
        implicitHeight: 78

        Rectangle {
            anchors.fill: parent
            color: "#09090d"
            opacity: 0.98
        }

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 20
            anchors.rightMargin: 20
            spacing: 12

            QQC2.ToolButton {
                id: backButton
                visible: !applicationWindow().wideScreen

                implicitWidth: 42
                implicitHeight: 42

                contentItem: Kirigami.Icon {
                    source: LayoutMirroring.enabled
                        ? "go-previous-symbolic-rtl"
                        : "go-previous-symbolic"
                    color: "#dedee2"
                }

                background: Rectangle {
                    radius: 12
                    color: hovered ? "#222229" : "#15151a"
                    border.width: hovered ? 1 : 0
                    border.color: "#3b3c44"
                }

                onClicked: root.pageStack.currentIndex = 0
            }

            Kirigami.Heading {
                Layout.fillWidth: true
                text: subCategoryColumn.title
                level: 2
                color: "#f5f5f7"
                font.family: "Montserrat"
                font.weight: Font.DemiBold
                elide: Text.ElideRight
            }
        }
    }

    ListView {
        id: subCategoryView

        anchors.fill: parent
        topMargin: 18
        bottomMargin: 18

        model: systemsettings.subCategoryModel
        currentIndex: systemsettings.activeSubCategoryRow

        activeFocusOnTab: true
        keyNavigationWraps: true
        Accessible.role: Accessible.List

        Keys.onUpPressed: event => {
            if (subCategoryView.currentIndex === 0) {
                subCategoryView.currentIndex = -1;
            }
            event.accepted = false;
        }

        Keys.onTabPressed: {
            systemsettings.focusNext();
        }

        onCountChanged: {
            if (count > 1) {
                if (root.pageStack.depth < 2) {
                    root.pageStack.push(subCategoryColumn);
                }
            } else {
                root.pageStack.pop(mainColumn)
            }
        }

        Connections {
            target: systemsettings

            function onActiveSubCategoryRowChanged() {
                subCategoryView.currentIndex = systemsettings.activeSubCategoryRow

                if (systemsettings.activeSubCategoryRow >= 0) {
                    if (subCategoryView.count > 1) {
                        subCategoryView.forceActiveFocus()
                    }
                    root.pageStack.currentIndex = 1
                } else if (root.pageStack.currentIndex > 0) {
                    root.pageStack.currentIndex = 0
                    if (root.pageStack.depth > 1) {
                        root.pageStack.pop()
                    }
                }
            }
        }

        delegate: CategoryItem {
            id: delegate

            required property int index
            required property var model
            required property int depth
            required property string iconName

            text: model.display
            icon.name: model.iconName

            leadingPadding: depth > 2
                ? ((depth - 2) * Kirigami.Units.iconSizes.smallMedium)
                    + Kirigami.Units.largeSpacing
                : 0

            highlighted: ListView.isCurrentItem

            onClicked: {
                systemsettings.loadModule(subCategoryView.model.index(index, 0));
            }

            onFocusChanged: {
                if (focus) {
                    subCategoryView.positionViewAtIndex(index, ListView.Contain);
                }
            }

            Keys.onEnterPressed: clicked()
            Keys.onReturnPressed: clicked()

            Keys.onEscapePressed: root.pageStack.currentIndex = 0

            Keys.onLeftPressed: {
                if (LayoutMirroring.enabled) {
                    clicked();
                } else {
                    root.pageStack.currentIndex = 0;
                }
            }

            Keys.onRightPressed: {
                if (!LayoutMirroring.enabled) {
                    clicked();
                } else {
                    root.pageStack.currentIndex = 0;
                }
            }
        }
    }
}

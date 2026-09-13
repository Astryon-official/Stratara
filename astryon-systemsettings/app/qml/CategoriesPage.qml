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
    id: mainColumn

    readonly property bool searchMode: searchField.text.length > 0

    Kirigami.Theme.colorSet: Kirigami.Theme.View
    Kirigami.Theme.inherit: false

    background: Rectangle {
        color: "#000000"
    }

    header: Item {
        id: pageHeader
        implicitHeight: 98

        Rectangle {
            anchors.fill: parent
            color: "#09090d"
            opacity: 0.98
        }

        Rectangle {
            anchors {
                left: parent.left
                right: parent.right
                bottom: parent.bottom
            }
            height: 1
            color: "#292a31"
        }

        ColumnLayout {
            anchors {
                left: parent.left
                right: parent.right
                verticalCenter: parent.verticalCenter
                leftMargin: 28
                rightMargin: 24
            }
            spacing: 10

            RowLayout {
                Layout.fillWidth: true
                spacing: 10

                Kirigami.Heading {
                    text: i18n("Settings")
                    level: 2
                    color: "#f5f5f7"
                    font.family: "Montserrat"
                    font.weight: Font.DemiBold
                    Layout.fillWidth: true
                }

                QQC2.Label {
                    text: i18n("Stratara")
                    color: "#777982"
                    font.family: "Montserrat"
                    font.pixelSize: 13
                }
            }

            QQC2.TextField {
                id: searchField
                Layout.fillWidth: true
                Layout.preferredHeight: 42

                placeholderText: i18n("Search settings")
                font.family: "Montserrat"
                font.pixelSize: 13
                color: "#f4f4f5"
                placeholderTextColor: "#73747c"
                selectionColor: "#e8e8ea"
                selectedTextColor: "#111114"

                background: Rectangle {
                    radius: 12
                    color: "#15151a"
                    border.width: searchField.activeFocus ? 1 : 0
                    border.color: "#555761"
                }

                leftPadding: 14
                rightPadding: 14

                onTextChanged: {
                    systemsettings.searchModel.filterRegExp = text;
                }

                KeyNavigation.down: categoryView
                KeyNavigation.right: hamburgerMenuButton
                Keys.onDownPressed: {
                    categoryView.currentIndex = 0;
                }

                onActiveFocusChanged: {
                    if (activeFocus) {
                        systemsettings.giveFocus();
                    }
                }
            }
        }

        HamburgerMenuButton {
            id: hamburgerMenuButton
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.topMargin: 18
            anchors.rightMargin: 18
            visible: false
        }
    }

    property Item __placeholder: Loader {
        parent: mainColumn
        anchors.centerIn: parent
        width: parent.width - 56
        opacity: categoryView.count === 0 ? 1 : 0
        active: opacity > 0
        visible: active

        Behavior on opacity {
            NumberAnimation {
                duration: 180
                easing.type: Easing.InOutQuad
            }
        }

        sourceComponent: Kirigami.PlaceholderMessage {
            width: parent.width
            icon.name: "edit-none"
            text: i18nc("A search yielded no results", "No items matching your search")
        }
    }

    Binding {
        target: categoryView
        property: "currentIndex"
        value: mainColumn.searchMode
            ? systemsettings.activeSearchRow
            : systemsettings.activeCategoryRow
    }

    ListView {
        id: categoryView

        model: mainColumn.searchMode
            ? systemsettings.searchModel
            : systemsettings.categoryModel

        anchors {
            left: parent.left
            right: parent.right
        }

        topMargin: 22
        bottomMargin: 22

        activeFocusOnTab: true
        keyNavigationWraps: true
        Accessible.role: Accessible.List

        KeyNavigation.up: searchField
        Keys.onUpPressed: event => {
            if (categoryView.currentIndex === 0) {
                categoryView.currentIndex = -1;
            }
            event.accepted = false;
        }

        Keys.onTabPressed: {
            systemsettings.focusNext();
        }

        section {
            property: "categoryDisplayRole"

            delegate: Item {
                width: ListView.view.width
                height: 34

                required property string section

                QQC2.Label {
                    anchors {
                        left: parent.left
                        leftMargin: 28
                        bottom: parent.bottom
                    }
                    text: parent.section
                    color: "#666871"
                    font.family: "Montserrat"
                    font.pixelSize: 11
                    font.weight: Font.DemiBold
                    font.letterSpacing: 1.1
                }
            }
        }

        delegate: CategoryItem {
            id: delegate

            required property int index
            required property var model
            required property bool isCategory
            required property int depth
            required property bool isKCM
            required property string iconName

            width: ListView.view.width - 24
            x: 12

            text: model.display
            icon.name: iconName

            showArrow: {
                if (!isCategory) {
                    return false;
                }
                const modelIndex = delegate.ListView.view.model.index(index, 0)
                return delegate.ListView.view.model.rowCount(modelIndex) > 1
            }

            leadingPadding: (depth > 1 && searchField.text.length > 0)
                ? ((depth - 1) * Kirigami.Units.iconSizes.smallMedium)
                  + Kirigami.Units.largeSpacing
                : 0

            hoverEnabled: !isCategory || !mainColumn.searchMode
            enabled: true
            highlighted: ListView.isCurrentItem

            onClicked: {
                if (!enabled) {
                    return;
                }

                if (isKCM || mainColumn.searchMode || isCategory) {
                    systemsettings.loadModule(categoryView.model.index(index, 0));
                }

                if (!mainColumn.searchMode && root.pageStack.depth > 1) {
                    root.pageStack.currentIndex = 1;
                }
            }

            onFocusChanged: {
                if (isCategory && mainColumn.searchMode) {
                    return;
                }
                if (focus) {
                    categoryView.positionViewAtIndex(index, ListView.Contain);
                }
            }

            Keys.onEnterPressed: clicked()
            Keys.onReturnPressed: clicked()

            Keys.onLeftPressed: {
                if (LayoutMirroring.enabled) {
                    clicked();
                }
            }

            Keys.onRightPressed: {
                if (!LayoutMirroring.enabled) {
                    clicked();
                }
            }
        }
    }
}

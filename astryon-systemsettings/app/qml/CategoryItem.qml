/*
    Astryon / Stratara System Settings frontend.
    SPDX-License-Identifier: LGPL-2.0-or-later
*/

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.kde.kirigami as Kirigami

ItemDelegate {
    id: delegate

    property bool showArrow: false
    property bool selected: delegate.highlighted || delegate.pressed
    property bool isSearching: false
    property real leadingPadding: 0

    required property bool showDefaultIndicator
    required property QtObject auxiliaryAction

    width: ListView.view?.width ?? 0
    height: 58

    Accessible.name: text
    Accessible.onPressAction: clicked()

    background: Rectangle {
        radius: 14
        color: delegate.selected
            ? "#24242b"
            : (delegate.hovered ? "#19191f" : "#0f0f13")

        border.width: delegate.selected ? 1 : 0
        border.color: "#3a3b44"

        Behavior on color {
            ColorAnimation {
                duration: 110
            }
        }

        Behavior on border.color {
            ColorAnimation {
                duration: 110
            }
        }
    }

    contentItem: RowLayout {
        anchors.fill: parent
        spacing: 12

        Kirigami.Icon {
            id: itemIcon

            Layout.leftMargin: 16 + delegate.leadingPadding
            Layout.preferredWidth: 24
            Layout.preferredHeight: 24

            source: icon.fromControlsIcon(delegate.icon)
            color: delegate.selected ? "#ffffff" : "#a7a8b0"
            selected: delegate.selected
        }

        Label {
            Layout.fillWidth: true
            text: delegate.text
            color: delegate.selected ? "#ffffff" : "#dedee2"

            font.family: "Montserrat"
            font.pixelSize: 13
            font.weight: delegate.selected ? Font.DemiBold : Font.Medium
            elide: Text.ElideRight
            verticalAlignment: Text.AlignVCenter
        }

        Kirigami.Badge {
            Layout.alignment: Qt.AlignVCenter
            Layout.preferredWidth: Kirigami.Units.largeSpacing
            Layout.preferredHeight: Kirigami.Units.largeSpacing

            visible: delegate.showDefaultIndicator
                && systemsettings.defaultsIndicatorsVisible

            type: Kirigami.Badge.Type.Warning
        }

        Component {
            id: auxiliaryButtonActionComponent

            ToolButton {
                implicitWidth: height
                implicitHeight: 32
                icon.color: delegate.selected || pressed || visualFocus
                    ? "#ffffff"
                    : "#9a9ba3"
                display: AbstractButton.IconOnly
                text: delegate.auxiliaryAction.text
                icon.name: systemsettings.actionIconName(delegate.auxiliaryAction)

                onClicked: delegate.auxiliaryAction.trigger()
            }
        }

        Component {
            id: auxiliarySwitchActionComponent

            Switch {
                Accessible.name: delegate.auxiliaryAction.text
                checked: delegate.auxiliaryAction.checked
                onToggled: delegate.auxiliaryAction.trigger()
            }
        }

        Loader {
            Layout.fillHeight: true
            Layout.topMargin: -delegate.topPadding + delegate.topInset
            Layout.bottomMargin: -delegate.bottomPadding + delegate.bottomInset
            Layout.rightMargin: -delegate.rightPadding + delegate.rightInset

            enabled: delegate.auxiliaryAction?.enabled ?? false
            visible: status === Loader.Ready

            sourceComponent: {
                const action = delegate.auxiliaryAction;

                if (action && action.visible) {
                    return action.checkable
                        ? auxiliarySwitchActionComponent
                        : auxiliaryButtonActionComponent;
                }

                return null;
            }
        }

        Kirigami.Icon {
            Layout.rightMargin: 14
            Layout.alignment: Qt.AlignVCenter
            Layout.preferredWidth: 16
            Layout.preferredHeight: 16

            opacity: delegate.showArrow ? 0.65 : 0
            source: LayoutMirroring.enabled
                ? "go-next-symbolic-rtl"
                : "go-next-symbolic"
            color: "#a9aab2"
            selected: delegate.selected

            visible: !delegate.auxiliaryAction?.visible ?? true
        }
    }
}

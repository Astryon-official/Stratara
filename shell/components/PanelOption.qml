import QtQuick

Item {
    property string regularFont: ""
    property string mediumFont: ""

        property string title: ""
        property string subtitle: ""

        property bool focused: false
        property bool hovered: false

        property bool enabledState: true

        signal clicked()

        Rectangle {
            anchors.fill: parent

            radius: 16

            color:
            hovered || focused
            ? "#29292f"
            : "#17171d"

            border.width: 1

            border.color:
            hovered || focused
            ? "#5a5a66"
            : "#292930"

            opacity:
            enabledState
            ? 1.0
            : 0.65

            Behavior on color {
                ColorAnimation {
                    duration: 120
                }
            }

            Behavior on border.color {
                ColorAnimation {
                    duration: 120
                }
            }
        }

        Column {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter

            anchors.leftMargin: 16
            anchors.rightMargin: 16

            spacing: 2

            Text {
                text: title

                color: "#f2f2f5"

		font.family: mediumFont
                font.pixelSize: 15
            }

            Text {
                width: parent.width

                text: subtitle

                color:
                hovered || focused
                ? "#c9c9d1"
                : "#92929c"

		font.family: regularFont
                font.pixelSize: 13

                elide: Text.ElideRight
            }
        }

        MouseArea {
            anchors.fill: parent

            hoverEnabled: true

            enabled: parent.enabledState

            onEntered:
            parent.hovered = true

            onExited:
            parent.hovered = false

            onClicked:
            parent.clicked()
        }
    }


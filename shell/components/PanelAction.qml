import QtQuick

Item {
    property string mediumFont: ""

    property string title: ""

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
        : "#1b1b21"

        border.width: 1

        border.color:
        hovered || focused
        ? "#5a5a66"
        : "#2b2b32"

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

    Text {
        anchors.centerIn: parent

        text: title

        color:
        enabledState
        ? "#f2f2f5"
        : "#6d6d76"

        font.family: mediumFont
        font.pixelSize: 15
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

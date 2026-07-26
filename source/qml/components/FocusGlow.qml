import QtQuick

Rectangle {
    id: glow

    anchors.fill: parent

    radius: parent.radius

    color: "transparent"

    border.width: 3
    border.color: "#7CFF00"

    opacity: 0

    Behavior on opacity {
        NumberAnimation {
            duration: 250
        }
    }
}

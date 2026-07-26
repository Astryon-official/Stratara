import QtQuick
import QtQuick.Controls

Rectangle {
    id: tile

    property string title: "Astryon"
    property string icon: "★"

    width: 220
    height: 160

    radius: 20
    color: "#1c1c1c"

    scale: mouseArea.containsMouse ? 1.05 : 1.0

    Behavior on scale {
        NumberAnimation {
            duration: 150
        }
    }

    Column {
        anchors.centerIn: parent
        spacing: 15

        Text {
            text: tile.icon
            font.pixelSize: 45
            anchors.horizontalCenter: parent.horizontalCenter
        }

        Text {
            text: tile.title
            color: "white"
            font.pixelSize: 22
            anchors.horizontalCenter: parent.horizontalCenter
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
    }
}

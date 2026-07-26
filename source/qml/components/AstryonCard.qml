import QtQuick
import QtQuick.Controls

Rectangle {

    id: card


    property string title: "Astryon"
    property string subtitle: ""
    property string icon: "★"


    property bool selected: false


    width: 280
    height: 170


    radius: 24


    color: "#171717"


    scale: selected ? 1.08 : 1


    Behavior on scale {
        NumberAnimation {
            duration: 200
            easing.type: Easing.OutCubic
        }
    }


    Rectangle {

        anchors.fill: parent

        radius: parent.radius

        color: "#242424"

        opacity: selected ? 1 : 0


        Behavior on opacity {
            NumberAnimation {
                duration: 200
            }
        }
    }


    Column {

        anchors.centerIn: parent

        spacing: 12


        Text {

            text: card.icon

            font.pixelSize: 55

            anchors.horizontalCenter: parent.horizontalCenter
        }


        Text {

            text: card.title

            color: "white"

            font.pixelSize: 24

            anchors.horizontalCenter: parent.horizontalCenter
        }


        Text {

            text: card.subtitle

            color: "#AAAAAA"

            font.pixelSize: 14

            anchors.horizontalCenter: parent.horizontalCenter
        }
    }


    FocusGlow {}
}

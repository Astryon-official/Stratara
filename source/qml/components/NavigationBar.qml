import QtQuick


Rectangle {

    height: 70

    width: parent.width


    color: "transparent"


    Text {

        anchors.left: parent.left

        anchors.leftMargin: 50

        anchors.verticalCenter: parent.verticalCenter


        text: "ASTRYON"

        color: "white"

        font.pixelSize: 34

        font.bold: true
    }


    Text {

        anchors.right: parent.right

        anchors.rightMargin: 50

        anchors.verticalCenter: parent.verticalCenter


        text: "Home"

        color: "#AAAAAA"

        font.pixelSize: 20
    }
}

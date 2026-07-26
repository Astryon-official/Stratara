import QtQuick


Rectangle {

    property string icon: "★"


    width: 80
    height: 80


    radius: 20


    color: "#202020"


    Text {

        anchors.centerIn: parent

        text: icon

        font.pixelSize: 40
    }
}

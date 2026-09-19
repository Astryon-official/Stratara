import QtQuick

Item {
    property string title: ""
    property string subtitle: ""
    property int controllerIndex: -1
    property bool hovered: false

    property bool controllerActive: false
    property int controllerFocusIndex: -1
    property string regularFont: ""
    property string semiBoldFont: ""

    property bool controllerFocused:
        controllerActive &&
        controllerFocusIndex === controllerIndex

    signal cardClicked()

    scale: hovered || controllerFocused ? 1.035 : 1.0

    Behavior on scale {
        NumberAnimation {
            duration: 120
            easing.type: Easing.OutCubic
        }
    }

    Rectangle {
        anchors.fill: parent
        radius: 26
        color: "#101014"
        opacity: hovered || controllerFocused ? 0.98 : 0.90
        border.width: 1
        border.color: hovered || controllerFocused ? "#3b3b44" : "#29292f"
    }

    Rectangle {
        anchors.fill: parent
        radius: 26
        color: "#29292f"
        opacity: hovered || controllerFocused ? 0.32 : 0
    }

    Rectangle {
        anchors.fill: parent
        radius: 26
        color: "transparent"
        border.width: 1
        border.color: "#ffffff"
        opacity: hovered || controllerFocused ? 0.085 : 0.045
    }

    Column {
        anchors.left: parent.left
        anchors.bottom: parent.bottom
        anchors.leftMargin: 27
        anchors.bottomMargin: 25
        spacing: 7

        Text {
            text: title
            color: "white"
            font.family: semiBoldFont
            font.pixelSize: 25
        }

        Text {
            text: subtitle
            color: "#a4a4ae"
            font.family: regularFont
            font.pixelSize: 15
        }
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        onEntered: parent.hovered = true
        onExited: parent.hovered = false
        onClicked: parent.cardClicked()
    }
}

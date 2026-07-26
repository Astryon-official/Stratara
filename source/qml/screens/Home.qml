import QtQuick
import QtQuick.Controls

ApplicationWindow {
    visible: true
    width: 1280
    height: 720
    title: "Astryon Home"

    Rectangle {
        anchors.fill: parent
        color: "#111111"

        Column {
            anchors.centerIn: parent
            spacing: 20

            Label {
                text: "Astryon Home"
                font.pixelSize: 42
                horizontalAlignment: Text.AlignHCenter
            }

            Button { text: "🎮 Games" }
            Button { text: "📺 Live TV" }
            Button { text: "🎬 Streaming" }
            Button { text: "⚙ Settings" }
        }
    }
}

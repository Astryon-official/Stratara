import QtQuick
import QtQuick.Controls
import "../components"

ApplicationWindow {
    visible: true
    width: 1280
    height: 720
    title: "Astryon Home"

    color: "#0b0b0b"

    Column {
        anchors.centerIn: parent
        spacing: 40

        Text {
            text: "Astryon Home"
            color: "white"
            font.pixelSize: 50
            anchors.horizontalCenter: parent.horizontalCenter
        }

        Row {
            spacing: 30
            anchors.horizontalCenter: parent.horizontalCenter

            AstryonTile {
                title: "Games"
                icon: "🎮"
            }

            AstryonTile {
                title: "Live TV"
                icon: "📺"
            }

            AstryonTile {
                title: "Streaming"
                icon: "🎬"
            }
        }

        Row {
            spacing: 30
            anchors.horizontalCenter: parent.horizontalCenter

            AstryonTile {
                title: "Media"
                icon: "🎵"
            }

            AstryonTile {
                title: "Settings"
                icon: "⚙"
            }
        }
    }
}

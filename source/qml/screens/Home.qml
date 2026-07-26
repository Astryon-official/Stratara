import QtQuick
import QtQuick.Controls

import "../components"


ApplicationWindow {

    visible: true


    width: 1280
    height: 720


    title: "Astryon Home"


    color: "#050505"



    NavigationBar {}



    Column {


        anchors.centerIn: parent


        spacing: 50



        Text {

            text: "Welcome back"

            color: "white"

            font.pixelSize: 48

            font.bold: true
        }



        Row {


            spacing: 35



            AstryonCard {

                title:"Games"

                subtitle:"Play"

                icon:"🎮"

                selected:true
            }



            AstryonCard {

                title:"Live TV"

                subtitle:"Channels"

                icon:"📺"
            }



            AstryonCard {

                title:"Streaming"

                subtitle:"Movies & Shows"

                icon:"🎬"
            }
        }



        Row {


            spacing:35



            AstryonCard {

                title:"Media"

                subtitle:"Music"

                icon:"🎵"
            }



            AstryonCard {

                title:"Settings"

                subtitle:"System"

                icon:"⚙"
            }
        }
    }
}

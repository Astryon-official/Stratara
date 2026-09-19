import QtQuick

Item {
        id: button

        property string iconType: ""
        property string regularFont: ""
        property string semiBoldFont: ""
        property int controllerIndex: -1
        property bool hovered: false

        property bool controllerActive: false
        property int controllerFocusIndex: -1

        property bool controllerFocused:
        controllerActive &&
        controllerFocusIndex === controllerIndex

        signal buttonClicked()

        width: 85
        height: 60

        Rectangle {
            anchors.fill: parent

            radius: 0

            topLeftRadius:
            button.controllerIndex === 5 ? 20 : 0

            bottomLeftRadius:
            button.controllerIndex === 5 ? 20 : 0

            topRightRadius:
            button.controllerIndex === 8 ? 20 : 0

            bottomRightRadius:
            button.controllerIndex === 8 ? 20 : 0

            color:
            hovered || controllerFocused
            ? "#29292f"
            : "transparent"

            border.width:
            hovered || controllerFocused
            ? 1
            : 0

            border.color: "#3a3a42"

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

        // --------------------------------------------------------
        // SETTINGS — ACTUAL GEAR
        // --------------------------------------------------------

        Image {
            visible: button.iconType === "settings"
            anchors.centerIn: parent
            width: 32
            height: 32
	    source: "qrc:/Stratara/icons/settings.svg"
            fillMode: Image.PreserveAspectFit
            smooth: true
            mipmap: true
        }

        // --------------------------------------------------------
        // BLUETOOTH
        // --------------------------------------------------------

        Canvas {
            visible:
            button.iconType === "bluetooth"

            anchors.centerIn: parent

            width: 25
            height: 29

            onPaint: {
                var ctx = getContext("2d")

                ctx.clearRect(
                    0,
                    0,
                    width,
                    height
                )

                ctx.strokeStyle = "#f2f2f5"
                ctx.lineWidth = 2.4
                ctx.lineCap = "round"
                ctx.lineJoin = "round"

                var cx = width / 2

                ctx.beginPath()

                ctx.moveTo(cx, 2)
                ctx.lineTo(cx, 27)

                ctx.moveTo(cx, 2)
                ctx.lineTo(19, 8)
                ctx.lineTo(7, 18)

                ctx.moveTo(cx, 27)
                ctx.lineTo(19, 21)
                ctx.lineTo(7, 9)

                ctx.stroke()
            }
        }

        // --------------------------------------------------------
        // WI-FI
        // --------------------------------------------------------

        Canvas {
            visible:
            button.iconType === "wifi"

            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            anchors.verticalCenterOffset: -2

            width: 31
            height: 28

            onPaint: {
                var ctx = getContext("2d")

                ctx.clearRect(
                    0,
                    0,
                    width,
                    height
                )

                ctx.strokeStyle = "#f2f2f5"
                ctx.fillStyle = "#f2f2f5"

                ctx.lineWidth = 2.3
                ctx.lineCap = "round"

                var cx = width / 2
                var cy = height - 4

                ctx.beginPath()

                ctx.arc(
                    cx,
                    cy,
                    15,
                    Math.PI * 1.22,
                    Math.PI * 1.78
                )

                ctx.stroke()

                ctx.beginPath()

                ctx.arc(
                    cx,
                    cy,
                    10,
                    Math.PI * 1.22,
                    Math.PI * 1.78
                )

                ctx.stroke()

                ctx.beginPath()

                ctx.arc(
                    cx,
                    cy,
                    5,
                    Math.PI * 1.22,
                    Math.PI * 1.78
                )

                ctx.stroke()

                ctx.beginPath()

                ctx.arc(
                    cx,
                    cy,
                    2,
                    0,
                    Math.PI * 2
                )

                ctx.fill()
            }
        }

        // --------------------------------------------------------
        // POWER
        // --------------------------------------------------------

        Canvas {
            visible:
            button.iconType === "power"

            anchors.centerIn: parent

            width: 29
            height: 29

            onPaint: {
                var ctx = getContext("2d")

                ctx.clearRect(
                    0,
                    0,
                    width,
                    height
                )

                ctx.strokeStyle = "#f2f2f5"
                ctx.lineWidth = 2.6
                ctx.lineCap = "round"

                var cx = width / 2
                var cy = height / 2

                ctx.beginPath()

                ctx.moveTo(cx, 3)
                ctx.lineTo(cx, 13)

                ctx.stroke()

                ctx.beginPath()

                ctx.arc(
                    cx,
                    cy + 1,
                    10.5,
                    Math.PI * 1.75,
                    Math.PI * 3.25,
                    false
                )

                ctx.stroke()
            }
        }

        Rectangle {
            visible: button.controllerIndex !== 5

            anchors.left: parent.left
            anchors.top: parent.top
            anchors.bottom: parent.bottom

            width: 1

            color: "#24242b"
        }

        MouseArea {
            anchors.fill: parent

            hoverEnabled: true

            onEntered:
            button.hovered = true

            onExited:
            button.hovered = false

            onClicked:
            button.buttonClicked()
        }

        onButtonClicked: {
            if (button.iconType === "settings") {
                window.weatherOpen = false
                window.bluetoothOpen = false
                window.wifiOpen = false
                window.powerOpen = false

                if (typeof settingsLauncher !== "undefined")
                    settingsLauncher.open()

                    return
            }

            if (button.iconType === "bluetooth") {
                window.weatherOpen = false
                window.wifiOpen = false
                window.powerOpen = false

                window.bluetoothOpen =
                !window.bluetoothOpen

                return
            }

            if (button.iconType === "wifi") {
                window.weatherOpen = false
                window.bluetoothOpen = false
                window.powerOpen = false

                window.wifiOpen =
                !window.wifiOpen

                if (window.wifiOpen &&
                    typeof systemManager !== "undefined") {

                    systemManager.refreshWifi()
                    }

                    return
            }

            if (button.iconType === "power") {
                window.weatherOpen = false
                window.bluetoothOpen = false
                window.wifiOpen = false

                window.powerOpen =
                !window.powerOpen
            }
        }
    }

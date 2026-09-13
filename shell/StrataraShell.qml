import QtQuick
import QtQuick.Controls
import QtQuick.Window
import QtPositioning
import QtQuick.Shapes
import QtQuick.Layouts

ApplicationWindow {
    id: window

    visible: true
    visibility: Window.FullScreen
    color: "#000000"
    title: "Stratara"

    property bool weatherOpen: false
    property bool weatherLoaded: false
    property bool bluetoothOpen: false

    property int controllerFocusIndex: 0
    property bool controllerActive: false

    property real currentLatitude: -33.8688
    property real currentLongitude: 151.2093

    property string weatherLocation: "Current Location"
    property string weatherTemperature: "--°"
    property string weatherCondition: "Loading weather..."
    property string weatherRain: "--%"
    property string weatherWind: "-- km/h"
    property string weatherHumidity: "--%"
    property string weatherHigh: "--°"
    property string weatherLow: "--°"

    function moveControllerFocus(direction) {
        controllerActive = true

        if (direction === "left") {
            controllerFocusIndex = Math.max(0, controllerFocusIndex - 1)
        } else if (direction === "right") {
            controllerFocusIndex = Math.min(3, controllerFocusIndex + 1)
        } else if (direction === "down") {
            controllerFocusIndex = 4
        } else if (direction === "up" && controllerFocusIndex === 4) {
            controllerFocusIndex = 0
        }
    }

    function activateControllerFocus() {
        if (controllerFocusIndex === 4) {
            weatherOpen = true
            bluetoothOpen = false
            return
        }

        var card = exploreCards.children[controllerFocusIndex]

        if (card)
            card.cardClicked()
    }

    FontLoader {
        id: montserratRegular
        source: "file:///usr/share/fonts/TTF/Montserrat-Regular.ttf"
    }

    FontLoader {
        id: montserratMedium
        source: "file:///usr/share/fonts/TTF/Montserrat-Medium.ttf"
    }

    FontLoader {
        id: montserratSemiBold
        source: "file:///usr/share/fonts/TTF/Montserrat-SemiBold.ttf"
    }

    function weatherDescription(code) {
        if (code === 0)
            return "Clear sky"

            if (code === 1 || code === 2)
                return "Partly cloudy"

                if (code === 3)
                    return "Overcast"

                    if (code >= 45 && code <= 48)
                        return "Foggy"

                        if (code >= 51 && code <= 57)
                            return "Drizzle"

                            if (code >= 61 && code <= 67)
                                return "Rain"

                                if (code >= 71 && code <= 77)
                                    return "Snow"

                                    if (code >= 80 && code <= 82)
                                        return "Rain showers"

                                        if (code >= 85 && code <= 86)
                                            return "Snow showers"

                                            if (code >= 95 && code <= 99)
                                                return "Thunderstorm"

                                                return "Unknown"
    }

    function loadWeather() {
        var url =
        "https://api.open-meteo.com/v1/forecast" +
        "?latitude=" + window.currentLatitude +
        "&longitude=" + window.currentLongitude +
        "&current=temperature_2m,relative_humidity_2m,weather_code,wind_speed_10m" +
        "&daily=temperature_2m_max,temperature_2m_min,precipitation_probability_max" +
        "&timezone=auto"

        var xhr = new XMLHttpRequest()

        xhr.onreadystatechange = function() {
            if (xhr.readyState !== XMLHttpRequest.DONE)
                return

                if (xhr.status !== 200) {
                    window.weatherCondition = "Weather unavailable"
                    return
                }

                try {
                    var data = JSON.parse(xhr.responseText)

                    window.weatherTemperature =
                    Math.round(data.current.temperature_2m) + "°"

                    window.weatherHumidity =
                    Math.round(data.current.relative_humidity_2m) + "%"

                    window.weatherRain =
                    Math.round(data.daily.precipitation_probability_max[0]) + "%"

                    window.weatherWind =
                    Math.round(data.current.wind_speed_10m) + " km/h"

                    window.weatherHigh =
                    Math.round(data.daily.temperature_2m_max[0]) + "°"

                    window.weatherLow =
                    Math.round(data.daily.temperature_2m_min[0]) + "°"

                    window.weatherCondition =
                    window.weatherDescription(data.current.weather_code)

                    window.weatherLoaded = true
                } catch (error) {
                    window.weatherCondition = "Weather unavailable"
                }
        }

        xhr.open("GET", url)
        xhr.send()
    }

    PositionSource {
        id: positionSource

        active: true
        updateInterval: 120000

        onPositionChanged: {
            if (position && position.coordinate.isValid) {
                window.currentLatitude = position.coordinate.latitude
                window.currentLongitude = position.coordinate.longitude
                window.loadWeather()
            }
        }
    }

    Timer {
        interval: 30000
        running: !window.weatherLoaded
        repeat: false

        onTriggered: window.loadWeather()
    }

    Timer {
        interval: 900000
        running: true
        repeat: true

        onTriggered: window.loadWeather()
    }

    Shortcut {
        sequence: "Escape"

        onActivated: {
            if (window.weatherOpen) {
                window.weatherOpen = false
                return
            }

            if (window.bluetoothOpen) {
                window.bluetoothOpen = false
                return
            }
        }
    }

    /*
     * XBOX CONTROLLER CONNECTION
     */

    Connections {
        target: controllerManager

        function onControllerConnected(name) {
            window.controllerActive = true
            window.controllerFocusIndex = 0
        }

        function onControllerDisconnected() {
            window.controllerActive = false
        }

        function onActionPressed(action) {
            window.controllerActive = true

            if (action === "left" ||
                action === "right" ||
                action === "up" ||
                action === "down") {

                window.moveControllerFocus(action)

                } else if (action === "accept") {
                    window.activateControllerFocus()

                } else if (action === "cancel") {
                    window.weatherOpen = false
                    window.bluetoothOpen = false

                } else if (action === "guide") {
                    window.weatherOpen = false
                    window.bluetoothOpen = false
                    window.controllerFocusIndex = 0
                }
        }
    }

    /*
     * PURE BLACK BACKGROUND
     */

    Rectangle {
        anchors.fill: parent
        color: "#000000"
    }

    /*
     * HEADER
     */

    Text {
        id: strataraTitle

        anchors.top: parent.top
        anchors.left: parent.left

        anchors.topMargin: 42
        anchors.leftMargin: 58

        text: "STRATARA"

        color: "white"

        font.family: montserratSemiBold.name
        font.pixelSize: 30
        font.weight: Font.Normal
    }

    /*
     * EXPLORE
     */

    Column {
        id: exploreSection

        anchors.top: strataraTitle.bottom
        anchors.left: parent.left
        anchors.right: parent.right

        anchors.topMargin: 54
        anchors.leftMargin: 58
        anchors.rightMargin: 58

        spacing: 20

        Text {
            text: "Explore"

            color: "white"

            font.family: montserratSemiBold.name
            font.pixelSize: 28
            font.weight: Font.Normal
        }

        Row {
            id: exploreCards

            width: parent.width
            height: 225

            spacing: 18

            GlassCard {
                width: (exploreCards.width - 54) / 4
                height: parent.height

                title: "Streaming"
                subtitle: "Movies, shows and music"

                controllerIndex: 0

                onCardClicked: console.log("Streaming")
            }

            GlassCard {
                width: (exploreCards.width - 54) / 4
                height: parent.height

                title: "Games"
                subtitle: "Your games, all together"

                controllerIndex: 1

                onCardClicked: console.log("Games")
            }

            GlassCard {
                width: (exploreCards.width - 54) / 4
                height: parent.height

                title: "Apps"
                subtitle: "Everything you need"

                controllerIndex: 2

                onCardClicked: console.log("Apps")
            }

            GlassCard {
                width: (exploreCards.width - 54) / 4
                height: parent.height

                title: "Live TV"
                subtitle: "TV, channels and more"

                controllerIndex: 3

                onCardClicked: console.log("Live TV")
            }
        }
    }

    /*
     * WEATHER CARD
     */

    WeatherCard {
        id: weatherCard

        anchors.left: parent.left
        anchors.bottom: parent.bottom

        anchors.leftMargin: 58
        anchors.bottomMargin: 38

        width: 505
        height: 230
    }

    /*
     * SYSTEM BUTTONS
     */

    Row {
        id: systemButtons

        anchors.right: parent.right
        anchors.bottom: parent.bottom

        anchors.rightMargin: 58
        anchors.bottomMargin: 38

        spacing: 18

        SystemButton {
            iconType: "settings"
        }

        SystemButton {
            id: bluetoothSystemButton
            iconType: "bluetooth"
        }

        SystemButton {
            iconType: "wifi"
        }

        SystemButton {
            iconType: "power"
        }
    }

    /*
     * GLASS CARD
     */

    component GlassCard: Item {
        id: card

        property string title: ""
        property string subtitle: ""
        property bool hovered: false
        property int controllerIndex: -1

        property bool controllerFocused:
        window.controllerActive &&
        window.controllerFocusIndex === controllerIndex

        signal cardClicked()

        scale: (hovered || controllerFocused) ? 1.06 : 1.0

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

            opacity:
            (hovered || controllerFocused)
            ? 0.98
            : 0.90

            border.width: 1

            border.color:
            (hovered || controllerFocused)
            ? "#3b3b44"
            : "#29292f"
        }

        Rectangle {
            anchors.fill: parent

            radius: 26
            color: "#29292f"

            opacity:
            (hovered || controllerFocused)
            ? 0.32
            : 0.0

            Behavior on opacity {
                NumberAnimation {
                    duration: 120
                    easing.type: Easing.OutCubic
                }
            }
        }

        Rectangle {
            anchors.fill: parent

            radius: 26
            color: "transparent"

            border.width: 1
            border.color: "#ffffff"

            opacity:
            (hovered || controllerFocused)
            ? 0.085
            : 0.045
        }

        Column {
            anchors.left: parent.left
            anchors.bottom: parent.bottom

            anchors.leftMargin: 27
            anchors.bottomMargin: 25

            spacing: 7

            Text {
                text: card.title

                color: "white"

                font.family: montserratSemiBold.name
                font.pixelSize: 25
                font.weight: Font.Normal
            }

            Text {
                text: card.subtitle

                color: "#a4a4ae"

                font.family: montserratRegular.name
                font.pixelSize: 15
            }
        }

        MouseArea {
            anchors.fill: parent

            hoverEnabled: true

            onEntered: card.hovered = true
            onExited: card.hovered = false

            onClicked: card.cardClicked()
        }
    }

    /*
     * WEATHER CARD
     */

    component WeatherCard: Item {
        id: weather

        property bool hovered: false

        property bool controllerFocused:
        window.controllerActive &&
        window.controllerFocusIndex === 4

        scale:
        (hovered ||
        window.weatherOpen ||
        controllerFocused)
        ? 1.06
        : 1.0

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

            opacity:
            (hovered ||
            window.weatherOpen ||
            controllerFocused)
            ? 0.98
            : 0.92

            border.width: 1

            border.color:
            (hovered ||
            window.weatherOpen ||
            controllerFocused)
            ? "#3b3b44"
            : "#29292f"
        }

        Rectangle {
            anchors.fill: parent

            radius: 26
            color: "#29292f"

            opacity:
            (hovered ||
            window.weatherOpen ||
            controllerFocused)
            ? 0.32
            : 0.0

            Behavior on opacity {
                NumberAnimation {
                    duration: 120
                    easing.type: Easing.OutCubic
                }
            }
        }

        Rectangle {
            anchors.fill: parent

            radius: 26
            color: "transparent"

            border.width: 1
            border.color: "#ffffff"

            opacity:
            (hovered ||
            window.weatherOpen ||
            controllerFocused)
            ? 0.085
            : 0.045
        }

        MouseArea {
            anchors.fill: parent

            hoverEnabled: true

            onEntered: weather.hovered = true
            onExited: weather.hovered = false

            onClicked: {
                window.weatherOpen = !window.weatherOpen
                window.bluetoothOpen = false
            }
        }

        Column {
            anchors.left: parent.left
            anchors.top: parent.top

            anchors.leftMargin: 28
            anchors.topMargin: 24

            spacing: 7

            Text {
                text: window.weatherLocation

                color: "#a8a8b1"

                font.family: montserratRegular.name
                font.pixelSize: 15
            }

            Text {
                text: window.weatherTemperature

                color: "white"

                font.family: montserratSemiBold.name
                font.pixelSize: 43
                font.weight: Font.Normal
            }

            Text {
                text: window.weatherCondition

                color: "#b3b3bc"

                font.family: montserratRegular.name
                font.pixelSize: 16
            }
        }

        Row {
            anchors.left: parent.left
            anchors.bottom: parent.bottom

            anchors.leftMargin: 28
            anchors.bottomMargin: 24

            spacing: 14

            Text {
                text: window.weatherHigh + " / " + window.weatherLow

                color: "#b1b1ba"

                font.family: montserratRegular.name
                font.pixelSize: 15
            }
        }

        Item {
            id: weatherMenu

            anchors.left: parent.left
            anchors.bottom: parent.top

            width: parent.width
            height: window.weatherOpen ? 360 : 0

            clip: true
            z: 100

            Behavior on height {
                NumberAnimation {
                    duration: window.weatherOpen ? 380 : 220
                    easing.type: Easing.OutCubic
                }
            }

            Rectangle {
                anchors.fill: parent

                radius: 26
                color: "#101014"

                opacity:
                window.weatherOpen
                ? 0.98
                : 0.0

                border.width: 1
                border.color: "#3b3b44"
            }

            Rectangle {
                anchors.fill: parent

                radius: 26
                color: "#29292f"

                opacity:
                window.weatherOpen
                ? 0.32
                : 0.0
            }

            Rectangle {
                anchors.fill: parent

                radius: 26
                color: "transparent"

                border.width: 1
                border.color: "#ffffff"

                opacity:
                window.weatherOpen
                ? 0.085
                : 0.0
            }

            Column {
                anchors.fill: parent

                anchors.leftMargin: 28
                anchors.rightMargin: 28
                anchors.topMargin: 24
                anchors.bottomMargin: 24

                spacing: 15

                Item {
                    width: parent.width
                    height: 46

                    Text {
                        anchors.left: parent.left
                        anchors.verticalCenter: parent.verticalCenter

                        text: "Weather"

                        color: "white"

                        font.family: montserratSemiBold.name
                        font.pixelSize: 21
                    }

                    Rectangle {
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter

                        width: 42
                        height: 42

                        radius: 21

                        color:
                        closeMouse.containsMouse
                        ? "#2a2a31"
                        : "#1d1d23"

                        Text {
                            anchors.centerIn: parent

                            text: "×"

                            color: "#e8e8ed"

                            font.family: montserratRegular.name
                            font.pixelSize: 26
                        }

                        MouseArea {
                            id: closeMouse

                            anchors.fill: parent

                            hoverEnabled: true

                            onClicked:
                            window.weatherOpen = false
                        }
                    }
                }

                WeatherListRow {
                    label: "Rain"
                    value: window.weatherRain
                }

                WeatherListRow {
                    label: "Wind"
                    value: window.weatherWind
                }

                WeatherListRow {
                    label: "Humidity"
                    value: window.weatherHumidity
                }
            }
        }
    }

    /*
     * WEATHER LIST ROW
     */

    component WeatherListRow: Item {
        id: row

        property string label: ""
        property string value: ""

        width: parent.width
        height: 52

        Text {
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter

            text: row.label

            color: "#a7a7b0"

            font.family: montserratRegular.name
            font.pixelSize: 17
        }

        Text {
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter

            text: row.value

            color: "white"

            font.family: montserratRegular.name
            font.pixelSize: 17
        }
    }

    /*
     * BLUETOOTH POPUP
     *
     * Positioned directly from the system button row.
     */

    Item {
        id: bluetoothMenu

        x:
        systemButtons.x +
        bluetoothSystemButton.x +
        (bluetoothSystemButton.width / 2) -
        (width / 2)

        y:
        systemButtons.y -
        height -
        18

        width: 430
        height: window.bluetoothOpen ? 560 : 0

        clip: true
        z: 200

        /*
         * Same animation timing as Weather:
         * 380 ms opening
         * 220 ms closing
         */

        Behavior on height {
            NumberAnimation {
                duration: window.bluetoothOpen ? 380 : 220
                easing.type: Easing.OutCubic
            }
        }

        Rectangle {
            anchors.fill: parent

            radius: 26
            color: "#101014"

            opacity:
            window.bluetoothOpen
            ? 0.985
            : 0.0

            border.width: 1
            border.color: "#3b3b44"

            Behavior on opacity {
                NumberAnimation {
                    duration: window.bluetoothOpen ? 380 : 220
                    easing.type: Easing.OutCubic
                }
            }
        }

        Rectangle {
            anchors.fill: parent

            radius: 26
            color: "#29292f"

            opacity:
            window.bluetoothOpen
            ? 0.30
            : 0.0

            Behavior on opacity {
                NumberAnimation {
                    duration: window.bluetoothOpen ? 380 : 220
                    easing.type: Easing.OutCubic
                }
            }
        }

        Rectangle {
            anchors.fill: parent

            radius: 26
            color: "transparent"

            border.width: 1
            border.color: "#ffffff"

            opacity:
            window.bluetoothOpen
            ? 0.085
            : 0.0

            Behavior on opacity {
                NumberAnimation {
                    duration: window.bluetoothOpen ? 380 : 220
                    easing.type: Easing.OutCubic
                }
            }
        }

        ColumnLayout {
            anchors.fill: parent

            anchors.leftMargin: 26
            anchors.rightMargin: 26
            anchors.topMargin: 24
            anchors.bottomMargin: 22

            spacing: 12

            /*
             * HEADER
             */

            Item {
                Layout.fillWidth: true
                Layout.preferredHeight: 46

                Text {
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter

                    text: "Bluetooth"

                    color: "white"

                    font.family: montserratSemiBold.name
                    font.pixelSize: 22
                    font.weight: Font.Normal
                }

                Rectangle {
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter

                    width: 42
                    height: 42

                    radius: 21

                    color:
                    bluetoothCloseMouse.containsMouse
                    ? "#2a2a31"
                    : "#1d1d23"

                    Text {
                        anchors.centerIn: parent

                        text: "×"

                        color: "#e8e8ed"

                        font.family: montserratRegular.name
                        font.pixelSize: 26
                    }

                    MouseArea {
                        id: bluetoothCloseMouse

                        anchors.fill: parent

                        hoverEnabled: true

                        onClicked:
                        window.bluetoothOpen = false
                    }
                }
            }

            /*
             * POWER
             */

            Item {
                Layout.fillWidth: true
                Layout.preferredHeight: 58

                Rectangle {
                    anchors.fill: parent

                    radius: 16

                    color:
                    bluetoothPowerMouse.containsMouse
                    ? "#202027"
                    : "#17171d"

                    border.width: 1
                    border.color: "#292930"
                }

                Column {
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter

                    anchors.leftMargin: 16

                    spacing: 2

                    Text {
                        text: "Bluetooth"

                        color: "white"

                        font.family: montserratMedium.name
                        font.pixelSize: 15
                    }

                    Text {
                        text:
                        (typeof bluetoothManager !== "undefined" &&
                        bluetoothManager.powered)
                        ? "On"
                        : "Off"

                        color:
                        (typeof bluetoothManager !== "undefined" &&
                        bluetoothManager.powered)
                        ? "#bfc0c8"
                        : "#92929c"

                        font.family: montserratRegular.name
                        font.pixelSize: 13
                    }
                }

                Rectangle {
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter

                    anchors.rightMargin: 14

                    width: 46
                    height: 26

                    radius: 13

                    color:
                    (typeof bluetoothManager !== "undefined" &&
                    bluetoothManager.powered)
                    ? "#f2f2f5"
                    : "#303038"

                    Rectangle {
                        width: 20
                        height: 20

                        radius: 10

                        anchors.verticalCenter: parent.verticalCenter

                        x:
                        (typeof bluetoothManager !== "undefined" &&
                        bluetoothManager.powered)
                        ? parent.width - width - 3
                        : 3

                        color:
                        (typeof bluetoothManager !== "undefined" &&
                        bluetoothManager.powered)
                        ? "#101014"
                        : "#8e8e98"

                        Behavior on x {
                            NumberAnimation {
                                duration: 180
                                easing.type: Easing.OutCubic
                            }
                        }
                    }
                }

                MouseArea {
                    id: bluetoothPowerMouse

                    anchors.fill: parent

                    hoverEnabled: true

                    onClicked: {
                        if (typeof bluetoothManager !== "undefined") {
                            bluetoothManager.togglePowered()
                        }
                    }
                }
            }

            /*
             * DEVICES
             */

            Text {
                Layout.fillWidth: true
                Layout.preferredHeight: 20

                text: "Devices"

                color: "#a4a4ae"

                font.family: montserratMedium.name
                font.pixelSize: 14
            }

            ListView {
                id: bluetoothDeviceList

                Layout.fillWidth: true
                Layout.fillHeight: true

                spacing: 8
                clip: true

                boundsBehavior: Flickable.StopAtBounds

                model:
                typeof bluetoothManager !== "undefined"
                ? bluetoothManager.devices
                : null

                delegate: BluetoothDeviceRow {
                    width: bluetoothDeviceList.width
                    height: 58

                    deviceName: model.name
                    connected: model.connected
                    paired: model.paired
                    deviceAddress: model.address

                    onClicked: {
                        if (typeof bluetoothManager !== "undefined") {
                            bluetoothManager.toggleDeviceConnection(
                                deviceAddress
                            )
                        }
                    }
                }

                ScrollBar.vertical: ScrollBar {
                    policy: ScrollBar.AsNeeded

                    contentItem: Rectangle {
                        implicitWidth: 5
                        radius: 2.5
                        color: "#3b3b44"
                    }

                    background: Item {}
                }

                Text {
                    anchors.centerIn: parent

                    visible:
                    bluetoothDeviceList.count === 0

                    text:
                    (typeof bluetoothManager !== "undefined" &&
                    !bluetoothManager.powered)
                    ? "Bluetooth is off"
                    : "No devices found"

                    color: "#7f7f89"

                    font.family: montserratRegular.name
                    font.pixelSize: 15
                }
            }

            /*
             * SCAN
             */

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 52

                radius: 16

                color:
                bluetoothScanMouse.containsMouse
                ? "#29292f"
                : "#1b1b21"

                border.width: 1

                border.color:
                bluetoothScanMouse.containsMouse
                ? "#41414a"
                : "#2b2b32"

                Text {
                    anchors.centerIn: parent

                    text:
                    (typeof bluetoothManager !== "undefined" &&
                    bluetoothManager.discovering)
                    ? "Scanning…"
                    : "Scan for devices"

                    color:
                    (typeof bluetoothManager !== "undefined" &&
                    bluetoothManager.powered)
                    ? "#f2f2f5"
                    : "#6d6d76"

                    font.family: montserratMedium.name
                    font.pixelSize: 15
                }

                MouseArea {
                    id: bluetoothScanMouse

                    anchors.fill: parent

                    hoverEnabled: true

                    enabled:
                    typeof bluetoothManager !== "undefined" &&
                    bluetoothManager.powered

                    onClicked:
                    bluetoothManager.startDiscovery()
                }
            }
        }
    }

    /*
     * BLUETOOTH DEVICE ROW
     */

    component BluetoothDeviceRow: Item {
        id: deviceRow

        property string deviceName: ""
        property bool connected: false
        property bool paired: false
        property string deviceAddress: ""

        signal clicked()

        Rectangle {
            anchors.fill: parent

            radius: 16

            color:
            deviceMouse.containsMouse
            ? "#24242b"
            : "#17171d"

            border.width: 1

            border.color:
            connected
            ? "#3e3e47"
            : "#292930"

            Behavior on color {
                ColorAnimation {
                    duration: 100
                }
            }
        }

        Canvas {
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter

            anchors.leftMargin: 16

            width: 20
            height: 24

            onPaint: {
                var ctx = getContext("2d")

                ctx.clearRect(0, 0, width, height)

                ctx.strokeStyle = "#f2f2f5"
                ctx.lineWidth = 1.9
                ctx.lineCap = "round"
                ctx.lineJoin = "round"

                var cx = width / 2

                ctx.beginPath()

                ctx.moveTo(cx, 1)
                ctx.lineTo(cx, 23)

                ctx.moveTo(cx, 1)
                ctx.lineTo(16, 6)
                ctx.lineTo(5, 17)

                ctx.moveTo(cx, 23)
                ctx.lineTo(16, 18)
                ctx.lineTo(5, 7)

                ctx.stroke()
            }
        }

        Column {
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter

            anchors.leftMargin: 48
            anchors.rightMargin: connected ? 52 : 16

            spacing: 2

            Text {
                width: parent.width

                text:
                deviceRow.deviceName.length > 0
                ? deviceRow.deviceName
                : deviceRow.deviceAddress

                color: "white"

                font.family: montserratMedium.name
                font.pixelSize: 14

                elide: Text.ElideRight
            }

            Text {
                text:
                connected
                ? "Connected"
                : paired
                ? "Paired"
                : "Available"

                color:
                connected
                ? "#c8c8cf"
                : "#81818b"

                font.family: montserratRegular.name
                font.pixelSize: 12
            }
        }

        Rectangle {
            visible: connected

            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter

            anchors.rightMargin: 16

            width: 8
            height: 8

            radius: 4

            color: "#f2f2f5"
        }

        MouseArea {
            id: deviceMouse

            anchors.fill: parent

            hoverEnabled: true

            onClicked:
            deviceRow.clicked()
        }
    }

    /*
     * SYSTEM BUTTON
     */

    component SystemButton: Item {
        id: button

        property string iconType: ""
        property bool hovered: false

        width: 52
        height: 52

        scale: hovered ? 1.06 : 1.0

        Behavior on scale {
            NumberAnimation {
                duration: 120
                easing.type: Easing.OutCubic
            }
        }

        Rectangle {
            anchors.fill: parent

            radius: 18

            color:
            hovered
            ? "#29292f"
            : "#16161b"

            border.width: 1

            border.color:
            hovered
            ? "#3a3a42"
            : "#27272e"

            Behavior on color {
                ColorAnimation {
                    duration: 100
                }
            }

            Behavior on border.color {
                ColorAnimation {
                    duration: 100
                }
            }
        }

        /*
         * SETTINGS ICON
         */

        Item {
            visible: button.iconType === "settings"

            anchors.centerIn: parent

            width: 28
            height: 28

            Repeater {
                model: 8

                Rectangle {
                    width: 5
                    height: 8

                    radius: 1.5

                    color: "#f2f2f5"

                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.top: parent.top

                    anchors.topMargin: 1

                    transformOrigin: Item.Bottom

                    rotation: index * 45
                }
            }

            Rectangle {
                anchors.centerIn: parent

                width: 19
                height: 19

                radius: 9.5

                color: "#f2f2f5"
            }

            Rectangle {
                anchors.centerIn: parent

                width: 8
                height: 8

                radius: 4

                color: "#16161b"
            }
        }

        /*
         * BLUETOOTH ICON
         */

        Canvas {
            visible: button.iconType === "bluetooth"

            anchors.centerIn: parent

            width: 24
            height: 28

            onPaint: {
                var ctx = getContext("2d")

                ctx.clearRect(0, 0, width, height)

                ctx.strokeStyle = "#f2f2f5"
                ctx.lineWidth = 2.3
                ctx.lineCap = "round"
                ctx.lineJoin = "round"

                var cx = width / 2

                ctx.beginPath()

                ctx.moveTo(cx, 2)
                ctx.lineTo(cx, 26)

                ctx.moveTo(cx, 2)
                ctx.lineTo(19, 8)
                ctx.lineTo(7, 18)

                ctx.moveTo(cx, 26)
                ctx.lineTo(19, 20)
                ctx.lineTo(7, 8)

                ctx.stroke()
            }
        }

        /*
         * WIFI ICON
         */

        Canvas {
            visible: button.iconType === "wifi"

            anchors.centerIn: parent

            width: 30
            height: 27

            onPaint: {
                var ctx = getContext("2d")

                ctx.clearRect(0, 0, width, height)

                ctx.strokeStyle = "#f2f2f5"
                ctx.fillStyle = "#f2f2f5"

                ctx.lineWidth = 2.3
                ctx.lineCap = "round"

                var cx = width / 2
                var dotY = height - 4

                ctx.beginPath()
                ctx.arc(
                    cx,
                    dotY,
                    6.5,
                    Math.PI * 1.22,
                    Math.PI * 1.78
                )
                ctx.stroke()

                ctx.beginPath()
                ctx.arc(
                    cx,
                    dotY,
                    11.5,
                    Math.PI * 1.22,
                    Math.PI * 1.78
                )
                ctx.stroke()

                ctx.beginPath()
                ctx.arc(
                    cx,
                    dotY,
                    16.5,
                    Math.PI * 1.22,
                    Math.PI * 1.78
                )
                ctx.stroke()

                ctx.beginPath()
                ctx.arc(
                    cx,
                    dotY,
                    2.0,
                    0,
                    Math.PI * 2
                )
                ctx.fill()
            }
        }

        /*
         * POWER ICON
         */

        Text {
            visible: button.iconType === "power"

            anchors.centerIn: parent

            text: "⏻"

            color: "#f2f2f5"

            font.family: "sans-serif"
            font.pixelSize: 29
            font.weight: Font.Normal

            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }

        MouseArea {
            anchors.fill: parent

            hoverEnabled: true

            onEntered: button.hovered = true
            onExited: button.hovered = false

            onClicked: {
                if (button.iconType === "settings") {
                    window.weatherOpen = false
                    window.bluetoothOpen = false
                    settingsLauncher.open()

                } else if (button.iconType === "bluetooth") {
                    window.weatherOpen = false
                    window.bluetoothOpen = !window.bluetoothOpen

                } else if (button.iconType === "wifi") {
                    console.log("Wi-Fi")

                } else if (button.iconType === "power") {
                    console.log("Power")
                }
            }
        }
    }
}

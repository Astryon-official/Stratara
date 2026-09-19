import QtQuick
import QtQuick.Controls
import QtQuick.Window
import QtPositioning
import QtQuick.Layouts
import Stratara 1.0

ApplicationWindow {
    id: window

    visible: true
    visibility: Window.FullScreen
    color: "#000000"
    title: "Stratara"

    // ============================================================
    // STATE
    // ============================================================

    property bool weatherOpen: false
    property bool weatherLoaded: false

    property bool bluetoothOpen: false
    property bool wifiOpen: false
    property bool powerOpen: false
    property bool liveTVOpen: false

    property bool controllerActive: false
    property int controllerFocusIndex: 0

    property int bluetoothControllerFocus: 0
    property int wifiControllerFocus: 0
    property int powerControllerFocus: 0

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

    // ============================================================
    // FONTS
    // ============================================================

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

    // ============================================================
    // WEATHER
    // ============================================================

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
        "?latitude=" + currentLatitude +
        "&longitude=" + currentLongitude +
        "&current=temperature_2m,relative_humidity_2m,weather_code,wind_speed_10m" +
        "&daily=temperature_2m_max,temperature_2m_min,precipitation_probability_max" +
        "&timezone=auto"

        var xhr = new XMLHttpRequest()

        xhr.onreadystatechange = function() {
            if (xhr.readyState !== XMLHttpRequest.DONE)
                return

                if (xhr.status !== 200) {
                    weatherCondition = "Weather unavailable"
                    return
                }

                try {
                    var data = JSON.parse(xhr.responseText)

                    weatherTemperature =
                    Math.round(data.current.temperature_2m) + "°"

                    weatherHumidity =
                    Math.round(data.current.relative_humidity_2m) + "%"

                    weatherRain =
                    Math.round(
                        data.daily.precipitation_probability_max[0]
                    ) + "%"

                    weatherWind =
                    Math.round(data.current.wind_speed_10m) + " km/h"

                    weatherHigh =
                    Math.round(data.daily.temperature_2m_max[0]) + "°"

                    weatherLow =
                    Math.round(data.daily.temperature_2m_min[0]) + "°"

                    weatherCondition =
                    weatherDescription(data.current.weather_code)

                    weatherLoaded = true
                }
                catch (error) {
                    weatherCondition = "Weather unavailable"
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
                currentLatitude = position.coordinate.latitude
                currentLongitude = position.coordinate.longitude
                loadWeather()
            }
        }
    }

    Timer {
        interval: 30000
        running: !weatherLoaded
        repeat: false

        onTriggered: loadWeather()
    }

    Timer {
        interval: 900000
        running: true
        repeat: true

        onTriggered: loadWeather()
    }

    // ============================================================
    // BLUETOOTH HELPERS
    // ============================================================

    function bluetoothModelCount() {
        if (typeof bluetoothManager === "undefined" ||
            !bluetoothManager.devices) {
            return 0
            }

            return bluetoothManager.devices.count
    }

    function bluetoothMatches(section, row) {
        if (!row)
            return false

            if (section === "connected")
                return row.deviceConnected

                if (section === "available")
                    return !row.deviceConnected && !row.devicePaired

                    if (section === "paired")
                        return row.devicePaired && !row.deviceConnected

                        return false
    }

    function bluetoothSectionCount(repeater, section) {
        var count = 0

        if (!repeater)
            return 0

            for (var i = 0; i < repeater.count; i++) {
                var row = repeater.itemAt(i)

                if (bluetoothMatches(section, row) &&
                    bluetoothUniqueAddress(repeater, i)) {
                    count++
                    }
            }

            return count
    }

    function bluetoothVisibleCount() {
        return bluetoothSectionCount(
            bluetoothConnectedRepeater,
            "connected"
        )
        +
        bluetoothSectionCount(
            bluetoothAvailableRepeater,
            "available"
        )
        +
        bluetoothSectionCount(
            bluetoothPairedRepeater,
            "paired"
        )
    }

    function bluetoothRowFocus(section, rawIndex, repeater) {
        var ordinal = 0

        if (!repeater)
            return -1

            for (var i = 0; i < repeater.count; i++) {
                var row = repeater.itemAt(i)

                if (!bluetoothMatches(section, row) ||
                    !bluetoothUniqueAddress(repeater, i))
                    continue

                    if (i === rawIndex)
                        return ordinal

                        ordinal++
            }

            return -1
    }

    function bluetoothFocusedRow() {
        var target = bluetoothControllerFocus - 2

        if (target < 0)
            return null

            var repeaters = [
                bluetoothConnectedRepeater,
                bluetoothAvailableRepeater,
                bluetoothPairedRepeater
            ]

            var sections = [
                "connected",
                "available",
                "paired"
            ]

            for (var r = 0; r < repeaters.length; r++) {
                var repeater = repeaters[r]
                var section = sections[r]

                for (var i = 0; i < repeater.count; i++) {
                    var row = repeater.itemAt(i)

                    if (!bluetoothMatches(section, row) ||
                        !bluetoothUniqueAddress(repeater, i))
                        continue

                        if (target === 0)
                            return row

                            target--
                }
            }

            return null
    }

    function bluetoothUniqueAddress(repeater, rawIndex) {
        if (!repeater)
            return true

            var row = repeater.itemAt(rawIndex)

            if (!row || row.deviceAddress === "")
                return true

                for (var i = 0; i < rawIndex; i++) {
                    var previous = repeater.itemAt(i)

                    if (previous &&
                        previous.deviceAddress === row.deviceAddress) {
                        return false
                        }
                }

                return true
    }

    function moveBluetoothControllerFocus(direction) {
        var deviceCount = bluetoothVisibleCount()
        var maxFocus = deviceCount + 2

        if (direction === "up") {
            bluetoothControllerFocus =
            Math.max(
                0,
                bluetoothControllerFocus - 1
            )
        }
        else if (direction === "down") {
            bluetoothControllerFocus =
            Math.min(
                maxFocus,
                bluetoothControllerFocus + 1
            )
        }

        var row = bluetoothFocusedRow()

        if (row) {
            bluetoothDeviceFlickable.contentY =
            Math.max(
                0,
                Math.min(
                    bluetoothDeviceFlickable.contentHeight -
                    bluetoothDeviceFlickable.height,
                    row.y - 34
                )
            )
        }
    }

    function activateBluetoothControllerFocus() {
        var deviceCount = bluetoothVisibleCount()

        if (bluetoothControllerFocus === 0) {
            bluetoothOpen = false
            return
        }

        if (bluetoothControllerFocus === 1) {
            if (typeof bluetoothManager !== "undefined")
                bluetoothManager.togglePowered()

                return
        }

        if (bluetoothControllerFocus >= 2 &&
            bluetoothControllerFocus <= deviceCount + 1) {

            var row = bluetoothFocusedRow()

            if (row && row.activate)
                row.activate()

                return
            }

            if (bluetoothControllerFocus === deviceCount + 2) {
                if (typeof bluetoothManager !== "undefined" &&
                    bluetoothManager.powered) {
                    bluetoothManager.startDiscovery()
                    }
            }
    }

    // ============================================================
    // WI-FI CONTROLLER
    // ============================================================

    function wifiCount() {
        if (typeof systemManager === "undefined" ||
            !systemManager.wifiNetworks)
            return 0

            return systemManager.wifiNetworks.length
    }

    function moveWifiControllerFocus(direction) {
        var count = wifiCount()
        var maxFocus = count + 2

        if (direction === "up")
            wifiControllerFocus =
            Math.max(0, wifiControllerFocus - 1)

            else if (direction === "down")
                wifiControllerFocus =
                Math.min(maxFocus, wifiControllerFocus + 1)

                if (wifiControllerFocus >= 3 &&
                    wifiControllerFocus <= count + 2 &&
                    wifiNetworkRepeater.count > 0) {

                    var row =
                    wifiNetworkRepeater.itemAt(
                        wifiControllerFocus - 3
                    )

                    if (row) {
                        wifiNetworkFlickable.contentY =
                        Math.max(
                            0,
                            Math.min(
                                wifiNetworkFlickable.contentHeight -
                                wifiNetworkFlickable.height,
                                row.y - 34
                            )
                        )
                    }
                    }
    }

    function activateWifiControllerFocus() {
        var count = wifiCount()

        if (wifiControllerFocus === 0) {
            wifiOpen = false
            return
        }

        if (wifiControllerFocus === 1) {
            if (typeof systemManager !== "undefined")
                systemManager.toggleWifi()

                return
        }

        if (wifiControllerFocus === 2)
            return

            if (wifiControllerFocus >= 3 &&
                wifiControllerFocus <= count + 2 &&
                typeof systemManager !== "undefined") {

                var network =
                systemManager.wifiNetworks[
                    wifiControllerFocus - 3
                ]

                if (network)
                    systemManager.connectWifi(network)
                }
    }

    // ============================================================
    // POWER CONTROLLER
    // ============================================================

    function performPowerAction(action) {
        if (typeof systemManager === "undefined")
            return

            if (action === "lock")
                systemManager.lock()

                else if (action === "logout")
                    systemManager.logout()

                    else if (action === "sleep")
                        systemManager.sleep()

                        else if (action === "restart") {
                            if (typeof systemManager.restart === "function")
                                systemManager.restart()
                        }

                        else if (action === "shutdown")
                            systemManager.shutdown()

                            powerOpen = false
    }

    function movePowerControllerFocus(direction) {
        if (direction === "up") {
            powerControllerFocus =
            Math.max(
                0,
                powerControllerFocus - 1
            )
        }
        else if (direction === "down") {
            powerControllerFocus =
            Math.min(
                5,
                powerControllerFocus + 1
            )
        }
    }

    function activatePowerControllerFocus() {
        if (powerControllerFocus === 0) {
            powerOpen = false
            return
        }

        if (powerControllerFocus === 1)
            performPowerAction("lock")

            else if (powerControllerFocus === 2)
                performPowerAction("logout")

                else if (powerControllerFocus === 3)
                    performPowerAction("sleep")

                    else if (powerControllerFocus === 4)
                        performPowerAction("restart")

                        else if (powerControllerFocus === 5)
                            performPowerAction("shutdown")
    }

    // ============================================================
    // MAIN CONTROLLER NAVIGATION
    // ============================================================

    function moveControllerFocus(direction) {
        controllerActive = true

        if (liveTVOpen)
            return

            if (bluetoothOpen) {
                moveBluetoothControllerFocus(direction)
                return
            }

            if (wifiOpen) {
                moveWifiControllerFocus(direction)
                return
            }

            if (powerOpen) {
                movePowerControllerFocus(direction)
                return
            }

            if (weatherOpen) {
                if (direction === "up")
                    weatherOpen = false

                    return
            }

            if (controllerFocusIndex >= 0 &&
                controllerFocusIndex <= 3) {

                if (direction === "left") {
                    controllerFocusIndex =
                    Math.max(
                        0,
                        controllerFocusIndex - 1
                    )
                }

                else if (direction === "right") {
                    controllerFocusIndex =
                    Math.min(
                        3,
                        controllerFocusIndex + 1
                    )
                }

                else if (direction === "down") {
                    if (controllerFocusIndex <= 1)
                        controllerFocusIndex = 4

                        else if (controllerFocusIndex === 2)
                            controllerFocusIndex = 5

                            else if (controllerFocusIndex === 3)
                                controllerFocusIndex = 8
                }

                return
                }

                if (controllerFocusIndex === 4) {
                    if (direction === "right")
                        controllerFocusIndex = 5

                        else if (direction === "up")
                            controllerFocusIndex = 0

                            return
                }

                if (controllerFocusIndex >= 5 &&
                    controllerFocusIndex <= 8) {

                    if (direction === "left") {
                        controllerFocusIndex =
                        controllerFocusIndex === 5
                        ? 4
                        : controllerFocusIndex - 1
                    }

                    else if (direction === "right") {
                        controllerFocusIndex =
                        Math.min(
                            8,
                            controllerFocusIndex + 1
                        )
                    }

                    else if (direction === "up") {
                        controllerFocusIndex = 3
                    }
                    }
    }

    // ============================================================
    // CONTROLLER ACCEPT
    // ============================================================

    function activateControllerFocus() {
        if (liveTVOpen)
            return

            if (bluetoothOpen) {
                activateBluetoothControllerFocus()
                return
            }

            if (wifiOpen) {
                activateWifiControllerFocus()
                return
            }

            if (powerOpen) {
                activatePowerControllerFocus()
                return
            }

            if (weatherOpen) {
                weatherOpen = false
                return
            }

            if (controllerFocusIndex === 4) {
                weatherOpen = true

                bluetoothOpen = false
                wifiOpen = false
                powerOpen = false

                return
            }

            if (controllerFocusIndex >= 5 &&
                controllerFocusIndex <= 8) {

                var button =
                systemButtons.children[
                    controllerFocusIndex - 5
                ]

                if (button)
                    button.buttonClicked()

                    return
                }

                var card =
                exploreCards.children[
                    controllerFocusIndex
                ]

                if (card)
                    card.cardClicked()
    }

    // ============================================================
    // OPEN / CLOSE STATE
    // ============================================================

    onBluetoothOpenChanged: {
        if (bluetoothOpen) {
            bluetoothControllerFocus = 0

            wifiOpen = false
            powerOpen = false
            weatherOpen = false
        }
    }

    onWifiOpenChanged: {
        if (wifiOpen) {
            wifiControllerFocus = 0

            bluetoothOpen = false
            powerOpen = false
            weatherOpen = false

            if (typeof systemManager !== "undefined")
                systemManager.refreshWifi()
        }
    }

    onPowerOpenChanged: {
        if (powerOpen) {
            powerControllerFocus = 0

            bluetoothOpen = false
            wifiOpen = false
            weatherOpen = false
        }
    }

    onWeatherOpenChanged: {
        if (weatherOpen) {
            bluetoothOpen = false
            wifiOpen = false
            powerOpen = false
        }
    }

    // ============================================================
    // KEYBOARD
    // ============================================================

    Shortcut {
        sequence: "Escape"

        onActivated: {
            if (liveTVOpen) {
                liveTVOpen = false
                return
            }

            if (weatherOpen) {
                weatherOpen = false
                return
            }

            if (bluetoothOpen) {
                bluetoothOpen = false
                return
            }

            if (wifiOpen) {
                wifiOpen = false
                return
            }

            if (powerOpen) {
                powerOpen = false
                return
            }
        }
    }

    // ============================================================
    // CONTROLLER CONNECTION
    // ============================================================

    Connections {
        target: controllerManager

        function onControllerConnected(name) {
            controllerActive = true
            controllerFocusIndex = 0
        }

        function onControllerDisconnected() {
            controllerActive = false
        }

        function onActionPressed(action) {
            controllerActive = true

            if (action === "left" ||
                action === "right" ||
                action === "up" ||
                action === "down") {

                moveControllerFocus(action)
                }

                else if (action === "accept") {
                    activateControllerFocus()
                }

                else if (action === "cancel") {
                    liveTVOpen = false
                    weatherOpen = false
                    bluetoothOpen = false
                    wifiOpen = false
                    powerOpen = false
                }

                else if (action === "guide") {
                    weatherOpen = false
                    bluetoothOpen = false
                    wifiOpen = false
                    powerOpen = false
                    controllerFocusIndex = 0
                }
        }
    }

    // ============================================================
    // BACKGROUND
    // ============================================================

    Rectangle {
        anchors.fill: parent
        color: "#000000"
    }

    // ============================================================
    // TITLE
    // ============================================================

    Text {
        anchors.top: parent.top
        anchors.left: parent.left

        anchors.topMargin: 42
        anchors.leftMargin: 58

        text: "STRATARA"

        color: "white"

        font.family: montserratSemiBold.name
        font.pixelSize: 30
    }

    // ============================================================
    // EXPLORE
    // ============================================================

    Column {
        id: exploreSection

        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right

        anchors.topMargin: 126
        anchors.leftMargin: 58
        anchors.rightMargin: 58

        spacing: 20

        Text {
            text: "Explore"

            color: "white"

            font.family: montserratSemiBold.name
            font.pixelSize: 28
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
                controllerActive: window.controllerActive
                controllerFocusIndex: window.controllerFocusIndex
                regularFont: montserratRegular.name
                semiBoldFont: montserratSemiBold.name

                onCardClicked:
                console.log("Streaming")
            }

            GlassCard {
                width: (exploreCards.width - 54) / 4
                height: parent.height

                title: "Games"
                subtitle: "Your games, all together"
                controllerIndex: 1
                controllerActive: window.controllerActive
                controllerFocusIndex: window.controllerFocusIndex
                regularFont: montserratRegular.name
                semiBoldFont: montserratSemiBold.name

                onCardClicked:
                console.log("Games")
            }

            GlassCard {
                width: (exploreCards.width - 54) / 4
                height: parent.height

                title: "Apps"
                subtitle: "Everything you need"
                controllerIndex: 2
                controllerActive: window.controllerActive
                controllerFocusIndex: window.controllerFocusIndex
                regularFont: montserratRegular.name
                semiBoldFont: montserratSemiBold.name

                onCardClicked:
                console.log("Apps")
            }

            GlassCard {
                width: (exploreCards.width - 54) / 4
                height: parent.height

                title: "Live TV"
                subtitle: "TV, channels and more"
                controllerIndex: 3
                controllerActive: window.controllerActive
                controllerFocusIndex: window.controllerFocusIndex
                regularFont: montserratRegular.name
                semiBoldFont: montserratSemiBold.name

                onCardClicked: {
                    liveTVOpen = true

                    weatherOpen = false
                    bluetoothOpen = false
                    wifiOpen = false
                    powerOpen = false
                }
            }
        }

        }

        // ============================================================
        // LIVE TV
        // ============================================================

        Loader {
            id: liveTVLoader

            anchors.fill: parent

            z: 600

            active: true

            source: "panels/LiveTV/LiveTVPanel.qml"

            onLoaded: {
                item.open = Qt.binding(function() {
                    return window.liveTVOpen
                })

                item.closeRequested.connect(function() {
                    window.liveTVOpen = false
                })
            }
        }

    // ============================================================
    // WEATHER CARD + SLIDE-UP DETAIL PANEL
    // ============================================================

    Item {
        id: weatherCard

        anchors.left: parent.left
        anchors.bottom: parent.bottom

        anchors.leftMargin: 58
        anchors.bottomMargin: 68

        width: 505
        height: 230

        z: 401

        property bool hovered: false

        scale:
        hovered ||
        weatherOpen ||
        (controllerActive && controllerFocusIndex === 4)
        ? 1.02
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

            color:
            weatherOpen
            ? "#18181e"
            : "#101014"

            opacity:
            weatherCard.hovered ||
            (controllerActive && controllerFocusIndex === 4)
            ? 0.98
            : 0.92

            border.width: 1

            border.color:
            weatherOpen
            ? "#555560"
            : weatherCard.hovered ||
            (controllerActive && controllerFocusIndex === 4)
            ? "#3b3b44"
            : "#29292f"

            Behavior on color {
                ColorAnimation {
                    duration: 180
                }
            }

            Behavior on border.color {
                ColorAnimation {
                    duration: 180
                }
            }
        }

        Rectangle {
            anchors.fill: parent

            radius: 26

            color: "#29292f"

            opacity:
            weatherCard.hovered ||
            (controllerActive && controllerFocusIndex === 4)
            ? 0.20
            : 0
        }

        Column {
            anchors.left: parent.left
            anchors.top: parent.top

            anchors.leftMargin: 28
            anchors.topMargin: 24

            spacing: 7

            Text {
                text: weatherLocation

                color: "#a8a8b1"

                font.family: montserratRegular.name
                font.pixelSize: 15
            }

            Text {
                text: weatherTemperature

                color: "white"

                font.family: montserratSemiBold.name
                font.pixelSize: 43
            }

            Text {
                text: weatherCondition

                color: "#b3b3bc"

                font.family: montserratRegular.name
                font.pixelSize: 16
            }
        }

        // High / Low
        Row {
            anchors.left: parent.left
            anchors.bottom: parent.bottom

            anchors.leftMargin: 28
            anchors.bottomMargin: 24

            spacing: 9

            Text {
                text: "H " + weatherHigh

                color: "#c0c0c8"

                font.family: montserratMedium.name
                font.pixelSize: 16
            }

            Text {
                text: "•"

                color: "#666670"

                font.family: montserratMedium.name
                font.pixelSize: 14
            }

            Text {
                text: "L " + weatherLow

                color: "#c0c0c8"

                font.family: montserratMedium.name
                font.pixelSize: 16
            }
        }

        // Open indicator
        Canvas {
            id: weatherChevron

            anchors.right: parent.right
            anchors.bottom: parent.bottom

            anchors.rightMargin: 29
            anchors.bottomMargin: 27

            width: 22
            height: 13

            rotation: weatherOpen ? 0 : 180

            Behavior on rotation {
                NumberAnimation {
                    duration: 240
                    easing.type: Easing.OutCubic
                }
            }

            onPaint: {
                var ctx = getContext("2d")

                ctx.clearRect(0, 0, width, height)

                ctx.strokeStyle = "#b5b5be"
                ctx.lineWidth = 2.8
                ctx.lineCap = "round"
                ctx.lineJoin = "round"

                ctx.beginPath()

                ctx.moveTo(3, 4)
                ctx.lineTo(11, 11)
                ctx.lineTo(19, 4)

                ctx.stroke()
            }
        }

        MouseArea {
            anchors.fill: parent

            hoverEnabled: true

            onEntered:
            weatherCard.hovered = true

            onExited:
            weatherCard.hovered = false

            onClicked: {
                weatherOpen = !weatherOpen

                bluetoothOpen = false
                wifiOpen = false
                powerOpen = false
            }
        }

        // --------------------------------------------------------
        // WEATHER DETAIL PANEL
        // --------------------------------------------------------

        Item {
            id: weatherPanel

            anchors.left: parent.left
            anchors.bottom: parent.top

            width: parent.width
            height: 318

            z: 20

            enabled: weatherOpen
            visible: opacity > 0

            opacity: weatherOpen ? 1 : 0

            y: weatherOpen
            ? 0
            : height + 24

            Behavior on y {
                NumberAnimation {
                    duration: weatherOpen ? 360 : 260
                    easing.type: Easing.OutCubic
                }
            }

            Behavior on opacity {
                NumberAnimation {
                    duration: weatherOpen ? 220 : 160
                    easing.type: Easing.OutCubic
                }
            }

            Rectangle {
                anchors.fill: parent

                radius: 26

                color: "#16161b"

                border.width: 1
                border.color: "#555560"
            }

            Text {
                anchors.left: parent.left
                anchors.top: parent.top

                anchors.leftMargin: 26
                anchors.topMargin: 20

                text: "Weather"

                color: "white"

                font.family: montserratSemiBold.name
                font.pixelSize: 22
            }

            Text {
                anchors.right: parent.right
                anchors.top: parent.top

                anchors.rightMargin: 27
                anchors.topMargin: 20

                text: weatherCondition

                color: "#9696a1"

                font.family: montserratRegular.name
                font.pixelSize: 14
            }

            // ----------------------------------------------------
            // CURRENT WEATHER SUMMARY
            // ----------------------------------------------------

            Item {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top

                anchors.leftMargin: 24
                anchors.rightMargin: 24
                anchors.topMargin: 61

                height: 74

                Rectangle {
                    anchors.fill: parent

                    radius: 18

                    color: "#1d1d23"

                    border.width: 1
                    border.color: "#292930"
                }

                Column {
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter

                    anchors.leftMargin: 17

                    spacing: 1

                    Text {
                        text: weatherTemperature

                        color: "#f2f2f5"

                        font.family: montserratSemiBold.name
                        font.pixelSize: 29
                    }

                    Text {
                        text: weatherLocation

                        color: "#8f8f99"

                        font.family: montserratRegular.name
                        font.pixelSize: 12
                    }
                }

                Row {
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter

                    anchors.rightMargin: 17

                    spacing: 22

                    Column {
                        spacing: 2

                        Text {
                            text: "HIGH"

                            color: "#a6a6b0"

                            font.family: montserratMedium.name
                            font.pixelSize: 13
                        }

                        Text {
                            text: weatherHigh

                            color: "#f2f2f5"

                            font.family: montserratSemiBold.name
                            font.pixelSize: 19
                        }
                    }

                    Column {
                        spacing: 2

                        Text {
                            text: "LOW"

                            color: "#a6a6b0"

                            font.family: montserratMedium.name
                            font.pixelSize: 13
                        }

                        Text {
                            text: weatherLow

                            color: "#f2f2f5"

                            font.family: montserratSemiBold.name
                            font.pixelSize: 19
                        }
                    }
                }
            }

            // ----------------------------------------------------
            // DETAIL GRID
            // ----------------------------------------------------

            Row {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top

                anchors.leftMargin: 24
                anchors.rightMargin: 24
                anchors.topMargin: 148

                spacing: 9

                WeatherDetail {
                    width: (parent.width - 18) / 3
                    label: "Rain"
                    value: weatherRain
                }

                WeatherDetail {
                    width: (parent.width - 18) / 3
                    label: "Wind"
                    value: weatherWind
                }

                WeatherDetail {
                    width: (parent.width - 18) / 3
                    label: "Humidity"
                    value: weatherHumidity
                }
            }

            // ----------------------------------------------------
            // FORECAST RANGE
            // ----------------------------------------------------

            Item {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom

                anchors.leftMargin: 24
                anchors.rightMargin: 24
                anchors.bottomMargin: 18

                height: 52

                Rectangle {
                    anchors.fill: parent

                    radius: 15

                    color: "#1d1d23"

                    border.width: 1
                    border.color: "#292930"
                }

                Text {
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter

                    anchors.leftMargin: 16

                    text: "Today's range"

                    color: "#a6a6b0"

                    font.family: montserratMedium.name
                    font.pixelSize: 15
                }

                Row {
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter

                    anchors.rightMargin: 16

                    spacing: 9

                    Text {
                        text: weatherHigh

                        color: "#f2f2f5"

                        font.family: montserratSemiBold.name
                        font.pixelSize: 17
                    }

                    Text {
                        text: "•"

                        color: "#777781"

                        font.family: montserratMedium.name
                        font.pixelSize: 14
                    }

                    Text {
                        text: weatherLow

                        color: "#f2f2f5"

                        font.family: montserratSemiBold.name
                        font.pixelSize: 17
                    }
                }
            }
        }
    }

    // ============================================================
    // WEATHER DETAIL COMPONENT
    // ============================================================

    component WeatherDetail: Item {
        property string label: ""
        property string value: ""

        height: 67

        Rectangle {
            anchors.fill: parent

            radius: 16

            color: "#1d1d23"

            border.width: 1
            border.color: "#292930"
        }

        Column {
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter

            anchors.leftMargin: 14

            spacing: 4

            Text {
                text: label

                color: "#a3a3ad"

                font.family: montserratMedium.name
                font.pixelSize: 14
            }

            Text {
                text: value

                color: "#f2f2f5"

                font.family: montserratSemiBold.name
                font.pixelSize: 16
            }
        }
    }

    // ============================================================
    // WEATHER ROW
    // ============================================================

    component WeatherListRow: Item {
        property string label: ""
        property string value: ""

        width: parent.width
        height: 47

        Rectangle {
            anchors.fill: parent

            radius: 14

            color: "#1d1d23"

            border.width: 1
            border.color: "#292930"
        }

        Text {
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter

            anchors.leftMargin: 16

            text: label

            color: "#a7a7b0"

            font.family: montserratRegular.name
            font.pixelSize: 15
        }

        Text {
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter

            anchors.rightMargin: 16

            text: value

            color: "#f2f2f5"

            font.family: montserratMedium.name
            font.pixelSize: 15

            horizontalAlignment: Text.AlignRight
            elide: Text.ElideRight
        }
    }

    // ============================================================
    // WEATHER DISMISS AREA
    // ============================================================

    MouseArea {
        id: weatherDismissArea

        anchors.fill: parent

        z: 300

        visible: weatherOpen
        enabled: weatherOpen

        onClicked: {
            weatherOpen = false
        }
    }

    // ============================================================
    // BOTTOM SYSTEM TASKBAR
    // ============================================================

    Item {
        id: systemButtonArea

        anchors.right: parent.right
        anchors.bottom: parent.bottom

        anchors.rightMargin: 72

        // Raised slightly so it has its own visual zone and
        // does not sit directly against the weather area.
        anchors.bottomMargin: 68

        width: 340
        height: 60

        z: 500

        Rectangle {
            anchors.fill: parent

            radius: 20

            color: "#16161b"

            border.width: 1
            border.color: "#303039"

            layer.enabled: true
        }

        Row {
            id: systemButtons

            anchors.fill: parent

            spacing: 0

            SystemButton {
                id: settingsSystemButton

                iconType: "settings"
                controllerIndex: 5
                controllerActive: window.controllerActive
                controllerFocusIndex: window.controllerFocusIndex
                regularFont: montserratRegular.name
                semiBoldFont: montserratSemiBold.name
            }

            SystemButton {
                id: bluetoothSystemButton

                iconType: "bluetooth"
                controllerIndex: 6
                controllerActive: window.controllerActive
                controllerFocusIndex: window.controllerFocusIndex
                regularFont: montserratRegular.name
                semiBoldFont: montserratSemiBold.name
            }

            SystemButton {
                id: wifiSystemButton

                iconType: "wifi"
                controllerIndex: 7
                controllerActive: window.controllerActive
                controllerFocusIndex: window.controllerFocusIndex
                regularFont: montserratRegular.name
                semiBoldFont: montserratSemiBold.name
            }

            SystemButton {
                id: powerSystemButton

                iconType: "power"
                controllerIndex: 8
                controllerActive: window.controllerActive
                controllerFocusIndex: window.controllerFocusIndex
                regularFont: montserratRegular.name
                semiBoldFont: montserratSemiBold.name
            }
        }
    }

    // ============================================================
    // BLUETOOTH PANEL
    // ============================================================

    Item {
        id: bluetoothMenu

        anchors.right: systemButtonArea.right
        anchors.bottom: systemButtonArea.top

        anchors.bottomMargin: 16

        width: 450
        height: 590

        z: 400

        visible: true
        enabled: bluetoothOpen

        opacity: bluetoothOpen ? 1 : 0
        scale: bluetoothOpen ? 1 : 0.96

        transformOrigin: Item.BottomRight

        Behavior on opacity {
            NumberAnimation {
                duration: bluetoothOpen ? 260 : 220
                easing.type: Easing.OutCubic
            }
        }

        Behavior on scale {
            NumberAnimation {
                duration: bluetoothOpen ? 380 : 260
                easing.type: Easing.OutCubic
            }
        }

        Rectangle {
            anchors.fill: parent

            radius: 28

            color: "#16161b"

            border.width: 1
            border.color: "#555560"
        }

        Item {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top

            anchors.leftMargin: 26
            anchors.rightMargin: 22
            anchors.topMargin: 20

            height: 46

            Text {
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter

                text: "Bluetooth"

                color: "white"

                font.family: montserratSemiBold.name
                font.pixelSize: 22
            }

            PanelCloseButton {
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter

                focused:
                controllerActive &&
                bluetoothControllerFocus === 0

                onClicked:
                bluetoothOpen = false
            }
        }

        PanelOption {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top

            anchors.leftMargin: 26
            anchors.rightMargin: 26
            anchors.topMargin: 78

            height: 58
	    regularFont: montserratRegular.name
	    mediumFont: montserratMedium.name

            focused:
            controllerActive &&
            bluetoothControllerFocus === 1

            title: "Bluetooth"

            subtitle:
            typeof bluetoothManager !== "undefined" &&
            bluetoothManager.powered
            ? "On"
            : "Off"

            onClicked:
            if (typeof bluetoothManager !== "undefined")
                bluetoothManager.togglePowered()
        }

        Flickable {
            id: bluetoothDeviceFlickable

            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.bottom: parent.bottom

            anchors.leftMargin: 20
            anchors.rightMargin: 20
            anchors.topMargin: 151
            anchors.bottomMargin: 88

            clip: true

            contentWidth: width
            contentHeight: bluetoothDeviceColumn.implicitHeight

            boundsBehavior: Flickable.StopAtBounds

            Behavior on contentY {
                NumberAnimation {
                    duration: 220
                    easing.type: Easing.OutCubic
                }
            }

            Column {
                id: bluetoothDeviceColumn

                width: parent.width
                spacing: 9

                Text {
                    width: parent.width
                    height: 24

                    text: "Connected"

                    color: "#a4a4ae"

                    font.family: montserratMedium.name
                    font.pixelSize: 14
                }

                Repeater {
                    id: bluetoothConnectedRepeater

                    model:
                    typeof bluetoothManager !== "undefined"
                    ? bluetoothManager.devices
                    : null

                    delegate: BluetoothDeviceRow {
                        width: bluetoothDeviceColumn.width - 8
                        x: 4

                        deviceName: model.name
                        deviceConnected: model.connected
                        devicePaired: model.paired
                        deviceAddress: model.address

                        section: "connected"

                        visible:
                        deviceConnected &&
                        window.bluetoothUniqueAddress(
                            bluetoothConnectedRepeater,
                            index
                        )

                        height: visible ? 58 : 0

                        controllerFocused:
                        window.controllerActive &&
                        window.bluetoothOpen &&
                        window.bluetoothControllerFocus ===
                        2 +
                        window.bluetoothRowFocus(
                            "connected",
                            index,
                            bluetoothConnectedRepeater
                        )
                    }
                }

                Item {
                    width: parent.width
                    height:
                    window.bluetoothSectionCount(
                        bluetoothConnectedRepeater,
                        "connected"
                    ) === 0
                    ? 42
                    : 0

                    visible: height > 0

                    Text {
                        anchors.left: parent.left
                        anchors.leftMargin: 8
                        anchors.verticalCenter: parent.verticalCenter

                        text: "No devices found"

                        color: "#777781"

                        font.family: montserratRegular.name
                        font.pixelSize: 13
                    }
                }

                Text {
                    width: parent.width
                    height: 24

                    text: "Available"

                    color: "#a4a4ae"

                    font.family: montserratMedium.name
                    font.pixelSize: 14
                }

                Repeater {
                    id: bluetoothAvailableRepeater

                    model:
                    typeof bluetoothManager !== "undefined"
                    ? bluetoothManager.devices
                    : null

                    delegate: BluetoothDeviceRow {
                        width: bluetoothDeviceColumn.width - 8
                        x: 4

                        deviceName: model.name
                        deviceConnected: model.connected
                        devicePaired: model.paired
                        deviceAddress: model.address

                        section: "available"

                        visible:
                        !deviceConnected &&
                        !devicePaired &&
                        window.bluetoothUniqueAddress(
                            bluetoothAvailableRepeater,
                            index
                        )

                        height: visible ? 58 : 0

                        controllerFocused:
                        window.controllerActive &&
                        window.bluetoothOpen &&
                        window.bluetoothControllerFocus ===
                        2 +
                        window.bluetoothSectionCount(
                            bluetoothConnectedRepeater,
                            "connected"
                        ) +
                        window.bluetoothRowFocus(
                            "available",
                            index,
                            bluetoothAvailableRepeater
                        )
                    }
                }

                Item {
                    width: parent.width
                    height:
                    window.bluetoothSectionCount(
                        bluetoothAvailableRepeater,
                        "available"
                    ) === 0
                    ? 42
                    : 0

                    visible: height > 0

                    Text {
                        anchors.left: parent.left
                        anchors.leftMargin: 8
                        anchors.verticalCenter: parent.verticalCenter

                        text: "No devices found"

                        color: "#777781"

                        font.family: montserratRegular.name
                        font.pixelSize: 13
                    }
                }

                Text {
                    width: parent.width
                    height: 24

                    text: "Paired"

                    color: "#a4a4ae"

                    font.family: montserratMedium.name
                    font.pixelSize: 14
                }

                Repeater {
                    id: bluetoothPairedRepeater

                    model:
                    typeof bluetoothManager !== "undefined"
                    ? bluetoothManager.devices
                    : null

                    delegate: BluetoothDeviceRow {
                        width: bluetoothDeviceColumn.width - 8
                        x: 4

                        deviceName: model.name
                        deviceConnected: model.connected
                        devicePaired: model.paired
                        deviceAddress: model.address

                        section: "paired"

                        visible:
                        devicePaired &&
                        !deviceConnected &&
                        window.bluetoothUniqueAddress(
                            bluetoothPairedRepeater,
                            index
                        )

                        height: visible ? 58 : 0

                        controllerFocused:
                        window.controllerActive &&
                        window.bluetoothOpen &&
                        window.bluetoothControllerFocus ===
                        2 +
                        window.bluetoothSectionCount(
                            bluetoothConnectedRepeater,
                            "connected"
                        ) +
                        window.bluetoothSectionCount(
                            bluetoothAvailableRepeater,
                            "available"
                        ) +
                        window.bluetoothRowFocus(
                            "paired",
                            index,
                            bluetoothPairedRepeater
                        )
                    }
                }

                Item {
                    width: parent.width
                    height:
                    window.bluetoothSectionCount(
                        bluetoothPairedRepeater,
                        "paired"
                    ) === 0
                    ? 42
                    : 0

                    visible: height > 0

                    Text {
                        anchors.left: parent.left
                        anchors.leftMargin: 8
                        anchors.verticalCenter: parent.verticalCenter

                        text: "No devices found"

                        color: "#777781"

                        font.family: montserratRegular.name
                        font.pixelSize: 13
                    }
                }
            }
        }

        PanelAction {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom

            anchors.leftMargin: 26
            anchors.rightMargin: 26
            anchors.bottomMargin: 20

            height: 52

	    mediumFont: montserratMedium.name

            focused:
            controllerActive &&
            bluetoothControllerFocus ===
            bluetoothVisibleCount() + 2

            title:
            typeof bluetoothManager !== "undefined" &&
            bluetoothManager.discovering
            ? "Searching..."
            : "Search for devices"

            enabledState:
            typeof bluetoothManager !== "undefined" &&
            bluetoothManager.powered

            onClicked: {
                if (typeof bluetoothManager !== "undefined" &&
                    bluetoothManager.powered) {

                    bluetoothManager.startDiscovery()
                    }
            }
        }
    }

    // ============================================================
    // BLUETOOTH DEVICE ROW
    // ============================================================

    component BluetoothDeviceRow: Item {
        property string deviceName: ""
        property bool deviceConnected: false
        property bool devicePaired: false
        property string deviceAddress: ""

        property string section: ""

        property bool controllerFocused: false
        property bool hovered: false

        signal clicked()

        function activate() {
            clicked()
        }

        width: parent ? parent.width : 0

        Rectangle {
            anchors.fill: parent

            anchors.leftMargin: 2
            anchors.rightMargin: 2

            radius: 15

            color:
            hovered || controllerFocused
            ? "#29292f"
            : "#17171d"

            border.width: 1

            border.color:
            hovered || controllerFocused
            ? "#5a5a66"
            : "#292930"

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

        Canvas {
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter

            anchors.leftMargin: 17

            width: 22
            height: 26

            onPaint: {
                var ctx = getContext("2d")

                ctx.clearRect(0, 0, width, height)

                ctx.strokeStyle = "#f2f2f5"
                ctx.lineWidth = 2.1
                ctx.lineCap = "round"
                ctx.lineJoin = "round"

                var cx = width / 2

                ctx.beginPath()

                ctx.moveTo(cx, 2)
                ctx.lineTo(cx, 24)

                ctx.moveTo(cx, 2)
                ctx.lineTo(18, 7)
                ctx.lineTo(6, 17)

                ctx.moveTo(cx, 24)
                ctx.lineTo(18, 19)
                ctx.lineTo(6, 9)

                ctx.stroke()
            }
        }

        Column {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter

            anchors.leftMargin: 50
            anchors.rightMargin:
            deviceConnected
            ? 42
            : 16

            spacing: 2

            Text {
                width: parent.width

                text:
                deviceName.length > 0
                ? deviceName
                : deviceAddress

                color: "#f2f2f5"

                font.family: montserratMedium.name
                font.pixelSize: 14

                elide: Text.ElideRight
            }

            Text {
                text:
                deviceConnected
                ? "Connected"
                : devicePaired
                ? "Paired"
                : "Available"

                color:
                deviceConnected
                ? "#c8c8cf"
                : "#81818b"

                font.family: montserratRegular.name
                font.pixelSize: 12
            }
        }

        Rectangle {
            visible: deviceConnected

            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter

            anchors.rightMargin: 18

            width: 8
            height: 8

            radius: 4

            color: "#f2f2f5"
        }

        MouseArea {
            anchors.fill: parent

            hoverEnabled: true

            onEntered:
            parent.hovered = true

            onExited:
            parent.hovered = false

            onClicked: {
                if (typeof bluetoothManager !== "undefined")
                    bluetoothManager.toggleDeviceConnection(
                        parent.deviceAddress
                    )
            }
        }
    }

    // ============================================================
    // WI-FI PANEL
    // ============================================================

    Item {
        id: wifiPanel

        anchors.right: systemButtonArea.right
        anchors.bottom: systemButtonArea.top

        anchors.bottomMargin: 16

        width: 450
        height: 550

        z: 400

        visible: true
        enabled: wifiOpen

        opacity: wifiOpen ? 1 : 0
        scale: wifiOpen ? 1 : 0.96

        transformOrigin: Item.BottomRight

        Behavior on opacity {
            NumberAnimation {
                duration: wifiOpen ? 260 : 220
                easing.type: Easing.OutCubic
            }
        }

        Behavior on scale {
            NumberAnimation {
                duration: wifiOpen ? 380 : 260
                easing.type: Easing.OutCubic
            }
        }

        Rectangle {
            anchors.fill: parent

            radius: 28

            color: "#16161b"

            border.width: 1
            border.color: "#555560"
        }

        Item {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top

            anchors.leftMargin: 26
            anchors.rightMargin: 22
            anchors.topMargin: 20

            height: 46

            Text {
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter

                text: "Wi-Fi"

                color: "white"

                font.family: montserratSemiBold.name
                font.pixelSize: 22
            }

            PanelCloseButton {
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter

                focused:
                controllerActive &&
                wifiControllerFocus === 0

                onClicked:
                wifiOpen = false
            }
        }

        PanelOption {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top

            anchors.leftMargin: 26
            anchors.rightMargin: 26
            anchors.topMargin: 78

	    height: 58

	    regularFont: montserratRegular.name
	    mediumFont: montserratMedium.name

            focused:
            controllerActive &&
            wifiControllerFocus === 1

            title: "Wi-Fi"

            subtitle:
            typeof systemManager !== "undefined" &&
            systemManager.wifiEnabled
            ? "Enabled"
            : "Disabled"

            onClicked:
            if (typeof systemManager !== "undefined")
                systemManager.toggleWifi()
        }

        InfoOption {
            id: ethernetOption

            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top

            anchors.leftMargin: 26
            anchors.rightMargin: 26
            anchors.topMargin: 150

            height: 58

            focused:
            controllerActive &&
            wifiOpen &&
            wifiControllerFocus === 2

            title: "Ethernet"

            subtitle:
            typeof systemManager !== "undefined" &&
            systemManager.ethernetConnected
            ? systemManager.ethernetConnection !== ""
            ? systemManager.ethernetConnection
            : "Connected"
            : "Disconnected"
        }

        Text {
            anchors.left: parent.left
            anchors.top: parent.top

            anchors.leftMargin: 26
            anchors.topMargin: 224

            text:
            typeof systemManager !== "undefined" &&
            systemManager.wifiConnection !== ""
            ? "Connected to " +
            systemManager.wifiConnection
            : "Available networks"

            color: "#a8a8b2"

            font.family: montserratRegular.name
            font.pixelSize: 15
        }

        Flickable {
            id: wifiNetworkFlickable

            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.bottom: parent.bottom

            anchors.leftMargin: 20
            anchors.rightMargin: 20
            anchors.topMargin: 253
            anchors.bottomMargin: 20

            clip: true

            contentWidth: width
            contentHeight: wifiNetworkColumn.implicitHeight

            boundsBehavior: Flickable.StopAtBounds

            Behavior on contentY {
                NumberAnimation {
                    duration: 220
                    easing.type: Easing.OutCubic
                }
            }

            Column {
                id: wifiNetworkColumn

                width: parent.width
                spacing: 9

                Repeater {
                    id: wifiNetworkRepeater

                    model:
                    typeof systemManager !== "undefined"
                    ? systemManager.wifiNetworks
                    : null

                    delegate: WifiNetworkRow {
                        width: wifiNetworkColumn.width - 8
                        x: 4
                        height: 58

                        networkName: modelData

                        connected:
                        typeof systemManager !== "undefined" &&
                        modelData === systemManager.wifiConnection

                        controllerFocused:
                        window.controllerActive &&
                        window.wifiOpen &&
                        window.wifiControllerFocus ===
                        index + 3

                        onClicked:
                        if (typeof systemManager !== "undefined")
                            systemManager.connectWifi(modelData)
                    }
                }

                Item {
                    width: parent.width
                    height:
                    wifiNetworkRepeater.count === 0
                    ? 42
                    : 0

                    visible: height > 0

                    Text {
                        anchors.left: parent.left
                        anchors.leftMargin: 8
                        anchors.verticalCenter: parent.verticalCenter

                        text:
                        typeof systemManager !== "undefined" &&
                        !systemManager.wifiEnabled
                        ? "Wi-Fi is off"
                        : "No networks found"

                        color: "#7f7f89"

                        font.family: montserratRegular.name
                        font.pixelSize: 15
                    }
                }
            }
        }
    }

    // ============================================================
    // INFO OPTION
    // ============================================================

    component InfoOption: Item {
        property string title: ""
        property string subtitle: ""

        property bool hovered: false
        property bool focused: false

        width: parent ? parent.width : 0

        Rectangle {
            anchors.fill: parent

            radius: 16

            color:
            hovered || focused
            ? "#29292f"
            : "#17171d"

            border.width: 1

            border.color:
            hovered || focused
            ? "#5a5a66"
            : "#292930"

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

        Column {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter

            anchors.leftMargin: 16
            anchors.rightMargin: 16

            spacing: 2

            Text {
                text: title

                color: "#f2f2f5"

                font.family: montserratMedium.name
                font.pixelSize: 15
            }

            Text {
                width: parent.width

                text: subtitle

                color:
                hovered || focused
                ? "#c9c9d1"
                : "#92929c"

                font.family: montserratRegular.name
                font.pixelSize: 13

                elide: Text.ElideRight
            }
        }

        MouseArea {
            anchors.fill: parent

            hoverEnabled: true

            onEntered:
            parent.hovered = true

            onExited:
            parent.hovered = false
        }
    }

    // ============================================================
    // WI-FI NETWORK ROW
    // ============================================================

    component WifiNetworkRow: Item {
        property string networkName: ""
        property bool connected: false
        property bool controllerFocused: false
        property bool hovered: false

        signal clicked()

        Rectangle {
            anchors.fill: parent

            anchors.leftMargin: 2
            anchors.rightMargin: 2

            radius: 15

            color:
            hovered || controllerFocused
            ? "#29292f"
            : "#1d1d23"

            border.width: 1

            border.color:
            hovered || controllerFocused
            ? "#5a5a66"
            : "#292930"

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

        Text {
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter

            anchors.leftMargin: 16

            width: parent.width - 130

            text: networkName

            color: "#f2f2f5"

            font.family: montserratRegular.name
            font.pixelSize: 16

            elide: Text.ElideRight
        }

        Text {
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter

            anchors.rightMargin: 16

            text:
            connected
            ? "Connected"
            : "Connect"

            color:
            connected
            ? "#8be28b"
            : hovered || controllerFocused
            ? "#f2f2f5"
            : "#9999a3"

            font.family: montserratMedium.name
            font.pixelSize: 14

            Behavior on color {
                ColorAnimation {
                    duration: 120
                }
            }
        }

        MouseArea {
            anchors.fill: parent

            hoverEnabled: true

            onEntered:
            parent.hovered = true

            onExited:
            parent.hovered = false

            onClicked:
            parent.clicked()
        }
    }

    // ============================================================
    // POWER PANEL
    // ============================================================

    Item {
        id: powerPanel

        anchors.right: systemButtonArea.right
        anchors.bottom: systemButtonArea.top

        anchors.bottomMargin: 16

        width: 450
        height: 560

        z: 400

        visible: true
        enabled: powerOpen

        opacity: powerOpen ? 1 : 0
        scale: powerOpen ? 1 : 0.96

        transformOrigin: Item.BottomRight

        Behavior on opacity {
            NumberAnimation {
                duration: powerOpen ? 260 : 220
                easing.type: Easing.OutCubic
            }
        }

        Behavior on scale {
            NumberAnimation {
                duration: powerOpen ? 380 : 260
                easing.type: Easing.OutCubic
            }
        }

        Rectangle {
            anchors.fill: parent

            radius: 28

            color: "#16161b"

            border.width: 1
            border.color: "#555560"
        }

        Item {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top

            anchors.leftMargin: 26
            anchors.rightMargin: 22
            anchors.topMargin: 20

            height: 46

            Text {
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter

                text: "Power"

                color: "white"

                font.family: montserratSemiBold.name
                font.pixelSize: 22
            }

            PanelCloseButton {
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter

                focused:
                controllerActive &&
                powerControllerFocus === 0

                onClicked:
                powerOpen = false
            }
        }

        Rectangle {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top

            anchors.topMargin: 70
            anchors.leftMargin: 20
            anchors.rightMargin: 20

            height: 84

            radius: 18

            color: "#1d1d23"

            Text {
                anchors.left: parent.left
                anchors.top: parent.top

                anchors.leftMargin: 16
                anchors.topMargin: 13

                text: "Recommendation"

                color: "#f2f2f5"

                font.family: montserratMedium.name
                font.pixelSize: 14
            }

            Text {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom

                anchors.leftMargin: 16
                anchors.rightMargin: 16
                anchors.bottomMargin: 13

                text:
                "Shut down overnight. Use Sleep during the day " +
                "when you want to resume quickly."

                color: "#a8a8b2"

                font.family: montserratRegular.name
                font.pixelSize: 13

                wrapMode: Text.WordWrap
            }
        }

        Column {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top

            anchors.leftMargin: 20
            anchors.rightMargin: 20
            anchors.topMargin: 170

            spacing: 8

            PowerOption {
                title: "Lock"

                description:
                "Locks Stratara while keeping your session running."

                focused:
                controllerActive &&
                powerControllerFocus === 1

                actionName: "lock"

                onClicked:
                performPowerAction(actionName)
            }

            PowerOption {
                title: "Log out"

                description:
                "Ends your current session and returns to the login screen."

                focused:
                controllerActive &&
                powerControllerFocus === 2

                actionName: "logout"

                onClicked:
                performPowerAction(actionName)
            }

            PowerOption {
                title: "Sleep"

                description:
                "Uses low power and lets you resume quickly."

                focused:
                controllerActive &&
                powerControllerFocus === 3

                actionName: "sleep"

                onClicked:
                performPowerAction(actionName)
            }

            PowerOption {
                title: "Restart"

                description:
                "Restarts Stratara and starts a fresh session."

                focused:
                controllerActive &&
                powerControllerFocus === 4

                actionName: "restart"

                onClicked:
                performPowerAction(actionName)
            }

            PowerOption {
                title: "Shut down"

                description:
                "Fully powers off the PC."

                focused:
                controllerActive &&
                powerControllerFocus === 5

                actionName: "shutdown"

                onClicked:
                performPowerAction(actionName)
            }
        }

        Text {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom

            anchors.leftMargin: 24
            anchors.rightMargin: 24
            anchors.bottomMargin: 16

            text:
            [
                "Close the Power panel.",
                "Lock — keeps your session running.",
                "Log out — returns to the login screen.",
                "Sleep — lets you resume quickly.",
                "Restart — starts a fresh session.",
                "Shut down — fully powers off the PC."
            ][powerControllerFocus]

            color: "#8f8f99"

            font.family: montserratRegular.name
            font.pixelSize: 13

            wrapMode: Text.WordWrap
        }
    }

    // ============================================================
    // PANEL CLOSE BUTTON
    // ============================================================

    component PanelCloseButton: Item {
        property bool focused: false
        property bool hovered: false

        signal clicked()

        width: 42
        height: 42

        scale:
        hovered || focused
        ? 1.04
        : 1.0

        Behavior on scale {
            NumberAnimation {
                duration: 120
                easing.type: Easing.OutCubic
            }
        }

        Rectangle {
            anchors.fill: parent

            radius: 21

            color:
            hovered || focused
            ? "#2a2a31"
            : "#1d1d23"

            border.width:
            focused
            ? 1
            : 0

            border.color: "#5a5a66"

            Behavior on color {
                ColorAnimation {
                    duration: 120
                }
            }
        }

        Text {
            anchors.centerIn: parent

            text: "×"

            color: "#e8e8ed"

            font.family: montserratRegular.name
            font.pixelSize: 26
        }

        MouseArea {
            anchors.fill: parent

            hoverEnabled: true

            onEntered:
            parent.hovered = true

            onExited:
            parent.hovered = false

            onClicked:
            parent.clicked()
        }
    }

    // ============================================================
    // POWER OPTION
    // ============================================================

    component PowerOption: Item {
        property string title: ""
        property string description: ""
        property string actionName: ""

        property bool focused: false
        property bool hovered: false

        signal clicked()

        width: parent.width
        height: 58

        scale:
        hovered || focused
        ? 1.015
        : 1.0

        Behavior on scale {
            NumberAnimation {
                duration: 120
                easing.type: Easing.OutCubic
            }
        }

        Rectangle {
            anchors.fill: parent

            radius: 14

            color:
            hovered || focused
            ? "#29292f"
            : "#1d1d23"

            border.width: 1

            border.color:
            hovered || focused
            ? "#5a5a66"
            : "#292930"

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

        Column {
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter

            anchors.leftMargin: 16

            spacing: 2

            Text {
                text: title

                color: "#f2f2f5"

                font.family: montserratMedium.name
                font.pixelSize: 16
            }

            Text {
                width: parent.parent.width - 32

                text: description

                color: "#85858f"

                font.family: montserratRegular.name
                font.pixelSize: 11

                elide: Text.ElideRight
            }
        }

        MouseArea {
            anchors.fill: parent

            hoverEnabled: true

            onEntered:
            parent.hovered = true

            onExited:
            parent.hovered = false

            onClicked:
            parent.clicked()
        }
    }


}

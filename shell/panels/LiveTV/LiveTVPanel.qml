import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    id: liveTV

    anchors.fill: parent

    // ------------------------------------------------------------------
    // Public API
    // ------------------------------------------------------------------

    property bool open: false
    signal closeRequested()

    // ------------------------------------------------------------------
    // Stratara colours
    // ------------------------------------------------------------------

    readonly property color backgroundColor: "#050706"
    readonly property color accentColor: "#65ff9a"
    readonly property color textColor: "#f2f5f3"
    readonly property color secondaryTextColor: "#8f9a94"
    readonly property color overlayColor: "#101513"

    // ------------------------------------------------------------------
    // Channel state
    // ------------------------------------------------------------------

    property int currentChannel: 0
    property bool exitPromptOpen: false
    property int exitPromptFocus: 1

    property bool channelOverlayVisible: false

    // ------------------------------------------------------------------
    // Channels
    //
    // These are placeholders for now.
    // The stream URLs will be added when we build the real TV backend.
    // ------------------------------------------------------------------

    ListModel {
        id: channelModel

        ListElement {
            number: 1
            name: "ABC"
            description: "ABC TV"
        }

        ListElement {
            number: 2
            name: "7"
            description: "Seven"
        }

        ListElement {
            number: 3
            name: "7TWO"
            description: "7TWO"
        }

        ListElement {
            number: 4
            name: "7mate"
            description: "7mate"
        }

        ListElement {
            number: 5
            name: "9"
            description: "Nine"
        }

        ListElement {
            number: 6
            name: "9Go!"
            description: "9Go!"
        }

        ListElement {
            number: 7
            name: "10"
            description: "Network 10"
        }

        ListElement {
            number: 8
            name: "10 Peach"
            description: "10 Peach"
        }

        ListElement {
            number: 9
            name: "SBS"
            description: "SBS"
        }

        ListElement {
            number: 10
            name: "SBS Viceland"
            description: "SBS Viceland"
        }
    }

    // ------------------------------------------------------------------
    // Helpers
    // ------------------------------------------------------------------

    function showChannelOverlay() {
        channelOverlayVisible = true
        channelOverlayTimer.restart()
    }

    function nextChannel() {
        if (exitPromptOpen)
            return

            if (channelModel.count === 0)
                return

                currentChannel =
                Math.min(
                    channelModel.count - 1,
                    currentChannel + 1
                )

                showChannelOverlay()
    }

    function previousChannel() {
        if (exitPromptOpen)
            return

            if (channelModel.count === 0)
                return

                currentChannel =
                Math.max(
                    0,
                    currentChannel - 1
                )

                showChannelOverlay()
    }

    function openExitPrompt() {
        exitPromptOpen = true
        exitPromptFocus = 1
        channelOverlayVisible = false

        exitPrompt.forceActiveFocus()
    }

    function closeExitPrompt() {
        exitPromptOpen = false
        liveTV.forceActiveFocus()
    }

    function confirmExit() {
        if (exitPromptFocus === 0) {
            exitPromptOpen = false
            closeRequested()
        }
        else {
            closeExitPrompt()
        }
    }

    // ------------------------------------------------------------------
    // Main entrance / exit animation
    // ------------------------------------------------------------------

    opacity: open ? 1 : 0
    scale: open ? 1 : 0.985

    Behavior on opacity {
        NumberAnimation {
            duration: open ? 220 : 180
            easing.type: Easing.OutCubic
        }
    }

    Behavior on scale {
        NumberAnimation {
            duration: open ? 280 : 200
            easing.type: Easing.OutCubic
        }
    }

    visible: opacity > 0

    // ------------------------------------------------------------------
    // Channel overlay timer
    // ------------------------------------------------------------------

    Timer {
        id: channelOverlayTimer

        interval: 2200
        repeat: false

        onTriggered: {
            channelOverlayVisible = false
        }
    }

    // ------------------------------------------------------------------
    // Full-screen TV background
    // ------------------------------------------------------------------

    Rectangle {
        anchors.fill: parent

        color: liveTV.backgroundColor
    }

    // ------------------------------------------------------------------
    // VIDEO AREA
    //
    // This is intentionally completely fullscreen.
    // Real playback will replace this placeholder.
    // ------------------------------------------------------------------

    Rectangle {
        anchors.fill: parent

        color: "#020302"

        // Temporary stream placeholder
        Column {
            anchors.centerIn: parent

            spacing: 12

            Text {
                anchors.horizontalCenter: parent.horizontalCenter

                text: "LIVE"

                color: liveTV.accentColor

                font.family: "Montserrat"
                font.pixelSize: 15
                font.weight: Font.DemiBold
            }

            Text {
                anchors.horizontalCenter: parent.horizontalCenter

                text: channelModel.get(currentChannel).name

                color: liveTV.textColor

                font.family: "Montserrat"
                font.pixelSize: 48
                font.weight: Font.DemiBold
            }

            Text {
                anchors.horizontalCenter: parent.horizontalCenter

                text: "Live stream"

                color: liveTV.secondaryTextColor

                font.family: "Montserrat"
                font.pixelSize: 14
            }
        }
    }

    // ------------------------------------------------------------------
    // Subtle top gradient
    // ------------------------------------------------------------------

    Rectangle {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top

        height: 170

        gradient: Gradient {
            GradientStop {
                position: 0.0
                color: "#90000000"
            }

            GradientStop {
                position: 1.0
                color: "#00000000"
            }
        }
    }

    // ------------------------------------------------------------------
    // Subtle bottom gradient
    // ------------------------------------------------------------------

    Rectangle {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom

        height: 210

        gradient: Gradient {
            GradientStop {
                position: 0.0
                color: "#00000000"
            }

            GradientStop {
                position: 1.0
                color: "#B0000000"
            }
        }
    }

    // ------------------------------------------------------------------
    // Channel information overlay
    // ------------------------------------------------------------------

    Rectangle {
        id: channelOverlay

        anchors.left: parent.left
        anchors.bottom: parent.bottom

        anchors.leftMargin: 54
        anchors.bottomMargin: 48

        width: 350
        height: 112

        radius: 20

        color: "#D9101513"

        border.width: 1
        border.color: "#303a34"

        opacity: channelOverlayVisible ? 1 : 0

        y: channelOverlayVisible ? 0 : 20

        Behavior on opacity {
            NumberAnimation {
                duration: 180
                easing.type: Easing.OutCubic
            }
        }

        Behavior on y {
            NumberAnimation {
                duration: 220
                easing.type: Easing.OutCubic
            }
        }

        RowLayout {
            anchors.fill: parent

            anchors.leftMargin: 20
            anchors.rightMargin: 20

            spacing: 16

            Rectangle {
                Layout.preferredWidth: 58
                Layout.preferredHeight: 58

                radius: 16

                color: "#193526"

                Text {
                    anchors.centerIn: parent

                    text: channelModel.get(currentChannel).number

                    color: liveTV.accentColor

                    font.family: "Montserrat"
                    font.pixelSize: 24
                    font.weight: Font.DemiBold
                }
            }

            ColumnLayout {
                Layout.fillWidth: true

                spacing: 2

                Text {
                    text: channelModel.get(currentChannel).name

                    color: liveTV.textColor

                    font.family: "Montserrat"
                    font.pixelSize: 21
                    font.weight: Font.DemiBold
                }

                Text {
                    text: channelModel.get(currentChannel).description

                    color: liveTV.secondaryTextColor

                    font.family: "Montserrat"
                    font.pixelSize: 13
                }

                Text {
                    text: "LIVE"

                    color: liveTV.accentColor

                    font.family: "Montserrat"
                    font.pixelSize: 11
                    font.weight: Font.DemiBold
                }
            }
        }
    }

    // ------------------------------------------------------------------
    // Small channel indicator
    // ------------------------------------------------------------------

    Rectangle {
        anchors.right: parent.right
        anchors.top: parent.top

        anchors.rightMargin: 42
        anchors.topMargin: 38

        width: 74
        height: 42

        radius: 13

        color: "#B0101513"

        border.width: 1
        border.color: "#28332d"

        opacity: channelOverlayVisible ? 0 : 0.85

        Behavior on opacity {
            NumberAnimation {
                duration: 180
            }
        }

        Text {
            anchors.centerIn: parent

            text: "CH " +
            channelModel.get(currentChannel).number

            color: liveTV.textColor

            font.family: "Montserrat"
            font.pixelSize: 13
            font.weight: Font.DemiBold
        }
    }

    // ------------------------------------------------------------------
    // EXIT CONFIRMATION
    // ------------------------------------------------------------------

    Rectangle {
        id: exitDimmer

        anchors.fill: parent

        color: "#A8000000"

        opacity: exitPromptOpen ? 1 : 0

        visible: opacity > 0

        Behavior on opacity {
            NumberAnimation {
                duration: 180
            }
        }
    }

    Rectangle {
        id: exitPrompt

        anchors.centerIn: parent

        width: 480
        height: 245

        radius: 26

        color: "#151c19"

        border.width: 1
        border.color: "#39453f"

        opacity: exitPromptOpen ? 1 : 0

        scale: exitPromptOpen ? 1 : 0.94

        visible: opacity > 0

        focus: exitPromptOpen

        Behavior on opacity {
            NumberAnimation {
                duration: 180
                easing.type: Easing.OutCubic
            }
        }

        Behavior on scale {
            NumberAnimation {
                duration: 220
                easing.type: Easing.OutCubic
            }
        }

        Column {
            anchors.fill: parent

            anchors.leftMargin: 32
            anchors.rightMargin: 32
            anchors.topMargin: 28
            anchors.bottomMargin: 28

            spacing: 10

            Text {
                width: parent.width

                text: "Return to Live TV?"

                color: liveTV.textColor

                font.family: "Montserrat"
                font.pixelSize: 25
                font.weight: Font.DemiBold

                horizontalAlignment: Text.AlignHCenter
            }

            Text {
                width: parent.width

                text: "Would you like to return to the Stratara home screen?"

                color: liveTV.secondaryTextColor

                font.family: "Montserrat"
                font.pixelSize: 13

                horizontalAlignment: Text.AlignHCenter

                wrapMode: Text.WordWrap
            }

            Item {
                width: 1
                height: 14
            }

            Row {
                anchors.horizontalCenter: parent.horizontalCenter

                spacing: 14

                Rectangle {
                    width: 165
                    height: 54

                    radius: 15

                    color:
                    exitPromptFocus === 0
                    ? "#193526"
                    : "#101513"

                    border.width:
                    exitPromptFocus === 0
                    ? 1
                    : 0

                    border.color: liveTV.accentColor

                    Text {
                        anchors.centerIn: parent

                        text: "YES"

                        color:
                        exitPromptFocus === 0
                        ? liveTV.accentColor
                        : liveTV.textColor

                        font.family: "Montserrat"
                        font.pixelSize: 15
                        font.weight: Font.DemiBold
                    }

                    MouseArea {
                        anchors.fill: parent

                        onClicked: {
                            exitPromptFocus = 0
                            confirmExit()
                        }
                    }
                }

                Rectangle {
                    width: 165
                    height: 54

                    radius: 15

                    color:
                    exitPromptFocus === 1
                    ? "#193526"
                    : "#101513"

                    border.width:
                    exitPromptFocus === 1
                    ? 1
                    : 0

                    border.color: liveTV.accentColor

                    Text {
                        anchors.centerIn: parent

                        text: "NO"

                        color:
                        exitPromptFocus === 1
                        ? liveTV.accentColor
                        : liveTV.textColor

                        font.family: "Montserrat"
                        font.pixelSize: 15
                        font.weight: Font.DemiBold
                    }

                    MouseArea {
                        anchors.fill: parent

                        onClicked: {
                            exitPromptFocus = 1
                            confirmExit()
                        }
                    }
                }
            }
        }

        Keys.onLeftPressed: {
            exitPromptFocus = 0
        }

        Keys.onRightPressed: {
            exitPromptFocus = 1
        }

        Keys.onUpPressed: {
            exitPromptFocus = 0
        }

        Keys.onDownPressed: {
            exitPromptFocus = 1
        }

        Keys.onReturnPressed: {
            confirmExit()
        }

        Keys.onEnterPressed: {
            confirmExit()
        }

        Keys.onEscapePressed: {
            closeExitPrompt()
        }
    }

    // ------------------------------------------------------------------
    // Keyboard / controller navigation
    //
    // Stratara's controller manager sends actions through the shell.
    // The shell will be updated so Live TV receives these actions.
    // ------------------------------------------------------------------

    Keys.onUpPressed: {
        if (!exitPromptOpen)
            previousChannel()
    }

    Keys.onDownPressed: {
        if (!exitPromptOpen)
            nextChannel()
    }

    Keys.onEscapePressed: {
        if (exitPromptOpen) {
            closeExitPrompt()
            return
        }

        openExitPrompt()
    }

    focus: open

    onOpenChanged: {
        if (open) {
            exitPromptOpen = false
            liveTV.forceActiveFocus()
        }
    }

    Component.onCompleted: {
        if (open)
            forceActiveFocus()
    }
}

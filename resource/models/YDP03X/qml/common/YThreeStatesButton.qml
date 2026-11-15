import QtQuick 2.12

YButtonBase {
    id: id_three_states_button
    implicitWidth: 120
    implicitHeight: 92
    state: "off"
    enabled: "middle" !== state
    color: YColors.white
    radius: height/2
    mouseAreaMargins: -5

    readonly property int waitingDuration: 420
    property alias imageName: id_icon.imageName

    signal callOff() // user click trigger
    signal callOn() // user click trigger

    function setOn() {
        state = "on"
    }

    function setOff() {
        state = "off"
    }

    Rectangle {
        id: id_on_bg
        anchors.fill: parent
        radius: parent.height/2
        visible: false
        gradient: Gradient {
            GradientStop { position: 0.0; color: "#4DA0FF" }
            GradientStop { position: 1.0; color: "#457AE6" }
        }
    }

    YImage {
        id: id_icon
        anchors.centerIn: parent
        sourceSize: Qt.size(44, 44)
    }

    states: [
        State {
            name: "off"
            PropertyChanges { target: id_three_states_button; color: "#FFFFFF" }
            PropertyChanges { target: id_on_bg; visible: false }
            PropertyChanges { target: id_three_states_button; enabled: true }
        },
        State {
            name: "middle"
            PropertyChanges { target: id_three_states_button; color: "transparent" }
            PropertyChanges { target: id_on_bg; visible: true }
            PropertyChanges { target: id_on_bg; opacity: 0.6 }
            PropertyChanges { target: id_icon; opacity: 0.6 }
            PropertyChanges { target: id_three_states_button; enabled: false }
        },
        State {
            name: "on"
            PropertyChanges { target: id_three_states_button; color: "transparent" }
            PropertyChanges { target: id_on_bg; visible: true }
            PropertyChanges { target: id_on_bg; opacity: 1 }
            PropertyChanges { target: id_icon; opacity: 1 }
            PropertyChanges { target: id_three_states_button; enabled: true }
        }
    ]

    onClicked: {
        if ("on" === id_three_states_button.state) {
            id_three_states_button.state = "off"
            callOff()
        } else if ("off" === id_three_states_button.state) {
            id_three_states_button.state = "middle"
            callOn()
        }
    }

    readonly property QtObject turnOnTimeoutTimer: id_turn_on_timer
    signal turnOnTimeout()

    YTimer {
        id: id_turn_on_timer
        interval: 5000
        objectName: "YThreeStatesButton.qml_id_turn_on_timer"
        onTriggered: {
            turnOnTimeout()
        }
    }
}

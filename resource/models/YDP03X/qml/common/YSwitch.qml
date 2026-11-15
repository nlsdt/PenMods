import QtQuick 2.12

Rectangle {
    implicitWidth: 80
    implicitHeight: 44
    radius: 22
    smooth: true
    property color onColor: YColors.green
    property color offColor: YColors.graySwitchOff
    color: switchOn ? onColor : offColor
    readonly property bool animationRunning: id_transition_animation.running
    property bool switchOn: false

    Rectangle {
        implicitWidth: 36
        implicitHeight: 36
        radius: 18
        color: YColors.white
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        anchors.leftMargin: !switchOn ? 4 : 40
        Behavior on anchors.leftMargin {
            NumberAnimation {
                id: id_transition_animation
            }
        }
    }
}

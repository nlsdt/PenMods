import QtQuick 2.12

Rectangle {
    id: root

    property bool isAnimating: false

    width: 64
    height: 36
    radius: 16
    color: "#1A1B1F"

    Row {
        anchors.centerIn: parent
        spacing: 6

        Rectangle {
            width: 8; height: 8; radius: 4
            color: "#8899AA"
            anchors.verticalCenter: parent.verticalCenter

            SequentialAnimation on scale {
                running: root.isAnimating
                loops: Animation.Infinite
                NumberAnimation { from: 1.0; to: 1.5; duration: 200; easing.type: Easing.OutCubic }
                NumberAnimation { from: 1.5; to: 1.0; duration: 200; easing.type: Easing.InCubic }
                PauseAnimation { duration: 800 }
            }
        }
        Rectangle {
            width: 8; height: 8; radius: 4
            color: "#8899AA"
            anchors.verticalCenter: parent.verticalCenter

            SequentialAnimation on scale {
                running: root.isAnimating
                loops: Animation.Infinite
                PauseAnimation { duration: 200 }
                NumberAnimation { from: 1.0; to: 1.5; duration: 200; easing.type: Easing.OutCubic }
                NumberAnimation { from: 1.5; to: 1.0; duration: 200; easing.type: Easing.InCubic }
                PauseAnimation { duration: 600 }
            }
        }
        Rectangle {
            width: 8; height: 8; radius: 4
            color: "#8899AA"
            anchors.verticalCenter: parent.verticalCenter

            SequentialAnimation on scale {
                running: root.isAnimating
                loops: Animation.Infinite
                PauseAnimation { duration: 400 }
                NumberAnimation { from: 1.0; to: 1.5; duration: 200; easing.type: Easing.OutCubic }
                NumberAnimation { from: 1.5; to: 1.0; duration: 200; easing.type: Easing.InCubic }
                PauseAnimation { duration: 400 }
            }
        }
    }
}

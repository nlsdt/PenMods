import QtQuick 2.12

import BaseQml 1.0

Rectangle {
    id: id_interactive_button
    implicitWidth: 128
    implicitHeight: 50
    radius: height/2
    color: "#27282C"

    signal validClicked()

    function play() {
        id_loud_speeker_playing.play()
    }

    function stopPlay() {
        id_loud_speeker_playing.stopPlay()
    }

    Item {
        implicitWidth: 50
        implicitHeight: 50
        anchors.left: parent.left
        anchors.leftMargin: 6
        anchors.verticalCenter: parent.verticalCenter

        YAnimatedImagesView {
            id: id_loud_speeker_playing
            objectName: "YInteractiveQuizzesListenQuestionButton.qml"
            anchors.centerIn: parent
            frameSize: Qt.size(46, 46)
            frameCountLoop: 35
            imageNameLoop: "loud_speaker"
            opacity: running ? (id_button.pressed ? 0.6 : 1) : 0
            onCurrentFrameChanged: {
                if (-1 === currentPlayId) {
                    id_loud_speeker_playing.stopPlay()
                }
            }
        }

        YImage {
            anchors.centerIn: parent
            sourceSize: Qt.size(46, 46)
            visible: !id_loud_speeker_playing.running
            imageName: "touchreading/loud_speaker_stop"
            opacity: id_button.pressed ? 0.6 : 1
        }
    }

    YTextMedium {
        id: id_tip
        anchors.verticalCenter: parent.verticalCenter
        anchors.right: parent.right
        anchors.rightMargin: 14
        font.pixelSize: 20
        text: "听题目"
        opacity: id_button.pressed ? 0.6 : 1
    }

    YButtonBaseMouseArea {
        id: id_button
        anchors.fill: parent
        onValidClicked: {
            id_interactive_button.validClicked()
        }
        objectName: "YInteractiveQuizzesListenQuestionButton.qml_id_button"
    }
}

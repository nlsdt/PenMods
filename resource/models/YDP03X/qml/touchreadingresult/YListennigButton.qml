import QtQuick 2.12

import BaseQml 1.0

Item {
    id: id_listennig_button
    implicitWidth: 70
    implicitHeight: 70
    anchors.right: parent.right
    anchors.rightMargin: 16
    anchors.verticalCenter: parent.verticalCenter

    signal currentFrameChanged()
    signal validClicked()

    function play() {
        id_loud_speeker_playing.play()
    }

    function stopPlay() {
        id_loud_speeker_playing.stopPlay()
    }

    YAnimatedImagesView {
        id: id_loud_speeker_playing
        objectName: "YListennigButton.qml"
        anchors.centerIn: parent
        frameSize: Qt.size(70, 70)
        frameCountLoop: 35
        imageNameLoop: "loud_speaker"
        opacity: running ? (id_button.pressed ? 0.6 : 1) : 0
        onCurrentFrameChanged: {
            id_listennig_button.currentFrameChanged()
        }
    }

    YImage {
        anchors.centerIn: parent
        sourceSize: Qt.size(70, 70)
        visible: !id_loud_speeker_playing.running
        imageName: "touchreading/loud_speaker_stop"
        opacity: id_button.pressed ? 0.6 : 1
    }

    YButtonBaseMouseArea {
        id: id_button
        anchors.fill: parent
        anchors.margins: -10
        onValidClicked: {
            id_listennig_button.validClicked()
        }
        objectName: "YListennigButton.qml_id_button"
    }
}

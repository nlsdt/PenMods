import QtQuick 2.12
import com.youdao.pen 1.0

import BaseQml 1.0
import "../timers"

Rectangle {
    implicitWidth: 70
    implicitHeight: isStopped ? 70 : 148
    radius: width/2
    color: isStopped ? "#00000000" : "#262752"


    property bool isStopped: true
    property bool isPlaying: false

    Behavior on height {
        NumberAnimation { duration: 120 }
    }

    YIconButton {
        id: id_playback_button
        implicitWidth: 70
        implicitHeight: 70
        radius: height/2
        color: "#333575"
        sourceSize: Qt.size(42, 42)
        imageName: "touchreading/playback_stop"
        onValidClicked: {
            isStopped = !isStopped
        }
    }

    Rectangle {
        id: id_playback_close_button
        implicitWidth: 70
        implicitHeight: 70
        radius: height/2
        color: "#333575"
        border.color: "#5D4EE9"
        border.width: 4
        visible: false

        YAnimatedImagesView {
            id: id_playing_animation
            objectName: "YPlayBackButton.qml"
            frameSize: Qt.size(78, 100)
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.horizontalCenterOffset: -1
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 4
            frameCount: 16
            imageName: "recorder"
            frameCountLoop: 54
            imageNameLoop: "recorder_loop"
        }

        onVisibleChanged: {
            if (visible) {
                id_playing_animation.play()
            } else {
                id_playing_animation.stopPlay()
            }
        }
    }

    Connections {
        target: readingBookReadingManager
        ignoreUnknownSignals: true
        function onAudioPlayStateChanged() {
            switch (readingBookReadingManager.audioPlayState) {
            case YEnum.PAUSED:
            case YEnum.STOPPED:
                isPlaying = false
                break
            case YEnum.PLAYING:
                isPlaying = true
                break
            }
        }
    }

    onIsPlayingChanged: {
        YTimers.delayCall(120, function(){
            id_playback_close_button.visible = isPlaying
        })
    }

    YIconButton {
        id: id_playback_play_pause_button
        implicitWidth: 70
        implicitHeight: 70
        anchors.bottom: parent.bottom
        radius: height/2
        color: "#333575"
        sourceSize: Qt.size(42, 42)
        visible: !isStopped
        imageName: isPlaying ? "touchreading/playback_play" : "touchreading/playback_pause"
        onValidClicked: {
            if (!isPlaying) {
                console.log("YPlayBackButton.qml===playback_play")
                readingBookReadingManager.playAudio(true)
            } else {
                readingBookReadingManager.pauseAudio()
            }
        }
    }
}

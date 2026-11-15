import QtQuick 2.12
import com.youdao.pen 1.0
import BaseQml 1.0
import "../components"

YMouseArea {
    anchors.fill: parent
    anchors.topMargin: -80
    anchors.bottomMargin: -30
    hoverEnabled: true

    property int lstMouseX: 0
    property bool isPlayingBeforePosition: false
    readonly property int nSetp: Math.min(mediaPlayerManager.duration * 0.05, 5000)

    function checkProgressTimeinfo() {
        if (id_player_progress_timeinfo_item.visible) {
            id_check_timer.restart()
            id_player_progress_timeinfo_item.visible = false
        }
    }

    onClicked: {
        if (!id_check_timer.running) {
            mediaPlayerManager.onClickedPause()
            id_pause.visible = true
        }
    }
    onEntered: {
        isPlayingBeforePosition = isPlaying
        lstMouseX = mouseX
    }
    onExited: {
        checkProgressTimeinfo()
    }
    onCanceled: {
        checkProgressTimeinfo()
    }
    onReleased: {
        checkProgressTimeinfo()
    }

    onPositionChanged:{
        if (pressed && !id_pause.visible){
            if (lstMouseX - mouseX > 20){
                mediaPlayerManager.onFastBackward(nSetp)
                lstMouseX = mouseX
                id_player_progress_timeinfo_item.visible = true
                if (mediaPlayerManager.progress <= 0) {
                    id_audio_progress_bar.emptyProgress()
                }
            } else if (lstMouseX - mouseX < -20){
                mediaPlayerManager.onFastForward(nSetp)
                lstMouseX = mouseX
                id_player_progress_timeinfo_item.visible = true
            }
        }
    }

    YTimer {
        id: id_check_timer
        interval: 100
        onTriggered: {
            if (isPlayingBeforePosition) {
                mediaPlayerManager.onClickedPlay()
            }
        }
        objectName: "YGlobeAudioPlayerMouseArea.qml_id_check_timer"
    }

    objectName: "YGlobeAudioPlayerMouseArea.qml_YMouseArea"
}


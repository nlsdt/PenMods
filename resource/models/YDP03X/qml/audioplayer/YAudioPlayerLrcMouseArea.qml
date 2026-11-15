import QtQuick 2.12

import BaseQml 1.0

YMouseArea {
    anchors.fill: parent
    anchors.topMargin: -80
    anchors.bottomMargin: -30
    anchors.leftMargin: -10
    hoverEnabled: true
    enabled: !id_player_state_mask_hide.running

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
            id_player_state_mask_show.show()
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
        if (pressed){
            if (lstMouseX - mouseX > 40){
                mediaPlayerManager.onFastBackward(nSetp)
                id_play_bar.callStopRepeat()
                lstMouseX = mouseX
                id_player_progress_timeinfo_item.visible = true
            } else if (lstMouseX - mouseX < -40){
                mediaPlayerManager.onFastForward(nSetp)
                id_play_bar.callStopRepeat()
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
        objectName: "YAudioPlayerLrcMouseArea.qml_id_check_timer"
    }

    objectName: "YAudioPlayer.qml_YText_hasLrc_YMouseArea"
}


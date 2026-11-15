import QtQuick 2.12

import BaseQml 1.0
import "../timers"

YGuideBackground {
    id: id_touch_reading_follow_play_back_guide

    function play() {
        visible = true
        YTimers.delayCall(120, function(){
            playMp3("follow-playback-notify")
        })
    }

    onEndPlay: {
        YTimers.delayCall(240, function(){
            if ("follow-playback-notify" === playingFileName) {
                id_tip_image.imageName = "touchreading/guide_replay"
                playMp3("follow-playback-start-notify")
            } else {
                visible = false
                closed()
            }
        })
    }

    YImage {
        id: id_tip_image
        anchors.fill: parent
        imageName: "touchreading/guide_switch_audio"
    }
}

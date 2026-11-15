import QtQuick 2.12

import BaseQml 1.0
import "../timers"

YGuideBackground {
    id: id_touch_reading_follow_page_guide

    function play() {
        visible = true
        playMp3("follow-speech-notify")
    }

    onEndPlay: {
        if ("follow-speech-notify" === playingFileName) {
            YTimers.delayCall(120, function(){
                visible = false
                closed()
            })
        }
    }

    YImage {
        anchors.fill: parent
        imageName: "touchreading/guide_follow_speech"
    }
}

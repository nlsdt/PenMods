import QtQuick 2.12

import BaseQml 1.0

YGuideBackground {
    id: id_touch_reading_follow_page_guide

    function play() {
        visible = true
        playMp3("follow-record-notify")
    }

    YTimer {
        id: id_delay_stop_audio_timer
        interval: 480
        onTriggered: {
            visible = false
            closed()
        }
        objectName: "YTouchReadingFollowPageGuide.qml_id_delay_stop_audio_timer"
    }

    onEndPlay: {
        if ("follow-record-notify" === playingFileName) {
            id_delay_stop_audio_timer.restart()
        }
    }

    YImage {
        anchors.fill: parent
        imageName: "touchreading/guide_mic"
    }
}

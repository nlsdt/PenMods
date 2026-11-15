import QtQuick 2.12
import com.youdao.pen 1.0

import BaseQml 1.0

YGuideBackground {
    id: id_guide_page
    objectName: "YInteractiveQuizzesScrollGuide.qml"

    onEndPlay: {
        id_delay_stop_audio_timer.restart()
    }

    function play() {
        visible = true
        playMp3("quiz_scroll_guide")
        id_bg.play()
        id_reading_animation.play()
    }

    YTimer {
        id: id_delay_stop_audio_timer
        interval: 1800

        function stopAnimation() {
            visible = false
            id_bg.stopPlay()
            id_guide_page.stop()
            closed()
        }

        onTriggered: {
            stopAnimation()
        }
        objectName: "YInteractiveQuizzesScrollGuide.qml_id_delay_stop_audio_timer"
    }

    YAnimatedImagesView {
        id: id_bg
        objectName: "YInteractiveQuizzesScrollGuide.qml_id_bg"
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: 20
        frameSize: Qt.size(200, 118)
        scale: 0.84
        frameCountLoop: 93
        imageNameLoop: "quiz_scroll_guide"
    }

    YTextMedium {
        id: id_tips
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 14
        font.family: fontManager.fontFamilyZhCn
        text: "上下滑动可以查看更多题目信息"
    }
}

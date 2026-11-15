import QtQuick 2.12
import com.youdao.pen 1.0

import BaseQml 1.0

YGuideBackground {
    id: id_guide_page
    objectName: "YReviewGuideBase.qml"

    property string guideAudioName: "follow-review-guide"

    property alias text: id_tips_content.text

    onEndPlay: {
        id_delay_stop_audio_timer.restart()
    }

    function play() {
        visible = true
        playMp3(guideAudioName)
        id_bg.play()
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
        objectName: "YReviewGuideBase.qml_id_delay_stop_audio_timer"
    }

    YAnimatedImagesView {
        id: id_bg
        objectName: "YReviewGuideBase.qml_id_bg"
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: 16
        frameSize: Qt.size(206, 128)
        frameCountLoop: 128
        imageNameLoop: "review_hand"
    }

    YTextMedium {
        id: id_tips_content
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 14
        font.family: fontManager.fontFamilyZhCn
        text: "左右滑动查看上/下一题呦"
    }
}

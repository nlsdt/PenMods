import QtQuick 2.12
import com.youdao.pen 1.0

import BaseQml 1.0
import "../i18n"

YTouchFollowReadingAudioPlayBase {
    id: id_guide_page
    objectName: "YInteractiveQuizzesResultRight.qml"
    anchors.fill: parent
    visible: false

    signal closed()

    onEndPlay: {
        id_delay_stop_audio_timer.restart()
    }

    function play() {
        visible = true
        playMp3("follow-review-guide")
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
        objectName: "YInteractiveQuizzesReviewGuide.qml_id_delay_stop_audio_timer"
    }

    Rectangle {
        implicitWidth: 370
        implicitHeight: 214
        color: "#373A5C"
        radius: 36
        anchors.centerIn: parent

        YAnimatedImagesView {
            id: id_bg
            objectName: "YInteractiveQuizzesReviewGuide.qml_id_bg"
            anchors.horizontalCenter: parent.horizontalCenter
            frameSize: Qt.size(290, 180)
            frameCountLoop: 129
            imageNameLoop: "review_hand"
        }

        YTextMedium {
            id: id_title
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 34
            font.pixelSize: 24
            font.wordSpacing: 2
            font.family: fontManager.fontFamilyZhCn
            text: YTranslateText.reviewGuideText
        }
    }

    YAnimatedImagesView {
        id: id_reading_animation
        objectName: "YInteractiveQuizzesReviewGuide.qml_id_reading_animation"
        frameSize: Qt.size(218, 164)
        anchors.left: parent.left
        anchors.bottom: parent.bottom
        frameDuration: 40

        frameCount: 20
        frameCountLoop: 106

        imageName: "follow_matti_scaled_mirrored"
        imageNameLoop: "follow_matti_scaled_mirrored_loop"
    }
}

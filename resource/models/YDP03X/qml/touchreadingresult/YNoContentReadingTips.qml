import QtQuick 2.12
import com.youdao.pen 1.0

import BaseQml 1.0
import "../i18n"

YTouchFollowReadingAudioPlayBase {
    anchors.fill: parent
    objectName: "YNoContentReadingTips.qml_object"

    function play() {
        id_reading_animation.play()
    }

    function stop() {
        id_reading_animation.stopPlay()
    }

    YImage {
        sourceSize: Qt.size(800, 254)
        imageName: "touchreading/no_content_bg"

        YAnimatedImagesView {
            id: id_reading_animation
            objectName: "YNoContentReadingTips.qml"
            frameSize: Qt.size(250, 220)
            anchors.right: parent.right
            anchors.rightMargin: 33
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 7
            imageNameLoop: "matti_no_content"
            frameCountLoop: 40
        }
    }

    YImage {
        id: id_scan_touch_tips_intersperse
        sourceSize: Qt.size(31, 10)
        imageName: "touchreading/scan_touch_tips_intersperse"
        anchors.left: parent.left
        anchors.leftMargin: 60
        anchors.top: parent.top
        anchors.topMargin: 88
    }

    YTextMedium {
        id: id_title
        anchors.left: parent.left
        anchors.leftMargin: 56
        anchors.top: id_scan_touch_tips_intersperse.bottom
        anchors.topMargin: 8
        font.pixelSize: 38
        font.wordSpacing: 2
        text: YTranslateText.hereNoContentTip
        font.family: fontManager.fontFamilyZhCn
    }

    YText {
        anchors.left: id_title.left
        anchors.top: id_title.bottom
        anchors.topMargin: 20
        font.pixelSize: 22
        text: YTranslateText.touchOtherWhereTip
        font.family: fontManager.fontFamilyZhCn
    }
}

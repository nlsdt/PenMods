import QtQuick 2.12
import com.youdao.pen 1.0

import BaseQml 1.0
import "../i18n"

YBackgroundIgnoreMouseEvent {
    objectName: "YTouchBookReadingTips.qml_object"
    visible: false
    anchors.fill: parent

    function play() {
        visible = true
        id_reading_animation.play()
    }

    function stop() {
        id_reading_animation.stopPlay()
    }

    YImage {
        sourceSize: Qt.size(800, 254)
        imageName: "touchreading/scan_touch_bg"
        asynchronous: false
    }

    YImage {
        id: id_scan_touch_tips_intersperse
        sourceSize: Qt.size(31, 10)
        imageName: "touchreading/scan_touch_tips_intersperse"
        anchors.left: parent.left
        anchors.leftMargin: 60
        anchors.top: parent.top
        anchors.topMargin: 63
    }

    YTextMedium {
        id: id_title
        anchors.left: parent.left
        anchors.leftMargin: 56
        anchors.top: id_scan_touch_tips_intersperse.bottom
        anchors.topMargin: 8
        font.pixelSize: 38
        font.wordSpacing: 2
        font.bold: true
        font.family: fontManager.fontFamilyZhCn
        text: YTranslateText.readingFollowMatti
    }

    YText {
        anchors.left: id_title.left
        anchors.top: id_title.bottom
        anchors.topMargin: 20
        font.pixelSize: 22
        font.family: fontManager.fontFamilyZhCn
        textFormat: YText.RichText
        text: YTranslateText.startFollowReadingTip
    }

    YAnimatedImagesView {
        id: id_reading_animation
        objectName: "YFollowMattiReadingTips.qml"
        frameSize: Qt.size(275, 206)
        anchors.verticalCenter: parent.verticalCenter
        anchors.right: parent.right
        anchors.rightMargin: 44

        frameCount: 20
        frameCountLoop: 106

        imageName: "follow_matti"
        imageNameLoop: "follow_matti_loop"
    }
}

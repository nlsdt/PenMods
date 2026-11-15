import QtQuick 2.12
import com.youdao.pen 1.0

import BaseQml 1.0
import "../i18n"

YBackgroundIgnoreMouseEvent {
    objectName: "YTouchBookReadingTips.qml_object"
    visible: false
    anchors.fill: parent

    property alias text: id_tips.text

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

    Column {
        anchors.left: parent.left
        anchors.leftMargin: 60
        spacing: 8
        anchors.verticalCenter: parent.verticalCenter

        YImage {
            sourceSize: Qt.size(31, 10)
            imageName: "touchreading/scan_touch_tips_intersperse"
            anchors.left: parent.left
            anchors.leftMargin: 4
        }

        YTextMedium {
            id: id_tips
            font.pixelSize: 28
            font.bold: true
            font.family: fontManager.fontFamilyZhCn
            textFormat: YTextMedium.RichText
            text: YTranslateText.startReadingBook
        }
    }

    YAnimatedImagesView {
        id: id_reading_animation
        objectName: "YTouchBookReadingTips.qml"
        frameSize: Qt.size(306, 206)
        anchors.verticalCenter: parent.verticalCenter
        anchors.right: parent.right
        anchors.rightMargin: 34
        frameCount: 75
        frameCountLoop: 26

        imageName: "matti_reading"
        imageNameLoop: "matti_reading_loop"
    }
}


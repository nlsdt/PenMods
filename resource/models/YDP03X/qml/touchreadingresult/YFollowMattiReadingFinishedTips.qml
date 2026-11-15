import QtQuick 2.12
import com.youdao.pen 1.0

import BaseQml 1.0
import "../i18n"

YTouchFollowReadingAudioPlayBase {
    id: id_follow_matti_reading_finished_tips
    anchors.fill: parent

    objectName: "YFollowMattiReadingFinishedTips.qml_object"
    onEndPlay: {
        stop()
    }

    readonly property int starCount: readingBookReadingManager.followStars

    function play() {
        playMp3("follow-seg-finish-notify")
        id_reading_animation.play()
    }

    function stop() {
        id_reading_animation.stopPlay()
        id_follow_matti_reading_finished_tips.visible = false
        id_follow_matti_reading_finished_tips.destroy()
    }

    YBackground {
        anchors.fill: parent
        color: YColors.touchReadingBg
        Rectangle {
            implicitWidth: 472
            implicitHeight: 454
            radius: width/2
            color: "#1A31ECFF"
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.rightMargin: -241
            anchors.bottomMargin: -250
        }
    }

    Column {
        anchors.left: parent.left
        anchors.leftMargin: 40
        spacing: 8
        anchors.verticalCenter: parent.verticalCenter

        YImage {
            sourceSize: Qt.size(31, 10)
            imageName: "touchreading/scan_touch_tips_intersperse"
            anchors.left: parent.left
            anchors.leftMargin: 4
        }

        YTextMedium {
            id: id_title
            font.pixelSize: 38
            font.bold: true
            font.family: fontManager.fontFamilyZhCn
            textFormat: YTextMedium.RichText
            text: YTranslateText.followFinishedGetStarCount.arg(starCount)
        }
    }

    YAnimatedImagesView {
        id: id_reading_animation
        objectName: "YFollowMattiReadingFinishedTips.qml"
        frameSize: Qt.size(480, 254)
        anchors.verticalCenter: parent.verticalCenter
        anchors.right: parent.right
        frameCountLoop: 60
        imageNameLoop: "matti_get_star"
    }
}


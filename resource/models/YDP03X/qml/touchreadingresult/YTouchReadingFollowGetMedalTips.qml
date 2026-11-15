import QtQuick 2.12
import com.youdao.pen 1.0

import BaseQml 1.0
import "../components"
import "../i18n"

Item {
    function play() {
        id_reading_animation.play()
    }

    function stop() {
        id_reading_animation.stopPlay()
    }

    property alias source: id_current_medal_icon.source

    YAnimatedImagesView {
        id: id_reading_animation
        objectName: "YTouchReadingFollowGetMedalTips.qml"
        frameSize: Qt.size(350, 206)
        anchors.right: parent.right
        anchors.rightMargin: 34
        anchors.verticalCenter: parent.verticalCenter
        frameCount: 63
        frameCountLoop: 38

        imageName: "follow_medal_get"
        imageNameLoop: "follow_medal_get_loop"
    }

    Item {
        implicitWidth: 78
        implicitHeight: 78
        anchors.top: parent.top
        anchors.topMargin: 96
        anchors.right: parent.right
        anchors.rightMargin: 222
        YAspectFitAlignCenterImage {
            id: id_current_medal_icon
            width: parent.width
            height: parent.height
            anchors.centerIn: parent
            scale: 0
            onLoaded: {
                id_current_medal_icon_animator.running = true
            }
            ScaleAnimator {
                id: id_current_medal_icon_animator
                target: id_current_medal_icon
                from: 0
                to: 1
                duration: 1000
                loops: 1
                running: false
            }
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
        font.family: fontManager.fontFamilyZhCn
        text: YTranslateText.readingBookFinishedTip
    }

    YText {
        anchors.left: id_title.left
        anchors.top: id_title.bottom
        anchors.topMargin: 20
        font.pixelSize: 22
        font.family: fontManager.fontFamilyZhCn
        text: YTranslateText.readingBookFinishedGetMedal
    }
}

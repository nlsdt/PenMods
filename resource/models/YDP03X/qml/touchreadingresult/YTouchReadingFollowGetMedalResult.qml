import QtQuick 2.12
import com.youdao.pen 1.0

import BaseQml 1.0
import "../components"
import "../i18n"

Item {

    function play() {
        id_reading_animation.play()
    }

    property alias source: id_current_medal_icon.source
    property string metalTitle: ""

    function stop() {
    }

    YAnimatedImagesView {
        id: id_reading_animation
        objectName: "YTouchReadingFollowGetMedalResult.qml"
        frameSize: Qt.size(280, 206)
        anchors.right: parent.right
        anchors.rightMargin: 34
        anchors.verticalCenter: parent.verticalCenter
        frameCount: 120
        imageName: "follow_medal_result"

        YAspectFitAlignCenterImage {
            id: id_current_medal_icon
            width: 211
            height: 155
            anchors.centerIn: parent
        }
    }

    YImage {
        id: id_scan_touch_tips_intersperse
        sourceSize: Qt.size(31, 10)
        imageName: "touchreading/scan_touch_tips_intersperse"
        anchors.left: parent.left
        anchors.leftMargin: 60
        anchors.top: parent.top
        anchors.topMargin: 54
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
        textFormat: YTextMedium.RichText
        text: YTranslateText.getOneMedal.arg(metalTitle)
    }

    YText {
        anchors.left: id_title.left
        anchors.top: id_title.bottom
        anchors.topMargin: 20
        font.pixelSize: 22
        textFormat: YText.RichText
        font.family: fontManager.fontFamilyZhCn
        text: YTranslateText.getOneMedalCheckWhere.arg("#26FFFF")
    }
}

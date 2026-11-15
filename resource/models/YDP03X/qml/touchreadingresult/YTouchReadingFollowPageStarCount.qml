import QtQuick 2.12
import com.youdao.pen 1.0

import BaseQml 1.0

YIconLabelButton {
    id: id_star_count_indicator
    anchors.top: parent.top
    anchors.topMargin: 8
    anchors.right: parent.right
    anchors.rightMargin: 8
    implicitHeight: 42
    radius: height/2
    color: "#1B1C30"
    border.width: 3
    border.color: "#21223A"
    spacing: 4
    sourceSize: Qt.size(30, 30)
    imageName: "touchreading/star"
    textColor: "#3E406B"
    pixelSize: 24
    textFontFamily: fontManager.fontFamilyPinyin
    textFontWeight: Font.Bold
    textItem.anchors.verticalCenter: id_star_count_indicator.verticalCenter
    textItem.anchors.verticalCenterOffset: 2
    clickable: false
    leftMargin: 12

    function playStarIncrease() {
        iconVisible = false
        id_playing_animation.play()
    }

    Item {
        implicitWidth: 30
        implicitHeight: 30
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        anchors.leftMargin: 12
        visible: id_playing_animation.running

        YAnimatedImagesView {
            id: id_playing_animation
            objectName: "YTouchReadingFollowPageStarCount.qml"
            frameSize: Qt.size(70, 70)
            anchors.centerIn: parent
            frameCount: 40
            imageName: "star_increase"
            loops: 1
            onEnterAnimatedImagePlayEnd: {
                iconVisible = true
            }
            onRunningChanged: {
                if (!running) {
                    iconVisible = true
                }
            }
        }
    }
}

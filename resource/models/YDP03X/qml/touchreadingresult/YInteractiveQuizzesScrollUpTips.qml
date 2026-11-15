import QtQuick 2.12

import BaseQml 1.0

Rectangle {
    implicitWidth: 800
    implicitHeight: 100

    gradient: Gradient {
        GradientStop { position: 0.0; color: "transparent" }
        GradientStop { position: 1.0; color: "black" }
    }


    YImage {
        id: id_tip_arrow
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 26
        sourceSize: Qt.size(30, 30)
        imageName: "touchreading/quiz_scroll_up_arrow"
    }

    YTextMedium {
        id: id_tips
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 10
        font.family: fontManager.fontFamilyZhCn
        color: YColors.yellow
        text: "向上滑动查看更多"
    }

    SequentialAnimation {
        running: true
        NumberAnimation { target: id_tip_arrow; property: "anchors.bottomMargin"; to: 32; duration: 1000 }
        NumberAnimation { target: id_tip_arrow; property: "anchors.bottomMargin"; to: 26; duration: 1000 }
        loops: NumberAnimation.Infinite
    }
}

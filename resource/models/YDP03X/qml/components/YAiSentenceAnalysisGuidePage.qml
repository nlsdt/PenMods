import QtQuick 2.12
import com.youdao.pen 1.0

import BaseQml 1.0
/*YGuideBackground*/Rectangle{
    anchors.fill: parent
    id: id_follow_guide_page
    objectName: "YFollowGuidePage.qml"
    color: "transparent"
    Rectangle {
        anchors.fill: parent
        color: "#000000"
        opacity: 0.8
    }

    YImage {
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.rightMargin: 156
        anchors.topMargin: 87
        width: 305
        height: 74
        sourceSize: Qt.size(width, height)
        imageName: "dict/ai_sentence_guide_icon"
        fillMode: Image.PreserveAspectFit
    }

//    YImage {
//        anchors.right: parent.right
//        anchors.top: parent.top
//        anchors.rightMargin: 13
//        anchors.topMargin: 93
//        width: 68
//        height: 68
//        sourceSize: Qt.size(width, height)
//        imageName: "dict/follow_ai_icon"
//        fillMode: Image.PreserveAspectFit
//    }
    YIconButton {
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.rightMargin: 16
        anchors.topMargin: 92
        implicitWidth: 80
        implicitHeight: 70
//        anchors.horizontalCenter: parent.horizontalCenter
        icon: "dict/dict_ai_white_sentence"
    }

    YImage {
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.rightMargin: 71
        anchors.topMargin: 151
        width: 49
        height: 61
        sourceSize: Qt.size(width, height)
        imageName: "dict/follow_guide_hand_icon"
        fillMode: Image.PreserveAspectFit
    }

}

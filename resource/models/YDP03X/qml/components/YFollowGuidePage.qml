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
        anchors.rightMargin: 113
        anchors.topMargin: 46
        width: 170
        height: 162
        sourceSize: Qt.size(width, height)
        imageName: "dict/follow_guide_icon"
        fillMode: Image.PreserveAspectFit
    }

    YImage {
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.rightMargin: 13
        anchors.topMargin: 93
        width: 68
        height: 68
        sourceSize: Qt.size(width, height)
        imageName: "dict/follow_ai_icon"
        fillMode: Image.PreserveAspectFit
    }

    YImage {
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.rightMargin: 59
        anchors.topMargin: 141
        width: 36
        height: 45
        sourceSize: Qt.size(width, height)
        imageName: "dict/follow_guide_hand_icon"
        fillMode: Image.PreserveAspectFit
    }

}

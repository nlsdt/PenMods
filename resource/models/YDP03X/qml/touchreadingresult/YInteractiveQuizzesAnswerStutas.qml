import QtQuick 2.12

import BaseQml 1.0

Item {
    anchors.fill: parent

    property int solidLineRadius: height/2
    property Component dashLineComponent: YImage {
        sourceSize: Qt.size(96, 96)
        imageName: "touchreading/mask_answer_error"
    }
    property Component solidLineComponent: Rectangle {
        color: "transparent"
        radius: solidLineRadius
        border.color: "#2295FF"
        border.width: 2
    }

    YLoader {
        anchors.fill: parent
        active: {
            if (answerContentGroup === selectedAnswerContentGroup) {
                if ("n" === answerResult) {
                    return true
                }
            }
            if ((answerResult.length > 0) && ("y" === model.modelData.option_isTrue)) {
                return true
            }
            return false
        }
        sourceComponent: ("touchreading/quizze_txt_error"
                          === id_selcted_indicator.imageName)
                         ? dashLineComponent : solidLineComponent
    }

    YIconButton {
        id: id_selcted_indicator
        implicitWidth: 32
        implicitHeight: 32
        radius: height/2
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        sourceSize: Qt.size(20, 20)
        visible: imageName.length > 0
        color: {
            if (answerContentGroup === selectedAnswerContentGroup) {
                if ("n" === answerResult) {
                    return "#FF5847"
                }
            }
            if ((answerResult.length > 0) && ("y" === model.modelData.option_isTrue)) {
                return "#2295FF"
            }
            return YColors.transparent
        }
        imageName: {
            if (answerContentGroup === selectedAnswerContentGroup) {
                if ("n" === answerResult) {
                    return "touchreading/quizze_txt_error"
                }
            }
            if ((answerResult.length > 0) && ("y" === model.modelData.option_isTrue)) {
                return "touchreading/quizze_txt_right"
            }
            return ""
        }
    }
}

import QtQuick 2.12

import BaseQml 1.0
import "../components"

YAnswerQuestionOptionItem {
    objectName: "YInteractiveQuizzesImageQuestionItem.qml===YMouseArea"
    backgroundItem.radius: id_icon.maskItem.radius

    YOpacityMaskImage {
        id: id_icon
        anchors.fill: parent
        source: qmlGlobal.fileExists(model.modelData.option_image)
                ? model.modelData.option_image.toLoadFileUrl() : ""
        maskItem.radius: 28
    }

    YLoader {
        id: id_answer_status_loader
        active: answerCompleted
        anchors.fill: parent
        sourceComponent: Item {
            YImage {
                sourceSize: Qt.size(51, 51)
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                imageName: {
                    if (answerCompleted) {
                        if ("n" === answerResult) {
                            return "touchreading/quizze_error"
                        }
                    }
                    if ((answerResult.length > 0) && ("y" === model.modelData.option_isTrue)) {
                        return "touchreading/quizze_right"
                    }
                    return ""
                }
            }

            Rectangle {
                anchors.fill: parent
                color: "transparent"
                radius: 30
                border.color: "y" === answerResult ? "#0073FF" : "#FF6D12"
                border.width: visible ? 6 : 0
            }
        }
    }
}

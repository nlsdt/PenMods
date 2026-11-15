import QtQuick 2.12

import BaseQml 1.0

YAnswerQuestionOptionItem {
    id: id_quiz_learning_start_to_answer_text_question_item
    implicitWidth: {
        if (("three" === id_interactive_quizzes_delegate.state)
                && ("word" === contentType)) {
            return 660
        }
        return isFiveType ? 430 : 164
    }
    implicitHeight: {
        if (("three" === id_interactive_quizzes_delegate.state)
                && ("word" === contentType)) {
            return 76
        }
        return isFiveType ? 102 : 164
    }
    backgroundItem.radius: (1 === columnsCount) ? height/2 : 28

    readonly property alias textItem: id_text_item

    YTextMedium {
        id: id_text_item
        font.weight: Font.Bold
        text: model.modelData.option_text.trim()
        anchors.left: parent.left
        anchors.leftMargin: 20
        anchors.right: parent.right
        anchors.rightMargin: 96
        wrapMode: YTextEnUs.Wrap
        anchors.verticalCenter: parent.verticalCenter
        font.pixelSize: 26
//        onLineCountChanged: {
//            if (lineCount > 1) {
//                font.pixelSize = 16
//            }
//        }
        font.family: {
            if (text.match(/[\u3400-\u9FBF]/)) {
                return fontManager.fontFamilyZhCn
            }
            return fontManager.fontFamilyEnUs
        }
//        onTextChanged: {
//            if (isFiveType) {
//                if (currentTextLength < 11) {
//                    font.pixelSize = 40
//                } else if (currentTextLength >= 11 && currentTextLength <= 16) {
//                    font.pixelSize = 34
//                } else {
//                    font.pixelSize = 26
//                }
//            } else {
//                switch (currentTextLength) {
//                case 1:
//                    font.pixelSize = 52
//                    break
//                case 2:
//                case 3:
//                    font.pixelSize = 40
//                    break
//                default:
//                    font.pixelSize = 26
//                    break
//                }
//            }
//        }
        color: {
            if (answerCompleted) {
                return "y" === answerResult ? "#EAFCFF" : "#FFFDE3"
            }
            return "#B9B7E7"
        }
        horizontalAlignment: Text.AlignLeft
    }

    YLoader {
        anchors.right: parent.right
        anchors.rightMargin: 34
        anchors.verticalCenter: parent.verticalCenter
        active: answerCompleted
        sourceComponent: YImage {
            sourceSize: Qt.size(52, 52)
            imageName: {
                if (answerCompleted) {
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

}

import QtQuick 2.12

import BaseQml 1.0

YAnswerQuestionOptionItem {
    implicitWidth: 660
    implicitHeight: 76

    readonly property alias textItem: id_text_item

    YTextEnUs {
        id: id_text_item
        font.weight: Font.Bold
        text: model.modelData.option_text.trim()
        anchors.left: parent.left
        anchors.leftMargin: 20
        anchors.right: parent.right
        anchors.rightMargin: 96
        wrapMode: YTextEnUs.Wrap
        anchors.verticalCenter: parent.verticalCenter
        horizontalAlignment: YTextEnUs.AlignLeft
        function hasWhiteSpace(s) {
            return /\s/g.test(s);
        }
        font.pixelSize: 26 // hasWhiteSpace(text) ? 20 : 26
        font.family: {
            if (text.match(/[\u3400-\u9FBF]/)) {
                return fontManager.fontFamilyZhCn
            }
            return fontManager.fontFamilyEnUs
        }
        color: {
            if (answerCompleted) {
                return "y" === answerResult ? "#EAFCFF" : "#FFFDE3"
            }
            return "#B9B7E7"
        }
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

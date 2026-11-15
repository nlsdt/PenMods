import QtQuick 2.12
import com.youdao.pen 1.0

import BaseQml 1.0
import "../components"
import "../i18n"

YQuizLearningDelegate {
    id: id_word_card_item
    explainImgs: jsonContent.explain_img
    explainImgsCount: 1
    sourceComponent: Rectangle {
        color: YColors.grayNormal
        radius: 28

        YOpacityMaskImage {
            id: id_icon_left
            width: visible ? 110 : 0
            height: visible ? 110 : 0
            maskItem.radius: 28
            source: (explainImgs.length > 0) && qmlGlobal.fileExists(explainImgs)
                    ? explainImgs.toLoadFileUrl() : ""
            visible: source.toString().length
        }

        Item {
            id: id_text_container
            implicitHeight: 110
            width: parent.width - id_icon_left.width
            anchors.right: parent.right

            YTextMedium {
                id: id_text
                width: paintedWidth
                height: paintedHeight
                anchors.centerIn: parent
                font.family: fontManager.fontFamilyZhCn
                font.pixelSize: {
                    const txtLength = jsonContent.explain_text.trim().length
                    if (txtLength <= 2) {
                        return 54
                    } else if (txtLength <= 3) {
                        return 40
                    }
                    return 26
                }
                textFormat: YTextMedium.RichText
                text: jsonContent.explain_text
                wrapMode: Text.NoWrap
                anchors.horizontalCenter: parent.horizontalCenter
            }
        }
    }
}

import QtQuick 2.12
import com.youdao.pen 1.0

import "../commons"
import "../i18n"

Column {
    id: id_translate_content_col
    spacing: 10

    property var jsonPoemData:   dictJson

    Repeater {
        id: id_detail_translate_repeater
        model: jsonPoemData

        Column {
            id: id_detail_translate_column
            spacing: 4
            width: parent.width
            anchors.left: parent.left
            //anchors.right: parent.right
            readonly property var modelModelData: model.modelData

            YText {
                anchors.left: parent.left
                width: parent.width
                height: paintedHeight
                font.family: qmlGlobal.fontFamilyZhCn
                color: YColors.grayText
                wrapMode: YTextBase.Wrap
                font.pixelSize: 20
                text: {
                    let qsOriginSentence = ""
                    id_detail_translate_column.modelModelData.sentences.forEach(function(sentencesObject){
                        qsOriginSentence += sentencesObject.origin
                    })
                    return qsOriginSentence
                }
                visible: id_poem_translate_text.visible
            }

            YTextMedium {
                id: id_poem_translate_text
                anchors.left: parent.left
                width: parent.width
                height: paintedHeight
                font.family: qmlGlobal.fontFamilyZhCn
                font.pixelSize: 22
                color: YColors.white
                wrapMode: YTextBase.Wrap
                text: {
                    let qslTranslate = ""
                    id_detail_translate_column.modelModelData.sentences.forEach(function(sentencesObject){
                        qslTranslate += typeof sentencesObject.translate !== "undefined" ? sentencesObject.translate : ""
                    })
                    return qslTranslate
                }
                visible: text.length > 0
            }

        } // Column id_detail_translate_column

    } // Repeater id_detail_translate_repeater

}



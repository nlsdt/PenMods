import QtQuick 2.12
import com.youdao.pen 1.0

import "../commons"
import "../i18n"

Column {
    spacing: 10
    id: id_poem_dict_data_column

    property var jsonPoemData: {

       return  dictJson
    }

    onJsonPoemDataChanged: {
        iExplanationIndex = 0
    }

    property var iExplanationIndex: 0
//    YTextBase {
//        id: id_detail_explanation_text
//        anchors.left: parent.left
//        font.pixelSize: 20
//        font.family: qmlGlobal.fontFamily
//        font.weight: Font.Normal
//        color: YColors.wordBlue
//        width: parent.width
//        //                height: contentHeight + 16
//        text: YTranslateText.annotation
//        //                topPadding: 16
//        visible: iExplanationIndex > 0


//    }

    Repeater {
        id: id_detail_explanation_repeater
        model: {
            if (jsonPoemData !== null) {
                return jsonPoemData
            }
            return []
        }

        Column {
            id: id_detail_explanation_column
            anchors.left: parent.left
            width: id_poem_dict_data_column.width
            spacing: 10
            readonly property var modelModelData: model.modelData

            Repeater {
                id: id_detail_explanation_sentence_repeater
                model: id_detail_explanation_column.modelModelData.sentences

                Column {
                    id: id_detail_explanation_sentence_column
                    width: id_poem_dict_data_column.width
                    spacing: 10
                    readonly property var modelModelData: model.modelData

                    Repeater {
                        id: id_detail_explanation_sentence_explanation_repeater
                        model: {
                            //兼容数据错误
                            let explanationArray = []
                            for(let i = 0; i < id_detail_explanation_sentence_column.modelModelData.explanations.length; i++) {
                                explanationArray[id_detail_explanation_sentence_column.modelModelData.origin.indexOf(
                                                      id_detail_explanation_sentence_column.modelModelData.explanations[i].word )] =
                                         id_detail_explanation_sentence_column.modelModelData.explanations[i]
                            }
                            let modelDataArray = []
                            explanationArray.forEach( function(item) {
                                modelDataArray.push(item)
                            } )
                            return modelDataArray.length ? modelDataArray : id_detail_explanation_sentence_column.modelModelData.explanations
                        }

                        YText {
                            anchors.left: parent.left
                            width: id_poem_dict_data_column.width
                            font.family: qmlGlobal.fontFamilyZhCn
                            font.pixelSize: 22
                            wrapMode: YTextBase.Wrap
                            textFormat: YTextBase.RichText
                            Component.onCompleted: {
                                id_poem_dict_data_column.iExplanationIndex += 1
                                text = ('<span style="color:%1;">[').arg(YColors.grayText) + id_poem_dict_data_column.iExplanationIndex + ']</span>'
                                        + qmlGlobal.getChinese(model.modelData.word) + ':&nbsp;' + qmlGlobal.getChinese(model.modelData.meaning)
                            }
                        }

                    } // Repeater id_detail_explanation_sentence_explanation_repeater

                } // Column id_detail_explanation_sentence_column

            } // Repeater id_detail_explanation_sentence_repeater

        } // Column id_detail_translate_column

    } // Repeater id_detail_explanation_repeater
    //        }
}


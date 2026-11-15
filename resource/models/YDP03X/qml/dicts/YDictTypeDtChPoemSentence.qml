import QtQuick 2.12

import BaseQml 1.0
import "../i18n"
import "../components"

Item {
    id: id_poem_sentence_dict
    height: id_poem_sentence_dict_column.height

    property var jsonPoemData: null
    property var sentenceKeyWord: []
    property int nCurExplanationIdx: 0
    property int iExplanationIndex: 1
    property var poemSentenceArr: []
    property var poemAnnotationArr: []
    onJsonPoemDataChanged: {
        nCurExplanationIdx = 0
        iExplanationIndex = 1
        poemSentenceArr = []
        poemAnnotationArr= []
        if (sentenceKeyWord.length > 0) {
            sentenceKeyWord.forEach(function(sentenceKey){
                jsonPoemData.detail.content.forEach(function(contentObj){
                    contentObj.sentences.forEach(function(sentenceObj){
                        if (sentenceObj.origin.indexOf(sentenceKey) >= 0) {
                            poemSentenceArr.push(sentenceObj)
                        }
                    })
                })
            })
        }
    }

    Column {
        id: id_poem_sentence_dict_column
        width: id_poem_sentence_dict.width
        spacing: 10

        Repeater {
            id: id_detail_explanation_sentence_repeater
            model: id_poem_sentence_dict.poemSentenceArr

            Column {
                id: id_detail_explanation_sentence_column
                width: id_poem_sentence_dict.width
                spacing: 16
                readonly property var modelModelData: model.modelData

                Column {
                    width: id_poem_sentence_dict.width
                    spacing: 10

                    YTextMedium {
                        width: parent.width
                        height: paintedHeight
                        font.family: fontManager.fontFamilyZhCn
                        color: YColors.grayText
                        wrapMode: YTextBase.Wrap
                        textFormat: YTextBase.RichText
                        visible: id_detail_explanation_sentence_column.modelModelData !== null
                        Component.onCompleted: {
                            let qsFormatResult = ""
                            console.log("YDictTypeDtChPoemSentence.qml === poem sentence formatted:", id_detail_explanation_sentence_column.modelModelData.formatted)
                            if (id_detail_explanation_sentence_column.modelModelData !== null)
                            {
                                qsFormatResult = id_detail_explanation_sentence_column.modelModelData.formatted;
                                qsFormatResult = qsFormatResult.replace(/mark/g, "u");
                                console.log("YDictTypeDtChPoemSentence.qml === poem sentence qsFormatResult after replace:", qsFormatResult)
                                var nExplanationPos = 0;
                                var nLastPos = 0;
                                while ((nExplanationPos = qsFormatResult.indexOf("</u>", nLastPos)) !== -1)
                                {
                                    id_poem_sentence_dict.nCurExplanationIdx++;
                                    qsFormatResult = qsFormatResult.slice(0, nExplanationPos + 4)
                                            + "[" + id_poem_sentence_dict.nCurExplanationIdx + "]"
                                            + qsFormatResult.slice(nExplanationPos + 4);
                                    nLastPos = nExplanationPos + 4;
                                }
                            }
                            console.log("YDictTypeDtChPoemSentence.qml === poem sentence qsFormatResult:", qsFormatResult)
                            text = qsFormatResult;
                            if(typeof id_detail_explanation_sentence_column.modelModelData.explanations != "undefined")
                                poemAnnotationArr = poemAnnotationArr.concat(id_detail_explanation_sentence_column.modelModelData.explanations)
                        }
                    }

                    YTextMedium {
                        id: id_poem_translate_text
                        width: parent.width
                        height: paintedHeight
                        font.family: fontManager.fontFamilyZhCn
                        font.pixelSize: 28
                        color: "#FFFFFF"
                        wrapMode: YTextBase.Wrap
                        text: visible ? id_detail_explanation_sentence_column.modelModelData.translate : ""
                        visible: id_detail_explanation_sentence_column.modelModelData !== null
                    }


                } // Column id_detail_translate_column

            } // Column id_detail_explanation_sentence_column

        } // Repeater id_detail_explanation_sentence_repeater

        YTextBase {
            id: id_detail_explanation_text
            font.pixelSize: 26
            font.family: fontManager.fontFamily
            font.weight: Font.Normal
            color: YColors.red
            width: parent.width
            height: contentHeight + 16
            text: YTranslateText.annotation
            topPadding: 16
            visible: {
                if(id_poem_sentence_dict.poemSentenceArr.length) {
                    return id_poem_sentence_dict.poemSentenceArr[0] !== null
                            && typeof id_poem_sentence_dict.poemSentenceArr[0].explanations != "undefined"
                            && id_poem_sentence_dict.poemSentenceArr[0].explanations.length > 0

                } else
                    return false
            }
            Component.onCompleted: {
                dictNodeCompleted(text, dictType, 1, this);
            }
        }

        Column {
            anchors.left: parent.left
            width: id_poem_sentence_dict.width
            spacing: 10
            Repeater {
                id: id_detail_explanation_sentence_explanation_repeater
                model: id_detail_explanation_text.visible && poemAnnotationArr.length ? poemAnnotationArr : null

                YTextMedium {
                    width: id_poem_sentence_dict.width
                    height: paintedHeight
                    font.family: fontManager.fontFamilyZhCn
                    font.pixelSize: 28
                    color: "#FFFFFF"
                    wrapMode: YTextBase.Wrap
                    textFormat: YTextBase.RichText
                    Component.onCompleted: {
                        let qsExplanation = ('<span style="color:%1;">[').arg(YColors.grayText) + (index+1)/*id_poem_sentence_dict.iExplanationIndex*/ + ']</span>'
                        qsExplanation += qmlGlobal.getChinese(model.modelData.word) + ':&nbsp;' + qmlGlobal.getChinese(model.modelData.meaning)
                        text = qsExplanation
                        //id_poem_sentence_dict.iExplanationIndex += 1
                    }
                }

            } // Repeater id_detail_explanation_sentence_explanation_repeater

        }

        YTextBase {
            id: id_poem_source_text
            font.pixelSize: 26
            font.family: fontManager.fontFamily
            font.weight: Font.Normal
            color: YColors.red
            width: parent.width
            height: contentHeight
            text: YTranslateText.idiomSource
            //topPadding: 16
            visible: id_poems_titlse_value.visible
            Component.onCompleted: {
                dictNodeCompleted(text, dictType, 1, this);
            }
        }

        Flow {
            //height:
            id:id_poems_titlse_value
            width: 614
            //anchors.top: id_antonyms_pos_txt.bottom
            spacing:0
            visible: {
                return typeof dictJson.titles != "undefined" && dictJson.titles.length
            }
            //readonly property var modelModelData: model.modelData
            Repeater{
                id:id_synonyms_repeter
                model: dictJson.titles
                YDictPageClickSearchTextItem{
                    word:model.modelData
                    isCHType: true
                    onClicked: {
                        id_dict_page.clickSearchWord(model.modelData)
                        //id_dict_page.requeryWord(model.modelData, "en", "zh-CHS")
                    }
                }
            }
        }

    } // Column id_poem_sentence_dict_column
}


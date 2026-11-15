import QtQuick 2.12

import BaseQml 1.0
import "../i18n"

Column {
    id: id_dict_content_column
    property var dictJson: id_dict_detail_page.dictJson

    spacing: 10

    Row {
        id: id_word_frequency_container
        spacing: 2
        width: parent.width
        height: id_word_frequency.contentHeight

        YTextBase {
            id: id_word_frequency
            font.pixelSize: 26
            color: YColors.grayText
            text: YTranslateText.wordFrequency
        }
        YSpacing {
            implicitWidth: 6
            implicitHeight: 6
        }
        Repeater {
            model: (typeof dictJson.frequency != "undefined") ? dictJson.frequency : []
            YImage {
                anchors.verticalCenter: id_word_frequency_container.verticalCenter
                sourceSize: Qt.size(19, 19)
                imageName: "dict/star"
            }
        }
    }

    YTextBase {
        font.pixelSize: 26
        color: YColors.red
        width: parent.width
        height: contentHeight + 10
        topPadding: 10
        text: YTranslateText.annotationExample
        visible: id_trans_repeater.count > 0
    }

    Column {
        width: id_dict_content_column.width
        spacing: 16

        Repeater {
            id: id_trans_repeater
            model: dictJson.trans

            Item {
                id: id_trans_item
                width: parent.width
                height: id_trans_sense_column.height
                readonly property var modelModelData: model.modelData

                YTextBase {
                    id: id_trans_pos_txt
                    font.pixelSize: 24
                    font.styleName: "Italic"
                    font.family: fontManager.fontFamilyClass
                    topPadding: 5
                    color: YColors.grayText
                    text: id_trans_item.modelModelData.pos
                    width: 64
                    wrapMode: YTextBase.Wrap
                }
                Column {
                    id: id_trans_sense_column
                    anchors.left: id_trans_pos_txt.right
                    anchors.right: parent.right
                    spacing: 12

                    YTextMedium {
                        id: id_sense
                        height: id_sense.contentHeight
                        width: parent.width
                        font.family: fontManager.fontFamilyZhCn
                        text: id_trans_item.modelModelData.sense
                        wrapMode: YTextMedium.Wrap
                    }

                    Repeater {
                        id: id_trans_sents_repeater
                        model: id_trans_item.modelModelData.sents

                        Column {
                            id: id_trans_sents_column
                            width: id_trans_sense_column.width
                            spacing: 10
                            readonly property var modelModelData: model.modelData

                            YTextMedium {
                                id: id_sents_en
                                height: id_sents_en.contentHeight
                                width: parent.width
                                font.family: fontManager.fontFamilyEnUs
                                textFormat: YTextBase.RichText
                                text: id_trans_sents_column.modelModelData.en
                                wrapMode: YTextEnUs.Wrap
                            }

                            YTextBase {
                                id: id_sents_zh
                                font.pixelSize: 28
                                height: id_sents_zh.contentHeight
                                width: parent.width
                                color: YColors.grayText
                                font.family: fontManager.fontFamilyZhCn
                                textFormat: YTextBase.RichText
                                wrapMode: YTextBase.Wrap
                                text: id_trans_sents_column.modelModelData.zh
                                      + '<span style="color:#90919999;font-size:24px;">（'
                                      + id_trans_sents_column.modelModelData.source + '）</span>'
                            }
                        }
                    }
                }
            }
        }
    }

    YTextBase {
        font.pixelSize: 26
        color: YColors.red
        width: parent.width
        height: contentHeight + 10
        topPadding: 10
        text: YTranslateText.wordsInflection
        visible: id_anagram_wfs_repeater.count > 0
    }

    Column {
        width: id_dict_content_column.width
        spacing: 16

        Repeater {
            id: id_anagram_wfs_repeater
            model: (typeof dictJson.anagram != "undefined" && typeof dictJson.anagram.wfs != "undefined") ? dictJson.anagram.wfs : null

            Item {
                id: id_anagram_wfs_item
                width: parent.width
                height: id_anagram_wfs_item_column.height

                readonly property var modelModelData: model.modelData

                YTextBase {
                    id: id_anagram_wfs_index
                    width: 43
                    height: id_anagram_wfs_item_column.height
                    font.pixelSize: 26
                    font.family: fontManager.fontFamilyEnUs
                    color: YColors.grayText
                    text: ("%1.").arg(index + 1)
                }
                Column {
                    id: id_anagram_wfs_item_column
                    anchors.left: id_anagram_wfs_index.right
                    anchors.right: parent.right
                    spacing: 8

                    YTextMedium {
                        width: parent.width
                        font.pixelSize: 26
                        font.family: fontManager.fontFamilyZhCn
                        color: YColors.grayText
                        wrapMode: YTextMedium.Wrap
                        text: id_anagram_wfs_item.modelModelData.name
                    }

                    YTextMedium {
                        width: parent.width
                        font.pixelSize: 28
                        font.family: fontManager.fontFamilyEnUs
                        color: YColors.white
                        wrapMode: YTextMedium.Wrap
                        text: id_anagram_wfs_item.modelModelData.value
                    }

                }
            }
        }
    }

    YTextBase {
        font.pixelSize: 26
        color: YColors.red
        width: parent.width
        height: contentHeight + 10
        topPadding: 10
        text: YTranslateText.rootMnemonic
        visible: id_mnemonic_method_text.visible
    }

    YTextMedium {
        id: id_mnemonic_method_text
        width: parent.width
        font.pixelSize: 26
        font.family: fontManager.fontFamilyZhCn
        color: YColors.white
        wrapMode: YTextMedium.Wrap
        text: visible ? dictJson.mnemonic.method : ""
        visible: (typeof dictJson.mnemonic != "undefined" && typeof dictJson.mnemonic.method != "undefined")
    }

    YTextBase {
        font.pixelSize: 26
        color: YColors.red
        width: parent.width
        height: contentHeight + 10
        topPadding: 10
        text: YTranslateText.commonTests
        visible: id_idiomatic_repeater.count > 0
    }

    Column {
        width: id_dict_content_column.width
        spacing: 16

        Repeater {
            id: id_idiomatic_repeater
            model: typeof dictJson.idiomatic != "undefined" ? dictJson.idiomatic : null

            Item {
                id: id_idiomatic_item
                width: parent.width
                height: id_idiomatic_item_column.height

                readonly property var modelModelData: model.modelData

                YTextBase {
                    id: id_idiomatic_index
                    width: 43
                    topPadding: 4
                    height: id_idiomatic_item_column.height
                    font.pixelSize: 26
                    font.family: fontManager.fontFamilyEnUs
                    color: YColors.grayText
                    text: ("%1.").arg(index + 1)
                }

                Column {
                    id: id_idiomatic_item_column
                    anchors.left: id_idiomatic_index.right
                    anchors.right: parent.right
                    spacing: 12

                    YTextMedium {
                        width: parent.width
                        font.pixelSize: 28
                        font.family: fontManager.fontFamilyZhCn
                        color: YColors.white
                        wrapMode: YTextMedium.Wrap
                        text: id_idiomatic_item.modelModelData.colloc.en
                              + " "
                              + id_idiomatic_item.modelModelData.colloc.zh
                    }

                    Repeater {
                        id: id_idiomatic_sents_repeater
                        model: id_idiomatic_item.modelModelData.sents

                        Column {
                            id: id_idiomatic_sents_column
                            width: id_idiomatic_item_column.width
                            spacing: 8

                            readonly property var modelModelData: model.modelData

                            YTextBase {
                                width: parent.width
                                font.pixelSize: 28
                                font.family: fontManager.fontFamilyEnUs
                                color: YColors.white
                                text: id_idiomatic_sents_column.modelModelData.en
                                wrapMode: YTextEnUs.Wrap
                            }

                            YTextBase {
                                width: parent.width
                                font.pixelSize: 26
                                font.family: fontManager.fontFamilyZhCn
                                color: YColors.grayText
                                text: id_idiomatic_sents_column.modelModelData.zh
                                wrapMode: YTextBase.Wrap
                            }
                        }
                    }

                }
            }
        }
    }

    readonly property bool haveDiscriminate: typeof dictJson.discriminate != "undefined"
    YTextBase {
        font.pixelSize: 26
        color: YColors.red
        width: parent.width
        height: contentHeight + 10
        topPadding: 10
        text: YTranslateText.analysisOfMiscibleWords
        visible: haveDiscriminate
    }

    Column {
        width: parent.width
        spacing: 10
        visible: haveDiscriminate

        YTextMedium {
            font.pixelSize: 26
            font.family:  fontManager.fontFamilyEnUs
            color: YColors.white
            width: parent.width
            text: visible ? dictJson.discriminate.mixWords : ""
            visible: haveDiscriminate && typeof dictJson.discriminate.mixWords != "undefined"
        }

        Column {
            width: parent.width
            spacing: 8

            Repeater {
                id: id_discriminate_content_repeater
                model: {
                    let contentObjList = []
                    if (haveDiscriminate && typeof dictJson.discriminate.content != "undefined") {
                        let contentSplitList = dictJson.discriminate.content.split("\n")
                        for (var i = 0; i < contentSplitList.length; i++) {
                            var contentObj = new Object
                            contentObj["content"] = contentSplitList[i]
                            if (contentSplitList[i].charAt(contentSplitList[i].length - 1) === '如' && contentSplitList.length > i + 2) {
                                contentObj["sentences"] = []
                               do {
                                    let sentenceObj = ({})
                                    sentenceObj["en"] = contentSplitList[++i]
                                    sentenceObj["zh"] = contentSplitList[++i]
                                    contentObj["sentences"].push(sentenceObj)
                                } while((i+1) < contentSplitList.length && contentSplitList[(i+1)].charAt(contentSplitList[i+1].length - 1) !== '如')
                            }
                            contentObjList.push(contentObj)
                        }
                    }
                    return contentObjList
                }

                Item {
                    width: id_dict_content_column.width
                    height: id_discriminate_content_column.height
                    readonly property var discriminateContentObj: model.modelData

                    YTextBase {
                        id: id_discriminate_content_index
                        color: YColors.grayText
                        font.pixelSize: 26
                        font.family:  fontManager.fontFamilyEnUs
                        width: 43
                        topPadding: 4
                        height: id_discriminate_content_column.height
                        text: ("%1.").arg(index + 1)
                    }

                    Column {
                        id: id_discriminate_content_column
                        anchors.left: id_discriminate_content_index.right
                        anchors.right: parent.right
                        spacing: 10

                        YTextMedium {
                            color: YColors.white
                            font.family:  fontManager.fontFamilyZhCn
                            font.pixelSize: 28
                            wrapMode: YTextMedium.Wrap
                            width: parent.width
                            height: contentHeight
                            text: discriminateContentObj.content
                        }

                        Repeater {
                            model:  typeof discriminateContentObj.sentences != "undefined" ? discriminateContentObj["sentences"] : ""
                            Column {
                                id: id_sentence_column
                                anchors.left: parent.left
                                anchors.right: parent.right
                                spacing: 10
                                property var modelModelData: model.modelData
                                YTextBase {
                                    color: YColors.grayText
                                    font.pixelSize: 28
                                    font.family: fontManager.fontFamilyEnUs
                                    textFormat: YTextMedium.RichText
                                    wrapMode: YTextMedium.Wrap
                                    width: parent.width
                                    height: contentHeight
                                    text: visible ? id_sentence_column.modelModelData.en : ""
                                    visible: typeof id_sentence_column.modelModelData.en != "undefined"
                                }

                                YTextBase {
                                    color: YColors.grayText
                                    font.pixelSize: 26
                                    font.family: fontManager.fontFamilyZhCn
                                    textFormat: YTextBase.RichText
                                    wrapMode: YTextMedium.Wrap
                                    width: parent.width
                                    height: contentHeight
                                    text: visible ? id_sentence_column.modelModelData.zh : ""
                                    visible: typeof id_sentence_column.modelModelData.zh != "undefined"
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    YTextBase {
        font.pixelSize: 26
        color: YColors.red
        width: parent.width
        height: contentHeight + 10
        topPadding: 10
        text: YTranslateText.highScoreExpressionInWriting
        visible: id_haveHighExpression_repeater.count > 0
    }

    Column {
        width: parent.width
        spacing: 16

        Repeater {
            id: id_haveHighExpression_repeater
            model: typeof dictJson.highExpression != "undefined" ? dictJson.highExpression : null

            Item {
                id: id_haveHighExpression_item
                width: id_dict_content_column.width
                height: id_haveHighExpression_item_content.height
                readonly property var modelModelData: model.modelData

                YTextBase {
                    id: id_haveHighExpression_item_index
                    color: YColors.grayText
                    font.pixelSize: 26
                    font.family:  fontManager.fontFamilyEnUs
                    width: 43
                    topPadding: 4
                    height: id_haveHighExpression_item_content.height
                    text: ("%1.").arg(index + 1)
                }

                Column {
                    id: id_haveHighExpression_item_content
                    anchors.left:  id_haveHighExpression_item_index.right
                    anchors.right: parent.right
                    spacing: 10

                    YTextMedium {
                        id: id_haveHighExpression_expression_text
                        color: YColors.white
                        font.pixelSize: 28
                        textFormat: YTextMedium.RichText
                        wrapMode: YTextMedium.Wrap
                        width: parent.width
                        height: contentHeight
                        text: '<span style="font-family: ' + fontManager.fontFamilyEnUs + '; font-size: 28px">' + id_haveHighExpression_item.modelModelData.expression.en + '</span>'
                              + '<span>&nbsp;&nbsp;</span>'
                              + '<span style="font-family: ' + fontManager.fontFamilyZhCn + '; font-size: 26px">' + id_haveHighExpression_item.modelModelData.expression.zh + '</span>'
                    }

                    Repeater {
                        id: id_haveHighExpression_sents_repeater
                        model: id_haveHighExpression_item.modelModelData.sents

                        Column {
                            id: id_haveHighExpression_sents_column
                            width: id_haveHighExpression_item_content.width
                            readonly property var modelModelData: model.modelData
                            spacing: 10

                            YTextBase {
                                color: YColors.grayText
                                font.pixelSize: 28
                                textFormat: YTextMedium.RichText
                                wrapMode: YTextMedium.Wrap
                                width: parent.width
                                height: contentHeight
                                text: '<span style="font-family: ' + fontManager.fontFamilyEnUs + '; font-size: 28px">' + id_haveHighExpression_sents_column.modelModelData.en + '</span>'
                                      + '<span>&nbsp;&nbsp;</span>'
                                      + '<span style="font-family: ' + fontManager.fontFamilyZhCn + '; font-size: 26px">（' + id_haveHighExpression_sents_column.modelModelData.category + '）</span>'
                            }

                            YTextBase {
                                color: YColors.grayText
                                font.pixelSize: 26
                                font.family: fontManager.fontFamilyZhCn
                                textFormat: YTextBase.RichText
                                wrapMode: YTextMedium.Wrap
                                width: parent.width
                                height: contentHeight
                                text: id_haveHighExpression_sents_column.modelModelData.zh
                                      + (typeof id_haveHighExpression_sents_column.modelModelData.source != "undefined"
                                         ? ('<span style="color:#90919999;font-size:24px;">（'
                                            + id_haveHighExpression_sents_column.modelModelData.source + '）</span>') : "")
                            }
                        }
                    }
                }
            }
        }
    }

    YTextBase {
        font.pixelSize: 26
        color: YColors.red
        width: parent.width
        height: contentHeight + 10
        topPadding: 10
        text: YTranslateText.corootOrDerivation
        visible: id_derivative_repeater.count > 0
    }

    Column {
        width: parent.width
        spacing: 16

        Repeater {
            id: id_derivative_repeater
            model: typeof dictJson.derivative != "undefined" ? dictJson.derivative : null

            Item {
                id: id_derivative_item
                width: id_dict_content_column.width
                height: id_derivative_item_content.height
                readonly property var modelModelData: model.modelData

                YTextBase {
                    id: id_derivative_item_pos
                    color: YColors.grayText
                    font.pixelSize: 24
                    font.family:  fontManager.fontFamilyClass
                    font.styleName: "Italic"
                    topPadding: 5
                    width: 66
                    height: id_derivative_item_content.height
                    text: id_derivative_item.modelModelData.pos
                }

                Column {
                    id: id_derivative_item_content
                    anchors.left:  id_derivative_item_pos.right
                    anchors.right: parent.right
                    spacing: 10

                    Repeater {
                        model: id_derivative_item.modelModelData.trans

                        Column {
                            id: id_derivative_trans_column
                            width: id_derivative_item_content.width
                            spacing: 6
                            readonly property var modelModelData: model.modelData

                            YTextMedium {
                                color: YColors.white
                                font.pixelSize: 28
                                font.family: fontManager.fontFamilyEnUs
                                wrapMode: YTextMedium.Wrap
                                width: parent.width
                                height: contentHeight
                                text: id_derivative_trans_column.modelModelData.word
                            }

                            YTextBase {
                                color: YColors.grayText
                                font.pixelSize: 26
                                font.family: fontManager.fontFamilyZhCn
                                wrapMode: YTextMedium.Wrap
                                width: parent.width
                                height: contentHeight
                                text: id_derivative_trans_column.modelModelData.tran
                            }

                        }
                    }
                }
            }
        }
    }

    YTextBase {
        font.pixelSize: 26
        color: YColors.red
        width: parent.width
        height: contentHeight + 10
        topPadding: 10
        text: YTranslateText.synonyms
        visible: id_synonym_repeater.count > 0
    }

    Column {
        width: parent.width
        spacing: 16

        Repeater {
            id: id_synonym_repeater
            model: typeof dictJson.synonym != "undefined" ? dictJson.synonym : null

            Item {
                id: id_synonym_item
                width: id_dict_content_column.width
                height: id_synonym_item_content.height
                readonly property var modelModelData: model.modelData

                YTextBase {
                    id: id_synonym_item_pos
                    color: YColors.grayText
                    font.pixelSize: 24
                    font.family:  fontManager.fontFamilyClass
                    font.styleName: "Italic"
                    topPadding: 5
                    width: 66
                    height: id_synonym_item_content.height
                    text: id_synonym_item.modelModelData.pos
                }

                Column {
                    id: id_synonym_item_content
                    anchors.left:  id_synonym_item_pos.right
                    anchors.right: parent.right
                    spacing: 10

                    Repeater {
                        model: id_synonym_item.modelModelData.trans

                        Column {
                            id: id_synonym_trans_column
                            width: id_synonym_item_content.width
                            spacing: 6
                            readonly property var modelModelData: model.modelData

                            YTextMedium {
                                color: YColors.white
                                font.pixelSize: 28
                                font.family: fontManager.fontFamilyEnUs
                                wrapMode: YTextMedium.Wrap
                                width: parent.width
                                height: contentHeight
                                text: id_synonym_trans_column.modelModelData.word
                            }

                            YTextBase {
                                color: YColors.grayText
                                font.pixelSize: 26
                                font.family: fontManager.fontFamilyZhCn
                                wrapMode: YTextMedium.Wrap
                                width: parent.width
                                height: contentHeight
                                text: id_synonym_trans_column.modelModelData.tran
                            }

                        }
                    }
                }
            }
        }
    }

    YTextBase {
        font.pixelSize: 26
        color: YColors.red
        width: parent.width
        height: contentHeight + 10
        topPadding: 10
        text: YTranslateText.antonyms
        visible: id_antonym_repeater.count > 0
    }

    Column {
        width: parent.width
        spacing: 16

        Repeater {
            id: id_antonym_repeater
            model: typeof dictJson.antonym != "undefined" ? dictJson.antonym : null

            Item {
                id: id_antonym_item
                width: id_dict_content_column.width
                height: id_antonym_item_content.height
                readonly property var modelModelData: model.modelData

                YTextBase {
                    id: id_antonym_item_pos
                    color: YColors.grayText
                    font.pixelSize: 24
                    font.family:  fontManager.fontFamilyClass
                    font.styleName: "Italic"
                    topPadding: 5
                    width: 66
                    height: id_antonym_item_content.height
                    text: id_antonym_item.modelModelData.pos
                }

                Column {
                    id: id_antonym_item_content
                    anchors.left:  id_antonym_item_pos.right
                    anchors.right: parent.right
                    spacing: 10

                    Repeater {
                        model: id_antonym_item.modelModelData.trans

                        Column {
                            id: id_antonym_trans_column
                            width: id_antonym_item_content.width
                            spacing: 6
                            readonly property var modelModelData: model.modelData

                            YTextMedium {
                                color: YColors.white
                                font.pixelSize: 28
                                font.family: fontManager.fontFamilyEnUs
                                wrapMode: YTextMedium.Wrap
                                width: parent.width
                                height: contentHeight
                                text: id_antonym_trans_column.modelModelData.word
                            }

                            YTextBase {
                                color: YColors.grayText
                                font.pixelSize: 26
                                font.family: fontManager.fontFamilyZhCn
                                wrapMode: YTextMedium.Wrap
                                width: parent.width
                                height: contentHeight
                                text: id_antonym_trans_column.modelModelData.tran
                            }

                        }
                    }
                }
            }
        }
    }

    YTextBase {
        font.pixelSize: 26
        color: YColors.red
        width: parent.width
        height: contentHeight + 10
        topPadding: 10
        text: YTranslateText.famousProverb
        visible: id_sayings_repeater.count > 0
    }

    Column {
        width: parent.width
        spacing: 16

        Repeater {
            id: id_sayings_repeater
            model: typeof dictJson.sayings != "undefined" ? dictJson.sayings : null

            Item {
                id: id_sayings_item
                width: id_dict_content_column.width
                height: id_sayings_item_content.height
                readonly property var modelModelData: model.modelData

                YTextBase {
                    id: id_sayings_item_index
                    color: YColors.grayText
                    font.pixelSize: 24
                    font.family:  fontManager.fontFamilyEnUs
                    width: 66
                    height: id_sayings_item_content.height
                    text: ("%1.").arg(index + 1)
                }

                Column {
                    id: id_sayings_item_content
                    anchors.left:  id_sayings_item_index.right
                    anchors.right: parent.right
                    spacing: 6

                    YTextMedium {
                        color: YColors.white
                        font.pixelSize: 28
                        font.family: fontManager.fontFamilyEnUs
                        wrapMode: YTextMedium.Wrap
                        width: parent.width
                        height: contentHeight
                        text: id_sayings_item.modelModelData.en
                    }

                    YTextBase {
                        color: YColors.grayText
                        font.pixelSize: 26
                        font.family: fontManager.fontFamilyZhCn
                        wrapMode: YTextMedium.Wrap
                        width: parent.width
                        height: contentHeight
                        text: id_sayings_item.modelModelData.zh
                    }

                }
            }
        }
    }

}


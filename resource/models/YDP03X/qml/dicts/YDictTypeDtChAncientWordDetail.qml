import QtQuick 2.12

import BaseQml 1.0
import "../i18n"

Item {
    property var dictJson: id_dict_detail_page.dictJson
    property var paraphrasesJson: dictJson.paraphrases[0]
    onDictJsonChanged: {
        paraphrasesJson = dictJson.paraphrases[0]
    }

    height: id_for_wordList_column.height

    Column {
        id: id_for_wordList_column
        width: parent.width
        spacing: 20

        Flickable {
            anchors.left: parent.left
            anchors.right: parent.right
            height: 52
            contentWidth: id_dict_ch_pinyin_list.width
            flickableDirection: Flickable.HorizontalFlick
            visible: id_dict_ch_pinyin_list_repeater.count > 1
            clip: true

            Row {
                id: id_dict_ch_pinyin_list
                height: 52
                spacing: 10
                anchors.bottom: parent.bottom

                Repeater {
                    id: id_dict_ch_pinyin_list_repeater
                    model: dictJson.paraphrases
                    property int curIndex: 0

                    YButton {
                        height: 52
                        width: textWidth + 60
                        color: YColors.grayNormal
                        pixelSize: 26
                        textFamily: fontManager.fontFamilyEnUs
                        textWeight: Font.Normal
                        text: model.modelData.phone
                        textColor: index === id_dict_ch_pinyin_list_repeater.curIndex ? YColors.red : YColors.white
                        onClicked: {
                            if (id_dict_ch_pinyin_list_repeater.curIndex !== index)
                            {
                                id_word_Column.paraItemTotalIndex = 0
                                id_dict_ch_pinyin_list_repeater.curIndex = index
                                 paraphrasesJson = dictJson.paraphrases[index]
                            }
                        }
                    }
                }
            }
        }

        Column {
            id: id_word_Column
            spacing: 20
            width: id_for_wordList_column.width
            property var modelModelData: paraphrasesJson
            property var paraItemTotalIndex: 0

            Repeater {
                id: id_word_detailParas_repeater
                model: (typeof id_word_Column.modelModelData.detailParas == "undefined")
                       ? null : id_word_Column.modelModelData.detailParas

                Column {
                    id: id_word_detailParas_column
                    spacing: 20
                    width: id_word_Column.width
                    property var modelModelData: model.modelData

                    Repeater {
                        id: id_word_detailParas_paraItems_repeater
                        model: (typeof id_word_detailParas_column.modelModelData.paraItems == "undefined")
                               ? null : id_word_detailParas_column.modelModelData.paraItems

                        Item {
                            id: id_word_detailParas_paraItems_item
                            width: id_word_detailParas_column.width
                            height: id_word_detailParas_paraItems_index.height
                            property var modelModelData: model.modelData

                            YTextBase {
                                id: id_word_detailParas_paraItems_index
                                color: YColors.grayText
                                font.pixelSize: 26
                                font.weight: Font.Bold
                                width: 44
                                height: id_word_detailParas_paraItems_column.height
                                Component.onCompleted: {
                                    id_word_Column.paraItemTotalIndex += 1
                                    text = id_word_Column.paraItemTotalIndex
                                }
                            }

                            Column {
                                id: id_word_detailParas_paraItems_column
                                spacing: 12
                                anchors.left: id_word_detailParas_paraItems_index.right
                                anchors.right: parent.right

                                YTextBase {
                                    id: id_word_detailParas_paraItems_para
                                    width: parent.width
                                    height: paintedHeight
                                    font.family: fontManager.fontFamilyZhCn
                                    font.pixelSize: 28
                                    font.weight: Font.Medium
                                    textFormat: YTextBase.RichText
                                    wrapMode: YTextBase.Wrap
                                    color: "#FFFFFF"
                                    text: {
                                        if (!id_word_detailParas_paraItems_para.visible) return ""
                                        let qsText = ""
                                        if (typeof id_word_detailParas_paraItems_item.modelModelData.wordsAttri != "undefined")
                                            qsText += ('<span style="color: %1">&lt;').arg(YColors.grayText) + id_word_detailParas_paraItems_item.modelModelData.wordsAttri + '&gt;</span>'
                                        qsText += id_word_detailParas_paraItems_item.modelModelData.para
                                        return qsText
                                    }
                                    visible: typeof id_word_detailParas_paraItems_item.modelModelData.para != "undefined"
                                } // Text id_word_detailParas_paraItems_para

                                Repeater {
                                    id: id_word_detailParas_paraItems_examples_repeater
                                    model: (typeof id_word_detailParas_paraItems_item.modelModelData.examples == "undefined")
                                           ? null : id_word_detailParas_paraItems_item.modelModelData.examples

                                    YTextBase {
                                        id: id_word_detailParas_paraItems_example
                                        width: parent.width
                                        height: paintedHeight
                                        font.family: fontManager.fontFamilyZhCn
                                        font.pixelSize: 26
                                        font.weight: Font.Normal
                                        wrapMode: YTextBase.Wrap
                                        color: YColors.grayText
                                        text: model.modelData
                                    } // Text id_word_detailParas_paraItems_example

                                } // Repeater id_word_detailParas_paraItems_examples_repeater

                            } // Column id_word_trs_sents_content_column

                        } // Item id_word_trs_sents_item

                    } // id_word_detailParas_paraItems_repeater

                } // Column id_word_detailParas_column

            } // Repeater id_word_detailParas_repeater

        } // Column

        YTextBase {
            font.family: fontManager.fontFamily
            font.pixelSize: 24
            lineHeightMode: Text.FixedHeight
            lineHeight: 32
            font.weight: Font.Normal
            color: "#666873"
            wrapMode: YTextBase.Wrap
            textFormat: YTextBase.RichText
            horizontalAlignment: YTextBase.AlignHCenter
            width: parent.width
            text: YTranslateText.contentComeFrom + '<br/>' + YTranslateText.dtChAncientWord
        }

    } //Column id_for_wordList_column

    onVisibleChanged: {
        if (!visible) {
            id_word_Column.paraItemTotalIndex = 0
        }
    }

}// Item root

/*
    // 一
{
    "phones":[{"pronun":"哪","phone":"nǎ"},{"pronun":"捺","phone":"nà"},{"pronun":"挪","phone":"nuó"},{"pronun":"懦","phone":"nuò"},{"pronun":"哪","phone":"né"}],
    "paraphrases":[
        {
            "detailParas":[
                {
                    "paraItems":[
                        {
                            "para":"见“那吒”。"
                        },
                        {
                            "para":"见ｎǎ。"
                        }
                    ]
                }
            ],
            "phone":"né",
            "words":"那"
        },
        {
            "detailParas":[
                {
                    "paraItems":[
                        {
                            "wordsAttri":"助",
                            "examples":[
                                "《后汉书·韩康传》：“公是韩伯休～?乃不二价乎?”"
                            ],
                            "para":"表疑问语气。"
                        },
                        {
                            "para":"见ｎǎ。"
                        }
                    ]
                }
            ],
            "phone":"nuò",
            "words":"那"
        },
        {
            "detailParas":[
                {
                    "paraItems":[
                        {
                            "wordsAttri":"代",
                            "examples":[
                                "《孔雀东南飞》：“处分适兄意，～得自任专?”",
                                "《乐府诗集·折杨柳枝歌》：“阿婆不嫁女，～得儿孙抱?”【注】古无“哪”字，古文中用“哪”的问句都用“那”。"
                            ],
                            "para":"同“哪”。如何；怎么。"
                        }
                    ]
                }
            ],
            "phone":"nǎ",
            "words":"那"
        },
        {
            "detailParas":[
                {
                    "paraItems":[
                        {
                            "wordsAttri":"代",
                            "para":"指较远的人或事物。"
                        }
                    ]
                }
            ],
            "phone":"nà",
            "words":"那"
        },
        {
            "detailParas":[
                {
                    "paraItems":[
                        {
                            "wordsAttri":"形",
                            "examples":[
                                "《诗经·商颂·那》：“猗与～与!”(猗：叹美之辞。)"
                            ],
                            "para":"多。"
                        },
                        {
                            "wordsAttri":"动",
                            "examples":[
                                "《左传·宣公二年》：“牛则有皮，犀兕尚多，弃甲则～。”"
                            ],
                            "para":"“奈何”的合音。"
                        },
                        {
                            "para":"见ｎǎ。"
                        }
                    ]
                }
            ],
            "phone":"nuó",
            "words":"那"
        }
    ],
    "word":"那",
    "relatedWords": {"end":["兀那"],"first":["那吒"],"empty":false}
}
  */



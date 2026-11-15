import QtQuick 2.12

import BaseQml 1.0
import "../i18n"

Item {
    property var dictJson: id_dict_detail_page.dictJson

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
                    model: dictJson.dataList
                    property int curIndex: 0

                    YButton {
                        height: 52
                        width: textWidth + 60
                        color: YColors.grayNormal
                        pixelSize: 26
                        textFamily: fontManager.fontFamilyEnUs
                        textWeight: Font.Normal
                        text: {
                            let phoneCur = model.modelData.phone
                            phoneCur = phoneCur.replace(/\[/g, "")
                            phoneCur = phoneCur.replace(/\]/g, "")
                            return phoneCur
                        }
                        textColor: index === id_dict_ch_pinyin_list_repeater.curIndex ? YColors.red : YColors.white
                        onClicked: {
                            if (id_dict_ch_pinyin_list_repeater.curIndex !== index)
                            {
                                id_dict_ch_pinyin_list_repeater.curIndex = index
                                id_word_Column.modelModelData = dictJson.dataList[index]
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
            property var modelModelData: dictJson.dataList[0]

            YTextBase {
                font.pixelSize: 30
                wrapMode: YTextBase.Wrap
                textFormat: YTextBase.RichText
                width: id_for_wordList_column.width
                height: contentHeight
                text: '<span style="font-family: ' + fontManager.fontFamilyZhCn + ('; color: %1; font-weight: 500">').arg(YColors.white) + dictJson.word + '</span>'
                      + '<span>&nbsp;&nbsp;&nbsp;&nbsp;</span>'
                      + '<span style="font-family: ' + fontManager.fontFamilyEnUs + ('; color: %1; font-weight: 400;">').arg(YColors.grayText) + id_word_Column.modelModelData.phone + '</span>'
            } // text word_phone

            Repeater {
                id: id_word_trs_repeater
                model: (typeof id_word_Column.modelModelData.trs == "undefined") ? null : id_word_Column.modelModelData.trs

                Item {
                    id: id_word_trs_item
                    width: id_for_wordList_column.width
                    height: id_word_trs_index.height
                    visible: typeof id_word_trs_item.modelModelData.tr != "undefined"
                             && (typeof id_word_trs_item.modelModelData.tr.cn != "undefined"
                                 || typeof id_word_trs_item.modelModelData.tr.en != "undefined")
                    property var modelModelData: model.modelData

                    YTextMedium {
                        id: id_word_trs_index
                        color: YColors.grayText
                        font.pixelSize: 26
                        font.family: fontManager.fontFamilyZhCn
                        width: 44
                        height: id_word_trs_content_column.height
                        text: ("%1.").arg(index + 1)
                        //text: "1."
                    } // Text id_word_trs_index

                    Column {
                        id: id_word_trs_content_column
                        spacing: 16
                        anchors.left: id_word_trs_index.right
                        anchors.right: parent.right

                        YTextBase {
                            id: id_word_trs_pos
                            width: parent.width
                            height: contentHeight
                            font.weight: Font.Medium
                            wrapMode: YTextBase.Wrap
                            textFormat: YTextBase.RichText
                            text: {
                                if (!id_word_trs_item.visible) return ""
                                let qsPos = (typeof id_word_trs_item.modelModelData.pos != "undefined")
                                             ? "&lt;" + id_word_trs_item.modelModelData.pos + "&gt;" : ""
                                let qsTranCn = (typeof id_word_trs_item.modelModelData.tr.cn != "undefined")
                                                ? ("（" + id_word_trs_item.modelModelData.tr.cn + "）") : ""
                                let qsTranEn = (typeof id_word_trs_item.modelModelData.tr.en != "undefined")
                                                ? id_word_trs_item.modelModelData.tr.en : ""
                                return '<span style="font-family: ' + fontManager.fontFamilyZhCn + ('; color: %1; font-size: 26px">').arg(YColors.grayText) + qsPos + '</span>'
                                        + '<span style="font-family: ' + fontManager.fontFamilyZhCn + ('; color: %1; font-size: 28px">').arg(YColors.white) + qsTranCn + '</span>'
                                        + '<span style="font-family: ' + fontManager.fontFamilyEnUs + ('; color: %1; font-size: 28px">').arg(YColors.white) + qsTranEn + '</span>'
                            }
                        } // Text id_word_trs_pos

                        Repeater {
                            id: id_word_trs_sents_repeater
                            model: (typeof id_word_trs_item.modelModelData.sents == "undefined") ? null : id_word_trs_item.modelModelData.sents

                            Item {
                                id: id_word_trs_sents_item
                                width: id_word_trs_content_column.width
                                height: id_word_trs_sents_index.height
                                property var modelModelData: model.modelData

                                YTextBase {
                                    id: id_word_trs_sents_index
                                    color: "#FFFFFF"
                                    font.pixelSize: 26
                                    font.weight: Font.Bold
                                    font.family: fontManager.fontFamilyEnUs
                                    width: 24
                                    height: id_word_trs_sents_content_column.height
                                    text: ("·")
                                }

                                Column {
                                    id: id_word_trs_sents_content_column
                                    spacing: 8
                                    anchors.left: id_word_trs_sents_index.right
                                    anchors.right: parent.right

                                    YTextBase {
                                        id: id_word_trs_sents_cn
                                        width: parent.width
                                        height: paintedHeight
                                        font.family: fontManager.fontFamilyZhCn
                                        font.pixelSize: 28
                                        font.weight: Font.Normal
                                        wrapMode: YTextBase.Wrap
                                        color: "#FFFFFF"
                                        text: visible ? id_word_trs_sents_item.modelModelData.cn : ""
                                        visible: typeof id_word_trs_sents_item.modelModelData.cn != "undefined"
                                    } // Text id_word_trs_sents_cn


                                    YText {
                                        id: id_word_trs_sents_en
                                        width: parent.width
                                        height: paintedHeight
                                        font.family: fontManager.fontFamilyEnUs
                                        font.weight: Font.Normal
                                        wrapMode: YTextBase.Wrap
                                        color: YColors.grayText
                                        text: visible ? id_word_trs_sents_item.modelModelData.en : ""
                                        visible: typeof id_word_trs_sents_item.modelModelData.en != "undefined"
                                    } // Text id_word_trs_sents_en

                                } // Column id_word_trs_sents_content_column

                            } // Item id_word_trs_sents_item

                        } // id_word_trs_sents_repeater

                    } // Column id_word_trs_content_column

                } // Item id_word_trs_item

            } // Repeater id_word_trs_repeater

            readonly property bool haveRelatedInfo: typeof id_word_Column.modelModelData.relatedinfo != "undefined"
            YTextBase {
                font.pixelSize: 26
                font.family: fontManager.fontFamily
                font.weight: Font.Medium
                color: YColors.red
                width: parent.width
                height: 38
                verticalAlignment: YTextBase.AlignBottom
                text: YTranslateText.relatedWords
                visible: id_word_Column.haveRelatedInfo
            }

            Repeater {
                id: id_word_relatedinfo_repeater
                model: id_word_Column.haveRelatedInfo ? id_word_Column.modelModelData.relatedinfo : null

                Item {
                    id: id_word_relatedinfo_item
                    width: id_for_wordList_column.width
                    height: id_word_relatedinfo_index.height
                    property var modelModelData: model.modelData

                    YTextMedium {
                        id: id_word_relatedinfo_index
                        color: YColors.grayText
                        font.pixelSize: 26
                        font.family: fontManager.fontFamilyZhCn
                        width: 44
                        height: id_word_relatedinfo_content_column.height
                        text: ("%1.").arg(index + 1)
                        //text: "1."
                    } // Text id_word_relatedinfo_index

                    Column {
                        id: id_word_relatedinfo_content_column
                        spacing: 8
                        anchors.left: id_word_relatedinfo_index.right
                        anchors.right: parent.right

                        YTextBase {
                            id: id_word_relatedinfo_cn
                            width: parent.width
                            height: contentHeight
                            font.family: fontManager.fontFamilyZhCn
                            font.pixelSize: 28
                            font.weight: Font.Normal
                            wrapMode: YTextBase.Wrap
                            color: "#FFFFFF"
                            text: visible ? id_word_relatedinfo_item.modelModelData.cn : ""
                            visible: typeof id_word_relatedinfo_item.modelModelData.cn != "undefined"
                        } // Text id_word_relatedinfo_cn


                        YText {
                            id: id_word_relatedinfo_en
                            width: parent.width
                            height: contentHeight
                            font.family: fontManager.fontFamilyEnUs
                            font.weight: Font.Normal
                            wrapMode: YTextBase.Wrap
                            color: YColors.grayText
                            text: visible ? id_word_relatedinfo_item.modelModelData.en : ""
                            visible: typeof id_word_relatedinfo_item.modelModelData.en != "undefined"
                        } // Text id_word_relatedinfo_en

                    } // Column id_word_relatedinfo_content_column

                } // Item id_word_relatedinfo_item

            } // Repeater id_word_relatedinfo_repeater

            readonly property bool haveNotice: typeof id_word_Column.modelModelData.notice != "undefined"
            YTextBase {
                font.pixelSize: 26
                font.family: fontManager.fontFamily
                font.weight: Font.Medium
                color: YColors.red
                width: parent.width
                height: 38
                verticalAlignment: YTextBase.AlignBottom
                text: YTranslateText.notice
                visible: id_word_Column.haveNotice
            }

            YTextBase {
                id: id_word_notice_text
                width: parent.width
                height: paintedHeight
                font.family: fontManager.fontFamilyZhCn
                font.pixelSize: 28
                font.weight: Font.Normal
                wrapMode: YTextBase.Wrap
                color: "#FFFFFF"
                text: visible ? id_word_Column.modelModelData.notice : ""
                visible: id_word_Column.haveNotice
            } // Text id_word_notice_text

        } // Column

        Column {
            width: id_for_wordList_column.width
            spacing: 10

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
                text: YTranslateText.contentComeFrom + '<br/>' + YTranslateText.dtChLarge
            }

        }

    } //Column id_for_wordList_column

}// Item root

/*
    // 那
{
    "dataList":[
        {
            "trs":[
                {
                    "tr":{
                        "en":"that",
                        "cn":"Ⅰ□代指示比较远的人或事物"
                    },
                    "sents":[
                        {
                            "en":"Who is that?",
                            "cn":"那是谁?"
                        },
                        {
                            "en":"That was my fault",
                            "cn":"那是我的过错。"
                        },
                        {
                            "en":"That is a factory",
                            "cn":"那是一个工厂。"
                        },
                        {
                            "en":"That was in 1989",
                            "cn":"那是1989年的事。"
                        }
                    ]
                }
            ],
            "phone":"[nà]",
            "notice":"[": ① 单用的“那”限于在动词前。 在动词后面用“那个”， 只有跟“这”对举的时候可以用“那”， 如: 说这道 那 的; 看看这， 看看 那， 真有说 不出的高兴。 ② 在口语里， “那”单用或者后面直接跟名词， 说 nà 或 nè; “那”后面跟量词或数词加量词， 常常说 nèi 或 nè。 以下“那个”、“那会儿”、“那些”、“那样”各条在口语里都常常说 nèi- 或 nè-， “那么些”、“那么样”、“那么着”各条在口语里都常常说 nè-。 Ⅱ □连  (那么) then; in that case: 那 我们就不再等了。 In that case, we won't wait any longer. 你要是跟我们一块走， 那 就得快点。 If you're coming with us, you must hurry. 如果你喜欢， 那 就买吧! If you like it, take it, then."]"
        },
        {
            "trs":[
                {
                    "pos":"名",
                    "tr":{
                        "en":"a surname",
                        "cn":"姓氏"
                    },
                    "sents":[
                        {
                            "en":"Na Rong",
                            "cn":"那荣"
                        }
                    ]
                }
            ],
            "phone":"[nā]"
        },
        {
            "trs":[
                {
                    "pos":"名",
                    "tr":{
                        "en":"a surname",
                        "cn":"姓氏"
                    },
                    "sents":[
                        {
                            "en":"Nuo Jian",
                            "cn":"那鉴"
                        }
                    ]
                }
            ],
            "phone":"[nuó]"
        },
        {
            "trs":[
                {
                    "pos":"代",
                    "tr":{
                        "en":"which; what",
                        "cn":"表示疑问"
                    },
                    "sents":[
                        {
                            "en":"Which one of you is Mr.",
                            "cn":"你们中间那一位是王先生?"
                        },
                        {
                            "en":"What is your favourite kind of music?",
                            "cn":"你最喜欢那种音乐?"
                        },
                        {
                            "en":"What foreign language are you studying?.",
                            "cn":"你学的是那国语言?"
                        }
                    ]
                },
                {
                    "pos":"代",
                    "tr":{
                        "en":"any",
                        "cn":"泛指"
                    }
                },
                {
                    "pos":"副",
                    "tr":{
                        "cn":"表示反问"
                    },
                    "sents":[
                        {
                            "en":"How can there be things as such?",
                            "cn":"那会有这种事?"
                        }
                    ]
                }
            ],
            "phone":"[nǎ]"
        }
    ],
    "word":"那"
}
  */




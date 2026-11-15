import QtQuick 2.12
import com.youdao.pen 1.0

import BaseQml 1.0
import "../i18n"

YDictTypeBase {
    id: id_dict_type_ch_chinese
    title: YTranslateText.dtChChinese
    //property var chPinyinList: []

    Item {
        width: parent.width
        height: id_for_wgt_ch.height

        Column {
            id: id_for_wgt_ch
            spacing: 20
            width: parent.width

            Repeater {
                model: dictJson.meanings
                Row {
                    spacing: 26
                    width: id_for_wgt_ch.width
                    height: id_detail_index_column.height
                    YTextBase {
                        id: id_detail_index_label
                        color: YColors.grayText
                        font.pixelSize: 26
                        width: contentWidth
                        height: contentHeight
                        text: ("%1.").arg(index + 1)
                        visible: id_detail_index_column.visibleSet

                    }

                    Column {
                        id: id_detail_index_column
                        width: parent.width - parent.spacing - id_detail_index_label.width
                        spacing: 12
                        property var visibleSet: id_value_text.visible || id_detail_meaning_examples.visible

                        YTextMedium {
                            id: id_value_text
                            wrapMode: YText.Wrap
                            width: parent.width
                            height: contentHeight
                            font.family: fontManager.fontFamilyZhCn
                            text: typeof model.modelData.value !== "undefined" ? model.modelData.value : ""
                            visible: text.length
                        }

                        YTextBase {
                            id: id_detail_meaning_examples
                            wrapMode: YText.Wrap
                            color: YColors.grayText
                            textFormat: YTextBase.RichText
                            font.family: fontManager.fontFamilyZhCn
                            font.pixelSize: 26
                            width: parent.width
                            height: contentHeight
                            text: model.modelData.example.join('&nbsp;')
                            visible: model.modelData.example.join('&nbsp;').length > 0
                        }
                    }
                }
            }

            YTextBase {
                id: id_synonyms_antonyms_title
                font.pixelSize: 26
                color: YColors.red
                height: contentHeight
                text: YTranslateText.synonymsAndAntonyms
                visible: id_synonyms_word_row.visible
                         || id_antonyms_word_row.visible
                Component.onCompleted: {
                    dictNodeCompleted(text, dictType, 1, this);
                }
            }

            Row {
                id: id_synonyms_word_row
                spacing: 26
                anchors.left: parent.left
                anchors.right: parent.right
                height: id_synonyms_word_row_column.height
                visible: (typeof dictJson.synonyms != "undefined") && (dictJson.synonyms.length > 0)
                YTextBase {
                    id: id_synonyms_word_label
                    color: YColors.grayText
                    font.pixelSize: 26
                    width: contentWidth
                    height: contentHeight
                    text: "1."
                }

                Column {
                    id: id_synonyms_word_row_column
                    width: parent.width - parent.spacing - id_synonyms_word_label.width
                    spacing: 12

                    YTextMedium {
                        width: parent.width
                        height: contentHeight
                        font.family: fontManager.fontFamilyZhCn
                        text: YTranslateText.synonyms
                    }

                    YTextBase {
                        id: id_synonyms_word_value
                        wrapMode: YText.Wrap
                        color: YColors.grayText
                        font.family: fontManager.fontFamilyZhCn
                        font.pixelSize: 26
                        width: parent.width
                        height: contentHeight
                        text: dictJson.synonyms.join('、')
                    }
                }
            }

            Row {
                id: id_antonyms_word_row
                spacing: 26
                anchors.left: parent.left
                anchors.right: parent.right
                height: id_antonyms_word_row_column.height
                visible: (typeof dictJson.antonyms != "undefined") && (dictJson.antonyms.length > 0)
                YTextBase {
                    id: id_antonyms_word_label
                    color: YColors.grayText
                    font.pixelSize: 26
                    width: contentWidth
                    height: contentHeight
                    text: {
                        if (id_synonyms_word_row.visible) {
                            return "2."
                        }
                        return "1."
                    }
                }

                Column {
                    id: id_antonyms_word_row_column
                    width: parent.width - parent.spacing - id_antonyms_word_label.width
                    spacing: 12

                    YTextMedium {
                        wrapMode: YText.Wrap
                        width: parent.width
                        height: contentHeight
                        font.family: fontManager.fontFamilyZhCn
                        text: YTranslateText.antonyms
                    }

                    YTextBase {
                        id: id_antonyms_word_value
                        wrapMode: YText.Wrap
                        color: YColors.grayText
                        font.family: fontManager.fontFamilyZhCn
                        font.pixelSize: 26
                        width: parent.width
                        height: contentHeight
                        text: dictJson.antonyms.join('、')
                    }
                }
            }
        }
    }
}

// for YEnum.WGT_Ch_Group === resultManager.currentQueryType
// 首次
/*
{
    "antonyms": [
        "多次"
    ],
    "meanings": [
        {
            "value": "第一次",
            "example": [
                "<b>首次</b>登台亮相。"
            ]
        }
    ],
    "pinyin": [
        "shǒu",
        "cì"
    ],
    "synonyms": [
        "初次",
        "初度"
    ]
}
  */

// 词典
/*
{
    "antonyms": [],
    "meanings": [
        {
            "pos": "名",
            "value": "收集词语，按一定顺序编排，加以注音、释义等，供人查阅参考的工具书。",
            "example": []
        }
    ],
    "pinyin": [
        "cí",
        "diǎn"
    ],
    "synonyms": [
        "辞书"
    ]
}
  */

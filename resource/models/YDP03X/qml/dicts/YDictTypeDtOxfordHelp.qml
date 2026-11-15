import QtQuick 2.12

import BaseQml 1.0
import "./YDictOxfordUtilities.js" as OxfordUtilities
import "./YDictOxfordModel.js" as OxfordModel

Column {
    id: id_word_help_column
    width: componentWidth
    spacing: 4

    Repeater {
        model: qslEn

        Column {
            width: id_word_help_column.width
            spacing: 4
            readonly property int qslEnIndex: index

            YTextMedium {
                id: id_help_qsEn_text
                font.family: fontManager.fontFamilyEnUs
                font.pixelSize: 30
                textFormat: YTextBase.RichText
                wrapMode: YTextBase.WordWrap
                width: parent.width
                color: "#FFFFFF"
                text: {
                    var formatted = ""
                    if (qslEnIndex === 0 && bHasIcon) {
                        formatted += OxfordUtilities.formatBorderText("HELP") + '&nbsp;&nbsp;'
                    }
                    formatted += OxfordUtilities.htmlToFormatted(model.modelData)
                    return formatted
                }
                visible: text.length > 0
            }

            Repeater {
                model: {
                    var qsEx = "x" + (qslEnIndex + 1).toString()
                    if (typeof helpObj[qsEx] == "undefined") {
                        return null
                    }
                    var vxArr = []
                    if (OxfordUtilities.isArrayFn(helpObj[qsEx])) {
                        vxArr = helpObj[qsEx]
                    } else {
                        vxArr.push(helpObj[qsEx])
                    }
                    return vxArr
                }

                Item {
                    id: id_help_qsEn_xnum_item
                    width: id_help_qsEn_text.width
                    height: id_help_qsEn_xnum_content_column.height
                    readonly property var xqsEn: {
                        if (typeof model.modelData == "string") {
                            return model.modelData
                        } else if (typeof model.modelData == "object") {
                            return model.modelData.content
                        }
                        return ""
                    }
                    readonly property var xqsCh: {
                        if (typeof model.modelData == "object") {
                            return model.modelData.chn.content
                        }
                        return ""
                    }
                    readonly property var bDel: typeof model.modelData == "object" && typeof model.modelData.wx == "boolean" ? model.modelData.wx : false

                    YTextMedium {
                        id: id_help_qsEn_xnum_point
                        font.family: fontManager.fontFamilyEnUs
                        font.weight: Font.Bold
                        anchors.left: parent.left
                        width: 24
                        height: id_help_qsEn_xnum_content_column.height
                        color: YColors.grayText
                        text: "· "
                        visible: id_help_qsEn_xnum_en.visible || id_help_qsEn_xnum_ch.visible
                    }

                    Column {
                        id: id_help_qsEn_xnum_content_column
                        anchors.left: id_help_qsEn_xnum_point.right
                        anchors.right: parent.right
                        spacing: 6

                        YTextMedium {
                            id: id_help_qsEn_xnum_en
                            font.family: fontManager.fontFamilyEnUs
                            font.pixelSize: 28
                            font.strikeout: id_help_qsEn_xnum_item.bDel
                            textFormat: YTextBase.RichText
                            wrapMode: YTextBase.WordWrap
                            width: parent.width
                            color: "#FFFFFF"
                            text: OxfordUtilities.htmlToFormatted(id_help_qsEn_xnum_item.xqsEn)
                            visible: text.length > 0
                        }

                        YTextMedium {
                            id: id_help_qsEn_xnum_ch
                            font.family: fontManager.fontFamilyZhCn
                            textFormat: YTextBase.RichText
                            wrapMode: YTextBase.WordWrap
                            width: parent.width
                            color: YColors.grayText
                            text: id_help_qsEn_xnum_item.xqsCh
                            visible: text.length > 0
                        }
                    }
                }
            }
        }

    }

    YTextMedium {
        id: id_help_qsCh_text
        font.family: fontManager.fontFamilyZhCn
        font.pixelSize: 30
        textFormat: YTextBase.RichText
        wrapMode: YTextBase.WordWrap
        width: parent.width
        color: "#FFFFFF"
        text: qsCh
        visible: text.length > 0
    }
}


import QtQuick 2.12

import BaseQml 1.0
import "../i18n"

Item {
    property int curWordListIndex: 0
    property var dictJson: id_dict_detail_page.dictJson
    onDictJsonChanged: {
        curWordListIndex = 0
    }

    height: id_for_wordList_column.height

    function removeHtmlTag(qsContent){
        if (typeof qsContent != "string") {
            return ""
        }
        let qsResult = qsContent;
        qsResult = qsResult.replace(/<a>/g, "<b>");
        qsResult = qsResult.replace(/<\/a>/g, "</b>");
        qsResult = qsResult.replace(/&lt/g, ("<font color=\"%1\">(").arg(YColors.grayText));
        qsResult = qsResult.replace(/&gt/g, ")</font>");
        return qsResult;
    }

    Column {
        id: id_for_wordList_column
        width: parent.width
        spacing: 20

        Flickable {
            anchors.left: parent.left
            anchors.right: parent.right
            height: 52
            contentWidth: id_wordList_hw_row.width
            flickableDirection: Flickable.HorizontalFlick
            visible: id_wordList_hw_repeater.count > 1
            clip: true

            Row {
                id: id_wordList_hw_row
                spacing: 10
                visible: id_wordList_hw_repeater.count > 1

                Repeater {
                    id: id_wordList_hw_repeater
                    model: (typeof dictJson.wordList != "undefined") ? dictJson.wordList : []

                    YMouseArea {
                        id: id_word_hw_MouseArea
                        width: id_word_hw_background.width
                        height: 52
                        objectName: "YDictTypeDtWebster.qml_wordListhw_index" + index

                        Rectangle {
                            id: id_word_hw_background
                            width: id_word_hw_text.width + 32 * 2
                            height: parent.height
                            color: YColors.grayNormal
                            opacity: parent.pressed ? 0.6 : 1
                            radius: 38

                            Text {
                                id: id_word_hw_text
                                anchors.centerIn: parent
                                font.family: fontManager.fontFamilyEnUs
                                textFormat: YTextBase.RichText
                                color: index === curWordListIndex ? YColors.red : YColors.white
                                font.pixelSize: 24
                                font.weight: Font.Bold
                                width: paintedWidth
                                height: paintedHeight
                                text: model.modelData.hw
                            }

                        }

                        onClicked: {
                            if (curWordListIndex !== index)
                            {
                                curWordListIndex = index
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
            readonly property var modelModelData: (typeof dictJson.wordList != "undefined") ? dictJson.wordList[curWordListIndex] : new Object

            YText {
                id: id_wordList_hw_text
                font.family: fontManager.fontFamilyEnUs
                font.pixelSize: 26
                textFormat: YTextBase.RichText
                wrapMode: Text.Wrap
                color: YColors.grayText
                width: parent.width
                height: contentHeight
                text: {
                    let qsRst = ""
                    if (typeof dictJson.wordList != "undefined" && dictJson.wordList.length === 1) {
                        qsRst += id_word_Column.modelModelData.hw
                    }
                    if (typeof id_word_Column.modelModelData.pr == "string") {
                        if (qsRst.length > 0) {
                            qsRst += "  "
                        }
                        qsRst += "\\" + id_word_Column.modelModelData.pr + "\\"
                    }
                    return qsRst
                }
                visible: text.length > 0
            }

            YText {
                font.family: fontManager.fontFamilyEnUs
                font.weight: Font.Bold
                wrapMode: YTextBase.Wrap
                textFormat: YTextBase.RichText
                color: YColors.grayText
                width: id_for_wordList_column.width
                height: paintedHeight
                text: {
                    if (!visible) {
                    } else if (typeof id_word_Column.modelModelData.vr == "string") {
                        return id_word_Column.modelModelData.vr
                    } else if (typeof id_word_Column.modelModelData.vr == "object") {
                        let qsRst = ""
                        if (typeof id_word_Column.modelModelData.vr.content == "string") {
                            qsRst += id_word_Column.modelModelData.vr.content
                        }
                        if (typeof id_word_Column.modelModelData.vr.pr == "string") {
                            if (qsRst.length > 0) {
                                qsRst += "  "
                            }
                            qsRst += "\\" + id_word_Column.modelModelData.vr.pr + "\\"
                        }
                        return qsRst
                    }
                    return ""
                }
                visible: typeof id_word_Column.modelModelData.vr != "undefined"
            } // text word_vr

            YTextBase {
                font.family: fontManager.fontFamilyEnUs
                font.pixelSize: 28
                font.weight: Font.Bold
                wrapMode: YTextBase.Wrap
                textFormat: YTextBase.RichText
                color: YColors.red
                width: id_for_wordList_column.width
                height: paintedHeight
                text: visible ? id_word_Column.modelModelData.fl + "." : ""
                visible: typeof id_word_Column.modelModelData.fl != "undefined"
            } // text word_fl

            Repeater {
                id: id_word_inf_repeater
                model: {
                    if (typeof id_word_Column.modelModelData.inf != "undefined") {
                        if (typeof id_word_Column.modelModelData.inf.length == "number") {
                            return id_word_Column.modelModelData.inf
                        } else {
                            return [id_word_Column.modelModelData.inf]
                        }
                    }
                    return []
                }
                YTextBase {
                    font.family: fontManager.fontFamilyEnUs
                    font.pixelSize: 28
                    font.weight: Font.Bold
                    wrapMode: YTextBase.Wrap
                    textFormat: YTextBase.RichText
                    color: "#FFFFFF"
                    width: id_for_wordList_column.width
                    height: paintedHeight
                    text: {
                        if (typeof model.modelData.content == "undefined") {
                        } else if (typeof model.modelData.content == "string") {
                            return removeHtmlTag(model.modelData.content)
                        } else if (typeof model.modelData.content.length == "number") {
                            let qsRstList = []
                            model.modelData.content.forEach(function(qsContent){
                                if (typeof qsContent == "string") {
                                    qsRstList.push(qsContent)
                                }
                            })
                            if (qsRstList.length > 0) {
                                return removeHtmlTag(qsRstList.join(" "))
                            }
                        }
                        return removeHtmlTag(JSON.stringify(model.modelData))
                    }
                    visible: text.length > 0
                }
            } // Repeater id_word_inf_repeater

            YTextBase {
                font.family: fontManager.fontFamilyEnUs
                font.pixelSize: 28
                font.weight: Font.Bold
                wrapMode: YTextBase.Wrap
                textFormat: YTextBase.RichText
                color: "#FFFFFF"
                width: id_for_wordList_column.width
                height: paintedHeight
                text: visible ? removeHtmlTag((typeof id_word_Column.modelModelData.inf.content == "undefined")
                                              ? JSON.stringify(id_word_Column.modelModelData.inf)
                                              : id_word_Column.modelModelData.inf.content)
                              : ""
                visible: id_word_inf_repeater.count < 1 && (typeof id_word_Column.modelModelData.inf != "undefined")
            } // text word_inf

            YText {
                font.family: fontManager.fontFamilyEnUs
                wrapMode: YTextBase.Wrap
                textFormat: YTextBase.RichText
                color: YColors.grayText
                width: id_for_wordList_column.width
                height: paintedHeight
                text: visible ? id_word_Column.modelModelData.def.sl : ""
                visible: (typeof id_word_Column.modelModelData.def != "undefined"
                          && typeof id_word_Column.modelModelData.def.sl != "undefined")
            } // text word_sl

            Repeater {
                id: id_word_def_sensb_repeater
                //model: dictJson.wordList[0].def.sensb
                model: (typeof id_word_Column.modelModelData.def != "undefined"
                        && typeof id_word_Column.modelModelData.def.sensb != "undefined")
                       ? id_word_Column.modelModelData.def.sensb : null

                Column {
                    id: id_word_def_sensb_Column
                    spacing: 20
                    width: id_for_wordList_column.width
                    readonly property var modelModelData: model.modelData

                    YTextBase {
                        font.family: fontManager.fontFamilyClass
                        font.pixelSize: 26
                        font.weight: Font.Normal
                        color: "#FFFFFF"
                        wrapMode: YTextBase.Wrap
                        textFormat: YTextBase.RichText
                        width: id_for_wordList_column.width
                        height: paintedHeight
                        text:  visible ? '[ <span style="font-style: italic">' + id_word_def_sensb_Column.modelModelData.et + ' </span> ]' : ""
                        visible: typeof id_word_def_sensb_Column.modelModelData.et != "undefined"
                    }

                    Repeater {
                        id: id_word_def_sensb_meaning_repeater
                        model: (typeof id_word_def_sensb_Column.modelModelData.meaning == "undefined") ? null : id_word_def_sensb_Column.modelModelData.meaning
                        //model: dictJson.wordList[0].def.sensb[0].meaning

                        Item {
                            id: id_word_def_sensb_meaning_item
                            width: id_for_wordList_column.width
                            height: id_meaning_content.height
                            readonly property var modelModelData: model.modelData

                            YTextBase {
                                id: id_meaning_index
                                color: YColors.grayText
                                font.pixelSize: 26
                                font.weight: Font.Normal
                                font.family: fontManager.fontFamilyZhCn
                                topPadding: 4
                                width: 40
                                height: id_meaning_content.height
                                text: visible ? ("%1.").arg(index + 1) : ""
                                visible: id_meaning_dt_content.visible || id_meaning_sense_repeater.count > 0
                            }

                            Column {
                                id: id_meaning_content
                                anchors.left: id_meaning_index.right
                                anchors.right: parent.right

                                YTextBase {
                                    id: id_meaning_dt_content
                                    color: "#FFFFFF"
                                    font.pixelSize: 28
                                    font.weight: Font.Medium
                                    font.family: fontManager.fontFamilyEnUs
                                    wrapMode: YTextBase.Wrap
                                    textFormat: YTextBase.RichText
                                    width: id_meaning_content.width
                                    height: paintedHeight
                                    text: visible ? removeHtmlTag(id_word_def_sensb_meaning_item.modelModelData.dt.content[0]) : ""
                                    visible: (typeof id_word_def_sensb_meaning_item.modelModelData.dt != "undefined")
                                             && (typeof id_word_def_sensb_meaning_item.modelModelData.dt.content != "undefined")
                                    //text: dictJson.wordList[0].def.sensb[0].meaning[0].dt.content[0]
                                }

                                Repeater {
                                    id: id_meaning_sense_repeater
                                    model: (typeof id_word_def_sensb_meaning_item.modelModelData.sense == "undefined") ? null : id_word_def_sensb_meaning_item.modelModelData.sense
                                    //model: dictJson.wordList[0].def.sensb[0].meaning[0].sense

                                    Column {
                                        id: id_meaning_sense_column
                                        width: id_meaning_content.width
                                        readonly property var modelModelData: model.modelData

                                        Item {
                                            id: id_meaning_sense_content_item
                                            width: id_meaning_content.width
                                            height: id_meaning_sense_index.height
                                            visible: id_meaning_sense_index.visible || !id_meaning_sense_content.textIsEmpty

                                            YTextBase {
                                                id: id_meaning_sense_index
                                                color: YColors.grayText
                                                font.pixelSize: 24
                                                font.weight: Font.Normal
                                                font.family: fontManager.fontFamilyEnUs
                                                width: 36
                                                topPadding: 4
                                                height: id_meaning_sense_content.height
                                                text: ("%1:").arg(String.fromCharCode(97 + index))
                                                visible: !(id_meaning_sense_repeater.count === 1
                                                           && (id_meaning_sense_content.textIsEmpty || id_meaning_sense_subSense_repeater.count < 1))
                                                //text: "a:"
                                            }

                                            YTextBase {
                                                id: id_meaning_sense_content
                                                anchors.left: id_meaning_sense_index.visible ? id_meaning_sense_index.right : parent.left
                                                anchors.right: parent.right
                                                color: "#FFFFFF"
                                                font.pixelSize: 28
                                                font.weight: Font.Normal
                                                font.family: fontManager.fontFamilyEnUs
                                                wrapMode: YTextBase.Wrap
                                                textFormat: YTextBase.RichText
                                                height: paintedHeight
                                                text: textIsEmpty ? "" : removeHtmlTag(id_meaning_sense_column.modelModelData.dt.content[0])
                                                //text: dictJson.wordList[0].def.sensb[0].meaning[0].sense[0].dt.content[0]
                                                readonly property bool textIsEmpty: (typeof id_meaning_sense_column.modelModelData.dt == "undefined"
                                                                                    || typeof id_meaning_sense_column.modelModelData.dt.content == "undefined")
                                            }
                                        }

                                        Repeater {
                                            id: id_meaning_sense_subSense_repeater
                                            model: (typeof id_meaning_sense_column.modelModelData.subSense == "undefined") ? null : id_meaning_sense_column.modelModelData.subSense
                                            //model: dictJson.wordList[0].def.sensb[0].meaning[0].sense[0].subSense[0]

                                            Item {
                                                id: id_meaning_sense_subSense_item
                                                width: id_meaning_content.width
                                                height: id_meaning_sense_subSense_content.height
                                                readonly property var modelModelData: model.modelData

                                                YTextBase {
                                                    id: id_meaning_sense_subSense_index
                                                    color: YColors.grayText
                                                    font.pixelSize: 24
                                                    font.weight: Font.Normal
                                                    font.family: fontManager.fontFamilyEnUs
                                                    width: 36
                                                    height: id_meaning_sense_subSense_content.height
                                                    text: ("(%1)").arg(index + 1)
                                                    visible: id_meaning_sense_subSense_repeater.count > 1
                                                }

                                                YTextBase {
                                                    id: id_meaning_sense_subSense_content
                                                    anchors.left: id_meaning_sense_subSense_index.visible ? id_meaning_sense_subSense_index.right : parent.left
                                                    anchors.right: parent.right
                                                    color: "#FFFFFF"
                                                    font.pixelSize: 28
                                                    font.weight: Font.Normal
                                                    font.family: fontManager.fontFamilyEnUs
                                                    wrapMode: YTextBase.Wrap
                                                    textFormat: YTextBase.RichText
                                                    height: paintedHeight
                                                    text: visible ? removeHtmlTag(id_meaning_sense_subSense_item.modelModelData.dt.content[0]) : ""
                                                    visible: typeof id_meaning_sense_subSense_item.modelModelData.dt != "undefined"
                                                        && typeof id_meaning_sense_subSense_item.modelModelData.dt.content != "undefined"
                                                    //text: dictJson.wordList[0].def.sensb[0].meaning[0].sense[0].subSense[0].dt.content[0]
                                                }

                                            } // Item

                                        } // Repeater id_meaning_sense_subSense_repeater

                                    } // Item

                                } // Repeater id_meaning_sense_repeater

                            } // Column id_meaning_content

                        } // Item

                    } // Repeater id_word_def_sensb_meaning_repeater

                } // Column

            } // Repeater id_word_def_sensb_repeater

            YText {
                font.family: fontManager.fontFamilyEnUs
                font.weight: Font.Bold
                wrapMode: YTextBase.Wrap
                color: YColors.grayText
                width: id_for_wordList_column.width
                height: paintedHeight
                //text: ("First Know Use: " + id_word_Column.modelModelData.def.data)
                text: visible ? ("First Know Use: " + id_word_Column.modelModelData.def.date) : ""
                visible: (typeof id_word_Column.modelModelData.def != "undefined"
                         && typeof id_word_Column.modelModelData.def.date != "undefined")
            } // text word_def_date

            YText {
                font.family: fontManager.fontFamilyEnUs
                font.weight: Font.Bold
                wrapMode: YTextBase.Wrap
                textFormat: YTextBase.RichText
                color: YColors.grayText
                width: id_for_wordList_column.width
                height: paintedHeight
                text: {
                    console.log("YDictTypeDtWebsterDetail.qml === et type:", typeof id_word_Column.modelModelData.et)
                    if (typeof id_word_Column.modelModelData.et != "undefined") {
                        console.log("YDictTypeDtWebsterDetail.qml === et:", JSON.stringify(id_word_Column.modelModelData.et))
                        if (typeof id_word_Column.modelModelData.et == "string") {
                            return removeHtmlTag(id_word_Column.modelModelData.et)
                        } else if (typeof id_word_Column.modelModelData.et == "object") {
                            let qsRstList = []
                            let etObj = id_word_Column.modelModelData.et
                            if (typeof id_word_Column.modelModelData.et.et != "undefined") {
                                etObj = id_word_Column.modelModelData.et.et
                            }
                            if (typeof etObj.content == "string") {
                                qsRstList.push(etObj.content)
                            }
                            if (typeof etObj.content == "object") {
                                etObj.content.forEach(function(qsContent){
                                    qsRstList.push(qsContent)
                                })
                            }
                            Object.keys(etObj).forEach(function(keyName){
                                if (keyName === "content") {
                                    return
                                }
                                if (keyName !== "content" && typeof etObj[keyName] == "string") {
                                    qsRstList.push(etObj[keyName])
                                }
                            })
                            return removeHtmlTag(qsRstList.join(" "))
                        }
                    }
                    return ""
                }
                visible: text.length > 0
            } // text word_et

            Repeater {
                id: id_word_dro_repeater
                model: (typeof id_word_Column.modelModelData.dro == "undefined") ? null : id_word_Column.modelModelData.dro

                YDictTypeDtWebsterDroItem {
                    width: id_for_wordList_column.width
                    modelModelData: model.modelData
                }

            } // Repeater id_word_dro_repeater

            YDictTypeDtWebsterDroItem {
                width: id_for_wordList_column.width
                visible: (typeof id_word_Column.modelModelData.dro != "undefined") && id_word_dro_repeater.count < 1
                modelModelData: visible ? id_word_Column.modelModelData.dro : null
            } // Item id_word_dro_item

            YText {
                font.family: fontManager.fontFamilyEnUs
                font.weight: Font.Bold
                wrapMode: YTextBase.Wrap
                textFormat: YTextBase.RichText
                color: YColors.grayText
                width: id_for_wordList_column.width
                height: paintedHeight
                text: visible ? removeHtmlTag(id_word_Column.modelModelData.syn) : ""
                visible: typeof id_word_Column.modelModelData.syn != "undefined"
            } // text word_syn

            YText {
                font.family: fontManager.fontFamilyEnUs
                font.weight: Font.Bold
                wrapMode: YTextBase.Wrap
                textFormat: YTextBase.RichText
                color: YColors.grayText
                width: id_for_wordList_column.width
                height: paintedHeight
                text: visible ? id_word_Column.modelModelData.lb : ""
                visible: typeof id_word_Column.modelModelData.lb != "undefined"
            } // text word_lb

            Column {
                width: parent.width
                spacing: 12

                Repeater {
                    id: id_derivative_repeater
                    model: {
                        if (typeof id_word_Column.modelModelData.uro == "object") {
                            if (typeof id_word_Column.modelModelData.uro.length == "number") {
                                return id_word_Column.modelModelData.uro
                            } else {
                                return [id_word_Column.modelModelData.uro]
                            }
                        }
                        return []
                    }

                    YText {
                        id: id_derivative_text
                        color: YColors.white
                        font.family:  fontManager.fontFamilyEnUs
                        width: id_for_wordList_column.width
                        height: contentHeight
                        textFormat: Text.RichText
                        text: {
                            let qsRst = ""
                            if (typeof model.modelData.ure == "string") {
                                qsRst += model.modelData.ure
                            }
                            let qsPrAndFl = ""
                            if (typeof model.modelData.pr == "string") {
                                qsPrAndFl += "\\" + model.modelData.pr + "\\"
                            }
                            if (typeof model.modelData.fl == "string") {
                                if (qsPrAndFl.length > 0) {
                                    qsPrAndFl += "&nbsp;&nbsp;"
                                }
                                qsPrAndFl += "<i>" + model.modelData.fl + "</i>"
                            }
                            if (qsPrAndFl.length > 0) {
                                qsPrAndFl = '&nbsp;&nbsp;<span style="color:' + YColors.grayText + ';font-weight:400;">' + qsPrAndFl + '</span>'
                            }
                            return qsRst + qsPrAndFl
                        }
                        visible: text.length > 0
                    }
                }
            }
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
                text: YTranslateText.contentComeFrom + '<br/>' + YTranslateText.dtWebster
            }

        }

    } //Column id_for_wordList_column

}// Item root


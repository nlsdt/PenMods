import QtQuick 2.12
import com.youdao.pen 1.0

import BaseQml 1.0
import "../i18n"
import "./YDictKoUtils.js" as YDictKoUtils

Item {
    id: id_dt_chko_detail_item
    height: id_senseList_column.height

    property var dictJson: id_dict_detail_page.dictJson
    property var wordText: ""
    onDictJsonChanged: {
        if (dictJson === null || typeof dictJson != "object") {
            wordText = ""
        }
        if (typeof dictJson.word == "string") {
            wordText = dictJson.word
        }
    }

    function formattedChineseText(qsText){
        return YDictKoUtils.formattedChineseText(qsText)
    }

    function replaceSpecificSymble(qsText){
        return YDictKoUtils.replaceSpecificSymble(qsText)
    }

    Column {
        id: id_senseList_column
        width: parent.width
        spacing: 20

        Repeater {
            id: id_dataList_repeater
            model: (typeof dictJson == "undefined" || typeof dictJson.dataList == "undefined") ? [] : dictJson.dataList

            Column {
                id: id_wordList_datainfo_column
                width: id_senseList_column.width
                spacing: 20
                property var dataObjCur: model.modelData

                YTextMedium {
                    id: id_wordList_precontent
                    font.family: fontManager.fontFamilyKoKr
                    wrapMode: Text.Wrap
                    color: YColors.white
                    font.pixelSize: 26
                    width: parent.width
                    height: contentHeight
                    text: typeof dataObjCur.meanings.precontent == "string" ? replaceSpecificSymble(dataObjCur.meanings.precontent) : ""
                    visible: text.length > 0
                }

                Repeater {
                    model: dataObjCur.meanings.sense

                    Column {
                        id: id_wordList_senseinfo_column
                        width: id_wordList_datainfo_column.width
                        spacing: 20
                        property var senseObjCur: model.modelData

                        YText {
                            id: id_wordList_senseinfo_pos
                            font.family: fontManager.fontFamilyZhCn
                            font.pixelSize: 26
                            color: YColors.red
                            width: parent.width
                            height: contentHeight
                            text: {
                                if ((senseObjCur !== null)) {
                                    let qsRst = ""
                                    if (typeof senseObjCur.pos == "string") {
                                        qsRst += senseObjCur.pos
                                    }
                                    if (typeof senseObjCur.usetype == "string") {
                                        if (qsRst.length > 0) {
                                            qsRst += "/"
                                        }
                                        qsRst += senseObjCur.usetype
                                    }
                                    return (qsRst.length > 0) ? ("[" + qsRst + "]") : ""
                                }
                                return ""
                            }
                            visible: text.length > 0
                        }

                        Column {
                            width: parent.width
                            spacing: 16

                            Repeater {
                                model: senseObjCur.trs

                                Column {
                                    width: id_wordList_senseinfo_column.width
                                    spacing: 10

                                    readonly property var trsObj: model.modelData
                                    readonly property int trsObjIndex: index + 1

                                    Item {
                                        id: id_wordList_sense_trs_item
                                        width: id_wordList_senseinfo_column.width
                                        height: id_wordList_sense_trs_content.height

                                        YText {
                                            id: id_wordList_sense_trs_index
                                            width: 43
                                            height: id_wordList_sense_trs_content.height
                                            anchors.left: parent.left
                                            topPadding: 4
                                            font.family: fontManager.fontFamilyZhCn
                                            font.pixelSize: 26
                                            color: YColors.grayText
                                            text: "%1.".arg(trsObjIndex)
                                            visible: trsObj !== null
                                        }

                                        Column {
                                            id: id_wordList_sense_trs_content
                                            anchors.left: id_wordList_sense_trs_index.right
                                            anchors.right: parent.right
                                            spacing: 10

                                            YTextMedium {
                                                id: id_wordList_sense_trs_pos
                                                width: parent.width
                                                height: contentHeight
                                                font.family: fontManager.fontFamilyZhCn
                                                color: YColors.white
                                                wrapMode: YTextBase.Wrap
                                                text: {
                                                    let qsRst = ""
                                                    if (trsObj !== null && typeof trsObj.pos == "string") {
                                                        qsRst += "[" + trsObj.pos
                                                        if (typeof trsObj.usetype == "string") {
                                                            qsRst += " " + trsObj.usetype
                                                        }
                                                        qsRst += "]"
                                                    }
                                                    return qsRst
                                                }
                                                visible: text.length > 0
                                            }

                                            YTextMedium {
                                                id: id_wordList_sense_trs_tr
                                                width: parent.width
                                                height: contentHeight
                                                font.family: fontManager.fontFamilyKoKr
                                                font.pixelSize: 26
                                                color: YColors.white
                                                textFormat: Text.RichText
                                                wrapMode: YTextBase.Wrap
                                                text: {
                                                    if (trsObj !== null) {
                                                        //专用语
                                                        let qsMeans = ""
                                                        if (typeof trsObj.terminology == "string") {
                                                            qsMeans = trsObj.terminology
                                                            qsMeans += ('<span style="color:%1;font-family:%2;">').arg(YColors.grayText).arg(fontManager.fontFamilyZhCn)
                                                                    + qsMeans.replace(/</g, "&lt;").replace(/>/g, "&gt;") + '</span>'
                                                        }
                                                        //释义
                                                        let qsMeanRaw = ""
                                                        if (typeof trsObj.tr == "string") {
                                                            qsMeanRaw += formattedChineseText(trsObj.tr)
                                                        }
                                                        return replaceSpecificSymble(qsMeans + qsMeanRaw)
                                                    }
                                                    return ""
                                                }
                                                visible: text.length > 0
                                            }

                                            Repeater {
                                                model: (trsObj !== null && typeof trsObj.sentences != "undefined") ? trsObj.sentences : []

                                                Item {
                                                    id: id_wordList_sense_trs_sentences_item
                                                    width: id_wordList_sense_trs_content.width
                                                    height: id_wordList_sense_trs_sentences_content.height
                                                    readonly property var sentencesObj: model.modelData

                                                    YText {
                                                        id: id_wordList_sense_trs_sentences_index
                                                        width: 24
                                                        height: id_wordList_sense_trs_sentences_content.height
                                                        anchors.left: parent.left
                                                        font.family: fontManager.fontFamilyEnUs
                                                        font.pixelSize: 26
                                                        color: YColors.grayText
                                                        text: "· "
                                                    }

                                                    Column {
                                                        id: id_wordList_sense_trs_sentences_content
                                                        anchors.left: id_wordList_sense_trs_sentences_index.right
                                                        anchors.right: parent.right
                                                        spacing: 6

                                                        YText {
                                                            id: id_wordList_sense_trs_sentences_cn
                                                            width: parent.width
                                                            height: contentHeight
                                                            font.family: fontManager.fontFamilyZhCn
                                                            textFormat: YTextBase.RichText
                                                            wrapMode: YTextBase.Wrap
                                                            font.pixelSize: 26
                                                            color: YColors.grayText
                                                            text: {
                                                                if (typeof sentencesObj.cn == "string") {
                                                                    let vSplitText = sentencesObj.cn.split(wordText)
                                                                    let qsRst = vSplitText.join(('<span style="color:%1;">').arg(YColors.red) + wordText + '</span>')
                                                                    return replaceSpecificSymble(qsRst)
                                                                }
                                                                return ""
                                                            }
                                                            visible: text.length > 0
                                                        }

                                                        YTextMedium {
                                                            id: id_wordList_sense_trs_sentences_ko
                                                            width: parent.width
                                                            height: contentHeight
                                                            font.family: fontManager.fontFamilyKoKr
                                                            textFormat: YTextBase.RichText
                                                            wrapMode: YTextBase.Wrap
                                                            font.pixelSize: 26
                                                            color: YColors.grayText
                                                            text: (typeof sentencesObj.ko == "string") ? replaceSpecificSymble(formattedChineseText(sentencesObj.ko)) : ""
                                                            visible: text.length > 0
                                                        }
                                                    }
                                                }
                                            }

                                            YTextMedium {
                                                id: id_wordList_sense_trs_correctusage
                                                width: parent.width
                                                height: contentHeight
                                                font.pixelSize: 28
                                                color: YColors.red
                                                textFormat: Text.RichText
                                                wrapMode: YTextBase.Wrap
                                                text: {
                                                    if (typeof trsObj["correct-usage"] != "undefined") {
                                                        let qsView = ""
                                                        trsObj["correct-usage"].forEach(function(objCorrect){
                                                            if (typeof objCorrect.viewcontent == "string") {
                                                                if (qsView.length > 0) {
                                                                    qsView += "、"
                                                                }
                                                                qsView += objCorrect.viewcontent
                                                            }
                                                        })
                                                        let qsTmp = YTranslateText.wordsCorrectUsage + '&nbsp;&nbsp;<span style="color:'
                                                            + YColors.white + ';font-family:' + fontManager.fontFamilyZhCn + ';">'
                                                            + qsView + '</span>'
                                                        return replaceSpecificSymble(qsTmp)
                                                    }
                                                    return ""
                                                }
                                                visible: text.length > 0
                                            }

                                            YTextMedium {
                                                id: id_wordList_sense_trs_otheruse
                                                width: parent.width
                                                height: contentHeight
                                                font.pixelSize: 28
                                                color: YColors.red
                                                textFormat: Text.RichText
                                                wrapMode: YTextBase.Wrap
                                                text: {
                                                    if (typeof trsObj["other-use"] != "undefined") {
                                                        let qsView = ""
                                                        trsObj["other-use"].forEach(function(objOther){
                                                            if (typeof objOther.viewcontent == "string") {
                                                                if (qsView.length > 0) {
                                                                    qsView += "、"
                                                                }
                                                                qsView += objOther.viewcontent
                                                            }
                                                        })
                                                        let qsTmp = YTranslateText.wordsOtherUse + '&nbsp;&nbsp;<span style="color:'
                                                            + YColors.white + ';font-family:' + fontManager.fontFamilyZhCn + ';">'
                                                            + qsView + '</span>'
                                                        return replaceSpecificSymble(qsTmp)
                                                    }
                                                    return ""
                                                }
                                                visible: text.length > 0
                                            }
                                        }
                                    }

                                    Column {
                                        id: id_synonym_column
                                        width: parent.width
                                        spacing: 4
                                        readonly property var synonymList: typeof trsObj.synonym != "undefined" ? trsObj.synonym : []

                                        YTextMedium {
                                            color: YColors.red
                                            text: YTranslateText.synonymFor
                                            visible: id_synonym_column.synonymList.length > 0
                                        }

                                        Repeater {
                                            model: id_synonym_column.synonymList

                                            YTextMedium {
                                                id: id_synonym_word
                                                wrapMode: YText.Wrap
                                                width: id_synonym_column.width
                                                height: contentHeight
                                                color: YColors.white
                                                font.family: fontManager.fontFamilyZhCn
                                                font.pixelSize: 30
                                                text: model.modelData.viewcontent // redirectquery
                                                visible: text.length > 0

                                                YMouseArea {
                                                    anchors.fill: parent
                                                    onClicked: {
                                                        //console.log("YDictTypeDtChKoDetail.qml====id_synonym_word_clicked mainQuery:", id_synonym_word.text)
                                                        //id_dict_detail_page.requeryWord(id_synonym_word.text, "zh-CHS", "ko")
                                                    }
                                                    objectName: "YDictTypeDtChKoDetail.qml_id_synonym_word"
                                                }
                                            }
                                        }
                                    }

                                    Column {
                                        id: id_antonym_column
                                        width: parent.width
                                        spacing: 4
                                        readonly property var antonymList: typeof trsObj.antonym != "undefined" ? trsObj.antonym : []

                                        YTextMedium {
                                            color: YColors.red
                                            text: YTranslateText.antonyms
                                            visible: id_antonym_column.antonymList.length > 0
                                        }

                                        Repeater {
                                            model: id_antonym_column.antonymList

                                            YTextMedium {
                                                id: id_antonym_word
                                                wrapMode: YText.Wrap
                                                width: id_antonym_column.width
                                                height: contentHeight
                                                color: YColors.white
                                                font.family: fontManager.fontFamilyZhCn
                                                font.pixelSize: 30
                                                text: model.modelData.viewcontent // redirectquery
                                                visible: text.length > 0

                                                YMouseArea {
                                                    anchors.fill: parent
                                                    onClicked: {
                                                        //console.log("YDictTypeDtChKoDetail.qml====id_antonym_word_clicked mainQuery:", id_antonym_word.text)
                                                        //id_dict_detail_page.requeryWord(id_antonym_word.text, "zh-CHS", "ko")
                                                    }
                                                    objectName: "YDictTypeDtChKoDetail.qml_id_antonym_word"
                                                }
                                            }
                                        }
                                    }

                                    Column {
                                        id: id_notice_column
                                        width: parent.width
                                        spacing: 4

                                        YTextMedium {
                                            color: YColors.red
                                            text: YTranslateText.notice
                                            visible: typeof trsObj.notice == "string"
                                        }

                                        YTextMedium {
                                            id: id_notice_text
                                            width: parent.width
                                            height: contentHeight
                                            font.family: fontManager.fontFamilyKoKr
                                            font.pixelSize: 26
                                            color: YColors.white
                                            textFormat: Text.RichText
                                            wrapMode: YTextBase.Wrap
                                            text: {
                                                if (typeof trsObj.notice == "string") {
                                                    return replaceSpecificSymble(formattedChineseText(trsObj.notice))
                                                }
                                                return ""
                                            }
                                            visible: text.length > 0
                                        }
                                    }
                                }

                            }
                        }
                    }

                }

                Column {
                    id: id_synonym_all_column
                    width: parent.width
                    spacing: 4
                    readonly property var synonymList: typeof dataObjCur["synonym-all"] != "undefined" ? dataObjCur["synonym-all"] : []

                    YTextMedium {
                        color: YColors.red
                        text: YTranslateText.synonymFor
                        visible: id_synonym_all_column.synonymList.length > 0
                    }

                    Repeater {
                        model: id_synonym_all_column.synonymList

                        YTextMedium {
                            id: id_synonym_all_word
                            wrapMode: YText.Wrap
                            width: id_synonym_column.width
                            height: contentHeight
                            color: YColors.white
                            font.family: fontManager.fontFamilyZhCn
                            font.pixelSize: 30
                            text: model.modelData.viewcontent // redirectquery
                            visible: text.length > 0

                            YMouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    //console.log("YDictTypeDtChKoDetail.qml====id_synonym_all_word_clicked mainQuery:", id_synonym_all_word.text)
                                    //id_dict_detail_page.requeryWord(id_synonym_all_word.text, "zh-CHS", "ko")
                                }
                                objectName: "YDictTypeDtChKoDetail.qml_id_synonym_all_word"
                            }
                        }
                    }
                }

                Column {
                    width: parent.width
                    spacing: 6

                    YText {
                        color: YColors.grayText
                        text: YTranslateText.differentPronunciation
                        visible: typeof dataObjCur.diffphone == "string"
                    }

                    YTextMedium {
                        color: YColors.white
                        font.family: fontManager.fontFamilyEnUs
                        text: visible ? dataObjCur.diffphone : ""
                        visible: typeof dataObjCur.diffphone == "string"
                    }
                }

                Column {
                    width: parent.width
                    spacing: 6

                    YText {
                        color: YColors.grayText
                        text: YTranslateText.wordsVariants
                        visible: typeof dataObjCur.variants == "string"
                    }

                    YTextMedium {
                        color: YColors.white
                        font.family: fontManager.fontFamilyZhCn
                        text: visible ? dataObjCur.variants : ""
                        visible: typeof dataObjCur.variants == "string"
                    }
                }

                YVerticalDividingLine {
                    id: id_div_line
                    width: parent.width
                    visible: index < (id_dataList_repeater.count - 1)
                }

            }
        }

        YText {
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
            text: ("%1<br/>%2").arg(YTranslateText.contentComeFrom).arg(YTranslateText.dtChKo)
        }

    }
}

/*

{
    "word": "具体劳动",
    "dataList": [
        {
            "pinyin": "jùtǐ láodòng",
            "word": "具体劳动",
            "meanings": {
                "sense": [
                    {
                        "trs": [
                            {
                                "antonym": [
                                    {
                                        "redirectquery": "抽象劳动",
                                        "viewcontent": "抽象劳动"
                                    }
                                ],
                                "sentences": [
                                    {
                                        "ko": "구체적 유용 노동은 상품의 사용 가치를 창출한다.",
                                        "cn": "具体劳动创造商品的使用价值。"
                                    }
                                ],
                                "tr": "구체적 유용(有用) 노동."
                            }
                        ]
                    }
                ]
            }
        }
    ]
}

  */

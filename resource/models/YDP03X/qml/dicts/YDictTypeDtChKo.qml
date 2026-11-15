import QtQuick 2.12
import com.youdao.pen 1.0

import BaseQml 1.0
import "../i18n"
import "./YDictKoUtils.js" as YDictKoUtils

YDictTypeBase {
    id: id_dt_chko
    title: YTranslateText.dtChKo
    property var wordText: ""
    property var posList: []
    property var senseList: []
    property var currentPosIdx: 0
    onDictJsonChanged: {
        if (dictJson === null || typeof dictJson != "object") {
            wordText = ""
            posList = []
            senseList = []
            currentPosIdx = 0
            return
        }
        wordText = dictJson.word
        var posListTmp = []
        var posInfoListTmp = []
        var posInfoListTmpNoPos = []
        dictJson.dataList.forEach(function(dataObj){
            var qsPinyin = ""
            if (typeof dataObj.pinyin == "string" && dataObj.pinyin.length > 0) {
                qsPinyin = "/" + dataObj.pinyin + "/"
            }
            var qsVoice = ""
            if (typeof dataObj.voice == "string" && dataObj.voice.length > 0) {
                qsVoice = "/" + dataObj.voice + "/"
            }
            var qsPrecontent = ""
            if (typeof dataObj.meanings.precontent == "string") {
                qsPrecontent = dataObj.meanings.precontent
            }
            dataObj.meanings.sense.forEach(function(senseObj){
                var bHavePos = false
                if (typeof senseObj.pos == "string" && senseObj.pos.length > 0) {
                    posListTmp.push(senseObj.pos[0])
                    bHavePos = true
                }
                var posInfoObj = new Object
                posInfoObj["pinyin"] = qsPinyin
                posInfoObj["voice"] = qsVoice
                posInfoObj["precontent"] = qsPrecontent
                if (typeof senseObj.pos == "string") {
                    posInfoObj["pos"] = senseObj.pos
                }
                if (typeof senseObj.usetype == "string") {
                    posInfoObj["usetype"] = senseObj.usetype
                }
                if (typeof senseObj.trs == "object" && senseObj.trs.length > 0) {
                    posInfoObj["trs"] = senseObj.trs[0]
                }
                if (bHavePos) {
                    posInfoListTmp.push(posInfoObj)
                } else {
                    posInfoListTmpNoPos.push(posInfoObj)
                }
            })
        })
        posList = posListTmp
        if (posInfoListTmp.length > 0) {
            senseList = posInfoListTmp
        } else {
            senseList = posInfoListTmpNoPos
        }
        currentPosIdx = 0
    }

    function formattedChineseText(qsText){
        return YDictKoUtils.formattedChineseText(qsText)
    }

    function replaceSpecificSymble(qsText){
        return YDictKoUtils.replaceSpecificSymble(qsText)
    }

    Item {
        width: parent.width
        height: id_for_wordList_column.height

        Column {
            id: id_for_wordList_column
            width: parent.width
            spacing: 16

            Flickable {
                width: parent.width
                height: id_wordList_hw_row.height
                contentWidth: id_wordList_hw_row.width
                visible: id_wordList_hw_repeater.count > 1
                clip: true

                Row {
                    id: id_wordList_hw_row
                    spacing: 10

                    Repeater {
                        id: id_wordList_hw_repeater
                        model: posList

                        YMouseArea {
                            id: id_word_hw_MouseArea
                            width: id_word_hw_background.width
                            height: 52
                            objectName: "YDictTypeDtChKo.qml_wordListhw_index" + index

                            Rectangle {
                                id: id_word_hw_background
                                width: id_word_hw_text.width + 32 * 2
                                height: parent.height
                                color: YColors.grayNormal
                                opacity: parent.pressed ? 0.6 : 1
                                radius: 38

                                YTextMedium {
                                    id: id_word_hw_text
                                    anchors.centerIn: parent
                                    font.family: fontManager.fontFamilyZhCn
                                    font.pixelSize: 26
                                    textFormat: YTextMedium.RichText
                                    color: index === currentPosIdx ? YColors.red : YColors.grayText
                                    width: paintedWidth
                                    height: paintedHeight
                                    text: model.modelData
                                }

                            }

                            onClicked: {
                                currentPosIdx = index
                            }
                        }
                    } // id_wordList_hw_repeater

                } // Row id_wordList_hw_row

            }

            Column {
                id: id_wordList_senseinfo_column
                width: parent.width
                spacing: 20
                readonly property var senseObjCur: (currentPosIdx < senseList.length) ? senseList[currentPosIdx] : null
                readonly property var senseObjPinyin: senseObjCur !== null ? senseObjCur.pinyin : ""
                readonly property var senseObjVoice: senseObjCur !== null ? senseObjCur.voice : ""
                readonly property var senseObjPrecontent: senseObjCur !== null ? senseObjCur.precontent : ""

                YText {
                    id: id_wordList_senseinfo_pinyin
                    font.pixelSize: 26
                    color: YColors.grayText
                    width: contentWidth
                    height: contentHeight
                    textFormat: YText.RichText
                    text: {
                        let qsRst = ""
                        if (id_wordList_senseinfo_column.senseObjPinyin.length > 0) {
                            qsRst += '<span style="font-family:' + fontManager.fontFamilyZhCn + ';font-size:28px">'
                                    + id_wordList_senseinfo_column.senseObjPinyin + '</span>'
                        }
                        if (id_wordList_senseinfo_column.senseObjVoice.length > 0) {
                            if (qsRst.length > 0) {
                                qsRst += '&nbsp;&nbsp;'
                            }
                            qsRst += '<span style="font-family:' + fontManager.fontFamilyKoKr + '">'
                                    + formattedChineseText(id_wordList_senseinfo_column.senseObjVoice) + '</span>'
                        }
                        return qsRst
                    }
                    visible: text.length > 0
                }

                YTextMedium {
                    id: id_wordList_precontent
                    font.family: fontManager.fontFamilyKoKr
                    wrapMode: Text.Wrap
                    color: YColors.white
                    font.pixelSize: 26
                    width: parent.width
                    height: contentHeight
                    text: replaceSpecificSymble(id_wordList_senseinfo_column.senseObjPrecontent)
                    visible: text.length > 0
                }

                YText {
                    id: id_wordList_senseinfo_pos
                    font.family: fontManager.fontFamilyZhCn
                    color: YColors.red
                    width: parent.width
                    height: contentHeight
                    text: {
                        if (id_wordList_senseinfo_column.senseObjCur !== null) {
                            let qsRst = ""
                            if (typeof id_wordList_senseinfo_column.senseObjCur.pos == "string") {
                                qsRst += id_wordList_senseinfo_column.senseObjCur.pos
                            }
                            if (typeof id_wordList_senseinfo_column.senseObjCur.usetype == "string") {
                                if (qsRst.length > 0) {
                                    qsRst += "/"
                                }
                                qsRst += id_wordList_senseinfo_column.senseObjCur.usetype
                            }
                            return (qsRst.length > 0) ? ("[" + qsRst + "]") : ""
                        }
                        return ""
                    }
                    visible: text.length > 0
                }

                Item {
                    id: id_wordList_sense_trs_item
                    width: id_wordList_senseinfo_column.width
                    height: id_wordList_sense_trs_content.height
                    readonly property var trsObj: (id_wordList_senseinfo_column.senseObjCur !== null
                                                   && typeof id_wordList_senseinfo_column.senseObjCur.trs != "undefined")
                                                  ? id_wordList_senseinfo_column.senseObjCur.trs : null

                    YText {
                        id: id_wordList_sense_trs_index
                        width: 43
                        height: id_wordList_sense_trs_content.height
                        anchors.left: parent.left
                        topPadding: 4
                        font.family: fontManager.fontFamilyZhCn
                        font.pixelSize: 26
                        color: YColors.grayText
                        text: "1."
                        visible: id_wordList_sense_trs_item.trsObj !== null && id_wordList_sense_trs_content.height > 0
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
                            color: "#FFFFFF"
                            wrapMode: YTextBase.Wrap
                            text: {
                                let qsRst = ""
                                if (id_wordList_sense_trs_item.trsObj !== null && typeof id_wordList_sense_trs_item.trsObj.pos == "string") {
                                    qsRst += "[" + id_wordList_sense_trs_item.trsObj.pos
                                    if (typeof id_wordList_sense_trs_item.trsObj.usetype == "string") {
                                        qsRst += " " + id_wordList_sense_trs_item.trsObj.usetype
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
                            color: "#FFFFFF"
                            textFormat: Text.RichText
                            wrapMode: YTextBase.Wrap
                            text: {
                                if (id_wordList_sense_trs_item.trsObj !== null) {
                                    //专用语
                                    let qsMeans = ""
                                    if (typeof id_wordList_sense_trs_item.trsObj.terminology == "string") {
                                        qsMeans = id_wordList_sense_trs_item.trsObj.terminology
                                        qsMeans = ('<span style="color:%1;font-family:%2;">').arg(YColors.grayText).arg(fontManager.fontFamilyZhCn)
                                                + qsMeans.replace(/</g, "&lt;").replace(/>/g, "&gt;") + '</span>'
                                    }
                                    //释义
                                    let qsMeanRaw = ""
                                    if (typeof id_wordList_sense_trs_item.trsObj.tr == "string") {
                                        qsMeanRaw += formattedChineseText(id_wordList_sense_trs_item.trsObj.tr)
                                    }
                                    return replaceSpecificSymble(qsMeans + qsMeanRaw)
                                }
                                return ""
                            }
                            visible: text.length > 0
                        }

                        Repeater {
                            model: (id_wordList_sense_trs_item.trsObj !== null
                                    && typeof id_wordList_sense_trs_item.trsObj.sentences != "undefined")
                                   ? id_wordList_sense_trs_item.trsObj.sentences : []

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
                                                let qsTmp = replaceSpecificSymble(sentencesObj.cn)
                                                let vSplitText = qsTmp.split(wordText)
                                                return vSplitText.join(('<span style="color=%1">').arg(YColors.red) + wordText + '')
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
                    }
                }
            }
        }
    }
}


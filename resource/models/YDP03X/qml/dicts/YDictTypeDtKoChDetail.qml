import QtQuick 2.12
import com.youdao.pen 1.0

import BaseQml 1.0
import "../i18n"
import "./YDictKoUtils.js" as YDictKoUtils

Item {
    id: id_dt_koch_detail_item
    height: id_dataList_column.height
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

    Column {
        id: id_dataList_column
        width: parent.width
        spacing: 20

        Repeater {
            id: id_dataList_repeater
            model: (typeof dictJson == "undefined" || typeof dictJson.dataList == "undefined") ? [] : dictJson.dataList

            Column {
                id: id_wordList_wordinfo_column
                width: parent.width
                spacing: 10
                readonly property var headWordInfoObjCur: model.modelData
                readonly property var headWordCur: {
                    var qsContent = typeof headWordInfoObjCur.word == "string" ? headWordInfoObjCur.word : ""
                    var qsSource = ""
                    if (typeof headWordInfoObjCur.source == "object") {
                        if (typeof headWordInfoObjCur.source["source-content"] == "string") {
                            qsSource = headWordInfoObjCur.source["source-content"]
                        } else if (typeof headWordInfoObjCur.source.foreign == "object") {
                            qsSource += typeof headWordInfoObjCur.source.foreign["foreign-source"] == "string" ? headWordInfoObjCur.source.foreign["foreign-source"] : ""
                            qsSource += typeof headWordInfoObjCur.source.foreign["foreign-content"] == "string" ? headWordInfoObjCur.source.foreign["foreign-content"] : ""
                        }
                    }
                    if (qsSource.length > 0) {
                        qsSource = '<span style="font-family:' + fontManager.fontFamilyZhCn + '">' + qsSource + '</span>'
                    }
                    return qsContent + qsSource
                }

                YTextMedium {
                    id: id_head_word_text
                    font.family: fontManager.fontFamilyKoKr
                    font.pixelSize: 30
                    textFormat: YTextMedium.RichText
                    color: "#FFFFFF"
                    width: parent.width
                    height: contentHeight
                    text: headWordCur
                    visible: text.length > 0
                }

                YTextMedium {
                    id: id_wordList_otheruse
                    font.family: fontManager.fontFamilyKoKr
                    wrapMode: Text.Wrap
                    color: YColors.white
                    font.pixelSize: 26
                    width: parent.width
                    height: contentHeight
                    text: typeof id_wordList_wordinfo_column.headWordInfoObjCur.otheruse == "string"
                          ? id_wordList_wordinfo_column.headWordInfoObjCur.otheruse : ""
                    visible: text.length > 0
                }

                YTextMedium {
                    id: id_wordList_precontent
                    font.family: fontManager.fontFamilyZhCn
                    wrapMode: Text.Wrap
                    color: YColors.white
                    width: parent.width
                    height: contentHeight
                    text: (id_wordList_wordinfo_column.headWordInfoObjCur !== null
                           && typeof id_wordList_wordinfo_column.headWordInfoObjCur.meanings != "undefined"
                           && typeof id_wordList_wordinfo_column.headWordInfoObjCur.meanings.precontent == "string")
                          ? id_wordList_wordinfo_column.headWordInfoObjCur.meanings.precontent : ""
                    visible: text.length > 0
                }

                YLoader {
                    id: id_meaning_loader
                    asynchronous: false
                    active: id_wordList_wordinfo_column.headWordInfoObjCur !== null
                            && typeof id_wordList_wordinfo_column.headWordInfoObjCur.meanings != "undefined"
                            && typeof id_wordList_wordinfo_column.headWordInfoObjCur.meanings.sense != "undefined"
                    property var senseList: active ? id_wordList_wordinfo_column.headWordInfoObjCur.meanings.sense : []
                    property int trsMeanIndex: 1
                    onSenseListChanged: {
                        trsMeanIndex = 1
                    }
                    sourceComponent: id_senseList_component
                }

                Component {
                    id: id_senseList_component
                    //senseList trsMeanIndex

                    Column {
                        id: id_senseList_column
                        width: id_wordList_wordinfo_column.width
                        spacing: 10

                        Repeater {
                            model: senseList

                            Column {
                                id: id_senseobj_column
                                width: id_senseList_column.width
                                spacing: 10
                                readonly property var senseObj: model.modelData

                                YText {
                                    id: id_sense_pos_text
                                    font.family: fontManager.fontFamilyZhCn
                                    color: YColors.red
                                    width: parent.width
                                    height: contentHeight
                                    text: typeof senseObj.pos == "string" ? "[" + senseObj.pos + "]" : ""
                                    visible: text.length > 0
                                }

                                Repeater {
                                    model: senseObj.trs

                                    Column {
                                        id: id_senseobj_trs_column
                                        width: id_senseobj_column.width
                                        spacing: 10
                                        readonly property var trsObj: model.modelData

                                        Item {
                                            id: id_trsobj_mean_item
                                            width: parent.width
                                            height: id_trsobj_mean_content_column.height

                                            YText {
                                                id: id_trsobj_mean_item_index
                                                font.family: fontManager.fontFamilyZhCn
                                                color: YColors.grayText
                                                width: 43
                                                anchors.left: parent.left
                                                height: contentHeight
                                                visible: text.length > 0
                                                Component.onCompleted: {
                                                    if (id_senseobj_trs_tr_text.visible
                                                            || id_senseobj_trs_sentences_repeater.count > 0) {
                                                        text = trsMeanIndex + "."
                                                        trsMeanIndex += 1
                                                    }
                                                }
                                            }

                                            Column {
                                                id: id_trsobj_mean_content_column
                                                anchors.left: id_trsobj_mean_item_index.right
                                                anchors.right: parent.right
                                                spacing: 10

                                                YText {
                                                    id: id_senseobj_trs_tr_text
                                                    width: parent.width
                                                    height: contentHeight
                                                    font.family: fontManager.fontFamilyZhCn
                                                    textFormat: YText.RichText
                                                    wrapMode: YText.Wrap
                                                    color: "#FFFFFF"
                                                    text: {
                                                        //释义和拼音
                                                        let qsMeanRaw = typeof trsObj.tr == "string" ? trsObj.tr : ""
                                                        qsMeanRaw = qsMeanRaw.replace(/<pinyin>/g, ('<span style="color:%1; font-family:').arg(YColors.grayText) + fontManager.fontFamilyEnUs + '"> ')
                                                        qsMeanRaw = qsMeanRaw.replace(/<\/pinyin>/g, ' <\/span>')
                                                        //专用语
                                                        let qsMeans = ""
                                                        if (typeof id_wordList_wordinfo_column.headWordInfoObjCur.meanings.terminology == "string") {
                                                            qsMeans += id_wordList_wordinfo_column.headWordInfoObjCur.meanings.terminology
                                                        }
                                                        if (typeof trsObj.terminology == "string") {
                                                            qsMeans += trsObj.terminology
                                                        }
                                                        if (qsMeans.length > 0) {
                                                            qsMeans = qsMeans.replace(/</g, "&lt;").replace(/>/g, "&gt;")
                                                            qsMeans = ('<span style="color:%1;">').arg(YColors.grayText) + qsMeans + '</span>'
                                                        }
                                                        return qsMeans + qsMeanRaw
                                                    }
                                                    visible: text.length > 0
                                                }

                                                Repeater {
                                                    id: id_senseobj_trs_sentences_repeater
                                                    model: typeof trsObj.sentences != "undefined" ? trsObj.sentences : []

                                                    Item {
                                                        id: id_trsobj_mean_sentences_item
                                                        width: id_trsobj_mean_content_column.width
                                                        height: id_trsobj_mean_sentences_content_column.height
                                                        readonly property var sentencesObj: model.modelData

                                                        YText {
                                                            id: id_trsobj_mean_sentences_index
                                                            color: YColors.grayText
                                                            font.weight: Font.Bold
                                                            font.family: fontManager.fontFamilyEnUs
                                                            width: 24
                                                            anchors.left: parent.left
                                                            height: id_trsobj_mean_sentences_content_column.height
                                                            text: ("·")
                                                        }

                                                        Column {
                                                            id: id_trsobj_mean_sentences_content_column
                                                            anchors.left: id_trsobj_mean_sentences_index.right
                                                            anchors.right: parent.right
                                                            spacing: 6

                                                            YText {
                                                                id: id_wordList_sense_trs_sentences_ko
                                                                width: parent.width
                                                                height: contentHeight
                                                                font.family: fontManager.fontFamilyKoKr
                                                                textFormat: YTextBase.RichText
                                                                wrapMode: YTextBase.Wrap
                                                                color: YColors.grayText
                                                                text: {
                                                                    if (typeof sentencesObj.ko == "string") {
                                                                        let vSplitText = sentencesObj.ko.split(wordText)
                                                                        return vSplitText.join(('<span style="color=%1">').arg(YColors.red) + wordText + '')
                                                                    }
                                                                    return ""
                                                                }
                                                                visible: text.length > 0
                                                            }

                                                            YText {
                                                                id: id_wordList_sense_trs_sentences_cn
                                                                width: parent.width
                                                                height: contentHeight
                                                                font.family: fontManager.fontFamilyZhCn
                                                                wrapMode: YTextBase.Wrap
                                                                color: YColors.grayText
                                                                text: (typeof sentencesObj.cn == "string") ? sentencesObj.cn : ""
                                                                visible: text.length > 0
                                                            }

                                                        }
                                                    }
                                                }
                                            }
                                        }

                                        Column {
                                            id: id_synonym_column
                                            width: id_senseobj_trs_column.width
                                            spacing: 10
                                            readonly property var synonymObjList: typeof trsObj.synonym != "undefined" ? trsObj.synonym : []
                                            readonly property string synonymTitle: YTranslateText.synonymsAndSynonyms

                                            YText {
                                                width: parent.width
                                                height: contentHeight
                                                font.family: fontManager.fontFamilyZhCn
                                                color: YColors.red
                                                text: id_synonym_column.synonymTitle
                                                visible: id_synonym_repeater.count > 0
                                            }

                                            Repeater {
                                                id: id_synonym_repeater
                                                model: id_synonym_column.synonymObjList

                                                YText {
                                                    id: id_synonym_word
                                                    textFormat: Text.RichText
                                                    wrapMode: YText.Wrap
                                                    width: id_synonym_column.width
                                                    height: contentHeight
                                                    color: YColors.white
                                                    font.family: fontManager.fontFamilyKoKr
                                                    text: formattedChineseText(model.modelData.viewcontent) // redirectquery
                                                    visible: text.length > 0

                                                    YMouseArea {
                                                        anchors.fill: parent
                                                        onClicked: {
                                                            //console.log("YDictTypeDtKoChDetail.qml====id_synonym_word_clicked mainQuery:", id_synonym_word.text)
                                                            //id_dict_detail_page.requeryWord(id_synonym_word.text, "ko", "zh-CHS")
                                                        }
                                                        objectName: "YDictTypeDtKoChDetail.qml_id_synonym_word"
                                                    }
                                                }
                                            }
                                        }

                                        Column {
                                            id: id_antonym_column
                                            width: id_senseobj_trs_column.width
                                            spacing: 10
                                            readonly property var antonymObjList: typeof trsObj.antonym != "undefined" ? trsObj.antonym : []
                                            readonly property string antonymTitle: YTranslateText.antonyms

                                            YText {
                                                width: parent.width
                                                height: contentHeight
                                                font.family: fontManager.fontFamilyZhCn
                                                color: YColors.red
                                                text: id_antonym_column.antonymTitle
                                                visible: id_antonym_repeater.count > 0
                                            }

                                            Repeater {
                                                id: id_antonym_repeater
                                                model: id_antonym_column.antonymObjList

                                                YText {
                                                    id: id_antonym_word
                                                    textFormat: Text.RichText
                                                    wrapMode: YText.Wrap
                                                    width: id_antonym_column.width
                                                    height: contentHeight
                                                    color: YColors.white
                                                    font.family: fontManager.fontFamilyKoKr
                                                    text: formattedChineseText(model.modelData.viewcontent) // redirectquery
                                                    visible: text.length > 0

                                                    YMouseArea {
                                                        anchors.fill: parent
                                                        onClicked: {
                                                            //console.log("YDictTypeDtKoChDetail.qml====id_antonym_word_clicked mainQuery:", id_antonym_word.text)
                                                            //id_dict_detail_page.requeryWord(id_synonym_word.text, "ko", "zh-CHS")
                                                        }
                                                        objectName: "YDictTypeDtKoChDetail.qml_id_antonym_word"
                                                    }
                                                }
                                            }
                                        }

                                        Repeater {
                                            id: id_extralcontent_repeater
                                            model: typeof trsObj.extralcontent != "undefined" ? trsObj.extralcontent : []

                                            YText {
                                                id: id_extralcontent_text
                                                width: id_senseobj_trs_column.width
                                                height: contentHeight
                                                color: YColors.white
                                                textFormat: Text.RichText
                                                wrapMode: YText.Wrap
                                                font.family: fontManager.fontFamilyKoKr
                                                text: {
                                                    let qsExtralPos = typeof model.modelData.extralpos != "undefined" ? model.modelData.extralpos : ""
                                                    let qsExtralTr = typeof model.modelData.extraltr != "undefined" ? model.modelData.extraltr : ""
                                                    if (qsExtralPos.length > 0) {
                                                        qsExtralPos = ('<span style="color:%1;font-family:%2;">%3</span>').arg(YColors.red).arg(fontManager.fontFamilyZhCn).arg(qsExtralPos)
                                                    }
                                                    if (qsExtralTr.length > 0) {
                                                        qsExtralTr = ('<span style="font-size:26px;font-family:%1;">%2</span>').arg(fontManager.fontFamilyKoKr).arg(qsExtralTr)
                                                    }
                                                    return qsExtralPos + ((qsExtralPos.length > 0 && qsExtralTr.length > 0) ? '&nbsp;&nbsp;' : '') + qsExtralTr
                                                }
                                                visible: text.length > 0
                                            }
                                        }

                                        YTextMedium {
                                            id: id_similarsuffix_text
                                            width: parent.width
                                            height: contentHeight
                                            font.pixelSize: 28
                                            color: YColors.red
                                            textFormat: Text.RichText
                                            wrapMode: YTextBase.Wrap
                                            text: {
                                                if (typeof trsObj["similar-suffix"] != "undefined") {
                                                    let qsView = ""
                                                    trsObj["similar-suffix"].forEach(function(objSuffix){
                                                        if (typeof objSuffix.viewcontent == "string") {
                                                            if (qsView.length > 0) {
                                                                qsView += "·"
                                                            }
                                                            qsView += objSuffix.viewcontent
                                                        }
                                                    })
                                                    return YTranslateText.wordsSimilarSuffix + '&nbsp;&nbsp;<span style="color:'
                                                        + YColors.white + ';font-family:' + fontManager.fontFamilyKoKr + ';">'
                                                        + qsView + '</span>'
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

                YVerticalDividingLine {
                    id: id_div_line
                    width: parent.width
                    visible: index < (id_dataList_repeater.count - 1)
                }

            }
        }

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
            text: ("%1<br/>%2").arg(YTranslateText.contentComeFrom).arg(YTranslateText.dtKoCh)
        }

    }
}


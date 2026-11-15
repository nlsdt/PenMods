import QtQuick 2.12

import BaseQml 1.0
import "../i18n"

YDictTypeBase {
    id: id_dt_koch
    title: YTranslateText.navDtKoCh
    property var wordText: ""
    property var headWordList: []
    property var headWordInfoList: []
    property var currentHeadWordIdx: 0
    onDictJsonChanged: {
        if (dictJson === null || typeof dictJson != "object") {
            wordText = ""
            headWordList = []
            headWordInfoList = []
            currentHeadWordIdx = 0
            return
        }
        wordText = dictJson.word
        var headWordListTmp = []
        var headWordInfoListTmp = []
        dictJson.dataList.forEach(function(dataObj){
            var qsContent = typeof dataObj.word == "string" ? dataObj.word : ""
            var qsSource = ""
            if (typeof dataObj.source == "object") {
                if (typeof dataObj.source["source-content"] == "string") {
                    qsSource = dataObj.source["source-content"]
                } else if (typeof dataObj.source.foreign == "object") {
                    qsSource += typeof dataObj.source.foreign["foreign-source"] == "string" ? dataObj.source.foreign["foreign-source"] : ""
                    qsSource += typeof dataObj.source.foreign["foreign-content"] == "string" ? dataObj.source.foreign["foreign-content"] : ""
                }
            }
            if (qsSource.length > 0) {
                qsSource = '<span style="font-family:' + fontManager.fontFamilyZhCn + '">' + qsSource + '</span>'
            }
            headWordListTmp.push(qsContent + qsSource)
            headWordInfoListTmp.push(dataObj)
        })
        headWordList = headWordListTmp
        headWordInfoList = headWordInfoListTmp
        currentHeadWordIdx = 0
    }

    Item {
        width: parent.width
        height: id_for_wordList_column.height

        Column {
            id: id_for_wordList_column
            width: parent.width
            spacing: 10

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
                        model: headWordList

                        YMouseArea {
                            id: id_word_hw_MouseArea
                            width: id_word_hw_background.width
                            height: 52
                            objectName: "YDictTypeDtKoCh.qml_wordListhw_index" + index

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
                                    font.family: fontManager.fontFamilyKoKr
                                    font.pixelSize: 26
                                    textFormat: YTextMedium.RichText
                                    color: index === currentHeadWordIdx ? YColors.red : YColors.grayText
                                    width: paintedWidth
                                    height: paintedHeight
                                    text: "<sup>" + (index + 1) + "</sup>" + model.modelData
                                }

                            }

                            onClicked: {
                                currentHeadWordIdx = index
                            }
                        }
                    } // id_wordList_hw_repeater

                } // Row id_wordList_hw_row

            }

            Column {
                id: id_wordList_wordinfo_column
                width: parent.width
                spacing: 10
                readonly property var headWordInfoObjCur: (currentHeadWordIdx < headWordInfoList.length) ? headWordInfoList[currentHeadWordIdx] : null
                readonly property var headWordCur: (currentHeadWordIdx < headWordList.length) ? headWordList[currentHeadWordIdx] : ""

                YText {
                    id: id_head_word_voice
                    font.pixelSize: 26
                    font.family: fontManager.fontFamilyKoKr
                    color: YColors.grayText
                    width: contentWidth
                    height: contentHeight
                    text: {
                        if (id_wordList_wordinfo_column.headWordInfoObjCur !== null
                                && typeof id_wordList_wordinfo_column.headWordInfoObjCur.voice == "string") {
                            return '/' + id_wordList_wordinfo_column.headWordInfoObjCur.voice + '/'
                        }
                        return ""
                    }
                    visible: text.length > 0
                }

                YTextMedium {
                    id: id_head_word_text
                    font.family: fontManager.fontFamilyKoKr
                    font.pixelSize: 30
                    textFormat: YTextMedium.RichText
                    color: "#FFFFFF"
                    width: parent.width
                    height: contentHeight
                    text: visible ? headWordCur : ""
                    visible: typeof headWordCur != "undefined" && headWordCur.length > 0
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


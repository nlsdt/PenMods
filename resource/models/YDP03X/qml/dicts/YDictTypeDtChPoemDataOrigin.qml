import QtQuick 2.12
import com.youdao.pen 1.0

import BaseQml 1.0
import "../commons"
import "../i18n"
import "../components"

Item {
    id: id_poem_dict_data_column
    height: id_poem_dict_data_column_inner.height

    property var originAll: ""

    property var jsonPoemData: {
        return dictJson
    }
    property bool bHasAllPhone: dictJson.bHasAllPhone
    property int nCurExplanationIdx: 0

    onJsonPoemDataChanged: {
        originAll = ""
        nCurExplanationIdx = 0
        bHasAllPhone = dictJson.bHasAllPhone
    }

    function formatPoemSentence(qsExplanationFormat, qsPhoneFormat, qslPhone)
    {
        let qsFormatResult = qsExplanationFormat;
        qsFormatResult = qsFormatResult.replace(/mark/g, "u");
        var nExplanationPos = 0;
        var nLastPos = 0;
        while ((nExplanationPos = qsFormatResult.indexOf("</u>", nLastPos)) !== -1)
        {
            id_poem_dict_data_column.nCurExplanationIdx++;
            qsFormatResult = qsFormatResult.slice(0, nExplanationPos + 4)
                             + ("<font style='color:%1;'>[").arg(YColors.grayText) + id_poem_dict_data_column.nCurExplanationIdx + "]</font>"
                             + qsFormatResult.slice(nExplanationPos + 4);
            nLastPos = nExplanationPos + 4;
        }
        //一句诗词只有部分拼音时，拼音嵌插在诗词中
        if (!id_poem_dict_data_column.bHasAllPhone && qslPhone.length > 0)
        {
            var nPinyinIndex = 0;
            var nPinyinPos = 0;
            nExplanationPos = 0;
            while (nPinyinPos < qsPhoneFormat.length)
            {
                if (nPinyinIndex >= qslPhone.length) // 防止数组越界
                {
                    break;
                }
                if (YEnum.CT_CJK === qmlGlobal.getCharType(qsPhoneFormat[nPinyinPos]))
                {
                    while (nExplanationPos < qsFormatResult.length && qsPhoneFormat[nPinyinPos] !== qsFormatResult[nExplanationPos])
                    {
                        nExplanationPos++;
                    }
                    nExplanationPos++;
                    if (qsPhoneFormat.substr(nPinyinPos + 1, 7) === "</mark>")
                    {
                        if (qsFormatResult.substr(nExplanationPos, 4) === "</u>")
                        {
                            nExplanationPos += 4;
                        }
                        qsFormatResult = qsFormatResult.slice(0, nExplanationPos)
                                         + ("<font style='color:%1;'>（").arg(YColors.grayText) + qslPhone[nPinyinIndex++] + "）</font>"
                                         + qsFormatResult.slice(nExplanationPos);
                    }
                }
                nPinyinPos++;
            }
        }
        return qsFormatResult;
    }


    Column {
        id: id_poem_dict_data_column_inner
        spacing: 20
        anchors.left: parent.left
        anchors.right: parent.right

        Column {
            id: id_detail_content_col
            anchors.left: parent.left
            anchors.right: parent.right
            property bool watchOriginVisible: false

            Row {
                id: id_icon_row
                spacing: 12
                height: 52

//                YAudioPlayIconLabelButton {
//                    id: id_sound_org
//                    textFontFamily: fontManager.fontFamily
//                    textFormat: YText.PlainText
//                    text: YTranslateText.original
//                    visible: !id_poem_audiourl_button.visible
//                    onValidClicked: {
//                        if (playing) {
//                            qmlGlobal.audioPlayId = soundCenter.play(originAll,
//                                                                     "zh")
//                        }
//                    }
//                }

                YIconLabelButton {
                    id: id_poem_audiourl_button
                    implicitHeight: 52
                    leftMargin: 20
                    rightMargin: 20
                    spacing: 12
                    textColor: YColors.grayText
                    sourceSize: Qt.size(32, 32)
                    icon: "audioplayer/audioplayer-play-red"
                    text: YTranslateText.chPoemReading
                    visible: jsonPoemData !== null && typeof jsonPoemData.audio != "undefined" && jsonPoemData.audio.length > 0
                    mouseAreaMargins: -5
                    property double audioPlayId: 0

                    onTextChanged: {
                        if (text === YTranslateText.chPoemReading)
                            qmlGlobal.isPoemReading = false
                        else if (text === YTranslateText.stopReading) {
                            qmlGlobal.isPoemReading = true
                        }
                    }

                    onVisibleChanged: {
                        if (!visible) {
                            id_poem_audiourl_button.icon = "audioplayer/audioplayer-play-red"
                            id_poem_audiourl_button.text = YTranslateText.chPoemReading
                        }
                    }

                    onValidClicked: {
                        if (id_poem_audiourl_button.icon.indexOf("pause") < 0)
                        {
                            id_poem_audiourl_button.icon = "audioplayer/audioplayer-pause-red"
                            id_poem_audiourl_button.text = YTranslateText.stopReading
                            id_poem_audiourl_button.audioPlayId = 0
                            let playRst = resultManager.playPoemAudioFile(jsonPoemData.audio, jsonPoemData.id)
                            if (playRst !== 0) {
                                console.log("YDictTypeDtChPoemData.qml === id_poem_audiourl_button.onValidClicked in if playRst !== 0")
                                id_poem_audiourl_button.icon = "audioplayer/audioplayer-play-red"
                                id_poem_audiourl_button.text = YTranslateText.chPoemReading
                                if (playRst === 1) {
                                    baseSignals.showToast(YTranslateText.downloadingSource, "#E9900C")
                                } else if (playRst === 2) {
                                    baseSignals.showToast(YTranslateText.noNetworkTip, YColors.grayText)
                                }
                            }
                        }
                        else
                        {
                            soundCenter.stop()
                            id_poem_audiourl_button.icon = "audioplayer/audioplayer-play-red"
                            id_poem_audiourl_button.text = YTranslateText.chPoemReading
                        }
                    }

                    Connections {
                        target: qmlGlobal
                        ignoreUnknownSignals: true
                        enabled: id_poem_audiourl_button.visible
                        function onAudioPlayIdChanged() {
                            if (id_poem_audiourl_button.icon.indexOf("pause") >= 0) {
                                id_poem_audiourl_button.audioPlayId = qmlGlobal.audioPlayId
                            }
                        }
                    }

                    Connections {
                        target: soundCenter
                        ignoreUnknownSignals: true
                        enabled: id_poem_audiourl_button.visible
                        function onEnd(seq) {
                            if ((id_poem_audiourl_button.icon.indexOf("pause") >= 0)
                                    && (seq == id_poem_audiourl_button.audioPlayId)) {
                                id_poem_audiourl_button.icon = "audioplayer/audioplayer-play-red"
                                id_poem_audiourl_button.text = YTranslateText.chPoemReading
                            }
                        }
                    }
                }

                YIconLabelButton {
                    id: id_poem_explain_button
                    implicitHeight: 52
                    leftMargin: 20
                    rightMargin: 20
                    spacing: 12
                    textColor: YColors.grayText
                    sourceSize: Qt.size(32, 32)
                    icon: "audioplayer/audioplayer-explain"
                    text: YTranslateText.chPoemExplain
                    visible: jsonPoemData !== null && typeof jsonPoemData.poem_explanation != "undefined" && jsonPoemData.poem_explanation.length > 0
                    mouseAreaMargins: -5
                    property double audioPlayId: 0

                    onVisibleChanged: {
                        if (!visible) {
                            id_poem_explain_button.text = YTranslateText.chPoemExplain
                        }
                    }

                    onTextChanged: {
                        if (text === YTranslateText.chPoemExplain)
                            qmlGlobal.isPoemReading = false
                        else if (text === YTranslateText.stopExplain) {
                            qmlGlobal.isPoemReading = true
                        }
                    }

                    onValidClicked: {
                        if(id_poem_explain_button.text == YTranslateText.stopExplain)
                        {
                            id_poem_explain_button.text = YTranslateText.chPoemExplain
                            soundCenter.stop()
                        }
                        else
                        {
                            id_poem_explain_button.text = YTranslateText.stopExplain
                            id_poem_explain_button.audioPlayId = 0
                            logManager.sendHttpLog("action=detail_poem_analysis&URL="+jsonPoemData.poem_explanation)
                            let playRst = resultManager.playPoemExplanationFile(jsonPoemData.poem_explanation, jsonPoemData.id)
                            if (playRst !== 0) {
                                console.log("YDictTypeDtChPoemData.qml === id_poem_audiourl_button.onValidClicked in if playRst !== 0")
                                id_poem_explain_button.text = YTranslateText.chPoemExplain
                                if (playRst === 1) {
                                    baseSignals.showToast(YTranslateText.downloadingSource, "#E9900C")
                                } else if (playRst === 2) {
                                    baseSignals.showToast(YTranslateText.noNetworkTip, YColors.grayText)
                                }
                            }
                        }
                    }

                    Connections {
                        target: qmlGlobal
                        ignoreUnknownSignals: true
                        enabled: id_poem_audiourl_button.visible
                        function onAudioPlayIdChanged() {
                            if (id_poem_explain_button.text == YTranslateText.stopExplain) {
                                id_poem_explain_button.audioPlayId = qmlGlobal.audioPlayId
                            }
                        }
                    }

                    Connections {
                        target: soundCenter
                        ignoreUnknownSignals: true
                        enabled: id_poem_audiourl_button.visible
                        function onEnd(seq) {
                            if ((id_poem_explain_button.text == YTranslateText.stopExplain)
                                    && (seq === id_poem_explain_button.audioPlayId)) {
                                id_poem_explain_button.text = YTranslateText.chPoemExplain
                            }
                        }
                    }
                }

                YIconLabelButton {
                    id: id_poem_kaiShuReading_button
                    implicitHeight: 52
                    leftMargin: 20
                    rightMargin: 20
                    spacing: 12
                    textColor: YColors.grayText
                    sourceSize: Qt.size(32, 32)
                    icon: "audioplayer/kaishu"
                    text: YTranslateText.kaiShuReading
                    visible: jsonPoemData !== null && typeof jsonPoemData.uncleKaiAudio != "undefined" && jsonPoemData.uncleKaiAudio.length > 0
                    mouseAreaMargins: -5
                    property double audioPlayId: 0
                    property bool isRun: false

                    onVisibleChanged: {
                        if (!visible) {
                            id_poem_kaiShuReading_button.text = YTranslateText.kaiShuReading
                        }
                    }

                    onTextChanged: {
                        if (id_poem_kaiShuReading_button.text == YTranslateText.kaiShuReading)
                            qmlGlobal.isPoemReading = false
                        else if (id_poem_kaiShuReading_button.text == YTranslateText.kaiShuCurrentReading) {
                            qmlGlobal.isPoemReading = true
                        }
                    }

                    onValidClicked: {
                        //                if(id_poem_explain_button.text == YTranslateText.stopExplain)
                        //                {
                        //                    id_poem_explain_button.text = YTranslateText.chPoemExplain
                        //                    soundCenter.stop()
                        //                }
                        //                else
                         if(id_poem_kaiShuReading_button.text == YTranslateText.kaiShuCurrentReading) {
                            soundCenter.stop()
                            isRun = false
                             id_poem_kaiShuReading_button.text == YTranslateText.kaiShuReading
                        } else {
                            id_poem_kaiShuReading_button.text = YTranslateText.kaiShuCurrentReading
                            id_poem_kaiShuReading_button.audioPlayId = 0
                            //logManager.sendHttpLog("action=detail_poem_analysis&URL="+jsonPoemData.poem_explanation)
                            let playRst = resultManager.playPoemUncleKaiFile(jsonPoemData.uncleKaiAudio, jsonPoemData.id)
                            if (playRst !== 0) {
                                console.log("YDictTypeDtChPoemData.qml === playPoemUncleKaiFile.onValidClicked in if playRst !== 0")
                                id_poem_kaiShuReading_button.text = YTranslateText.kaiShuReading
                                isRun = false
                                if (playRst === 1) {
                                    baseSignals.showToast(YTranslateText.downloadingSource, "#E9900C")
                                } else if (playRst === 2) {
                                    baseSignals.showToast(YTranslateText.noNetworkTip, YColors.grayText)
                                }
                            } else {
                                qmlGlobal.isPoemReading = true
                                isRun = true
                            }
                        }
                    }

                    Connections {
                        target: qmlGlobal
                        ignoreUnknownSignals: true
                        //enabled: id_poem_kaiShuReading_button.visible
                        function onAudioPlayIdChanged() {
                            if (id_poem_kaiShuReading_button.text == YTranslateText.kaiShuCurrentReading) {
                                id_poem_kaiShuReading_button.audioPlayId = qmlGlobal.audioPlayId
                            }
                        }
                    }

                    Connections {
                        target: soundCenter
                        ignoreUnknownSignals: true
                        //enabled: id_poem_kaiShuReading_button.visible
                        function onEnd(seq) {
                            if ((id_poem_kaiShuReading_button.text == YTranslateText.kaiShuCurrentReading)
                                    && (seq === id_poem_kaiShuReading_button.audioPlayId)) {
                                id_poem_kaiShuReading_button.isRun = false
                                id_poem_kaiShuReading_button.text = YTranslateText.kaiShuReading
                                qmlGlobal.isPoemReading = false
                            }
                        }
                    }
                }
            }

            YSpacingForColumn {
                implicitHeight: 16
                visible: id_poem_title_dynasty.visible
            }

            YText {
                id: id_poem_title_dynasty
                width: parent.width
                height: paintedHeight
                wrapMode: YText.Wrap
                textFormat: YTextBase.RichText
                font.family: fontManager.fontFamilyZhCn
                font.pixelSize: 28
                text: {
                    if (jsonPoemData === null) return ""
                    let qsDynasty = ""
                    let qsAuthor = ""
                    if ((typeof jsonPoemData.dynasty != "undefined") && jsonPoemData.dynasty.length > 0) qsDynasty = ("<font color=\"%2\">[%1]</font>").arg(jsonPoemData.dynasty).arg(YColors.grayText)
                    if ((typeof jsonPoemData.author != "undefined") && jsonPoemData.author.length > 0)  qsAuthor = jsonPoemData.author
                    return qsDynasty + ((qsDynasty.length > 0 && qsAuthor.length > 0) ? " " : "") + qsAuthor
                }
                visible: text.length > 0
            } // Text id_poem_title_dynasty

            YSpacingForColumn {
                implicitHeight: 16
                visible: id_poem_title_dynasty.visible
            }

            Repeater {
                id: id_detail_content_repeater
                model: {
                    return typeof jsonPoemData.originContent === "undefined" ? null : jsonPoemData.originContent
                }
                property var totalHeight: 0
                property var curHeight: 0
                YTextMedium {
                            width: id_poem_dict_data_column.width
                            height: paintedHeight
                            font.family: fontManager.fontFamilyZhCn
                            font.pixelSize: 28
                            color: "#FFFFFF"
                            wrapMode: YTextBase.Wrap
                            textFormat: YTextBase.RichText
                            visible: text.length
                            Component.onCompleted: {
                                let qsFormattedSentence = ""
                                let qslFinalPhone = []
                                model.modelData.sentences.forEach(function(sentencesObject){
                                    originAll += sentencesObject.origin
                                    let qsFormatted = sentencesObject.formatted
                                    let qsPinyinFormatted = ""
                                    if (typeof sentencesObject.pinyinFormatted != "undefined") {
                                        qsPinyinFormatted = sentencesObject.pinyinFormatted
                                    }
                                    var qslPhone = []
                                    if (typeof sentencesObject.pinyin != "undefined") {
                                        sentencesObject.pinyin.forEach(function(pinyinPair){
                                            let qslPhoneCur = []
                                            pinyinPair.pinyin.forEach(function(qsPinyin){
                                                qslPhoneCur.push(qsPinyin)
                                            })
                                            qslPhone.push(qslPhoneCur.join(','))
                                        })
                                    }
                                    if (id_poem_dict_data_column.bHasAllPhone) {
                                        qslFinalPhone.push(qslPhone.join('&nbsp;'))
                                    }
                                    qsFormattedSentence += formatPoemSentence(qsFormatted, qsPinyinFormatted, qslPhone)
                                })
                                if (id_poem_dict_data_column.bHasAllPhone) {
                                    text = ('<span style="color:%1;">').arg(YColors.grayText) + qslFinalPhone.join('&nbsp;') + '</span><br/>' + qsFormattedSentence
                                } else {
                                    text = qsFormattedSentence
                                }
                            }
                        }
            } // Repeater id_detail_content_repeater
    }
}

}


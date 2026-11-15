import QtQuick 2.12
import com.youdao.pen 1.0

import BaseQml 1.0
import "../i18n"

Item {
    id: id_poem_dict_data_column
    height: id_poem_dict_data_column_inner.height

    property var jsonPoemData: null
    property bool bSimpleShow: false
    property bool bHasAllPhone: false
    property var authorIntro: ""
    property int nCurExplanationIdx: 0

    onJsonPoemDataChanged: {
        if (jsonPoemData) {
            bHasAllPhone = jsonPoemData.pinyinAll
            if (typeof jsonPoemData.audio != "undefined" && jsonPoemData.audio.length > 0) {
                resultManager.downloadPoemAudioFile(jsonPoemData.audio, jsonPoemData.id)
            }
            if (typeof jsonPoemData.poem_explanation != "undefined" && jsonPoemData.poem_explanation.length > 0) {
                resultManager.downloadPoemExplanationFile(jsonPoemData.poem_explanation, jsonPoemData.id)
            }
            if (typeof jsonPoemData.uncleKaiAudio != "undefined" && jsonPoemData.uncleKaiAudio.length > 0) {
                qmlGlobal.isPoemReading = false
                resultManager.downloadPoemUncleKaiFile(jsonPoemData.uncleKaiAudio, jsonPoemData.id)
            }
        }
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
        spacing: 16
        anchors.left: parent.left
        anchors.right: parent.right

        YTextBase {
            id: id_poem_title_origin
            width: parent.width
            height: paintedHeight
            font.family: fontManager.fontFamilyZhCn
            font.pixelSize: 28
            font.weight: Font.Medium
            textFormat: YTextBase.RichText
            wrapMode: YTextBase.Wrap
            color: "#FFFFFF"
            text: visible ? jsonPoemData.detail.title.origin : ""
            visible: jsonPoemData !== null
        } // Text id_poem_title_origin

        YTextBase {
            id: id_poem_title_dynasty
            width: parent.width
            height: paintedHeight
            font.family: fontManager.fontFamilyZhCn
            font.pixelSize: 26
            color: YColors.grayText
            wrapMode: YTextBase.Wrap
            text: {
                if (!visible) return ""
                let qsDynasty = ""
                let qsAuthor = ""
                if (typeof jsonPoemData.dynasty != "undefined") qsDynasty = jsonPoemData.dynasty
                if (typeof jsonPoemData.author != "undefined")  qsAuthor = jsonPoemData.author
                return qsDynasty + ((qsDynasty.length > 0 && qsAuthor.length > 0) ? " " : "") + qsAuthor
            }
            visible: jsonPoemData !== null
        } // Text id_poem_title_dynasty

        Repeater {
            id: id_detail_content_repeater
            model: jsonPoemData === null ? null : jsonPoemData.detail.content
            YTextMedium {
                width: id_poem_dict_data_column.width
                height: paintedHeight
                font.family: fontManager.fontFamilyZhCn
                font.pixelSize: 28
                color: "#FFFFFF"
                wrapMode: YTextBase.Wrap
                textFormat: YTextBase.RichText
                Component.onCompleted: {
                    let qsFormattedSentence = ""
                    let qslFinalPhone = []
                    model.modelData.sentences.forEach(function(sentencesObject){
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


        Row {
            id: id_icon_row
            spacing: 12
            height: 52

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


        YTextBase {
            id: id_detail_translate_text
            font.pixelSize: 26
            font.family: fontManager.fontFamily
            font.weight: Font.Normal
            color: YColors.red
            width: parent.width
            height: contentHeight + 16
            text: YTranslateText.translate
            visible: id_detail_translate_repeater.hideArray.indexOf(1) !== -1
            topPadding: 16
        }

        Repeater {
            id: id_detail_translate_repeater
            model: {
                id_detail_translate_repeater.hideArray = []
                return jsonPoemData === null ? null : jsonPoemData.detail.content
            }
            property var hideArray: []
            onHideArrayChanged: {
                id_detail_translate_text.visible = Qt.binding(function() { return id_detail_translate_repeater.hideArray.indexOf(1) !== -1})
            }

            Column {
                id: id_detail_translate_column
                width: id_poem_dict_data_column.width
                spacing: 10
                readonly property var modelModelData: model.modelData
                property var curIndex: index

                YText {
                    width: parent.width
                    height: paintedHeight
                    font.family: fontManager.fontFamilyZhCn
                    color: YColors.grayText
                    wrapMode: YTextBase.Wrap
                    text: {
                        let qsOriginSentence = ""
                        id_detail_translate_column.modelModelData.sentences.forEach(function(sentencesObject){
                            qsOriginSentence += sentencesObject.origin
                        })
                        return qsOriginSentence
                    }
                    visible: id_poem_translate_text.visible
                }

                YTextMedium {
                    id: id_poem_translate_text
                    width: parent.width
                    height: paintedHeight
                    font.family: fontManager.fontFamilyZhCn
                    font.pixelSize: 28
                    color: "#FFFFFF"
                    wrapMode: YTextBase.Wrap
                    text: {
                        let qslTranslate = ""
                        id_detail_translate_column.modelModelData.sentences.forEach(function(sentencesObject){
                            qslTranslate += typeof sentencesObject.translate !== "undefined" ? sentencesObject.translate : ''
                        })
                        return qslTranslate
                    }
                    onTextChanged: {
                        id_detail_translate_repeater.hideArray[id_detail_translate_column.curIndex] = text.length ? 1 : 0
                        let temp = id_detail_translate_repeater.hideArray
                        id_detail_translate_repeater.hideArray = []
                        id_detail_translate_repeater.hideArray = temp
                    }
                    visible: text.length > 0
                }

            } // Column id_detail_translate_column

        } // Repeater id_detail_translate_repeater

        YTextBase {
            id: id_detail_explanation_text
            font.pixelSize: 26
            font.family: fontManager.fontFamily
            font.weight: Font.Normal
            color: YColors.red
            width: parent.width
            height: contentHeight + 16
            text: YTranslateText.annotation
            topPadding: 16
            visible: iExplanationIndex > 0

            property var iExplanationIndex: 0
        }

        Repeater {
            id: id_detail_explanation_repeater
            model: {
                if (!bSimpleShow && jsonPoemData !== null
                    && typeof jsonPoemData.detail != "undefined"
                    && typeof jsonPoemData.detail.content != "undefined"
                    && jsonPoemData.detail.content.length > 0) {
                    return jsonPoemData.detail.content
                }
                return []
            }

            Column {
                id: id_detail_explanation_column
                width: id_poem_dict_data_column.width
                spacing: 10
                readonly property var modelModelData: model.modelData

                Repeater {
                    id: id_detail_explanation_sentence_repeater
                    model: id_detail_explanation_column.modelModelData.sentences

                    Column {
                        id: id_detail_explanation_sentence_column
                        width: id_poem_dict_data_column.width
                        spacing: 10
                        readonly property var modelModelData: model.modelData

                        Repeater {
                            id: id_detail_explanation_sentence_explanation_repeater
                            model: id_detail_explanation_sentence_column.modelModelData.explanations

                            YTextMedium {
                                width: id_poem_dict_data_column.width
                                font.family: fontManager.fontFamilyZhCn
                                wrapMode: YTextBase.Wrap
                                textFormat: YTextBase.RichText
                                Component.onCompleted: {
                                    id_detail_explanation_text.iExplanationIndex += 1
                                    text = ('<span style="color:%1;">[').arg(YColors.grayText) + id_detail_explanation_text.iExplanationIndex + ']</span>'
                                           + qmlGlobal.getChinese(model.modelData.word) + ':&nbsp;' + qmlGlobal.getChinese(model.modelData.meaning)
                                }
                            }

                        } // Repeater id_detail_explanation_sentence_explanation_repeater

                    } // Column id_detail_explanation_sentence_column

                } // Repeater id_detail_explanation_sentence_repeater

            } // Column id_detail_translate_column

        } // Repeater id_detail_explanation_repeater

        YTextBase {
            id: id_detail_analysis_text
            font.pixelSize: 26
            font.family: fontManager.fontFamily
            font.weight: Font.Normal
            color: YColors.red
            width: parent.width
            height: contentHeight + 16
            text: YTranslateText.appreciation
            topPadding: 16
            visible: !bSimpleShow && jsonPoemData !== null && typeof jsonPoemData.detail.analysis != "undefined"
        }

        Repeater {
            id: id_detail_analysis_repeater
            model: id_detail_analysis_text.visible ? jsonPoemData.detail.analysis : null

            Column {
                id: id_detail_analysis_column
                width: id_poem_dict_data_column.width
                spacing: 16
                readonly property var modelModelData: model.modelData

                YTextMedium {
                    width: parent.width
                    height: paintedHeight
                    font.family: fontManager.fontFamilyZhCn
                    font.pixelSize: 28
                    color: "#FFFFFF"
                    wrapMode: YTextBase.Wrap
                    text: id_detail_analysis_column.modelModelData
                }

            } // Column id_detail_analysis_column

        } // Repeater id_detail_analysis_repeater

        YTextBase {
            id: id_detail_author_text
            font.pixelSize: 26
            font.family: fontManager.fontFamily
            font.weight: Font.Normal
            color: YColors.red
            width: parent.width
            height: contentHeight + 16
            text: YTranslateText.aboutTheAuthor
            topPadding: 16
            visible: !bSimpleShow && id_poem_dict_data_column.authorIntro.length > 0
        }

        YTextMedium {
            width: parent.width
            height: paintedHeight
            font.family: fontManager.fontFamilyZhCn
            font.pixelSize: 28
            color: "#FFFFFF"
            wrapMode: YTextBase.Wrap
            text: id_poem_dict_data_column.authorIntro
            visible: id_detail_author_text.visible
        }
    }
}




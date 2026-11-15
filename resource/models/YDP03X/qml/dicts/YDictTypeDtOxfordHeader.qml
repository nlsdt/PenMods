import QtQuick 2.12

import BaseQml 1.0
import "./YDictOxfordUtilities.js" as OxfordUtilities
import "./YDictOxfordModel.js" as OxfordModel

Column {
    id: id_word_header_text_column
    width: parent.width
    spacing: 10
    property var oxfordModel: OxfordModel.createOxfordModel()
    property var wordText: ""
    property var wordListCount: 0
    property var currentMeanIdx: 0
    property var meanIndex: wordListCount > 1 ? currentMeanIdx : 0
    property var posList: []
    property var posListCur: posList.length > 0 ? (wordListCount > 1 ? posList[meanIndex] : [posList[meanIndex][currentMeanIdx]]) : []
    property var isDetailePage: false

    onOxfordModelChanged: {
        wordText = oxfordModel.wordText
        wordListCount = oxfordModel.wordListCount
        posList = oxfordModel.posList
    }

    readonly property var meanData: {
        if (isDetailePage) {
            return null
        }
        var vMean = null
        var qslPos = posList[meanIndex]
        if (wordListCount > 1) {
            qslPos.forEach (function (qsPos) {
                let meanList = oxfordModel.vMeanList[meanIndex][qsPos]
                if (typeof meanList != "undefined" && meanList.length > 0) {
                    vMean = meanList[0];
                }
            })
        } else {
            let meanList = oxfordModel.vMeanList[meanIndex][qslPos[currentMeanIdx]];
            if (meanList.length > 0) {
                vMean = meanList[0];
            }
        }
        if (vMean !== null && typeof vMean.sd == "undefined" && typeof vMean["n-g"] == "undefined") {
            vMean = null
        }
        return vMean
    }
    readonly property var qsMeanShowPos: {
        var qsShowPos = ""
        if (wordListCount > 1) {
            posList[meanIndex].forEach (function (qsPos) {
                let meanList = oxfordModel.vMeanList[meanIndex][qsPos]
                if (typeof meanList != "undefined" && meanList.length > 0) {
                    qsShowPos = qsPos;
                }
            })
        }
        return qsShowPos
    }

    YTextMedium {
        id: id_word_header_text
        font.family: fontManager.fontFamilyEnUs
        font.pixelSize: 28
        textFormat: YTextBase.RichText
        wrapMode: YTextBase.WordWrap
        width: parent.width
        color: "#FFFFFF"
        text: {
            let qsRst = ""
            let qsWordHead = oxfordModel.qsWordHeadList[meanIndex]
            let qsPosRst = ""
            if (qsWordHead === "Con·gress·man, Con·gress·woman") {
                qsRst += 'Con·gress·man,&nbsp;' + OxfordUtilities.formatText(" /ˈkɒŋɡresmən/ <i>NAmE</i> /ˈkɑːŋɡrəs‑/", YColors.grayText, 400) + '&nbsp;&nbsp;'
                qsRst += 'Con·gress·woman,&nbsp;' + OxfordUtilities.formatText(" /ˈkɒŋɡreswʊmən/ <i>NAmE</i> /ˈkɑːŋɡrəs‑/", YColors.grayText, 400)
            } else {
                qsRst = '<span style="color: #FFFFFF; font-weight: 500">' + qsWordHead + '</span>'
            }

            if (oxfordModel.bCoreWordList[meanIndex]) {
                qsRst += '&nbsp;<img src="image://icons/dict/oxford-key.png"/>'
            }

            let qslPos = posList[meanIndex]
            if (wordListCount > 1 || qslPos.length === 1) {
                if (qslPos.length > 0) {
                    if (qslPos.length === 1) {
                        qsPosRst += OxfordUtilities.formatText(qslPos[0], YColors.grayText, 400, 28, fontManager.fontFamilyClass) + " "
                    }
                    //xml转json后"bandito", amphora, chef-d'oeuvre的数据格式与展示要求差距甚大，无法统一处理，特殊处理一下
                    if (wordText === "bandito") {
                        qsPosRst += OxfordUtilities.htmlToFormatted("/bænˈdiːtəʊ/  <i>NAmE</i> /‑toʊ/ (also <b>ban·dido</b>) /‑dəʊ/ <i>NAmE</i> /‑doʊ/")
                    } else if (wordText === "amphora") {
                        qsPosRst += OxfordUtilities.htmlToFormatted("/ˈæmfərə/ <i>NAmE</i> also /æmˈfɔːrə/")
                    } else if (wordText === "chef-d'oeuvre") {
                        qsPosRst += OxfordUtilities.htmlToFormatted("/ˌʃeɪ ˈdɜːvrə/ <i>NAmE</i> also /ˈduːvrə/")
                    } else {
                        qsPosRst += OxfordUtilities.phoneticToFormattedText(oxfordModel.vPhoneticList[meanIndex][qslPos[0]], qslPos[0]);
                    }
                    if (wordListCount > 1 && qslPos.length > 1) {
                        let qsPosTmp = ""
                        oxfordModel.headPosList[meanIndex].forEach(function(vp){
                            if (qsPosTmp.length > 0) {
                                qsPosTmp += ", "
                            }
                            qsPosTmp += vp.p
                        })
                        qsPosRst += " " + qsPosTmp
                    }
                }
            } else {
                qsPosRst += OxfordUtilities.phoneticToFormattedText(oxfordModel.vPhoneticList[meanIndex][qslPos[currentMeanIdx]], qslPos[currentMeanIdx]);
            }
            if (qsPosRst.length > 0) {
                qsPosRst = OxfordUtilities.formatText(qsPosRst, YColors.grayText, 400)
                if (qsRst.length > 0) {
                    qsRst += "&nbsp;"
                }
                qsRst += qsPosRst
            }
            return qsRst
        }
    }

    YText {
        id: id_word_header_end_text
        font.family: fontManager.fontFamilyEnUs
        color: YColors.grayText
        textFormat: YTextBase.RichText
        wrapMode: YTextBase.WordWrap
        width: parent.width
        text: {
            if (oxfordModel.qsHeadEnd.length > 0 && oxfordModel.qsHeadEnd[meanIndex].length > 0) {
                return ('(BrE also <span style="font-weight: 500">' + oxfordModel.qsHeadEnd[currentMeanIdx] + '</span>)')
            }
            return ""
        }
        visible: text.length > 0
    }

    YText {
        id: id_word_header_global_info_text
        font.family: fontManager.fontFamilyEnUs
        font.pixelSize: 26
        color: YColors.grayText
        textFormat: YTextBase.RichText
        wrapMode: YTextBase.WordWrap
        width: parent.width
        text: {
            var vFormattedText = ""
            var qslPos = posList[meanIndex]
            if (wordListCount > 1) {
                if (oxfordModel.vGlobalPtList.length > 0) {
                    qslPos.forEach(function(qsPos){
                        vFormattedText += OxfordUtilities.ptToFormatted(oxfordModel.vGlobalPtList[meanIndex][qsPos])
                    })
                }
                if (qslPos.length === 1 && oxfordModel.vGlobalA.length > 0) {
                    vFormattedText += OxfordUtilities.aToFormatted(oxfordModel.vGlobalA[meanIndex][qslPos[0]], false)
                }
                if (oxfordModel.vGlobalVsgList.length > 0) {
                    qslPos.forEach(function(qsPos){
                        vFormattedText += OxfordUtilities.vsgToFormatted(oxfordModel.vGlobalVsgList[meanIndex][qsPos], true)
                    })
                }
                if (oxfordModel.vGlobalCf.length > 0) {
                    vFormattedText += OxfordUtilities.ccCfToFormatted(oxfordModel.vGlobalCf[meanIndex][qslPos[0]], " | ")
                }
                if (oxfordModel.vGlobalGrList.length > 0) {
                    qslPos.forEach(function(qsPos) {
                        vFormattedText += OxfordUtilities.grToFormatted(oxfordModel.vGlobalGrList[meanIndex][qsPos])
                    })
                }
                //多组释义时只显示全局的不规则形式，词性相关的不规则形式显示在释义列表的词性后面
                if (qslPos.length === 1 && oxfordModel.vGlobalIrrList.length > 0) {
                    vFormattedText += OxfordUtilities.irregularToFormattedText(oxfordModel.vGlobalIrrList[meanIndex])
                }
            } else {
                var qsPos = qslPos[currentMeanIdx]
                if (oxfordModel.vGlobalPtList.length > 0) {
                    vFormattedText += OxfordUtilities.ptToFormatted(oxfordModel.vGlobalPtList[0][qsPos])
                }
                if (oxfordModel.vGlobalA.length > 0) {
                    vFormattedText += OxfordUtilities.aToFormatted(oxfordModel.vGlobalA[0][qsPos], false)
                }
                if (oxfordModel.vGlobalMixStr.length > 0
                    && typeof oxfordModel.vGlobalMixStr[0][qsPos] != "undefined"
                    && oxfordModel.vGlobalMixStr[0][qsPos].length > 0) {
                    vFormattedText += htmlToFormatted(oxfordModel.vGlobalMixStr[0][qsPos])
                }
                //特殊处理"half note", "half step", "coitus
                if (wordText === "half note" || wordText === "half step") {
                    vFormattedText += OxfordUtilities.formatText("(<i>NAmE</i>, <b><i>music</i> 音</b>)", YColors.grayText, 400, 26)
                }
                if (wordText === "coitus") {
                    vFormattedText += OxfordUtilities.formatText("[U](<i>medical</i> 医 or <i>formal</i>)", YColors.grayText, 400, 26)
                }
                if (wordText !== "half note" && wordText !== "half step" && wordText !== "coitus") {
                    if (oxfordModel.vGlobalS.length > 0
                        && typeof oxfordModel.vGlobalS[0][qsPos] != "undefined"
                        && typeof oxfordModel.vGlobalS[0][qsPos].s == "string"
                        && oxfordModel.vGlobalS[0][qsPos].s.length > 0) {
                        vFormattedText += '(' + oxfordModel.vGlobalS[0][qsPos].s + ')'
                    }
                }
                if (oxfordModel.vGlobalAbbr.length > 0
                    && typeof oxfordModel.vGlobalAbbr[0][qsPos] == "string"
                    && oxfordModel.vGlobalAbbr[0][qsPos].length > 0) {
                    vFormattedText += OxfordUtilities.htmlToFormatted("(<i>abbr.</i> <b>" + oxfordModel.vGlobalAbbr[0][qsPos] + "</b>)")
                }
                vFormattedText += OxfordUtilities.uToFormattedText(oxfordModel.vGlobalU[0][qsPos], fontManager.fontFamilyZhCn)
                //bandito的vs-g已经在显示音标时特殊处理过了，这里直接忽略
                if (wordText !== "bandito" && oxfordModel.vGlobalVsgList.length > 0) {
                    vFormattedText += OxfordUtilities.vsgToFormatted(oxfordModel.vGlobalVsgList[0][qsPos], true)
                }
                if (oxfordModel.vGlobalCf.length > 0) {
                    vFormattedText += OxfordUtilities.ccCfToFormatted(oxfordModel.vGlobalCf[0][qsPos], " | ")
                }
                if (wordText !== "half note" && wordText !== "half step" && wordText !== "coitus"
                    && oxfordModel.vGlobalGrList.length > 0) {
                    //xml转json后丢失了标签的顺序，mano-a-mano特殊处理
                    vFormattedText += OxfordUtilities.grToFormatted(oxfordModel.vGlobalGrList[0][qsPos], true, wordText !== "mano-a-mano")
                }
                //部分单词特殊处理
                var prData = OxfordUtilities.s_specialIrregular[wordText]
                var bSpecialProcessed = false
                //prData第一个成员是词性，若不为空则仅对这个词性特殊处理，否则对所有词性特殊处理
                if (typeof prData != "undefined" && prData.length >= 2 && prData[1].length > 0 && (prData[0].length <= 0 || prData[0] === qsPos)) {
                    vFormattedText += OxfordUtilities.htmlToFormatted(prData[1])
                    bSpecialProcessed = true
                } else if (oxfordModel.vGlobalIrrList.length > 0) {
                    vFormattedText += OxfordUtilities.irregularToFormattedText(oxfordModel.vGlobalIrrList[0])
                }
                if (!bSpecialProcessed && oxfordModel.vIrregularList.length > 0) {
                    vFormattedText += OxfordUtilities.irregularToFormattedText(oxfordModel.vIrregularList[0][qsPos])
                }
            }
            return vFormattedText
        }
        visible: text.length > 0
    }

    Repeater {
        id: id_word_header_Xr_repeater
        model: posListCur

        YLoader {
            id: id_word_header_Xr_loader
            asynchronous: false
            readonly property int componentWidth: id_word_header_text_column.width
            readonly property var qsPosCur: model.modelData
            readonly property var xrObj: {
                if (oxfordModel.vGlobalXr.length > 0) {
                    if (typeof oxfordModel.vGlobalXr[meanIndex][qsPosCur] == "object") {
                        return oxfordModel.vGlobalXr[meanIndex][qsPosCur]
                    }
                }
                return null
            }
            active: xrObj !== null
            sourceComponent: YDictTypeDtOxfordXr{}
        }
    }

    Repeater {
        id: id_word_header_help_repeater
        model: {
            return posListCur
        }

        Column {
            width: id_word_header_text_column.width
            spacing: 10
            readonly property var qsPosCur: model.modelData
            readonly property var helpObjGlobal: (oxfordModel.vGlobalHelp.length > 0
                                                  && typeof oxfordModel.vGlobalHelp[meanIndex][qsPosCur] != "undefined")
                                                 ? oxfordModel.vGlobalHelp[meanIndex][qsPosCur] : null
            readonly property var helpObjGlobalCm: (oxfordModel.vGlobalHelp.length > 0
                                                    && typeof oxfordModel.vGlobalCm[meanIndex][qsPosCur] != "undefined"
                                                    && typeof oxfordModel.vGlobalCm[meanIndex][qsPosCur].cmid != "undefined")
                                                   ? oxfordModel.vGlobalCm[meanIndex][qsPosCur] : null

            YLoader {
                id: id_word_header_help_loader
                readonly property int componentWidth: id_word_header_text_column.width
                asynchronous: false
                readonly property var helpObj: helpObjGlobal
                readonly property bool bHasIcon: true
                readonly property var qsCh: OxfordUtilities.helpChToFormatted(helpObj)
                readonly property var qslEn: OxfordUtilities.helpEnToFormatted(helpObj)
                active: qsCh.length > 0 || qslEn.length > 0
                sourceComponent: YDictTypeDtOxfordHelp{}
            }

            YLoader {
                id: id_word_header_help_cm_loader
                readonly property int componentWidth: id_word_header_text_column.width
                asynchronous: false
                readonly property var helpObj: helpObjGlobalCm
                readonly property bool bHasIcon: false
                readonly property var qsCh: OxfordUtilities.helpChToFormatted(helpObj)
                readonly property var qslEn: OxfordUtilities.helpEnToFormatted(helpObj)
                active: qsCh.length > 0 || qslEn.length > 0
                sourceComponent: YDictTypeDtOxfordHelp{}
            }
        }
    }

    YText {
        width: parent.width
        height: contentHeight
        font.family: fontManager.fontFamilyClass
        color: YColors.grayText
        text: {
            if (id_word_header_text_column.meanData !== null) {
                if (id_word_header_text_column.qsMeanShowPos.length > 0) {
                    return id_word_header_text_column.qsMeanShowPos
                }
            }
            return ""
        }
        visible: text.length > 0
    }

    YText {
        width: parent.width
        height: contentHeight
        font.family: fontManager.fontFamilyClass
        font.pixelSize: 26
        color: YColors.grayText
        textFormat: YTextBase.RichText
        wrapMode: YTextBase.WordWrap
        text: {
            if (id_word_header_text_column.meanData !== null && oxfordModel.vGlobalA.length > 0) {
                if (typeof oxfordModel.vGlobalA[meanIndex][id_word_header_text_column.qsMeanShowPos] != "undefined") {
                    return OxfordUtilities.aToFormatted(oxfordModel.vGlobalA[meanIndex][id_word_header_text_column.qsMeanShowPos])
                }
            }
            return ""
        }
        visible: text.length > 0
    }

    YDictTypeDtOxfordSdgBlock {
        meanData: id_word_header_text_column.meanData
        bForHeader: true
    }

}


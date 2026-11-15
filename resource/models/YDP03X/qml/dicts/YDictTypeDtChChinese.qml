import QtQuick 2.12
import com.youdao.pen 1.0

import BaseQml 1.0
import "../i18n"
import "../components"

YDictTypeBase {
    id: id_dict_type_ch_chinese
    title: YTranslateText.dtChChinese
    //property var chPinyinList: []
    property string chPinyinSelected: ""//resultManager.chPinyinListSelected
    property string chPinyinHeaderSelected: id_dict_page.chPinyinSelected
    property var dictSelectDetailsJson:  {
        //if (resultManager.chPinyinListSelected.length > 0) {
        if (chPinyinSelected.length > 0) {
            //return getDictSelectDetailsJson(resultManager.chPinyinListSelected)
            return getDictSelectDetailsJson(chPinyinSelected)
        } else {
            return null
        }
    }

    onIsFirstDictChanged: {
        if (isFirstDict) {
            resultManager.phoneticSymbolJson = chPinyinSelected
        }
    }

    onDictJsonChanged: {
        //console.log("YDictTypeDtChChinese.qml === onDictJsonChanged")
        if(isFirstDict) {
        if (typeof dictJson.strokeCount != "undefined") {
            id_dict_page.strokeCount = dictJson.strokeCount
            //haveStrokeInfo = true
        }
        if ((typeof dictJson.structure != "undefined") && (dictJson.structure.length > 0)) {
            id_dict_page.structure = dictJson.structure.split("结构").join('')
            //haveStrokeInfo = true
        }
        if ((typeof dictJson.radical != "undefined") && (dictJson.radical.length > 0)) {
            id_dict_page.radical = dictJson.radical
            //haveStrokeInfo = true
        }
        }
        chPinyinSelected = ""
        chPinyinList = []

        dictJson.details.forEach(function(dictDetailObject){
            //resultManager.addChPinyin(dictDetailObject.pinyin, dictType)
            if (!arrayContains(chPinyinList, dictDetailObject.pinyin)) {
                chPinyinList.push(dictDetailObject.pinyin)
            }
        })

        if(isFirstDict) {
            firstDictJson = dictJson
            chPinYinList = chPinyinList
        }

        if (chPinyinList.length > 0) {
            chPinyinSelected = chPinyinList[0]
            if (isFirstDict) {
                resultManager.phoneticSymbolJson = chPinyinSelected
            }
        }
    }

    onChPinyinSelectedChanged: {
        //console.log("YDictTypeDtChChinese.qml === onChPinyinSelectedChanged chPinyinSelected: ", chPinyinSelected)
        dictSelectDetailsJson = getDictSelectDetailsJson(chPinyinSelected)
    }

    onChPinyinHeaderSelectedChanged: {
        if(isFirstDict) {
             chPinyinSelected = id_dict_page.chPinyinSelected
             dictSelectDetailsJson = getDictSelectDetailsJson(chPinyinSelected)
        }
    }

    function getDictSelectDetailsJson(pinyin) {
        //console.log("YDictTypeDtChChinese.qml === function getDictSelectDetailsJson pinyin: ", pinyin, ", typeof pinyin: ", typeof pinyin)
        let jsonObjectMatched = null
        if (typeof pinyin !== "string" || pinyin.length <= 0) {
            return jsonObjectMatched
        }
        dictJson.details.forEach(function(dictDetailObject){
            let curPinyin = dictDetailObject.pinyin
            //console.log("YDictTypeDtChChinese.qml === function getDictSelectDetailsJson current pinyin: ", curPinyin, ", typeof current pinyin: ", typeof curPinyin)
            //console.log("YDictTypeDtChChinese.qml === function getDictSelectDetailsJson curPinyin === pinyin: ", curPinyin === pinyin)
            if (curPinyin === pinyin) {
                jsonObjectMatched = dictDetailObject
            }
        })
        //console.log("YDictTypeDtChChinese.qml === function getDictSelectDetailsJson jsonObjectMatched: ", jsonObjectMatched)
        return jsonObjectMatched
    }

    Item {
        id: name
        width: parent.width
        height: id_for_wgt_ch_group_column.height

        Column {
            id: id_for_wgt_ch_group_column
            spacing: 20
            width: parent.width

            YLoader {
                //active: !isFirstDict
                //visible: active
               // sourceComponent:
                anchors.left: parent.left
                anchors.right: parent.right
                active: !isFirstDict
                visible: active
                sourceComponent: id_pinyin_component
                asynchronous: false

            }

            Component {
                id: id_pinyin_component
                Flickable {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    height: 52
                    contentWidth: id_dict_ch_pinyin_list.width
                    flickableDirection: Flickable.HorizontalFlick
                    visible: id_dict_ch_pinyin_list_repeater.count >= 1
                    clip: true

                    Row {
                        id: id_dict_ch_pinyin_list
                        height: 52
                        spacing: 10
                        anchors.bottom: parent.bottom
                        onVisibleChanged: {
                            if (settingManager.isAutoPronounce && !resultManager.isReturnSearch && visible && isFirstDict) {
                                if(chPinyinList.length) {
                                    chPinYinsSound = typeof dictJson.details[0].pinyinWithNum != "undefined" ?
                                                (typeof dictJson.details[0].pinyinWithNum != "string" ? dictJson.details[0].pinyinWithNum.join(" ") :
                                                                               dictJson.details[0].pinyinWithNum) : null
                                    id_dict_ch_pinyin_list_repeater.itemAt(0).play()
                                }
                                qmlGlobal.audioPlayId = soundCenter.play(resultManager.currentQuery,
                                                                         resultManager.getSoundLanguage(),
                                                                         chPinYinsSound === null ? resultManager.phoneticSymbolJson : chPinYinsSound,
                                                                         settingManager.autoPronounceType)
                                resultManager.isReturnSearch = true
                                logManager.sendHttpLog("action=sound_click")
                            }
                        }

                        Repeater {
                            id: id_dict_ch_pinyin_list_repeater
                            model: chPinyinList

                            YAudioPlayIconLabelHCenterButton {
                                height: 52
                                color: YColors.grayNormal
                                textItem.font.pixelSize: 26
                                textItem.font.family: fontManager.fontFamilyEnUs
                                text: model.modelData
                                textItem.color: isCurrentSelectedPinyin ? YColors.red : YColors.white
                                iconItem.visible: isFirstDict && isCurrentSelectedPinyin
                                width: (iconItem.visible ? iconItem.width : 0) + textItem.width + 20 * 2

                                readonly property bool isCurrentSelectedPinyin : chPinyinSelected === model.modelData

                                onValidClicked: {
                                    console.log("YDictPage.qml === id_dict_ch_pinyin_list.btn.onClicked text: ", text)
                                    logManager.sendHttpLog("action=detail_chinese_audio")
                                    chPinyinSelected = text
                                    if (isFirstDict) {
                                        resultManager.phoneticSymbolJson = text
                                        chPinYinsSound = typeof dictJson.details[index].pinyinWithNum != "undefined" ?
                                                    (typeof dictJson.details[index].pinyinWithNum != "string" ? dictJson.details[index].pinyinWithNum.join(" ") :
                                                                                                                dictJson.details[index].pinyinWithNum) : null
                                        qmlGlobal.soundWGTCh()
                                    }
                                }
                            }


    //                        YButton {
    //                            height: 52
    //                            width: textWidth + 60
    //                            color: YColors.grayNormal
    //                            pixelSize: 26
    //                            textFamily: fontManager.fontFamilyEnUs
    //                            textWeight: Font.Normal
    //                            text: model.modelData
    //                            textColor: chPinyinSelected === text ? YColors.red : YColors.white
    //                            onClicked: {
    //                                console.log("YDictPage.qml === id_dict_ch_pinyin_list.btn.onClicked text: ", text)
    //                                chPinyinSelected = text
    //                                if (isFirstDict) {
    //                                    resultManager.phoneticSymbolJson = text
    //                                    chPinYinsSound =typeof dictJson.details[index].pinyinWithNum!="undefined"
    //                                            ?(typeof dictJson.details[index].pinyinWithNum != "string"
    //                                              ?dictJson.details[index].pinyinWithNum.join(" ")
    //                                              :dictJson.details[index].pinyinWithNum):null
    //                                    qmlGlobal.soundWGTCh()
    //                                }
    //                            }
    //                        }

                        }
                    }
                }

            }
//            Row {
//                spacing: 6
//                visible: (typeof dictJson.stroke != "undefined") && (dictJson.stroke.length > 0)
//                anchors.left: parent.left
//                anchors.right: parent.right
//                height: id_stroke_content.height

//                YTextBase {
//                    id: id_stroke_label
//                    color: YColors.grayText
//                    font.pixelSize: 26
//                    width: contentWidth
//                    height: 40
//                    verticalAlignment: Text.AlignVCenter
//                    text: YTranslateText.orderOfStrokes
//                }

//                YTextMedium {
//                    id: id_stroke_content
//                    wrapMode: YText.Wrap
//                    font.pixelSize: 26
//                    width: parent.width - parent.spacing - id_stroke_label.width
//                    height: contentHeight
//                    font.family: fontManager.fontFamilyJaJp
//                    text: dictJson.stroke.join(' ')
//                }
//            }

//            Row {
//                spacing: 6
//                visible: ((typeof dictJson.structure != "undefined") && (dictJson.structure.length > 0))
//                anchors.left: parent.left
//                anchors.right: parent.right
//                height: id_structure_value.height
//                YTextBase {
//                    id: id_structure_label
//                    color: YColors.grayText
//                    font.pixelSize: 26
//                    width: contentWidth
//                    height: contentHeight
//                    text: YTranslateText.structure
//                }

//                YTextMedium {
//                    id: id_structure_value
//                    wrapMode: YText.Wrap
//                    width: parent.width - parent.spacing - id_structure_label.width
//                    height: contentHeight
//                    font.family: fontManager.fontFamilyZhCn
//                    text: dictJson.structure
//                }
//            }

//            Row {
//                spacing: 6
//                visible: ((typeof dictJson.strokeCount != "undefined"))
//                         || ((typeof dictJson.radical != "undefined") && (dictJson.radical.length > 0))
//                anchors.left: parent.left
//                anchors.right: parent.right
//                height: id_radical_value.height

//                YTextBase {
//                    id: id_strokeCount_label
//                    color: YColors.grayText
//                    font.pixelSize: 26
//                    width: contentWidth
//                    height: contentHeight
//                    text: YTranslateText.stroke
//                }

//                YTextMedium {
//                    id: id_strokeCount_value
//                    wrapMode: YText.Wrap
//                    width: contentWidth
//                    height: contentHeight
//                    font.family: fontManager.fontFamilyZhCn
//                    text: dictJson.strokeCount
//                }

//                YSpacing {
//                    id: id_strokeCount_spacing
//                    implicitWidth: 26
//                    implicitHeight: 20
//                }

//                YTextBase {
//                    id: id_radical_label
//                    color: YColors.grayText
//                    font.pixelSize: 26
//                    width: contentWidth
//                    height: contentHeight
//                    text: YTranslateText.radical
//                }

//                YTextMedium {
//                    id: id_radical_value
//                    wrapMode: YText.Wrap
//                    width: parent.width - parent.spacing*4 - id_strokeCount_label.width
//                           - id_strokeCount_value.width - id_radical_label.width
//                           - id_strokeCount_spacing.width
//                    height: contentHeight
//                    font.family: fontManager.fontFamilyZhCn
//                    text: dictJson.radical
//                }
//            }

            Repeater {
                model: dictSelectDetailsJson === null ? null : dictSelectDetailsJson.meanings
                Row {
                    width: id_for_wgt_ch_group_column.width
                    height: id_detail_meaning_content.height
                    spacing: 26
                    YTextBase {
                        id: id_detail_meaning_label
                        color: YColors.grayText
                        font.pixelSize: 26
                        width: contentWidth
                        height: contentHeight
                        text: ("%1.").arg(index + 1)
                    }

                    Column {
                        id: id_detail_meaning_content
                        width: parent.width - parent.spacing - id_detail_meaning_label.width
                        spacing: 12

                        YTextMedium {
                            wrapMode: YText.Wrap
                            width: parent.width
                            height: contentHeight
                            font.family: fontManager.fontFamilyZhCn
                            text: model.modelData.value
                        }

                        YTextBase {
                            id: id_detail_meaning_examples
                            wrapMode: YText.Wrap
                            color: YColors.grayText
                            font.family: fontManager.fontFamilyZhCn
                            font.pixelSize: 26
                            width: parent.width
                            height: contentHeight
                            text: model.modelData.example.join('、')
                        }
                    }
                }
            }

            YTextBase {
                id: id_word_group_title
                font.pixelSize: 26
                color: YColors.red
                height: contentHeight
                text: YTranslateText.groupOfWords
                visible: id_start_word_row.visible
                         || id_end_word_row.visible
                         || id_idioms_word_row.visible
                Component.onCompleted: {
                    dictNodeCompleted(text, dictType, 1, this);
                }
            }

            Row {
                id: id_start_word_row
                spacing: 26
                anchors.left: parent.left
                anchors.right: parent.right
                height: id_start_word_row_column.height
                visible: dictSelectDetailsJson !== null
                         && (typeof dictSelectDetailsJson.start != "undefined")
                         && (dictSelectDetailsJson.start.length > 0)
                YTextBase {
                    id: id_start_word_label
                    color: YColors.grayText
                    font.pixelSize: 26
                    width: contentWidth
                    height: contentHeight
                    text: "1."
                }

                Column {
                    id: id_start_word_row_column
                    width: parent.width - parent.spacing - id_start_word_label.width
                    spacing: 12

                    YTextMedium {
                        wrapMode: YText.Wrap
                        width: parent.width
                        height: contentHeight
                        font.family: fontManager.fontFamilyZhCn
                        text: YTranslateText.wordsBeginningWith.arg(resultManager.currentQuery)
                    }

                    YTextBase {
                        id: id_start_word_value
                        wrapMode: YText.Wrap
                        color: YColors.grayText
                        font.family: fontManager.fontFamilyZhCn
                        font.pixelSize: 26
                        lineHeightMode: Text.FixedHeight
                        lineHeight: 38
                        width: parent.width
                        height: contentHeight
                        text: id_start_word_row.visible ? dictSelectDetailsJson.start.join('、') : ""
                    }
                }
            }

            Row {
                id: id_end_word_row
                spacing: 26
                anchors.left: parent.left
                anchors.right: parent.right
                height: id_end_word_row_column.height
                visible: dictSelectDetailsJson !== null
                         && (typeof dictSelectDetailsJson.end != "undefined")
                         && (dictSelectDetailsJson.end.length > 0)
                YTextBase {
                    id: id_end_word_label
                    color: YColors.grayText
                    font.pixelSize: 26
                    width: contentWidth
                    height: contentHeight
                    text: {
                        if (id_start_word_row.visible) {
                            return "2."
                        }
                        return "1."
                    }
                }

                Column {
                    id: id_end_word_row_column
                    width: parent.width - parent.spacing - id_end_word_label.width
                    spacing: 12

                    YTextMedium {
                        wrapMode: YText.Wrap
                        width: parent.width
                        height: contentHeight
                        font.family: fontManager.fontFamilyZhCn
                        text: YTranslateText.wordsEndingWith.arg(resultManager.currentQuery)
                    }

                    YTextBase {
                        id: id_end_word_value
                        wrapMode: YText.Wrap
                        color: YColors.grayText
                        font.family: fontManager.fontFamilyZhCn
                        font.pixelSize: 26
                        lineHeightMode: Text.FixedHeight
                        lineHeight: 38
                        width: parent.width
                        height: contentHeight
                        text: id_end_word_row.visible ? dictSelectDetailsJson.end.join('、') : ""
                    }
                }
            }

            Row {
                id: id_idioms_word_row
                spacing: 26
                anchors.left: parent.left
                anchors.right: parent.right
                height: id_idioms_word_column.height
                visible: dictSelectDetailsJson !== null
                         && (typeof dictSelectDetailsJson.idioms != "undefined")
                         && (dictSelectDetailsJson.idioms.length > 0)
                YTextBase {
                    id: id_idioms_word_label
                    color: YColors.grayText
                    font.pixelSize: 26
                    width: contentWidth
                    height: contentHeight
                    text: {
                        if (id_start_word_row.visible) {
                            if (id_end_word_row.visible) {
                                return "3."
                            }
                            return "2."
                        }
                        return "1."
                    }
                }

                Column {
                    id: id_idioms_word_column
                    width: parent.width - parent.spacing - id_idioms_word_label.width
                    spacing: 12

                    YTextMedium {
                        wrapMode: YText.Wrap
                        width: parent.width
                        height: contentHeight
                        font.family: fontManager.fontFamilyZhCn
                        text: YTranslateText.anIdiomWith.arg(resultManager.currentQuery)
                    }

                    YTextBase {
                        id: id_idioms_word_value
                        wrapMode: YText.Wrap
                        color: YColors.grayText
                        font.family: fontManager.fontFamilyZhCn
                        font.pixelSize: 26
                        lineHeightMode: Text.FixedHeight
                        lineHeight: 38
                        width: parent.width
                        height: contentHeight
                        text: id_idioms_word_row.visible ? dictSelectDetailsJson.idioms.join('、') : ""
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
                height: id_synonyms_word_content.height
                visible: dictSelectDetailsJson !== null
                         && (typeof dictSelectDetailsJson.synonyms != "undefined")
                         && (dictSelectDetailsJson.synonyms.length > 0)
                YTextBase {
                    id: id_synonyms_word_label
                    color: YColors.grayText
                    font.pixelSize: 26
                    width: contentWidth
                    height: contentHeight
                    text: "1."
                }

                Column {
                    id: id_synonyms_word_content
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
                        text: id_synonyms_word_row.visible ? dictSelectDetailsJson.synonyms.join('、') : ""
                    }
                }
            }

            Row {
                id: id_antonyms_word_row
                spacing: 26
                anchors.left: parent.left
                anchors.right: parent.right
                height: id_antonyms_word_content.height
                visible: dictSelectDetailsJson !== null
                         && (typeof dictSelectDetailsJson.antonyms != "undefined")
                         && (dictSelectDetailsJson.antonyms.length > 0)
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
                    id: id_antonyms_word_content
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
                        text: id_antonyms_word_row.visible ? dictSelectDetailsJson.antonyms.join('、') : ""
                    }
                }
            }

        }

    }

}

// for YEnum.WGT_Ch === resultManager.currentQueryType
// 易
/*
{
    "details": [
        {
            "antonyms": [
                "难"
            ],
            "end": [
                "容易",
                "贸易",
                "不易",
                "交易",
                "简易",
                "改易",
                "辟易",
                "平易",
                "乐易",
                "难易",
                "更易",
                "移易"
            ],
            "idioms": [
                "平易近人",
                "轻而易举",
                "显而 易见"
            ],
            "meanings": [
                {
                    "value": "不难的，轻松，简单，省力",
                    "example": [
                        "容易",
                        "轻易",
                        "浅易",
                        "易如反掌",
                        "来之不易"
                    ]
                },
                {
                    "value": "一物换一物，交换",
                    "example": [
                        "贸易",
                        "交易",
                        "易货",
                        "国际贸易",
                        "以物易物"
                    ]
                },
                {
                    "value": "改变，发生变化，与原来不一样",
                    "example": [
                        "易容",
                        "易手",
                        "移风易俗",
                        "改弦易辙",
                        "易地而处"
                    ]
                },
                {
                    "value": "和蔼可亲，好相处",
                    "example": [
                        "和易",
                        "平易",
                        "平易近人",
                        "平心易气"
                    ]
                },
                {
                    "value": "态度傲慢 ，轻视",
                    "example": [
                        "躁易",
                        "佻易",
                        "玩易"
                    ]
                },
                {
                    "value": "指古代占卜之书",
                    "example": [
                        "《周易》",
                        "《易经》"
                    ]
                },
                {
                    "value": "铲除杂草，整治",
                    "example": [
                        "易田",
                        "易路"
                    ]
                }
            ],
            "pinyin": "yì",
            "start": [
                "易于",
                "易传",
                "易帜",
                "易水",
                "易与",
                "易经",
                "易地"
            ],
            "synonyms": []
        }
    ],
    "radical": "日(曰)",
    "stroke": [
        "丨",
        "ㄱ",
        "一",
        "一",
        "丿",
        "㇆",
        "丿",
        "丿"
    ],
    "strokeCount": 8,
    "structure": "上下结构"
}
  */


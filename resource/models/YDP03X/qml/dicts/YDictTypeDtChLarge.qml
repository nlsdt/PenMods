import QtQuick 2.12

import BaseQml 1.0
import "../i18n"

YDictTypeBase {
    title: YTranslateText.dtChLarge
    visible: dictSelectDataJson !== null
    property string chPinyinSelected: ""//resultManager.chPinyinListSelected
    property string chPinyinHeaderSelected: id_dict_page.chPinyinSelected
    property var dictSelectDataJson: {
        //if (resultManager.chPinyinListSelected.length > 0) {
        if (chPinyinSelected.length > 0) {
            //return getDictSelectDataJson(resultManager.chPinyinListSelected)
            return getDictSelectDataJson(chPinyinSelected)
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
        chPinyinSelected = ""
        chPinyinList = []
        dictJson.dataList.forEach(function(dictDataObject){
            let phoneCur = dictDataObject.phone
            phoneCur = phoneCur.replace(/\[/g, "")
            phoneCur = phoneCur.replace(/\]/g, "")
            //resultManager.addChPinyin(phoneCur, dictType)
            if (!arrayContains(chPinyinList, phoneCur)) {
                chPinyinList.push(phoneCur)
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
        //console.log("YDictTypeDtChLarge.qml === onChPinyinSelectedChanged chPinyinSelected: ", chPinyinSelected)
        dictSelectDataJson = getDictSelectDataJson(chPinyinSelected)
    }

    onChPinyinHeaderSelectedChanged: {
        if(isFirstDict) {
             chPinyinSelected = id_dict_page.chPinyinSelected
             dictSelectDataJson = getDictSelectDataJson(chPinyinSelected)
        }
    }

    function getDictSelectDataJson(phone) {
        //console.log("YDictTypeDtChLarge.qml === function getDictSelectDataJson phone: ", phone)
        let jsonObjectMatched = null
        if (typeof phone !== "string" || phone.length <= 0) {
            return jsonObjectMatched
        }
        dictJson.dataList.forEach(function(dictDataObject){
            let phoneCur = dictDataObject.phone
            phoneCur = phoneCur.replace(/\[/g, "")
            phoneCur = phoneCur.replace(/\]/g, "")
            //console.log("YDictTypeDtChLarge.qml === function getDictSelectDataJson current phone: ", phoneCur)
            if (phoneCur === phone) {
                jsonObjectMatched = dictDataObject
            }
        })
        return jsonObjectMatched
    }

    Item {
        id: name
        width: parent.width
        height: id_word_Column.height

        Column {
            id: id_word_Column
            spacing: 20
            width: parent.width
            property var modelModelData: dictSelectDataJson

            YLoader {
                //active: !isFirstDict
                //visible: active
                // sourceComponent:
                anchors.left: parent.left
                anchors.right: parent.right
                active: !isFirstDict && typeof chPinyinList.length !== "undefined" && chPinyinList.length > 1
                visible: active
                height: visible ? undefined : 0
                asynchronous: false
                sourceComponent: id_pinyin_component
            }

            Component {
                id: id_pinyin_component
                Flickable {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    height: 52
                    contentWidth: id_dict_ch_pinyin_list.width
                    flickableDirection: Flickable.HorizontalFlick
                    visible: id_dict_ch_pinyin_list_repeater.count > 1
                    clip: true

                    Row {
                        id: id_dict_ch_pinyin_list
                        height: 52
                        spacing: 10
                        anchors.bottom: parent.bottom

                        onVisibleChanged: {
                            if (settingManager.isAutoPronounce && !resultManager.isReturnSearch && visible && isFirstDict) {
                                if(chPinyinList.length) {
                                    chPinYinsSound = typeof dictJson.dataList[0].pinyinWithNum != "undefined"
                                            ? (typeof dictJson.details[0].pinyinWithNum != "string"
                                               ? dictJson.dataList[0].pinyinWithNum.join(" ")
                                               : dictJson.dataList[0].pinyinWithNum) : (typeof dictJson.dataList[0].speech != "undefined" ?
                                                                                            dictJson.dataList[0].speech : null)
                                    try {
                                        id_dict_ch_pinyin_list_repeater.itemAt(0).play()
                                    } catch(e){}
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

                            YButton {
                                height: 52
                                width: textWidth + 60
                                color: YColors.grayNormal
                                pixelSize: 26
                                textFamily: fontManager.fontFamilyEnUs
                                textWeight: Font.Normal
                                text: model.modelData
                                textColor: chPinyinSelected === text ? YColors.red : YColors.white
                                onClicked: {
                                    console.warn("YDictPage.qml === id_dict_ch_pinyin_list.btn.onClicked text: ", text)
                                    chPinyinSelected = text
                                    if (isFirstDict) {
                                        resultManager.phoneticSymbolJson = text
                                        console.warn("YDictPage.qml === index: "+index+",speech:"+dictJson.dataList[index].speech)
                                        chPinYinsSound = typeof dictJson.dataList[index].pinyinWithNum != "undefined"
                                                ? (typeof dictJson.details[index].pinyinWithNum != "string"
                                                   ? dictJson.dataList[index].pinyinWithNum.join(" ")
                                                   : dictJson.dataList[index].pinyinWithNum) : (typeof dictJson.dataList[index].speech != "undefined" ?
                                                                                                    dictJson.dataList[index].speech : null)

                                        qmlGlobal.soundWGTCh()
                                    }
                                }
                            }
                        }
                    }
                }
            }

            YTextBase {
                font.pixelSize: 30
                wrapMode: YTextBase.Wrap
                textFormat: YTextBase.RichText
                width: id_word_Column.width
                height: contentHeight
                text: visible
                      ? '<span style="font-family: ' + fontManager.fontFamilyZhCn + ('; color: %1; font-weight: 500">').arg(YColors.white) + dictJson.word + '</span>'
                        + '<span>&nbsp;&nbsp;&nbsp;&nbsp;</span>'
                        + '<span style="font-family: ' + fontManager.fontFamilyEnUs + ('; color: %1; font-weight: 400;">').arg(YColors.grayText) + id_word_Column.modelModelData.phone + '</span>'
                      : ""
                visible: id_word_Column.modelModelData !== null
            } // text word_phone

            Item {
                id: id_word_trs_item
                width: id_word_Column.width
                height: id_word_trs_content_column.height
                property var modelModelData: id_word_Column.modelModelData === null || (typeof id_word_Column.modelModelData.trs == "undefined") ? null : id_word_Column.modelModelData.trs[0]
                visible: id_word_trs_item.modelModelData !== null
                         && typeof id_word_trs_item.modelModelData.tr != "undefined"
                         && (typeof id_word_trs_item.modelModelData.tr.cn != "undefined"
                             || typeof id_word_trs_item.modelModelData.tr.en != "undefined")

                YTextMedium {
                    id: id_word_trs_index
                    color: YColors.grayText
                    font.pixelSize: 26
                    font.family: fontManager.fontFamilyZhCn
                    width: 44
                    height: id_word_trs_content_column.height
                    text: ("1.")
                    //text: "1."
                } // Text id_word_trs_index

                Column {
                    id: id_word_trs_content_column
                    spacing: 16
                    anchors.left: id_word_trs_index.right
                    anchors.right: parent.right

                    YTextBase {
                        id: id_word_trs_pos
                        width: parent.width
                        height: contentHeight
                        font.weight: Font.Medium
                        wrapMode: YTextBase.Wrap
                        textFormat: YTextBase.RichText
                        text: {
                            if (!id_word_trs_item.visible) return ""
                            if (!id_word_trs_item.visible) return ""
                            let qsPos = (typeof id_word_trs_item.modelModelData.pos != "undefined")
                                         ? "&lt;" + id_word_trs_item.modelModelData.pos + "&gt;" : ""
                            let qsTranCn = (typeof id_word_trs_item.modelModelData.tr.cn != "undefined")
                                            ? ("（" + id_word_trs_item.modelModelData.tr.cn + "）") : ""
                            let qsTranEn = (typeof id_word_trs_item.modelModelData.tr.en != "undefined")
                                            ? id_word_trs_item.modelModelData.tr.en : ""
                            return '<span style="font-family: ' + fontManager.fontFamilyZhCn + ('; color: %1; font-size: 26px">').arg(YColors.grayText) + qsPos + '</span>'
                                    + '<span style="font-family: ' + fontManager.fontFamilyZhCn + ('; color: %1; font-size: 28px">').arg(YColors.white) + qsTranCn + '</span>'
                                    + '<span style="font-family: ' + fontManager.fontFamilyEnUs + ('; color: %1; font-size: 28px">').arg(YColors.white) + qsTranEn + '</span>'
                        }
                    } // Text id_word_trs_pos

                    Item {
                        id: id_word_trs_sents_item
                        width: id_word_trs_content_column.width
                        height: id_word_trs_sents_content_column.height
                        property var modelModelData: !id_word_trs_item.visible || (typeof id_word_trs_item.modelModelData.sents == "undefined") ? null : id_word_trs_item.modelModelData.sents[0]

                        YTextBase {
                            id: id_word_trs_sents_index
                            color: "#FFFFFF"
                            font.pixelSize: 26
                            font.weight: Font.Bold
                            font.family: fontManager.fontFamilyEnUs
                            width: 24
                            height: id_word_trs_sents_content_column.height
                            text: visible ? ("·") : ""
                            visible: id_word_trs_sents_cn.visible || id_word_trs_sents_en.visible
                        }

                        Column {
                            id: id_word_trs_sents_content_column
                            spacing: 8
                            anchors.left: id_word_trs_sents_index.right
                            anchors.right: parent.right

                            YTextBase {
                                id: id_word_trs_sents_cn
                                width: parent.width
                                height: contentHeight
                                font.family: fontManager.fontFamilyZhCn
                                font.pixelSize: 28
                                font.weight: Font.Normal
                                wrapMode: YTextBase.Wrap
                                color: "#FFFFFF"
                                text: visible ? id_word_trs_sents_item.modelModelData.cn : ""
                                visible: id_word_trs_sents_item.modelModelData !== null && typeof id_word_trs_sents_item.modelModelData.cn != "undefined"
                            } // Text id_word_trs_sents_cn


                            YTextBase {
                                id: id_word_trs_sents_en
                                width: parent.width
                                height: contentHeight
                                font.family: fontManager.fontFamilyEnUs
                                font.pixelSize: 28
                                font.weight: Font.Normal
                                wrapMode: YTextBase.Wrap
                                color: YColors.grayText
                                text: visible ? id_word_trs_sents_item.modelModelData.en : ""
                                visible: id_word_trs_sents_item.modelModelData !== null && typeof id_word_trs_sents_item.modelModelData.en != "undefined"
                            } // Text id_word_trs_sents_en

                        } // Column id_word_trs_sents_content_column

                    } // Item id_word_trs_sents_item

                } // Column id_word_trs_content_column

            } // Item id_word_trs_item

        } // Column

    }
}

/*
    // 那
{
    "dataList":[
        {
            "trs":[
                {
                    "tr":{
                        "en":"that",
                        "cn":"Ⅰ□代指示比较远的人或事物"
                    },
                    "sents":[
                        {
                            "en":"Who is that?",
                            "cn":"那是谁?"
                        },
                        {
                            "en":"That was my fault",
                            "cn":"那是我的过错。"
                        },
                        {
                            "en":"That is a factory",
                            "cn":"那是一个工厂。"
                        },
                        {
                            "en":"That was in 1989",
                            "cn":"那是1989年的事。"
                        }
                    ]
                }
            ],
            "phone":"[nà]",
            "notice":"[": ① 单用的“那”限于在动词前。 在动词后面用“那个”， 只有跟“这”对举的时候可以用“那”， 如: 说这道 那 的; 看看这， 看看 那， 真有说 不出的高兴。 ② 在口语里， “那”单用或者后面直接跟名词， 说 nà 或 nè; “那”后面跟量词或数词加量词， 常常说 nèi 或 nè。 以下“那个”、“那会儿”、“那些”、“那样”各条在口语里都常常说 nèi- 或 nè-， “那么些”、“那么样”、“那么着”各条在口语里都常常说 nè-。 Ⅱ □连  (那么) then; in that case: 那 我们就不再等了。 In that case, we won't wait any longer. 你要是跟我们一块走， 那 就得快点。 If you're coming with us, you must hurry. 如果你喜欢， 那 就买吧! If you like it, take it, then."]"
        },
        {
            "trs":[
                {
                    "pos":"名",
                    "tr":{
                        "en":"a surname",
                        "cn":"姓氏"
                    },
                    "sents":[
                        {
                            "en":"Na Rong",
                            "cn":"那荣"
                        }
                    ]
                }
            ],
            "phone":"[nā]"
        },
        {
            "trs":[
                {
                    "pos":"名",
                    "tr":{
                        "en":"a surname",
                        "cn":"姓氏"
                    },
                    "sents":[
                        {
                            "en":"Nuo Jian",
                            "cn":"那鉴"
                        }
                    ]
                }
            ],
            "phone":"[nuó]"
        },
        {
            "trs":[
                {
                    "pos":"代",
                    "tr":{
                        "en":"which; what",
                        "cn":"表示疑问"
                    },
                    "sents":[
                        {
                            "en":"Which one of you is Mr.",
                            "cn":"你们中间那一位是王先生?"
                        },
                        {
                            "en":"What is your favourite kind of music?",
                            "cn":"你最喜欢那种音乐?"
                        },
                        {
                            "en":"What foreign language are you studying?.",
                            "cn":"你学的是那国语言?"
                        }
                    ]
                },
                {
                    "pos":"代",
                    "tr":{
                        "en":"any",
                        "cn":"泛指"
                    }
                },
                {
                    "pos":"副",
                    "tr":{
                        "cn":"表示反问"
                    },
                    "sents":[
                        {
                            "en":"How can there be things as such?",
                            "cn":"那会有这种事?"
                        }
                    ]
                }
            ],
            "phone":"[nǎ]"
        }
    ],
    "word":"那"
}
  */


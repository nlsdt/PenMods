import QtQuick 2.12

import BaseQml 1.0
import "../i18n"

YDictTypeBase {
    id: id_dict_type_ch_ancientword
    title: YTranslateText.dtChAncientWord
    visible: dictSelectParaphrasesJson !== null
    //property var chPinyinList: []
    property string chPinyinSelected: ""//resultManager.chPinyinListSelected
    property string chPinyinHeaderSelected: id_dict_page.chPinyinSelected

    property var dictSelectParaphrasesJson: {
        //if (resultManager.chPinyinListSelected.length > 0) {
        if (chPinyinSelected.length > 0) {
            //return getDictSelectParaphrasesJson(resultManager.chPinyinListSelected)
            return getDictSelectParaphrasesJson(chPinyinSelected)
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
        //console.log("YDictTypeDtChAncientWord.qml === onDictJsonChanged")
        chPinyinSelected = ""
        chPinyinList = []
        dictJson.phones.forEach(function(dictPhoneObject){
            if (!arrayContains(chPinyinList, dictPhoneObject.phone)) {
                chPinyinList.push(dictPhoneObject.phone)
            }
        });
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
        //console.log("YDictTypeDtChAncientWord.qml === onChPinyinSelectedChanged chPinyinSelected: ", chPinyinSelected)
        dictSelectParaphrasesJson = getDictSelectParaphrasesJson(chPinyinSelected)
    }

    onChPinyinHeaderSelectedChanged: {
        if(isFirstDict) {
             chPinyinSelected = id_dict_page.chPinyinSelected
             dictSelectParaphrasesJson = getDictSelectParaphrasesJson(chPinyinSelected)
        }
    }

    function getDictSelectParaphrasesJson(phone) {
        //console.log("YDictTypeDtChAncientWord.qml === function getDictSelectParaphrasesJson phone: ", phone)
        let jsonObjectMatched = null
        if (typeof phone !== "string" || phone.length <= 0) {
            return jsonObjectMatched
        }
        dictJson.paraphrases.forEach(function(dictParaphrasesObject){
            //console.log("YDictTypeDtChAncientWord.qml === function getDictSelectParaphrasesJson current phone: ", dictParaphrasesObject.phone)
            if (dictParaphrasesObject.phone === phone) {
                jsonObjectMatched = dictParaphrasesObject
            }
        })
        return jsonObjectMatched
    }

    Item {
        width: parent.width
        height: id_word_detailParas_column.height

        Column {
            id: id_word_detailParas_column
            spacing: 20
            width: parent.width
            property var paraItemTotalIndex: 0
            property var modelModelData: dictSelectParaphrasesJson === null || (typeof dictSelectParaphrasesJson.detailParas == "undefined")
                                         ? null : dictSelectParaphrasesJson.detailParas[0]
            onModelModelDataChanged: {
                paraItemTotalIndex = 0
            }

            YLoader {
                //active: !isFirstDict
                //visible: active
                // sourceComponent:
                anchors.left: parent.left
                anchors.right: parent.right
                active: (!isFirstDict && typeof chPinyinList.length !== "undefined" && chPinyinList.length > 1)
                visible: active
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
                            console.log("anciendWord,resultManager.isReturnSearch:"+resultManager.isReturnSearch+"**isFirstDict:"+isFirstDict)
                            if (settingManager.isAutoPronounce && !resultManager.isReturnSearch && visible && isFirstDict) {
                                if(chPinyinList.length) {
                                    chPinYinsSound = typeof dictJson.phones[0].pinyinWithNum != "undefined"
                                            ? (typeof dictJson.phones[0].pinyinWithNum != "string"
                                               ? dictJson.phones[0].pinyinWithNum.join(" ")
                                               : dictJson.phones[0].pinyinWithNum) : (typeof dictJson.phones[0].speech != "undefined" ?
                                                                                          dictJson.phones[0].speech : null)
                                    console.log("anciendWord,resultManager.chPinYinsSound:"+chPinYinsSound)
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
                                    console.log("YDictPage.qml === id_dict_ch_pinyin_list.btn.onClicked text: ", text)
                                    chPinyinSelected = text
                                    if (isFirstDict) {
                                        resultManager.phoneticSymbolJson = text
                                        chPinYinsSound = typeof dictJson.phones[index].pinyinWithNum != "undefined"
                                                ? (typeof dictJson.phones[index].pinyinWithNum != "string"
                                                   ? dictJson.phones[index].pinyinWithNum.join(" ")
                                                   : dictJson.phones[index].pinyinWithNum) : (typeof dictJson.phones[index].speech != "undefined" ?
                                                                                                  dictJson.phones[index].speech : null)
                                        qmlGlobal.soundWGTCh()
                                    }
                                }
                            }
                        }
                    }
                }

            }

            Repeater {
                id: id_word_detailParas_paraItems_repeater
                model: (typeof id_word_detailParas_column.modelModelData.paraItems == "undefined")
                       ? null : id_word_detailParas_column.modelModelData.paraItems

                Item {
                    id: id_word_detailParas_paraItems_item
                    width: id_word_detailParas_column.width
                    height: id_word_detailParas_paraItems_column.height
                    visible: index < 2

                    property var modelModelData: model.modelData

                    YTextBase {
                        id: id_word_detailParas_paraItems_index
                        color: YColors.grayText
                        font.pixelSize: 26
                        font.weight: Font.Bold
                        width: 44
                        height: id_word_detailParas_paraItems_column.height
                        Component.onCompleted: {
                            id_word_detailParas_column.paraItemTotalIndex += 1
                            text = id_word_detailParas_column.paraItemTotalIndex
                        }
                    }

                    Column {
                        id: id_word_detailParas_paraItems_column
                        spacing: 12
                        anchors.left: id_word_detailParas_paraItems_index.right
                        anchors.right: parent.right

                        YTextBase {
                            id: id_word_detailParas_paraItems_para
                            width: parent.width
                            height: contentHeight
                            font.family: fontManager.fontFamilyZhCn
                            font.pixelSize: 28
                            font.weight: Font.Medium
                            textFormat: YTextBase.RichText
                            wrapMode: YTextBase.Wrap
                            color: "#FFFFFF"
                            text: {
                                if (!id_word_detailParas_paraItems_para.visible) return ""
                                let qsText = ""
                                if (id_word_detailParas_paraItems_item.modelModelData !== null && typeof id_word_detailParas_paraItems_item.modelModelData.wordsAttri != "undefined")
                                    qsText += ('<span style="color: %1">&lt;').arg(YColors.grayText) + id_word_detailParas_paraItems_item.modelModelData.wordsAttri + '&gt;</span>'
                                qsText += id_word_detailParas_paraItems_item.modelModelData.para
                                return qsText
                            }
                            visible: id_word_detailParas_paraItems_item.modelModelData !== null
                                     && typeof id_word_detailParas_paraItems_item.modelModelData.para != "undefined"
                        } // Text id_word_detailParas_paraItems_para

                        Repeater {
                            id: id_word_detailParas_paraItems_examples_repeater
                            model: id_word_detailParas_paraItems_item.modelModelData === null || (typeof id_word_detailParas_paraItems_item.modelModelData.examples == "undefined")
                                   ? null : id_word_detailParas_paraItems_item.modelModelData.examples

                            YTextBase {
                                id: id_word_detailParas_paraItems_example
                                width: parent.width
                                height: contentHeight
                                font.family: fontManager.fontFamilyZhCn
                                font.pixelSize: 26
                                font.weight: Font.Normal
                                wrapMode: YTextBase.Wrap
                                color: YColors.grayText
                                text: model.modelData
                            } // Text id_word_detailParas_paraItems_example

                        } // Repeater id_word_detailParas_paraItems_examples_repeater

                    } // Column id_word_trs_sents_content_column

                } // Item id_word_trs_sents_item

            } // Column id_word_detailParas_column
        }
    }
}

/*
    // 一
{
    "phones":[{"pronun":"哪","phone":"nǎ"},{"pronun":"捺","phone":"nà"},{"pronun":"挪","phone":"nuó"},{"pronun":"懦","phone":"nuò"},{"pronun":"哪","phone":"né"}],
    "paraphrases":[
        {
            "detailParas":[
                {
                    "paraItems":[
                        {
                            "para":"见“那吒”。"
                        },
                        {
                            "para":"见ｎǎ。"
                        }
                    ]
                }
            ],
            "phone":"né",
            "words":"那"
        },
        {
            "detailParas":[
                {
                    "paraItems":[
                        {
                            "wordsAttri":"助",
                            "examples":[
                                "《后汉书·韩康传》：“公是韩伯休～?乃不二价乎?”"
                            ],
                            "para":"表疑问语气。"
                        },
                        {
                            "para":"见ｎǎ。"
                        }
                    ]
                }
            ],
            "phone":"nuò",
            "words":"那"
        },
        {
            "detailParas":[
                {
                    "paraItems":[
                        {
                            "wordsAttri":"代",
                            "examples":[
                                "《孔雀东南飞》：“处分适兄意，～得自任专?”",
                                "《乐府诗集·折杨柳枝歌》：“阿婆不嫁女，～得儿孙抱?”【注】古无“哪”字，古文中用“哪”的问句都用“那”。"
                            ],
                            "para":"同“哪”。如何；怎么。"
                        }
                    ]
                }
            ],
            "phone":"nǎ",
            "words":"那"
        },
        {
            "detailParas":[
                {
                    "paraItems":[
                        {
                            "wordsAttri":"代",
                            "para":"指较远的人或事物。"
                        }
                    ]
                }
            ],
            "phone":"nà",
            "words":"那"
        },
        {
            "detailParas":[
                {
                    "paraItems":[
                        {
                            "wordsAttri":"形",
                            "examples":[
                                "《诗经·商颂·那》：“猗与～与!”(猗：叹美之辞。)"
                            ],
                            "para":"多。"
                        },
                        {
                            "wordsAttri":"动",
                            "examples":[
                                "《左传·宣公二年》：“牛则有皮，犀兕尚多，弃甲则～。”"
                            ],
                            "para":"“奈何”的合音。"
                        },
                        {
                            "para":"见ｎǎ。"
                        }
                    ]
                }
            ],
            "phone":"nuó",
            "words":"那"
        }
    ],
    "word":"那",
    "relatedWords": {"end":["兀那"],"first":["那吒"],"empty":false}
}
  */


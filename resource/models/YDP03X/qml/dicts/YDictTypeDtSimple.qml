import QtQuick 2.12
import com.youdao.pen 1.0

import BaseQml 1.0
import "../i18n"
import "../components"

YDictTypeBase {
    title: dictType === YEnum.DtSimple ? YTranslateText.dtSimple
                                       : (YTranslateText.dtEnChKid).replace("<br/>", " ")
    property var textContenWidth: 582

    function regExpEscape(literal_string) {
        return literal_string.replace(/[-[\]{}()*+!<=:?.\/\\^$|#\s,]/g, '\\$&');
    }

    Item {
        width: parent.width
        height: id_dict_content_column.height

        Column {
            id: id_dict_content_column
            width: parent.width
            spacing: 12

            YTextBase {
                id: id_dict_content
                font.pixelSize: 28
                wrapMode: YText.Wrap
                textFormat: YTextBase.RichText
                width: parent.width
                height: paintedHeight
                lineHeightMode: Text.FixedHeight
                lineHeight: 44
                text: {
                    let sResult = ''
                    if (typeof dictJson.pure.m != "undefined") {
                        let mArray = dictJson.pure.m
                        mArray.forEach(function(mean){
                            if (typeof mean.pos !== "undefined") {
                                sResult += ('<span style="font-family: %1; font-style: italic; color: %2; font-size: 24px">').arg(fontManager.fontFamilyClass).arg(YColors.grayText)
                                        + mean.pos + '</span>' + '<span>&nbsp;</span>'
                            }

                            sResult += '<span style="font-family: OPPOSans; font-weight: 500; '
                                    + ('color: %1; font-size: 28px">').arg(YColors.white) + mean.m + '</span>'
                                    + '<span>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span>'
                        })
                        if (typeof dictJson.pure.phonics != "undefined")
                            setPhonic(dictJson)
                            //spellManager.phonics  = JSON.stringify(dictJson.pure.phonics);
                        else
                            spellManager.phonics = "";
                        return sResult
                    }
                    else if (typeof dictJson.pure.word != "undefined") {
                        let mArray = dictJson.pure.word.trs
                        mArray.forEach(function(mean){
                            if (typeof mean.pos !== "undefined") {
                                sResult += ('<span style="font-family: %1; font-style: italic; color: %2; font-size: 24px">').arg(fontManager.fontFamilyClass).arg(YColors.grayText)
                                        + mean.pos + '</span>' + '<span>&nbsp;</span>'
                            }

                            if (typeof mean.tran !== "undefined") {
                                sResult += '<span style="font-family: OPPOSans; font-weight: 500; '
                                        + ('color: %1; font-size: 28px">').arg(YColors.white) + mean.tran + '</span>'
                                        + '<span>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span>'
                            }

                            if (typeof mean["#text"] !== "undefined") {
                                sResult += '<span style="font-family: Nunito Sans; '
                                        + (' color: %1; font-size: 28px">').arg(YColors.white) + mean["#text"] + '</span>'
                                        + '<span>&nbsp;</span>'
                            }

                            if (typeof mean["#tran"] !== "undefined") {
                                sResult += '<span style="font-family: OPPOSans; font-weight: 500; '
                                        + ('color: %1; font-size: 28px">').arg(YColors.white) + mean["#tran"] + '</span>'
                                        + '<span>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span>'
                            }
                        })

                        spellManager.phonics = "";
                        return sResult
                    }
                }
            }

            readonly property bool haveExample: typeof dictJson.example != "undefined" && dictType !== YEnum.DtEnChKid

            Column {
                width: parent.width
                spacing: 0
                visible: id_dict_content_column.haveExample


                YTextBase {
                    font.pixelSize: 26
                    font.family: fontManager.fontFamily
                    color: YColors.red
                    width: parent.width
                    height: 42
                    verticalAlignment: YTextBase.AlignBottom
                    text: YTranslateText.bilingualSentences
                    visible: id_dict_content_column.haveExample
                    Component.onCompleted: {
                        dictNodeCompleted(text, dictType, 1, this);
                    }
                }

                YSpacingForColumn {
                    implicitHeight: 12
                }

                YTextBase {
                    font.family: fontManager.fontFamilyEnUs
                    font.pixelSize: 28
                    textFormat: YTextBase.RichText
                    color: "#FFFFFF"
                    width: parent.width
                    height: paintedHeight
                    text: {
                        if (!visible) return ""
                        console.log("seven:DtSimple:",JSON.stringify(dictJson))
                        let sentpair = dictJson.example["sentence-pair"][0]
                        let qsRst = sentpair["sentence-eng"]
                        qsRst = qsRst.replace(/<b>/g,'')
                        qsRst = qsRst.replace(/<\/b>/g,'')
                        const regEx = new RegExp(regExpEscape(resultManager.currentQuery), "ig")
                        qsRst = qsRst.replace(regEx, function(param){
                            console.log("seven:DtSimple:replace",param)
                            return ("<font style='color:%2;font-family:%3;font-weight:500;font-size:28px;'>%1</font>").arg(param).arg(YColors.red).arg(fontManager.fontFamilyEnUs);
                        });
                        console.log("seven:DtSimple:replace",qsRst)
                        return qsRst
                    }
                    wrapMode: YTextMedium.Wrap
                    visible: id_dict_content_column.haveExample
                }

                YSpacingForColumn {
                    implicitHeight: 10
                }

                YText {
                    font.family: fontManager.fontFamilyZhCn
                    textFormat: YTextBase.RichText
                    wrapMode: YTextBase.Wrap
                    color: YColors.grayText
                    width: parent.width
                    height: paintedHeight
                    text: {
                        if (!visible) return ""
                        let sentpair = dictJson.example["sentence-pair"][0]
                        let qsRst = sentpair["sentence-translation"]
                        if (typeof sentpair.source != "undefined") {
                            qsRst += '<span style="color:#90919999;font-size:24px;">（'
                                    + YTranslateText.exampleSentencesFrom + sentpair["source"] + '）</span>'
                        }
                        return qsRst
                    }
                    visible: id_dict_content_column.haveExample
                }
            }

            //单词变形
            YTextBase {
                font.pixelSize: 26
                color: YColors.red
                anchors.left: parent.left
                anchors.right: parent.right
                width: textContenWidth
                height:  34
                //topPadding: 10
                text: YTranslateText.wordsInflection
                visible: id_anagram_wfs_repeater.count > 0
                Component.onCompleted: {
                    dictNodeCompleted(text, dictType, 1, this);
                }
            }

            Column {
                width: id_dict_content_column.width
                spacing: 10
                Repeater {
                    id: id_anagram_wfs_repeater
                    model:
                        //(typeof dictJson.anagram != "undefined" && typeof dictJson.anagram.wfs != "undefined") ? dictJson.anagram.wfs : null
                    {
                        let result = new Array
                         if(typeof dictJson.pure.word.wfs != "undefined") {
                             return dictJson.pure.word.wfs
                         }else {
                             return null
                         }
//                        if(typeof dictJson.pure.word.wfs != "undefined" &&typeof dictJson.pure.word.wfs.third_person_singular != "undefined")
//                            result.push({"key":YTranslateText.thirdPersonSingular,"value":dictJson.pure.tenses.third_person_singular.split("或")})
//                        if(typeof dictJson.pure.word.wfs != "undefined" &&typeof dictJson.pure.tenses.present_participle != "undefined")
//                            result.push({"key":YTranslateText.presentParticiple,"value":dictJson.pure.tenses.present_participle.split("或")})
//                        if(typeof dictJson.pure.word.wfs != "undefined" &&typeof dictJson.pure.tenses.past != "undefined")
//                            result.push({"key":YTranslateText.past,"value":dictJson.pure.tenses.past.split("或")})
//                        if(typeof dictJson.pure.word.wfs != "undefined" &&typeof dictJson.pure.tenses.past_participle != "undefined")
//                            result.push({"key":YTranslateText.pastParticiple,"value":dictJson.pure.tenses.past_participle.split("或")})
//                        return result
                    }
                    Item {
                        id: id_anagram_wfs_item
                        width: parent.width
                        height:  id_words_inflection.height

                        readonly property var modelModelData: model.modelData
                        YTextBase {
                            id: id_wordsInflection_key
                            width: id_wordsInflection_key.contentWidth
                            height: id_wordsInflection_key.contentHeight
                            font.pixelSize: 28
                            font.family: fontManager.fontFamilyZhCn
                            color: YColors.grayText
                            text: model.modelData.wf.name+":"
                        }

                        Flow{
                            //height:
                            id:id_words_inflection
                            width: {
                                598  - id_wordsInflection_key.width
//                                switch (model.modelData.key){
//                                case YTranslateText.thirdPersonSingular:
//                                    return 598
//                                case YTranslateText.presentParticiple:
//                                    return 582
//                                case YTranslateText.past:
//                                    return 610
//                                case YTranslateText.pastParticiple:
//                                    return 582
//                                }
                            }
                            //height: id_wordsInflection_value.height
                            anchors.left: id_wordsInflection_key.right
                            anchors.leftMargin: 10
                            property var repeatModel: model.modelData.wf.value.split("或")
                            spacing:0
                            //readonly property var modelModelData: model.modelData
                            Repeater{
                                id:id_words_inflection_repeter
                                model: id_words_inflection.repeatModel
                                YDictPageClickSearchTextItem{
                                    word:model.modelData
                                    isCHType: false
                                    onClicked: {
                                        id_dict_page.clickSearchWord(model.modelData)
                                        //id_dict_page.requeryWord(model.modelData, "en", "zh-CHS")
                                    }
                                }
                            }
                        }

//                        YMouseArea{
//                            width: id_wordsInflection_value.width
//                            height: id_wordsInflection_value.height
//                            anchors.left: id_wordsInflection_key.right
//                            anchors.leftMargin: 10
//                            YTextBase {
//                                id: id_wordsInflection_value
//                                anchors.left: parent.left
//                                anchors.top: parent.top
//                                width: {
//                                     switch (model.modelData.key){
//                                     case YTranslateText.thirdPersonSingular:
//                                         return 526
//                                     case YTranslateText.presentParticiple:
//                                         return 582
//                                     case YTranslateText.past:
//                                         return 610
//                                     case YTranslateText.pastParticiple:
//                                         return 582
//                                     }
//                                }
//                                height: contentHeight
//                                font.pixelSize: 28
//                                font.family: fontManager.fontFamily
//                                color: YColors.blueText
//                                wrapMode: Text.Wrap
//                                font.bold: true
//                                text: model.modelData.value
//                            }
//                            onClicked: {
//                                id_dict_page.clickSearchWord(model.modelData.value)
//                                    //id_dict_page.requeryWord(model.modelData, "en", "zh-CHS")
//                            }
//                        }


                    }
                }
            }



        }
    }
}

/*
  // explosive
{
    "example":{
        "sentence-pair":[
            {
                "sentence-eng":"The &lt;b&gt;explosive&lt;/b&gt; device was timed to go off at the rush hour.",
                "sentence-translation":"该爆炸装置定在交通高峰时间爆炸。",
                "source":"《柯林斯英汉双解大词典》"
            }
        ]
    },
    "pure":{
        "m":[
            {
                "m":"爆炸的；爆炸性的；爆发性的",
                "pos":"adj."
            },
            {
                "m":"炸药；爆炸物",
                "pos":"n."
            }
        ],
        "uk":"ɪkˈspləʊsɪv; ɪkˈspləʊzɪv",
        "us":"ɪkˈsploʊsɪv,ɪkˈsploʊzɪv"
    }
}
  */


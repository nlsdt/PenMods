import QtQuick 2.12

import BaseQml 1.0

YDictTypeBase {
     id: id_dict_type_enko

    Column {
        id: id_dict_content_column_enko
        width: parent.width
        spacing: 16
        anchors.left: parent.left
        anchors.right: parent.right

        YTextMedium {
            id: id_dict_enko_content
            font.pixelSize: 28
            wrapMode: YText.Wrap
            textFormat: YTextBase.RichText
            width: parent.width
            height: paintedHeight

            text: {
                let sResult = ''
                let dictJson = null;
                dictJson = JSON.parse(content)
                if(typeof dictJson.eh.trs != "undefined"){
                    let mArray = dictJson.eh.trs
                    mArray.forEach(function(mean){
                        if (typeof mean.pos !== "undefined") {
                            sResult += ('<span style="font-family: %1; font-style: italic; font-weight: 400;').arg(fontManager.fontFamilyClass)
                                    + 'color: #909199; font-size: 28px">' + mean.pos + '</span>'
                                    + '<span>&nbsp;</span>'
                        }

                        sResult += '<span style="font-family: Noto Sans KR; font-weight: 400;'
                                + 'color: #FFFFFF; font-size: 28px">' + mean.tran + '</span>'
                                + '<span>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span>'
                                + '<br>'
                    })
                }

                let _sResult = sResult.substring(0,sResult.length - 4)
                return _sResult
            }
        }

        readonly property bool haveExampleType: typeof dictJson.exam_type["types"][0] != "undefined"
        YTextBase {
            font.family: fontManager.fontFamilyEnUs
            font.pixelSize: 26
            wrapMode: YTextBase.Wrap
            color: "#909199"
            width: parent.width
            height: paintedHeight
            text: {
                if (!visible) return ""

                let mArray = dictJson.exam_type["types"]
                let sResult = ''
                for(var i = 0;i < mArray.length;i++)
                {
                    sResult += dictJson.exam_type["types"][i];
                    sResult += '/'
                }

                let _sResult = sResult.substring(0,sResult.length - 1)
                return _sResult
            }
            visible: haveExampleType
        }


        YTextMedium {
            id: id_dict_enko_inflection
            font.pixelSize: 28
            wrapMode: YText.Wrap
            //height: id_dict_enko_content.contentHeight
            textFormat: YTextBase.RichText
            width: parent.width
            height: paintedHeight
            text: {
                let sResult = ''
                let dictJson = null;
                dictJson = JSON.parse(content)
                if(typeof dictJson.inflection.inflections != "undefined"){
                    let mArray = dictJson.inflection.inflections
                    mArray.forEach(function(mean){
                        if (typeof mean.name !== "undefined") {
                            sResult += ('<span style="font-family: %1; font-style: italic;').arg(fontManager.fontFamilyClass)
                                    + ' color: #909199; font-size: 24px">' + mean.name + '</span>'
                                    + '<span>&nbsp;</span>'
                        }

                        sResult += '<span style="font-family: Nunito Sans; font-weight: 400;'
                                + 'color: #FFFFFF; font-size: 28px">' + mean.value + '</span>'
                                + '<span>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span>'
                                + '<br>'
                    })
                }

                let _sResult = sResult.substring(0,sResult.length - 4)
                return _sResult
            }
        }// YTextMedium


        YTextMedium {
            id: id_dict_enko_sentence
            font.pixelSize: 28
            wrapMode: YText.Wrap
            //height: id_dict_enko_content.contentHeight
            textFormat: YTextBase.RichText
            width: parent.width
            height: paintedHeight
            text: {
                let sResult = ''
                let dictJson = null;
                dictJson = JSON.parse(content)
                if(typeof dictJson.auth_sents_part.sent != "undefined"){
                    let mArray = dictJson.auth_sents_part.sent
                    mArray.forEach(function(mean){

                        if (typeof mean.foreign !== "undefined") {
                            sResult += ('<span style="font-family: %1; font-style: italic;').arg(fontManager.fontFamilyClass)
                                    + ' color: #909199; font-size: 28px">' + 'e.g' + '</span>'
                                    + '<span>&nbsp;</span>'

                            sResult += '<span style="font-family: Nunito Sans; font-weight: 400;'
                                    + 'color: #FFFFFF; font-size: 28px">' + mean.foreign + '</span>'
                                    + '<span>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span>'
                                    + '<br>'
                        }

                    })
                }//if

                let _sResult = sResult.substring(0,sResult.length - 4)
                return _sResult
            }
        }// YTextMedium

    }// Column

}// YDictTypeBase

/*
{
    "exam_type": {
        "types": ["Top 4500", "Middle School"]
    },
    "eh": {
        "usphone": "klaʊd",
        "ukphone": "klaʊd",
        "trs": [{
            "pos": "n.",
            "tran": "구름; 먼지; 수많은 사람; 흐림; 부드러운 스카프;"
        }, {
            "pos": "v.",
            "tran": "구름으로 덮다; 흐리게 하다; 더럽히다; 애매하게 만들다; 구름 무늬로 아로새기다; 검은 반점으로 아로새기다;"
        }, {
            "pos": "-",
            "tran": "(먼지 연기 등의) 덩어리;"
        }],
        "return-phrase": "cloud"
    },
    "auth_sents_part": {
        "sentence-count": 1,
        "sent": [{
            "foreign": "<b>Cloud</b> workforces: work at home, crowdsourced labor: Along with all-<b>cloud</b> businesses, there will be more <b>cloud</b>-based workforces. "
        }]
    },
    "inflection": {
        "inflections": [{
            "name": "pl.",
            "value": "clouds"
        }, {
            "name": "pa. t.",
            "value": "clouded"
        }, {
            "name": "pa. pple.",
            "value": "clouded"
        }, {
            "name": "pr. pple.",
            "value": "clouding"
        }, {
            "name": "tps.",
            "value": "clouds"
        }]
    }
}
*/

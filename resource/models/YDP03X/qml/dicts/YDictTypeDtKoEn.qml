import QtQuick 2.12

import BaseQml 1.0

YDictTypeBase {
    id: id_dict_type_koen

    Column {
        id: id_dict_content_column_enko
        width: parent.width
        spacing: 16
        anchors.left: parent.left
        anchors.right: parent.right

        YTextMedium {
            id: id_dict_koen_content
            font.pixelSize: 28
            wrapMode: YText.Wrap
            textFormat: YTextBase.RichText
            width: parent.width
            height: paintedHeight
            text: {
                let sResult = ''
                let dictJson = null;
                dictJson = JSON.parse(content)
                if(typeof dictJson.he.trans != "undefined"){
                    let mArray = dictJson.he.trans
                    mArray.forEach(function(mean){
                        if (typeof mean.type !== "undefined") {
                            sResult += '<span style="font-family: OPPOSans; font-style: normal; font-weight: 500;'
                                    + 'color: #509DEB; font-size: 28px">' + mean.w + '</span>'
                                    + '<br>'
                        }

                        sResult += '<span style="font-family: Noto Sans KR; font-weight: 500;'
                                + 'color: #FFFFFF; font-size: 28px">' + mean.trans + '</span>'
                                + '<span>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span>'
                                + '<br>'
                    })
                }

                let _sResult = sResult.substring(0,sResult.length - 4)
                return _sResult
            }
        }

    } // Column
} // YDictTypeBase

/*
{
    "he": {
        "return-phrase": {
            "query-roman": "Neo",
            "word": "너"
        },
        "word": "너",
        "trans": [{
            "w": "you",
            "type": "n.",
            "trans": "너; 여러분; 당신; 당신들; 네; 너희; 너희들; 자네;"
        }, {
            "w": "laddie",
            "type": "n.",
            "trans": "젊은이; 친밀감을 가지고 젊은이; 너; 남자애;"
        }, {
            "w": "four",
            "type": "n.",
            "trans": "사; 네; 넷; 네개 한 벌; 네열 종대; 네푼 이자 공채; 네절판; 너;"
        }, {
            "w": "u",
            "type": "pron.",
            "trans": "유; 유 자형; 유 자형의 것; 제이십일번째; 제이십일번째의 것; 상류 사회의 사람; 너;"
        }]
    }
}
*/

import QtQuick 2.12

import BaseQml 1.0
import "../i18n"

Column {
    property var dictJson: id_dict_detail_page.dictJson

    spacing: 0


    YDictTypeDtChPoemDataGuide {
        width: parent.width
        jsonPoemData: {
            if(typeof dictJson.poems !== "undefined") {
            id_dict_detail_page.title =  YTranslateText.ancientPoemsReading +  " - " +
             dictJson.poems[0].detail.title.origin
            }
            //不要删下面日志
            console.log(" id_dict_detail_page.title :" + JSON.stringify(id_dict_detail_page.title))
            return typeof dictJson.poems == "undefined" ? null : dictJson.poems[0]
        }
        authorIntro: (typeof dictJson.authors == "undefined" || dictJson.authors.length <= 0) ? "" : dictJson.authors[0].author.intro
    }

//    YDictTypeDtChPoemData {
//        width: parent.width
//        jsonPoemData: typeof dictJson.poems == "undefined" ? null : dictJson.poems[0]
//        authorIntro: (typeof dictJson.authors == "undefined" || dictJson.authors.length <= 0) ? "" : dictJson.authors[0].author.intro
//    }
}


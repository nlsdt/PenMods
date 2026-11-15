import QtQuick 2.12
import QtQuick.XmlListModel 2.14
import com.youdao.pen 1.0
import BaseQml 1.0
import "../i18n"
import "../../qml/timers"
import "../components"

YText {
    id: id_mean_text
    width: visible ? (Math.min(id_meanings_repeater.contentWidth, paintedWidth)) : 0
    font.family: fontManager.fontFamilyXinHuaXiHei
    verticalAlignment: Text.AlignTop
    font.pixelSize: 28
    lineHeightMode:  Text.FixedHeight
    lineHeight: 37
    color: YColors.white
    wrapMode:  YText.NoWrap
    textFormat: YText.RichText
    Component.onCompleted: {
        if(paintedWidth > id_meanings_repeater.contentWidth) {
            width = id_meanings_repeater.contentWidth
            wrapMode = YText.WordWrap
        }
        else {
            width = paintedWidth
            wrapMode = YText.NoWrap
        }
    }

    property var dataJson: id_mean_column.curDataJson

    function getText() {
        //test
//        let temp = "iVBORw0KGgoAAAANSUhEUgAAABoAAAAiCAYAAABBY8kOAAAACXBIWXMAAAsTAAALEwEAmpwYAAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAAEPSURBVHgB7ZS9agJBFEa/DekigaRIZWGRP9KlFkKalCGQF0iTZwl5gRSp0uUBQtRnsBHBzkZkESz8ewBhPOKAIIKzMzsWsgcOA7PL/bh7lysVHATGmF98UGwISbGPZ/Lk2PG9OX4nSTKVJ0faE1mCEgXgGrT8dCcKwDVohiUF4Bo0xFMFkKWjvcxorEBcg1IsKwDXoAHeKjasnmuz4lyeuHY0seeNPHEKYseNONpYlSdZVtA/Pis2zOfRzulCsSGkhR+KDSHvOMXLLc+qeK+8oFgHm1jauP/EO+UFxa5sV18b939YUZ5Q8BVn2MCyvUtzD7KFn2zxHv7YP7KiGCwLY82seVNMCHjBOnZVULCLBWmAtkdV6QfOAAAAAElFTkSuQmCC"
//        id_word_mean_flow.firstMean ="汉字的一种笔形（乛"+ '<img align="top" src="data:image/png;base64,%1"></img>'.arg(temp) + "乚等）。"
//                return ""
        let tempText = ""
        if(dictSelectParaphrasesJsonObject.constructor === Object)
        {
            //let mentionPos = dataJson.释义.释义data.search(/(-.*?)/g)
            id_word_mean_flow.showCircleRectangle = false
            id_word_mean_flow.nextMean = ""
            //见条

            //释义data - 变红
            let dataMeanTemp = ((typeof dataJson["释义"] !== "undefined" &&
                                typeof dataJson["释义"]["释义data"] !== "undefined") ?
                    dataJson["释义"]["释义data"].replace(/\s*/g,"").replace(/\-/g,'<font color="%1">-</font>'.arg(YColors.red)) : '').trim()
            tempText  =  ((typeof dataJson["语体"] !== "undefined" &&
                           typeof dataJson["语体"]["语体data"] !== "undefined") ?
                              dataJson["语体"]["语体data"].replace(/\s*/g,"") : '')
                    + (dataMeanTemp) + id_dict_type_ch_ancientword.getMeanRichText(((typeof dataJson["例证"] !== "undefined" &&
                                                                                     typeof dataJson["例证"]["例证data"] !== "undefined") ?
                                                                                    ((dataMeanTemp[dataMeanTemp.length-1] !== ":" ||
                                                                                             dataMeanTemp[dataMeanTemp.length-1] !== "：" ? "：":"")+  dataJson["例证"]["例证data"]) : ''))

        } else {

            try {
                //语体data
                try {
                    tempText = (id_mean_column.curDataJson.语体.语体data.replace(/\s*/g,""))
                } catch(e) {}

                id_word_mean_flow.showCircleRectangle = id_mean_column.curDataJson.释义.注.类型.meanMentionType.length && id_mean_column.curDataJson.释义.注.类型.meanMentionType.trim() === "连一"
                let mentionFirstDataPos = id_mean_column.curDataJson.释义.释义data.indexOf(id_mean_column.curDataJson["释义"]["注"]['meanMention'])
                let mentionFirstDataMarkPos = id_mean_column.curDataJson.释义.释义data.indexOf("(",mentionFirstDataPos)
                if(mentionFirstDataMarkPos !== -1 && id_word_mean_flow.showCircleRectangle) {

                    tempText  +=  /*id_dict_type_ch_ancientword.getMeanRichText*/(id_mean_column.curDataJson.释义.释义data.substr(0,mentionFirstDataMarkPos).replace(/\s*/g,"")) +"   ( "
                    id_word_mean_flow.nextMean = id_mean_column.curDataJson.释义.释义data.substr(mentionFirstDataMarkPos+1).replace(/\s*/g,"")
                } else {
                    tempText +=  id_mean_column.curDataJson.释义.释义data.substr(0,mentionFirstDataPos).replace(/\s*/g,"")
                    id_word_mean_flow.nextMean = id_mean_column.curDataJson.释义.释义data.substr(mentionFirstDataPos).replace(/\s*/g,"")
                }



                id_word_mean_flow.nextMean = id_word_mean_flow.nextMean  + (((typeof id_mean_column.curDataJson["例证"] !== "undefined" &&
                                                                              typeof id_mean_column.curDataJson["例证"]["例证data"] !== "undefined") ?
                                                                                 id_mean_column.curDataJson["例证"]["例证data"].replace(/\s*/g,"") : ''))
            } catch (e) {
                id_word_mean_flow.nextMean = ""
                try{
                    tempText  =   ((typeof dataJson["语体"] !== "undefined" &&
                                    typeof dataJson["语体"]["语体data"] !== "undefined") ?
                                       dataJson["语体"]["语体data"].replace(/\s*/g,"") : '') +
                            ((typeof id_mean_column.curDataJson["释义"] !== "undefined" &&
                              typeof id_mean_column.curDataJson["释义"]["释义data"] !== "undefined") ?
                                 id_mean_column.curDataJson["释义"]["释义data"].replace(/\s*/g,"") : '') + id_dict_type_ch_ancientword.getMeanRichText(((typeof id_mean_column.curDataJson["例证"] !== "undefined" &&
                                                                                                                                                     typeof id_mean_column.curDataJson["例证"]["例证data"] !== "undefined") ?
                                                                                                                                                        id_mean_column.curDataJson["例证"]["例证data"].replace(/\s*/g,"") : ''))
                }catch(e) {
                }
            }

        }
        //                                        if(typeof id_mean_column.curDataJson.释义 !== "undefined") {
        //                                         if (typeof  id_mean_column.curDataJson["释义"]["注"] !== "undefined") {
        //                                         }
        //                                        }

        //return "ewte(-盛、兴-)"
        //            //释义/SUB 使用下
        if(tempText !== id_word_mean_flow.firstMean) {
            id_word_mean_flow.firstMean = tempText.replace(/:/g,"：").replace(/,/g,"，")
            try {
                if(id_mean_column.curDataJson["释义"]["SUB"]["SUBData"].length) {
                    let rawText = id_mean_column.curDataJson.释义.释义data
                    tempText = rawText.replace(id_mean_column.curDataJson["释义"]["SUB"]["SUBData"],'<sub style="line-height:29px;font-size:22px">%1</sub>'.arg(id_mean_column.curDataJson["释义"]["SUB"]["SUBData"]))
                }
                if(typeof tempText !== "undefined" && tempText.length) {
                    id_word_mean_flow.firstMean = tempText
                }
            } catch (e) {}

            try {
                if(id_mean_column.curDataJson["释义"]["SUP"]["SUPData"].length) {
                    let rawText = id_mean_column.curDataJson.释义.释义data
                    tempText = rawText.replace(id_mean_column.curDataJson["释义"]["SUP"]["SUPData"],'<sup style="font-size:22px">%1</sup>'.arg(id_mean_column.curDataJson["释义"]["SUP"]["SUPData"]))
                }
                if(typeof tempText !== "undefined" && tempText.length) {
                    id_word_mean_flow.firstMean = tempText
                }
            } catch (e) {}
        }

    }

    onDataJsonChanged: {
        getText()
    }

    onTextChanged: {
        if(paintedWidth > id_meanings_repeater.contentWidth) {
            width = id_meanings_repeater.contentWidth
            wrapMode = YText.WordWrap
        }
        else {
            width = paintedWidth
            wrapMode = YText.NoWrap
        }
    }

    text: {
        return  id_word_mean_flow.firstMean
    }
    visible: text.length
}






import QtQuick 2.12
import QtQuick.XmlListModel 2.14
import com.youdao.pen 1.0
import BaseQml 1.0
import "../i18n"
import "../../qml/timers"
import "../components"

Repeater {
    id: id_word_rectangle_repeater
    property var queryData: ""
    property var contentWidth: 538
    property var modelList: []
    model: modelList

    YLoader {
        active: id_word_rectangle_repeater.count
        asynchronous: false
        sourceComponent: id_word_rectangle_component
    }

    Component {
        id: id_word_rectangle_component
        Item {
            id: id_word_rectangle_item
            width: id_word_rectangle.width
            height: id_word_rectangle_column.height/* +  (index !== 0 && JSON.stringify(id_word_rectangle_item.modelModelData).length  ? 8 : 0)*/
            property var modelModelData: model.modelData

            Column {
                id: id_word_rectangle_column
                anchors.left: parent.left
                //anchors.right: parent.right

                YSpacingForColumn{
                    height: {
                        return index!==0 && JSON.stringify(id_word_rectangle_item.modelModelData).length ? 8 : 0
                    }
                }

                //词组
                Rectangle {
                    id: id_word_rectangle
                    anchors.left: parent.left
                    width: contentWidth
                    color: YColors.grayNormal
                    height: id_word_column.height +  + id_word_column.anchors.topMargin * 2
                    radius: 16
                    property var curWordIndex: index
                    property var curWordJson: {
                        let temp = ({})
                        let tempTextData = null
                        try {
                            if(typeof id_word_rectangle_item.modelModelData.词条 !== "undefined") {
                                if ( typeof  temp["词目"] === "undefined")
                                    temp["词目"] = {}
                                if ( typeof  temp["词目"]["词条"] === "undefined")
                                    temp["词目"]["词条"]  = {}
                                if((id_word_rectangle_item.modelModelData.词条).constructor === Array) {
                                    temp["词目"]["词条"]["specialWord"] = {"specialWord":id_word_rectangle_item.modelModelData.词条}
                                }else {

                                    tempTextData = id_dict_type_ch_ancientword.getKeyOrText(id_word_rectangle_item.modelModelData.词条)
                                    if(tempTextData !== null) {
                                        temp["词目"]["词条"]["specialWord"] = {"specialWord":tempTextData}
                                    }
                                }
                            }
                        } catch(e) {}

                        try{
                            if(typeof id_word_rectangle_item.modelModelData.词条.idOffline !== "undefined") {
                                if ( typeof  temp["词目"] === "undefined")
                                    temp["词目"] = {}
                                if ( typeof  temp["词目"]["词条"] === "undefined")
                                    temp["词目"]["词条"]  = {}
                                if((id_word_rectangle_item.modelModelData.词条.idOffline).constructor === Array) {
                                    //temp["词目"]["词条"]["idOffline"] = {"idOffline":id_word_rectangle_item.modelModelData.词条.idOffline}
                                }else {
                                    tempTextData = id_dict_type_ch_ancientword.getKeyOrText(id_word_rectangle_item.modelModelData.词条.idOffline)
                                    if(tempTextData !== null) {
                                        temp["词目"]["词条"]["idOffline"] = {"idOffline":tempTextData}
                                    }
                                }
                            }
                        } catch(e) {}

                        try {
                            if(typeof id_word_rectangle_item.modelModelData.词条.pinyin !== "undefined") {
                                if ( typeof temp["词目"] === "undefined")
                                    temp["词目"] = {}
                                if ( typeof  temp["词目"]["词条"] === "undefined")
                                    temp["词目"]["词条"]  = {}
                                tempTextData = id_dict_type_ch_ancientword.getAllValueString(id_word_rectangle_item.modelModelData.词条.pinyin)
                                if(tempTextData !== null) {
                                    temp["词目"]["词条"]["specialWordPinYin"] = {"specialWordPinYin":tempTextData}
                                }

                            }
                        } catch(e) {}

                        try {
                            if(typeof id_word_rectangle_item.modelModelData.词形.异形词 !== "undefined") {
                                if ( typeof temp["词目"] === "undefined")
                                    temp["词目"] = {}
                                if ( typeof  temp["词目"]["词形"] === "undefined")
                                    temp["词目"]["词形"]  = {}
                                if ( typeof  temp["词目"]["词形"]["异形词"] === "undefined")
                                    temp["词目"]["词形"]["异形词"]  = {}
                                tempTextData = id_dict_type_ch_ancientword.getAllValueString(id_word_rectangle_item.modelModelData.词形.异形词)
                                if(tempTextData !== null) {
                                    temp["词目"]["词形"]["异形词"]["specialOldWord"] = {"specialOldWord":tempTextData}
                                }

                            }
                        } catch(e) {}

                        try {
                            if(typeof id_word_rectangle_item.modelModelData.释文.义项 !== "undefined") {
                                if ( typeof temp["词目"] === "undefined")
                                    temp["词目"] = {}
                                if ( typeof temp["词目"]["释文"] === "undefined")
                                    temp["词目"]["释文"]  = []
                                if((id_word_rectangle_item.modelModelData.释文.义项).constructor === Array)
                                    temp["词目"]["释文"] = id_word_rectangle_item.modelModelData.释文.义项
                                else {
                                    temp["词目"]["释文"].push(id_word_rectangle_item.modelModelData.释文.义项)

                                }
                            } } catch(e) {}
                        return temp

                    }

                    property var modeModelData: model.modelData
                    visible:  {
                        //test
                        //                    return true
                        return typeof id_word_rectangle.curWordJson["词目"] !== "undefined" && typeof id_word_rectangle.curWordJson["词目"]["词条"] !== "undefined" &&   typeof id_word_rectangle.curWordJson["词目"]["词条"]["specialWord"] !== "undefined"
                    }

                    Column {
                        id: id_word_column
                        anchors.left: parent.left
                        anchors.leftMargin:  20
                        anchors.right: parent.right
                        anchors.rightMargin: 20
                        anchors.top: parent.top
                        anchors.topMargin: 16

                        Row{
                            id: id_word_row
                            anchors.left: parent.left
                            anchors.right: parent.right

                            Flow {
                                anchors.top:parent.top
                                width: 498
                                Repeater {
                                    id: id_click_repeater
                                    model: {
                                        let temp = []
                                        try{
                                            if((id_word_rectangle.curWordJson["词目"]["词条"]["specialWord"].specialWord).constructor === Array) {
                                                temp = id_word_rectangle.curWordJson["词目"]["词条"]["specialWord"].specialWord
                                            } else {
                                                temp.push(id_word_rectangle.curWordJson["词目"]["词条"]["specialWord"].specialWord)
                                            }
                                        }catch(e) {
                                            if((id_word_rectangle.curWordJson["词目"]["词条"]["specialWord"].specialWord).constructor === Array) {
                                                temp = id_word_rectangle.curWordJson["词目"]["词条"]["specialWord"].specialWord
                                            } else {
                                                temp.push(id_word_rectangle.curWordJson["词目"]["词条"]["specialWord"].specialWord)
                                            }
                                        }
                                        return temp
                                    }

                                    Row {
                                        id: id_click_row
                                        YDictPageClickSearchTextItem{
                                            id: id_word_text
                                            visible: { //test
                                                //return true
                                                typeof id_word_rectangle.curWordJson["词目"] !== "undefined" && typeof id_word_rectangle.curWordJson["词目"]["词条"] !== "undefined" &&   typeof id_word_rectangle.curWordJson["词目"]["词条"]["specialWord"] !== "undefined"
                                            }
                                            property var noPinYinWord: ""
                                            property var modelModelData: model.modelData
                                            isAddSpace: false
                                            word: {
                                                //test
                                                //                                return "wordXinhua"
                                                let wordTemp = ""
                                                try {
                                                    if(inputIsArray(id_word_rectangle.curWordJson["词目"]["词条"]["specialWord"].specialWord)) {

                                                        wordTemp = id_dict_type_ch_ancientword.getKeyOrText(id_word_text.modelModelData)
                                                        id_word_text.noPinYinWord = wordTemp
                                                        try {
                                                            let pinyinTemp = id_dict_type_ch_ancientword.getKeyOrText(id_word_text.modelModelData.pinyin)
                                                            wordTemp += "  " + ((pinyinTemp !== null) ? pinyinTemp : "")
                                                        } catch(e){}

                                                    } else {
                                                        try {
                                                            if(typeof id_word_rectangle.curWordJson["词目"]["词条"]["specialWord"].specialWord === "string") {
                                                                wordTemp = id_word_rectangle.curWordJson["词目"]["词条"]["specialWord"].specialWord
                                                                id_word_text.noPinYinWord = wordTemp
                                                            }
                                                        } catch(e){}
                                                        try {
                                                            wordTemp += "  " + id_word_rectangle.curWordJson["词目"]["词条"]["specialWordPinYin"].specialWordPinYin
                                                        } catch(e){}

                                                    }

                                                } catch(e) {}
                                                return wordTemp
                                            }
                                            isCHType: true
                                            onClicked: {
                                                id_dict_page.clickSearchWord(id_word_text.noPinYinWord)
                                                //id_dict_page.requeryWord(model.modelData, "en", "zh-CHS")
                                            }
                                        }


                                        Item{
                                            width: 6
                                            height: 10
                                            visible: id_click_repeater.count
                                        }

                                        YAudioPlayIconLabelHCenterButton {
                                            height: 34
                                            color: YColors.transparent
                                            textItem.font.pixelSize: 26
                                            textItem.font.family: fontManager.fontFamilyXinHuaXiHei
                                            text: ''
                                            visible: {
                                                let temp = ""
                                                if(inputIsArray(id_word_rectangle.curWordJson["词目"]["词条"]["specialWord"].specialWord)) {
                                                    temp = id_word_text.modelModelData["idOffline"]
                                                } else {
                                                    try {
                                                        temp = id_word_rectangle.curWordJson["词目"]["词条"]["idOffline"].idOffline
                                                    } catch (e) {
                                                    }
                                                }
                                                return temp.length
                                            }/*id_word_text.visible*/
                                            width: 32/*(iconItem.visible ? iconItem.width : 0) + textItem.width*/

                                            onValidClicked: {
                                                let pinyinTemp = ""
                                                //TODO
                                                if(inputIsArray(id_word_rectangle.curWordJson["词目"]["词条"]["specialWord"].specialWord)) {
                                                    pinyinTemp = id_word_text.modelModelData["idOffline"]
                                                }
                                                else {
                                                    try {
                                                        if(typeof id_word_rectangle.curWordJson["词目"]["词条"]["idOffline"].idOffline === "string") {
                                                            pinyinTemp = id_word_rectangle.curWordJson["词目"]["词条"]["idOffline"].idOffline
                                                        }
                                                    } catch(e){}
                                                }
                                                var nAutoPronType =  YEnum.XinHua
                                                qmlGlobal.audioPlayId = soundCenter.play(id_word_text.noPinYinWord,
                                                                                         "zh",
                                                                                         pinyinTemp, nAutoPronType + 1)
                                            }
                                        }


                                        Item {
                                            width: 10
                                            height: 10
                                            visible: index !== id_click_repeater.count - 1
                                            //                            visible: index !== 0
                                        }
                                    }
                                }
                                //}


                                Item{
                                    width: 20
                                    height: 10
                                    visible: id_word_other_text.visible
                                }

                                YText {
                                    id: id_word_other_text
                                    font.family: fontManager.fontFamilyXinHuaXiHei
                                    //anchors.verticalCenter: parent.verticalCenter
                                    font.pixelSize: 26
                                    color: YColors.grayText
                                    visible: text.length
                                    text: {
                                        let wordTemp = ""
                                        try {
                                            if(id_word_rectangle.curWordJson["词目"]["词形"]["异形词"]["specialOldWord"].specialOldWord.length)
                                                wordTemp = "(*" + id_word_rectangle.curWordJson["词目"]["词形"]["异形词"]["specialOldWord"].specialOldWord.replace(/\s*/g,"") + ")"
                                        } catch(e){}
                                        return wordTemp.replace(/:/g,"：").replace(/,/g,"，")
                                    }
                                }
                            }
                        }

                        YSpacingForColumn {
                            height: 8
                            visible: id_word_means_repeater.count
                        }

                        //有多少义项
                        YDictTypeDtChXinHuaWordMeanComponent {
                            id: id_word_means_repeater
                            meanList: {
                                let temp = []
                                try {
                                    if((id_word_rectangle.curWordJson.词目.释文).constructor === Array)
                                        temp = id_word_rectangle.curWordJson.词目.释文
                                    else {
                                        temp.push(id_word_rectangle.curWordJson.词目.释文)
                                    }
                                } catch(e) {
                                }
                                return temp
                            }
                            queryMeanData: queryData + "["+(id_word_rectangle.curWordIndex+1)+"]/释文/义项"
                            contentWidth: 442
                        }
                    }
                }

            }
        }
    }
}

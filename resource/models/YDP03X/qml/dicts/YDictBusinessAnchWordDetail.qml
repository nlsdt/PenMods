import QtQuick 2.12
import com.youdao.pen 1.0

import BaseQml 1.0
import "../i18n"
Item {
    id: id_dt_busAnCh_Detail 
    height: id_dataList_column.height
    property var dictJson: id_dict_detail_page.dictJson
    
    function constructingDataModel(){
        var adjustJsonObj = {}
        if(dictJson.length === 1){
            dictJson.forEach(function(jsonObj){
                var t_jsonObj = jsonObj.字目
                if(t_jsonObj.字形 !== undefined) adjustJsonObj.字形 = t_jsonObj.字形
                adjustJsonObj.词目 = t_jsonObj.词目
                adjustJsonObj.字条 = t_jsonObj.字条
                adjustJsonObj.释义组 = [t_jsonObj.释义组]
            })
        }else {
            dictJson.forEach(function(jsonObj){
                console.log("==========chenfei=======:",typeof jsonObj.字目.释义组)
                if(jsonObj.字目.释义组.constructor === Array){
                    adjustJsonObj = jsonObj.字目
                }
            })
        }
        return adjustJsonObj
    }

    ListModel {
        id: id_bus_words_model
        function createWordsModel(){

        }
    }

    Column {
        id: id_dataList_column
        width: parent.width
        spacing: 0



        Repeater {
            id: id_dataList_repeater
            property int content_margins: 10
            // model: id_dt_busAnCh_Detail.words//[1,2,3]
            model: {

                var adjustJsonObj = constructingDataModel()
                var styleString = "<font color=\"red\">~</font>"
                var temp_words = []
                console.log("seven:resultManager.currentBusWord():1",resultManager.currentBusWord())
                adjustJsonObj.词目.forEach(function(paraphraseObj){
                    console.log("seven:resultManager.currentBusWord():2:",resultManager.currentBusWord(),"==",paraphraseObj.音项.汉语拼音.content,":",resultManager.currentBusWord() === paraphraseObj.音项.汉语拼音.content)

                    if(paraphraseObj.音项.汉语拼音.content === resultManager.currentBusWord() && paraphraseObj.词条 === id_dict_detail_page.title){
                        paraphraseObj.释文.义项.forEach(function(entryWordObj){
                            var temp_content = ""

                            if(entryWordObj.释义 !== undefined && entryWordObj.释义.constructor === String){
                                temp_content += entryWordObj.释义
                            }
                            if(entryWordObj.释义.content !== undefined){
                                if(entryWordObj.释义.content.constructor === String){
                                    if(entryWordObj.释义.注 !== undefined){
                                        temp_content += entryWordObj.释义.注
                                    }
                                    temp_content += entryWordObj.释义.content
                                }else{
                                    var contentJson_index = 0
                                    var infuses
                                    if(entryWordObj.释义.注 !== undefined){
                                        infuses = entryWordObj.释义.注
                                        if(infuses.constructor !== Array) infuses = [infuses]
                                    }
                                    entryWordObj.释义.content.forEach(function(contenString){
                                        temp_content += contenString
                                        if(entryWordObj.释义.LINK !== undefined && contentJson_index === 0){
                                            temp_content += entryWordObj.释义.LINK.content
                                        }
                                        if(entryWordObj.释义.注 !== undefined){
//                                            var infuses = entryWordObj.释义.注
//                                            if(infuses.constructor === Array) infuses = [infuses]
                                            if(contentJson_index < infuses.length){
                                                temp_content += infuses[contentJson_index]
                                            }
                                        }
                                        contentJson_index ++
                                    })
                                }
                            }


                            //注释
                            if(entryWordObj.释义.注释 !== undefined){
                                var annotationArray = entryWordObj.释义.注释
                                if(annotationArray.constructor !== Array) annotationArray = [annotationArray]
                                annotationArray.forEach(function(annJson){
                                    temp_content += (annJson.词条 + "，")
                                    temp_content += annJson.content
                                })
                            }

                            if(entryWordObj.释义.书证 !== undefined)
                                entryWordObj.释义.书证.forEach(function(docObj){
                                    if(docObj.constructor === String){
                                        temp_content += docObj
                                    }else{
                                        temp_content += docObj.content
                                    }

                                    if(docObj.注 !== undefined){
                                        temp_content += docObj.注
                                    }
                                })
                            //引
                            var expound = []
                            var temp_map  = {}
                            temp_map.content = temp_content.replace(/~/g,styleString)
                            temp_content = ""
                            if(entryWordObj.引申 !== undefined){
                                var exDocs = entryWordObj.引申
                                if(exDocs.constructor !== Array) exDocs = [exDocs]
                                exDocs.forEach(function(exDocObj){
                                    if(exDocObj.释义.constructor === String)
                                        temp_content += exDocObj.释义
                                    if(exDocObj.书证 !== undefined){
                                        var docs = exDocObj.书证
                                        if(docs.constructor !== Array) docs = [docs]
                                        docs.forEach(function(docJson){
//                                            var contents = docJson.content
//                                            if(contents.constructor !== Array) contents = [contents]
//                                            var key_index = 0
//                                            var keys = docJson.KEY
//                                            if(keys.constructor !== Array) keys = [keys]
//                                            contents.forEach(function(keyObj){
//                                                temp_content += keyObj
//                                                if(key_index < keys.length)
//                                                    for(var k_i = 0; k_i < keys[key_index].length;++k_i)
//                                                        temp_content += "~"//keys[key_index]
//                                                key_index ++
//                                            })
                                            temp_content += docJson.content
                                        })
                                    }
                                })
                                expound.push({"content" :temp_content.replace(/~/g,styleString), "tag" : "引"})
                            }

                            //又
                            temp_map.arr = expound
                            temp_words.push(temp_map)
                        })
                        
                    } 
                })
                return temp_words
            }
            Column{
                width: parent.width
                Rectangle {
                    id: id_doc_rectangle
                    width: parent.width
                    height:id_paraphrase_ytext.contentHeight + id_dataList_repeater.content_margins * 2
                    color: "black"
                    Rectangle {
                        anchors.left: parent.left
                        y: id_dataList_repeater.content_margins + 5
                        id: id_paraphrase_num
                        width:26
                        height: width
                        color: "white"
                        radius: width / 2

                        YText {
                            anchors.fill: parent
                            text: index +  1
                            color: YColors.black
                            font.pixelSize: 18
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment :Text.AlignVCenter
                        }
                    }

                    YText {
                        id: id_paraphrase_ytext
                        anchors.left: id_paraphrase_num.right
                        anchors.top: parent.top
                        anchors.right: parent.right
                        // font.family: fontManager.fontFamilyXinHuaXiHei
                        font.pixelSize: 30
                        wrapMode: YText.WordWrap
                        textFormat: Text.RichText
                        visible: text.length
                        anchors.leftMargin: 15
                        anchors.topMargin:id_dataList_repeater.content_margins
                        anchors.bottomMargin:id_dataList_repeater.content_margins
                        color: YColors.white
                        text: id_dataList_repeater.model[index].content//id_dt_busAnCh_Detail.words[index]//"身，身体。《诗经·大雅·烝民》"
                    }

                }

                Rectangle {
                    id: id_expound_rectangle
                    x: 40
                    width: parent.width - 40
                    height: id_doc_colum.height
                    color: "#1A1B1F"
                    radius : 16
                    property int content_margins: 10
                    Column {
                        id: id_doc_colum
                        anchors.left: parent.left
                        anchors.right: parent.right
                        spacing: 10
                        Repeater {
                            id: id_expound_repeater
                            model: id_dataList_repeater.model[index].arr//[1,2,3]
                            Rectangle {
                                width: parent.width
                                height: id_doc_edc_text.contentHeight + id_expound_rectangle.content_margins * 2
                                color: "transparent"
                                Rectangle {
                                    id: id_docedv_num
                                    x: 15
                                    y: id_expound_rectangle.content_margins + 5
                                    width: 26
                                    height: width
                                    radius : width / 2
                                    border.width: 1
                                    antialiasing: true
                                    border.color: "white"
                                    color: "#1A1B1F"
                                    YText {
                                        anchors.fill: parent
                                        text: id_expound_repeater.model[index].tag
                                        color: YColors.white
                                        font.pixelSize: 18
                                        horizontalAlignment: Text.AlignHCenter
                                        verticalAlignment :Text.AlignVCenter
                                    }
                                }

                                YText {
                                    id: id_doc_edc_text
                                    anchors.left: id_docedv_num.right
                                    anchors.top: parent.top
                                    anchors.right: parent.right
                                    font.pixelSize: 28
                                    wrapMode: YText.WordWrap
                                    textFormat: Text.RichText
                                    visible: text.length
                                    anchors.leftMargin: 15
                                    anchors.margins:id_expound_rectangle.content_margins
                                    color: YColors.white
                                    text: id_expound_repeater.model[index].content//"安乐，安逸。《左传·僖公四年》：“君非姬氏，居不～。” 《论语·学而》：“君子食无求饱，居无求～。"//id_doc_edc_repeat.model[index].content
                                }

                            }
                        }
                    }
                }
            }
            
        }

        YSpacingForColumn{
            height: 18
            visible: id_paraphrase_ytext.visible
        }

        YText {
            id: id_paraphrase_ytext
            anchors.left: parent.left
            anchors.right: parent.right
            // font.family: fontManager.fontFamilyXinHuaXiHei
            font.pixelSize: 28
            wrapMode: YText.WordWrap
            textFormat: Text.RichText
            visible: text.length
            color: YColors.white
            text:{
                var adjustJsonObj = constructingDataModel()
                var temp_content = ""
                adjustJsonObj.词目.forEach(function(paraphraseObj){
                    if(paraphraseObj.音项.汉语拼音.content === resultManager.currentBusWord() && paraphraseObj.词条 === id_dict_detail_page.title){
                        paraphraseObj.释文.义项.forEach(function(entryWordObj){

                            if(entryWordObj.参考 !== undefined){
                                temp_content += entryWordObj.参考.类型
                                temp_content += ("“" + entryWordObj.参考.词条 + "”" + "。")
                                entryWordObj.参考.书证.forEach(function(contentJson){
                                    temp_content += contentJson.content
                                    if(contentJson.注 !== undefined){
                                        temp_content += contentJson.注
                                    }

                                })
                            }

                        })

                    }
                })
                return temp_content
            }
        }
    }
}

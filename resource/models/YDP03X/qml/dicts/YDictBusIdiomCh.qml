import QtQuick 2.12
import QtQuick.XmlListModel 2.14
import com.youdao.pen 1.0
import BaseQml 1.0
import "../i18n"
import "../../qml/timers"
import "../components"
import "../commons"

YDictTypeBase {
    id: id_dict_type_ch_busIdiomch
    title: YTranslateText.dtBusIdiomCh 
    property var paraphrases : []

    function createContentHighlightKey(key){
        var temp_content = ""
        temp_content += "<a href="
        temp_content += key
        temp_content += ">"
        temp_content += "<font color=\"#509DEB\">"
        temp_content += key
        temp_content += "</font>"
        temp_content += "</a>"

        return temp_content
    }

    Column {
        id: id_paraphrase_column
        property int content_margins : 10

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
                var temp_content = ""
                dictJson.forEach(function(jsonObj){
                    if(jsonObj.条目.释文.释义 !== undefined){
                        var paraphrases  = jsonObj.条目.释文.释义
                        paraphrases.forEach(function(paraphrase){
                            if(paraphrase.注释 !== undefined){
                                var annotations = paraphrase.注释
                                if(annotations.constructor !== Array) annotations = [annotations]
                                annotations.forEach(function(contentJson){
                                    temp_content += contentJson.词条
                                    temp_content += "："
                                    temp_content += contentJson.content
                                })
                            }
                            if(paraphrase.content !== undefined)
                                temp_content += paraphrase.content
                        })

                    }
                })
                return temp_content
            }
        }

        YSpacingForColumn{
            height: 18
            visible: id_paraphrase_ytext.visible
        }

        Repeater{
            id: id_paraphrase_repeater
            model: {
                var temp_paraphrases = []
                dictJson.forEach(function(jsonObj){
//                    var temp_arr = []
                    var temp_annotation_content = ""
                    //注释
                    if(jsonObj.条目.释文.注释 !== undefined){
                        var annotations = jsonObj.条目.释文.注释
                        if(annotations.constructor !== Array) annotations = [annotations]
                        annotations.forEach(function(annotationObj){
                            temp_annotation_content += annotationObj.词条
                            temp_annotation_content += "："
                            temp_annotation_content += annotationObj.content
                        })

                    }
                    console.log("seven:成语:注释:")
                    //释义
                    jsonObj.条目.释文.义项.forEach(function(rootJson){
//                        var rootJson = jsonObj.条目.释文.义项[0]
                        var temp_content = ""
                        var temp_arr = []
                        rootJson.释义.forEach(function(phsObj){
                            if(phsObj.注释 !== undefined){
                                phsObj.注释.forEach(function(annObj){
                                    temp_content += annObj.词条
                                    temp_content += "："
                                    temp_content += annObj.content
                                })
                            }

                            if(phsObj.出处 !== undefined){
                                var fromDoc = phsObj.出处
                                if(fromDoc.constructor === Array){
                                    fromDoc.forEach(function(fromObj){
                                        temp_content += fromObj
                                    })
                                }else if(fromDoc.constructor === String){
                                    temp_content += fromDoc
                                }else {
                                    temp_content += fromDoc.content
                                    if(fromDoc.注释 !== undefined){
                                        if(fromDoc.注释.constructor ===String)
                                            temp_content += fromDoc.注释
                                        else{
                                            temp_content += fromDoc.注释.词条
                                            temp_content += "："
                                            temp_content += fromDoc.注释.content
                                        }
                                    }
                                }

                            }

                            if(phsObj.content !== undefined)
                                temp_content += phsObj.content

                            if(phsObj.参考 !== undefined){
                                temp_content += phsObj.参考.类型
                                temp_content += ("“" + createContentHighlightKey(phsObj.参考.词条) + "”")
                            }

                        })
                        console.log("seven:成语:释义:")
                        //书证
                        if(rootJson.书证){
                            rootJson.书证.forEach(function(docObj){
                                var temp_doc_content = ""
                                temp_doc_content += docObj.content
                                if(docObj.注释 !== undefined){
                                    if(docObj.注释.constructor === String){
                                        temp_doc_content += docObj.注释
                                    }else{
                                        temp_doc_content += docObj.注释.词条
                                        temp_doc_content += "："
                                        temp_doc_content += docObj.注释.content
                                    }
                                }

                                temp_arr.push(temp_doc_content)

                            })
                        }
                        console.log("seven:成语:书证:")
                        temp_paraphrases.push({"content":temp_annotation_content + temp_content,"arr":temp_arr})
                        temp_annotation_content = "" //注释只是在头部出现，所以 条目技术要清理

                        console.log("seven:references0:")
                        if(rootJson.参考 !== undefined){
                            console.log("seven:references1:")
                            var references = rootJson.参考
                            if(references.constructor !== Array) references = [references]
                            console.log("seven:references2:",references)
                            references.forEach(function(docObj){
                                temp_content = ""
                                temp_arr = []
                                var wordRecord = docObj.词条
                                temp_content += docObj.类型
                                temp_content +=("“" + createContentHighlightKey(wordRecord) + "”")
                                if(docObj.书证 !== undefined){
                                    docObj.书证.forEach(function(bookObj){
                                        var temp_doc_content = ""
                                        if(bookObj.注释 !== undefined){
                                            temp_doc_content += bookObj.注释.词条
                                            temp_doc_content += "："
                                            temp_doc_content += bookObj.注释.content
                                        }
                                        temp_doc_content += bookObj.content
                                        temp_arr.push(temp_doc_content)
                                    })
                                }
                                temp_paraphrases.push({"content":temp_content,"arr":temp_arr})
                            })
                        }
                    })

                })
                return temp_paraphrases
            }
            Column {
                width: parent.width
                Rectangle {
                    id: id_paraphrase_rectangle
                    width: parent.width
                    height: id_paraphrase_ytext.contentHeight + id_paraphrase_column.content_margins * 2
                    color: "black"
                    Rectangle {
                        id: id_paraphrase_num
                        anchors.left: parent.left
                        y: 0 + id_paraphrase_column.content_margins + 5
                        width: 26
                        height: width
                        radius : width / 2
                        color: "#FFFFFF"

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
                        font.pixelSize: 28
                        wrapMode: YText.WordWrap
                        textFormat: Text.RichText
                        visible: text.length
                        anchors.leftMargin: 15
                        anchors.topMargin:id_paraphrase_column.content_margins
                        anchors.bottomMargin:id_paraphrase_column.content_margins
                        color: YColors.white
                        text: id_paraphrase_repeater.model[index].content
                        onLinkActivated : {
                            console.log("seven:linke:",link)
                            id_dict_page.clickSearchWord(link)
                        }
                    }

                }

                Repeater {
                    id: id_doc_repeater
                    model: id_paraphrase_repeater.model[index].arr//[1,2]
                    Rectangle{
                        id: id_doc_evi_rectangle
                        width: parent.width
                        height: id_doc_edv_ytext.contentHeight + id_paraphrase_column.content_margins * 2
                        color: "black"

                        YText {
                            id: id_doc_edv_num
                            x: 26 + 15
                            y: 0 + id_paraphrase_column.content_margins
                            text: index +  1 + "."
                            color: YColors.grayText
                            font.pixelSize: 26
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment :Text.AlignVCenter
                        }

                        YText {
                            id: id_doc_edv_ytext
                            anchors.left: id_doc_edv_num.right
                            anchors.top: parent.top
                            anchors.right: parent.right
                            // font.family: fontManager.fontFamilyXinHuaXiHei
                            font.pixelSize: 28
                            wrapMode: YText.WordWrap
                            textFormat: Text.RichText
                            visible: text.length
                            anchors.leftMargin: 15
                            anchors.topMargin:id_paraphrase_column.content_margins
                            anchors.bottomMargin:id_paraphrase_column.content_margins
                            color: YColors.white
                            text: id_doc_repeater.model[index]
                        }

                    }
                }
            }
            
        }

        YSpacingForColumn{
            height: 18
            visible: id_notice_ytext.visible
        }

        YText {
            id: id_notice_ytext
            anchors.left: parent.left
            anchors.right: parent.right
            // font.family: fontManager.fontFamilyXinHuaXiHei
            font.pixelSize: 28
            wrapMode: YText.WordWrap
            textFormat: Text.RichText
            visible: text.length
            color: YColors.white
            text:{
                var temp_content = ""
                dictJson.forEach(function(jsonObj){
                    var paraphrases = jsonObj.条目.释文.注意
                    if(paraphrases !== undefined){
                        temp_content += "注："
                        temp_content += paraphrases
                    }
                })
                return temp_content
            }
        }
    }
}

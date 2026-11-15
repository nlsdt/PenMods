import QtQuick 2.12
import QtQuick.XmlListModel 2.14
import com.youdao.pen 1.0
import BaseQml 1.0
import "../i18n"
import "../../qml/timers"
import "../components"
import "../commons"

YDictTypeBase {
    id: id_dict_type_ch_ancientword
    title: YTranslateText.dtBusinessAnCh 

    property string chPinyinSelected: ""//resultManager.chPinyinListSelected
    property string chPinyinHeaderSelected: id_dict_page.chPinyinSelected
    property var pinyinNumsList: [] //拼音
    property var buChPinyinList: [] //拼音
    property var countNumber: 0
    property var entryWords : [] // 词组
    property var paraphrases : [] // 释义组
    property var realDictJson : {} //真实存储的字头释义的json
    property var oldChinese : "" //繁体字
    property var diffChinese : "" //异体字
    property var wordpinyins : [] //相关词条
    signal showPageClick()
    function startSet() {

        if(!buChPinyinList.length && countNumber<50) {
            countNumber ++
            YTimers.delayCall(20, startSet)
            return
        }
        if(isFirstDict) {
            firstDictType = dictType
            firstDictJson = dictJson
            // chPinYinList = []
             chPinYinList = buChPinyinList//chPinyinList

            buPinYinNums = []
            buPinYinNums = pinyinNumsList
        }
        if (buChPinyinList.length > 0) {
            chPinyinSelected = buChPinyinList[0]
            if (isFirstDict) {
                resultManager.phoneticSymbolJson = chPinyinSelected
            }
        }
    }

    onDictJsonChanged: {
        console.log("========>chenfei:",JSON.stringify(dictJson));
        chPinyinSelected = ""
//        var adjustJsonObj = {} //矫正数据结构
//        if(dictJson.length === 1){
//            dictJson.forEach(function(jsonObj){
//                var t_jsonObj = jsonObj.字目
//                if(t_jsonObj.字形 !== undefined) adjustJsonObj.字形 = t_jsonObj.字形
//                adjustJsonObj.词目 = t_jsonObj.词目
//                adjustJsonObj.字条 = t_jsonObj.字条
//                adjustJsonObj.释义组 = [t_jsonObj.释义组]
//            })
//        }else {
//            dictJson.forEach(function(jsonObj){
//                console.log("==========chenfei=======:",typeof jsonObj.字目.释义组)
//                if(jsonObj.字目.释义组.constructor === Array){
//                    adjustJsonObj = jsonObj.字目
//                }
//            })
//        }
//        console.log("========>chenfei:111",JSON.stringify(adjustJsonObj));
//        constructingDataModel(adjustJsonObj,"")
        constructingDataModelBySelectPinyin("")
        startSet()
    }

    function constructingDataModelBySelectPinyin(currentSelectPinyinStr){
        var adjustJsonObj = {} //矫正数据结构
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
        console.log("========>chenfei:111",JSON.stringify(adjustJsonObj));
        if(currentSelectPinyinStr === ""){
            constructingDataModel(adjustJsonObj,adjustJsonObj.释义组[0].音项.汉语拼音.content)
        }else{
            constructingDataModel(adjustJsonObj,currentSelectPinyinStr)
        }

    }

    property var temp_chPinyinList : []
    property var temp_pinyinNumsList : []
    property var temp_paraphrases : []
    property var temp_entryWords : []
    // //构造古代汉语首页数据格式
    function constructingDataModel(contentJsonObj,currentSelectPinyinStr){
        var styleString = "<font color=\"red\">~</font>"
        temp_chPinyinList = []
        temp_pinyinNumsList = []
        temp_paraphrases = []
        temp_entryWords = []
        wordpinyins = []
        diffChinese = ""
        oldChinese = ""
        if(contentJsonObj.字形 !== undefined){
            if(contentJsonObj.字形.异体字 !== undefined){
                var diffs = contentJsonObj.字形.异体字
                if(diffs.constructor !== Array){
                    diffs = [diffs]
                }
                var i = 0
                diffs.forEach(function(diffObj){
                    var temp_diffObj
                    if(diffObj.constructor !== String)
                        temp_diffObj = diffObj.BU
                    else
                        temp_diffObj = diffObj
                    if(diffs.length - 1  !== i){
                        diffChinese += temp_diffObj
                        diffChinese += "、"
                    }else{
                        diffChinese += temp_diffObj
                    }
                    ++i
                })

            }
            if(contentJsonObj.字形.繁体字 !== undefined) oldChinese = contentJsonObj.字形.繁体字
        }
        console.log("========>chenfei:222",JSON.stringify(contentJsonObj));
        contentJsonObj.释义组.forEach(function(jsonObj){
            var temp_json = jsonObj.音项.汉语拼音
            temp_chPinyinList.push(temp_json.content)
            temp_pinyinNumsList.push(temp_json.索引)
            console.log("pinyin:chenfei:",temp_json.content)
            if(temp_json.content === currentSelectPinyinStr){ // 当前选中
                console.log("pinyin:chenfei:1",temp_json.content)
                temp_json = jsonObj.释文.义项
                if(temp_json.constructor !== Array){
                    temp_json = [temp_json]
                }
                temp_json.forEach(function(paraphrasesObj){
                    var temp_content = ""
                    var temp_paraphrasesJson = {}
                    //释义
                    var phs = paraphrasesObj.释义
                    if(phs.constructor === String){
                        temp_content += phs
                    }else{
                        if(phs.constructor !== Array){
                            phs = [phs]
                        }
                        phs.forEach(function(contentObj){
                            if(contentObj.content !== undefined && contentObj.content.constructor === String) temp_content += contentObj.content
                            if(contentObj.书证 !== undefined)
                                contentObj.书证.forEach(function(docObj){
                                    temp_content += docObj.content
                                    if(docObj.注 !== undefined) temp_content += docObj.注
                                })
                        })
                    }
                    temp_paraphrasesJson.content = temp_content.replace(/~/g,styleString);
                    var expoundArray = []
                    //引申
                    temp_content = ""
                    if(paraphrasesObj.引申 !== undefined){
                        phs = paraphrasesObj.引申
                        if(phs.constructor !== Array) phs = [phs]
                        phs.forEach(function(contentObj){
//                            if(contentObj.释义 !== undefined){
                                if(contentObj.释义 !== undefined/*contentObj.释义.constructor === String*/){
                                    if(contentObj.释义.constructor === String/*contentObj.释义 !== undefined*/) {
                                        temp_content += contentObj.释义
                                    }else{
                                        if(contentObj.释义.content !== undefined){
                                            var links = contentObj.释义.LINK
                                            if(links !== undefined)
                                                if(links.constructor !== Array) links = [links]
                                            var link_index = 0
                                            contentObj.释义.content.forEach(function(contentJson){
                                                temp_content += contentJson
                                                if(links !== undefined && link_index !== links.length)
                                                    temp_content += links[link_index].content
                                                link_index ++
                                            })

                                            if(contentObj.释义.注 && contentObj.释义.注.constructor === String) temp_content += contentObj.释义.注
                                        }
                                    }
                                    if(contentObj.书证 !== undefined)
                                        contentObj.书证.forEach(function(docObj){
                                            temp_content += docObj.content
                                            if(docObj.注 !== undefined) temp_content += docObj.注
                                        })
                                }else{
//                                    var links = contentObj.释义.LINK
//                                    if(links.constructor !== Array) links = [links]
//                                    var link_index = 0
//                                    contentObj.释义.content.forEach(function(contentJson){
//                                        temp_content += contentJson
//                                        if(link_index !== links.length)
//                                            temp_content += links[link_index].content
//                                        link_index ++
//                                    })
                                }
//                            }

                        })
                        expoundArray.push({"content":temp_content.replace(/~/g,styleString),"tag":"引","isDoc" : 1})
                    }
                    //又义
                    temp_content = ""
                    if(paraphrasesObj.又义 !== undefined){
                        phs = paraphrasesObj.又义
                        if(phs.constructor !== Array) phs = [phs]
                        phs.forEach(function(contentObj){

                            if(contentObj.释义 !== undefined){
                                if(contentObj.释义.constructor === String){
                                    temp_content += contentObj.释义
//                                    contentObj.书证.forEach(function(docObj){
//                                        temp_content += docObj.content
//                                        if(docObj.注 !== undefined) temp_content += docObj.注
//                                    })
                                }else{

                                    if(contentObj.释义.LINK !== undefined){
                                        var links = contentObj.释义.LINK
                                        if(links.constructor !== Array) links = [links]
                                        var link_index = 0
                                        contentObj.释义.content.forEach(function(contentJson){
                                            temp_content += contentJson
                                            if(link_index !== links.length)
                                                temp_content += links[link_index].content
                                            link_index ++
                                        })
                                    }else if(contentObj.释义.content !== undefined){
                                        var contents = contentObj.释义.content
                                        if(contents.constructor !== Array) contents = [contents]
                                        var r_index = 0
                                        contents.forEach(function(rObj){
                                            temp_content += rObj
                                            if(contentObj.释义.BU && r_index === 0)
                                                temp_content +=contentObj.释义.BU
                                            r_index++

                                        })
                                    }

                                }
                                if(contentObj.书证 !== undefined)
                                    contentObj.书证.forEach(function(docObj){
                                        temp_content += docObj.content
                                        if(docObj.注 !== undefined) temp_content += docObj.注
                                    })
                            }

                        })
                        expoundArray.push({"content":temp_content.replace(/~/g,styleString),"tag":"又","isDoc" : 1})
                    }
                    //分义项
                    if(paraphrasesObj.分义项 !== undefined){
                        phs = paraphrasesObj.分义项
                        if(phs.constructor !== Array) phs = [phs]
                        var temp_index = 1
                        phs.forEach(function(contentObj){
                            temp_content = ""
                            if(contentObj.释义.content.constructor === String){
                                temp_content += contentObj.释义.content
                                contentObj.释义.书证.forEach(function(docObj){
                                    temp_content += docObj.content
                                    if(docObj.注 !== undefined){
                                        temp_content += docObj.注
                                    }
                                })
                            }else{
                                var links = contentObj.释义.LINK
                                if(links.constructor !== Array) links = [links]
                                var link_index = 0
                                contentObj.释义.content.forEach(function(contentJson){
                                    temp_content += contentJson
                                    if(link_index !== links.length)
                                        temp_content += links[link_index].content
                                    link_index ++
                                })
                            }

                            expoundArray.push({"content":temp_content.replace(/~/g,styleString),"tag":temp_index + ".","isDoc" : 0})
                            temp_index ++
                        })

                    }

                    temp_paraphrasesJson["array"] = expoundArray
                    temp_paraphrases.push(temp_paraphrasesJson)
                })
            }
        })

        buChPinyinList = temp_chPinyinList
        pinyinNumsList = temp_pinyinNumsList
        paraphrases = temp_paraphrases
        //词目
        if(contentJsonObj.词目 !== undefined)
            contentJsonObj.词目.forEach(function(eWorsObj){
                temp_entryWords.push(eWorsObj.词条)
                wordpinyins.push(eWorsObj.音项.汉语拼音.content)
            })
        entryWords = temp_entryWords
        console.log("========>chenfei:444",JSON.stringify(buChPinyinList));
    }

    function onSelectPinYinChanged(selectedPinyin) {
        console.log("YDictBusinessAnCh.qml===onSelectPinYinChanged:", selectedPinyin)
        constructingDataModelBySelectPinyin(selectedPinyin)
    }

    Item {
        width: parent.width
        height: id_word_detailParas_column.height

        Column {
            id:id_word_detailParas_column
            spacing: 0
            width: parent.width
            
            //发音相关控件（如果是多音字，横向列表）
            YLoader {
                id: id_pinyins_loader
                anchors.left: parent.left
                anchors.right: parent.right
                active: !isFirstDict && typeof buChPinyinList.length !== "undefined" && buChPinyinList.length >= 1
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
                    visible: id_dict_ch_pinyin_list_repeater.count >= 1
                    clip: true

                    Row{
                        id: id_dict_ch_pinyin_list
                        height: 52
                        spacing: 10
                        anchors.bottom: parent.bottom

                        Repeater {
                            id: id_dict_ch_pinyin_list_repeater
                            model: buChPinyinList

                            YAudioPlayIconLabelHCenterButton {
                                height: 52
                                color: YColors.grayNormal
                                textItem.font.pixelSize: 26
                                textItem.font.family: fontManager.fontFamilyXinHuaXiHei
                                text: model.modelData
                                textItem.color: isCurrentSelectedPinyin ? YColors.red : YColors.white
                                iconItem.visible: isCurrentSelectedPinyin
                                width: (iconItem.visible ? iconItem.width : 0) + textItem.width + 20 * 2
                                readonly property bool isCurrentSelectedPinyin : chPinyinSelected === model.modelData

                                onValidClicked: {
                                    // id_dict_type_ch_ancientword.constructingDataModel(realDictJson,text)
                                    constructingDataModelBySelectPinyin(text)
                                    console.log("YDictPage.qml === id_dict_ch_pinyin_list.btn.onClicked text: ", text)
                                    chPinyinSelected = text
                                    resultManager.phoneticSymbolJson = text
                                    var nAutoPronType =  YEnum.DtBusinessAnCh
                                    if(typeof pinyinNumsList[index] !== "undefined") {
                                        qmlGlobal.audioPlayId = soundCenter.play(pinyinNumsList[index],
                                                                                "zh",
                                                                                pinyinNumsList[index], nAutoPronType + 1)
                                    }
                                    else
                                        qmlGlobal.soundWGTCh()
                                    
                                }
                            }
                        }
                    }
                }
            }

            YSpacingForColumn{
                height: 18
                visible: id_old_different_font.visible && id_old_different_font.height && id_pinyins_loader.active
            }
            //繁体字 异体字
            Flow {
                id: id_old_different_font
                anchors.left: parent.left
                anchors.right: parent.right
                // property var oldChinese: {
                //     let temp = ""
                //     return temp
                // }
                
                //繁体字
                Row {
                    visible:id_dict_type_ch_ancientword.oldChinese.length //id_old_different_font.oldChinese.length
                    width: visible ? id_old_chinese_rectangle.width +id_old_chinese_space.width + id_old_chinese_values.width + 40 : 0
                    Rectangle {
                        id: id_old_chinese_rectangle
                        height: 26
                        width: 26
                        radius: 30
                        color: YColors.transparent
                        border.color: YColors.white
                        anchors.verticalCenter: parent.verticalCenter
                        visible: id_dict_type_ch_ancientword.oldChinese.length //id_old_different_font.oldChinese.length
                        YText {
                            id: id_old_chinese_text
                            anchors.centerIn: parent
                            font.family: fontManager.fontFamilyXinHuaXiHei
                            font.pixelSize: 20
                            text: YTranslateText.oldChinese
                        }
                    }
                    Item{
                        id:id_old_chinese_space
                        width: 11
                        height: 26
                        visible: id_old_chinese_rectangle.visible
                    }
                    YText {
                        id: id_old_chinese_values
                        font.family: fontManager.fontFamilyXinHuaXiHei
                        anchors.verticalCenter: parent.verticalCenter
                        font.pixelSize: 28
                        color: YColors.red
                        text: id_dict_type_ch_ancientword.oldChinese //id_old_different_font.oldChinese.trim()
                        visible: id_old_chinese_rectangle.visible
                    }
                }

                property var differentFonts: {
                    let temp = []
                    return temp
                }

                //异体字
                Row {
                    visible: {
                        return id_dict_type_ch_ancientword.diffChinese.length //id_old_different_font.differentFonts.length
                    }
                    Rectangle {
                        id: id_different_chinese_rectangle
                        height: 26
                        width: 26
                        radius: 30
                        color: YColors.transparent
                        border.color: YColors.white
                        anchors.verticalCenter: parent.verticalCenter
                        visible: id_dict_type_ch_ancientword.diffChinese.length//id_old_different_font.differentFonts.length
                        YText {
                            id: id_different_chinese_text
                            anchors.centerIn: parent
                            font.family: fontManager.fontFamilyXinHuaXiHei
                            font.pixelSize: 20
                            text: YTranslateText.differentFont
                        }
                    }

                    Item {
                        width: 11
                        height: 26
                        visible: id_different_chinese_rectangle.visible
                    }

                    //异体字上标等
                    YText {
                        id: id_different_chinese_value
                        font.family: fontManager.fontFamilyXinHuaXiHei
                        anchors.verticalCenter: parent.verticalCenter
                        font.pixelSize: 28
                        color: YColors.red
                        text: id_dict_type_ch_ancientword.diffChinese
                        visible: id_different_chinese_rectangle.visible && text.length
                    }

                }
            }

            

            YSpacingForColumn {
                height: 8
                visible: true //id_paraphrase_loader.active
            }

            Repeater {
                id: id_paraphrase_repeater
                model: paraphrases
                property int content_width: 538 + 18 +26
                property int content_margins: 20
                property int content_num_margins: 5
                property int content_r_height:30
                property var docedvArrary : [1]
                Column {
                    width: id_paraphrase_repeater.content_width
                    //释义
                    Rectangle {
                        width:parent.width
                        height: id_paraphrase_ytext.contentHeight +id_paraphrase_repeater.content_margins * 2
                        color: "black"
                        Rectangle {
                            id: id_paraphrase_num
                            anchors.left: parent.left
                            y: id_paraphrase_repeater.content_margins + 5
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
                            anchors.topMargin:id_paraphrase_repeater.content_margins
                            anchors.bottomMargin:id_paraphrase_repeater.content_margins
                            color: YColors.white
                            text: id_paraphrase_repeater.model[index].content
                        }
                    }
                    //引/又
                    Repeater {
                        model: id_paraphrase_repeater.model[index].array
                        id: id_doc_edc_repeat
                        Column {
                            width:id_paraphrase_repeater.content_width
                            Rectangle {  
                                x: 26 + 15
                                width:parent.width - 26 - 15
                                height:{
                                    if(id_doc_edc_repeat.model[index].isDoc)
                                        return id_doc_edc_text.contentHeight + id_paraphrase_repeater.content_margins * 2
                                    else
                                        return id_doc_edc_text.contentHeight + id_paraphrase_repeater.content_num_margins * 2
                                }
                                color:{
                                    if(id_doc_edc_repeat.model[index].isDoc)
                                        return "#1A1B1F"
                                    else
                                        return "transparent"
                                }
                                radius : 16
                                Rectangle {
                                    anchors.left:parent.left
                                    anchors.right:parent.right
                                    height:id_paraphrase_repeater.content_r_height
                                    y: parent.height - id_paraphrase_repeater.content_r_height / 2
                                    color:"#1A1B1F"
                                    visible:{
                                        console.log("seven:tag:",id_doc_edc_repeat.model[index].tag)
                                        if(id_doc_edc_repeat.model[index].isDoc)
                                            return index == id_doc_edc_repeat.model.length - 1 ? false : true
                                        else{
                                            return false
                                        }
                                    }
                                }

                                Rectangle {
                                    id: id_docedv_num
                                    // anchors.left: parent.left
                                    x: {
                                        if(id_doc_edc_repeat.model[index].isDoc)
                                            return 15
                                        else
                                            return 0
                                    }
                                    y: {
                                        if(id_doc_edc_repeat.model[index].isDoc)
                                            return id_paraphrase_repeater.content_margins + 5
                                        else
                                            return id_paraphrase_repeater.content_num_margins + 5
                                    }
                                    width: 26
                                    height: width
                                    radius : width / 2
                                    border.width: 1
                                    antialiasing: true
                                    border.color:{
                                        if(id_doc_edc_repeat.model[index].isDoc)
                                            return "white"
                                        else
                                            return "transparent"
                                    }

                                    color: {
                                        if(id_doc_edc_repeat.model[index].isDoc)
                                            "#1A1B1F"
                                        else
                                            return "transparent"
                                    }

                                    YText {
                                        anchors.fill: parent
                                        text: id_doc_edc_repeat.model[index].tag
                                        color: {
                                            if(id_doc_edc_repeat.model[index].isDoc){
                                                return YColors.white
                                            }else
                                                return "#A8AAB2"
                                        }
                                        font.pixelSize: {
                                            if(id_doc_edc_repeat.model[index].isDoc)
                                                return 18
                                            else
                                                return 26
                                        }
                                        horizontalAlignment: Text.AlignHCenter
                                        verticalAlignment :Text.AlignVCenter
                                    }
                                }

                                YText {
                                    id: id_doc_edc_text
                                    anchors.left: id_docedv_num.right
                                    anchors.top: parent.top
                                    anchors.right: parent.right
                                    // font.family: {
                                    //     console.log("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~:",fontManager.fontFamilyXinHuaXiHei);
                                    //     return fontManager.fontFamilyXinHuaXiHei
                                    // }
                                    font.pixelSize: 28
                                    wrapMode: YText.WordWrap
                                    textFormat: Text.RichText
                                    visible: text.length
                                    anchors.leftMargin: 15
                                    anchors.margins:{
                                        if(id_doc_edc_repeat.model[index].isDoc)
                                            return id_paraphrase_repeater.content_margins
                                        else
                                            return id_paraphrase_repeater.content_num_margins
                                    }
                                    color: YColors.white
                                    text: id_doc_edc_repeat.model[index].content
                                }
                            }
                        }
                    }
                }
            }
            
            //相关词条

            YSpacingForColumn {
                height: 8
                visible: id_eDict_text.visible //id_paraphrase_loader.active
            }

            YTextBase {
                // font.family: fontManager.fontFamilyXinHuaXiHei
                id: id_eDict_text
                font.pixelSize: 28
                color: "#F03043"
                text: YTranslateText.dtRelatedTerms
                height: 44
                visible: id_entry_dict_flow.visible
                Component.onCompleted: {
                    dictNodeCompleted(text, dictType, 1, this)
                }
            }

            YSpacingForColumn {
                height: 16
                visible: id_entry_dict_flow.visible
            }

            Flow {
                id: id_entry_dict_flow
                width: 538 + 18 +26
                flow: Flow.LeftToRight
                spacing: 20
                visible: id_dict_type_ch_ancientword.entryWords.length !== 0
                Repeater{
                    id: id_entry_dict
                    model: id_dict_type_ch_ancientword.entryWords
                    property int entry_width: 538 + 18 +26
                    Rectangle{
                        width: id_entry.contentWidth //+ 15
                        height: 28
                        color: "black"
                        YText{
                            id: id_entry
                            // anchors.fill: parent
                            anchors.left: parent.left
                            anchors.top: parent.top
                            anchors.bottom: parent.bottom
                            // font.family: fontManager.fontsFamilyXinHuaXiHei
                            font.pixelSize: 30
                            color: "#509DEB" 
                            verticalAlignment: Text.AlignVCenter
                            horizontalAlignment: Text.AlignLeft
                            text: id_entry_dict.model[index]
                        }

                        MouseArea{
                            anchors.fill: parent
                            onClicked :{
                                // console.log("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~:",dictType,JSON.stringify(dictJson));
                                resultManager.setCurrentBusWord(wordpinyins[index])
                                console.log("seven:resultManager.currentBusWord():0:",resultManager.currentBusWord())
                                showPageClick()
                                qmlGlobal.showDictDetailPage(dictType, JSON.stringify(dictJson),id_entry_dict.model[index])
                            }
                        }
                    }

                }
            }
            
        }
    }

    Component.onCompleted: {
        resultManager.onSelectPinYinChanged.connect(onSelectPinYinChanged);
    }
}



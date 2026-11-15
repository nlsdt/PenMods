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
    title: YTranslateText.dtChXinHua
    //visible: dictSelectParaphrasesJson !== null
    //property var chPinyinList: []
    onChPinyinListChanged: {
        if(isFirstDict)
            chPinYinList = chPinyinList
    }
    property string chPinyinSelected: ""//resultManager.chPinyinListSelected
    property string chPinyinHeaderSelected: id_dict_page.chPinyinSelected
    function setCHHeader () {
    }
    property var dataLists: {
        let temp = []
        try {
            //xml
            //temp = content.split("###")
            //json
            temp = JSON.parse(content)
        } catch(e) {
        }

        return temp
    }

    property var radical: {
        let temp = ""
        try {
            temp = dictSelectParaphrasesJsonObject.字条.部首
        } catch (e) {}
        if(typeof temp === "undefined") {
            temp = ""
        }
        if(isFirstDict || firstDictType !== YEnum.DtChChinese) {
            if ((typeof temp != "undefined") && (temp.length > 0)) {
                id_dict_page.radical = temp
                //haveStrokeInfo = true
            }
        }
        return temp
    }
    property var strokeCount: {

        let temp =(radicalStrokeCount + notRadicalStrokeCount)
        if(isFirstDict || firstDictType !== YEnum.DtChChinese) {
            if ((typeof temp !== "undefined")) {
                id_dict_page.strokeCount = temp
                //haveStrokeInfo = true
            }
        }
        return temp
    }
    property var structure: {
        let temp = ""
        try {
            temp = dictSelectParaphrasesJsonObject.字条.结构
        } catch (e) {}

        if(typeof temp === "undefined") {
            temp = ""
        }
        if(isFirstDict || firstDictType !== YEnum.DtChChinese) {
            if ((typeof temp != "undefined") && (temp.length > 0)) {
                id_dict_page.structure = temp
                //haveStrokeInfo = true
            }
        }

        return temp
    }
    property var radicalStrokeCount:  {
        let temp = 0
        try {
            temp = parseInt(dictSelectParaphrasesJsonObject.字条.部首笔画数)
        } catch (e) {}
        return temp
    }

    property var notRadicalStrokeCount: {
        let temp = 0
        try {
            temp = parseInt(dictSelectParaphrasesJsonObject.字条.除部首外笔画数)
        } catch (e) {}
        return temp
    }


    property var fontLevel: {
        let temp = 0
        try {
            temp = dictSelectParaphrasesJsonObject.字条.字级
        } catch (e) {}
        return temp
    }
    property var markSound: {
        let temp = ""
        try {
            temp = getKeyOrText(dictSelectParaphrasesJsonObject.音项.注音)
        } catch (e) {}
        return temp
    }
    property var markSoundXml: {
        let temp = ""
        //        try {
        //            temp = dictSelectParaphrasesJsonObject.音项.注音.BU
        //        } catch (e) {}
        return temp
    }

    property var differentFonts: {
        let temp = []
        try {
            if((dictSelectParaphrasesJsonObject.字形.异体字).constructor === Array) {
                temp = dictSelectParaphrasesJsonObject.字形.异体字
            }else {
                let tempText = getKeyOrText(dictSelectParaphrasesJsonObject.字形.异体字)
                if(tempText !== null)
                    temp.push(tempText)
            }
        } catch (e) {
        }
        return temp
    }
    property var differentFontsReleates: []
    //旧读
    property var oldReadingData: ''
    //注意
    property var mentionData: {
        let temp = ""
        try {
            temp = dictSelectParaphrasesJsonObject.注意.content
        } catch (e) {
            try {
                temp = dictSelectParaphrasesJsonObject.注意
            } catch(e) {}
        }
        return temp
    }
    //义项，释义
    property var meaningsList: []

    property var curWord: {
        let temp = ""
        try {
            temp = getKeyOrText(dictSelectParaphrasesJsonObject.字条)/* dictSelectParaphrasesJsonObject.字条.text*/
        } catch (e) {
            try {
                temp = dictSelectParaphrasesJsonObject.字条
            } catch(e) {}
        }
        return temp
    }

    property var countNumber: 0

    property var curSelectPinYinSound: null
    property var pinyinNumsList: []
    onPinyinNumsListChanged: {
        xinHuaPinYinNums = []
        xinHuaPinYinNums = pinyinNumsList
    }

    property var testJson: ({义项:[{分义项:{释义:'称你、我以外的第三人,一般指男性,有时泛指,不分性别。'}}, {分义项:{释义:'别的',例证:'他</KEY>人乡。',词目:{词条:'其他',释文:[{义项:{释义:'代词,别的。'}}]}}}]})

    signal pinYinsSearchFinish
    property var xmlSearchComponent: null

    property var dictSelectParaphrasesJson: chPinyinSelected.length ? getDictSelectParaphrasesJson(chPinyinSelected) : null

    property var dictSelectParaphrasesXml:  {
        let temp = ""
        try {
            temp = (JSON.parse(dictSelectParaphrasesJson).xml)
        } catch(e) {}
        return temp
    }

    property var dictSelectParaphrasesJsonObject: {
        let temp = {}
        try {
            //temp = JSON.parse(JSON.parse(dictSelectParaphrasesJson).json)
            temp = dictSelectParaphrasesJson
        } catch(e) {

        }
        return temp
    }

    onIsFirstDictChanged: {
        if (isFirstDict) {
            resultManager.phoneticSymbolJson = chPinyinSelected
        }
    }

    function getSpecialFontText(textParameter) {
        let textTemp = null
        if(typeof textParameter === "string")
            textTemp = textParameter
        else if(textParameter.constructor === Array) {
            //temp = dictSelectParaphrasesJsonObject.字形.异体字
        }else if(textParameter.constructor === Object) {
            try {
                textTemp = textParameter.content
            } catch (e) {
                try {
                    textTemp = textParameter.BU
                } catch (e) {
                }
            }
        }
        return textTemp
    }

    function arraySetValue(textParameter) {
        let textTemp = []
        if(typeof textParameter === "string")
            textTemp = textParameter
        else if(textParameter.constructor === Array) {
            textTemp = textParameter
            //temp = dictSelectParaphrasesJsonObject.字形.异体字
        }else if(textParameter.constructor === Object) {
            textTemp.push(textParameter)
        }
        return textTemp
    }

    function getCurData() {
        let temp = ({})
        let tempTextData = null
        try {
            if(typeof id_meaning_column.modelModelData.释义 !== "undefined") {

                let m = {}
                if(typeof id_meaning_column.modelModelData.释义.见条 !== "undefined") {
                    tempTextData = id_dict_type_ch_ancientword.getAllValueString(id_meaning_column.modelModelData.释义.见条)
                } else
                    tempTextData = id_dict_type_ch_ancientword.getAllValueString(id_meaning_column.modelModelData.释义)
                if(tempTextData !== null) {
                    m["释义data"] = tempTextData
                    temp["释义"] = m
                }
            }
        } catch(e) {}

        try {
            if(typeof id_meaning_column.modelModelData.释义.注 !== "undefined") {
                if ( typeof  temp["释义"] === "undefined")
                    temp["释义"] = {}
                if ( typeof  temp["释义"]["注"] === "undefined")
                    temp["释义"]["注"]  = {}
                tempTextData = id_dict_type_ch_ancientword.getAllValueString(id_meaning_column.modelModelData.释义.注)
                if(tempText !== null)
                    temp["释义"]["注"]["meanMention"] = tempTextData
            }
        } catch(e) {}

        try {
            if(typeof id_meaning_column.modelModelData.释义.注.类型 !== "undefined") {
                if ( typeof temp["释义"] === "undefined")
                    temp["释义"] = {}
                if ( typeof temp["释义"]["注"] === "undefined")
                    temp["释义"]["注"]  = {}
                tempTextData = id_dict_type_ch_ancientword.getAllValueString(id_meaning_column.modelModelData.释义.注.类型)
            }
            if (tempTextData !== null)
                temp["释义"]["注"]["类型"] = {"meanMentionType":tempTextData}
        } catch(e) {}

        try {
            if(typeof id_meaning_column.modelModelData.比喻 !== "undefined") {
                tempTextData = id_dict_type_ch_ancientword.getAllValueString(id_meaning_column.modelModelData.比喻)
                if ( typeof temp["比喻"] === "undefined")
                {
                    if(tempTextData !== null)
                        temp["比喻"] = {"比喻data":tempTextData}
                }
                else if(tempTextData !== null)
                    temp["比喻"]["比喻data"] = tempTextData
            }
        } catch(e) {}

        try {
            if(typeof id_meaning_column.modelModelData.转化 !== "undefined") {
                tempTextData = id_dict_type_ch_ancientword.getAllValueString(id_meaning_column.modelModelData.转化)
                if ( typeof temp["转化"] === "undefined") {
                    if(tempTextData !== null)
                        temp["转化"] = {"转化data":tempTextData}
                }
                else if(tempTextData !== null)
                    temp["转化"]["转化data"] = tempTextData
            }
        } catch(e) {}

        try {
            if(typeof id_meaning_column.modelModelData.引申 !== "undefined") {
                tempTextData = id_dict_type_ch_ancientword.getAllValueString(id_meaning_column.modelModelData.引申)
                if ( typeof temp["引申"] === "undefined") {
                    if(tempTextData !== null)
                        temp["引申"] = {"引申data":tempTextData}
                }
                else   if(tempTextData !== null)
                    temp["引申"]["引申data"] = tempTextData
            }
        } catch(e) {}

        try {
            if(typeof id_meaning_column.modelModelData.引申.用法 !== "undefined") {
                tempTextData = id_dict_type_ch_ancientword.getAllValueString(id_meaning_column.modelModelData.引申.用法)
                if(tempTextData !== null)
                    temp["引申"]["extendedMethod"] = {"extendedMethod":tempTextData}
            }
        } catch(e) {}

        try {
            if(typeof id_meaning_column.modelModelData.引申.释义 !== "undefined") {
                tempTextData = id_dict_type_ch_ancientword.getAllValueString(id_meaning_column.modelModelData.引申.释义)
                if(tempTextData !== null)
                    temp["引申"]["extendedMeanData"] = {"extendedMeanData":tempTextData}
            }
        } catch(e) {}

        try {
            if(typeof id_meaning_column.modelModelData.引申.例证 !== "undefined") {
                tempTextData = id_dict_type_ch_ancientword.getAllValueString(id_meaning_column.modelModelData.引申.例证)
                if(tempTextData !== null)
                    temp["引申"]["extendedExample"] = {"extendedExample":tempTextData}
            }
        } catch(e) {}

        try {
            if(typeof id_meaning_column.modelModelData.注 !== "undefined") {
                tempTextData = id_dict_type_ch_ancientword.getMenteionText(id_meaning_column.modelModelData.注)
                if(tempTextData !== null)
                    temp["注"] = {"oldReading":tempTextData}
            }
        } catch(e) {}

        try {
            if(typeof id_meaning_column.modelModelData.注.SMALL !== "undefined") {
                tempTextData = id_dict_type_ch_ancientword.getAllValueString(id_meaning_column.modelModelData.注.SMALL)
                if ( typeof  temp["注"] === "undefined")
                    temp["注"] = {}
                if(tempTextData !== null)
                    temp["注"]['SMALL'] = {"mentionSmallData":tempTextData}
            }
        } catch(e) {}

        try {
            if(typeof id_meaning_column.modelModelData.例证 !== "undefined") {
                tempTextData = id_dict_type_ch_ancientword.getExampleText(id_meaning_column.modelModelData.例证)
                if(tempTextData !== null)
                    temp["例证"] = {"例证data":tempTextData}
            }
        } catch(e) {}


        try {
            if(typeof id_meaning_column.modelModelData.引申.分义项 !== "undefined") {
                if ( typeof temp["引申"] === "undefined") {
                    temp["引申"] = {}
                }
                if ( typeof temp["引申"]["分义项"] === "undefined")
                    temp["引申"]["分义项"] = []
                if((id_meaning_column.modelModelData.引申.分义项).constructor === Array) {
                    for(let i = 0; i < id_meaning_column.modelModelData.引申.分义项.length; i++)
                        temp["引申"]["分义项"].push({"extendedMultiMean":id_meaning_column.modelModelData.引申.分义项[i]})
                } else {
                    temp["引申"]["分义项"].push({"extendedMultiMean":id_meaning_column.modelModelData.引申.分义项})
                }
            }
        } catch(e) {}

        try {
            if(typeof id_meaning_column.modelModelData.转化.分义项 !== "undefined") {
                if ( typeof temp["转化"] === "undefined") {
                    temp["转化"] = {}
                }
                if ( typeof temp["转化"]["分义项"] === "undefined")
                    temp["转化"]["分义项"] = []
                if((id_meaning_column.modelModelData.引申.分义项).constructor === Array) {
                    for(let i = 0; i < id_meaning_column.modelModelData.转化.分义项.length; i++)
                        temp["转化"]["分义项"].push({"extendedMultiMean":id_meaning_column.modelModelData.转化.分义项[i]})
                } else {
                    temp["转化"]["分义项"].push({"extendedMultiMean":id_meaning_column.modelModelData.转化.分义项})
                }
            }
        } catch(e) {}

        try {
            if(typeof id_meaning_column.modelModelData.分义项 !== "undefined") {
                if((id_meaning_column.modelModelData.分义项).constructor === Array) {
                    id_meaning_column.splitMeanList = id_meaning_column.modelModelData.分义项
                } else {
                    id_meaning_column.splitMeanList.push(id_meaning_column.modelModelData.分义项)
                }
            }
        } catch(e) {}

        return temp
    }

    function getAllValueString(textParameter) {
        let tempText = ""
        if(dictSelectParaphrasesJsonObject.constructor === Object) {
            if(typeof textParameter.content !== "undefined")
            tempText =  textParameter.content
            else {
                tempText = JSON.stringify(textParameter).trim()
                if(tempText[0] === "\"")
                    tempText = tempText.substr(1)
                if(tempText[tempText.length - 1] === "\"") {
                    tempText = tempText.substr(0, tempText.length - 1)
                }
            }
        return tempText
        }
            else {

        let keysList = Object.keys(textParameter)
        let valueList = []
        for(let j = 0; j < keysList.length; j++) {
            if(JSON.stringify(keysList[j]).trim() == JSON.stringify('类型').trim()) {
                continue
            }

            if(JSON.stringify(keysList[j]).trim() == JSON.stringify('id').trim()) {
                continue
            }
            if(JSON.stringify(keysList[j]).trim() == JSON.stringify('refid').trim()) {
                continue
            }
            if(JSON.stringify(keysList[j]).trim() == JSON.stringify('序号').trim()) {
                continue
            }
            valueList.push(textParameter[keysList[j]])
        }
        let strt = null
        if(valueList.length === 1 ) {
            if(typeof valueList[0] === "string")
                return valueList[0]
            else
                if(JSON.stringify(Object.values(valueList[0])) === JSON.stringify(valueList[0])) {
                    return JSON.stringify(valueList[0])
                } else {
                    for(let k = 0; k< valueList.length; k++) {
                        if(strt === null)
                            strt = ""
                        let temp = getAllValueString(valueList[k])
                        strt +=  (temp === null ? "" : temp)
                        //strt +=  getAllValueString(valueList[k])
                    }
                }
        } else {
            for(let i = 0; i< valueList.length; i++) {
                if(strt === null)
                    strt = ""
                let temp = getAllValueString(valueList[i])
                strt +=  (temp === null ? "" : temp)
            }
        }
        return strt
        }
        //return Object.values(textParameter).join("")
    }

    function getExampleText(textParameter) {
        let temp = ""

        let dataText  = ''
        if (dictSelectParaphrasesJsonObject.constructor === Object) {
            if(typeof textParameter.例 !== "undefined") {
                if(inputIsArray(textParameter.例)) {
                    for(var i = 0 ; i < textParameter.例.length; i ++) {
                        dataText += textParameter.例[i].replace(/<b>.*?<\/b>/g, '<font color="%1">~</font>'.arg(YColors.red)) +
                        (i !== textParameter.例.length - 1 ? "  |  ": "")
                    }
                } else {
                    dataText += textParameter.例.replace(/<b>.*?<\/b>/g, '<font color="%1">~</font>'.arg(YColors.red))
                }
            } else {
            if (textParameter.indexOf("<b>") !== -1 && textParameter.indexOf("</b>") !== -1) {
                dataText = textParameter.replace(/<b>.*?<\/b>/g, '<font color="%1">~</font>'.arg(YColors.red))
            } else {
                dataText = textParameter
            }
            }
            temp = dataText

        } else {

        try{
            if(typeof textParameter.例 !== "undefined") {
                if((textParameter.例).constructor === Array) {
                    for(let i = 0; i < textParameter.例.length; i++) {
                        try{
                            if(i===0) {
                                temp = "："
                            }
                            let joinKey = ""
                            if(typeof textParameter.例[i].KEY !== "undefined")
                                joinKey =  getKeyOrText(textParameter.例[i].KEY)
                            temp += getKeyOrText(textParameter.例[i].content , joinKey)
                        } catch(e) {
                        }

                        if(i !== textParameter.例.length-1 && temp !== "：") {
                            temp += "|"
                        }
                    }
                } else  {
                    temp = "："
                    let joinKey = ""
                    try {
                        joinKey = getKeyOrText(textParameter.例.KEY)
                    } catch(e) {
                    }
                    temp += getKeyOrText(textParameter.例, joinKey)
                }
            }} catch(e) {
            temp = "：" + getKeyOrText(textParameter)
        }
        }
        return temp
        //return Object.values(textParameter).join("")
    }

    function getMenteionText(textParameter) {
        let temp = ""
        try{
            if(typeof textParameter.content !== "undefined") {
                if((textParameter.content).constructor === Array) {
                    try{
                        let joinKey = ""
                        if(typeof textParameter.SMALL !== "undefined")
                            joinKey =  getKeyOrText(textParameter.SMALL)
                        temp += getKeyOrText(textParameter.content,joinKey)
                    } catch(e) {
                    }
                } else  {
                    temp = "："
                    let joinKey = ""
                    try {
                        joinKey = getKeyOrText(textParameter)
                    } catch(e) {
                    }
                    temp += getKeyOrText(textParameter, joinKey)
                }
            }} catch(e) {
            temp = "：" + getKeyOrText(textParameter)
        }
        return temp
        //return Object.values(textParameter).join("")
    }

    function createRegRexText(textInput) {
        let temp = ''
        let tempList = textInput.split('/')
        for(let i =0; i < tempList.length; i++) {
            temp += "<"+tempList[i]+".*?>"
            if(i==tempList.length-1) {
                temp+= "(.*?)"
                for(let j =tempList.length-1; j >=0; j--) {
                    temp += "</"+tempList[j]+".*?>.*?"
                }
            } else {
                temp+= ".*?"
            }
        }
        return temp
    }


    function createRegRexTextHaveSelf(textInput) {
        let temp = ''
        let tempList = textInput.split('/')
        for(let i =0; i < tempList.length; i++) {
            temp += "(<"+tempList[i]+".*?>"
            if(i==tempList.length-1) {
                temp+= ".*?"
                for(let j =tempList.length-1; j >=0; j--) {
                    temp += "</"+tempList[j]+".*?>).*?"
                }
            } else {
                temp+= ".*?"
            }
        }
        return temp
    }

    //得到包含义项数组的xml字符串
    //得到包含义项数组的xml字符串
    function getMeanItemSearchXmlData(inputText, xmlData) {
        let temp = null
        let temp2 = createRegRexText(inputText)
        //let reg = new RegExp('<字目.*?>.*?<义项.*?>(.*?)</义项>.*?</字目>','g')
        let reg = new RegExp(temp2,'mg')
        temp = reg.exec(xmlData)
        if(temp.length > 1)
            return temp[1]
        return temp
    }

    //得到包含释义，例句的xml
    function getMeanSearchXmlData(inputText, spliteWord) {
        let temp = []
        if(spliteWord === "义项") {
            let temp2 = createRegRexText(spliteWord)
            let reg = new RegExp(temp2,'mg')
            while(temp2 = reg.exec(inputText)) {
                temp.push(temp2)
            }
        }
        return temp
    }

    function getMeanDataText(meanXml, selectKey) {
        let temp = null
        let tempData = ""
        let tempExec = ""
        let temp2 = createRegRexTextHaveSelf(selectKey)
        let reg = new RegExp(temp2,'mg')
        temp = reg.exec(meanXml)
        if(temp.length > 1)
            //包含释义的xml
            tempData = temp[1]
        reg = new RegExp('>(.*?)<','mg')
        while(temp = reg.exec(tempData)) {
            if(temp.length > 1)
                tempExec += temp[1]
        }
        return tempExec
    }

    //得到最外层xml字段下的字符串内容
    function spliteXmlNodeToGetText(testText,spliteKey) {
        var list = testText.split(spliteKey);
        var m =1
        var search =0
        var result = []
        var resultStr = []
        var lastFirstIndex = 1
        var startSearchIndex = (list[0]+spliteKey).length
        for(var i =0;i<list.length;i++) {
            let temp = list[i].trim()
            console.log('i:'+i+'\n'+temp);
            if(i!==0 && temp[temp.length-1]==='<'){
                m++
            }
            if(temp.substr(temp.length-2)==='</'){
                m--
                if(!m) {
                    result.push([lastFirstIndex,i])
                    let tempstr = null
                    var tempHaveSpliteKey = ""
                    for(var j=lastFirstIndex;j<list.length&&j<=i;j++)
                    {
                        if(tempstr===null) {
                            tempstr = list[j]
                        }else
                            tempstr+=list[j]
                        if(j !== list.length-1) {
                            tempHaveSpliteKey += (list[j] + spliteKey)
                        }
                        if( j>=i&& tempstr!==null){
                            let tempNotSubStartIndex = testText.indexOf(tempHaveSpliteKey,startSearchIndex)
                            let innerStr = testText.substr(startSearchIndex, tempNotSubStartIndex-startSearchIndex+1)
                            innerStr = innerStr.replace(/<.*?>.*?<\/.*?>/g,"")
                            if(! /<.*?>/.test(innerStr)) {
                                let tempNotSubEndIndex = tempNotSubStartIndex + (tempHaveSpliteKey.length-1)
                                startSearchIndex = tempNotSubEndIndex + 1
                                if(tempstr[0] === '>')
                                    tempstr = tempstr.substr(1)
                                if(tempstr.substr(tempstr.length-2) ==='</')
                                    tempstr=tempstr.substr(0,tempstr.length-2)
                                resultStr.push({"subStr":tempstr,"notSubStartIndex":tempNotSubStartIndex,"notSubEndIndex":tempNotSubEndIndex})
                            } else {
                                //从这个索引继续往下
                            }
                        }

                    }
                    lastFirstIndex = i+2
                    m=1
                    i++
                    console.log(result)
                }
            }
        }
        return resultStr
    }

    //释义:例证
    function getMeanRichText(text , splitKey = curWord) {
        let dataText  = ''
        if (dictSelectParaphrasesJsonObject.constructor === Object) {
            if(typeof text.例 !== "undefined") {
                if(inputIsArray(text.例)) {
                    for(let i = 0 ; i < text.例.length; i ++) {
                        dataText += text.例[i].replace(/<b>.*?<\/b>/g, '<font color="%1">~</font>'.arg(YColors.red)) +
                        (i !== text.例.length - 1 ? "  |  ": "")
                    }
                } else {
                    dataText += text.例.replace(/<b>.*?<\/b>/g, '<font color="%1">~</font>'.arg(YColors.red))
                }
            } else {
            if (text.indexOf("<b>") !== -1 && text.indexOf("</b>") !== -1) {
                dataText = text.replace(/<b>.*?<\/b>/g, '<font color="%1">~</font>'.arg(YColors.red))
            } else {
                dataText = text
            }
            }

        } else {
        try{
            dataText = text.replace(/\s*/g,"").replace(new RegExp(splitKey,'g'),'<font color="%1">~</font>'.arg(YColors.red))
        }catch (e) {
            dataText = ''
        }
        let maoHaoPos = dataText.indexOf(":")
        if(maoHaoPos === -1) {
            maoHaoPos = dataText.indexOf("：")
        }
        if(maoHaoPos !== -1)
            dataText =  dataText.slice(0,maoHaoPos+1)+"<font color='%1'>".arg(YColors.grayText)+dataText.slice(maoHaoPos+1)+'</font>'
        try {
            dataText = dataText.replace(/\|/g,"  |  ")
        } catch (e) {
        }
        }
        return dataText;
    }


//    Component{
//        id: id_xml_component
//        XmlListModel{
//            id:id_get_pinyin_list_component
//            property var curSearchPinYinIndex: 0
//            xml: dataLists[curSearchPinYinIndex]
//            query: "/字目"
//            XmlRole { name: "chPinYin"; query: "音项/汉语拼音/string()" }
//            onStatusChanged: {
//                if(status == XmlListModel.Ready && count > 0)
//                {
//                    if(id_get_pinyin_list_component.get(0).chPinYin){
//                        if (!arrayContains(chPinyinList, id_get_pinyin_list_component.get(0).chPinYin)) {
//                            chPinyinList.push(id_get_pinyin_list_component.get(0).chPinYin)
//                        }
//                        if(curSearchPinYinIndex < dataLists.length-1) {
//                            curSearchPinYinIndex++
//                        }else {
//                            let pinyinstemp = chPinyinList
//                            chPinyinList = []
//                            chPinyinList = pinyinstemp
//                        }
//                    }

//                }
//            }
//        }
//    }

//    Component{
//        id: id_xml_pinyinNmus_component
//        XmlListModel{
//            id:id_get_pinyinNum_list_component
//            property var curSearchPinYinIndex: 0
//            xml: dataLists[curSearchPinYinIndex]
//            query: "/字目"
//            XmlRole { name: "chPinYinNum"; query: "音项/汉语拼音/@索引/string()" }
//            onStatusChanged: {
//                if(status == XmlListModel.Ready && count > 0)
//                {
//                    if(id_get_pinyinNum_list_component.get(0).chPinYinNum){
//                        pinyinNumsList[curSearchPinYinIndex] = (id_get_pinyinNum_list_component.get(0).chPinYinNum)
//                        if(curSearchPinYinIndex < dataLists.length-1) {
//                            curSearchPinYinIndex++
//                        }else {
//                            let pinyinstemp = pinyinNumsList
//                            pinyinNumsList = []
//                            pinyinNumsList = pinyinstemp
//                        }
//                    }
//                }
//            }
//        }
//    }



    function startSet() {

        if(!chPinyinList.length && countNumber<50) {
            countNumber ++
            YTimers.delayCall(20, startSet)
            return
        }
        if(isFirstDict) {
            firstDictType = dictType
            firstDictJson = dictJson
            chPinYinList = []
            chPinYinList = chPinyinList

        }
        if (chPinyinList.length > 0) {
            chPinyinSelected = chPinyinList[0]
            if (isFirstDict) {
                resultManager.phoneticSymbolJson = chPinyinSelected
            }
        }
    }

    onDictJsonChanged: {
        chPinyinSelected = ""
        chPinyinList = []
        //dictJson.split("###").forEach(function(dictPhoneObject){
        dictJson.forEach(function(dictPhoneObject){
            try {
                dictPhoneObject = JSON.parse(JSON.parse(dictPhoneObject).json)
            } catch(e) {}
            try {
                if(inputIsArray(dictPhoneObject.音项.汉语拼音)){
                    //if (!arrayContains(chPinyinList, dictPhoneObject.音项.汉语拼音[0].text)) {
                    if (!arrayContains(chPinyinList, dictPhoneObject.音项.汉语拼音[0].content)) {
                        chPinyinList.push(dictPhoneObject.音项.汉语拼音[0].content)
                    }

                } else
                    if (!arrayContains(chPinyinList, dictPhoneObject.音项.汉语拼音.content)) {
                        chPinyinList.push(dictPhoneObject.音项.汉语拼音.content)
                    }
            } catch(e) { console.log('YDictTypeDtChXinHua.qml==search dictPhoneObject.音项.汉语拼音.text error,e:'+e)}
            try {
                if(inputIsArray(dictPhoneObject.音项.汉语拼音)) {
                    if (!arrayContains(pinyinNumsList, dictPhoneObject.音项.汉语拼音[0].索引)) {
                        pinyinNumsList.push(dictPhoneObject.音项.汉语拼音[0].索引)
                    }
                } else
                    if (!arrayContains(pinyinNumsList, dictPhoneObject.音项.汉语拼音.索引)) {
                        pinyinNumsList.push(dictPhoneObject.音项.汉语拼音.索引)
                    }
            } catch(e) { console.log('YDictTypeDtChXinHua.qml==search dictPhoneObject.音项.汉语拼音.索引 error,e:'+e)}
        });
        startSet()
    }

    onChPinyinSelectedChanged: {
        console.log("YDictTypeDtChAncientWord.qml === onChPinyinSelectedChanged chPinyinSelected: ", chPinyinSelected)
        dictSelectParaphrasesJson = getDictSelectParaphrasesJson(chPinyinSelected)
    }

    onChPinyinHeaderSelectedChanged: {
        if(isFirstDict) {
            chPinyinSelected = id_dict_page.chPinyinSelected
            dictSelectParaphrasesJson = getDictSelectParaphrasesJson(chPinyinSelected)
        }
    }

    function inputIsArray(value)  {
        let temp =  value.constructor === Array
        let result = false
        if(temp === true && typeof temp !== "undefined"){
            result = true
        }
        return result
    }

    function getDictSelectParaphrasesJson(phone) {
        console.log("YDictTypeDtChAncientWord.qml === function getDictSelectParaphrasesJson phone: ", phone)
        let jsonObjectMatched = null
        if (typeof phone !== "string" || phone.length <= 0) {
            return jsonObjectMatched
        }
        let pos =  chPinyinList.indexOf(phone)
        //jsonObjectMatched = pos !== -1 ? dictJson.split("###")[pos]: ( dataListsdictJson.split("###").length ? dictJson.split("###")[0]: "")
        //json
        jsonObjectMatched = pos !== -1 ? dictJson[pos]: (dictJson.length ? dictJson[0]: "")
        return jsonObjectMatched
    }

    function getKeyOrText(keyWord,joinKey="") {
        let temp = null
        try{
            if(typeof keyWord["content"] !== "undefined") {
                if(typeof keyWord["content"] === "string")
                    temp = joinKey + keyWord["content"]
                else if(keyWord["content"].constructor === Array) {
                    temp = keyWord["content"].join(joinKey)
                }
            }
            else
                if(typeof keyWord["BU"] !== "undefined")
                    temp = joinKey + keyWord["BU"]
                else if(typeof keyWord == "string")
                    temp = joinKey + keyWord
                else if(keyWord.constructor === Array) {
                    let textTemp = ""
                    for(let i = 0; i < keyWord.length; i++) {
                        if(typeof keyWord[i]["content"] !== "undefined") {
                            if(typeof keyWord[i]["content"] === "string")
                                textTemp += joinKey + keyWord[i]["content"]+"  "
                            else if(keyWord[i]["content"].constructor === Array) {
                                textTemp += keyWord[i]["content"].join(joinKey)
                            }
                        } else if(typeof keyWord[i]["BU"] !== "undefined") {
                            if(typeof keyWord[i]["BU"] === "string")
                                textTemp += joinKey + keyWord[i]["BU"] + "  "
                            else if(keyWord[i]["BU"].constructor === Array) {
                                textTemp += keyWord[i]["BU"].join(joinKey)
                            }
                        }
                    }
                    if(textTemp.length) {
                        temp = textTemp
                    }
                }
        } catch (e) {
        }
        return temp
    }

    Item {
        width: parent.width
        height: id_word_detailParas_column.height
        Column {
            id: id_word_detailParas_column
            spacing: 0
            width: parent.width
            property var paraItemTotalIndex: 0
            property var firstCurDataJson: {
                let temp = ({})
                let tempText = null
                try {
                    tempText = getKeyOrText(dictSelectParaphrasesJsonObject.词目.词条)
                    if(tempText !== null) {
                        if ( typeof  temp["词目"] === "undefined")
                            temp["词目"] = {}
                        if ( typeof  temp["词目"]["词条"] === "undefined")
                            temp["词目"]["词条"] = {}
                        temp["词目"]["词条"]["specialWord"] = ({"specialWord":tempText})
                    }

                } catch (e){}
                try {
                    tempText = getKeyOrText(dictSelectParaphrasesJsonObject.词目.词条.pinyin)
                    if(tempText !== null){
                        if ( typeof  temp["词目"] === "undefined")
                            temp["词目"] = {}
                        if ( typeof  temp["词目"]["词条"] === "undefined")
                            temp["词目"]["词条"] = {}
                        temp["词目"]["词条"]["specialWordPinYin"]  = ({"specialWordPinYin":tempText})
                    }
                } catch (e){}

                ///字目/词目/释文
                try {
                    {
                        if ( typeof  temp["词目"] === "undefined")
                            temp["词目"] = {}
                        if ( typeof  temp["词目"]["释文"] === "undefined")
                            temp["词目"]["释文"] = []
                        if((dictSelectParaphrasesJsonObject.词目.释文.义项).constructor === Array)
                            temp["词目"]["释文"] = dictSelectParaphrasesJsonObject.词目.释文.义项
                        else {
                            if(tempText !== null)
                                temp["词目"]["释文"].push(dictSelectParaphrasesJsonObject.词目.释文.义项)
                        }
                    }
                } catch (e){}

                //古义
                try {
                    if ( typeof  temp["古义"] === "undefined")
                        temp["古义"] = {}
                    if ( typeof  temp["古义"]["释义"] === "undefined")
                        temp["古义"]["释义"] = {}
                    if((dictSelectParaphrasesJsonObject.古义.释义).constructor === Array)
                        temp["古义"]["释义"] = dictSelectParaphrasesJsonObject.古义.释义
                    else {
                        if(tempText !== null)
                            temp["古义"]["释义"]["释义data"] = getAllValueString(dictSelectParaphrasesJsonObject.古义.释义)
                    }
                } catch (e){}

                try {
                    {
                        if ( typeof  temp["古义"] === "undefined")
                            temp["古义"] = {}
                        if ( typeof  temp["古义"]["语体"] === "undefined")
                            temp["古义"]["语体"] = {}
                        if((dictSelectParaphrasesJsonObject.古义.语体).constructor === Array)
                            temp["古义"]["语体"] = dictSelectParaphrasesJsonObject.古义.语体
                        else {
                            if(tempText !== null)
                                temp["古义"]["语体"]["语体data"] =getKeyOrText(dictSelectParaphrasesJsonObject.古义.语体)
                        }
                    }
                } catch (e){}

                return temp
            }

            YLoader {
                id: id_pinyins_loader
                anchors.left: parent.left
                anchors.right: parent.right
                active: !isFirstDict && typeof chPinyinList.length !== "undefined" && chPinyinList.length >= 1
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

                    Row {
                        id: id_dict_ch_pinyin_list
                        height: 52
                        spacing: 10
                        anchors.bottom: parent.bottom

                        Repeater {
                            id: id_dict_ch_pinyin_list_repeater
                            model: chPinyinList

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
                                    console.log("YDictPage.qml === id_dict_ch_pinyin_list.btn.onClicked text: ", text)
                                    chPinyinSelected = text
                                    resultManager.phoneticSymbolJson = text
                                    var nAutoPronType =  YEnum.XinHua
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
                visible: id_font_data.visible && id_font_data.height && id_pinyins_loader.active
            }

            //部首，笔画，结构
            Flow{
                anchors.left: parent.left
                anchors.right: parent.right
                id: id_font_data
                visible: radical !== "" || strokeCount !== 0 || structure !== ""
                property var widthSpace:  80

//                XmlListModel{
//                    id:id_get_xml_data_list_component
//                    property var curSearchPinYinIndex: 0
//                    xml: {
//                        //                        return '<字目 id="P424XCKP"><字条 id="P424XCKPZ01" 部首="亻" 部首笔画数="2" 笔顺="32111" 除部首外笔画数="3" 结构="左右" 字级="二级字">仨</字条><音项><汉语拼音 索引="sa1" 索引链接="https://ydlunacommon-cdn.nosdn.127.net/70121b480993ee4f2df50c0589c4358c.mp3">sā</汉语拼音><注音><BU></BU>ㄚ</注音></音项><释文><义项><释义>三个(“仨”字后面不能再用“个”字或其他量词)</释义><例证>:<例>他们哥<SMALL>儿</SMALL><KEY>仨</KEY></例>|<例><KEY>仨</KEY>瓜俩枣<注 类型="释义">(比喻很少的钱或物)</注>。</例></例证></义项></释文></字目>'
//                        return dictSelectParaphrasesXml
//                    }
//                    query: "/字目"
//                    XmlRole { name: "radical"; query: "字条/@部首/string()" }
//                    XmlRole { name: "radicalStrokeCount"; query: "字条/@部首笔画数/string()" }
//                    XmlRole { name: "notRadicalStrokeCount"; query: "字条/@除部首外笔画数/string()" }
//                    XmlRole { name: "structure"; query: "字条/@结构/string()" }
//                    XmlRole { name: "fontLevel"; query: "字条/@字级/string()" }
//                    XmlRole { name: "markSound"; query: "音项/注音/string()" }
//                    XmlRole { name: "oldReading"; query: "释文/义项/注/string()" }
//                    XmlRole { name: "curWord"; query: "字条/string()" }
//                    XmlRole { name: "mentionData"; query: "注意/string()" }
//                    XmlRole { name: "wordData"; query: "词目/string()" }
//                    //词目/词条
//                    XmlRole { name: "specialWord"; query: "词目/词条"+"/string()" }
//                    XmlRole { name: "specialWordPinYin"; query: "词目/词条/@pinyin"+"/string()" }
//                    //古义
//                    XmlRole { name: "oldWord"; query: "古义/语体"+"/string()" }
//                    XmlRole { name: "oldMeanWord"; query: "古义/释义"+"/string()" }
//                    onStatusChanged: {
//                        if(status == XmlListModel.Ready && count > 0)
//                        {

//                            if(id_get_xml_data_list_component.get(0).oldWord){
//                                if ( typeof  id_word_detailParas_column.firstCurDataJson["古义"] === "undefined")
//                                    id_word_detailParas_column.firstCurDataJson["古义"] = {}
//                                if ( typeof  id_word_detailParas_column.firstCurDataJson["古义"]["语体"] === "undefined")
//                                    id_word_detailParas_column.firstCurDataJson["古义"]["语体"]  = {}
//                                id_word_detailParas_column.firstCurDataJson["古义"]["语体"]["语体data"] = id_get_xml_data_list_component.get(0).oldWord
//                            }

//                            if(id_get_xml_data_list_component.get(0).oldMeanWord){
//                                if ( typeof  id_word_detailParas_column.firstCurDataJson["古义"] === "undefined")
//                                    id_word_detailParas_column.firstCurDataJson["古义"] = {}
//                                if ( typeof  id_word_detailParas_column.firstCurDataJson["古义"]["释义"] === "undefined")
//                                    id_word_detailParas_column.firstCurDataJson["古义"]["释义"]  = {}
//                                id_word_detailParas_column.firstCurDataJson["古义"]["释义"]["释义data"] = id_get_xml_data_list_component.get(0).oldMeanWord
//                            }

//                            if(id_get_xml_data_list_component.get(0).radical){
//                                radical = id_get_xml_data_list_component.get(0).radical
//                            }
//                            if(id_get_xml_data_list_component.get(0).radicalStrokeCount){
//                                radicalStrokeCount = parseInt(id_get_xml_data_list_component.get(0).radicalStrokeCount)
//                            }
//                            if(id_get_xml_data_list_component.get(0).notRadicalStrokeCount){
//                                notRadicalStrokeCount = parseInt(id_get_xml_data_list_component.get(0).notRadicalStrokeCount)
//                            }
//                            if(id_get_xml_data_list_component.get(0).structure){
//                                structure = id_get_xml_data_list_component.get(0).structure
//                            }

//                            if(id_get_xml_data_list_component.get(0).fontLevel){
//                                fontLevel = id_get_xml_data_list_component.get(0).fontLevel
//                            }

//                            if(id_get_xml_data_list_component.get(0).markSound){
//                                markSoundXml = id_get_xml_data_list_component.get(0).markSound
//                            }

//                            //                            //旧读
//                            //                            if(id_get_xml_data_list_component.get(0).oldReading){
//                            //                                console.warn("id_get_pinyin_list_component.get(0).oldReading"+id_get_xml_data_list_component.get(0).oldReading)
//                            //                                oldReadingData = id_get_xml_data_list_component.get(0).oldReading
//                            //                            }
//                            //注意
//                            if(id_get_xml_data_list_component.get(0).mentionData){
//                                mentionData = id_get_xml_data_list_component.get(0).mentionData
//                            }

//                            //当前字
//                            if(id_get_xml_data_list_component.get(0).curWord){
//                                curWord = id_get_xml_data_list_component.get(0).curWord
//                            }

//                            if(id_get_xml_data_list_component.get(0).specialWord){
//                                if ( typeof  id_word_detailParas_column.firstCurDataJson["词目"] === "undefined")
//                                    id_word_detailParas_column.firstCurDataJson["词目"] = {}
//                                if ( typeof  id_word_detailParas_column.firstCurDataJson["词目"]["词条"] === "undefined")
//                                    id_word_detailParas_column.firstCurDataJson["词目"]["词条"]  = {}
//                                id_word_detailParas_column.firstCurDataJson["词目"]["词条"]["specialWord"] = {"specialWord":id_get_xml_data_list_component.get(0).specialWord}
//                            }
//                            if(id_get_xml_data_list_component.get(0).specialWordPinYin){
//                                if ( typeof  id_word_detailParas_column.firstCurDataJson["词目"] === "undefined")
//                                    id_word_detailParas_column.firstCurDataJson["词目"] = {}
//                                if ( typeof  id_word_detailParas_column.firstCurDataJson["词目"]["词条"] === "undefined")
//                                    id_word_detailParas_column.firstCurDataJson["词目"]["词条"]  = {}
//                                id_word_detailParas_column.firstCurDataJson["词目"]["词条"]["specialWordPinYin"] = {"specialWordPinYin":id_get_xml_data_list_component.get(0).specialWordPinYin}
//                            }

//                            let temp = id_word_detailParas_column.firstCurDataJson
//                            id_word_detailParas_column.firstCurDataJson = []
//                            id_word_detailParas_column.firstCurDataJson = temp
//                        }
//                    }
//                }

//                //词目/释义
//                XmlListModel{
//                    id:id_get_simple_word_meanings_mean
//                    property var curSearchPinYinIndex: 0
//                    xml: dictSelectParaphrasesJson
//                    query: "/字目/词目/释文/义项"
//                    //引申分义项
//                    XmlRole { name: "wordMultiMean"; query: "string()" }
//                    onStatusChanged: {
//                        if(status == XmlListModel.Ready && count > 0)
//                        {
//                            for(let i = 0; i < count; i++) {
//                                if(id_get_simple_word_meanings_mean.get(i).wordMultiMean){
//                                    if ( typeof  id_word_detailParas_column.firstCurDataJson["词目"] === "undefined")
//                                        id_word_detailParas_column.firstCurDataJson["词目"] = {}
//                                    if ( typeof  id_word_detailParas_column.firstCurDataJson["词目"]["释文"] === "undefined")
//                                        id_word_detailParas_column.firstCurDataJson["词目"]["释文"]  = []
//                                    id_word_detailParas_column.firstCurDataJson["词目"]["释文"].push({"义项":{"义项data":id_get_simple_word_meanings_mean.get(i).wordMultiMean}})
//                                }
//                            }
//                            let temp = id_word_detailParas_column.firstCurDataJson
//                            id_word_detailParas_column.firstCurDataJson = []
//                            id_word_detailParas_column.firstCurDataJson = temp
//                        }
//                    }
//                }


                Row {
                    visible: radical !== ""
                    width: id_radical_key .width + id_radical_space.width + id_radical_value.width + id_font_data.widthSpace
                    height: 37
                    YText {
                        id: id_radical_key
                        width: settingManager.uiLanguage === YEnum.ZH_CN ? 64 : paintedWidth
                        lineHeightMode: Text.FixedHeight
                        lineHeight: 37
                        font.pixelSize: 28
                        color: YColors.grayText
                        text: YTranslateText.radical
                    }

                    Item {
                        id: id_radical_space
                        anchors.top: parent.top
                        anchors.bottom: parent.bottom
                        width: 10
                    }

                    YText {
                        id: id_radical_value
                        width: paintedWidth
                        lineHeightMode: Text.FixedHeight
                        lineHeight: 37
                        font.pixelSize: 28
                        font.family: fontManager.fontFamilyXinHuaXiHei
                        color: YColors.white
                        //wrapMode: YText.Wrap
                        //anchors.verticalCenter: parent.verticalCenter
                        //anchors.verticalCenterOffset: -5
                        textFormat: Text.RichText
                        text: {
                            //                            let temp = "iVBORw0KGgoAAAANSUhEUgAAABoAAAAiCAYAAABBY8kOAAAACXBIWXMAAAsTAAALEwEAmpwYAAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAAGHSURBVHgB7ZTPKwRhGMefsavIZdmbgzhwdLCSQorLXtQe2P+AHJTiyFF7Ejc3R6Xc3FYOLKXIP+DmoJSSg8MSxudtnyltmR/vzjhovvXpmXnnmefb887zjkiqfyXXdWvwAMuSpDB4h12xUFvYRAyGCe1wKkkKo1V4BKdpfdsQ9H7Wp/AKYRpeoQ5FyMAez7y0HJQ0/9lxnIpYdNANfXrdA19QkiRlDNyGMjABkxJRYYdhFq7Ymk/iAFxgtiNxi6J3sKTX89pdf5QagR1RcJwwCFVdqmt8kQgKs3WLcMm23ev9h1jI18hMnjTG+tYnZw02JUB+5yhPqEEvFLg/1Ed5jfusme7Kmn9D11WxkfngcA2jkFPK3jD8WDN0SJyiYFGNclHeC/1TDTDPw5xfTlbstUDxMeIQnMCRtGqk2zQDpvCULhfgAM4ZAldsRfER2IAzeDMTBsdQsflGfkbeR3+CdehqWo/HSItuNf/TEjH6xfzPxtsboEgHtBWjSEfDxsjrpFNSpbLRN5UyL7YJhuHGAAAAAElFTkSuQmCC"
                            //                            return '<img  align="bottom" height="35" src="data:image/png;base64,%1"></img>'.arg(temp)
                            return radical
                        }
                    }
                }

                Row {
                    width: id_stoke_key .width + id_stroke_space.width + id_stroke_value.width + id_font_data.widthSpace
                    visible: strokeCount !== 0
                    YText {
                        id: id_stoke_key
                        width: settingManager.uiLanguage === YEnum.ZH_CN ? 64 : paintedWidth
                        lineHeightMode: Text.FixedHeight
                        lineHeight: 37
                        font.pixelSize: 28
                        color: YColors.grayText
                        text: YTranslateText.stroke
                    }

                    Item {
                        id: id_stroke_space
                        anchors.top: parent.top
                        anchors.bottom: parent.bottom
                        width: 10
                    }

                    YText {
                        id: id_stroke_value
                        width: paintedWidth
                        lineHeightMode: Text.FixedHeight
                        lineHeight: 37
                        font.pixelSize: 28
                        color: YColors.white
                        //wrapMode: YText.Wrap
                        text: strokeCount
                    }
                }

                Row {
                    visible: structure !== ""
                    width: id_structure_key .width + id_structure_space.width + id_structure_value.width + id_font_data.widthSpace
                    YText {
                        id: id_structure_key
                        width: settingManager.uiLanguage === YEnum.ZH_CN ? 64 : paintedWidth
                        lineHeightMode: Text.FixedHeight
                        lineHeight: 37
                        font.pixelSize: 28
                        color: YColors.grayText
                        text: YTranslateText.structure
                    }

                    Item {
                        id: id_structure_space
                        anchors.top: parent.top
                        anchors.bottom: parent.bottom
                        width: 10
                    }

                    YText {
                        id: id_structure_value
                        width: paintedWidth
                        lineHeightMode: Text.FixedHeight
                        font.family: fontManager.fontFamilyXinHuaXiHei
                        lineHeight: 37
                        font.pixelSize: 28
                        color: YColors.white
                        //wrapMode: YText.Wrap
                        text: structure
                    }
                }

            }

            YSpacingForColumn{
                visible: id__markSound_and_fontLevel.visible && id__markSound_and_fontLevel.height
                height: 10
            }

            //注音， 字级
            Row{
                anchors.left: parent.left
                anchors.right: parent.right
                id: id__markSound_and_fontLevel
                visible: {
                    return  markSound !== "" || fontLevel.length
                }
                property var widthSpace:  80
                Row {
                    visible: markSound !== ""
                    width: id_markSound_key .width + id_markSound_space.width + id_markSound_value.width + id__markSound_and_fontLevel.widthSpace
                    YText {
                        id: id_markSound_key
                        width: settingManager.uiLanguage === YEnum.ZH_CN ? 64 : paintedWidth
                        lineHeightMode: Text.FixedHeight
                        lineHeight: 37
                        font.pixelSize: 28
                        color: YColors.grayText
                        text: YTranslateText.markSound
                    }

                    Item {
                        id: id_markSound_space
                        anchors.top: parent.top
                        anchors.bottom: parent.bottom
                        width: 10
                    }

                    YText {
                        id: id_markSound_value
                        width: paintedWidth
                        lineHeightMode: Text.FixedHeight
                        lineHeight: 37
                        font.pixelSize: 28
                        font.family: fontManager.fontFamilyXinHuaXiHei
                        color: YColors.white
                        anchors.top: parent.top
                        anchors.topMargin: 4
                        //wrapMode: YText.Wrap
                        //anchors.verticalCenter: parent.verticalCenter
                        //anchors.verticalCenterOffset: -5
                        text: markSound
                    }
                }

                Row {
                    width: id_fontLevel_key .width + id_fontLevel_space.width + id_fontLevel_value.width + id__markSound_and_fontLevel.widthSpace
                    visible: fontLevel.length
                    YText {
                        id: id_fontLevel_key
                        width: settingManager.uiLanguage === YEnum.ZH_CN ? 64 : paintedWidth
                        lineHeightMode: Text.FixedHeight
                        lineHeight: 37
                        font.pixelSize: 28
                        color: YColors.grayText
                        text: YTranslateText.fontLevel
                    }

                    Item {
                        id: id_fontLevel_space
                        anchors.top: parent.top
                        anchors.bottom: parent.bottom
                        width: 10
                    }

                    YText {
                        id: id_fontLevel_value
                        width: paintedWidth
                        lineHeightMode: Text.FixedHeight
                        font.family: fontManager.fontFamilyXinHuaXiHei
                        lineHeight: 37
                        font.pixelSize: 28
                        color: YColors.white
                        //wrapMode: YText.Wrap
                        text: fontLevel
                    }
                }
            }


            //繁体字，异体字
            Flow{
                id: id_old_different_font
                anchors.left: parent.left
                anchors.right: parent.right
                property var oldChinese: {
                    let temp = ""
                    try {
                        if(typeof dictSelectParaphrasesJsonObject.字形.繁体字.content !== "undefined")
                            temp = dictSelectParaphrasesJsonObject.字形.繁体字.content
                        else if(typeof dictSelectParaphrasesJsonObject.字形.繁体字 !== "undefined")
                            temp = getKeyOrText(dictSelectParaphrasesJsonObject.字形.繁体字)
                    } catch (e) {
                        try {
                            temp = getKeyOrText(dictSelectParaphrasesJsonObject.字形.繁体字)
                        } catch(e) {}
                    }
                    if (temp === null || typeof temp == "undefined")
                        temp = ""
                    return temp
                }
//                XmlListModel{
//                    id:id_oldChinese_data
//                    property var curSearchPinYinIndex: 0
//                    xml: dictSelectParaphrasesJson
//                    query: "/字目/字形/繁体字"
//                    //繁体字
//                    XmlRole { name: "oldChinese"; query: "string()" }

//                    onStatusChanged: {
//                        if(status == XmlListModel.Ready && count > 0)
//                        {
//                            if(id_oldChinese_data.get(0).oldChinese){
//                                id_old_different_font.oldChinese = id_oldChinese_data.get(0).oldChinese
//                            }
//                        }
//                    }
//                }

//                XmlListModel{
//                    id:id_differentChinese_data
//                    property var curSearchPinYinIndex: 0
//                    xml: dictSelectParaphrasesJson
//                    query: "/字目/字形/异体字"
//                    XmlRole { name: "differentFont"; query: "string()" }
//                    onStatusChanged: {
//                        if(status == XmlListModel.Ready && count > 0)
//                        {
//                            for(let i = 0; i < count; i++) {
//                                if(id_differentChinese_data.get(i).differentFont){
//                                    differentFonts.push(id_differentChinese_data.get(i).differentFont)
//                                    if(i === count -1 ) {
//                                        let listTemp =  differentFonts
//                                        differentFonts = []
//                                        differentFonts = listTemp
//                                    }
//                                }
//                            }
//                        }
//                    }
//                }

//                XmlListModel{
//                    id:id_get_meanings_list
//                    property var curSearchPinYinIndex: 0
//                    xml: dictSelectParaphrasesJson
//                    query: "/字目/释文/义项"
//                    //繁体字
//                    XmlRole { name: "meaningsList"; query: "string()" }
//                    onStatusChanged: {
//                        if(status == XmlListModel.Ready && count > 0)
//                        {
//                            meaningsList = []
//                            for(let i = 0; i < count; i++) {
//                                if(id_get_meanings_list.get(i).meaningsList){
//                                    var keyWord = "义项"+i
//                                    var m = {}
//                                    m[keyWord] = id_get_meanings_list.get(i).meaningsList
//                                    meaningsList.push(m)
//                                    if(i === count -1) {
//                                        let temp = meaningsList
//                                        meaningsList = []
//                                        meaningsList = temp
//                                    }
//                                }
//                            }
//                        }
//                    }
//                }

                Row {
                    //width:
                    visible: id_old_different_font.oldChinese.length
                    width: visible ? id_old_chinese_rectangle.width +id_old_chinese_space.width + id_old_chinese_values.width + 40 : 0
                    Rectangle {
                        id: id_old_chinese_rectangle
                        height: 26
                        width: 26
                        radius: 30
                        color: YColors.transparent
                        border.color: YColors.white
                        anchors.verticalCenter: parent.verticalCenter
                        visible: id_old_different_font.oldChinese.length
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
                        text: id_old_different_font.oldChinese.trim()
                        visible: id_old_chinese_rectangle.visible
                    }
                }

                //异体字
                Row {
                    //width:
                    visible: {
                        return differentFonts.length

                    }

                    Rectangle {
                        id: id_different_chinese_rectangle
                        height: 26
                        width: 26
                        radius: 30
                        color: YColors.transparent
                        border.color: YColors.white
                        anchors.verticalCenter: parent.verticalCenter
                        visible: differentFonts.length
                        YText {
                            id: id_different_chinese_text
                            anchors.centerIn: parent
                            font.family: fontManager.fontFamilyXinHuaXiHei
                            font.pixelSize: 20
                            text: YTranslateText.differentFont
                        }
                    }

                    Item{
                        width: 11
                        height: 26
                        visible: id_different_chinese_rectangle.visible
                    }

                    //异体字上标等
                    Repeater{
                        model:differentFonts
                        Row{
                            id: id_different_simple
                            visible: JSON.stringify(model.modelData).length
                            width: visible ? (id_different_releate_rectangle.width + id_star_space.width + id_star.width + id_different_chinese_value.width + 18) : 0
                            property var differentReleate: {
                                let temp = ""
                                try {
                                    temp = dictSelectParaphrasesJsonObject.字形.异体字[index].关联.content
                                } catch (e) {
                                    try {
                                        temp = dictSelectParaphrasesJsonObject.字形.异体字[index].关联
                                    } catch(e) {}
                                }
                                if(typeof temp === "undefined")
                                    temp = ""
                                return temp
                            }
//                            XmlListModel{
//                                id:id_different_releate_data
//                                xml: dictSelectParaphrasesJson
//                                query: "/字目"
//                                //繁体字
//                                XmlRole { name: "differenReleate"; query: "字形/异体字["+(index+1)+"]/@关联/string()" }
//                                onStatusChanged: {
//                                    if(status == XmlListModel.Ready && count > 0)
//                                    {
//                                        if(id_different_releate_data.get(0).differenReleate){
//                                            id_different_simple.differentReleate = id_different_releate_data.get(0).differenReleate
//                                        }
//                                    }
//                                }
//                            }

                            Rectangle{
                                id:id_different_releate_rectangle
                                anchors.top: parent.top
                                anchors.bottom: parent.bottom
                                height: visible ? 16 : 0
                                width: id_releate_text.paintedWidth
                                //radius: 30
                                color: YColors.transparent
                                border.color: YColors.transparent
                                visible: JSON.stringify(model.modelData).length && id_different_simple.differentReleate.length
                                YText{
                                    id:id_releate_text
                                    anchors.top: parent.top
                                    anchors.left: parent.left
                                    font.pixelSize: 12
                                    font.family: fontManager.fontFamilyXinHuaXiHei
                                    text: {
                                        return id_different_simple.differentReleate.replace(/:/g,"：").replace(/,/g,"，")
                                    }
                                    color: YColors.white
                                    visible: {
                                        return  id_different_simple.differentReleate.length
                                    }
                                }
                            }

                            Item {
                                id:id_star_space
                                width: visible ? 6 : 0
                                height: 16
                                visible:id_star.visible
                            }

                            YText{
                                id:id_star
                                anchors.top: parent.top
                                width: visible ? 12+6 : 0
                                font.family: fontManager.fontFamilyXinHuaXiHei
                                height: 12
                                text: "*"
                                visible:id_different_chinese_value.visible
                            }

                            YText {
                                id: id_different_chinese_value
                                width: visible ? paintedWidth : 0
                                font.family: fontManager.fontFamilyXinHuaXiHei
                                anchors.verticalCenter: parent.verticalCenter
                                font.pixelSize: 28
                                color: YColors.red
                                text: {
                                    let tempText = getKeyOrText(model.modelData)
                                    return tempText !== null ? tempText.trim() : ""
                                }
                                visible: id_different_chinese_rectangle.visible && text.length
                            }
                        }
                    }
                }
            }

            YSpacingForColumn {
                height: 8
                visible: id_mean_method_text_active.active
            }

            YLoader {
                id: id_mean_method_text_active
                active: {
                    try {
                        let temp = getKeyOrText(dictSelectParaphrasesJsonObject.释文.用法)
                        return temp.length
                    } catch (e) { return false }
                }
                sourceComponent: id_mean_method_text_component
            }

            Component {
                id: id_mean_method_text_component
                //字目/释文/用法
                YText {
                    id: id_mean_method_text
                    font.family: fontManager.fontFamilyXinHuaXiHei
                    //anchors.top: parent.top
                    anchors.left: parent.left
                    //anchors.leftMargin:  17
                    //anchors.right: parent.right
                    width: 582
                    font.pixelSize: 28
                    //width: parent.width - (id_word_index_text.width) - anchors.leftMargin
                    wrapMode: YText.WordWrap
                    textFormat: Text.RichText
                    color: YColors.white
                    visible: text.length
                    text: {
                        let tempText = ""
                        try {
                            tempText = getKeyOrText(dictSelectParaphrasesJsonObject.释文.用法)
                            if(tempText !== null) {
                                tempText =  id_dict_type_ch_ancientword.getMeanRichText(tempText.replace(/\s*/g,""))
                                tempText = tempText.replace(/参看.*?页/g,"")
                            }
                        } catch(e) {}
                        tempText.replace(/:/g,"：").replace(/,/g,"，")
                        return tempText
                    }
                }
            }

            YSpacingForColumn {
                height: 8
                visible: id_meanings_repeater.count
            }

            //义项组件
            YDictTypeDtChXinHuaMeanComponent {
                id:id_meanings_repeater
                contentWidth: 538
                meanList: {
                    let temp = []
                    try {
                        if((dictSelectParaphrasesJsonObject.释文.义项).constructor === Array)
                            temp = dictSelectParaphrasesJsonObject.释文.义项
                        else {
                            temp.push(dictSelectParaphrasesJsonObject.释文.义项)
                        }
                    } catch(e) {
                    }
                    return temp
                }
                queryMeanData: "/字目/释文/义项"
            }



            YDictTypeDtChXinHuaWordsComponent{
                id: id_word_rectangle_repeater
                contentWidth: id_meanings_repeater.contentWidth
                modelList: {
                    let temp = []
                    try {
                        if((dictSelectParaphrasesJsonObject.词目).constructor === Array)
                            temp = dictSelectParaphrasesJsonObject.词目
                        else {
                            temp.push(dictSelectParaphrasesJsonObject.词目)
                        }
                    } catch(e) {
                    }
                    return temp
                }
                queryData: "/字目/词目"
            }

            YText {
                id: id_mention_key_text
                color: YColors.white
                font.family: fontManager.fontFamilyXinHuaXiHei
                font.pixelSize: 28
                visible: id_mention_key_text.text.length
                text: {
                    let temp = ""
                    try {
                        temp = mentionData.replace(/:/g,"：").replace(/,/g,"，")
                    } catch (e) {}
                    return temp
                }
            }

            //古义
            Flow {
                id: id_word_mean_flow
                anchors.left: parent.left
                width:  id_meanings_repeater.contentWidth
                property var firstMean: ""
                property var nextMean: ""
                property bool showCircleRectangle: false
                property var maoHaoPos: -1

                YDtTypeDtChXinHuaOldMeanTextComponent {
                    id: id_mean_text
                }

                Item {
                    width: 26
                    height: 37
                    visible: id_word_mean_flow.showCircleRectangle
                    Rectangle {
                        id: id_connectData_rectangle
                        height: 26
                        width: 26
                        radius: 30
                        color: YColors.transparent
                        border.color: YColors.grayText
                        anchors.top: parent.top
                        anchors.topMargin: 6
                        //anchors.verticalCenter: parent.verticalCenter
                        visible: id_word_mean_flow.showCircleRectangle

                        YText {
                            id: id_connectData_text
                            anchors.centerIn: parent
                            color: YColors.grayText
                            font.family: fontManager.fontFamilyXinHuaXiHei
                            font.pixelSize: 20
                            text: YTranslateText.connectFont
                        }
                    }
                }

                Repeater {
                    model: {
                        let modelTemp = []
                        id_word_mean_flow.maoHaoPos = -1
                        try {
                            for(let i = 0; i < id_word_mean_flow.nextMean.length; i++) {
                                modelTemp.push(id_word_mean_flow.nextMean[i])
                            }

                            let maoHaoPos = id_word_mean_flow.nextMean.indexOf(":")
                            if(maoHaoPos === -1) {
                                maoHaoPos = id_word_mean_flow.nextMean.indexOf("：")
                            }

                            id_word_mean_flow.maoHaoPos = maoHaoPos

                        } catch(e) {}

                        return modelTemp
                    }
                    YText {
                        id: id_next_mean_text
                        width: visible ? (Math.min(id_meanings_repeater.contentWidth, paintedWidth))  : 0
                        font.family: fontManager.fontFamilyXinHuaXiHei
                        verticalAlignment: Text.AlignTop
                        font.pixelSize: 28
                        color:  (id_word_mean_flow.maoHaoPos !==-1 ? (index > id_word_mean_flow.maoHaoPos ? YColors.grayText : YColors.white) : YColors.white)
                        wrapMode: paintedWidth > id_meanings_repeater.contentWidth ? YText.WordWrap : YText.NoWrap
                        textFormat: YText.RichText
                        text: {
                            let textTemp = model.modelData
                            if(textTemp !== " ")
                                textTemp = id_dict_type_ch_ancientword.getMeanRichText(textTemp)
                            textTemp = textTemp.replace(/\|/g," |  ")
                            try {
                                //有注，短线变红色
                                if(id_word_detailParas_column.firstCurDataJson["古义"]["释义"]["注"]['meanMention'].length) {

                                    textTemp = textTemp.replace(/\-/g,'<font color="%1">-</font>'.arg(YColors.red))
                                } } catch(e) {}
                            if(index === 0 ) textTemp = "&nbsp;" + textTemp
                            try {
                                if(textTemp[0] === " ") {
                                    textTemp = "&nbsp;" + textTemp.substr(1)
                                }
                                let maoHaoPos = textTemp.indexOf(":")
                                if(maoHaoPos === -1) {
                                    maoHaoPos = textTemp.indexOf("：")
                                }
                                if(maoHaoPos !== -1) {
                                    textTemp =  textTemp.slice(0,maoHaoPos+1)+""
                                }

                                let rightParentThesesPos = textTemp.indexOf(")")
                                if(rightParentThesesPos !== -1)
                                    textTemp = textTemp.substr(0,rightParentThesesPos)+ "&nbsp;" + textTemp.substr(rightParentThesesPos)+ " "

                            } catch(e) {}

                            textTemp = textTemp.replace(/:/g,"：").replace(/,/g,"，")
                            return  textTemp
                        }
                        visible: text.length
                    }
                }
            }
        }
    }
}



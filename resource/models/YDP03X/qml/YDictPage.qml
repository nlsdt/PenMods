import QtQuick 2.12
import com.youdao.pen 1.0

import BaseQml 1.0
import "./dicts"
import "./components"
import "./i18n"
import "./commons"

YPage {
    id: id_dict_page
    objectName: "YPage===YDictPage.qml"

    readonly property int tagsIndex: id_container_flickable.privateTagsIndex
//    readonly property bool displayWords: (id_dict_listview.count > 0)
//                                         && (tagsIndex >= 0)
    property var stackQueryResult: []

    property string title: ""

    property int strokeCount: 0
    property string structure: ""
    property string radical: ""
    property int backCountY: 0
    property int backContentYCount : 0
    property bool searchMoreIsClick: false
    property var containWidth: 614 + 8
    property alias needSearchMoreVisible: id_head_search_more_loader.visibleSet
    property bool top_detail_button_visible: false
    property bool emptyTipVisible: false
    property var backContentYPos:null

    property var chPinYinsSound: null //中文多音字发音字段
    property var chWordSourceData: ""
    property var ocrContentString: ""
    property var sentenceMeanPos: 0
    property bool isButtonIsRePress: true
    readonly property bool isShowPinYinDict: null !== id_dict_content_view.pinYinDictIndex && id_dict_content_view.pinYinDictIndex >= 0 &&
                                             resultManager.itemCount === 1

    property var chPinYinList: []
    property var firstDictJson: ({})
    property var firstDictType: null
    //当第一本词典是新华时，将新华字典发音数据从词典页传递到词头
    property var xinHuaPinYinNums: [] // 新华词典发音索引
    property var buPinYinNums: [] //古代汉语发音索引
    property string chPinyinSelected: chPinYinList.length ? chPinYinList[0] : ""//resultManager.chPinyinListSelected
    property var lastCollinsPrimaryLoadMoreVisible: false
    property var ocrStopShowCollins: true
    property var collinsSelect: []
    property var isLoadMoreCount: 0
    property bool isPhoneticSymbolShow: false
    //第一本是否加载完
    property bool isFirstDictLoaded: false

    property var dictPageObjet: null

    //记录当前词典操作
    property int currentDictType: -1

    onChPinYinListChanged: {
        chPinyinSelected = chPinYinList.length ? chPinYinList[0] : ""
    }

    property var reportedSet:new Set()
    onOcrContentStringChanged:  {
        console.log("headviewModel:"+ocrContentString)
        //id_dict_listview.repeaterModel =  ocrContentString
        id_dict_content_view_repeater_empty_check_timer.restart()
    }
    property alias isScannig: id_dict_listview.isScanning
    onIsScannigChanged: {
        if(!isScannig)
            id_dict_content_view_repeater_empty_check_timer.restart()
        else {
            if(resultManager.itemCount) {
                ocrContentString = ""
            }
        }
    }

    property int pointScanItemsWidth: 0

    function initStrokeInfo() {
        strokeCount = 0
        structure = ""
        radical = ""
    }

    function arrayContains(arr, val) {
        for (var i = 0; i < arr.length; i++) {
            if (arr[i] === val) {
                return true;
            }
        }
        return false;
    }

    function simpleParaphraseFunc(content, dictType) {
        let qsSrcLang = resultManager.srcLang
        let qsDstLang = resultManager.dstLang
        if (dictType === YEnum.AsyncLocalTran || dictType === YEnum.NetTran)
            return ['{"pos":"","tran":"' + content.replace(/\\"/g,"\"").replace(/"/g,"\\\"") + '"}', qsSrcLang, qsDstLang]

        let dictJson = null;
        try{
            dictJson = JSON.parse(content)
        }
        catch(err){
            console.warn("parse dict json error:", err);
            return ['{"pos":"","tran":""}', qsSrcLang, qsDstLang]
        }
        let pos = ""
        let trans = ""
        switch (dictType) {
        case YEnum.DtChChinese:
            if (typeof dictJson.meanings != "undefined") {
                if (typeof dictJson.meanings[0].pos != "undefined") pos = dictJson.meanings[0].pos
                if (typeof dictJson.meanings[0].value != "undefined") trans = dictJson.meanings[0].value
            } else if (typeof dictJson.details != "undefined" && typeof dictJson.details[0].meanings != "undefined") {
                if (typeof dictJson.details[0].meanings[0].pos != "undefined") pos = dictJson.details[0].meanings[0].pos
                if (typeof dictJson.details[0].meanings[0].value != "undefined") trans = dictJson.details[0].meanings[0].value
            }
            qsSrcLang = "zh"
            qsDstLang = "zh"
            break
        case YEnum.DtPEPPrim:
            trans = dictJson.trans;
            qsSrcLang = "en"
            qsDstLang = "zh"
            break;
        case YEnum.DtChEnglish:
        case YEnum.DtChEnKid:
            if (typeof dictJson.pure.word != "undefined") {
                trans = dictJson.pure.word.trs[0]["#text"]
            }
            else {
                trans = dictJson.pure[0].w
            }
            qsSrcLang = "zh"
            qsDstLang = "en"
            break
        case YEnum.DtChLarge:
            qsSrcLang = "zh"
            if (typeof dictJson.dataList[0].trs[0].pos != "undefined") pos = dictJson.dataList[0].trs[0].pos
            if (typeof dictJson.dataList[0].trs[0].tr.en != "undefined") {
                trans = dictJson.dataList[0].trs[0].tr.en
                qsDstLang = "en"
            } else if (typeof dictJson.dataList[0].trs[0].tr.cn != "undefined") {
                trans = dictJson.dataList[0].trs[0].tr.cn
                qsDstLang = "zh"
            }
            break
        case YEnum.DtChAncientWord:
            if (typeof dictJson.paraphrases[0].detailParas[0].paraItems[0].para != "undefined") {
                trans = dictJson.paraphrases[0].detailParas[0].paraItems[0].para
            }
            qsSrcLang = "zh"
            qsDstLang = "zh"
            break
        case YEnum.DtSenior:
            if (typeof dictJson.trans[0].pos != "undefined") pos = dictJson.trans[0].pos
            if (typeof dictJson.trans[0].sense != "undefined") trans = dictJson.trans[0].sense
            qsSrcLang = "en"
            qsDstLang = "zh"
            break
        case YEnum.DtWebster:
            if (typeof dictJson.wordList[0].def.sensb[0].et != "undefined") pos = dictJson.wordList[0].def.sensb[0].et
            if (typeof dictJson.wordList[0].def.sensb[0].meaning[0].sense == "undefined") {
                trans = dictJson.wordList[0].def.sensb[0].meaning[0].dt.content[0]
            } else {
                trans = dictJson.wordList[0].def.sensb[0].meaning[0].sense[0].dt.content[0]
            }
            qsSrcLang = "en"
            qsDstLang = "en"
            break
        case YEnum.DtOxford:
            if (typeof dictJson.wordList[0]["p-g"] != "undefined") {
                pos = dictJson.wordList[0]["p-g"][0].p[0].p
                if (typeof dictJson.wordList[0]["p-g"][0]["sd-g"] != "undefined") {
                    trans = dictJson.wordList[0]["p-g"][0]["sd-g"][0].sd.chn.content
                }
            } else {
                pos = dictJson.wordList[0]["h-g"].p[0].p
                if (typeof dictJson.wordList[0]["h-g"]["sd-g"] != "undefined") {
                    trans = dictJson.wordList[0]["h-g"]["sd-g"][0].sd.chn.content
                }
            }
            qsSrcLang = "en"
            qsDstLang = "zh"
            break
        case YEnum.DtTOEFL:
        case YEnum.DtGRE:
        case YEnum.DtSSAT:
        case YEnum.DtSAT:
        case YEnum.DtIELTS:
            qsSrcLang = "en"
            if (typeof dictJson.content.trans[0].pos != "undefined") pos = dictJson.content.trans[0].pos
            if (typeof dictJson.content.trans[0].tran[0].cn != "undefined") {
                trans = dictJson.content.trans[0].tran[0].cn
                qsDstLang = "zh"
            } else {
                trans = dictJson.content.trans[0].tran[0].en
                qsDstLang = "en"
            }
            break
        case YEnum.DtSimple:
        case YEnum.DtEnChKid:
            if (typeof dictJson.pure.word != "undefined" && typeof dictJson.pure.word.trs != "undefined") {
                pos = dictJson.pure.word.trs[0].pos
                trans = dictJson.pure.word.trs[0].tran
            }
            else if(typeof dictJson.pure.m != "undefined"){
                pos = dictJson.pure.m[0].pos
                trans = dictJson.pure.m[0].m
            }else if(typeof dictJson.pure.brief_meaning != "undefined")//mango新词典解析
            {
                pos = dictJson.pure.brief_meaning[0].pos
                trans = dictJson.pure.brief_meaning[0].meanings[0].meaning
            }
            qsSrcLang = "en"
            qsDstLang = "zh"
            break
        case YEnum.DtChKo:
            if (typeof dictJson.dataList[0].meanings.sense[0].pos != "undefined") {
                pos = dictJson.dataList[0].meanings.sense[0].pos
            }
            if (typeof dictJson.dataList[0].meanings.sense[0].trs != "undefined"
                    && typeof dictJson.dataList[0].meanings.sense[0].trs[0].tr != "undefined") {
                trans = dictJson.dataList[0].meanings.sense[0].trs[0].tr
            }
            qsSrcLang = "zh"
            qsDstLang = "ko"
            break
        case YEnum.DtKoCh:
            if (typeof dictJson.dataList[0].pos != "undefined") {
                pos = dictJson.dataList[0].meanings.sense[0].pos
            }
            if (typeof dictJson.dataList[0].meanings.sense[0].trs != "undefined"
                    && typeof dictJson.dataList[0].meanings.sense[0].trs[0].tr != "undefined") {
                trans = dictJson.dataList[0].meanings.sense[0].trs[0].tr
                trans = trans.replace(/<pinyin>.+?<\/pinyin>/g, '')
            }
            qsSrcLang = "ko"
            qsDstLang = "zh"
            break
        default:
            break
        }
        if (typeof pos != "string") pos = ""
        if (typeof trans != "string") {
            trans = ""
        } else {
            //避免换行符和 html tag 影响显示效果，特殊处理一下
            trans = trans.replace(/\n/g, " ")
            trans = trans.replace(/<[^>]+>/g, "")
        }
        return ['{"pos":"' + pos + '","tran":"' + trans.replace(/"/g,"\\\"") + '"}', qsSrcLang, qsDstLang]
    }

//    YTimer {
//        id: id_set_ch_header_show
//        interval: 600
//        onTriggered: {
//            if(firstDictType === settingManager.topShowChDict || firstDictType === settingManager.topShowChDict) {
//                isFirstDictLoaded = true
//            } else {
//                id_set_ch_header_total_show.restart()
//            }
//        }
//    }

    function getDictContentValue(dictType,content,index){
        if(index === 0) {
            firstDictType = dictType
            let temp = ({})
            try {
                temp = JSON.parse(content)
                if(content.length)
                    firstDictJson = JSON.parse(content)
            } catch(e) {
                temp = content
                 if(content.length)
                    firstDictJson = content
            }

            if(firstDictType !== YEnum.DtXinHua) {
                if (typeof temp.strokeCount != "undefined") {
                    id_dict_page.strokeCount = temp.strokeCount
                    //haveStrokeInfo = true
                }
                if ((typeof temp.structure != "undefined") && (temp.structure.length > 0)) {
                    id_dict_page.structure = temp.structure.split("结构").join('')
                    //haveStrokeInfo = true
                }
                if ((typeof temp.radical != "undefined") && (temp.radical.length > 0)) {
                    id_dict_page.radical = temp.radical
                    //haveStrokeInfo = true
                }
            }
        }

        switch (dictType) {
        case YEnum.DtChChinese:
        case YEnum.DtChIdiom:
            if(firstDictType === dictType) {
                let dictJson = JSON.parse(content)
                if (YEnum.WGT_Ch_Group === resultManager.currentQueryType) {
                    resultManager.phoneticSymbolJson = dictJson.pinyin.join(" ")
                    if(typeof  dictJson.pinyinWithNum != "undefined")
                        chPinYinsSound = typeof dictJson.pinyinWithNum!="string"?dictJson.pinyinWithNum.join(" ")
                                                                                :dictJson.pinyinWithNum
                    if (typeof  dictJson.source != "undefined") {
                        chWordSourceData = dictJson.source
                    }

                } else {
                    resultManager.phoneticSymbolJson = dictJson.details[0].pinyin
                    if(typeof dictJson.details[0].pinyinWithNum != "undefined")
                        chPinYinsSound =typeof dictJson.details[0].pinyinWithNum!="string" ? dictJson.details[0].pinyinWithNum.join(" ")
                                                                                           : dictJson.details[0].pinyinWithNum
                }
            }
            break
        case YEnum.DtChPoemDict:
            if(firstDictType === dictType) {
            let dictJsonStr = JSON.parse(content)
            if(dictJsonStr.source === "poem_data" ){
                dictJsonStr.poems.some(function(objectJson){
                    if(typeof objectJson.detail.title.origin != "undefined"
                            && typeof objectJson.detail.title.position != "undefined") {
                        let pos = objectJson.detail.title.origin.trim().indexOf(resultManager.currentQuery)
                        let pinYinPosIndexs = objectJson.detail.title.position
                        if (pos === -1) {
                            let originProcess = objectJson.detail.title.origin.replace("·","")
                            pos = originProcess.indexOf(resultManager.currentQuery)
                            for (let k = 0; k < objectJson.detail.title.origin.length; k++) {
                                if (objectJson.detail.title.origin[k] === '·') {
                                    objectJson.detail.title.origin[k] = ""
                                    for (let m = 0; m < pinYinPosIndexs.length; m++) {
                                        if (pinYinPosIndexs[m] > k + 1) {
                                            pinYinPosIndexs[m]  = pinYinPosIndexs[m] - 1
                                        }
                                    }
                                }
                            }
                        }
                        if(typeof objectJson.detail.title.pinyinWithNum!="undefined"
                                && pos != -1 ) {
                            let pinYinJson ="["
                            if(typeof objectJson.detail.title.position!="undefined") {
                                let pinYinPos = -1
                                for(let i = 0; i<resultManager.currentQuery.length; i++) {
                                    pinYinPos = pinYinPosIndexs.indexOf(pos+i+1)
                                    if( pinYinPos !== -1) {
                                        pinYinJson+="{"+'"pinYinPos"'+':'+ (i+1)+
                                                ',"pinyinWithNum"'+':"'+objectJson.detail.title.pinyinWithNum[pinYinPos]+'"},'
                                    } else {
                                    }
                                }
                                if (pinYinJson.indexOf("},") !== -1)
                                    pinYinJson = pinYinJson.substr(0,pinYinJson.length -1) + "]"
                                //                                for(let j = 0; j<objectJson.detail.title.position.length; j++)
                                //                                {
                                //                                    pinYinJson+="{"+'"pinYinPos"'+':'+objectJson.detail.title.position[j]+',"pinyinWithNum"'+':"'+objectJson.detail.title.pinyinWithNum[j]+'"}'
                                //                                    pinYinJson+=(j!=objectJson.detail.title.position.length-1)?",":"]"
                                //                                }

                            }
                            console.log("*************pinYinJson:"+pinYinJson)
                            chPinYinsSound =pinYinJson.indexOf("{") !== -1 ? pinYinJson : objectJson.detail.title === resultManager.currentQuery ?
                                                                                 (typeof objectJson.detail.title.pinyinWithNum != "string" ?
                                                                                      objectJson.detail.title.pinyinWithNum.join(" ") :
                                                                                      objectJson.detail.title.pinyinWithNum) : null
                            return true
                        }
                    }
                })
            }
            else if(dictJsonStr.source === "poem_sentence")
            {
                dictJsonStr.poems.some(function(objectJson){

                    if(typeof objectJson.detail.content!="undefined")
                    {
                        for(let j=0;j<objectJson.detail.content.length;j++)
                        {
                            let contentJson = objectJson.detail.content[j]
                            for(let i=0;i<contentJson.sentences.length;i++)
                            {
                                let jObjec =contentJson.sentences[i]
                                let pos = jObjec.origin.trim().indexOf(resultManager.currentQuery)
                                if(typeof jObjec.pinyinWithNum !="undefined" && pos !== -1)
                                {
                                    let pinYinJson ="["
                                        if(typeof jObjec.position!="undefined") {
                                            let pinYinPos = -1
                                            for(let i = 0; i < resultManager.currentQuery.length; i++) {
                                                 pinYinPos = jObjec.position.indexOf(pos+i+1)
                                                if( pinYinPos !== -1) {
                                                    pinYinJson += "{" + '"pinYinPos"' + ':' + (i+1) +
                                                            ',"pinyinWithNum"' + ':"' + jObjec.pinyinWithNum[pinYinPos]+'"},'
                                                }
                                            }
                                            if (pinYinJson.indexOf("},") !== -1)
                                                pinYinJson = pinYinJson.substr(0,pinYinJson.length -1) + "]"
//                                            for(let j = 0; j<jObjec.position.length; j++)
//                                            {
//                                                pinYinJson+="{"+'"pinYinPos"'+':'+jObjec.position[j]+',"pinyinWithNum"'+':"'+jObjec.pinyinWithNum[j]+'"}'
//                                                pinYinJson+=(j!=jObjec.position.length-1)?",":"]"
//                                            }
                                        }
                                      chPinYinsSound = pinYinJson.indexOf("{") !== -1 ? pinYinJson : null
                                    return true
                                }
                            }
                        }
                    }
                })
            }
            }
            break;
        case YEnum.DtChLarge:
            if(index === 0) {
            let dictJson = JSON.parse(content)
            chPinYinsSound = typeof dictJson.dataList[0].pinyinWithNum != "undefined"
                    ? (typeof dictJson.details[0].pinyinWithNum != "string"
                       ? dictJson.dataList[0].pinyinWithNum.join(" ")
                       : dictJson.dataList[0].pinyinWithNum) : (typeof dictJson.dataList[0].speech != "undefined" ?
                                                                    dictJson.dataList[0].speech : null)
            }
            break;
        case YEnum.DtSimple:
        case YEnum.DtEnChKid:
            let dictJsonSimple = JSON.parse(content)
            let phoneticJsonObj = new Object
            try{
                if(typeof dictJsonSimple.pure.word["return-phrase"] !== "undefined" && dictJsonSimple.pure.word["return-phrase"].trim().toLowerCase() === resultManager.currentQuery.trim().toLowerCase()) {
                    // 格式新旧兼容
                    if (typeof dictJsonSimple.pure.word != "undefined") {
                        if (typeof dictJsonSimple.pure.word.ukphone == "string") {
                            phoneticJsonObj["uk"] = dictJsonSimple.pure.word.ukphone
                        }
                        if (typeof dictJsonSimple.pure.word.usphone == "string") {
                            phoneticJsonObj["us"] = dictJsonSimple.pure.word.usphone
                        }
                    } else {
                        if (typeof dictJsonSimple.pure.uk == "string") {
                            phoneticJsonObj["uk"] = dictJsonSimple.pure.uk
                        }
                        if (typeof dictJsonSimple.pure.us == "string") {
                            phoneticJsonObj["us"] = dictJsonSimple.pure.us
                        }
                    }
                    console.warn("return-phrase:" + JSON.stringify(phoneticJsonObj))
                }
            } catch(e) {
            }
            //新词覆盖旧词
            if(typeof dictJsonSimple.pure.word === "string" && dictJsonSimple.pure.word.trim().toLowerCase() === resultManager.currentQuery.trim().toLowerCase()) {
                if (typeof dictJsonSimple.pure.phonetics!= "undefined"&& dictJsonSimple.pure.phonetics.length>0)
                {
                    if(typeof dictJsonSimple.pure.phonetics[0].phone!= "undefined")
                        phoneticJsonObj["uk"] = dictJsonSimple.pure.phonetics[0].phone
                }
                if (typeof dictJsonSimple.pure.us_phonetics!= "undefined"&& dictJsonSimple.pure.us_phonetics.length>0)
                {
                    if(typeof dictJsonSimple.pure.us_phonetics[0].phone!= "undefined")
                        phoneticJsonObj["us"] = dictJsonSimple.pure.us_phonetics[0].phone
                }
            }

            if(Object.keys(phoneticJsonObj).length)
                resultManager.phoneticSymbolJson = JSON.stringify(phoneticJsonObj)
            if( YEnum.DtEnChKid === dictType) {
                setPhonic(dictJsonSimple)
                //else
                //spellManager.phonics = "";

                if (typeof dictJsonSimple.pure.phonics != "undefined" && typeof dictJsonSimple.pure.phonics.phone_names != "undefined") {
                    let posArray = null
                    if(typeof dictJsonSimple.pure.phonics.letter_split != "undefined")
                    {
                        posArray=dictJsonSimple.pure.phonics.letter_split.split("/")
                    }
                    let mArray = dictJsonSimple.pure.phonics.phone_names
                    let i =0;
                    let phonicsStr="["
                    if(typeof dictJsonSimple.pure.word != "undefined")
                        spellManager.phonics = id_dict_content_view.getstr(mArray,dictJsonSimple.pure.word, posArray)
                }
            }
            break
        case YEnum.DtPEPPrim:
            let dictJsonPEPPrim = JSON.parse(content)
            if (resultManager.phoneticSymbolJson.length <= 0 && typeof(dictJsonPEPPrim.phone) !== "undefined"
                                                                     && dictJsonPEPPrim.phone.length > 0)
            {
              resultManager.phoneticSymbolJson = dictJsonPEPPrim.phone
            }
            break
        case YEnum.AsyncLocalTran:
        case YEnum.NetTran:
            //id_dict_listview.visible = true
            //resultManager.phoneticSymbolJson = content
            break
        case YEnum.DtPinYin:
            id_dict_content_view.pinYinDictIndex = index
            break
        default:
            break
        }

    }

    function clickSearchWord(word) {
        console.log("***********id_dict_page.needSearchMoreVisible:"+id_dict_page.needSearchMoreVisible)
        if(id_dict_page.needSearchMoreVisible) {
            id_dict_page.requeryWord(resultManager.mainQuery, "en", "zh-CHS",id_dict_listview.repeaterModel,false,true,true,word)
        }
        else{
            id_dict_page.requeryWord(resultManager.currentQuery, "en", "zh-CHS",id_dict_listview.repeaterModel,false,false,true,word)
        }
    }

    function requeryWord(word, srcLang, dstLang,headBreakList=null,isOnlyAdd = false,isSearchMore = false,
                         isEnterNewPage = false,searchWord = null) {
        upsetTopButtonStatus()
        resultManager.isReturnSearch = false
        top_detail_button_visible = false;
        initStrokeInfo()
        var qsMainQuery = resultManager.mainQuery
        var qsSrcLang = resultManager.srcLang
        var qsDstLang = resultManager.dstLang
        var selectIndex = resultManager.autoSelectIndex
        var qsTitle = id_dict_page.title
        var contentYPos = id_container_flickable.contentY
        let listViewDataArray = []
        listViewDataArray.push(id_dict_listview.pixelSizeArray)
        listViewDataArray.push(id_dict_listview.indexMapArray)
        listViewDataArray.push(id_dict_listview.rawBreakListBackArray)
        listViewDataArray.push(id_dict_listview.isClick)
        listViewDataArray.push(id_dict_listview.pointScanIsClick)
        listViewDataArray.push(id_dict_listview.orgBreakList)
        listViewDataArray.push(id_dict_listview.clickIndex)
        listViewDataArray.push(id_dict_listview.chType)
        listViewDataArray.push(id_dict_listview.isScanning)
        listViewDataArray.push(id_dict_listview.isAutoBreakWords)
        listViewDataArray.push(id_dict_listview.pointSelectIndex)
         var currentSearchMethod = resultManager.searchMethodAndParameter
         listViewDataArray.push(currentSearchMethod)
        listViewDataArray.push(id_dict_listview.newBreakIndexToRawIndex)
        stackQueryResult.push([qsMainQuery, qsSrcLang, qsDstLang, selectIndex, qsTitle, contentYPos,headBreakList,word,isSearchMore,isEnterNewPage,listViewDataArray,qmlGlobal.scanOldType,isLoadMoreCount,resultManager.itemCount])
        if(!isOnlyAdd) {
            qmlGlobal.queryFromDictPage(searchWord===null?word:searchWord, srcLang, dstLang)
        }
        id_container_flickable.contentY = 0
    }



    function backToContentTop() {
        id_container_flickable.contentY = 0
        updateNavigationPage()
    }

    function upsetTopButtonStatus(){
        id_to_top_button.visible = false
        id_to_top_button.visible = Qt.binding(function() {
                return id_container_flickable.contentY > 500}
            )
    }

    function isChinese(str){
        if(/[\u3220-\uFA29]+/.test(str)){
            return true;
        }else{
            return false;
        }
    }

    function headFontFamily(charType) {
        let haveChinese = charType === YEnum.CT_UNKNOWN ? isChinese(content) : false
        switch (charType) {
        case YEnum.CT_ENG:
            return fontManager.fontFamilyEnUs
        case YEnum.CT_JP:
            return fontManager.fontFamilyJaJp
        case YEnum.CT_KO:
            return fontManager.fontFamilyKoKr
        case YEnum.CT_CJK:
            return fontManager.fontFamilyZhCn
        default:
            return !haveChinese ? fontManager.fontFamilyEnUs : fontManager.fontFamilyZhCn
        }
    }

    function setPhonic(dictJsonSimple) {
          if (typeof dictJsonSimple.pure.phonics != "undefined") {
              let spellPosArray = []
              for (let m = 0; m < dictJsonSimple.pure.phonics.length; m++) {
                  if (typeof dictJsonSimple.pure.phonics[m].position != "undefined") {
                      for (let j = 0; j < dictJsonSimple.pure.phonics[m].position.length; j++) {
                          spellPosArray.push(dictJsonSimple.pure.phonics[m].position[j])
                      }
                  }
              }
              if(spellPosArray.length === resultManager.currentQuery.length)
               spellManager.phonics  = JSON.stringify(dictJsonSimple.pure.phonics);
          }
      }


    function arrayAdd(isSelect , notSelectContent, selectContent, valueLists, addKey) {
        if(isSelect) {
            valueLists.push(addKey)
        } else {
            if(JSON.stringify(notSelectContent).trim() !== JSON.stringify(selectContent).trim() &&
                    JSON.stringify(notSelectContent).trim().substring(0,20) !== JSON.stringify(selectContent).trim().substring(0,20))
                valueLists.push(addKey)
        }
    }

    function resetDictJson(content,keys=[],i=0) {
        try {
            var jsonObj =  JSON.parse(content)
            let rawJsonObj = JSON.parse(content)
            let isPure = false
            let isExample = false
            var isA1 = false
            var isB1 = false
            var isC1 = false
            var c1Value = []
            if(typeof rawJsonObj.pure != "undefined" ) {
                isPure = true
                jsonObj =  typeof jsonObj.pure === "string" ? JSON.parse(jsonObj.pure) : jsonObj.pure
                for(var key in jsonObj){
                    if(key.indexOf(i) !== -1 && key.indexOf("\t") !== -1) {
                        var newKeys = []
                        for(var keySimple in jsonObj) {
                            var isA1Simple = false
                            var isB1Simple = false
                            var isC1Simple = false
                            if(resultManager.currentQuery === keySimple.substr(0,keySimple.indexOf('\t'))) {
                                isA1 = true
                                isA1Simple = true
                            } else
                            if(resultManager.currentQuery.toLowerCase() === keySimple.substr(0,keySimple.indexOf('\t'))) {
                                isB1 = true
                                isB1Simple = true
                            } else
                            if(resultManager.currentQuery.toLowerCase() === keySimple.substr(0,keySimple.indexOf('\t')).toLowerCase() ) {
                                isC1 = true
                                isC1Simple = true
                                c1Value.push(keySimple)
                            }

                            if(isC1Simple && (isA1 || isB1)) {
                                for (var m = 0; m < keys.length; m++) {
                                     var haveC1 = false
                                     for (var k = 0; k < c1Value.length; k++)  {
                                         if (keys[m] === c1Value[k]) {
                                             haveC1 = true
                                             break;
                                         }
                                     }

                                     if(!haveC1) {
                                         arrayAdd(keys[m] === key,jsonObj[keys[m]],jsonObj[key],newKeys,keys[m])
                                         //newKeys.push(keys[m])
                                     }
                                }
                                keys = newKeys
                                break
                            }
                            arrayAdd(keySimple === key, jsonObj[keySimple], jsonObj[key] ,keys, keySimple)
                            //keys.push(keySimple)
                        }
                        rawJsonObj.pure = jsonObj[key]
                        break
                    }else if(key.indexOf("\t") === -1) {
                        break
                    }
                }
            }

            if(typeof rawJsonObj.example != "undefined") {
                isExample = true
                jsonObj =  typeof rawJsonObj.example === "string" ? JSON.parse(rawJsonObj.example) : rawJsonObj.example
                for(var key in jsonObj){
                    if(key.indexOf(i) !== -1 && key.indexOf("\t") !== -1) {
                        rawJsonObj.example = jsonObj[key]
                        break
                    }else if(key.indexOf("\t") === -1) {
                        break
                    }
                }
            }

            if(!isPure && !isExample) {
                for(var key in jsonObj){
                    if(key.indexOf(i) !== -1 && key.indexOf("\t") !== -1) {
                        var newKeys = []
                        for(let keySimple in jsonObj) {
                            let isA1Simple = false
                            let isB1Simple = false
                            let isC1Simple = false
                            if(resultManager.currentQuery === keySimple.substr(0,keySimple.indexOf('\t'))) {
                                isA1 = true
                                isA1Simple = true
                            } else
                            if(resultManager.currentQuery.toLowerCase() === keySimple.substr(0,keySimple.indexOf('\t'))) {
                                isB1 = true
                                isB1Simple = true
                            } else
                            if(resultManager.currentQuery.toLowerCase() === keySimple.substr(0,keySimple.indexOf('\t')).toLowerCase() ) {
                                isC1 = true
                                isC1Simple = true
                                c1Value.push(keySimple)
                            }

                            if(isC1Simple && (isA1 || isB1)) {
                                for (let m = 0; m < keys.length; m++) {
                                     let haveC1 = false
                                     for (let k = 0; k < c1Value.length; k++)  {
                                         if (keys[m] === c1Value[k]) {
                                             haveC1 = true
                                             break;
                                         }
                                     }
                                     if(!haveC1) {
                                          arrayAdd(keys[m] === key, jsonObj[keys[m]], jsonObj[key] ,newKeys, keys[m])
                                         //newKeys.push(keys[m])
                                     }
                                }
                                keys = newKeys
                                break
                            }
                            //去除释义相同key
                             arrayAdd(keySimple === key, jsonObj[keySimple], jsonObj[key] ,keys, keySimple)
                               // keys.push(keySimple)
                        }
                        rawJsonObj = jsonObj[key]
                        //去除释义相同key
//                        for (var t = 0; t < keys.length; t++) {
//                             var newKeysTemp = []
//                            if(keys[t].indexOf(i) === -1) {
//                                if(jsonObj[key])
//                            } else {
//                                newKeysTemp.push(keys[t])
//                            }
//                        }
                        break
                    }else if(key.indexOf("\t") === -1) {
                        break
                    }
                }
            }

            return rawJsonObj

        } catch(e) {
            console.warn("YDictPage.qml============e:" +e)
            try {
                return JSON.parse(content)
            }catch (e) {
                return content
            }
        }
    }

    function recordResult() {
        let item = id_dict_content_view.itemAtIndex(0)
        if(item == null) {
            return
        }
        logManager.sendHttpLog((item.dictType === YEnum.AsyncLocalTran || item.dictType === YEnum.NetTran) ?
                                    "action=detail_result&trans=" + item.dictType : "action=detail_result&dict=" + item.dictType)
        efficiencyReport.addClock("show_query_qml_result");
        efficiencyReport.printReport();
        if (qmlGlobal.canAutoAddToWb) {
            qmlGlobal.canAutoAddToWb = false
            let simpleParaphrase = simpleParaphraseFunc(item.content, item.dictType)
            resultManager.addHistory(resultManager.mainQuery, JSON.parse(simpleParaphrase[0]).tran, simpleParaphrase[1], simpleParaphrase[2])
            if (settingManager.isAutoAddWb /*&& resultManager.currentQuery === resultManager.mainQuery*/) {
                resultManager.addToWordBook(resultManager.currentQuery, simpleParaphrase[0], simpleParaphrase[1], simpleParaphrase[2])
            }
        }
    }

    //AI 精读
    property bool isNeedVisibleAiButton: false


    YFunctionFeedback{
        id: id_feedback_dialog
    }

    //词典导航
    Item {
        id: id_inner_item
        anchors.fill: parent
    }

    ShaderEffectSource {
        id: id_effect_source
        anchors.top: parent.top
        anchors.right: parent.left
        anchors.bottom: parent.bottom
        width: id_navigation_pages.width
        sourceItem: id_inner_item
        sourceRect: Qt.rect(0, 0, width, height)
        visible: false
    }

    property int g_y: 0
    PropertyAnimation {
        id: id_dict_content_animator
        target: id_container_flickable
        property: "contentY"
        from: id_container_flickable.contentY
        to: g_y
        duration: 120
        running: false
        alwaysRunToEnd: true
    }

    YDictNavigationPage {
//        visible: true
        id: id_navigation_pages
        fastBlurTarget: id_effect_source
        onNavigationSendToDictPageItem:{
            var g_ofsetY = id_container_flickable.mapFromItem(dictNode, 0, 0 + id_container_flickable.contentY)
            var maxOfSetY = id_container_flickable.contentHeight - YBaseEnum.Screen.Height
            g_y = g_ofsetY.y >= maxOfSetY ?  maxOfSetY : g_ofsetY.y
            console.log("seven:title:",title, ":dictNode:", dictNode,":contentY:",g_y)
            id_dict_content_animator.restart()
        }
        onVisibleChanged: {
            if(visible && settingManager.isFirstEnterDictPage){
                qmlGlobal.shownavigationTips();
            }
        }
    }

    function updateNavigationPage(){
        for(var i = 0; i < id_navigation_pages.dictNavigationModel.count; ++i){
            var dictNode = id_navigation_pages.dictNavigationModel.get(i).dictNode
            var dict_gY = id_container_flickable.mapFromItem(dictNode,0,0 + id_container_flickable.contentY).y
            console.log("seven:dict_gY:",dict_gY)
            if( dict_gY >= id_container_flickable.contentY && dict_gY < (id_container_flickable.contentY + id_container_flickable.height)/*YBaseEnum.Screen.Height*/){
                id_navigation_pages.setCurrentIndex(i)
                break
            }
        }
    }

    YPopLayer {
        id: id_ai_pop_layer
        function showPage(qrcqml, properties) {
            show(qrcqml, false, false, properties)
            currentShowPage = popItemObject
        }
    }
    property var currentShowPage: null
    Flickable {
        id: id_container_flickable
        anchors.fill: parent
        anchors.leftMargin: 90
        anchors.rightMargin: 16
        contentHeight: Math.max(id_dict_content_column.height, id_buttons_column.height)
        flickableDirection: Flickable.VerticalFlick

        Behavior on contentY {
            id: id_content_animation
            enabled: sentenceMeanPos !== 0
            NumberAnimation {
                id: id_transition_animation
                to: sentenceMeanPos;  duration: 500
                onRunningChanged: {
                    if(!running) {
                        sentenceMeanPos = 0
                    }
                }
            }
        }

        onMovingChanged: {
            var temp = (id_container_flickable.contentHeight - YBaseEnum.Screen.Height ) /*+ YBaseEnum.Screen.Height / 6*/
            if (!moving && contentY >= temp) {
                resultManager.loadMore()
                isLoadMoreCount++
                id_navigation_pages.dictNodeAdjust()
            }
            console.log("seven:onMovingChanged")
        }


        onMovementEnded: {
            console.log("seven:contentY:",contentY)
//            for(var i = 0; i < id_navigation_pages.dictNavigationModel.count; ++i){
//                var dictNode = id_navigation_pages.dictNavigationModel.get(i).dictNode
//                var dict_gY = mapFromItem(dictNode,0,0 + id_container_flickable.contentY).y
//                console.log("seven:dict_gY:",dict_gY)
//                if( dict_gY >= contentY && dict_gY < (contentY + height)/*YBaseEnum.Screen.Height*/){
//                    id_navigation_pages.setCurrentIndex(i)
//                    break
//                }
//            }
            updateNavigationPage()
        }

        property int privateTagsIndex: {
            let nLowLimit = 0
            switch (resultManager.mainQueryType) {
            case YEnum.WGT_Sentence:
            case YEnum.WGT_Ch_Group:
            case YEnum.WGT_En_Group:
            case YEnum.WGT_Ko_Group:
                nLowLimit = -1;
                break
            default:
                break
            }
            return resultManager.autoSelectIndex.bound(
                        nLowLimit, resultManager.mainQueryBreakList.length - 1)
        }

        Column {
            id: id_dict_content_column
            anchors.left: parent.left
            width: containWidth
            spacing: 0

            YSpacingForColumn {
                implicitHeight: 20
            }


            YDictPageHeaderItem {
                id: id_word
                visible: isButtonIsRePress && (!(resultManager.itemCount) &&
                          !id_dict_content_view_repeater_empty_tip.visible)
                //anchors.centerIn: parent
                wordItem.lineHeight: 40
                wordItem.lineHeightMode: YTextMedium.FixedHeight
                enabled: !isScannig
                charType: qmlTranslator.getCharType(ocrContentString)
                anchors.left: parent.left
                anchors.right: parent.right
                width:containWidth -8
                content: ocrContentString
                onContentChanged: {
                    id_dict_content_view_repeater_empty_check_timer.restart()
                }
                onVisibleChanged: {
                    if(visible) {
                        collinsSelect = []
                    }
                }
            }

            Flickable {
                id: id_header_flickable
                width: /*? containWidth : */ containWidth
                //height:
                interactive:  flickableDirection === Flickable.HorizontalFlick
                contentWidth: flickableDirection === Flickable.HorizontalFlick ? (pointScanItemsWidth > containWidth ? pointScanItemsWidth : containWidth) + 100 : containWidth
                height: flickableDirection === Flickable.HorizontalFlick ? 45 : id_dict_listview.height
                //contentHeight: Math.max(id_dict_content_column.height, id_buttons_column.height)
                flickableDirection: 0 === qmlGlobal.scanOldType ? Flickable.HorizontalFlick : Flickable.VerticalFlick
                clip: true
                visible: !id_stroke_info_item.visible && !id_word.visible

                YDictPageHeaderView {
                    id: id_dict_listview
                    //visible: !id_stroke_info_item.visible && !id_word.visible /*&& !id_dict_listview_pointScan.visible*/
                }
            }

            YSpacingForColumn {
                implicitHeight: 17
                visible: id_phonetic_symbol_loader.active && id_phonetic_symbol_loader.visible
            }

            YLoaderPhoneticSymbol{
                id: id_phonetic_symbol_loader
                active: (resultManager.currentQueryType === YEnum.WGT_En_Group || resultManager.currentQueryType === YEnum.WGT_En) &&
                        0 === qmlGlobal.scanOldType && systemBase.isButtonRelease && !isShowPinYinDict
                visible: active && !id_word.visible
                onLoaded: {
                    item.isWrap = Qt.binding(function(item) {return qmlGlobal.scanOldType === 0})
                }
                onVisibleChanged: {
                    if(0 === qmlGlobal.scanOldType)
                        isPhoneticSymbolShow = visible
                    if(0 === qmlGlobal.scanOldType && item)
                        item.isWrap = true
                }
            }

//            YSpacingForColumn {
//                implicitHeight: 16
//                visible: id_phonetic_symbol_loader.active
//            }

            YSpacingForColumn {
                id: id_search_loader_space
                implicitHeight: 10
                visible: id_word.visible
                onYChanged: {
                    let beforeContentHeight =  y + height + 34 + 40
                    let moveY = (beforeContentHeight - YBaseEnum.Screen.Height)
                    if (moveY >= 0)
                        id_container_flickable.contentY  = moveY
                }
            }

            YWaitingTipsText {
                id: id_searching
                anchors.left: parent.left
                horizontalAlignment: Text.AlignLeft
                font.family: fontManager.fontFamilyZhCn
                implicitHeight: 34
                font.pixelSize: 28
                color: YColors.grayText
                //anchors.horizontalCenter: parent.horizontalCenter
                font.weight: Font.Normal
                text: YTranslateText.searching
                running: false
                visible:  isButtonIsRePress && !isScannig && (!(resultManager.itemCount) &&
                                         !id_dict_content_view_repeater_empty_tip.visible)
//                onYChanged: {
//                        let beforeContentHeight =  y + height
//                        let moveY = (beforeContentHeight - YBaseEnum.Screen.Height)
//                        if (moveY >= 0)
//                            id_container_flickable.contentY  = moveY
//                }
            }

            YSpacingForColumn {
                implicitHeight: 10
                visible: id_dict_listview.visible && id_stroke_info_item.visible
            }

            YSpacingForColumn {
                implicitHeight: 10
                visible: id_dict_listview.visible && id_stroke_info_item.visible
            }

            YDictPageHeaderChChinese {
                id: id_stroke_info_item
                function bindValue() {
                    chCharacter = Qt.binding(function(){return resultManager.currentQuery})
                    strokeCount = Qt.binding(function(){return id_dict_page.strokeCount})
                    structure = Qt.binding(function(){return id_dict_page.structure})
                    radical = Qt.binding(function(){return id_dict_page.radical})
                    console.log("seven:onClicked:BreakList:3:",chCharacter)
                    if(visible && resultManager.currentQuery.length === 1)
                        strokeManager.queryStrokeByKey(chCharacter)
                }
                chCharacter: resultManager.currentQuery
                strokeCount: id_dict_page.strokeCount
                structure: id_dict_page.structure
                radical: id_dict_page.radical
                onVisibleChanged: {
                    if(visible && resultManager.currentQuery.length === 1) {
                        console.log("seven:onClicked:BreakList:2:",chCharacter)
                        strokeManager.queryStrokeByKey(chCharacter)
                    }
                }
                onHeaderSelectedPinYinChanged: {
                    console.log("seven:onHeaderSelectedPinYinChanged:",currentPinYin)
                    if(dictPageObjet)
                        dictPageObjet.onSelectPinYinChanged(currentPinYin)

                }
                property bool visibleProperty: {
                    console.log("seven:currentQueryType:0",resultManager.currentQueryType,YEnum.WGT_Ch,resultManager.currentQuery)
                    return (resultManager.currentQueryType === YEnum.WGT_Ch || resultManager.currentQueryType === YEnum.WGT_Ja_Ch) &&
                            !isScannig &&
                            !id_searching.visible &&
                            !isScannig &&
                            resultManager.currentQuery.length
                }/*&& isFirstDictLoaded*/

                visible:{
                    if(firstDictType === YEnum.DtChToJap || firstDictType === YEnum.DtJapToCh){
                        console.log("seven:currentQueryType:1",resultManager.currentQueryType,YEnum.WGT_Ch,resultManager.currentQuery)
                        return false
                    }else{
                        console.log("seven:currentQueryType:2",resultManager.currentQueryType,YEnum.WGT_Ch,resultManager.currentQuery,visibleProperty)
                        if(resultManager.currentQueryType === YEnum.WGT_Ja_Ch && resultManager.currentQuery.length > 1) return false //如果是日文汉字(两个字以上则隐藏笔顺动画组件)
                        if(resultManager.isTransBtnVisible) return false
                        return visibleProperty
                    }
                }
            }

            YSpacingForColumn {
                id: id_search_more_space
                implicitHeight: 20
                visible: id_head_search_more_loader.visible
            }

            //显示我要查
            YLoader{
                id:id_head_search_more_loader
                property var currentQueryPos: resultManager.mainQuery.indexOf(resultManager.currentQuery)
                property var leftCurrentQuery: resultManager.mainQuery.substr(0,currentQueryPos)
                property var rightCurrentQuery: resultManager.mainQuery.substr(currentQueryPos + resultManager.currentQuery.length)
                property var leftAndRightIsSpaceOrPunction: (qmlGlobal.isSpaceAndPunctunction(leftCurrentQuery) <= 0) && (qmlGlobal.isSpaceAndPunctunction(rightCurrentQuery) <= 0)

                property var visibleSet : {
                   return  (qmlGlobal.scanOldType !== 0 || id_stroke_info_item.visible) && !searchMoreIsClick
                                          && tagsIndex != -1
                                          && resultManager.currentQuery !== resultManager.mainQuery
                                          && !id_dict_listview.isClick && !leftAndRightIsSpaceOrPunction
                && !resultManager.isAllMatchPoem
                }
                asynchronous: true
                visible:id_head_search_more_loader.visibleSet
                active: id_head_search_more_loader.visibleSet
                sourceComponent: id_search_more_component
            }

            Component{
                id:id_search_more_component
                Row{
                    anchors.left: parent.left
                    width: 614
                    height: 37
                    visible: id_head_search_more_loader.visible
                    id: id_search_more_row
                    YText {
                        text: YTranslateText.needSearchMore
                        font.pixelSize: 28
                        color: YColors.white
                    }

                    YMouseArea{
                        width: 502
                        height: 37
                        onClicked: {
                            searchMoreIsClick = true
                            //id_search_more_row.visible = false
                            id_dict_page.requeryWord(resultManager.mainQuery, "en", "zh-CHS",id_dict_listview.repeaterModel,true,true)
                            resultManager.autoSelectIndex = -1
                            resultManager.entryResult(resultManager.mainQuery, resultManager.srcLang, resultManager.dstLang, YEnum.DictDetail, 1, true)
                        }
                        YText{
                            id: id_more_text
                            text:id_get_middleElide_text.elidedText
                            font.pixelSize: 28
                            color: YColors.blueText
                        }
                        TextMetrics{
                            text:resultManager.mainQuery
                            font.family: fontManager.fontFamily
                            font.pixelSize: id_more_text.font.pixelSize
                            id:id_get_middleElide_text
                            elideWidth: 502
                            elide: Text.ElideMiddle
                        }
                    }
                }
            }


            YSpacingForColumn {
                id: id_content_space
                implicitHeight: 16
                onYChanged: {
                    if (!(resultManager.itemCount) &&
                            !id_dict_content_view_repeater_empty_tip.visible && !resultManager.isReturnSearch) {
                        let beforeContentHeight =  y + height
                        let moveY = (beforeContentHeight - YBaseEnum.Screen.Height)
                        if (moveY >= 0)
                            id_container_flickable.contentY  = moveY
                    }
                }
            }

            Flickable {
                id: id_dict_ch_pinyin_list_flickable
                anchors.left: parent.left
                anchors.right: parent.right
                height: 72
                contentWidth: id_dict_ch_pinyin_list.width
                flickableDirection: Flickable.HorizontalFlick
                visible: id_dict_ch_pinyin_list_repeater.count > 1
                clip: true

                Row {
                    id: id_dict_ch_pinyin_list
                    height: 52
                    spacing: 10
                    anchors.bottom: parent.bottom

                    Repeater {
                        id: id_dict_ch_pinyin_list_repeater
                        model: resultManager.chPinyinList

                        YButton {
                            height: 52
                            width: textWidth + 60
                            color: YColors.grayNormal
                            pixelSize: 26
                            textFamily: fontManager.fontFamilyEnUs
                            textWeight: Font.Normal
                            text: model.modelData
                            textColor: resultManager.chPinyinListSelected === text ? YColors.red : YColors.white
                            onClicked: {
                                console.log("YDictPage.qml === id_dict_ch_pinyin_list.btn.onClicked text: ", text)
                                resultManager.chPinyinListSelected = text
                                resultManager.phoneticSymbolJson = text
                                qmlGlobal.soundWGTCh()
                                //id_dict_content_column.forceLayout()
                            }
                        }
                    }
                }
            }

            YSpacingForColumn {
                id: id_pinyin_list_space
                implicitHeight: 16
                visible: id_dict_ch_pinyin_list_flickable.visible
            }


            YTimer{
                id: id_set_button_is_presss
                repeat: false
                interval: 500
                onTriggered: {
                     if((resultManager.itemCount || id_dict_content_view_repeater_empty_tip.visible) && systemBase.isButtonRelease)
                      isButtonIsRePress = false
                }
            }

            Column {
                id: id_dict_content_view
                spacing: 28
                anchors.left: parent.left
                anchors.right: parent.right
                property var pinYinDictIndex: null


                function itemAtIndex(index) {
                    return id_dict_content_view_repeater.itemAt(index)
                }


                onYChanged: {
                   if (resultManager.currentQueryType === YEnum.WGT_Sentence && !resultManager.isReturnSearch) {
                        let moveY = (y - YBaseEnum.Screen.Height / 2)
                        if (moveY >= 0) {
                            sentenceMeanPos = moveY
                            id_container_flickable.contentY  = moveY
                            isButtonIsRePress = false
                        }
                   }
                }

                onHeightChanged: {
                    if(resultManager.itemCount || id_dict_content_view_repeater_empty_tip.visible)
                        id_set_button_is_presss.restart()
                }

                Repeater {
                    id: id_dict_content_view_repeater
                    model: resultManager
                    delegate: YLoader {
                        id: id_dict_content_view_delegate
                        asynchronous: false
                        readonly property int dictType: model.modelData.dictType
                        property string content: JSON.stringify(resetDictJson(model.modelData.content))
                        onContentChanged: {
                            if (typeof content != "undefined" && content.length)
                                ocrContentString = ""
                        }

                        active: YEnum.AsyncLocalTran === dictType
                                || YEnum.NetTran === dictType
                                || YEnum.DtChChinese === dictType
                                || YEnum.DtChEnglish === dictType
                                //|| YEnum.DtChEnKid === dictType
                                || YEnum.DtChLarge === dictType
                                || YEnum.DtChAncientWord === dictType
                                || YEnum.DtChPoemDict === dictType
                                || YEnum.DtChIdiom === dictType
                                //英文词典
                                || YEnum.DtSimple === dictType
                                || YEnum.DtEnChKid === dictType
                                || YEnum.DtOxford === dictType
                                || YEnum.DtGRE === dictType
                                || YEnum.DtSSAT === dictType
                                || YEnum.DtSAT === dictType
                                || YEnum.DtTOEFL === dictType
                                || YEnum.DtIELTS === dictType
                                || YEnum.DtSenior === dictType
                                || YEnum.DtWebster === dictType
                                || YEnum.DtPEPPrim === dictType
                                || YEnum.DtCollinsPrimary === dictType
                                //拼音词典
                                || (YEnum.DtPinYin === dictType)
                                //韩文词典
                                || YEnum.DtChKo === dictType
                                || YEnum.DtKoCh === dictType
                                //新华词典
                                //|| YEnum.DtXinHua === dictType
                                //古代汉语词典（商务）
                                //|| YEnum.DtBusinessAnCh === dictType
                                // 成语大词典 (商务印书馆)
                                //|| YEnum.DtBusIdiomCh === dictType
                                //在线查词
                                || YEnum.DtOnline === dictType
                                //日中词典
                                || YEnum.DtJapToCh === dictType
                                //中日
                                || YEnum.DtChToJap === dictType
                                || dictType === customDict.dictTypeId
                        sourceComponent: {
                            if (dictType === customDict.dictTypeId) return id_dt_penmods_component;
                            getDictContentValue(dictType,content,index)
                            if(dictType === YEnum.AsyncLocalTran || dictType === YEnum.NetTran)
                                isNeedVisibleAiButton = true
                            else
                                isNeedVisibleAiButton = false
                            console.warn("====chenei: ", dictType, isNeedVisibleAiButton)
                            switch (dictType) {
                            case YEnum.DtChChinese:
                                if (YEnum.WGT_Ch_Group === resultManager.currentQueryType) {
                                    return id_dt_ch_chinese_group_component
                                }
                                return id_dt_ch_chinese_component
                            case YEnum.DtChEnglish:
//                            case YEnum.DtChEnKid:
                                return id_dt_ch_english_component
                            case YEnum.DtPinYin:
                                return id_dt_mango_pinyin_component
                            case YEnum.DtCollinsPrimary:
                                return id_dt_mango_collins_primary_component
                            case YEnum.DtChLarge:
                                return id_dt_ch_large_component
                            case YEnum.DtChAncientWord:
                                return id_dt_ch_ancientword_component
                            case YEnum.DtChPoemDict:
                                return id_dt_ch_poemdict_component
                            case YEnum.DtChIdiom:
                                return id_dt_ch_idiom_component
                            case YEnum.AsyncLocalTran:
                            case YEnum.NetTran:
                                return id_dt_sentence_component
                            case YEnum.DtSenior:
                                return id_dt_senior_component
                            case YEnum.DtTOEFL:
                                return id_dt_toefl_component
                            case YEnum.DtWebster:
                                return id_dt_webster_component
                            case YEnum.DtOxford:
                                return id_dt_oxford_component
                            case YEnum.DtGRE:
                                return id_dt_gre_component
                            case YEnum.DtSSAT:
                                return id_dt_ssat_component
                            case YEnum.DtSAT:
                                return id_dt_sat_component
                            case YEnum.DtIELTS:
                                return id_dt_ielts_component
                            case YEnum.DtChKo:
                                return id_dt_chko_component
                            case YEnum.DtKoCh:
                                return id_dt_koch_component
                            case YEnum.DtPEPPrim:
                                return id_dt_pepprim_component
                            case YEnum.DtEnChKid:
                                return id_dt_mango_kid_english_component
                           // case YEnum.DtXinHua:
                               // return id_dt_xinhua_component
                           // case YEnum.DtBusinessAnCh:                      //古代汉语词典(商务)
                               // return id_dt_business_an_ch_component
                            //case YEnum.DtBusIdiomCh:                        //成语大词典 (商务印书馆)
                               // return id_dt_business_idiom_ch_component
                            case YEnum.DtOnline:                            //在线查词
                                return id_dt_online_search_words
                            case YEnum.DtJapToCh:                           //日中词典
                                return id_dt_jap_to_ch
                            case YEnum.DtChToJap:                           //中日词典
                                return id_dt_ch_to_jap
                            case YEnum.DtSimple:
                            default:
                                return id_dt_simple_component
                            }
                        }

                        Component{
                            id: id_dt_mango_kid_english_component
                            YDictTypeDtMangoKidEnglish{
                                onDictNodeCompleted:{
                                    console.log("seven:onDictNodeCompleted:",title,":type:",type,":dictNode:",dictNode)
                                    addDictItemToNavigation(title, type, subType, dictNode)
                                }
                            }
                        }

                        Component {
                            id: id_dt_penmods_component
                            YDictTypeDtPenMods {}
                        }

                        Component {
                            id: id_dt_simple_component
                            YDictTypeDtSimple {
                                onDictNodeCompleted:{
                                    console.log("seven:onDictNodeCompleted:",title,":type:",type,":dictNode:",dictNode)
                                    addDictItemToNavigation(title, type, subType, dictNode)
                                }
                            }
                        }

                        Component {
                            id: id_dt_senior_component
                            YDictTypeDtSenior {
                                onDictNodeCompleted:{
                                    console.log("seven:onDictNodeCompleted:",title,":type:",type,":dictNode:",dictNode)
                                    addDictItemToNavigation(title, type, subType, dictNode)
                                }
                            }
                        }

                        Component {
                            id: id_dt_sentence_component
                            YDictTypeWGTSentence {
                                onDictNodeCompleted:{
                                    console.log("seven:onDictNodeCompleted:1111111111111111",)
                                    console.log("seven:onDictNodeCompleted:",title,":type:",type,":dictNode:",dictNode)
                                    addDictItemToNavigation(title, type, subType, dictNode)
                                }
                                onAiSentenceClick:{
                                    jupToAiSentencepage()
                                }
                            }
                        }

                        Component {
                            id: id_dt_ch_chinese_component
                            YDictTypeDtChChinese {
                                onDictNodeCompleted:{
                                    console.log("seven:onDictNodeCompleted:",title,":type:",type,":dictNode:",dictNode)
                                    addDictItemToNavigation(title, type, subType, dictNode)
                                }
                            }
                        }

                        Component {
                            id: id_dt_ch_chinese_group_component
                            YDictTypeDtChChineseGroup {
                                onDictNodeCompleted:{
                                    console.log("seven:onDictNodeCompleted:",title,":type:",type,":dictNode:",dictNode)
                                    addDictItemToNavigation(title, type, subType, dictNode)
                                }
                            }
                        }

                        Component {
                            id: id_dt_ch_english_component
                            YDictTypeDtChEnglish {
                                onDictNodeCompleted:{
                                    console.log("seven:onDictNodeCompleted:",title,":type:",type,":dictNode:",dictNode)
                                    addDictItemToNavigation(title, type, subType, dictNode)
                                }
                            }
                        }

                        Component {
                            id: id_dt_ch_large_component
                            YDictTypeDtChLarge {
                                onDictNodeCompleted:{
                                    console.log("seven:onDictNodeCompleted:",title,":type:",type,":dictNode:",dictNode)
                                    addDictItemToNavigation(title, type, subType, dictNode)
                                }
                            }
                        }

                        Component {
                            id: id_dt_ch_ancientword_component
                            YDictTypeDtChAncientWord {
                                onDictNodeCompleted:{
                                    console.log("seven:onDictNodeCompleted:",title,":type:",type,":dictNode:",dictNode)
                                    addDictItemToNavigation(title, type, subType, dictNode)
                                }
                            }
                        }

                        Component {
                            id: id_dt_ch_poemdict_component
                            YDictTypeDtChPoemDict {
                                onDictNodeCompleted:{
                                    console.log("seven:onDictNodeCompleted:",title,":type:",type,":dictNode:",dictNode)
                                    addDictItemToNavigation(title, type, subType, dictNode)
                                }
                            }
                        }

                        Component {
                            id: id_dt_ch_idiom_component
                            YDictTypeDtChChineseIdiom {
                                onDictNodeCompleted:{
                                    console.log("seven:onDictNodeCompleted:",title,":type:",type,":dictNode:",dictNode)
                                    addDictItemToNavigation(title, type, subType, dictNode)
                                }
                            }
                        }

                        Component {
                            id: id_dt_toefl_component
                            YDictTypeDtTOEFL {
                                onDictNodeCompleted:{
                                    console.log("seven:onDictNodeCompleted:",title,":type:",type,":dictNode:",dictNode)
                                    addDictItemToNavigation(title, type, subType, dictNode)
                                }
                            }
                        }

                        Component {
                            id: id_dt_webster_component
                            YDictTypeDtWebster {
                                onDictNodeCompleted:{
                                    console.log("seven:onDictNodeCompleted:",title,":type:",type,":dictNode:",dictNode)
                                    addDictItemToNavigation(title, type, subType, dictNode)
                                }
                            }
                        }

                        Component {
                            id: id_dt_oxford_component
                            YDictTypeDtOxford {
                                onDictNodeCompleted:{
                                    console.log("seven:onDictNodeCompleted:",title,":type:",type,":dictNode:",dictNode)
                                    addDictItemToNavigation(title, type, subType, dictNode)
                                }
                            }
                        }

                        Component {
                            id: id_dt_gre_component
                            YDictTypeDtGRE {
                                onDictNodeCompleted:{
                                    console.log("seven:onDictNodeCompleted:",title,":type:",type,":dictNode:",dictNode)
                                    addDictItemToNavigation(title, type, subType, dictNode)
                                }
                            }
                        }

                        Component {
                            id: id_dt_ssat_component
                            YDictTypeDtSSAT {
                                onDictNodeCompleted:{
                                    console.log("seven:onDictNodeCompleted:",title,":type:",type,":dictNode:",dictNode)
                                    addDictItemToNavigation(title, type, subType, dictNode)
                                }
                            }
                        }

                        Component {
                            id: id_dt_sat_component
                            YDictTypeDtSAT {
                                onDictNodeCompleted:{
                                    console.log("seven:onDictNodeCompleted:",title,":type:",type,":dictNode:",dictNode)
                                    addDictItemToNavigation(title, type, subType, dictNode)
                                }
                            }
                        }

                        Component {
                            id: id_dt_ielts_component
                            YDictTypeDtIELTS {
                                onDictNodeCompleted:{
                                    console.log("seven:onDictNodeCompleted:",title,":type:",type,":dictNode:",dictNode)
                                    addDictItemToNavigation(title, type, subType, dictNode)
                                }
                            }
                        }

                        Component {
                            id: id_dt_chko_component
                            YDictTypeDtChKo {
                                onDictNodeCompleted:{
                                    console.log("seven:onDictNodeCompleted:",title,":type:",type,":dictNode:",dictNode)
                                    addDictItemToNavigation(title, type, subType, dictNode)
                                }
                            }
                        }

                        Component {
                            id: id_dt_koch_component
                            YDictTypeDtKoCh {
                                onDictNodeCompleted:{
                                    console.log("seven:onDictNodeCompleted:",title,":type:",type,":dictNode:",dictNode)
                                    addDictItemToNavigation(title, type, subType, dictNode)
                                }
                            }
                        }

                        Component {
                            id: id_dt_pepprim_component
                            YDictTypeDtPEPPrim {
                                onDictNodeCompleted:{
                                    console.log("seven:onDictNodeCompleted:",title,":type:",type,":dictNode:",dictNode)
                                    addDictItemToNavigation(title, type, subType, dictNode)
                                }
                            }
                        }

                        Component{
                            id:id_dt_mango_pinyin_component
                            YDictPinYinPage{
                                onDictNodeCompleted:{
                                    console.log("seven:onDictNodeCompleted:",title,":type:",type,":dictNode:",dictNode)
                                    addDictItemToNavigation(title, type, subType, dictNode)
                                }
                            }
                        }

                        //科林斯词典
                        Component{
                            id:id_dt_mango_collins_primary_component
                            YDictTypeDtCollinsPrimaryPage{
                                onDictNodeCompleted:{
                                    console.log("seven:onDictNodeCompleted:",title,":type:",type,":dictNode:",dictNode)
                                    addDictItemToNavigation(title, type, subType, dictNode)
                                }
                            }
                        }

                        //新华词典
                        Component{
                            id:id_dt_xinhua_component
                            YDictTypeDtChXinHua{
                                onDictNodeCompleted:{
                                    console.log("seven:onDictNodeCompleted:",title,":type:",type,":dictNode:",dictNode)
                                    addDictItemToNavigation(title, type, subType, dictNode)
                                }
                            }
                        }

                        //古代汉语词典（商务）
                        Component{
                            id:id_dt_business_an_ch_component
                            YDictBusinessAnCh{
                                onShowPageClick:{
                                    id_dict_page.backContentYPos = id_container_flickable.contentY
                                }

                                onDictNodeCompleted:{
                                    console.log("seven:onDictNodeCompleted:",title,":type:",type,":dictNode:",dictNode)
                                    addDictItemToNavigation(title, type, subType, dictNode)
                                    dictPageObjet = this
                                }
                            }
                        }

                        // 成语大词典 (商务印书馆)
                        Component {
                            id: id_dt_business_idiom_ch_component
                            YDictBusIdiomCh {
                                onDictNodeCompleted:{
                                    console.log("seven:onDictNodeCompleted:",title,":type:",type,":dictNode:",dictNode)
                                    addDictItemToNavigation(title, type, subType, dictNode)
                                }
                            }
                        }

                        //在线查词
                        Component {
                            id: id_dt_online_search_words
                            YDictOnlineSearchWords{
                                onDictNodeCompleted:{
                                    console.log("seven:onDictNodeCompleted:",title,":type:",type,":dictNode:",dictNode)
                                    addDictItemToNavigation(title, type, subType, dictNode)
                                }
                            }
                        }

                        //日中词典
                        Component {
                            id: id_dt_jap_to_ch
                            YDictJapToChPage{
                                onDictNodeCompleted:{
                                    console.log("seven:onDictNodeCompleted:",title,":type:",type,":dictNode:",dictNode)
                                    addDictItemToNavigation(title, type, subType, dictNode)
                                }
                            }
                        }

                        //中日词典
                        Component {
                            id: id_dt_ch_to_jap
                            YDictChToJapPage {
                                onDictNodeCompleted:{
                                    console.log("seven:onDictNodeCompleted:",title,":type:",type,":dictNode:",dictNode)
                                    addDictItemToNavigation(title, type, subType, dictNode)
                                }
                            }
                        }
                    }
                }

                YTimer {
                    id: id_dict_content_view_repeater_empty_check_timer
                    interval: 2000
                    onTriggered: {
                        if(isScannig) {
                            return restart()
                        }
                        if (0 === id_dict_content_view_repeater_empty_tip.count) {
                            id_dict_content_view_repeater_empty_tip.visible = true
                            //人教版 扫词空结果 不显示反馈按钮
                            if(qmlGlobal.skuRegion() === YEnum.SKU_PEP && settingManager.isPepVersion)
                               resultManager.isReportButtonVisible = false;
                            if (typeof content != "undefined" && content.length)
                                ocrContentString = ""
                        }
                    }
                    objectName: "YDictPage.qml_id_dict_content_view_repeater_empty_check_timer"
                }

                YSpacingForColumn {
                    id: id_dict_content_view_repeater_empty_tip
                    implicitHeight: 128
                    visible: false

                    readonly property int count: resultManager.itemCount
                    onCountChanged: {
                        id_dict_content_view_repeater_empty_tip.visible = false
                        id_dict_content_view_repeater_empty_check_timer.restart()
                    }


                    YTextMedium {
                                   width: 616
                                   anchors.verticalCenter: parent.verticalCenter
                                   anchors.left: parent.left
                                   anchors.leftMargin: 2
                                   textFormat: YTextMedium.RichText
                                   horizontalAlignment: Text.AlignHCenter
                                   color: YColors.grayText
                                   text: (qmlGlobal.skuRegion() === YEnum.SKU_PEP && settingManager.isPepVersion)
                                         ? YTranslateText.noParaphraseFoundFromPepDict : YTranslateText.noParaphraseFound
                               }




                }

//                YDictPageSearchingTip {}
            }
        }

//        YTextBase {
//            id: id_word_source
//            visible: (YEnum.WGT_Ch_Group === resultManager.currentQueryType || YEnum.WGT_Ch === resultManager.currentQueryType) &&
//                     (chWordSourceData.length && chWordSourceData === "现代汉语规范词典")
////                anchors.left:parent.left
////                anchors.right: parent.right
//            width: contentWidth
//            anchors.horizontalCenter: parent.horizontalCenter
//            //anchors.verticalCenter: parent.verticalCenter
//            font.pixelSize: 18
//            color: YColors.grayText
//            //wrapMode: YText.WordWrap
//            text: chWordSourceData
//        }

        Column {
            id: id_buttons_column
            anchors.right: parent.right
//            anchors.rightMargin: 10
            width: 80
            spacing: 8
            visible: !id_search_loader_space.visible

            YSpacingForColumn {
                implicitHeight: 6
            }

            YIconCheckedButton {
                id: id_fav_word_button
                implicitWidth: 80
                implicitHeight: 70
                anchors.horizontalCenter: parent.horizontalCenter
                icon: "dict/fav"
                checkedIcon: "dict/fav-stored"
                visible: resultManager.itemCount && id_dict_content_view.itemAtIndex(0).content != null
                onClicked: {
                   checkedWord = resultManager.currentQuery
                    if (checked) {
                        let item = id_dict_content_view.itemAtIndex(0)
                        let simpleParaphrase = simpleParaphraseFunc(item.content, item.dictType)
                        console.warn("YDictPage.qml===id_fav_word_button===onValidClicked: checkedWord:", checkedWord, ", simpleParaphrase:", simpleParaphrase)
                        resultManager.addToWordBook(checkedWord, simpleParaphrase[0], simpleParaphrase[1], simpleParaphrase[2])
                        if (settingManager.isFirstAddWb) {
                            settingManager.isFirstAddWb = false
                            baseSignals.showToast(YTranslateText.isFirstAddWb, "#2D2E33")
                        }
                    } else {
                        console.warn("YDictPage.qml===id_fav_word_button===onValidClicked: deleteFromWordBook:", checkedWord)
                        resultManager.deleteFromWordBook(checkedWord)
                        if (settingManager.isFirstRemoveWb) {
                            settingManager.isFirstRemoveWb = false
                            baseSignals.showToast(YTranslateText.isFirstRemoveWb, "#2D2E33")
                        }
                    }
                }
                onVisibleChanged: {
                    if (visible) {
                        recordResult()
                    }
                }

                property string checkedWord: ""

                Connections {
                    target: resultManager
                    ignoreUnknownSignals: true
                    function isInWordBookChanged() {
                        id_fav_word_button.rebindingCheck()
                    }
                }

                function queryResult(word) {
                    resultManager.queryResult(word,false,[],true)
                    checkedWord = word
                    rebindingCheck()
                }

                function rebindingCheck() {
                    id_fav_word_button.checked = Qt.binding(function(){ return resultManager.isInWordBook })
                }
            }

            //AI 精读
            YIconButton {
                implicitWidth: 80
                implicitHeight: 70
                anchors.horizontalCenter: parent.horizontalCenter
                icon: "dict/dict_ai_white_sentence"
                visible: {
//                    if(resultManager.currentQuery.length > 150) return false
//                    if(resultManager.itemCount <= 0) return false
//                    var re = /[A-Za-z]+/
//                    console.log("seven:AIBUTTON:",resultManager.currentQuery.search(re))
//                    if(resultManager.currentQuery.search(re) === 0 && isNeedVisibleAiButton) return true
//                    return false
                    return getAiJumpVisible()
                }
                onValidClicked: {
                    jupToAiSentencepage()
                    logManager.sendHttpLog("action=get_analysis_toolbar")
                }

                onVisibleChanged: {
                    console.log("seven:ai:button:onVisibleChanged",visible)
//                    id_guide_loader.active = visible

                    if(visible && settingManager.aiPageCount() < 1){
                        settingManager.setAiPageCount(settingManager.aiPageCount() + 1)
                        id_guide_loader.active = true
                    }else{
                        id_guide_loader.active = false
                    }
                }
            }

            YIconButton {
                implicitWidth: 80
                implicitHeight: 70
                anchors.horizontalCenter: parent.horizontalCenter
                icon: "dict/follow-pron"
                visible: resultManager.itemCount > 0 && qmlTranslator.textIsEnglishOnly(resultManager.currentQuery)
                onValidClicked: {

                    followManager.ukPhonetic = "";
                    followManager.usPhonetic = "";
                    try {
                        console.log("##############", JSON.stringify(resultManager.phoneticSymbolJson));
                        var phoneticSymbolJson = JSON.parse(resultManager.phoneticSymbolJson);
                    } catch(e) { }
                    if (typeof phoneticSymbolJson != "undefined"){
                        //console.log("&&&&&&&&", phoneticSymbolJson.us);
                        followManager.ukPhonetic = typeof phoneticSymbolJson.uk == "undefined" ? "" : phoneticSymbolJson.uk;
                        followManager.usPhonetic = typeof phoneticSymbolJson.us == "undefined" ? "" : phoneticSymbolJson.us;
                    }
                    if (followManager.ukPhonetic.length === 0 && followManager.usPhonetic.length === 0) {
                        logManager.sendHttpLog("action=detail_trans_follow_click")
                    }
                    else {
                        logManager.sendHttpLog("action=detail_add_follow_click")
                    }

                    followManager.clearResult()
                    followManager.content = resultManager.currentQuery;
                    followManager.isUk = (settingManager.autoPronounceType === YEnum.UK) && followManager.ukPhonetic.length != 0
//                    qmlGlobal.showFollowPage();
                    console.log("seven:queryWordInfo:-1:",followManager.content)
                    if(followManager.content.split(" ").length < 2){
                        jupToFollowWordPageEx()
                    }else {
                        jupToFollowPageEx()
                    }

                }
            }

            YIconButton {
                implicitWidth: 80
                implicitHeight: 70
                anchors.horizontalCenter: parent.horizontalCenter
                icon: "dict/spelling"
                visible: spellManager.phonics.length > 0 && !settingManager.isPepVersion
                onValidClicked: {
                    logManager.sendHttpLog("action=detail_add_spell_click")
                    soundCenter.stop();
                    spellManager.content = resultManager.currentQuery;
                    spellManager.richContent = resultManager.currentQuery;
                    qmlGlobal.showSpellPage();
                }
            }

            YIconButton {
                implicitWidth: 80
                implicitHeight: 70
                anchors.horizontalCenter: parent.horizontalCenter
                icon: "dict/report"
                visible: resultManager.isReportButtonVisible
                onValidClicked: {
                    // logManager.sendHttpLog("action=detail_improve_click")
                    // baseSignals.showToast(YTranslateText.thxReport, "#2D2E33")
                    // resultManager.reportBadcaseButtonClicked()
                    // resultManager.isReportButtonVisible = false
                    // reportedSet.add(resultManager.currentQuery)
                    if(!wifiManager.isOnline()){
                        baseSignals.showToast(YTranslateText.networkAbnormalPleaseCheck, "#2D2E33")
                    }else{
                        id_feedback_dialog.feedbackType = 0
                        id_feedback_dialog.createFeedbackModel()
                        id_feedback_dialog.show()
                    }
                }
            }

            YIconButton {
                implicitWidth: 80
                implicitHeight: 70
                anchors.horizontalCenter: parent.horizontalCenter
                icon: {
                    switch (resultManager.transBtnType) {
                    case YEnum.TBT_Ja:
                        return "dict/switch_jp"
                    case YEnum.TBT_Ch:
                    default:
                        return "dict/switch_ch"
                    }
                }
                visible: resultManager.isTransBtnVisible
                onValidClicked: {
                    switch (resultManager.transBtnType) {
                        case YEnum.TBT_Ja:
                            resultManager.transBtnType = YEnum.TBT_Ch
                            break
                        case YEnum.TBT_Ch:
                            resultManager.transBtnType = YEnum.TBT_Ja
                            break
                    }
                    id_fav_word_button.queryResult(/*getWords()*/resultManager.currentQuery)
//                    resultManager.entryResult(resultManager.currentQuery, "", "", YEnum.Speech, 1, false)
                }
                function getWords(){
                    if (-1 === tagsIndex) {
                        return resultManager.mainQuery
                    } else {
                        const a = resultManager.mainQueryBreakList
                        return a[tagsIndex].content
                    }
                }
            }

            YIconButton {
                implicitWidth: 80
                implicitHeight: 70
                anchors.horizontalCenter: parent.horizontalCenter
                icon: "dict/detail"
                visible: top_detail_button_visible
                onValidClicked: {
                    console.warn("YDictPage.qml === dict_detail_button===onValidClicked,top_detail_button_visible:"+JSON.stringify(top_detail_button_visible))
                    let item = id_dict_content_view.itemAtIndex(0)
                    id_dict_page.backContentYPos =  id_container_flickable.contentY
                    if (resultManager.mainQueryBreakList.length > 1 && id_dict_page.tagsIndex >= 0) {
                        qmlGlobal.showDictDetailPage(item.dictType, item.content, resultManager.mainQueryBreakList[id_dict_page.tagsIndex].content)
                    } else {
                        qmlGlobal.showDictDetailPage(item.dictType, item.content, resultManager.mainQuery)
                    }
                }
            }
        }


        YFastBlurTitleBar {
            id: id_fastBlur
            //z: 200
            anchors.topMargin: 20
            anchors.left: parent.left
            anchors.leftMargin: -90
            height: id_header_flickable.height
            sourceItem: /*id_container_flickable*/id_header_flickable
            //sourceItemLeftMargin: 0
        }

    }


    YVerticalTitleBar {
        id: id_title_bar
        onCallBack: {
            resultManager.isReturnSearch = true
            resultManager.isClickReturn = true
            qmlGlobal.stopAllAnimationMusic()
            backProcess()
        }
    }


    YIconButton {
        id: id_to_top_button
        opacity: mouseAreaItem.pressed || !enabled ? 0.2 : 1
        implicitWidth: 44
        implicitHeight: 44
        radius: height/2
        mouseAreaMargins: -25
        anchors.left: parent.left
        anchors.leftMargin: 16
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 18
        imageName: "dict/to-top"
        visible: id_container_flickable.contentY > 500
        onValidClicked: {
            backToContentTop()
        }
    }


    //ignoreDefaultBackButtonClicked: true
    function backProcess(){
//        let pointScanVisible = id_dict_listview_pointScan.visible
//        if (pointScanVisible) {
//            id_dict_listview_pointScan.isFirstShow = true
//            tagsIndex = 0
//            return
//        }
        if (stackQueryResult.length > 0) {
            backContentYCount = 0;
            var queryResultLast = stackQueryResult.pop()
            backCountY = queryResultLast[5]
            setTimeout( function() {
                backContentYCount++;
                //resultManager.loadMore()
                if(id_dict_page.height >= backCountY || backContentYCount > 10) {
                    if(queryResultLast[12]) {
                        Qt.callLater(resultManager.loadMore , queryResultLast[13])
                    }
                    if(id_container_flickable.contentY < backCountY-5)
                       id_container_flickable.contentY = backCountY
                    timer.stop()
                }else
                    timer.restart()
            },1)
            console.log("*************queryResultLast:"+JSON.stringify(queryResultLast))
            if(queryResultLast[6] !== null && stackQueryResult.length >= 1)
            {
                //显示我要查界面返回
                if(queryResultLast[8]) {
                    //resultManager.autoSelectIndex = queryResultLast[3]
                    resultManager.updteCurrentQueryCondation(queryResultLast[0])
                    resultManager.entryResult(queryResultLast[0], queryResultLast[1], queryResultLast[2],YEnum.DictDetail,queryResultLast[11])
                }
                else {
                    //从近义词，反义词等跳转界面返回
                    if(queryResultLast[9]) {
                        //console.log("***************!!!!!!!!!!queryResultLast[10][2]:"+queryResultLast[10][2])
                        //resultManager.autoSelectIndex = -1
                        qmlGlobal.canAutoAddToWb = false
                        let scanType = queryResultLast[11]
                        if(queryResultLast[11] === 0 && stackQueryResult.length !== 0)
                            scanType = 1

                        //要实现以下跳转到新查词页面跳转回来，将以下注释
                        resultManager.updteCurrentQueryCondation(queryResultLast[7])
                        resultManager.entryResult(queryResultLast[7], queryResultLast[1], queryResultLast[2],YEnum.DictDetail,scanType)
                        stackQueryResult=[]

                        //要实现以下跳转到新查词页面跳转回来，将以下注释放开即可，目前需求未涉及
//                        console.warn("queryResultLast[10][11]" + JSON.stringify(queryResultLast[10][11]))
//                        let sInput = JSON.parse(queryResultLast[10][11])
//                        if(parseInt(sInput.isEntry)) {
//                             console.warn("parseInt 1")
//                            resultManager.entryResult(queryResultLast[7], sInput.srcLang, sInput.dstLang,sInput.fromPage,sInput.scanType, sInput.fromSearchMore)
//                        } else {
//                            resultManager.queryResult(queryResultLast[7])
//                            //id_dict_listview.pixelSizeArray = queryResultLast[10][0]
//                            id_dict_listview.indexMapArray = queryResultLast[10][1]
//                            id_dict_listview.rawBreakListBackArray = queryResultLast[10][2]
//                            resultManager.autoSelectIndex = queryResultLast[3]
//                            id_dict_listview.isClick = queryResultLast[10][3]
//                            id_dict_listview.pointScanIsClick = queryResultLast[10][4]
//                            id_dict_listview.orgBreakList = queryResultLast[10][5]
//                            id_dict_listview.clickIndex = queryResultLast[10][6]
//                            id_dict_listview.chType = queryResultLast[10][7]
//                            id_dict_listview.isScanning = queryResultLast[10][8]
//                            id_dict_listview.isAutoBreakWords = queryResultLast[10][9]
//                            id_dict_listview.pointSelectIndex = queryResultLast[10][10]
//                            id_dict_listview.newBreakIndexToRawIndex = queryResultLast[10][12]
//                            id_dict_listview.repeaterModel = []
//                            id_dict_listview.repeaterModel= queryResultLast[6]
//                        }

                    }
                    else {
                        resultManager.autoSelectIndex = -1
                        resultManager.queryResult(queryResultLast[7])
                        //回到点查首页，选中文字要高亮
                        if (queryResultLast[11] === 0 && stackQueryResult.length === 0) {
                            id_dict_listview.isClick = false
                            id_dict_listview.pointScanIsClick = false
                            resultManager.autoSelectIndex = queryResultLast[3]
                        }
                        id_dict_listview.repeaterModel = []
                        if (id_dict_listview.indexMapArray.length > 0)
                            id_dict_listview.newBreakIndexToRawIndex = id_dict_listview.indexMapArray.pop()
                        if (id_dict_listview.rawBreakListBackArray.length > 0)
                            id_dict_listview.orgBreakList=id_dict_listview.rawBreakListBackArray.pop()
                        id_dict_listview.repeaterModel= queryResultLast[6]
                    }
                }
            }
            else{
                resultManager.updteCurrentQueryCondation(queryResultLast[0])
                resultManager.entryResult(queryResultLast[0], queryResultLast[1], queryResultLast[2],YEnum.Dict,queryResultLast[11])
                id_dict_page.title = queryResultLast[4]
            }
            if(queryResultLast[12]) {
                Qt.callLater(resultManager.loadMore,queryResultLast[13])
            }
            if(reportedSet.has(resultManager.currentQuery)) {
                resultManager.isReportButtonVisible = false
            }
            else {
                resultManager.isReportButtonVisible = true
            }
            id_container_flickable.contentY = queryResultLast[5]
        } else {
            ocrStopShowCollins = true
            collinsSelect = []
            backButtonClicked()
        }
    }

//    onBackButtonClickedCallback: {
//        qmlGlobal.stopAllAnimationMusic()
//        initStrokeInfo()
//        backProcess()
//    }

    Timer {id: timer}
    function setTimeout(cb,delayTime) {
        //timer = new Timer();
        timer.interval = delayTime;
        timer.repeat = false;
        timer.triggered.connect(cb);
        timer.start();
    }

//    YTimer {
//        id: id_delay_pos_timer
//        interval: 300
//        onTriggered: {
//            if (resultManager.autoSelectIndex < 0) {
//                id_dict_listview.positionViewAtBeginning()
//            } else {
//                id_dict_listview.positionViewAtIndex(resultManager.autoSelectIndex, ListView.Center)
//            }
//        }
//        objectName: "YDictPage.qml_id_delay_pos_timer"
//    }

    function resetTransDirection(){
        resultManager.transBtnType = YEnum.TBT_Ja
    }

    Connections {
        target: systemBase
        ignoreUnknownSignals: true
        //enabled: id_dict_page.visible
        function onOcrStart() {
            resetTransDirection()
            console.log("YDictPage.qml====ocr_start")
            ocrStopShowCollins = true
            backToContentTop()
            isButtonIsRePress = true
            isScannig = true
            //visible = false
            id_dict_content_view_repeater_empty_tip.visible = false
            resultManager.clearChPinyinList()
            initStrokeInfo()
            reportedSet.clear()
            id_dict_content_view.pinYinDictIndex = null
            collinsSelect = []
            //id_fav_word_button.updateChecked()
            //重新查词将充值导航
            resetDictNavigation()

        }
        function onOcrStop(scanType) {
            isScannig = false
            ocrStopShowCollins = true
            //resultManager.phoneticSymbolJson = ""
        }
    }

    Connections {
        target: resultManager
        ignoreUnknownSignals: true
        function onCurrentQueryChanged() {
            sentenceMeanPos = 0
            pointScanItemsWidth = 0
            id_header_flickable.contentX = 0
            id_fav_word_button.rebindingCheck()
            chWordSourceData = ""
            id_stroke_info_item.initValue()
            id_stroke_info_item.bindValue()
            chPinYinsSound = null
            id_dict_content_view.pinYinDictIndex = null
            id_dict_content_view_repeater_empty_tip.visible = false
            id_dict_content_view_repeater_empty_check_timer.restart()
            spellManager.phonics = ""
            isLoadMoreCount = 0
            backToContentTop()
            id_dict_listview.isDetailShow = false
            backContentYPos = null
            if(reportedSet.has(resultManager.currentQuery)) {
                resultManager.isReportButtonVisible = false
            }
            else {
                resultManager.isReportButtonVisible = true
            }
            isFirstDictLoaded = false
            resetDictNavigation()
        }
        function onIsInWordBookChanged() {
            id_fav_word_button.rebindingCheck()
        }

        function onHistoryPageSearchkeyWords(){
//            resetDictNavigation()
        }
    }

    Connections {
        target: qmlGlobal
        ignoreUnknownSignals: true
        function onHideDictPage() {
            console.log("onHideDictPage!!!!!!")
            id_dict_page.backButtonClicked()
        }
    }

    Connections {
        target: qmlGlobal
        ignoreUnknownSignals: true
        enabled: id_dict_page.visible
        function onSoundSentence(qsWord, sundType, isOrg) {
            if (id_dict_page.visible) {
                /*const*/var sSoundWord = (qsWord.length > 0)
                                 ? qsWord : resultManager.currentQuery
                if(currentDictType === YEnum.DtChPoemDict){
                    console.log("seven:dictType:1", sSoundWord)
                    sSoundWord = sSoundWord.replace(/\s/g,"")
                }
                var isHasChinese = qmlGlobal.isHaveChinese(sSoundWord)
                var sund_type = isHasChinese ? "zh" : ((qsWord.length > 0) ?
                                                      resultManager.getSoundTargetLanguage() :
                                                      resultManager.getSoundLanguage())
                if(sundType.length ) {
                    sund_type = qsWord.length ? resultManager.getSoundTargetLanguage() : resultManager.getSoundLanguage()//sundType
                }
                console.log("seven:dictType:2", sSoundWord, sund_type)
                if(resultManager.isTransBtnVisible && isHasChinese && isOrg){
                    if(resultManager.transBtnType === YEnum.TBT_Ch) sund_type = "ja"
                    else sund_type = "zh"
                }
                qmlGlobal.audioPlayId = soundCenter.play(sSoundWord, sund_type)
                console.log("YDictPage.qml===onSoundSentence===sSoundWord:", sSoundWord, firstDictType)
                logManager.sendHttpLog("action=sound_click")
            }
        }

        function onSoundWGTCh() {
            if (id_dict_page.visible) {
                console.log("seven:onSoundWGTCh:chPinYinsSound:",chPinYinsSound,":phoneticSymbolJson:",resultManager.phoneticSymbolJson,":autoPronounceType:",settingManager.autoPronounceType)
                qmlGlobal.audioPlayId = soundCenter.play(resultManager.currentQuery,
                                                         resultManager.getSoundLanguage(),
                                                         chPinYinsSound === null ? resultManager.phoneticSymbolJson : chPinYinsSound,
                                                         settingManager.autoPronounceType)
                console.log("YDictPage.qml===onSoundWGTC===audioPlayId:", qmlGlobal.audioPlayId)
                logManager.sendHttpLog("action=sound_click")
            }
        }

       function onSoundWGTPep(qsWord) {
               if (id_dict_page.visible) {
                   console.log("YDictPage.qml===onSoundWGTPep")
                   qmlGlobal.audioPlayId = soundCenter.playPepPrim(qsWord)
                   logManager.sendHttpLog("action=sound_click")
               }
           }


        function onSoundWGTEn(qsWord, autoPronType) {
            if (id_dict_page.visible) {
                const nAutoPronType = (-1 == autoPronType)
                                    ? settingManager.autoPronounceType : autoPronType
                console.log("YDictPage.qml===onSoundWGTEn===nAutoPronType:", nAutoPronType)
                qmlGlobal.audioPlayId = soundCenter.play(qsWord,
                                                         resultManager.getSoundLanguage(),
                                                         resultManager.currentQuery,
                                                         nAutoPronType + 1)
                logManager.sendHttpLog("action=sound_click")
            }
        }
        function onSoundWGTKo() {
            if (id_dict_page.visible) {
                qmlGlobal.audioPlayId = soundCenter.play(resultManager.currentQuery,
                                                         resultManager.getSoundLanguage(),
                                                         chPinYinsSound === null ? resultManager.phoneticSymbolJson : chPinYinsSound,
                                                         settingManager.autoPronounceType)
                console.log("YDictPage.qml===onSoundWGTKo===audioPlayId:", qmlGlobal.audioPlayId)
                logManager.sendHttpLog("action=sound_click")
            }
        }
    }

    Connections{
        enabled: id_dict_page.visible
        ignoreUnknownSignals: true
        target: funcFeedback
        onRequestResultCallBack:{
            if(responseJsonString === "0"){
                resultManager.isReportButtonVisible = false
                baseSignals.showToast(YTranslateText.thxReport, "#2D2E33")
            }else
                baseSignals.showToast(YTranslateText.thxReportError, "#2D2E33")
        }
    }

    function resetDictNavigation(){
        id_navigation_pages.visible = false
        id_navigation_pages.dictNavigationModel.clear()
        id_navigation_pages.packUpDictNav()
    }

    function getNavDictTitle(dictNodeTitle){
        //词典导航页名称映射关系
        var navMap = {}
        if (dictNodeTitle.contains(YTranslateText.dtChPoemDict)) dictNodeTitle = YTranslateText.dtChPoemDict
        navMap[YTranslateText.dtChEnglish] = YTranslateText.navDtChEnglish
        navMap[YTranslateText.dtChIdiom] = YTranslateText.navDtChIdiom
        navMap[YTranslateText.dtChEnKid] = YTranslateText.navDtChEnKid
        navMap[YTranslateText.dtChChinese] = YTranslateText.navDtChChinese
        navMap[YTranslateText.dtChLarge] = YTranslateText.navDtChLarge
        navMap[YTranslateText.dtChAncientWord] = settingManager.uiLanguage === YEnum.ZH_CN ?
                    YTranslateText.dtChAncientWord : YTranslateText.navDtChAncientWord
        navMap[YTranslateText.dtChPoemDict] = settingManager.uiLanguage === YEnum.ZH_CN ?
                    YTranslateText.dtChPoemDict : YTranslateText.navDtChPoemDict
        navMap[YTranslateText.dtChXinHua] = settingManager.uiLanguage === YEnum.ZH_CN ?
                    YTranslateText.dtChXinHua : YTranslateText.navDtChXinHua

        navMap[YTranslateText.dtSimple] = settingManager.uiLanguage === YEnum.ZH_CN ?
                    YTranslateText.dtSimple : YTranslateText.navDtSimple
        navMap[(YTranslateText.dtEnChKid).replace("<br/>", " ")] = YTranslateText.navDtEnChKid
        navMap[YTranslateText.dtCollinsPrimary] = YTranslateText.navDtCollinsPrimary
        navMap[YTranslateText.dtPinYinDict] = settingManager.uiLanguage === YEnum.ZH_CN ?
                    YTranslateText.dtPinYinDict : YTranslateText.navDtPinYinDict
        navMap[YTranslateText.dtSenior] = settingManager.uiLanguage === YEnum.ZH_CN ?
                    YTranslateText.dtSenior : YTranslateText.navDtSenior
        navMap[YTranslateText.dtYDSenior] = settingManager.uiLanguage === YEnum.ZH_CN ?
                    YTranslateText.dtYDSenior : YTranslateText.navDtYDSenior
        navMap[YTranslateText.dtWebster] = YTranslateText.navDtWebster
        navMap[(YTranslateText.dtOxford).replace("<br/>", " ")] = YTranslateText.navDtOxford
        navMap[YTranslateText.dtOxfordNumber] = YTranslateText.navDtOxfordNumber
        navMap[YTranslateText.dtSSAT] = YTranslateText.navDtSSAT
        navMap[YTranslateText.dtSAT] = YTranslateText.navDtSAT
        navMap[YTranslateText.dtGRE] =  YTranslateText.navDtGRE
        navMap[YTranslateText.dtTOEFL] =  YTranslateText.navDtTOEFL
        navMap[YTranslateText.dtIELTS] = YTranslateText.navDtIELTS
        navMap[YTranslateText.dtPEPPrim ] =  YTranslateText.navDtPEPPrim
        navMap[YTranslateText.dtPEPPrimDict ] = YTranslateText.navDtPEPPrimDict
        navMap[YTranslateText.dtChKo] = YTranslateText.navDtChKo
        navMap[YTranslateText.dtKoCh] = YTranslateText.navDtKoCh
        navMap[YTranslateText.dtBusinessAnCh] = YTranslateText.navDtBusinessAnCh
        navMap[YTranslateText.dtBusIdiomCh] = YTranslateText.navDtBusIdiomCh
        navMap[YTranslateText.dtYoudaoTras] =  YTranslateText.navDtYoudaoTras

        navMap[YTranslateText.fixedCollocation] = settingManager.uiLanguage === YEnum.ZH_CN ?
                    YTranslateText.fixedCollocation : YTranslateText.navCollocation
        navMap[YTranslateText.wordsInflection] =  settingManager.uiLanguage === YEnum.ZH_CN ?
                    YTranslateText.wordsInflection : YTranslateText.navWordsForms
        navMap[YTranslateText.bilingualSentences] =  settingManager.uiLanguage === YEnum.ZH_CN ?
                    YTranslateText.bilingualSentences : YTranslateText.navSentences
        navMap[YTranslateText.exampleSentences] =  settingManager.uiLanguage === YEnum.ZH_CN ?
                    YTranslateText.exampleSentences : YTranslateText.navSentences
        navMap[YTranslateText.commonTests] =  settingManager.uiLanguage === YEnum.ZH_CN ?
                    YTranslateText.commonTests : YTranslateText.navKeyPoints
        navMap[YTranslateText.analysisOfMiscibleWords] =  YTranslateText.navAnalysis
        navMap[YTranslateText.highScoreExpressionInWriting] =  settingManager.uiLanguage === YEnum.ZH_CN ?
                    YTranslateText.highScoreExpressionInWriting : YTranslateText.navExpressions
        navMap[YTranslateText.corootOrDerivation] =  YTranslateText.navDerivatives
        navMap[YTranslateText.famousProverb] = settingManager.uiLanguage === YEnum.ZH_CN ?
                    YTranslateText.famousProverb : YTranslateText.navProverbs
        navMap[YTranslateText.mbtSynonym] = settingManager.uiLanguage === YEnum.ZH_CN ?
                    YTranslateText.mbtSynonym : YTranslateText.synonymFor
        navMap[YTranslateText.groupOfWords] = settingManager.uiLanguage === YEnum.ZH_CN ?
                    YTranslateText.groupOfWords : YTranslateText.navGroups
        navMap[YTranslateText.synonymsAndAntonyms] = settingManager.uiLanguage === YEnum.ZH_CN ?
                    YTranslateText.synonymsAndAntonyms : YTranslateText.navSynAnt
        return navMap[dictNodeTitle]
    }

    function addDictItemToNavigation(title, type, subType, dictNode){
        console.log("seven:dictNode1:",":dictNode:",dictNode,"type:",type,":subType:",subType,":title:",title,":visible:",dictNode.visible)
        if(type === YEnum.DtOnline || type === YEnum.NetTran || type === YEnum.AsyncLocalTran){
            id_navigation_pages.updateDisplayStatus()
            return
        }
        if(subType === 0 || (title !== "" /*&& dictNode.visible*/)){
            var dictNodeTitle = getNavDictTitle(title)
            console.log("seven:nodeTitle:",dictNodeTitle)
            var dicJson = {"title":dictNodeTitle !== undefined ? dictNodeTitle : title, "type":type, "subType":subType , "dictNode":dictNode}
            console.log("seven:nodeTitle1:",dictNodeTitle)
            var isPush = true
            var temp_index = 0
            if(type === firstDictType/*settingManager.topShowDict*/){
                console.log("seven:settingManager.topShowDict")
                isPush = false
                if(subType === 0)
                    temp_index = 0
//                    id_navigation_pages.dictNavigationModel.insert(0,dicJson)
                else {
                    for(var index = 0; index < id_navigation_pages.dictNavigationModel.count; ++index){
                        var item = id_navigation_pages.dictNavigationModel.get(index)
                        if(item.type !== type){
                            temp_index = index
                            break
                        }
                    }
                }
            }else{
                for(var i = 0; i < id_navigation_pages.dictNavigationModel.count; ++i){
                    var s_item = id_navigation_pages.dictNavigationModel.get(i)
                    if(s_item.type === type){
                        temp_index = i
                        isPush = false
                        break;
                    }
                }
            }

            if(isPush){
                id_navigation_pages.dictNavigationModel.append(dicJson)
            }else{
                id_navigation_pages.dictNavigationModel.insert(temp_index,dicJson)
            }
        }
        id_navigation_pages.updateDisplayStatus()

    }


    Component.onDestruction: {
        console.log("YDictPage.qml===Component.onDestruction===called")
    }

    onBackButtonClicked: {
        console.log("seven:onBackButtonClicked:")
        resultManager.clearChPinyinList()
        if (YEnum.PLAYING !== mediaPlayerManager.playState) {
            // do not do this, audioplaer is playing
            qmlGlobal.stopAllAnimationMusic()
        }
    }
    onVisibleChanged: {
        upsetTopButtonStatus()

        if(id_navigation_pages.dictNavigationModel.count !==0){
            id_navigation_pages.updateDisplayStatus()
        }else{
            id_navigation_pages.visible = false
        }
        if (visible) {
            qmlGlobal.currentPageIndex = YEnum.PageIndex.Dict
            id_fav_word_button.rebindingCheck()
            id_dict_content_view_repeater_empty_check_timer.restart()
            if(id_dict_page.backContentYPos !=  null){
                id_container_flickable.contentY = id_dict_page.backContentYPos
                id_dict_page.backContentYPos =null
            }
             console.log("settingManager.isFirstEnterDictPage",settingManager.isFirstEnterDictPage)
//            if(settingManager.isFirstEnterDictPage){
//                qmlGlobal.shownavigationTips();
//            }

        } else {
            id_navigation_pages.packUpDictNav()
            qmlGlobal.canAutoAddToWb = false
            soundCenter.stop()
        }
    }

    //AI句子分析入口
    function jupToAiSentencepage(){
        if (!wifiManager.internetConnect){
            id_ai_pop_layer.showPage("components/YNetWorkConfigDialog");
//            baseSignals.showToast("此功能需要联网使用，请联网", YColors.grayNormal)
        }else{
            baseSignals.showLoading("分析中，请稍候", "#2D2E33")
            httprequestManager.httpReuqestAiSentence(resultManager.currentQuery)
            id_ai_pop_layer.showPage("dicts/YAISentenceAnalysisPage");
        }
    }

    function getAiJumpVisible(){
        if(resultManager.currentQuery.length === 0) return false
        var nWord = resultManager.currentQuery.split(" ")
        console.log("seven:AIBUTTON:0:",nWord)
        if(resultManager.currentQuery.length > 150) return false
        if(nWord.length < 3) return false
        if(resultManager.itemCount <= 0) return false
        var re = /[A-Za-z]+/
        if(resultManager.currentQuery.search(re) === 0 && isNeedVisibleAiButton) return true
        return false
    }

    //句子单词跟读
    function jupToFollowPageEx(){
        id_ai_pop_layer.showPage("follow/YFollowExPage");
    }

    function jupToFollowWordPageEx(){
        id_ai_pop_layer.showPage("components/YFollowWordExPage");
        currentShowPage.queryWordInfo()
    }


    YLoader {
        id: id_guide_loader
        anchors.fill: parent
        asynchronous: false
        active: false
        sourceComponent:id_follow_guide
    }

    Component {
        id: id_follow_guide
        YAiSentenceAnalysisGuidePage {
            z: 1000
            MouseArea {
                anchors.fill: parent
                onClicked: {
//                    id_guide_loader.sourceComponent = null
                    id_guide_loader.active = false
                }
            }
        }
    }
}

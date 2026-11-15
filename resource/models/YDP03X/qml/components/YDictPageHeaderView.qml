import QtQuick 2.12
import com.youdao.pen 1.0

import BaseQml 1.0
import "../components"
import "../i18n"
import "../commons"

Flow {
    id: id_dict_listview
    anchors.left: parent.left
    anchors.right: parent.right
    readonly property var koSpecialChar: ["-", ":", "^"]

    property var orgBreakList: resultManager.mainQueryBreakList
    property var breakContentStack: []
    property var breakSentenceStack: []
    property alias repeaterModel: id_breakList_repeter.model
    property var newBreakListArray: new Array//[[{},{}],[{}]]每一个分词以单词或字符为单位分词存进数组
    property var newBreakIndexToRawIndex: []
    property var singleWordLeftMargin: 0
    property var groupWordLeftMargin:  0/*chType ? 3 : 4*/
    property var singleWordRightMargin: 0
    property var groupWordRightMargin: 0/*chType ? 3 : 4*/
    property var clickIndex: null
    property var  isClick: false
    property bool chType: YEnum.WGT_Ch === resultManager.currentQueryType
                          ||YEnum.WGT_Ch_Group === resultManager.currentQueryType
    property bool isScanning: true

    property bool isAutoBreakWords: (resultManager.autoSelectIndex >= 0 || resultManager.mainQueryBreakList.length === 1) /*&& qmlGlobal.scanOldType !== 0*/

    property var indexMapArray: []
    property var pixelSizeArray:[]
    property var rawBreakListBackArray: []
    //spacing: 2
    focus: true
    property bool pointScanIsClick: false
    property var pointSelectIndex: []
    property var  mainQueryBreakListNotify :resultManager.mainQueryBreakList
    property bool isDetailShow: false
    property var detailContent: resultManager.currentQuery
    property var keysResult: resultManager.keysResult
    property int childrenHeight: height

    onMainQueryBreakListNotifyChanged: {
        breakContentStack = []
        breakSentenceStack = []
        clickIndex = null
        isClick = false
        pointScanIsClick = false
        try {
            id_dict_page.searchMoreIsClick = false
        }
        catch (e) {}
        pointSelectIndex = []

        if(resultManager.mainQueryBreakList.length <= 0)
            return
        isScanning = false
        id_breakList_repeter.model = ""
        orgBreakList = resultManager.mainQueryBreakList
        chType = Qt.binding(function(){return YEnum.WGT_Ch === resultManager.currentQueryType
                                       ||YEnum.WGT_Ch_Group === resultManager.currentQueryType})
        let totalArray = resultManager.newMainQueryBreakList
        let breakListData= null
        let arrayData = new Array
        //句子中是否含有中文
        if(YEnum.WGT_Sentence === resultManager.currentQueryType){
            resultManager.mainQueryBreakList.some(function(item){
                if(item.charType===YEnum.CT_CJK){
                    chType=true
                    return true
                }
            })
        }

        isAutoBreakWords = Qt.binding(function(){
            return (resultManager.autoSelectIndex >= 0 || resultManager.mainQueryBreakList.length === 1) /*&& qmlGlobal.scanOldType !== 0*/
        })
        if(isAutoBreakWords) {
            pointSelectIndex = resultManager.pointSelectIndex
        }
        orgBreakList = resultManager.orgBreakList
        setNewBreakListProperty()
        return  id_breakList_repeter.model = totalArray.length > 0 ? totalArray : orgBreakList
    }

    function setNewBreakListProperty() {
        newBreakIndexToRawIndex=[]
        newBreakListArray=[]
        newBreakIndexToRawIndex = resultManager.newBreakListIndexs
        newBreakListArray = resultManager.newBreakList
    }

    function breakWords(text,charType = -1) {
        let charactersList = null;
        if (charType !== -1 && charType !== YEnum.CT_PUNC) {
            switch (charType) {
            case YEnum.CT_ENG:
                if (text.indexOf(" ") !== -1) {
                    charactersList = qmlGlobal.englishSentenceToWordsList(text)
                }
                break
            case YEnum.CT_KO:
                charactersList = qmlGlobal.koreanToCharactersList(text)
                break
            case YEnum.CT_CJK:
            default:
                if(text.length>1)
                    charactersList = qmlGlobal.chineseToCharactersList(text)
                break
            }
        } else if(charType === -1) {
            switch (resultManager.currentQueryType) {
            case YEnum.WGT_En_Group:
                charactersList = qmlGlobal.englishSentenceToWordsList(text)
                break
            case YEnum.WGT_Ko_Group:
                charactersList = qmlGlobal.koreanToCharactersList(text)
                break
            case YEnum.WGT_Ch_Group:
            default:
                charactersList = qmlGlobal.chineseToCharactersList(text)
                break
            }
        }
        return charactersList != null && charactersList[0] !== text ? charactersList : null
    }


    function breakWordsNewMethod( text, charType = -1 ) {
        let charactersList = null;
        if ( charType !== -1 && charType !== YEnum.CT_PUNC ) {
            switch (charType) {
            case YEnum.CT_ENG:{
                if (text.indexOf(" ") !== -1) {
                    charactersList = text.split(" ")
                }
            }
            break
            case YEnum.CT_KO:
                charactersList = []
                for (let i=0; i<text.length; i++)
                    charactersList.push(text[i])
                break
            case YEnum.CT_UNKNOWN:
                charactersList = []
                charactersList.push(text)
                break
            case YEnum.CT_CJK:
            default:
            {
                charactersList = []
                for (let i=0; i<text.length; i++)
                    charactersList.push(text[i])
            }
            break
            }
        } else if (charType === -1) {
            switch (resultManager.currentQueryType) {
            case YEnum.WGT_En_Group:
                if (text.indexOf(" ") !== -1) {
                    charactersList = text.split(" ")
                }
                break
            case YEnum.WGT_Ko_Group:
                charactersList = []
                for (let i=0; i<text.length; i++)
                    charactersList.push(text[i])
                break
            case YEnum.WGT_Ch_Group:
            default:
                charactersList = []
                for(let i=0; i<text.length; i++)
                    charactersList.push(text[i])
                break
            }
        }
        return charactersList !== null && charactersList[0] != text ? charactersList : null
    }


    function getTotalBreakListArrayNewMethod(rawBreakList, totalArray, isExternal = 0) {
        newBreakIndexToRawIndex=[]
        newBreakListArray=[]
        for(let i = 0;i < rawBreakList.length;i++){
            if( typeof rawBreakList[i] == 'string' ) {
            }
            else {
                getSingleBreakListNewMethod(i, rawBreakList[i], totalArray)
            }
        }
        if(isExternal)
            id_breakList_repeter.model = totalArray
    }

    function getSingleBreakListNewMethod(rawindex, textJson, totalArray) {
        var breakListArray = breakWordsNewMethod(textJson.content,textJson.charType)
        if(breakListArray == null) {
            if(typeof newBreakListArray[rawindex] == "undefined")
                newBreakListArray[rawindex] = []
            newBreakListArray[rawindex].push(textJson)
            totalArray.push(textJson)
            let index = -1
            for(let i = 0 ;i <= rawindex; i++) {
                index += newBreakListArray[i].length
            }
            if(index !== -1)
                newBreakIndexToRawIndex[index] = rawindex
            return
        }else {
            for(var i = 0 ;i < breakListArray.length; i++) {
                var strJson = {'charType':textJson.charType,'content':breakListArray[i]}
                if(typeof newBreakListArray[rawindex] == "undefined")
                    newBreakListArray[rawindex]=[]
                newBreakListArray[rawindex].push(strJson)
                totalArray.push(strJson)
                let index = -1
                for(let i = 0 ;i <= rawindex;i++) {
                    index += newBreakListArray[i].length
                }
                if(index !== -1)
                    newBreakIndexToRawIndex[index]=rawindex
            }
        }
    }

    function getTotalBreakListArray(rawBreakList,totalArray,isExternal = 0) {
        newBreakIndexToRawIndex=[]
        newBreakListArray=[]
        for(let i=0;i<rawBreakList.length;i++) {
            if(typeof rawBreakList[i]=='string') {
            }
            else {
                getSingleBreakList(i,rawBreakList[i],totalArray)
            }
        }
        if(isExternal)
            id_breakList_repeter.model = totalArray
    }

    function getSingleBreakList(rawindex,textJson,totalArray) {
        var breakListArray = breakWords(textJson.content,textJson.charType)
        if(breakListArray === null) {
            if(typeof newBreakListArray[rawindex] == "undefined")
                newBreakListArray[rawindex]=[]
            newBreakListArray[rawindex].push(textJson)
            totalArray.push(textJson)
            let index = -1
            for(let i =0 ;i<=rawindex;i++)
            {
                index+=newBreakListArray[i].length
            }
            if(index != -1)
                newBreakIndexToRawIndex[index]=rawindex
            return
        } else {
            for(var i =0 ;i<breakListArray.length; i++) {
                var strJson = {'charType':textJson.charType,'content':breakListArray[i]}
                getSingleBreakList(rawindex,strJson,totalArray)
            }
        }
    }

    function updateRepeaterModel(index, charType, contentText) {
        if (resultManager.autoSelectIndex < 0) {
            resultManager.autoSelectIndex = index
            breakContentStack = []
        } else {
            breakContentStack.push(id_breakList_repeter.model)
        }
        breakSentenceStack.push(contentText)
        resultManager.queryResult(contentText)
        let charactersList
        switch (charType) {
        case YEnum.CT_ENG:
            charactersList = qmlGlobal.englishSentenceToWordsList(contentText)
            break
        case YEnum.CT_KO:
            charactersList = qmlGlobal.koreanToCharactersList(contentText)
            break
        case YEnum.CT_CJK:
        default:
            charactersList = qmlGlobal.chineseToCharactersList(contentText)
            break
        }

        let breakListTmp = []
        charactersList.forEach(function(breakChar){
            breakListTmp.push({charType: charType, content: breakChar})
        })
        id_breakList_repeter.model = breakListTmp
    }

    function backToPrevious() {
        //console.log("YDictPageHeaderView.qml === backToPrevious breakSentenceStack:", breakSentenceStack)
        breakSentenceStack.pop()
        //console.log("YDictPageHeaderView.qml === backToPrevious breakSentenceStack:", breakSentenceStack)
        if (breakContentStack.length > 0) {
            resultManager.queryResult(breakSentenceStack[breakSentenceStack.length - 1])
            id_breakList_repeter.model = breakContentStack.pop()
        } else if (resultManager.autoSelectIndex >= 0) {
            resultManager.autoSelectIndex = -1
            resultManager.queryResult(resultManager.mainQuery)
            id_breakList_repeter.model = orgBreakList
        }
    }

    function itemAtIndex(index) {
        return id_breakList_repeter.itemAt(index)
    }

    YTimer{
        id: id_delay_set_clickIndx
        interval: 200
        onTriggered: {
            clickIndex = null
        }
    }

    Repeater{
        id: id_breakList_repeter
        model: isDetailShow ? mainQueryBreakListNotify : null

        YDictPageHeaderHaveBottomLineItem {
            id: id_delegate
            enabled: !isScanning && rawEnableSet
            charType: isDetailShow ? YEnum.CT_ENG : model.modelData.charType
            nextIsNotPunc: index+1 < id_breakList_repeter.model.length && id_breakList_repeter.model[index+1].charType !== YEnum.CT_PUNC

            rectLastIsNotNewWord: rectItem.clickable && newBreakIndexToRawIndex.length>0
                                  && index !== 0
                                  && newBreakIndexToRawIndex[index] === newBreakIndexToRawIndex[index-1]
            rectNextIsNotNewWord: newBreakIndexToRawIndex.length > 0
                                  && index!=newBreakIndexToRawIndex.length-1
                                  && newBreakIndexToRawIndex[index] === newBreakIndexToRawIndex[index+1]
            rectLeftWidth: typeof isShowPinYinDict !== "undefined" && isShowPinYinDict ? 8 : (rectItem.lastIsNotNewWord ?
                                            groupWordLeftMargin :
                                            (rectItem.clickable && rectItem.nextIsNotNewWord ? singleWordLeftMargin : 0))
            rectRightWidth:  typeof isShowPinYinDict !== "undefined" && isShowPinYinDict ? 8 : (rectItem.nextIsNotNewWord ?
                                 groupWordRightMargin : (rectItem.clickable && rectItem.lastIsNotNewWord ?
                                                             singleWordRightMargin : 0))
            indexNum: index
            //点击变白色
            wordItem.color: {
                return (clickIndex !== null && newBreakIndexToRawIndex[clickIndex] === newBreakIndexToRawIndex[index]) ||
                       (pointSearchSelectIndex || typeof isShowPinYinDict !== "undefined" && isShowPinYinDict || isDetailShow) ? YColors.white : YColors.grayText
            }

//            visible: isDetailShow ? ( (0 === qmlGlobal.scanOldType && isAutoBreakWords && pointSelectIndex.indexOf(newBreakIndexToRawIndex[index]) !== -1) || resultManager.currentQuery === orgBreakList[(newBreakIndexToRawIndex.length ?newBreakIndexToRawIndex[index]:index)].content ? true : false) : true
            visible: isDetailShow ? (index === 0) : true

            readonly property bool isPunc: charType === YEnum.CT_PUNC
            readonly property string contentText: model.modelData.content

            content: isDetailShow ? detailContent : model.modelData.content
            rectClickIndex: clickIndex
            rectIndex: index
            associatedWord: resultManager.associatedWord

            Component.onCompleted: {
                if(qmlGlobal.scanOldType === 0) {
                    pointScanItemsWidth += width
                }
            }

            onClicked: {
                if(!isDetailShow) {
                    console.log("seven:ocr_word:")
                    logManager.sendHttpLog("action=detail_trans_words_click")
                    let iWantSearchVisible = id_head_search_more_loader.visible
                    isClick  = true
                    clickIndex = index
                    id_delay_set_clickIndx.restart()
                    if ((resultManager.currentQuery !== model.modelData.content && newBreakIndexToRawIndex.length<=0) ||
                            (newBreakIndexToRawIndex.length > index &&
                             resultManager.currentQuery !== orgBreakList[newBreakIndexToRawIndex[index]].content)) {

                        console.log("seven:ocr_word:1",resultManager.currentQuery)
                        pointScanIsClick = true
                        indexMapArray.push(newBreakIndexToRawIndex)
                        rawBreakListBackArray.push(orgBreakList)

                        if( iWantSearchVisible ) {
                            console.log("seven:ocr_word:2",resultManager.currentQuery, id_breakList_repeter.model)
                            id_dict_page.requeryWord(resultManager.mainQuery, "en", "zh-CHS",id_breakList_repeter.model,true,true)
                        }
                        else {
                            console.log("seven:ocr_word:3",resultManager.currentQuery, id_breakList_repeter.model)
                            id_dict_page.requeryWord(resultManager.currentQuery, "en", "zh-CHS",id_breakList_repeter.model,true)
                        }

                        resultManager.autoSelectIndex = newBreakIndexToRawIndex[index]
                        soundCenter.stop()
                        var tmp_keyWord = orgBreakList[newBreakIndexToRawIndex[index]].content
                        resultManager.updteCurrentQueryCondation(tmp_keyWord)
                        resultManager.queryResult(tmp_keyWord, false, [], true)
                        console.log("seven:ocr_word:4",resultManager.currentQuery, orgBreakList[newBreakIndexToRawIndex[index]].content)
                        if(id_dict_page.reportedSet.has(resultManager.currentQuery)) {
                            resultManager.isReportButtonVisible = false;
                        }
                        else {
                            resultManager.isReportButtonVisible = true;
                        }

                        let charactersList
                        switch (charType) {
                        case YEnum.CT_ENG:
                            charactersList = qmlGlobal.englishSentenceToWordsList(orgBreakList[newBreakIndexToRawIndex[index]].content)
                            break
                        case YEnum.CT_KO:
                            charactersList = qmlGlobal.koreanToCharactersList(orgBreakList[newBreakIndexToRawIndex[index]].content)
                            break
                        case YEnum.CT_CJK:
                        default:
                            charactersList = qmlGlobal.chineseToCharactersList(orgBreakList[newBreakIndexToRawIndex[index]].content)
                            break
                        }

                        let breakListTmp = []
                        charactersList.forEach(function(breakChar){
                            breakListTmp.push({charType: charType, content: breakChar})
                        })
                        orgBreakList = breakListTmp
                        let  totalArray = new Array
                        id_dict_listview.getTotalBreakListArray(orgBreakList,totalArray)
                        id_delay_set_clickIndx.stop()
                        clickIndex = null
                        id_breakList_repeter.model = totalArray.length > 0 ? totalArray : orgBreakList
                    }
//                    id_dict_listview.clickIndex = null
//                    console.warn("queryafter,clickIndex:::"+JSON.stringify(id_dict_listview.clickIndex))
                }
            }
        }
    }

    Component {
        id: id_break_word_component

        Item {
            id:id_rect_item
            width: !id_word_bg.nextIsNotNewWord
                   ?id_word_bg.implicitRectWidth+1 : id_word_bg.implicitRectWidth
            height: id_word_bg.height+1
            clip: true
            Rectangle {
                id: id_break_word_content
                height: id_break_word_text.height + 18
                //width: id_break_word_text.width + (isPunc ? 0 : 24)
                color: isPunc ? "transparent" : YColors.grayNormal
                radius: 8
                property int leftAndRightMargin: 8
                property int leftMove: 5
                property int implicitRectWidth: id_word.width + (clickable ? (leftWidth+rightWidth) : 0)
                width: implicitRectWidth + (id_break_word_content.lastIsNotNewWord||id_break_word_content.nextIsNotNewWord?leftMove:0)
                anchors.left: parent.left
                anchors.leftMargin: id_break_word_content.lastIsNotNewWord ? -leftMove : 0
                property int textPixelSize: id_word.font.pixelSize
                property int textLineCount: id_word.lineCount
                property var lastIsNotNewWord: false
                property var nextIsNotNewWord: false
                property var leftWidth:  0
                property var rightWidth: 0
                readonly property int charType: model.modelData.charType
                readonly property bool isPunc: charType === YEnum.CT_PUNC
                readonly property string contentText: model.modelData.content



                YTextBase {
                    id: id_break_word_text_width_cal
                    visible: false
                    anchors.centerIn: parent
                    font.pixelSize: 24
                    font.weight: Font.Bold
                    width: paintedWidth
                    text: id_break_word_content.contentText
                    readonly property bool needWrap: !id_break_word_content.isPunc && (width > (id_dict_listview.width - 24))
                }

                YTextBase {
                    id: id_break_word_text
                    width: id_break_word_text_width_cal.needWrap ? (id_dict_listview.width - 24) : paintedWidth
                    wrapMode:id_break_word_text_width_cal.needWrap ? YText.Wrap : YText.NoWrap
                    anchors.centerIn: parent
                    font.pixelSize: 24
                    font.weight: Font.Bold
                    color: id_break_word_content.isPunc ? YColors.grayText : YColors.red
                    text: id_break_word_content.contentText
                }

                YMouseArea {
                    anchors.fill: parent
                    enabled: !isPunc
                    onClicked: {
                        if (id_breakList_repeter.count <= 1) {
                            return
                        }
                        updateRepeaterModel(index, id_break_word_content.charType, id_break_word_content.contentText)
                    }
                }
            }
        }
    }


    YLoaderPhoneticSymbol{
        id: id_phonetic_symbol_loader
        active: (resultManager.currentQueryType === YEnum.WGT_En_Group || resultManager.currentQueryType === YEnum.WGT_En) && 0 !== qmlGlobal.scanOldType && !isDetailShow && systemBase.isButtonRelease && !isShowPinYinDict && id_breakList_repeter.model !==null && typeof id_breakList_repeter.model.length !== "undefined" && id_breakList_repeter.model.length
        visible: active
        onVisibleChanged: {
            if(0 !== qmlGlobal.scanOldType && !isDetailShow)
            isPhoneticSymbolShow = visible
        }
        property var parentHeight: childrenHeight
        onParentHeightChanged: {
            if(item)
                item.isWrap =  childrenHeight > 60
        }
        onLoaded: {
            item.isWrap =  childrenHeight > 60
        }
    }
}


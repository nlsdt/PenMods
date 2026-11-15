import QtQuick 2.12
import com.youdao.pen 1.0

import BaseQml 1.0
import "../i18n"

Item {
    id: id_poem_dict_data_column
    height: id_poem_dict_data_column_inner.height

    property var jsonPoemData: null
    property bool bSimpleShow: false
    property bool bHasAllPhone: false
    property var authorIntro: ""
    property int nCurExplanationIdx: 0

    onJsonPoemDataChanged: {
        if (jsonPoemData) {
            bHasAllPhone = jsonPoemData.pinyinAll
            if (typeof jsonPoemData.audio != "undefined" && jsonPoemData.audio.length > 0) {
                resultManager.downloadPoemAudioFile(jsonPoemData.audio, jsonPoemData.id)
            }
            if (typeof jsonPoemData.poem_explanation != "undefined" && jsonPoemData.poem_explanation.length > 0) {
                resultManager.downloadPoemExplanationFile(jsonPoemData.poem_explanation, jsonPoemData.id)
            }
            if (typeof jsonPoemData.uncleKaiAudio != "undefined" && jsonPoemData.uncleKaiAudio.length > 0) {
                qmlGlobal.isPoemReading = false
                resultManager.downloadPoemUncleKaiFile(jsonPoemData.uncleKaiAudio, jsonPoemData.id)
            }
        }
    }

    function formatPoemSentence(qsExplanationFormat, qsPhoneFormat, qslPhone)
    {
        let qsFormatResult = qsExplanationFormat;
        qsFormatResult = qsFormatResult.replace(/mark/g, "u");
        var nExplanationPos = 0;
        var nLastPos = 0;
        while ((nExplanationPos = qsFormatResult.indexOf("</u>", nLastPos)) !== -1)
        {
            id_poem_dict_data_column.nCurExplanationIdx++;
            qsFormatResult = qsFormatResult.slice(0, nExplanationPos + 4)
                    + ("<font style='color:%1;'>[").arg(YColors.grayText) + id_poem_dict_data_column.nCurExplanationIdx + "]</font>"
                    + qsFormatResult.slice(nExplanationPos + 4);
            nLastPos = nExplanationPos + 4;
        }
        //一句诗词只有部分拼音时，拼音嵌插在诗词中
        if (!id_poem_dict_data_column.bHasAllPhone && qslPhone.length > 0)
        {
            var nPinyinIndex = 0;
            var nPinyinPos = 0;
            nExplanationPos = 0;
            while (nPinyinPos < qsPhoneFormat.length)
            {
                if (nPinyinIndex >= qslPhone.length) // 防止数组越界
                {
                    break;
                }
                if (YEnum.CT_CJK === qmlGlobal.getCharType(qsPhoneFormat[nPinyinPos]))
                {
                    while (nExplanationPos < qsFormatResult.length && qsPhoneFormat[nPinyinPos] !== qsFormatResult[nExplanationPos])
                    {
                        nExplanationPos++;
                    }
                    nExplanationPos++;
                    if (qsPhoneFormat.substr(nPinyinPos + 1, 7) === "</mark>")
                    {
                        if (qsFormatResult.substr(nExplanationPos, 4) === "</u>")
                        {
                            nExplanationPos += 4;
                        }
                        qsFormatResult = qsFormatResult.slice(0, nExplanationPos)
                                + ("<font style='color:%1;'>（").arg(YColors.grayText) + qslPhone[nPinyinIndex++] + "）</font>"
                                + qsFormatResult.slice(nExplanationPos);
                    }
                }
                nPinyinPos++;
            }
        }
        return qsFormatResult;
    }


    function isHaveExplanation() {
        let isFind = false
        try{
        if (typeof jsonPoemData.detail.content != "undefined") {
            for (let i = 0; i< jsonPoemData.detail.content.length; i++) {
                jsonPoemData.detail.content[i].sentences.some(function(sentencesObject){
                    let qsFormatResult = sentencesObject.formatted
                    qsFormatResult = qsFormatResult.replace(/mark/g, "u");
                    var nExplanationPos = 0;
                    var nLastPos = 0;
                    while ((nExplanationPos = qsFormatResult.indexOf("</u>", nLastPos)) !== -1) {
                        nLastPos = nExplanationPos + 4;
                        isFind = true;
                        return true;
                    }})
                if(isFind) break;
            }
        }
        }catch(e) {}
        return isFind
    }

    function isHaveTranslate() {
        let isFind = false
        try{
            if (typeof jsonPoemData.detail.content != "undefined") {
                for (let i = 0; i< jsonPoemData.detail.content.length; i++) {
                    jsonPoemData.detail.content[i].sentences.some(function(sentencesObject){
                        if(typeof sentencesObject.translate !== "undefined" && sentencesObject.translate.length) {
                            isFind = true;
                            return true;
                        }
                    })
                    if(isFind) break;
                }
            }
        }catch(e) {}
        return isFind
    }

    Column {
        id: id_poem_dict_data_column_inner
        spacing: 16
        anchors.left: parent.left
        anchors.right: parent.right

        Grid{
            id: id_poem_content_grid
            rowSpacing: 12
            columnSpacing: 10
            columns: 2
            Repeater{
                id:id_poemButtons_repeater
                model: {
                    let buttonsArray=[]
                    //查看原文
                    if(jsonPoemData !== null
                            && typeof jsonPoemData.detail.content != "undefined"
                            && jsonPoemData.detail.content.length
                            && typeof jsonPoemData.detail.content[0].sentences != "undefined"
                            && jsonPoemData.detail.content[0].sentences.length)
                    {
                        buttonsArray.push(YTranslateText.original)
                    }

                    //查看赏析
                    if(jsonPoemData !== null
                            && typeof jsonPoemData.detail.analysis != "undefined"
                            && jsonPoemData.detail.analysis.length)
                    {
                        buttonsArray.push(YTranslateText.appreciation)
                    }
                    //注释对照
                    if(jsonPoemData !== null
                            && typeof jsonPoemData.detail.content != "undefined"
                            && jsonPoemData.detail.content.length
                            && (id_poem_dict_data_column.nCurExplanationIdx >= 1 || isHaveExplanation()))
                    {
                        buttonsArray.push(YTranslateText.annotationCompare)
                    }
                    //译文对照
                    if(jsonPoemData !== null
                            && typeof jsonPoemData.detail.content != "undefined"
                            && jsonPoemData.detail.content.length
                            && typeof jsonPoemData.detail.content[0].sentences != "undefined"
                            && jsonPoemData.detail.content[0].sentences.length && isHaveTranslate())
                    {
                        buttonsArray.push(YTranslateText.translationCompare)
                    }
                    //了解诗人
                    if(!bSimpleShow && id_poem_dict_data_column.authorIntro.length > 0)
                    {
                        buttonsArray.push(YTranslateText.author)
                    }
                    return buttonsArray
                }

                delegate:
                    //查看译文等
                    YButton {
                    radius: 16
                    width: 290
                    height: 76
                    //anchors.left: parent.left
                    text: model.modelData
                    color: YColors.grayNormal
                    textColor: YColors.white
                    onClicked: {
                        //                        if(qmlGlobal.currentPageIndex == YEnum.PageIndex.DictDetail)
                        //                            id_dict_detail_page.backLastPos = id_container_flickable.contentY
                        if(qmlGlobal.currentPageIndex == YEnum.PageIndex.Dict)
                            id_dict_page.backContentYPos =  id_container_flickable.contentY
                        let content =""
                        let title =""
                        switch(model.modelData)
                        {
                        case YTranslateText.original:
                        {

                             baseSignals.showToast(YTranslateText.loadingpoemcontent, YColors.grayNormal)
                            logManager.sendHttpLog("action=detail_more_click&dict=poem&card_name=trans")
                            content = JSON.stringify(jsonPoemData.detail.content)
                            title =  jsonPoemData.detail.title.origin+ " - " +YTranslateText.original
                            if(qmlGlobal.currentPageIndex == YEnum.PageIndex.Dict)
                                id_dict_page.backContentYPos =  id_container_flickable.contentY
                            qmlGlobal.showDictDetailPage(YEnum.DtChPoemDict,JSON.stringify({"originContent":jsonPoemData.detail.content,
                                                                                               "bHasAllPhone":id_poem_dict_data_column.bHasAllPhone,
                                                                                               "dynasty":(typeof jsonPoemData.dynasty != "undefined" ?
                                                                                                              jsonPoemData.dynasty:""),
                                                                                               "author" : typeof jsonPoemData.author != "undefined" ?
                                                                                               jsonPoemData.author:"",
                                                                                               "audio":jsonPoemData.audio,"id": jsonPoemData.id,
                                                                                               "poem_explanation":jsonPoemData.poem_explanation,
                                                                                               "uncleKaiAudio":jsonPoemData.uncleKaiAudio,
                                                                                           }),title)
                            break;
                        }
                        case YTranslateText.appreciation:
                        {
                            content =  JSON.stringify(jsonPoemData.detail.analysis)
                            title =  jsonPoemData.detail.title.origin + " - "+ YTranslateText.appreciation
                            qmlGlobal.showDictDetailPage(YEnum.DtChPoemDict+52, content, title)
                            break;
                        }
                        //注释对照
                        case YTranslateText.annotationCompare:
                        {
                            //TODO
                              baseSignals.showToast(YTranslateText.loadingpoemcontent, YColors.grayNormal)
                            id_deley_timer1.start()

                           // id_poem_view.show(YDictTypeDtChPoemReferenceView.ShowMode.OriginalNotes, jsonPoemData.detail.content)
                            break;
                        }
                        //译文对照
                        case YTranslateText.translationCompare:
                        {
                            //TODO
                            id_poem_view.show(YDictTypeDtChPoemReferenceView.ShowMode.OriginalTranslation, jsonPoemData.detail.content)
                            break;
                        }
                        //了解诗人
                        case YTranslateText.author:
                        {
                            //TODO
                            content = JSON.stringify({"aboutAuthor":id_poem_dict_data_column.authorIntro})
                            title =  jsonPoemData.detail.title.origin + " - "+YTranslateText.author
                             qmlGlobal.showDictDetailPage(YEnum.DtChPoemDict+53, content, title)
                            break;
                        }
                        }
                    }

                    YTimer {
                        id: id_deley_timer1
                        interval: 500
                        repeat: false
                        running: false;
                        onTriggered: {

                              id_poem_view.show(YDictTypeDtChPoemReferenceView.ShowMode.OriginalNotes, jsonPoemData.detail.content)
                        }
                    }



                }
            }
        }
    }
}




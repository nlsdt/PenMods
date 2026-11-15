import QtQuick 2.12

import BaseQml 1.0
import "../i18n"
import "../components"
import com.youdao.pen 1.0

YDictTypeBase{
    id:id_collins_item
    title: YTranslateText.dtCollinsPrimary
    property int containWidth: 545

    function getEnPartofSpeechList()
    {
        let enPartofSpeechListVar = []
        let iKey = 0

        if(typeof dictJson.gramcat!== "undefined" && typeof dictJson.gramcat.length != "undefined")
        {
            //let collinsSelectWord = collinsSelect.length ? collinsSelect.pop() : ""
            for(let i=0; i<dictJson.gramcat.length;i++)
            {
                if(typeof dictJson.gramcat[i].partofspeech != "undefined")
                    enPartofSpeechListVar.push(dictJson.gramcat[i].partofspeech)
            }
        }
        enPartofSpeechSelected = enPartofSpeechListVar[iKey]

        return enPartofSpeechListVar
    }

    function getDictSelectDetailsJson(enPartofSpeech,isClickLoadMore = false) {
        //console.log("YDictTypeDtChChinese.qml === function getDictSelectDetailsJson pinyin: ", pinyin, ", typeof pinyin: ", typeof pinyin)
        let jsonObjectMatched = null
        if (typeof enPartofSpeech !== "string" || enPartofSpeech.length <= 0) {
            return jsonObjectMatched
        }
        let jsonData = JSON.parse(content)
        jsonData.gramcat.some(function(dictDetailObject){
            let curPartofspeech = dictDetailObject.partofspeech
            if (curPartofspeech === enPartofSpeech) {
                if(isFirstShowAndClickLoadMore && !isClickLoadMore && typeof dictDetailObject.senses != "undefined"
                        &&( (typeof dictDetailObject.senses.length != "undefined" && dictDetailObject.senses.length>1)
                           ||( (typeof dictDetailObject.senses.length != "undefined" && dictDetailObject.senses.length > 0 &&
                                typeof dictDetailObject.senses[0].examples != "undefined" && typeof dictDetailObject.senses[0].examples.length != "undefined"
                                &&  dictDetailObject.senses[0].examples.length>0)
                              ||((typeof dictDetailObject.senses.length != "undefined" && dictDetailObject.senses.length > 0
                                  && typeof dictDetailObject.senses[0].derivatives != "undefined"
                                  && typeof dictDetailObject.senses[0].derivatives.length != "undefined"
                                  &&  dictDetailObject.senses[0].derivatives.length>0))))
                        )
                {
                    //delete dictDetailObject.senses[0].examples
                    let arrayObject = {}
                    if( typeof dictDetailObject.senses[0].word != "undefined")
                        arrayObject["word"] = dictDetailObject.senses[0].word
                    if( typeof dictDetailObject.senses[0].definition != "undefined")
                        arrayObject["definition"] = dictDetailObject.senses[0].definition
                    dictDetailObject.senses=[arrayObject]
                    loadMoreVisible = true
                    ocrStopShowCollins = false
                }
                if(isClickLoadMore)  ocrStopShowCollins = false
                jsonObjectMatched = dictDetailObject
                return true
            }
        })
        return jsonObjectMatched
    }

    property var enPartofSpeechList: getEnPartofSpeechList()
    property string enPartofSpeechSelected:""

    property var dictSelectDetailsJson:  {
        if (enPartofSpeechSelected.length > 0) {
            return getDictSelectDetailsJson(enPartofSpeechSelected)
        } else {
            return null
        }
    }

    onEnPartofSpeechSelectedChanged: {
        //console.log("YDictTypeDtChChinese.qml === onChPinyinSelectedChanged chPinyinSelected: ", chPinyinSelected)
        dictSelectDetailsJson = getDictSelectDetailsJson(enPartofSpeechSelected)
    }

    onDictJsonChanged: {
        if(dictType == YEnum.DtCollinsPrimary) {
//            console.warn("***********************collisDictJSon:"+JSON.stringify(dictJson))
            //isFirstShowAndClickLoadMore = true
            enPartofSpeechList = getEnPartofSpeechList()
        }
    }

    Component.onCompleted: {
        let collinsSelectWord = collinsSelect.length ? collinsSelect.pop() : ""
        if( collinsSelectWord !==  enPartofSpeechSelected && enPartofSpeechList.indexOf(collinsSelectWord) !== -1) {
            enPartofSpeechSelected = collinsSelectWord
        }
    }

    property var loadMoreVisible: false
    property bool isFirstShowAndClickLoadMore: ocrStopShowCollins

    Item{
        width: parent.width
        height: id_dict_content_column.height




        Column {
            id: id_dict_content_column


            //            onDictJsonChanged: {
            //                  }
            width: parent.width
            spacing: 8

//            Flickable {
//                id: id_ch_pinyins_flick
//                anchors.left: parent.left
//                anchors.right: parent.right
//                height: 52
//                contentWidth: id_dict_ch_pinyin_list.width
//                flickableDirection: Flickable.HorizontalFlick
//                visible: id_dict_ch_pinyin_list_repeater.count >= 1
//                clip: true

//                Connections {
//                    target: resultManager
//                    ignoreUnknownSignals: true
//                    function onCurrentQueryChanged() {
////                        chPinYinList =[]
////                        firstDictJson = ({})
////                        chPinyinSelected = Qt.binding(function(){ return chPinYinList.length ? chPinYinList[0] : ""})
//                    }
//                }

//                Row {
//                    id: id_dict_ch_pinyin_list
//                    height: 52
//                    spacing: 10
//                    anchors.bottom: parent.bottom
//                    visible: (keysList.length && Object.keys(dictJson).length) || id_dict_content_view_repeater_empty_tip.visible

//                    Repeater {
//                        id: id_dict_ch_pinyin_list_repeater
//                        model: {
//                             return keysList
//                        }

//                        YAudioPlayIconLabelHCenterButton {
//                            height: 52
//                            color: YColors.grayNormal
//                            textItem.font.pixelSize: 26
//                            textItem.font.family: fontManager.fontFamilyEnUs
//                            text: model.modelData.split('\t')[0]
//                            textItem.color: isCurrentSelectedPinyin ? YColors.red : YColors.white
//                            iconItem.visible: false
//                            width: (iconItem.visible ? iconItem.width : 0) + textItem.width + 20 * 2
//                            property var currentModelData: model.modelData
//                            property int selectI: chCurrentEnSelected.split('\t').length ? parseInt(chCurrentEnSelected.split('\t')[1]) : 0

//                            Component.onCompleted: {
//                                chCurrentEnSelected =  keysList.length ? getDefalutKey() : ""
//                            }

//                            readonly property bool isCurrentSelectedPinyin : {
//                              console.warn("isCurrentSelectedPinyin::::::::::::::::chCurrentEnSelected:"+chCurrentEnSelected)
//                               return  chCurrentEnSelected === currentModelData
//                            }

//                            onValidClicked: {
//                                console.log("YDictPage.qml === id_dict_ch_pinyin_list.btn.onClicked text: ", text)
//                                console.warn("YDictPage.qml === id_dict_ch_pinyin_list.btn.onClicked seletI: ", selectI)
//                                logManager.sendHttpLog("action=detail_chinese_audio")
//                                chCurrentEnSelected = currentModelData
//                                let keysListTmp
//                                dictJson = resetDictJson(rawContent,keysListTmp,selectI)
//                                getDictContentValue(dictType,content,index)
//                                }
//                            }
//                        }
//                    }
//                }


//            YSpacingForColumn{
//                height: 2
//                visible: id_ch_pinyins_flick.visible
//            }


            Flickable {
                anchors.left: parent.left
                anchors.right: parent.right
                height: 52
                contentWidth: id_dict_en_pinyin_list.width
                flickableDirection: Flickable.HorizontalFlick
                visible: id_dict_en_pinyin_list_repeater.count >= 1
                clip: true

                Row {
                    id: id_dict_en_pinyin_list
                    height: 52
                    spacing: 10
                    anchors.bottom: parent.bottom

                    Repeater {
                        id: id_dict_en_pinyin_list_repeater
                        model: enPartofSpeechList

                        YButton {
                            height: 52
                            width: textWidth + 35*2
                            textColor: id_collins_item.enPartofSpeechSelected+"." === text ? YColors.red : YColors.white
                            color: "#27282C"
                            textFamily: fontManager.fontFamilyClass
                            textItem.font.styleName: "Italic"
                            textItem.topPadding: 3
                            textWeight: Font.Medium
                            text: model.modelData+"."
                            pixelSize: 28
                            //letterSpacing: 2.6
                            onClicked: {
                                loadMoreVisible = false
                                id_sound_uk.stop()
                                console.log("YDictPage.qml === id_dict_ch_pinyin_list.btn.onClicked text: ", text)
                                id_collins_item.enPartofSpeechSelected = text.substring(0,text.length-1)
                                console.log("YDictPage.qml === id_dict_ch_pinyin_list.btn.onClicked id_collins_item.enPartofSpeechSelected: ", id_collins_item.enPartofSpeechSelected)
                                //                                if (isFirstDict) {
                                //                                    //resultManager.phoneticSymbolJson = text
                                //                                    //qmlGlobal.soundWGTCh()
                                //                                }
                            }
                        }
                    }
                }
            }

            //发音
            YAudioPlayIconLabelButton {
                implicitHeight: textItem.contentHeight+2
                id: id_sound_uk
                textItem.width: 570
                leftMargin: 0
                textWrapMode:YText.Wrap
                sourceSize:Qt.size(32,textItem.contentHeight+18)
                color: "transparent"
                property var audioNumber: dictSelectDetailsJson.audio
                visible: (typeof dictSelectDetailsJson.pronunciation != "undefined"
                          && typeof dictSelectDetailsJson.pronunciation.length != "undefined"
                          && dictSelectDetailsJson.pronunciation.length > 0)
                text: {
                    if (!visible) {
                        return ""
                    }
                    if (typeof dictSelectDetailsJson.pronunciation != "undefined"
                            && typeof dictSelectDetailsJson.pronunciation.length != "undefined"
                            && dictSelectDetailsJson.pronunciation.length > 0) {
                        return ('<span style="font-family: %3;font-size:28px">&frasl;&nbsp;%4&nbsp;&frasl;</span>')
                        /* .arg(fontManager.fontFamily).arg(YTranslateText.shorthandEN)*/.arg(fontManager.fontFamilyEnUs).arg(dictSelectDetailsJson.pronunciation)
                    }
                }
                onValidClicked: {
                    if (playing) {
                        logManager.sendHttpLog("action=detail_words_click")
                        var nAutoPronType =  YEnum.CollinsPrimary
                        qmlGlobal.audioPlayId = soundCenter.play(resultManager.currentQuery,
                                                                 resultManager.getSoundLanguage(),
                                                                 id_sound_uk.audioNumber,
                                                                 nAutoPronType + 1)
                        //qmlGlobal.soundWGTEn(resultManager.currentQuery, YEnum.UK)

                    }
                }
            }

            Repeater{
                anchors.left: parent.left
                anchors.right: parent.right
                visible: (typeof dictSelectDetailsJson.senses != "undefined"
                          && typeof dictSelectDetailsJson.senses.length != "undefined"
                          && dictSelectDetailsJson.senses.length > 0)
                model:  dictSelectDetailsJson.senses

               Column {
                   anchors.left: parent.left
                   anchors.right: parent.right
                Item {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    //anchors.leftMargin: 36
                    height: Math.max(id_mean_column.height,id_en_sentenct_index.height)

                    YText {
                        id: id_en_sentenct_index
                        //width: 6
                        //height: 6
                        font.family: fontManager.fontFamilyEnUs
                        font.pixelSize: 28
                        color: YColors.grayText
                        text: (index+1) + ". "
                        font.bold: true
                        //visible: id_en_sen_mean.visible
                    }

                    Column{
                        anchors.left: id_en_sentenct_index.right
                        anchors.leftMargin: 12
                        anchors.right: parent.right
                        spacing: 0
                        id: id_mean_column

                        //英文释义
                        YText {
                            id: id_en_mean
                            anchors.left: parent.left
                            anchors.right: parent.right
                            //anchors.verticalCenter: parent.verticalCenter
                            font.family: fontManager.fontFamilyEnUs
                            wrapMode: YText.Wrap
                            font.pixelSize: 28
                            width: containWidth
                            height: paintedHeight
                            textFormat: YText.RichText
                            text: /*'<font color="%2">%1</font>'.arg((index+1) + ". ").arg(YColors.grayText)+*/model.modelData.definition
                            visible: typeof model.modelData.definition!="undefined"
                                     && typeof model.modelData.definition.length!="undefined"
                                     && model.modelData.definition.length>0
                            font.bold: true
                        }

                        YSpacingForColumn{
                            height: 6
                        }
                        //中文释义
                        YText {
                            id: id_zh_mean
                            anchors.left: parent.left
                            anchors.right: parent.right
                            //anchors.verticalCenter: parent.verticalCenter
                            font.family: fontManager.fontFamilyZhCn
                            color: YColors.grayText
                            wrapMode: YText.Wrap
                            font.pixelSize: 28
                            width: containWidth
                            height: paintedHeight
                            visible: typeof model.modelData.word!="undefined"
                                     && typeof model.modelData.word.length!="undefined"
                                     && model.modelData.word.length>0 && !settingManager.isNotShowCollinsChinese
                            text: model.modelData.word
                        }

                        YSpacingForColumn{
                            visible:id_examples_repeater.count && id_examples_repeater.itemAt(0).visible
                            height: 16
                        }

                        property var modelModelData: model.modelData

                        Repeater{
                            id: id_examples_repeater
                            visible: typeof id_mean_column.modelModelData.examples!="undefined"
                                     && typeof id_mean_column.modelModelData.examples.length!="undefined"
                                     && id_mean_column.modelModelData.examples.length>0
                                     && typeof id_mean_column.modelModelData.examples[0].example!="undefined"
                            && typeof id_mean_column.modelModelData.examples[0].example.length!="undefined"
                            && typeof id_mean_column.modelModelData.examples[0].example.length>0
                            model: {
                                return id_mean_column.modelModelData.examples
                            }
                            Item {
                                anchors.left: parent.left
                                anchors.right: parent.right
                                //anchors.leftMargin: 36
                                height: Math.max(id_sentece_column.height,id_en_sentenct_circle.height)
                                //visible: id_en_sen_mean.visible
                                YText {
                                    id: id_en_sentenct_circle
                                    //width: 6
                                    //height: 6
                                    font.family: fontManager.fontFamilyEnUs
                                    font.pixelSize: 28
                                    text: "· "
                                    font.bold: true
                                    //visible: id_en_sen_mean.visible
                                }
                                Column{
                                    id: id_sentece_column
                                    anchors.left: id_en_sentenct_circle.right
                                    anchors.leftMargin: 12
                                    width: containWidth
                                    //height: id_en_sen_mean.height + id_en_ch_sen_mean.height
                                    //英文句子
                                    YText {
                                        id: id_en_sen_mean
                                        anchors.left: parent.left
                                        anchors.right: parent.right
                                        //anchors.verticalCenter: parent.verticalCenter
                                        font.family: fontManager.fontFamilyEnUs
                                        wrapMode: YText.Wrap
                                        font.pixelSize: 28
                                        width: containWidth
                                        height: paintedHeight
                                        visible: typeof model.modelData.example!="undefined"
                                                 && typeof model.modelData.example.length!="undefined"
                                                 && model.modelData.example.length>0
                                        text: model.modelData.example
                                        font.bold: true
                                    }
                                    YSpacingForColumn{
                                        visible: id_en_ch_sen_mean.visible
                                        height: 6
                                    }
                                    //英文句子翻译
                                    YText {
                                        id: id_en_ch_sen_mean
                                        anchors.left: parent.left
                                        anchors.right: parent.right
                                        color: YColors.grayText
                                        //anchors.verticalCenter: parent.verticalCenter
                                        font.family: fontManager.fontFamilyZhCn
                                        wrapMode: YText.Wrap
                                        font.pixelSize: 28
                                        width: containWidth
                                        height: paintedHeight
                                        visible: typeof model.modelData.sense!="undefined"
                                                 && typeof model.modelData.sense.word!="undefined"
                                                 && model.modelData.sense.word.length>0 && !settingManager.isNotShowCollinsChinese
                                        text: model.modelData.sense.word
                                        //                            font.bold: true
                                    }

                                }

                            }
                        }

                        YSpacingForColumn{
                            height: 24
                            visible: id_derivatives_text.visible
                        }
                        //                    //虚线
                        //                    YVerticalDividingLine {
                        //                        id: id_div_derivatives_line
                        //                        width: parent.width
                        //                        height: 2
                        //                        visible: id_derivatives_repeater.count > 0 && id_derivatives_repeater.itemAt(0).visible
                        //                    }

                        //                    YSpacingForColumn{
                        //                        height: 20
                        //                        visible: id_div_derivatives_line.visible
                        //                    }

                    }
                }

                Column {
                    id:id_derivatives_content_column
                    anchors.left: parent.left
                    anchors.right: parent.right

                    property var modelModelData: model.modelData



                    //派生词
                    YTextBase {
                        id:id_derivatives_text
                        font.pixelSize: 26
                        color: YColors.red
                        anchors.left: parent.left
                        anchors.right: parent.right
                        //anchors.leftMargin:
                        width: 100
                        height:  34
                        text: YTranslateText.derivatives
                        visible: id_derivatives_repeater.count > 0 && id_derivatives_repeater.itemAt(0).visible
                        Component.onCompleted: {
                            if(id_derivatives_repeater.count > 0 && id_derivatives_repeater.itemAt(0).visible)
                                dictNodeCompleted(text, dictType, 1, this);
                        }
                    }

                    YSpacingForColumn{
                        height: 10
                        visible: id_derivatives_text.visible
                    }
                    Repeater{
                        id: id_derivatives_repeater
                        visible: typeof id_derivatives_content_column.modelModelData.derivatives!="undefined"
                                 && typeof id_derivatives_content_column.modelModelData.derivatives.length!="undefined"
                                 && id_derivatives_content_column.modelModelData.derivatives.length>0
                                 && typeof id_derivatives_content_column.modelModelData.derivatives[0].word!="undefined"
                        && typeof id_derivatives_content_column.modelModelData.derivatives[0].word.length!="undefined"
                        && typeof id_derivatives_content_column.modelModelData.derivatives[0].word.length>0
                        model: id_derivatives_content_column.modelModelData.derivatives
                        Column{
                            anchors.left: parent.left
                            anchors.right: parent.right
                            spacing: 0
                            id:id_derivatives_column
                            //英文句子翻译
                            YDictPageClickSearchTextItem{
                                word: {
                                    return '<span style="color:#509DEB;font-weight:500">%1</span>'.arg(model.modelData.word) +
                                            (typeof model.modelData.partofspeech === "undefined" ? ""
                                                                                                 : (('<span style="color:#909199; font-weight:normal; font-family:%1">[%2.]</span>').arg(fontManager.fontFamilyClass).arg(model.modelData.partofspeech)))
                                }
                                isCHType: false
                                onClicked: {
                                    collinsSelect.push(enPartofSpeechSelected)
                                    id_dict_page.clickSearchWord(model.modelData.word)
                                }
                            }

                            YSpacingForColumn{
                                height: 13
                                visible:id_derivatives_sound_uk.visible
                            }
                            //发音
                            YAudioPlayIconLabelButton {
                                implicitHeight: textItem.contentHeight+2
                                id: id_derivatives_sound_uk
                                leftMargin:0
                                textItem.width: 570
                                textWrapMode:YText.Wrap
                                sourceSize:Qt.size(32,textItem.contentHeight+18)
                                color: "transparent"
                                property var audioNumber: model.modelData.audio
                                visible: (typeof model.modelData.pronunciation != "undefined"
                                          && typeof model.modelData.pronunciation.length != "undefined"
                                          && model.modelData.pronunciation.length > 0)
                                text: {
                                    if (!visible) {
                                        return ""
                                    }
                                    if (typeof model.modelData.pronunciation != "undefined"
                                            && typeof model.modelData.pronunciation.length != "undefined"
                                            && model.modelData.pronunciation.length > 0) {
                                        return ('<span style="font-family: %3;font-size:28px">&frasl;&nbsp;%4&nbsp;&frasl;</span>')
                                        /*.arg(fontManager.fontFamily).arg(YTranslateText.shorthandEN)*/.arg(fontManager.fontFamilyEnUs).arg(model.modelData.pronunciation)
                                    }
                                }
                                onValidClicked: {
                                    if (playing) {
                                        var nAutoPronType =  YEnum.CollinsPrimary
                                        qmlGlobal.audioPlayId = soundCenter.play(resultManager.currentQuery,
                                                                                 resultManager.getSoundLanguage(),
                                                                                 id_derivatives_sound_uk.audioNumber,
                                                                                 nAutoPronType + 1)
                                        //qmlGlobal.soundWGTEn(resultManager.currentQuery, YEnum.UK)

                                    }
                                }
                            }

                            YSpacingForColumn{
                                height: 13
                                //visible:
                            }
                            //句子
                            property var modelModelData: model.modelData
                            Repeater{
                                id: id_derivatives_examples_repeater
                                property var visibleVar: typeof id_derivatives_column.modelModelData.sense!="undefined"
                                                         && typeof id_derivatives_column.modelModelData.sense.length!="undefined"
                                                         && id_derivatives_column.modelModelData.sense.length>0
                                                         && typeof id_derivatives_column.modelModelData.sense[0].word!="undefined"
                                && typeof id_derivatives_column.modelModelData.sense[0].word.length!="undefined"
                                && typeof id_derivatives_column.modelModelData.sense[0].word.length>0
                                model:
                                {
                                    return id_derivatives_column.modelModelData.sense
                                }
                                Column{
                                    anchors.left: parent.left
                                    id:id_derivatives_mean_column
                                    property var modelModelData: model.modelData
                                    width: containWidth
                                    //height: id_en_sen_mean.height+id_en_ch_sen_mean.height
                                    //中文意思
                                    YText {
                                        id: id_derivatives_ch_mean
                                        anchors.left: parent.left
                                        anchors.right: parent.right
                                        //anchors.verticalCenter: parent.verticalCenter
                                        color: YColors.grayText
                                        font.family: fontManager.fontFamilyZhCn
                                        wrapMode: YText.Wrap
                                        font.pixelSize: 28
                                        width: containWidth
                                        height: paintedHeight
                                        visible: typeof model.modelData.word!="undefined"
                                                 && typeof model.modelData.word.length!="undefined"
                                                 && model.modelData.word.length>0 && !settingManager.isNotShowCollinsChinese
                                        text: model.modelData.word
                                    }
                                    YSpacingForColumn{
                                        height: 6
                                        visible: id_derivatives_mean_examples_repeater.visibleVar
                                    }
                                    Repeater{
                                        id: id_derivatives_mean_examples_repeater
                                        property var visibleVar: typeof id_derivatives_mean_column.modelModelData.examples!="undefined"
                                                                 && typeof id_derivatives_mean_column.modelModelData.examples.length!="undefined"
                                                                 && id_derivatives_mean_column.modelModelData.examples.length>0
                                                                 && typeof id_derivatives_mean_column.modelModelData.examples[0].example!="undefined"
                                        && typeof id_derivatives_mean_column.modelModelData.examples[0].example.length!="undefined"
                                        && typeof id_derivatives_mean_column.modelModelData.examples[0].example.length>0
                                        model:
                                        {
                                            return id_derivatives_mean_column.modelModelData.examples
                                        }
                                        Column{
                                            anchors.left: parent.left
                                            anchors.right: parent.right
                                            //英文句子
                                            YText {
                                                id: id_derivatives_en_sentence
                                                anchors.left: parent.left
                                                anchors.right: parent.right
                                                //anchors.verticalCenter: parent.verticalCenter
                                                font.family: fontManager.fontFamilyEnUs
                                                wrapMode: YText.Wrap
                                                font.pixelSize: 28
                                                width: containWidth
                                                height: paintedHeight
                                                visible: typeof model.modelData.example!="undefined"
                                                         && typeof model.modelData.example.length!="undefined"
                                                         && model.modelData.example.length>0
                                                text: model.modelData.example
                                                font.bold: true
                                            }
                                            YSpacingForColumn{
                                                visible: id_derivatives_en_ch_sentence_mean.visible
                                                height: 6
                                            }
                                            //英文句子翻译
                                            YText {
                                                id: id_derivatives_en_ch_sentence_mean
                                                anchors.left: parent.left
                                                anchors.right: parent.right
                                                color: YColors.grayText
                                                //anchors.verticalCenter: parent.verticalCenter
                                                font.family: fontManager.fontFamilyZhCn
                                                wrapMode: YText.Wrap
                                                font.pixelSize: 22
                                                width: containWidth
                                                height: paintedHeight
                                                visible: typeof model.modelData.sense!="undefined"
                                                         && typeof model.modelData.sense.word!="undefined"
                                                         && model.modelData.sense.word.length>0 && !settingManager.isNotShowCollinsChinese
                                                text: model.modelData.sense.word
                                            }
                                        }
                                    }

                                }
                            }

                        }
                    }

                }

               }
            }

            //短语
            Column {
                id:id_phrases_content_column
                anchors.left: parent.left
                anchors.right: parent.right

                property var modelModelData: model.modelData



                //短语
                YTextBase {
                    id:id_phrases_text
                    font.pixelSize: 26
                    color: YColors.red
                    anchors.left: parent.left
                    anchors.right: parent.right
                    //anchors.leftMargin:
                    width: 100
                    height:  34
                    text: YTranslateText.phrases
                    visible: id_phrases_repeater.count > 0 && id_phrases_repeater.itemAt(0).visible
                    Component.onCompleted: {
                        dictNodeCompleted(text, dictType, 1, this);
                    }
                }

                YSpacingForColumn{
                    height: 10
                    visible: id_phrases_text.visible
                }
                Repeater{
                    id: id_phrases_repeater
                    visible: typeof dictSelectDetailsJson.phrases!="undefined"
                             && typeof dictSelectDetailsJson.phrases.length!="undefined"
                             && dictSelectDetailsJson.phrases.length>0
                             && ((typeof dictSelectDetailsJson.phrases[0].phrase!="undefined"
                    && typeof dictSelectDetailsJson.phrases[0].phrase.length!="undefined"
                    && typeof dictSelectDetailsJson.phrases[0].phrase.length>0 ) || (typeof dictSelectDetailsJson.phrases[0].phrasalverb!="undefined"
                                                                                     && typeof dictSelectDetailsJson.phrases[0].phrasalverb.length!="undefined"
                                                                                     && typeof dictSelectDetailsJson.phrases[0].phrasalverb.length>0 ))
                    model: dictSelectDetailsJson.phrases
                    Column{
                        anchors.left: parent.left
                        anchors.right: parent.right
                        spacing: 0
                        id:id_phrases_column
                        //英文句子翻译
                        YDictPageClickSearchTextItem{
                            property var textWord: typeof model.modelData.phrase !== "undefined" ?
                                                       model.modelData.phrase :
                                                       model.modelData.phrasalverb[0].phrase
                            word: {
                                return '<span style="color:#509DEB;font-weight:500">%1</span>'.arg(textWord)
                            }
                            isCHType: false
                            onClicked: {
                                collinsSelect.push(enPartofSpeechSelected)
                                id_dict_page.clickSearchWord(textWord)
                            }
                        }

//                        YSpacingForColumn{
//                            height: 13
//                            visible:id_phrases_sound_uk.visible
//                        }
//                        //发音
//                        YAudioPlayIconLabelButton {
//                            implicitHeight: textItem.contentHeight+2
//                            id: id_phrases_sound_uk
//                            leftMargin:0
//                            textItem.width: 570
//                            textWrapMode:YText.Wrap
//                            sourceSize:Qt.size(32,textItem.contentHeight+18)
//                            color: "transparent"
//                            property var audioNumber: model.modelData.audio
//                            visible: (typeof model.modelData.pronunciation != "undefined"
//                                      && typeof model.modelData.pronunciation.length != "undefined"
//                                      && model.modelData.pronunciation.length > 0)
//                            text: {
//                                if (!visible) {
//                                    return ""
//                                }
//                                if (typeof model.modelData.pronunciation != "undefined"
//                                        && typeof model.modelData.pronunciation.length != "undefined"
//                                        && model.modelData.pronunciation.length > 0) {
//                                    return ('<span style="font-family: %3;font-size:28px">&frasl;&nbsp;%4&nbsp;&frasl;</span>')
//                                    /*.arg(qmlGlobal.fontFamily).arg(YTranslateText.shorthandEN)*/.arg(qmlGlobal.fontFamilyEnUs).arg(model.modelData.pronunciation)
//                                }
//                            }
//                            onValidClicked: {
//                                if (playing) {
//                                    var nAutoPronType =  YEnum.CollinsPrimary
//                                    qmlGlobal.audioPlayId = soundCenter.play(resultManager.currentQuery,
//                                                                             resultManager.getSoundLanguage(),
//                                                                             id_derivatives_sound_uk.audioNumber,
//                                                                             nAutoPronType + 1)
//                                    //qmlGlobal.soundWGTEn(resultManager.currentQuery, YEnum.UK)

//                                }
//                            }
//                        }

                        YSpacingForColumn{
                            height: 13
                            //visible:
                        }
                        //句子
                        property var modelModelData: model.modelData
                        Repeater{
                            id: id_phrases_examples_repeater
                            property var visibleVar: typeof id_phrases_column.modelModelData.senses!="undefined"
                                                     && typeof id_phrases_column.modelModelData.senses.length!="undefined"
                                                     && id_phrases_column.modelModelData.senses.length>0
                                                     && typeof id_phrases_column.modelModelData.senses[0].word!="undefined"
                            && typeof id_phrases_column.modelModelData.senses[0].word.length!="undefined"
                            && typeof id_phrases_column.modelModelData.senses[0].word.length>0
                            model:
                            {
                                return id_phrases_column.modelModelData.senses
                            }
                            Column{
                                anchors.left: parent.left
                                id:id_phrases_mean_column
                                property var modelModelData: model.modelData
                                width: containWidth
                                //height: id_en_sen_mean.height+id_en_ch_sen_mean.height
                                //中文意思
                                YText {
                                    id: id_phrases_ch_mean
                                    anchors.left: parent.left
                                    anchors.right: parent.right
                                    //anchors.verticalCenter: parent.verticalCenter
                                    color: YColors.grayText
                                    font.family: qmlGlobal.fontFamilyZhCn
                                    wrapMode: YText.Wrap
                                    font.pixelSize: 28
                                    width: containWidth
                                    height: paintedHeight
                                    visible: typeof model.modelData.word!="undefined"
                                             && typeof model.modelData.word.length!="undefined"
                                             && model.modelData.word.length>0 && !settingManager.isNotShowCollinsChinese
                                    text: model.modelData.word
                                }
                                YSpacingForColumn{
                                    height: 6
                                    visible: id_phrases_mean_examples_repeater.visibleVar
                                }
                                Repeater{
                                    id: id_phrases_mean_examples_repeater
                                    property var visibleVar: typeof id_phrases_mean_column.modelModelData.examples!="undefined"
                                                             && typeof id_phrases_mean_column.modelModelData.examples.length!="undefined"
                                                             && id_phrases_mean_column.modelModelData.examples.length>0
                                                             && typeof id_phrases_mean_column.modelModelData.examples[0].example!="undefined"
                                    && typeof id_phrases_mean_column.modelModelData.examples[0].example.length!="undefined"
                                    && typeof id_phrases_mean_column.modelModelData.examples[0].example.length>0
                                    model:
                                    {
                                        return id_phrases_mean_column.modelModelData.examples
                                    }
                                    Column{
                                        anchors.left: parent.left
                                        anchors.right: parent.right
                                        //英文句子
                                        YText {
                                            id: id_phrases_en_sentence
                                            anchors.left: parent.left
                                            anchors.right: parent.right
                                            //anchors.verticalCenter: parent.verticalCenter
                                            font.family: qmlGlobal.fontFamilyEnUs
                                            wrapMode: YText.Wrap
                                            font.pixelSize: 28
                                            width: containWidth
                                            height: paintedHeight
                                            visible: typeof model.modelData.example!="undefined"
                                                     && typeof model.modelData.example.length!="undefined"
                                                     && model.modelData.example.length>0
                                            text: model.modelData.example
                                            font.bold: true
                                        }
                                        YSpacingForColumn{
                                            visible: id_phrases_en_ch_sentence_mean.visible
                                            height: 6
                                        }
                                        //英文句子翻译
                                        YText {
                                            id: id_phrases_en_ch_sentence_mean
                                            anchors.left: parent.left
                                            anchors.right: parent.right
                                            color: YColors.grayText
                                            //anchors.verticalCenter: parent.verticalCenter
                                            font.family: qmlGlobal.fontFamilyZhCn
                                            wrapMode: YText.Wrap
                                            font.pixelSize: 26
                                            width: containWidth
                                            height: paintedHeight
                                            visible: typeof model.modelData.sense!="undefined"
                                                     && typeof model.modelData.sense.word!="undefined"
                                                     && model.modelData.sense.word.length>0 && !settingManager.isNotShowCollinsChinese
                                            text: model.modelData.sense.word
                                        }
                                    }
                                }

                            }
                        }

                    }
                }

            }


            //全部按钮
            YButtonBase {
                width: 162
                height: 52
                visible: loadMoreVisible
                radius:height/2
                onVisibleChanged: {
                    if(visible) {
                        clicked()
                    }
                }

                Component.onCompleted: {
                    clicked()
                }

                YTextMedium {
                    id: id_button_tip
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: YTranslateText.loadmore
                }
                onClicked: {
                    loadMoreVisible  = false
                    lastCollinsPrimaryLoadMoreVisible = loadMoreVisible
                    dictSelectDetailsJson = getDictSelectDetailsJson(enPartofSpeechSelected,true)
                }
            }

            YSpacingForColumn{
                height: 24
                visible:  id_anagram_wfs_repeater.count > 0 && id_anagram_wfs_repeater.itemAt(0).visible && !loadMoreVisible
            }

            //            //虚线
            //            YVerticalDividingLine {
            //                id: id_div_word_change_line
            //                width: parent.width
            //                height: 2
            //                visible: id_anagram_wfs_repeater.count > 0 && id_anagram_wfs_repeater.itemAt(0).visible && !loadMoreVisible
            //            }

            //            YSpacingForColumn{
            //                height: 1
            //                visible:  id_anagram_wfs_repeater.count > 0 && id_anagram_wfs_repeater.itemAt(0).visible && !loadMoreVisible
            //            }

            //单词变形
            YTextBase {
                font.pixelSize: 26
                color: YColors.red
                anchors.left: parent.left
                anchors.right: parent.right
                width: 104
                height:  34
                //topPadding: 10
                text: YTranslateText.wordsInflection
                visible: id_anagram_wfs_repeater.count > 0 && id_anagram_wfs_repeater.itemAt(0).visible && !loadMoreVisible
                Component.onCompleted: {
                    dictNodeCompleted(text, dictType, 1, this);
                }
            }

            YSpacingForColumn{
                height: 10
                visible:  id_anagram_wfs_repeater.count > 0 && id_anagram_wfs_repeater.itemAt(0).visible && !loadMoreVisible
            }

            Column {
                anchors.left: parent.left
                anchors.right: parent.right
                spacing: 8
                visible: !loadMoreVisible
                Repeater {
                    id: id_anagram_wfs_repeater
                    model:  dictSelectDetailsJson.forms

                    YDictPageClickSearchTextItem{
                        containWidth: 156
                        word: model.modelData.form
                        isCHType: false
                        onClicked: {
                            collinsSelect.push(enPartofSpeechSelected)
                            id_dict_page.clickSearchWord(model.modelData.form)
                        }
                    }
                }
            }
        }
        YPopLayer {
            id: id_page_pop_helper
        }
    }
}



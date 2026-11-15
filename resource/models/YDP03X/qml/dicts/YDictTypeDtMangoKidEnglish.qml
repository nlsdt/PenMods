import QtQuick 2.12

import BaseQml 1.0
import "../i18n"
import "../components"
import com.youdao.pen 1.0

YDictTypeBase{
    title: (YTranslateText.dtEnChKid).replace("<br/>", " ")
    property var textContenWidth: 582



    Item{
        width: parent.width
        height: id_dict_content_column.height
        id:id_kid_item

        Column {
            id: id_dict_content_column
            //property var dictJson: JSON.parse(content)
//            onDictJsonChanged: {
//                  }
            width: parent.width
            spacing: 0

//            Flickable {
//                id: id_ch_pinyins_flick
//                anchors.left: parent.left
//                anchors.right: parent.right
//                height: 52
//                contentWidth: id_dict_ch_pinyin_list.width
//                flickableDirection: Flickable.HorizontalFlick
//                visible: id_dict_ch_pinyin_list_repeater.count > 1
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
//                height: 16
//                visible: id_ch_pinyins_flick.visible
//            }

//            YButtonBase {
//                id: id_icon_label_button_bg
//                width: 98
//                implicitHeight: 32
//                radius: height/2
//                //mouseAreaMargins: -5
//                visible: !id_dict_content_view.isShowEnDict(index)&&(resultManager.currentQueryType ==YEnum.WGT_En_Group ||resultManager.currentQueryType == YEnum.WGT_En)
//                color: "#27282C"
//                YImage {
//                    id: id_button_icon
//                    anchors.left: id_label.right
//                    anchors.leftMargin: 3
//                    anchors.verticalCenter: parent.verticalCenter
//                    cache: true
//                    sourceSize: Qt.size(9, 10)
//                    imageName: "dict/mango_practice_pronunciation"
//                }

//                YText {
//                    id: id_label
//                    anchors.left: parent.left
//                    anchors.leftMargin: 16
//                    anchors.verticalCenter: parent.verticalCenter
//                    font.pixelSize: 18
//                    width: paintedWidth
//                    height: paintedHeight
//                    color: YColors.yellow
//                    text: YTranslateText.practicePronuncChoice
//                }
//                onClicked: {
//                    console.log("mango_practice _pronunciation clicked")
//                    logManager.sendHttpLog("action=detail_pronunciation")
//                    soundCenter.stop();
//                    spellManager.content = resultManager.currentQuery;
//                    spellManager.richContent = resultManager.currentQuery;
//                    qmlGlobal.showSpellPage();
//                }
//            }

//            YSpacingForColumn{
//                visible: id_icon_label_button_bg.visible
//                height: 4
//            }

            Column {
                width: id_dict_content_column.width
                anchors.left: parent.left
                anchors.right: parent.right
                spacing: 10

                //height:

                function getMeanModel(){
                    if (typeof dictJson.pure.m != "undefined") {
                        return  dictJson.pure.m
                    }
                    if(typeof dictJson.pure.brief_meaning != "undefined")
                    {
                        return dictJson.pure.brief_meaning
                    }
                }
                Repeater {
                    id: id_trans_repeater
                    model:{
                        let modelData = null
                        if (typeof dictJson.pure!= "undefined" &&typeof dictJson.pure.m != "undefined") {
                            modelData = dictJson.pure.m
                        }
                        if(typeof dictJson.pure.brief_meaning != "undefined"){
                            modelData = dictJson.pure.brief_meaning
                        }
                        return modelData
                    }
                    Item {
                        id: id_trans_item
                        width: parent.width
                        height: id_pos_mean.height
                        readonly property var modelModelData: model.modelData
                        Column{
                            id:id_pos_mean
                            anchors.left: parent.left
                            anchors.right: parent.right
                            spacing: 10
                            Repeater{
                                model: {
                                    let modelData = null
                                    if (typeof modelModelData.pos != "undefined") {
                                        modelData= new Array
                                        modelData.push(modelModelData)
                                    }
                                    if (typeof modelModelData.meanings !="undefined")
                                        modelData = modelModelData.meanings
                                    return modelData
                                }
                                Column {
                                    id: id_trans_sense_column
                                    anchors.left: parent.left
                                    anchors.right: parent.right
                                    spacing: 10

                                    Row{
                                        height: id_trans_pos_txt.contentHeight
                                        YTextBase {
                                            id: id_trans_pos_txt
                                            font.pixelSize: 28
                                            color: YColors.grayText
                                            wrapMode: YTextBase.Wrap
                                            height: id_trans_pos_txt.contentHeight
                                            textFormat: YText.RichText
                                            // anchors.bottom: id_sense.bottom
                                            font.family: fontManager.fontFamilyZhCn
                                            text: {
                                                if (typeof modelModelData.m != "undefined") {
                                                    if(typeof modelModelData.pos != "undefined")
                                                    {
                                                        return  ('<span style="font-family:%1; font-style:italic;">').arg(fontManager.fontFamilyClass) + modelModelData.pos +'</span> ' + modelModelData.m}
                                                    else
                                                        return  ('<span style="font-family:%1; font-style:italic;">').arg(fontManager.fontFamilyClass) + modelModelData.pos + '</span> '
                                                }
                                                if (typeof id_trans_item.modelModelData.pos !="undefined")
                                                    return  ('<span style="font-family:%1; font-style:italic;">').arg(fontManager.fontFamilyClass)
                                                            + id_trans_item.modelModelData.pos + '</span> ' + model.modelData.meaning

                                            }
                                            width: textContenWidth
                                        }
                                    }

                                    Column{
                                        anchors.left: parent.left
                                        anchors.right: parent.right
                                        spacing: 4
                                        Repeater {
                                            id: id_trans_sents_repeater
                                            model: {
                                                if (typeof id_trans_item.modelModelData.meanings!= "undefined"&&typeof id_trans_item.modelModelData.meanings[index].sentences != "undefined")
                                                    return id_trans_item.modelModelData.meanings[index].sentences
                                            }

                                            Column {
                                                id: id_trans_sents_column
                                                //anchors.leftMargin: -25
                                                anchors.right: parent.right
                                                anchors.left: parent.left
                                                //anchors.rightMargin: 16
                                                //width: id_trans_sense_column.width
                                                spacing: 4
                                                readonly property var modelModelData: model.modelData

                                                YTextMedium {
                                                    id: id_sents_en
                                                    height: id_sents_en.contentHeight
                                                    //anchors.right: parent.right
                                                    //anchors.rightMargin: 16
                                                    anchors.left: parent.left
                                                    width: textContenWidth
                                                    font.family: fontManager.fontFamilyEnUs
                                                    text: {
                                                        if(typeof id_trans_sents_column.modelModelData.sentence != "undefined")
                                                   return "      "+id_trans_sents_column.modelModelData.sentence
                                                    }
                                                    font.pixelSize: 28
                                                    wrapMode: YTextEnUs.WordWrap
                                                    YAudioPlayButton {
                                                        width: 32
                                                        implicitHeight: 32
                                                        sourceSize: Qt.size(32, 32)
                                                        imageName: "dict/sound"
                                                        id: id_follow_content_pron
                                                        textFontFamily: fontManager.fontFamilyEnUs
                                                        textFormat: YText.PlainText
                                                        leftMargin: 0
                                                        anchors.left: parent.left
                                                        anchors.top:parent.top
                                                        anchors.topMargin: 2
                                                        //anchors.verticalCenter: parent.verticalCenter

                                                        color: YColors.black
                                                        //enabled: !id_sound_play.playing
                                                        text: ""
                                                        visible: id_sents_en.text.length
                                                        onValidClicked: {
                                                            let isUk,ukPhonetic = "", usPhonetic = "";
                                                            try {
                                                                console.log("##############",JSON.stringify(resultManager.phoneticSymbolJson));
                                                                var phoneticSymbolJson = JSON.parse(resultManager.phoneticSymbolJson);
                                                            } catch(e) { }
                                                            if (typeof phoneticSymbolJson != "undefined"){
                                                                ukPhonetic = typeof phoneticSymbolJson.uk == "undefined" ? "" : phoneticSymbolJson.uk;
                                                                usPhonetic = typeof phoneticSymbolJson.us == "undefined" ? "" : phoneticSymbolJson.us;
                                                            }
                                                            isUk = (settingManager.autoPronounceType === YEnum.UK) && ukPhonetic.length != 0
                                                            if (playing) {
                                                                logManager.sendHttpLog("action=detail_sentence_tts_click")
                                                                playWord(id_trans_sents_column.modelModelData.sentence, "en",
                                                                         id_trans_sents_column.modelModelData.sentence,
                                                                         isUk ? 1 : 2)
                                                            }
                                                        }
                                                    }
                                                }

                                                YTextBase {
                                                    id: id_sents_zh
                                                    font.pixelSize: 28
                                                    height: id_sents_zh.contentHeight
                                                    width: parent.width
                                                    color: YColors.grayText
                                                    font.family: fontManager.fontFamilyZhCn
                                                    textFormat: YTextBase.RichText
                                                    wrapMode: YTextBase.Wrap
                                                    text: {
                                                        if(typeof id_trans_sents_column.modelModelData.meaning != "undefined")
                                                            return id_trans_sents_column.modelModelData.meaning
                                                    }
                                                }
                                            }
                                        }

                                       YSpacingForColumn{
                                           visible: id_trans_sents_repeater.count>0
                                           height: 6
                                       }
                                    }
                                }
                            }
                        }
                    }
                }
            }

            YSpacingForColumn{
                visible: id_anagram_wfs_repeater.count > 0
                height: 20
            }
//            YVerticalDividingLine {
//                id: id_div_line
//                width: parent.width
//                height: 2
//                visible: id_anagram_wfs_repeater.count > 0
//            }
//            Item{
//                width: parent.width
//                height: 20
//                visible: id_anagram_wfs_repeater.count > 0
//            }
            //单词变形
            YTextBase {
                font.pixelSize: 26
                color: YColors.red
                anchors.left: parent.left
                anchors.right: parent.right
                width: textContenWidth
                height:  34
                //topPadding: 10
                text: YTranslateText.wordsInflection
                visible: id_anagram_wfs_repeater.count > 0

                Component.onCompleted: {
                    dictNodeCompleted(text, dictType, 1, this);
                }
            }

            YSpacingForColumn{
                visible: id_anagram_wfs_repeater.count > 0
                height: 10
            }
            Column {
                width: id_dict_content_column.width
                spacing: 10
                Repeater {
                    id: id_anagram_wfs_repeater
                    model:
                        //(typeof dictJson.anagram != "undefined" && typeof dictJson.anagram.wfs != "undefined") ? dictJson.anagram.wfs : null
                    {
                        let result = new Array
                        if(typeof dictJson.pure.tenses != "undefined" &&typeof dictJson.pure.tenses.third_person_singular != "undefined")
                            result.push({"key":YTranslateText.thirdPersonSingular,"value":dictJson.pure.tenses.third_person_singular.split("或")})
                        if(typeof dictJson.pure.tenses != "undefined" &&typeof dictJson.pure.tenses.present_participle != "undefined")
                            result.push({"key":YTranslateText.presentParticiple,"value":dictJson.pure.tenses.present_participle.split("或")})
                        if(typeof dictJson.pure.tenses != "undefined" &&typeof dictJson.pure.tenses.past != "undefined")
                            result.push({"key":YTranslateText.past,"value":dictJson.pure.tenses.past.split("或")})
                        if(typeof dictJson.pure.tenses != "undefined" &&typeof dictJson.pure.tenses.past_participle != "undefined")
                            result.push({"key":YTranslateText.pastParticiple,"value":dictJson.pure.tenses.past_participle.split("或")})
                        return result
                    }
                    Item {
                        id: id_anagram_wfs_item
                        width: parent.width
                        height:  id_words_inflection.height

                        readonly property var modelModelData: model.modelData
                        YTextBase {
                            id: id_wordsInflection_key
                            width: id_wordsInflection_key.contentWidth
                            height: id_wordsInflection_key.contentHeight
                            font.pixelSize: 28
                            font.family: fontManager.fontFamilyZhCn
                            color: YColors.grayText
                            text: model.modelData.key
                        }

                        Flow{
                            //height:
                            id:id_words_inflection
                            width: {
                                switch (model.modelData.key){
                                case YTranslateText.thirdPersonSingular:
                                    return 526
                                case YTranslateText.presentParticiple:
                                    return 582
                                case YTranslateText.past:
                                    return 610
                                case YTranslateText.pastParticiple:
                                    return 582
                                }
                            }
                            //height: id_wordsInflection_value.height
                            anchors.left: id_wordsInflection_key.right
                            anchors.leftMargin: 10
                            property var repeatModel: model.modelData.value
                            spacing:0
                            //readonly property var modelModelData: model.modelData
                            Repeater{
                                id:id_words_inflection_repeter
                                model: id_words_inflection.repeatModel
                                YDictPageClickSearchTextItem{
                                    word:model.modelData
                                    isCHType: false
                                    onClicked: {
                                        id_dict_page.clickSearchWord(model.modelData)
                                        //id_dict_page.requeryWord(model.modelData, "en", "zh-CHS")
                                    }
                                }
                            }
                        }

//                        YMouseArea{
//                            width: id_wordsInflection_value.width
//                            height: id_wordsInflection_value.height
//                            anchors.left: id_wordsInflection_key.right
//                            anchors.leftMargin: 10
//                            YTextBase {
//                                id: id_wordsInflection_value
//                                anchors.left: parent.left
//                                anchors.top: parent.top
//                                width: {
//                                     switch (model.modelData.key){
//                                     case YTranslateText.thirdPersonSingular:
//                                         return 526
//                                     case YTranslateText.presentParticiple:
//                                         return 582
//                                     case YTranslateText.past:
//                                         return 610
//                                     case YTranslateText.pastParticiple:
//                                         return 582
//                                     }
//                                }
//                                height: contentHeight
//                                font.pixelSize: 28
//                                font.family: fontManager.fontFamily
//                                color: YColors.blueText
//                                wrapMode: Text.Wrap
//                                font.bold: true
//                                text: model.modelData.value
//                            }
//                            onClicked: {
//                                id_dict_page.clickSearchWord(model.modelData.value)
//                                    //id_dict_page.requeryWord(model.modelData, "en", "zh-CHS")
//                            }
//                        }


                    }
                }
            }


            YSpacingForColumn{
                visible: id_fix_text.visible
                height: 20
            }
//            YVerticalDividingLine {
//                //id: id_div_line
//                width: parent.width
//                height: 2
//                visible:  id_fixed_collocation_repeater.count > 0
//            }
//            Item{
//                width: parent.width
//                height: 20
//                visible:  id_fixed_collocation_repeater.count > 0
//            }
            //固定搭配
            YTextBase {
                id:id_fix_text
                font.pixelSize: 26
                color: YColors.red
                anchors.left: parent.left
                anchors.right: parent.right
                width: textContenWidth
                height:  34
                //topPadding: 10
                text: YTranslateText.fixedCollocation
                visible: id_fixed_collocation_repeater.count > 0 &&(
                             typeof  dictJson.pure.phrases!= "undefined"
                             && dictJson.pure.phrases.length > 0
                             && typeof dictJson.pure.phrases[0].phrase!= "undefined"
                             && dictJson.pure.phrases[0].phrase.length > 0)
                Component.onCompleted: {
                    dictNodeCompleted(text, dictType, 1, this);
                }
            }
            YSpacingForColumn{
                visible: id_fix_text.visible
                height: 10
            }
            Column {
                id:id_fixed_collocation_column
                width: id_dict_content_column.width
                spacing: 10
                visible: id_fix_text.visible
                property bool fixedLoadmoreVisible: false
                Repeater {
                    id: id_fixed_collocation_repeater
                    model: //dictJson.phrases
                    {
                        let fixedCollocationResult = new Array
                        let i =0
                        if(typeof  dictJson.pure.phrases!= "undefined")
                        {
                            dictJson.pure.phrases.some(item=>{
                              i++
                              fixedCollocationResult.push(item)
                              if(i>=3 && i<dictJson.pure.phrases.length)
                               {
                                   id_fixed_collocation_column.fixedLoadmoreVisible =true
                                   return true;
                               }
                              else
                                return false
                            })
                        }
                        return fixedCollocationResult
                    }
                    Item {
                        id: id_fixed_Collocation_item
                        width: parent.width
                        height: id_fixed_collocation_key.contentHeight+id_fixed_collocation_value.contentHeight

                        readonly property var modelModelData: model.modelData
                        YTextBase {
                            id: id_fixed_collocation_key
                            width: textContenWidth
                            height: contentHeight
                            font.pixelSize: 28
                            font.family: fontManager.fontFamilyEnUs
                            color: YColors.white
                            font.bold: true
                            wrapMode: Text.WordWrap
                            text: model.modelData.phrase
                        }
                        YTextBase {
                            id: id_fixed_collocation_value
                            width: textContenWidth
                            height: contentHeight
                            font.pixelSize: 26
                            anchors.top: id_fixed_collocation_key.bottom
                            anchors.topMargin: 4
                            font.family: fontManager.fontFamilyZhCn
                            color: YColors.grayText
                            wrapMode: Text.WordWrap
                            text: model.modelData.meanings[0]
                        }
                    }
                }
            }

            YSpacingForColumn{
                visible: id_fixed_collocation_repeater.count>0
                         && id_fix_text.visible
                         && id_fixed_collocation_column.fixedLoadmoreVisible
                height: 10
            }
            //全部按钮
            YButtonBase {
                width: 162
                height: 52
                visible: id_fixed_collocation_repeater.count>0
                         && id_fix_text.visible
                         && id_fixed_collocation_column.fixedLoadmoreVisible
                radius:height/2
                YTextMedium {
                    id: id_button_tip
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: YTranslateText.loadmore
                }
                onClicked: {
                    logManager.sendHttpLog("action=detail_more_click&dict=kid-ec&card_name=collocation")
                    id_dict_page.backContentYPos =  id_container_flickable.contentY
                    qmlGlobal.showDictDetailPage(dictType, JSON.stringify(dictJson.pure.phrases), YTranslateText.fixedCollocation)
                }
            }

            YSpacingForColumn{
                visible: id_synonymsAndSynonyms_repeater.count > 0 && id_fix_text.visible
                height: 20
            }
//            YVerticalDividingLine {
//                //id: id_div_line
//                width: parent.width
//                height: 2
//                visible:  id_synonymsAndSynonyms_repeater.count > 0 && id_fix_text.visible
//            }
//            Item{
//                width: parent.width
//                height: 20
//                visible:  id_synonymsAndSynonyms_repeater.count > 0 && id_fix_text.visible
//            }

            //同近义词
            YTextBase {
                font.pixelSize: 26
                color: YColors.red
                anchors.left: parent.left
                anchors.right: parent.right
                width: textContenWidth
                height:  34
                //topPadding: 10
                text: YTranslateText.synonymsAndSynonyms
                visible: id_synonymsAndSynonyms_repeater.count > 0
                Component.onCompleted: {
                    dictNodeCompleted(text, dictType, 1, this);
                }
            }

            YSpacingForColumn{
                visible: id_synonymsAndSynonyms_repeater.count > 0
                height: 10
            }

            Column {
                id:id_synonymsAndSynonyms
                width: id_dict_content_column.width
                property bool synonymsMoreVisible: false
                spacing: 10
                function showPage(qrcqml, cachePage, properties) {
                    if ((typeof cachePage !== undefined) && cachePage) {
                        return id_page_pop_helper.cacheShow(qrcqml, false, properties)
                    }
                    return id_page_pop_helper.show(qrcqml, false, false, properties)
                }
                Repeater {
                    id: id_synonymsAndSynonyms_repeater
                    model: {
                        let resultArray = new Array
                        let i =0;
                        dictJson.pure.synonyms.some(item=>{
                         i++
                         resultArray.push(item)
                         if(i>=3 && i<dictJson.pure.synonyms.length)
                         {
                            id_synonymsAndSynonyms.synonymsMoreVisible =true
                            return true;
                         }
                         else
                            return false;
                        } )
                        return resultArray

                        //dictJson.pure.synonyms
                    }
                    Item {
                        id: id_synonymsAndSynonyms_item
                        width: parent.width
                        height: id_synonymsAndSynonyms_pos_txt.contentHeight+id_synonyms_flow.height

                        readonly property var modelModelData: model.modelData
                        YTextBase {
                            id: id_synonymsAndSynonyms_pos_txt
                            font.pixelSize: 28
                            //font.styleName: "italic"
                            font.family: fontManager.fontFamilyZhCn
                            color: YColors.grayText
                            text: ('<span style="font-family:%1; font-style:italic;">').arg(fontManager.fontFamilyClass)
                                  + id_synonymsAndSynonyms_item.modelModelData.pos + '</span>' + model.modelData.meaning
                            width: textContenWidth
                            wrapMode: YTextBase.Wrap
                            textFormat: YText.RichText
                            height: id_synonymsAndSynonyms_pos_txt.contentHeight
                            // anchors.bottom: id_sense.bottom
                        }

                        Flow{
                            //height:
                            id:id_synonyms_flow
                            width: textContenWidth
                            anchors.top: id_synonymsAndSynonyms_pos_txt.bottom
                            spacing:0
                            //readonly property var modelModelData: model.modelData
                            Repeater{
                                id:id_synonyms_repeter
                                model:{
                                    let resultArray = new Array
                                    let i =0;
                                    id_synonymsAndSynonyms_item.modelModelData.synonyms.some(item=>{
                                     i++
                                     resultArray.push(item)
                                     if(i>=3 && i<id_synonymsAndSynonyms_item.modelModelData.synonyms.length)
                                     {
                                        id_synonymsAndSynonyms.synonymsMoreVisible =true
                                        return true;
                                     }
                                     else
                                        return false;
                                    } )
                                    return resultArray
                                }
                                YDictPageClickSearchTextItem{
                                    word:model.modelData
                                    isCHType: false
                                    onClicked: {
                                        id_dict_page.clickSearchWord(model.modelData)
                                        //id_dict_page.requeryWord(model.modelData, "en", "zh-CHS")
                                    }
                                }
                            }
                        }

                    }
                }
            }

            YSpacingForColumn{
                visible:  id_synonymsAndSynonyms_repeater.count>0 && id_synonymsAndSynonyms.synonymsMoreVisible
                height: 10
            }
            //全部按钮
            YButtonBase {
                width: 162
                height: 52
                visible: id_synonymsAndSynonyms_repeater.count>0 && id_synonymsAndSynonyms.synonymsMoreVisible
                radius:height/2
                YTextMedium {
                    id: id_all_button
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: YTranslateText.loadmore
                }
                onClicked: {
                    logManager.sendHttpLog("action=detail_more_click&dict=kid-ec&card_name=synonym")
                    id_dict_page.backContentYPos =  id_container_flickable.contentY
                    qmlGlobal.showDictDetailPage(dictType, JSON.stringify(dictJson.pure.synonyms), YTranslateText.synonymsAndSynonyms)
                }
            }

            //            YSpacingForColumn{
            //                implicitHeight: 10
            //            }
        }
        YPopLayer {
            id: id_page_pop_helper
        }
    }
}



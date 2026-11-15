import QtQuick 2.12
import com.youdao.pen 1.0

import BaseQml 1.0
import "../components"
import "../i18n"

Item {
    id: id_dict_type_base_item
    width: 612
    height: !visible ? 0 : (id_dict_type_base.height > (id_buttons_column.height + 24) ? id_dict_type_base.height : (id_buttons_column.height + 24))
    readonly property int dictType: model.modelData.dictType
    readonly property string rawContent: model.modelData.content
    readonly property string content: YEnum.AsyncLocalTran === dictType || YEnum.NetTran === dictType   ? rawContent : JSON.stringify(dictJson)
    property var keysList: []
    property var chPinyinList: []
    function getDefalutKey() {
        for(let i=0; i<keysList.length; i++) {
            if(keysList[i].split('\t')[1].trim() === "0") {
                return keysList[i]
            }
        }
        return keysList.length ? keysList[0] : ""
    }

    property var chCurrentEnSelected: keysList.length ? getDefalutKey() : ""


    property var dictJson: (YEnum.AsyncLocalTran === dictType || YEnum.NetTran === dictType) ? null :
                            resetDictJson(model.modelData.content, keysList)


    readonly property bool isFirstDict: index <= 0 || (id_dict_content_view_repeater.count && index === 1 && !id_dict_content_view_repeater.itemAt(0).active &&
                              id_dict_content_view_repeater.itemAt(0).dictType === YEnum.DtPinYin)
    default property alias sourceComponent: id_content_loader.sourceComponent
    property alias title: id_dictionary_title.text
    property var detail_button_visible: false
    onDetail_button_visibleChanged: {
        if (isFirstDict) {
            id_dict_page.top_detail_button_visible = detail_button_visible
        }
    }

    onVisibleChanged: {
        if (isFirstDict) {
            id_dict_page.top_detail_button_visible = detail_button_visible
        }
    }

    Connections {
        target: resultManager
        ignoreUnknownSignals: true
        function onCurrentQueryChanged() {
            dictJson = Qt.binding(function(item) {
                 return (YEnum.AsyncLocalTran === dictType || YEnum.NetTran === dictType) ? null : resetDictJson(model.modelData.content,keysList)
            })
        }

//                        chPinYinList =[]
//                        firstDictJson = ({})
//                        chPinyinSelected = Qt.binding(function(){ return chPinYinList.length ? chPinYinList[0] : ""})
        }

    onDictTypeChanged: {
        let bVisible = false
        switch (dictType) {
        case YEnum.DtChLarge:
        case YEnum.DtChAncientWord:
        //case YEnum.DtChPoemDict:
        case YEnum.DtSenior:
        case YEnum.DtWebster:
        case YEnum.DtOxford:
        case YEnum.DtKoCh:
        case YEnum.DtChKo:
            bVisible = true
            break
        default:
            break
        }
         detail_button_visible = bVisible
    }

    onDictJsonChanged: {
        if(isFirstDict) {
            firstDictType =  dictType
        }
    }
    //导航词典标题
    property alias titleOfsetY: id_dictionary_title.y
    property alias title_id: id_dictionary_title
    /*
      *title 节点名称
      *type 词典种类
      * subType 词典子类型
      * 节点示例(QML UI 实例)
    */
    signal dictNodeCompleted(var title, var type, var subType, var dictNode)

    /**
      * ai 句子分析入口
    */
    signal aiSentenceClick()
    Column {
        id: id_dict_type_base
        width: parent.width
        spacing: 0

        YTextBase {
            id: id_dictionary_title
            font.pixelSize: 26
            color: YColors.red
            height: id_dictionary_title.contentHeight
            visible: {
                if (isFirstDict) {
                    return false
                }
                else
                {
                    return (id_dictionary_title.text.length > 0)
                }
            }
            Component.onCompleted: {
                console.log("seven:-----1")
//                resultManager.sendDictitem(text,dictType)
                dictNodeCompleted(text, dictType, 0, this);
                console.log("seven:-----2")
            }
        }

        YSpacingForColumn {
            visible: id_dictionary_title.visible
            implicitHeight: 12
        }

        YLoader {
            id: id_audio_ch_play_buttons_loader
            active: {
                //如果中文页面内拼音不显示，就显示此按钮
                let isVisible = false
                if(dictType == YEnum.DtBusinessAnCh ||
//                   dictType == YEnum.DtBusIdiomCh ||
                   dictType == YEnum.DtOnline ||
                   dictType == YEnum.DtChToJap ||
                   dictType == YEnum.DtJapToCh ){
                    console.log("chenfei:YLoader:",false)
                    return false
                }
                if (isFirstDict && !id_audio_play_buttons_loader.active &&  systemBase.isButtonRelease) {
                    if (!id_stroke_info_item.visibleProperty) {
                        if (dictType === YEnum.DtChLarge || dictType === YEnum.DtChAncientWord ||
                                                                 YEnum.DtPinYin === dictType || YEnum.DtXinHua === dictType || dictType === YEnum.DtChChinese) {
                        try{
                             console.warn("typeof id_content_loader.item.dictType:"+dictType)
                            if(YEnum.DtPinYin === dictType) {
                                isVisible = !chPinyinList.length
                            } else {
                                isVisible = true
                            }
                        } catch(e) {
                            console.warn("typeof id_content_loader.item.dictType,error:"+e)
                        }
                    } else {
                            isVisible = true
                        }
                    }
                    //如果是单字，笔顺头拼音显示了，也不显示此发音按钮,否则显示
                    if(id_stroke_info_item.visibleProperty && !chPinYinList.length) {
                        isVisible = true
                    }
                }
                return isVisible
//                return  isFirstDict && !id_audio_play_buttons_loader.active  &&
//                        (((dictType !== YEnum.DtChLarge && dictType !== YEnum.DtChAncientWord &&
//                          YEnum.DtPinYin !== dictType && YEnum.DtXinHua !== dictType) && (dictType !== YEnum.DtChChinese || resultManager.currentQueryType === YEnum.WGT_Ch_Group) &&
//                         !id_stroke_info_item.visibleProperty) || (id_stroke_info_item.visibleProperty && !chPinYinList.length))
            }
            visible: active
            width: parent.width
            sourceComponent: {
                console.log("seven:YDictTypeBase:sourceComponent",dictType, resultManager.currentQueryType)
                switch (dictType) {
                    case YEnum.AsyncLocalTran:
                    case YEnum.NetTran:
                        return id_sentence_buttons
                }
                switch (resultManager.currentQueryType) {
                case YEnum.WGT_Ch_Group:
                case YEnum.WGT_Ch:
                case YEnum.WGT_Ko_Group:
                case YEnum.WGT_Ko:
                    return id_cn_zh_word_button
                case YEnum.WGT_Sentence:
                case YEnum.WGT_Ja:
                    return id_sentence_buttons
                case YEnum.WGT_En_Group:
                case YEnum.WGT_En:
                default:
                    return id_pronounce_buttons
                }
            }
            onLoaded: {
                //getDictContentValue(dictType,content,index)
                if (settingManager.isAutoPronounce && id_dict_page.visible && !resultManager.isReturnSearch) {
                    audioAutoPlay()
                }
            }
            function audioAutoPlay() {
                if (settingManager.isPepVersion) {
                    if (soundCenter.hasPepSound(resultManager.currentQuery)) {
                        item.autoPlay()
                        qmlGlobal.soundWGTPep(resultManager.currentQuery)
                    }
                    return
                }
                item.autoPlay()
                switch (resultManager.currentQueryType) {
                case YEnum.WGT_Sentence:
                    console.trace();
                    console.log("YEnum.WGT_Sentence" + qmlGlobal.audioAutoPlayId);
                    if (qmlGlobal.audioAutoPlayId > 0)
                        break
                case YEnum.WGT_Ja:
                    qmlGlobal.soundSentence()
                    break
                case YEnum.WGT_Ch_Group:
                case YEnum.WGT_Ch:
                    qmlGlobal.soundWGTCh()
                    break
                case YEnum.WGT_Ko_Group:
                case YEnum.WGT_Ko:
                    qmlGlobal.soundWGTKo()
                    break
                case YEnum.WGT_En_Group:
                case YEnum.WGT_En:
                    qmlGlobal.soundWGTEn(resultManager.currentQuery)
                    break
                default:
                    break
                }
            }

            Connections {
                target: qmlGlobal
                ignoreUnknownSignals: true
                enabled: id_audio_ch_play_buttons_loader.isLoaded
                function onShowDictPage(pageIndex, ocrContent) {
                    if (YEnum.PageIndex.Dict === pageIndex && settingManager.isAutoPronounce) {
                        // todo check fav history need or not
                        id_audio_ch_play_buttons_loader.audioAutoPlay()
                    }
                }
            }
        }

        YSpacingForColumn {
            visible: id_audio_ch_play_buttons_loader.visible
            implicitHeight: 24
        }

        Flickable {
            id: id_ch_pinyins_flick
            anchors.left: parent.left
            anchors.right: parent.right
            height: visible ? 52 : 0
            contentWidth: id_dict_ch_pinyin_list.width
            flickableDirection: Flickable.HorizontalFlick
            visible: id_dict_ch_pinyin_list_repeater.count > 1
            clip: true

            Connections {
                target: resultManager
                ignoreUnknownSignals: true
                function onCurrentQueryChanged() {
//                        chPinYinList =[]
//                        firstDictJson = ({})
//                        chPinyinSelected = Qt.binding(function(){ return chPinYinList.length ? chPinYinList[0] : ""})
                }
            }

            Row {
                id: id_dict_ch_pinyin_list
                height: 52
                spacing: 10
                anchors.bottom: parent.bottom
                visible: (keysList.length && Object.keys(dictJson).length) || id_dict_content_view_repeater_empty_tip.visible

                Repeater {
                    id: id_dict_ch_pinyin_list_repeater
                    model: {
                         return keysList
                    }

                    YAudioPlayIconLabelHCenterButton {
                        height: 52
                        color: YColors.grayNormal
                        textItem.font.pixelSize: 26
                        textItem.font.family: fontManager.fontFamilyEnUs
                        text: model.modelData.split('\t')[0]
                        textItem.color: isCurrentSelectedPinyin ? YColors.red : YColors.white
                        iconItem.visible: false
                        width: (iconItem.visible ? iconItem.width : 0) + textItem.width + 20 * 2
                        property var currentModelData: model.modelData
                        property int selectI: chCurrentEnSelected.split('\t').length ? parseInt(chCurrentEnSelected.split('\t')[1]) : 0

                        Component.onCompleted: {
                            chCurrentEnSelected =  keysList.length ? getDefalutKey() : ""
                        }

                        readonly property bool isCurrentSelectedPinyin : {
                           return  chCurrentEnSelected === currentModelData
                        }

                        onValidClicked: {
                            logManager.sendHttpLog("action=detail_chinese_audio")
                            chCurrentEnSelected = currentModelData
                            let keysListTmp
                            dictJson = resetDictJson(rawContent,keysListTmp,selectI)
                            getDictContentValue(dictType,content,index)
                            }
                        }
                    }
                }
            }

        YSpacingForColumn{
            height: 8
            visible: id_ch_pinyins_flick.visible
        }

        YLoader {
            id: id_content_loader
            active: true
            width: parent.width
            height: item.height
            asynchronous: false
        }

        YSpacingForColumn {
            height: 12
            visible: id_word_source_key.visible
        }

        YTextBase {
            id: id_word_source_key
            visible: dictJson!== null && (typeof  dictJson.source !== "undefined" &&
                     (dictJson.source.length && dictJson.source === "现代汉语规范词典")) || (dictType === YEnum.DtXinHua)
//                anchors.left:parent.left
//                anchors.right: parent.right
            width: contentWidth
            anchors.horizontalCenter: parent.horizontalCenter
            //anchors.verticalCenter: parent.verticalCenter
            font.pixelSize: 26
            color: YColors.grayText
            //wrapMode: YText.WordWrap
            text: dictType === YEnum.DtXinHua ? YTranslateText.xinhuaNoticeText : YTranslateText.chWordSource.arg(dictJson !== null ? dictJson.source : "")
        }

        YSpacingForColumn {
            visible: id_audio_play_buttons_loader.active
            implicitHeight: 16
        }


        YLoader {
            id: id_audio_play_buttons_loader
            active:{
                if(dictType == YEnum.DtBusinessAnCh ||
                   dictType == YEnum.DtBusIdiomCh ||
                   dictType == YEnum.DtOnline ||
                   dictType == YEnum.DtChToJap ||
                   dictType == YEnum.DtJapToCh ){
                    console.log("chenfei:YLoader:",false)
                    return false
                }
                return isFirstDict && (dictType !== YEnum.DtChChinese && dictType !== YEnum.DtChLarge &&
                                dictType !== YEnum.DtChAncientWord && dictType != YEnum.DtChIdiom &&
                                dictType !== YEnum.DtChPoemDict && YEnum.DtPinYin !== dictType && YEnum.DtXinHua !== dictType /*&&
                                YEnum.DtChEnglish !== dictType*/)
            }

            visible: active && !isPhoneticSymbolShow
            width: parent.width
            sourceComponent: {
                console.log("seven:resultManager.currentQueryType", resultManager.currentQueryType)
                switch (dictType) {
                    case YEnum.AsyncLocalTran:
                    case YEnum.NetTran:
                        return id_sentence_buttons
                }
                switch (resultManager.currentQueryType) {
                case YEnum.WGT_Ch_Group:
                case YEnum.WGT_Ch:
                case YEnum.WGT_Ko_Group:
                case YEnum.WGT_Ko:
                    return id_cn_zh_word_button
                case YEnum.WGT_Sentence:
                    if(dictType === YEnum.DtKoCh){
                        return id_pronounce_buttons
                    }
                    return id_sentence_buttons
                case YEnum.WGT_Ja:
                    return id_sentence_buttons
                case YEnum.WGT_En_Group:
                case YEnum.WGT_En:
                default:
                    return id_pronounce_buttons
                }
            }
            onLoaded: {
                //getDictContentValue(dictType,content,index)
                if (settingManager.isAutoPronounce && id_dict_page.visible && !resultManager.isReturnSearch ) {
                    audioAutoPlay()
                }
            }
            function audioAutoPlay() {
                if (settingManager.isPepVersion) {
                    if (soundCenter.hasPepSound(resultManager.currentQuery)) {
                        item.autoPlay()
                        qmlGlobal.soundWGTPep(resultManager.currentQuery)
                    }
                    return
                }
                item.autoPlay()
                switch (dictType) {
                    case YEnum.AsyncLocalTran:
                    case YEnum.NetTran:
                        if (qmlGlobal.audioAutoPlayId > 0)
                            return
                }

                switch (resultManager.currentQueryType) {
                case YEnum.WGT_Sentence:
                    console.trace();
                    console.log("YEnum.WGT_Sentence" + qmlGlobal.audioAutoPlayId);
                    if (qmlGlobal.audioAutoPlayId > 0)
                        break
                case YEnum.WGT_Ja:
                    qmlGlobal.soundSentence()
                    break
                case YEnum.WGT_Ch_Group:
                case YEnum.WGT_Ch:
                    qmlGlobal.soundWGTCh()
                    break
                case YEnum.WGT_Ko_Group:
                case YEnum.WGT_Ko:
                    qmlGlobal.soundWGTKo()
                    break
                case YEnum.WGT_En_Group:
                case YEnum.WGT_En:
                    qmlGlobal.soundWGTEn(resultManager.currentQuery)
                    break
                default:
                    break
                }

            }

            Connections {
                target: qmlGlobal
                ignoreUnknownSignals: true
                enabled: id_audio_play_buttons_loader.isLoaded
                function onShowDictPage(pageIndex, ocrContent) {
                    if (YEnum.PageIndex.Dict === pageIndex && settingManager.isAutoPronounce) {
                        // todo check fav history need or not
                        id_audio_play_buttons_loader.audioAutoPlay()
                    }
                }
            }
        }

        Column {
            id: id_associated_word_column
            width: parent.width
            spacing: 16
            readonly property var associatedWordDictJson: resultManager.associatedTrans.length > 0
                                                       ? JSON.parse(resultManager.associatedTrans) : null

            YSpacingForColumn {
                visible: id_associated_word_row.visible
                implicitHeight: 1
            }

            Row {
                id: id_associated_word_row
                spacing: 6
                visible: {
                    console.log("YDictTypeBase.qml === resultManager.associatedWord: ", resultManager.associatedWord)
                    return isFirstDict && resultManager.associatedWord.length > 0
                }
                anchors.left: parent.left
                anchors.right: parent.right
                height: 36

                YText {
                    id: id_associated_word_label
                    color: YColors.grayText
                    font.pixelSize: 26
                    width: contentWidth
                    height: contentHeight
                    anchors.bottom: parent.bottom
                    text: YTranslateText.relatedWords + ": "
                }

                YTextMedium {
                    id: id_associated_word_content
                    color: YColors.blueText
                    wrapMode: YText.Wrap
                    font.pixelSize: 30
                    font.family: fontManager.fontFamilyEnUs
                    width: parent.width - parent.spacing - id_associated_word_label.width
                    height: contentHeight
                    text: resultManager.associatedWord

                    YMouseArea {
                        width: parent.width
                        height: parent.height + 40
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.verticalCenter: parent.verticalCenter
                        onClicked: {
                            console.log("YDictTypeBase.qml====id_related_word_clicked associatedWord:", resultManager.associatedWord)
                            id_dict_page.clickSearchWord(resultManager.associatedWord)
                            //id_dict_page.requeryWord(resultManager.associatedWord, "en", "zh-CHS")
                        }
                        objectName: "YDictTypeBase.qml_id_related_word_trans"
                    }
                }
            }

            YTextBase {
                id: id_associated_word_dictJson
                font.pixelSize: 28
                wrapMode: YText.Wrap
                textFormat: YTextBase.RichText
                width: parent.width
                height: paintedHeight
                lineHeightMode: Text.FixedHeight
                lineHeight: 44
                text: {
                    if (id_associated_word_column.associatedWordDictJson === null) {
                        return ""
                    }
                    let sResult = ''
                    if (typeof id_associated_word_column.associatedWordDictJson.pure.m != "undefined") {
                        let mArray = id_associated_word_column.associatedWordDictJson.pure.m
                        mArray.forEach(function(mean){
                            if (typeof mean.pos !== "undefined") {
                                sResult += ('<span style="font-family: %1; font-style: italic; color: %2; font-size: 24px">').arg(fontManager.fontFamilyClass).arg(YColors.grayText)
                                        + mean.pos + '</span>' + '<span>&nbsp;</span>'
                            }

                            sResult += '<span style="font-family: OPPOSans; font-weight: 500; '
                                    + ('color: %1; font-size: 28px">').arg(YColors.white) + mean.m + '</span>'
                                    + '<span>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span>'
                        })
                        if (typeof id_associated_word_column.associatedWordDictJson.pure.phonics != "undefined")
                             setPhonic(id_associated_word_column.associatedWordDictJson)
                            //spellManager.phonics  = JSON.stringify(id_associated_word_column.associatedWordDictJson.pure.phonics);
                        else
                            spellManager.phonics = "";
                        return sResult
                    }
                    else if (typeof id_associated_word_column.associatedWordDictJson.pure.word != "undefined") {
                        let mArray = id_associated_word_column.associatedWordDictJson.pure.word.trs
                        mArray.forEach(function(mean){
                            if (typeof mean.pos !== "undefined") {
                                sResult += ('<span style="font-family: %1; font-style: italic; color: %2; font-size: 24px">').arg(fontManager.fontFamilyClass).arg(YColors.grayText)
                                        + mean.pos + '</span>' + '<span>&nbsp;</span>'
                            }

                            sResult += '<span style="font-family: OPPOSans; font-weight: 500; '
                                    + ('color: %1; font-size: 28px">').arg(YColors.white) + mean.tran + '</span>'
                                    + '<span>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span>'
                        })

                        spellManager.phonics = "";
                        return sResult
                    }
                }
                visible: text.length > 0
            }

            Grid {
                id: id_associated_word_pronounce_buttons_grid
                columnSpacing: 12
                rowSpacing: 10
                columns: (id_associated_word_sound_us.width + columnSpacing + id_associated_word_sound_uk.width) > parent.width ? 1 : 2
                readonly property var phoneticSymbolJson: (id_associated_word_column.associatedWordDictJson !== null
                                                           && typeof id_associated_word_column.associatedWordDictJson.pure.word != "undefined")
                                                          ? id_associated_word_column.associatedWordDictJson.pure.word : null

                function play(isUS) {
                    if (isUS) {
                        if (id_associated_word_sound_uk.playing) {
                            id_associated_word_sound_uk.stop()
                        }
                        id_associated_word_sound_us.play()
                    } else {
                        if (id_associated_word_sound_us.playing) {
                            id_associated_word_sound_us.stop()
                        }
                        id_associated_word_sound_uk.play()
                    }
                }

                YAudioPlayIconLabelButton {
                    id: id_associated_word_sound_us
                    visible: soundCenter.hasUsSound(resultManager.associatedWord)
                             && id_associated_word_pronounce_buttons_grid.phoneticSymbolJson !== null
                             && (typeof id_associated_word_pronounce_buttons_grid.phoneticSymbolJson.usphone != "undefined")
                    textFormat: YText.RichText
                    text: {
                        let qsRst = ""
                        if (!id_associated_word_sound_uk.visible) {
                            qsRst = ('<span style="font-family: %1; font-weight: 500">%2</span>')
                            .arg(fontManager.fontFamily).arg(YTranslateText.pronunciation)
                        } else if (id_associated_word_pronounce_buttons_grid.phoneticSymbolJson.usphone.length > 0) {
                            qsRst = ('<span style="font-family: %1; font-weight: 500">%2</span>&nbsp;<span style="font-family: %3">&frasl;&nbsp;%4&nbsp;&frasl;</span>')
                            .arg(fontManager.fontFamily).arg(YTranslateText.shorthandUS).arg(fontManager.fontFamilyEnSymbol).arg(id_associated_word_pronounce_buttons_grid.phoneticSymbolJson.usphone)
                        } else {
                            qsRst = ('<span style="font-family: %1; font-weight: 500">%2</span>')
                            .arg(fontManager.fontFamily).arg(YTranslateText.shorthandUS)
                        }
                        return qsRst
                    }
                    onValidClicked: {
                        if (playing) {
                            id_associated_word_pronounce_buttons_grid.play(true)
                            if (!id_associated_word_sound_uk.visible) {
                                qmlGlobal.soundWGTEn(resultManager.associatedWord)
                            } else {
                                qmlGlobal.soundWGTEn(resultManager.associatedWord, YEnum.US)
                            }
                            logManager.sendHttpLog("action=detail_american_accent_click")
                        }
                    }
                }

                YAudioPlayIconLabelButton {
                    id: id_associated_word_sound_uk
                    visible: soundCenter.hasUkSound(resultManager.associatedWord)
                             && id_associated_word_pronounce_buttons_grid.phoneticSymbolJson !== null
                             && (typeof id_associated_word_pronounce_buttons_grid.phoneticSymbolJson.ukphone != "undefined")
                    textFormat: YText.RichText
                    text: {
                        let qsRst = ""
                        if (!id_associated_word_sound_us.visible) {
                            qsRst = ('<span style="font-family: %1; font-weight: 500">%2</span>')
                            .arg(fontManager.fontFamily).arg(YTranslateText.pronunciation)
                        } else if (id_associated_word_pronounce_buttons_grid.phoneticSymbolJson.ukphone.length > 0) {
                            qsRst = ('<span style="font-family: %1; font-weight: 500">%2</span>&nbsp;<span style="font-family: %3">&frasl;&nbsp;%4&nbsp;&frasl;</span>')
                            .arg(fontManager.fontFamily).arg(YTranslateText.shorthandEN).arg(fontManager.fontFamilyEnSymbol).arg(id_associated_word_pronounce_buttons_grid.phoneticSymbolJson.ukphone)
                        } else {
                            qsRst = ('<span style="font-family: %1; font-weight: 500">%2</span>')
                            .arg(fontManager.fontFamily).arg(YTranslateText.shorthandEN)
                        }
                        return qsRst
                    }
                    onValidClicked: {
                        if (playing) {
                            id_associated_word_pronounce_buttons_grid.play(false)
                            if (!id_associated_word_sound_us.visible) {
                                qmlGlobal.soundWGTEn(resultManager.associatedWord)
                            } else {
                                qmlGlobal.soundWGTEn(resultManager.associatedWord, YEnum.UK)
                            }
                            logManager.sendHttpLog("action=detail_british_accent_click")
                        }
                    }
                }
            }

        }

        YSpacingForColumn {
            implicitHeight: 24
        }

        Component {
            id: id_pronounce_buttons

            Grid {
                id: id_pronounce_buttons_grid
                columnSpacing: 12
                rowSpacing: 10
                columns: (id_sound_us.width + columnSpacing + id_sound_uk.width) > id_content_loader.width ? 1 : 2
                readonly property var phoneticSymbolJson: {
                    let jsonObjTmp = null
                    try {
                        jsonObjTmp = JSON.parse(resultManager.phoneticSymbolJson)
                    } catch(e) { }
                    return jsonObjTmp
                }

                function autoPlay() {
                    if (id_sound_default.visible) {
                        id_sound_default.play()
                    } else {
                        play(YEnum.US === settingManager.autoPronounceType)
                    }
                }

                function play(isUS) {
                    if (isUS) {
                        if (id_sound_uk.playing) {
                            id_sound_uk.stop()
                        }
                        id_sound_us.play()
                    } else {
                        if (id_sound_us.playing) {
                            id_sound_us.stop()
                        }
                        id_sound_uk.play()
                    }
                }

                YAudioPlayIconLabelButton {
                    id: id_sound_us
                    visible: soundCenter.hasUsSound(resultManager.currentQuery)
                             && id_pronounce_buttons_grid.phoneticSymbolJson !== null
                             && (typeof id_pronounce_buttons_grid.phoneticSymbolJson.us != "undefined")
                    textFormat: YText.RichText
                    text: {
                        if (!visible) {
                            return ""
                        }
                        if (!id_sound_uk.visible) {
                            return ('<span style="font-family: %1; font-weight: 500">%2</span>')
                            .arg(fontManager.fontFamily).arg(YTranslateText.pronunciation)
                        }
                        if (id_pronounce_buttons_grid.phoneticSymbolJson.us.length > 0) {
                            return ('<span style="font-family: %1; font-weight: 500">%2</span>&nbsp;<span style="font-family: %3">&frasl;&nbsp;%4&nbsp;&frasl;</span>')
                            .arg(fontManager.fontFamily).arg(YTranslateText.shorthandUS).arg(fontManager.fontFamilyEnSymbol).arg(id_pronounce_buttons_grid.phoneticSymbolJson.us)
                        } else {
                            return ('<span style="font-family: %1; font-weight: 500">%2</span>')
                            .arg(fontManager.fontFamily).arg(YTranslateText.shorthandUS)
                        }
                    }
                    onValidClicked: {
                        if (playing) {
                            id_pronounce_buttons_grid.play(true)
                            if (!id_sound_uk.visible) {
                                qmlGlobal.soundWGTEn(resultManager.currentQuery)
                            } else {
                                qmlGlobal.soundWGTEn(resultManager.currentQuery, YEnum.US)
                            }
                            logManager.sendHttpLog("action=detail_american_accent_click")
                        }
                    }
                }

                YAudioPlayIconLabelButton {
                    id: id_sound_uk
                    visible: soundCenter.hasUkSound(resultManager.currentQuery)
                             && id_pronounce_buttons_grid.phoneticSymbolJson !== null
                             && (typeof id_pronounce_buttons_grid.phoneticSymbolJson.uk != "undefined")
                    textFormat: YText.RichText
                    text: {
                        if (!visible) {
                            return ""
                        }
                        if (!id_sound_us.visible) {
                            return ('<span style="font-family: %1; font-weight: 500">%2</span>')
                            .arg(fontManager.fontFamily).arg(YTranslateText.pronunciation)
                        }
                        console.log(fontManager.fontFamilyEnUs, resultManager.phoneticSymbolJson);
                        if (id_pronounce_buttons_grid.phoneticSymbolJson.uk.length > 0) {
                            return ('<span style="font-family: %1; font-weight: 500">%2</span>&nbsp;<span style="font-family: %3">&frasl;&nbsp;%4&nbsp;&frasl;</span>')
                            .arg(fontManager.fontFamily).arg(YTranslateText.shorthandEN).arg(fontManager.fontFamilyEnSymbol).arg(id_pronounce_buttons_grid.phoneticSymbolJson.uk)
                        } else {
                            return ('<span style="font-family: %1; font-weight: 500">%2</span>')
                            .arg(fontManager.fontFamily).arg(YTranslateText.shorthandEN)
                        }
                    }
                    onValidClicked: {
                        if (playing) {
                            id_pronounce_buttons_grid.play(false)
                            if (!id_sound_us.visible) {
                                qmlGlobal.soundWGTEn(resultManager.currentQuery)
                            } else {
                                qmlGlobal.soundWGTEn(resultManager.currentQuery, YEnum.UK)
                            }
                            logManager.sendHttpLog("action=detail_british_accent_click")
                        }
                    }
                }

                YAudioPlayIconLabelButton {
                    id: id_sound_default
                    visible: !id_sound_us.visible && !id_sound_uk.visible && text.length > 0
                    textFormat: YText.RichText
                    text: {
                        if (dictType === YEnum.DtPEPPrim) {
                            if (soundCenter.hasPepSound(resultManager.currentQuery)) {
                                console.log(fontManager.fontFamilyEnUs, resultManager.phoneticSymbolJson);
                                if (id_pronounce_buttons_grid.phoneticSymbolJson === null && resultManager.phoneticSymbolJson.length > 0) {
                                    return ('<span style="font-family: %1">&nbsp;%2&nbsp;</span>')
                                    .arg(fontManager.fontFamilyEnUs).arg(resultManager.phoneticSymbolJson)
                                } else {
                                    return ('<span style="font-family: %1; font-weight: 500">%2</span>')
                                    .arg(fontManager.fontFamily).arg(YTranslateText.pronunciation)
                                }
                            }
                            return ""
                        }
                        return ('<span style="font-family: %1; font-weight: 500">%2</span>')
                        .arg(fontManager.fontFamily).arg(YTranslateText.pronunciation)
                    }
                    onValidClicked: {
                        if (playing) {
                            if (dictType === YEnum.DtPEPPrim) {
                                qmlGlobal.soundWGTPep(resultManager.currentQuery)
                            } else {
                                qmlGlobal.soundWGTEn(resultManager.currentQuery)
                            }
                        }
                    }
                }
            }
        }

        Component {
            id: id_sentence_buttons

            Row {
                id: id_sentence_buttons_grid
//                columnSpacing: 12
//                rowSpacing: 10
                spacing: 10
//                columns: (id_sound_org.width + columnSpacing + id_sound_tar.width) > id_content_loader.width ? 1 : 2

                function autoPlay() {
                    play(true, true)
                }

                function play(isOrg, isAutoPlay) {
                    if (isOrg) {
                        if (id_sound_tar.playing) {
                            id_sound_tar.stop()
                        }
                        if (isAutoPlay)
                            id_sound_org.autoplay()
                        else
                            id_sound_org.play()
                    } else {
                        if (id_sound_org.playing) {
                            id_sound_org.stop()
                        }
                        if (isAutoPlay)
                            id_sound_tar.autoplay()
                        else
                            id_sound_tar.play()
                    }
                }

                YAudioPlayIconLabelButton {
                    id: id_sound_org
                    textFontFamily: fontManager.fontFamily
                    textFormat: YText.PlainText
                    text: YTranslateText.original
                    onValidClicked: {
                        if (playing) {
                            id_sentence_buttons_grid.play(true, false)
                            console.log("seven:dictType:org",dictType)
                            currentDictType = dictType
                            qmlGlobal.soundSentence()
                            currentDictType = -1
                            logManager.sendHttpLog("action=detail_trans_origin_pronounce_click");
                        }
                    }
                }

                YAudioPlayIconLabelButton {
                    id: id_sound_tar
                    textFontFamily: fontManager.fontFamily
                    textFormat: YText.PlainText
                    text: YTranslateText.translation
                    onValidClicked: {
                        if (playing) {
                            id_sentence_buttons_grid.play(false, false)
                            if(settingManager.transLanguage === YEnum.JA_JP) qmlGlobal.soundSentence(id_dict_type_base_item.content, "ja", false)
                            else qmlGlobal.soundSentence(id_dict_type_base_item.content)
                            console.log("seven:dictType:tar:")
                            logManager.sendHttpLog("action=detail_trans_pronounce_click");
                        }
                    }
                }

                //句法分析入口
                Rectangle {
                    width: id_ai_title.contentWidth + 32 + 32//145 + 15
                    height: 52
                    color: "#1A1B1F"
                    radius: 26
                    visible: {
//                        if(resultManager.currentQuery.length > 150) return false
//                        if(resultManager.currentQuery.split(" ").length < 3) return false
//                        return true
                        return getAiJumpVisible()
                    }
                    Rectangle{
                        id: id_ai_img
                        anchors.left: parent.left
                        anchors.top: parent.top
                        anchors.leftMargin: 15
                        anchors.topMargin: (parent.height - width) / 2
                        width: 32
                        height: 32
                        color: "transparent"
                        YImage {
                            width: 32
                            height: 32
                            anchors.horizontalCenter: parent.horizontalCenter
                            anchors.bottom: parent.bottom
                            sourceSize: Qt.size(520, 130)
                            imageName: "dict/dict_ai_sentence"
                        }
                    }

                    YText {
                        id: id_ai_title
                        anchors.left: id_ai_img.right
                        anchors.top: parent.top
                        anchors.right: parent.right
                        anchors.bottom: parent.bottom
                        anchors.leftMargin: -10
                        font.pixelSize: 26
                        color: "#909199"
                        verticalAlignment: Text.AlignVCenter
                        horizontalAlignment  : Text.AlignHCenter
                        text: YTranslateText.aiReading//"AI精读"
                    }

                    MouseArea{
                        anchors.fill: parent
                        onClicked: {
                            aiSentenceClick()
                            logManager.sendHttpLog("action=get_analysis_text")
                        }
                    }
                }
            }
        }

        Component {
            id: id_cn_zh_word_button
            Item {
                id: id_cn_zh_word_button_item
                height: id_sound_cn_zh_word.height

                function autoPlay() {
                    id_sound_cn_zh_word.play()
                }
//                Rectangle {
//                    width: id_sound_cn_zh_word.width//id_sound_cn_zh_word.width
//                    height: id_sound_cn_zh_word.realHeight
//                    color: "red"
//                    radius: height / 2
                    YAudioPlayIconLabelButton {
                        id: id_sound_cn_zh_word
                        textFontFamily: fontManager.fontFamilyEnUs
                        textFormat: YText.RichText
                        textItem.width: plainText.length > 52 ? 518/*558*/ : textItem.paintedWidth
                        textWrapMode: plainText.length > 52 ? Text.WordWrap : Text.NoWrap
                        anchors.verticalCenter: parent.verticalCenter
                        property var plainText: ""
                        height: {
                            console.log("seven:YButtonBase:height", realHeight)
                            return realHeight + 17
                        }
                        text: {
                            if(dictType == YEnum.DtBusIdiomCh){
                                var contentJson = dictJson[0]
                                if(contentJson !== undefined){
                                    chPinYinsSound = contentJson.条目.索引
                                    resultManager.phoneticSymbolJson = chPinYinsSound
                                    return contentJson.条目.汉语拼音
                                }
                            }
                            if (resultManager.phoneticSymbolJson.length > 0) {
                                plainText = resultManager.phoneticSymbolJson
                                return resultManager.phoneticSymbolJson
                            } else {
                                plainText = YTranslateText.pronunciation
                                return ('<span style="font-family: %1; font-weight: 500">%2</span>')
                                .arg(fontManager.fontFamily).arg(YTranslateText.pronunciation)
                            }
                        }
                        onValidClicked: {
                            if (playing) {
                                console.log("seven:YDictTypeBase:onValidClicked")
                                switch (resultManager.currentQueryType) {
                                case YEnum.WGT_Ch_Group:
                                case YEnum.WGT_Ch:
                                    qmlGlobal.soundWGTCh()
                                    break
                                case YEnum.WGT_Ko_Group:
                                case YEnum.WGT_Ko:
                                    qmlGlobal.soundWGTKo()
                                    break
                                }
                            }
                        }
                    }
//                }

            }
        }
    }

    YVerticalDividingLine {
        id: id_div_line
        anchors.bottom: parent.bottom
        visible: (resultManager.itemCount > 1) && (index < (resultManager.itemCount - 1))
    }

    Column {
        id: id_buttons_column
        anchors.left: parent.right
        anchors.leftMargin: 10
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 24
        width: 80
        spacing: 8

//        YIconButton {
//            implicitWidth: 80
//            implicitHeight: 70
//            anchors.horizontalCenter: parent.horizontalCenter
//            icon: "dict/top"
//            onValidClicked: {
//                resultManager.setTop(dictType)
//                id_dict_page.top_detail_button_visible = detail_button_visible
//                id_dict_page.backToContentTop()
//            }
//            visible: !isFirstDict
//        }

        YIconButton {
            id: id_dict_detail_button
            implicitWidth: 80
            implicitHeight: 70
            anchors.horizontalCenter: parent.horizontalCenter
            icon: "dict/detail"
            visible: isFirstDict ? false : detail_button_visible
            onValidClicked: {
                console.log("YDictTypeBase.qml===id_dict_detail_button===onValidClicked")
                id_dict_page.backContentYPos =  id_container_flickable.contentY
                if (resultManager.mainQueryBreakList.length > 1) {
                    qmlGlobal.showDictDetailPage(dictType, content, resultManager.mainQueryBreakList[id_dict_page.tagsIndex].content)
                } else {
                    qmlGlobal.showDictDetailPage(dictType, content, resultManager.mainQuery)
                }
            }
        }
    }

}


import QtQuick 2.12
import com.youdao.pen 1.0
import BaseQml 1.0

import "./qml/i18n"
import "./qml"
import "./qml/components"
import "./qml/audioplayer"
import "./qml/touchreadingresult"
import "./qml/timers"
import "./qml/globeaudioplayer"
import "./qml/dicts"

YMainWindow {
    id: id_main_menu_root
    isVideoPlayerShowing: id_video_player.isShowing

    function showPage(qrcqml, cachePage, properties) {
        if ((typeof cachePage !== undefined) && cachePage) {
            return id_page_pop_helper.cacheShow(qrcqml, false, properties)
        }
        return id_page_pop_helper.show(qrcqml, false, cachePage, properties)
    }

    function closeAudioPlayer() {
        // 三代 YAudioPlayer.close() 会在媒体非停止状态拉起悬浮指示器，
        // 对未显示的播放器调用 close() 会导致扫词时凭空出现音乐悬浮按钮。
        if (id_audio_player_loader.item != null && id_audio_player_loader.item.isShowing) {
            id_audio_player_loader.item.close()
        }
    }

    function closeItemsForHomeKeyReleased() {
        if (closeQuickSetting()) {
            return
        }

        if (YInputProperty.inputPageShowing) {
            baseSignals.closeInputPageWhileHomeKeyReleased()
        }

        if (qmlGlobal.isArticleEditing) {
            if (qmlGlobal.currentPageIndex === YEnum.PageIndex.Article
                    && (id_audio_player_loader.item === null || id_audio_player_loader.item.state !== "show")) {
                qmlGlobal.requestNoSubmitArticleTip()
                return
            } else {
                qmlGlobal.isArticleEditing = false
            }
        }

        closeAudioPlayer()
        id_video_player.hidden()
        id_globe_audio_player.close()

        if (id_scan_words_result_loader.active) {
            qmlGlobal.stopAllAnimationMusic()
            id_scan_words_result_loader.active = false
        }

        if (id_touch_reading_result_loader.active) {
            id_touch_reading_result_loader.closeCurrentComponent()
        }

        baseSignals.closePageWhileHomeKeyReleased()
        
        qmlGlobal.currentPageIndex = YEnum.PageIndex.NonePage

        id_page_pop_helper.closeAllPopPage()

        if (isUpdateOSShowing) isUpdateOSShowing  = false
    }

    YIndexPage {
        id: id_index_page
        onPageIndexClicked: {
            if (!id_stack_view.visible) {
                id_stack_view.visible = true
            }
        }
    }

    YTouchReadingResultLoader {
        id: id_touch_reading_result_loader
        onTouchReadingPageCalled: {
            closeSpeechNeedNetworkDialog()
            if (YEnum.TRAPI_Learning === activePageIndex) {
                id_stack_view.visible = false
            } else {
                if (0 === id_touch_reading_result_loader.optionCode.length) {
                    id_page_pop_helper.closeAllPopPage()
                }
            }
            closeAudioPlayer()
            if (YEnum.TRAPI_Cover !== activePageIndex) {
                id_video_player.hidden()
            }
            id_video_player.hidden()
            id_globe_audio_player.close()
        }
        onActivePageIndexChanged: {
            if (!id_stack_view.visible) {
                id_stack_view.visible = true
            }
        }
        onActiveChanged: {
            if (!active && !id_stack_view.visible){
                id_stack_view.visible = true
            }
        }
        isVerifiyFinished: id_main_menu_root.isVerifiyFinished
    }

    YStackView {
        id: id_stack_view
        onCurrentPopIdValidChanged: {
            if (!currentPopIdValid) {
                qmlGlobal.currentPageIndex = YEnum.PageIndex.NonePage
            }
        }
    }

    YPopLayer {
        id: id_page_pop_helper
    }

    YScanWordsResultLoader {
        id: id_scan_words_result_loader
        onOcrStart: {
            if (id_touch_reading_result_loader.active
                    && (YEnum.TRAPI_LargeBook
                        !== id_touch_reading_result_loader.activePageIndex)
                    && (0 === id_touch_reading_result_loader.optionCode.length)) {
                id_touch_reading_result_loader.closeCurrentComponent(isStartOid)
            }
            closeAudioPlayer()
            closeQuickSetting()
            id_video_player.hidden()
            id_globe_audio_player.close()
            speechManager.setEnable(false)
            thirdQmlContainerShowing = false
        }
        isVerifiyFinished: id_main_menu_root.isVerifiyFinished
    }

    YLoader {
        id: id_audio_player_loader
        width: parent.width
        height: parent.height
    }

    YVideoPlayer {
        id: id_video_player
        onVideoPlayPageCalled: {
            id_page_pop_helper.closeAllPopPage()
        }
    }

    YBackground {
        id: id_globe_audio_player_mask
        anchors.fill: parent
        visible: false
        YTextMedium {
            anchors.centerIn: parent
            text: "数据加载中..."
        }
    }

    YGlobeAudioPlayer {
        id: id_globe_audio_player
        onGlobeAudioPlayerPageCalled: {
            id_page_pop_helper.closeAllPopPage()
        }
        onClosed: {
            id_globe_audio_player_mask.visible = false
        }
    }

    YTouchReadingFollowResultLoader {
        id: id_word_large_book_question_result_loader
    }

    YDictTypeDtChPoemReferenceView{
        id: id_poem_view
    }


    // for fps test
//    YFPSText {
//        width: 180
//        height: 60
//        anchors.left: parent.left
//        anchors.leftMargin: 20
//        anchors.top: parent.top
//        anchors.topMargin: 20
//        YTextMedium {
//            anchors.centerIn: parent
//            text: "FPS: " + parent.fps.toFixed(2)
//            color: YColors.red
//        }
//    }

    Connections {
        target: qmlGlobal
        ignoreUnknownSignals: true
        enabled: isVerifiyFinished
        function onRequestSettingPage(index) {
            const settingPage = showPage("YSettingPage")
            const stackViewVisible = id_stack_view.visible
            settingPage.backButtonClicked.connect(function(){
                if (!stackViewVisible) {
                    id_stack_view.visible = false
                }
            })
            if ((index < YEnum.SettingIndex.SI_COUNT)
                    && (null !== id_page_pop_helper.popItemObject)) {
                id_page_pop_helper.popItemObject.settingItemClicked(index, true)
            }
            id_scan_words_result_loader.hidden()
            closeQuickSetting()
            closeAudioPlayer()
            id_video_player.hidden()
            id_globe_audio_player.close()
            if (!id_stack_view.visible) {
                id_stack_view.visible = true
            }
        }
        function onShowLoginPage() {
            console.log("main.qml===onShowLoginPage===called")
            if (!wifiManager.onoff || !wifiManager.link) {
                baseSignals.showToast(YTranslateText.networkAbnormalPleaseCheck, YColors.grayNormal)
                return
            }
            showPage("YLoginPage", true)
        }
        function onShowFollowPage(spellSwitchButtonVisible) {
            const followPage = showPage("YFollowPage")
            const stackViewVisible = id_stack_view.visible
            followPage.backButtonClicked.connect(function(){
                if (!stackViewVisible) {
                    id_stack_view.visible = false
                }
            })

            try {
                followPage.spellSwitchButtonVisible = spellSwitchButtonVisible
            }catch(e) {}

            if (id_audio_player_loader.item != null && id_audio_player_loader.item.isShowing) {
                followPage.backButtonClicked.connect(id_audio_player_loader.item.raise)
                id_audio_player_loader.item.hidden()
            }
            if (!stackViewVisible) {
                id_stack_view.visible = true
            }
        }

        function onShowSpellPage(propertiesValue) {
            const spellPage = showPage("YSpellPage")
            const stackViewVisible = id_stack_view.visible
            spellPage.backButtonClicked.connect(function(){
                if (!stackViewVisible) {
                    id_stack_view.visible = false
                }
            })
            if (propertiesValue.length > 0) {
                const values = JSON.parse(propertiesValue)
                if (typeof values.ukSoundButtonVisible != "undefined") {
                    spellPage.ukSoundButtonVisible = (values.ukSoundButtonVisible === "true")
                }
                if (typeof values.usSoundButtonVisible != "undefined") {
                    spellPage.usSoundButtonVisible = (values.usSoundButtonVisible === "true")
                }
                if (typeof values.spellButtonVisible != "undefined") {
                    spellPage.spellButtonVisible = (values.spellButtonVisible === "true")
                }
                if (typeof values.followButtonVisible != "undefined") {
                    spellPage.followButtonVisible = (values.followButtonVisible === "true")
                }
            }
            if (!spellPage.spellButtonVisible && typeof spellPage.play != "undefined") {
                spellPage.play()
            }
            if (!stackViewVisible) {
                id_stack_view.visible = true
            }
        }

        function onShowSpeechPage() {
            if (id_touch_reading_result_loader.active) {
                qmlGlobal.stopAllAnimationMusic()
                readingBookReadingManager.abort()
                id_touch_reading_result_loader.closeCurrentComponent()
            }
            id_scan_words_result_loader.hidden()
           // showPage("YSpeechPage", false)
            showPage("YVoiceAssistant",false)
        }

        function onShowMathPage() {
            mathManager.enterMath()
            showPage("YMathPage", false)
        }

        function onShowDictPage(pageIndex, ocrContent) {
            console.log("main.qml===onShowDictPage===called pageIndex:", pageIndex)
            closeSpeechNeedNetworkDialog()
            resultManager.isReturnSearch = false
            const dictPageObj = showPage("YDictPage", true)
            if (null !== dictPageObj) {
                dictPageObj.stackQueryResult = []
                switch (pageIndex) {
                case YEnum.PageIndex.History:
                    dictPageObj.title = YTranslateText.history
                    break
                case YEnum.PageIndex.Fav:
                    dictPageObj.title = YTranslateText.favoriteWords
                    dictPageObj.backButtonClicked.connect(function() {
                        qmlGlobal.backToWordCardView()
                    })
                    break
                case YEnum.PageIndex.Reading:
                    dictPageObj.title = YTranslateText.touchreading
                    break
                default:
                    dictPageObj.title = ""
                    break
                }

                dictPageObj.visible = true
                if (ocrContent.length && ocrContent !== "isOcrStart") {
                    dictPageObj.ocrContentString = ocrContent
                    //dictPageObj.isScannig = true
                } else if (ocrContent === "isOcrStart") {
                    console.log('ocrContent === "isOcrStart"')
                    dictPageObj.isButtonIsRePress = true
                    dictPageObj.isScannig = true
                    dictPageObj.visible = false
                }

                //resultManager.isReportButtonVisible = false
            }
        }

        function onQueryFromDictPage(mainQuery, srcLang, dstLang) {
            console.log("main.qml===onQueryFromDictPage===called mainQuery: ", mainQuery, ", srcLang:", srcLang, "dstLang:", dstLang)
            if (!resultManager.entryResult(mainQuery, srcLang, dstLang)) {
                baseSignals.showToast(YTranslateText.queryFaildPleaseTryAgain, "#2D2E33")
            } else {
                const dictPageObj = showPage("YDictPage", true)
                if (null !== dictPageObj) {
                    dictPageObj.title = YTranslateText.history//临时标记，防止加入历史记录、单词本
                    //dictPageObj.stackQueryResult  = []
                }
            }
        }

        function onShowDictDetailPage(dictType, dictContent, qsTitle) {
            console.warn("main.qml===onShowDictDetailPage===called dictType:", dictType, ", qsTitle:", qsTitle, ", dictContent", dictContent)
            let dictDetailPageObj =null
            let showDefaultTitle = true;
            switch (dictType){
            case  YEnum.DtChPoemDict+50:
                dictDetailPageObj = showPage("YDictPoemDataDetailPage", true)
                break
            case  YEnum.DtChPoemDict+52:
                  dictDetailPageObj= showPage("poemdetail/YDictTypeDetailDtChPoemDataAppreciation", true)
                break
            case  YEnum.DtChPoemDict+53:
                  dictDetailPageObj= showPage("poemdetail/YDictTypeDetailDtChPoemDataAboutTheAuthor", true)
                break
            case YEnum.NetTran:
                 dictDetailPageObj= showPage("YDictDetailPage", true)
                break
            default:
                switch(qsTitle){
                case  YTranslateText.translation:
                    dictDetailPageObj= showPage("poemdetail/YDictTypeDetailDtChPoemDataTranslation", true)
                    break;
                case YTranslateText.appreciation:
                    dictDetailPageObj= showPage("poemdetail/YDictTypeDetailDtChPoemDataAppreciation", true)
                    break;
                case YTranslateText.annotation:
                    dictDetailPageObj= showPage("poemdetail/YDictTypeDetailDtChPoemDataAnnotation", true)
                    break;
                case YTranslateText.aboutTheAuthor:
                    dictDetailPageObj= showPage("poemdetail/YDictTypeDetailDtChPoemDataAboutTheAuthor", true)
                    break;
                case YTranslateText.polyPhone:
                    dictDetailPageObj= showPage("dicts/YDictTypeDetailPolyPhone", true)
                    dictDetailPageObj.resJson = dictDetailPageObj.getData()
                    dictDetailPageObj.phoneticSymbolJson = dictDetailPageObj.getPhoneticJson()
                    dictDetailPageObj.curWord = resultManager.currentQuery
                    dictDetailPageObj.soundLanguageType = resultManager.getSoundLanguage()
                    dictDetailPageObj.spellPhonics = spellManager.phonics
                    break;
                default:
                    console.log("seven:netTrans:0:",dictContent)
                    switch(typeof JSON.parse(dictContent).originContent != "undefined"){
                    case true:
                        console.log("seven:netTrans:1:",dictContent)
                        dictDetailPageObj= showPage("poemdetail/YDictTypeDetailDtChPoemDataOrigin", true)
                        showDefaultTitle = false
                        break
                    default:
                        console.log("seven:netTrans:2:",dictContent)
                        dictDetailPageObj= showPage("YDictDetailPage", true)
                    }
                }
            }

            dictDetailPageObj.content = dictContent
            dictDetailPageObj.title = qsTitle
            dictDetailPageObj.dictType = dictType
            dictDetailPageObj.showPoemTitle = false
            switch (dictType) {
            case YEnum.DtChLarge:
                dictDetailPageObj.title = YTranslateText.dtChLarge
                break
            case YEnum.DtChAncientWord:
                dictDetailPageObj.title = YTranslateText.dtChAncientWord
                break
            case YEnum.DtChPoemDict:
//                dictDetailPageObj.title = YTranslateText.ancientPoemsReading
                switch(qsTitle){
                case  YTranslateText.translation:
                case YTranslateText.appreciation:
                case YTranslateText.annotation:
                case YTranslateText.aboutTheAuthor:
                    dictDetailPageObj.showPoemTitle = true
                    break;
                default:
                    dictDetailPageObj.showPoemTitle = false
                }
                if(showDefaultTitle)
                    dictDetailPageObj.title = YTranslateText.ancientPoemsReading
                break
            case YEnum.DtSenior:
                if (qmlGlobal.skuRegion() === YEnum.SKU_PEP) {
                    dictDetailPageObj.title = YTranslateText.dtYDSenior
                } else {
                    dictDetailPageObj.title = YTranslateText.dtSenior
                }
                break
            case YEnum.DtWebster:
                dictDetailPageObj.title = YTranslateText.dtWebster
                break
            case YEnum.DtOxford:
                dictDetailPageObj.title = YTranslateText.dtOxfordNumber
                break
            case YEnum.DtKoCh:
                dictDetailPageObj.title = YTranslateText.dtKoCh
                break
            case YEnum.DtChKo:
                dictDetailPageObj.title = YTranslateText.dtChKo
                break
            default:
                break
            }
        }

        //功能反馈
        function onShowFuncFeedBack() {
            console.log("onShowFuncFeedBack")
            showPage("components/YFunctionFeedback")
            console.log("YFunctionFeedback")
        }


        function onRequestTouchReadingPage(index) {
            if (index < YEnum.RI_COUNT) {
                id_page_pop_helper.showWithProperties(
                            "YTouchReadingPage", {"currentTabIndex": index})
            } else {
                showPage("YTouchReadingPage")
            }
            if (id_touch_reading_result_loader.active) {
                id_touch_reading_result_loader.closeCurrentComponent()
            }
        }

        function onRequestShowPage(index, cachePage) {
            switch (index) {
            case YEnum.PageIndex.Dict:
                if (resultManager.mainQuery.length > 0) {
                    qmlGlobal.showDictPage(index)
                } else {
                    id_scan_words_result_loader.showEmpty()
                }
                break
            case YEnum.PageIndex.UpdateOS:
                if (wifiManager.internetConnect) {
                    updateManager.checkOtaUpdate()
                }
                showPage("settingpages/YSettingUpdate")
                break
            case YEnum.PageIndex.Speech:
                qmlGlobal.showSpeechPage();
                break
            case YEnum.PageIndex.Reading:
                showPage("YTouchReadingPage")
                break
            case YEnum.PageIndex.TextBook:
                showPage("YTextbookPage")
                break
            case YEnum.PageIndex.Math:
                qmlGlobal.showMathPage()
                break
            case YEnum.PageIndex.MathTutor:
                showPage("YMathExercisePage")
                break
            case YEnum.PageIndex.Fav:
                showPage("YWordBookPage")
                break
            case YEnum.PageIndex.Audioplayer:
                showPage("YAudioPage", cachePage)
                break
            case YEnum.PageIndex.History:
                const resultItem = showPage("YHistoryPage")
                if (null !== resultItem) {
                    historyManager.loadMore()
                }
                break
            case YEnum.PageIndex.Setting:
                showPage("YSettingPage")
                break
            case YEnum.PageIndex.Article:
                showPage("YArticlePage")
                break
            }
        }

        function onRequestShowThirdQML(thirdQML) {
            console.warn("main.qml===onRequestShowThirdQML===thirdQML:" + thirdQML)
            showPage(thirdQML, true)
        }

        function onRequestWordLargeBookAnswerResult(followResultIndex) {
            function newComponentInit(incubatorObject) {
                incubatorObject.resultShowFinished.connect(
                            incubatorObject.resultShowFinishedReceived)
                systemBase.homeKeyRelease.connect(incubatorObject.destroy)
                systemBase.homeKeyLongPress.connect(incubatorObject.destroy)
                qmlGlobal.requestWordLargeBookAnswerResult.connect(incubatorObject.destroy)
                id_scan_words_result_loader.ocrStart.connect(incubatorObject.resultShowFinishedReceived)
                id_scan_words_result_loader.ocrStart.connect(id_touch_reading_result_loader.closeCurrentComponent)
                id_scan_words_result_loader.ocrStart.connect(incubatorObject.destroy)
                id_touch_reading_result_loader.touchReadingPageCalled.connect(
                            incubatorObject.touchReadingPageCalledReceived)
                incubatorObject.show(followResultIndex)
            }

            const incubator = id_word_large_book_answer_result_component.incubateObject(
                                id_main_menu_root)
            if (incubator.status !== Component.Ready) {
                incubator.onStatusChanged = function(status) {
                    if (status === Component.Ready) {
                        if (0 === --incubatorCreateWordLargeBookAnswerResultCount) {
                            // 异步重入只显示最后一个创建的对象
                            newComponentInit(incubator.object)
                        } else {
                            incubator.object.destroy()
                        }
                    }
                }
                ++incubatorCreateWordLargeBookAnswerResultCount
            } else {
                newComponentInit(incubator.object)
            }
        }

        property int incubatorCreateWordLargeBookAnswerResultCount: 0

        function onBackToHomePage() {
            closeItemsForHomeKeyReleased()
            if (id_stack_view.visible) {
                id_stack_view.visible = false
            }
            if (isUpdateOSShowing) isUpdateOSShowing = false
        }
    }

    Connections {
        target: baseSignals
        ignoreUnknownSignals: true
        function onShowAudioPlayer() {
            if (id_audio_player_loader.item != null) {
                id_audio_player_loader.item.show()
            }
        }

        function onShowGlobeAudioPlayer() {
            id_globe_audio_player.show()
        }
    }

    Component {
        id: id_word_large_book_answer_result_component
        YTouchReadingFollowResultLoader {
            id: id_word_large_book_answer_result
            function resultShowFinishedReceived() {
                id_touch_reading_result_loader.optionCode = ""
                id_touch_reading_result_loader.checkBackgroundVisible()
                id_word_large_book_answer_result.destroy()
            }
            function touchReadingPageCalledReceived() {
                if ((YEnum.TRAPI_Learning !== id_touch_reading_result_loader.activePageIndex)
                        && (0 === id_touch_reading_result_loader.optionCode.length)) {
                    id_word_large_book_answer_result.destroy()
                }
            }
        }
    }

    Connections {
        target: systemBase
        ignoreUnknownSignals: true
        function onHomeKeyRelease() {
            console.log("main.qml===onHomeKeyRelease===")
            closeItemsForHomeKeyReleased()
            qmlGlobal.qweInputWidgetShowing = false
        }

        function onHomeKeyDoublePress() {
            console.log("main.qml====onHomeKeyDoublePress")
            if (isVideoPlayerShowing) return
            if (quickSettingOpening) {
                closeQuickSetting()
            } else {
                openQuickSetting()
            }
        }

        function onHomeKeyLongPress() {
            console.log("main.qml====onHomeKeyLongPress")
            closeItemsForHomeKeyReleased()
        }

        function onStopContinueScan() {
            id_scan_words_result_loader.showIndex = 0
        }
    }

    Connections {
        target: settingManager
        ignoreUnknownSignals: true
        function onIsPepVersionChanged() {
            id_index_page.updateMainMenuModel()
        }
    }

    Connections {
        target: readingBookAudioPlayerManager
        ignoreUnknownSignals: true
        enabled: isVerifiyFinished

        function onPrepareGlobeAudioPlayer() {
            id_globe_audio_player_mask.visible = true
        }
    }

    // 三代固件未暴露 updateOsManager（OS 升级走 updateManager），此连接在二代上才有效
    Connections {
        target: typeof updateOsManager !== "undefined" ? updateOsManager : null
        ignoreUnknownSignals: true
        enabled: isVerifiyFinished && typeof updateOsManager !== "undefined"

        function onOsstateChanged() {
            if (updateOsManager.osstate !== YEnum.DefaultState) {
                qmlGlobal.requestShowUpdateOSPage()
            }
        }
    }

    Component.onCompleted: {
        systemBase.headSetInitStatus()
        YTimers.delayCall(60, function(){
            console.warn("main.qml====Component.onCompleted delay init")
            delayInitMainWindow()
            id_index_page.delayInitMainTitleBar()
            id_audio_player_loader.source = "qml/audioplayer/YAudioPlayer.qml"
            id_audio_player_loader.setActive()
            qmlGlobal.mainWindowDisplayed()
        })

        if (typeof updateOsManager !== "undefined"
                && updateOsManager.osstate !== YEnum.DefaultState
                && updateOsManager.osstate !== YEnum.DowningResourceFailState
                && updateOsManager.osstate !== YEnum.BackupingFailDataState
                && updateOsManager.osstate !== YEnum.DowingOtaFailState
                && updateOsManager.osstate !== YEnum.InstingOtaFailState
                && updateOsManager.osstate !== YEnum.UploadingFailSerDataState) {
            qmlGlobal.requestShowUpdateOSPage()
        }
    }
}

import QtQuick 2.12
import com.youdao.pen 1.0

import ".."
import BaseQml 1.0
import "../i18n"
import "../timers"

Item {
    id: id_touch_reading_page
    anchors.fill: parent

    readonly property bool active: id_child_page_container.active
                                   || (YEnum.TRAPI_COUNT !== activePageIndex)

    property int activePageIndex: YEnum.TRAPI_COUNT

    readonly property bool pageShowing: activePageIndex !== YEnum.TRAPI_COUNT
    readonly property bool isBookMetalGet: null !== id_get_medal_tip.bookMetalGetObject
    readonly property alias currentBookMetalValue: id_get_medal_tip.bookMetalGetObject
    property bool isVerifiyFinished: false
    property string optionCode: ""

    function showBookMetal(isFromXiaoXiangCover=false) {
        if (isBookMetalGet && (currentBookMetalValue.bookId
                               === readingBookManager.lastQueryBookId)) {
            YTimers.delayCall(600, function(){
                qmlGlobal.stopAllAnimationMusic()
                id_get_medal_tip.showMedal(isFromXiaoXiangCover)
            })
        }
    }

    function mp3FullPath(fileName) {
        return ("%1%2.mp3").arg(qmlGlobal.touchReadingTipsSoundPath).arg(fileName)
    }

    function playAudioFile(fileName) {
        soundCenter.playMusic(mp3FullPath(fileName))
    }

    signal touchReadingPageCalled()
    signal backButtonClicked()

    function closeCurrentComponent(backgroundVisible = false) {
        console.warn("YTouchReadingResultLoader.qml===closeCurrentComponent()")
        if (backgroundVisible) {
            id_bg.visible = true
        } else {
            id_delay_disabled_timer.restart()
        }
        backButtonClicked()
        if (YEnum.TRAPI_COUNT !== activePageIndex) {
            switch (activePageIndex) {
            case YEnum.TRAPI_TouchReading:
            case YEnum.TRAPI_FollowReading:
                qmlGlobal.requestStartAutoScreenOff()
                break
            default:
                break
            }
            optionCode = ""
            qmlGlobal.stopAllAnimationMusic()
            if (YEnum.STOPPED !== readingBookReadingManager.audioPlayState) {
                readingBookReadingManager.stopAudio()
            }
            id_child_page_container.active = false
            activePageIndex = YEnum.TRAPI_COUNT
            if (null === id_get_medal_tip.metalGetObject) {
                qmlGlobal.currentPageIndex = YEnum.PageIndex.NonePage
            }
        }
    }

    function showComponent(newPageIndex) {
        if ((newPageIndex !== activePageIndex) || !id_child_page_container.active) {
            if (id_child_page_container.active) {
                closeCurrentComponent()
            }
            switch (newPageIndex) {
            case YEnum.TRAPI_NoContentTip:
                YTimers.delayCall(300, function(){
                    playAudioFile("reading-nocontent")
                })
                break
            case YEnum.TRAPI_QuizzesTip:
                YTimers.delayCall(300, function(){
                    playAudioFile("reading-question-start")
                })
                break
            }
            YTimers.delayCall(300, function(){
                systemBase.wakeUpScreen()
            })
            activePageIndex = newPageIndex
            id_child_page_container.active = true
        }
    }

    function wordLargeBookAnswerRight() {
        qmlGlobal.requestWordLargeBookAnswerResult(YEnum.TRFRI_Excellent)
    }

    function wordLargeBookAnswerWrong() {
        qmlGlobal.requestWordLargeBookAnswerResult(YEnum.TRFRI_TryAgain)
    }

    function checkBackgroundVisible() {
        if (id_bg.visible && (YEnum.TRAPI_COUNT === activePageIndex)) {
            id_delay_disabled_timer.restart()
        }
    }

    YBackgroundIgnoreMouseEvent {
        id: id_bg
        anchors.fill: parent
        visible: false
        color: (YEnum.TRAPI_LargeBook === activePageIndex) ? YColors.black : YColors.touchReadingBg

        function clearData() {
            readingBookReadingManager.wipeData()
            readingBookCoverManager.wipeData()
            readingBookManager.wipeData()
            readingBookContentArrayManager.wipeData()
        }

        function homeKeyTriggered() {
            const sendEndMsg = (YEnum.TRAPI_TouchReading === activePageIndex)
            id_get_medal_tip.closeMedal()
            id_bg.clearData()
            if (id_child_page_container.active) {
                closeCurrentComponent()
            }
            if (sendEndMsg) {
                logManager.touchReadingTouchTextEnd()
            }
        }
    }

    Item {
        id: id_child_page_container
        anchors.fill: parent

        property bool active: false

        property var theQuizLearningIndexPagePlayCallBack: null
        property int incubatorCreateCount: 0

        function creatIncubateOpeningItemObject(qmlPageFileName, newPageIndex) {
            id_delay_disabled_timer.stop()
            id_bg.visible = true

            id_get_medal_tip.closeMedal() // 关闭已经打开的勋章界面

            closeCurrentComponent()

            showComponent(newPageIndex)

            const newComponent = Qt.createComponent(qmlPageFileName);
            const incubator = newComponent.incubateObject(id_child_page_container)
            if (incubator.status !== Component.Ready) {
                incubator.onStatusChanged = function(status) {
                    if (status === Component.Ready) {
                        if (0 === --incubatorCreateCount) {
                            // 异步重入只显示最后一个创建的对象
                            creatIncubateOpeningItemObjectFinished(incubator.object, newPageIndex)
                        } else {
                            incubator.object.destroy()
                        }
                    }
                }
                ++incubatorCreateCount
            } else {
                creatIncubateOpeningItemObjectFinished(incubator.object, newPageIndex)
            }

            touchReadingPageCalled()
            qmlGlobal.currentPageIndex = YEnum.PageIndex.Reading
        }

        function creatIncubateOpeningItemObjectFinished(pageObject, newPageIndex) {
            if (!id_scan_words_result_loader.active) {
                id_touch_reading_page.backButtonClicked.connect(pageObject.destroy)
                id_scan_words_result_loader.activeChanged.connect(pageObject.destroy)
                systemBase.homeKeyRelease.connect(pageObject.destroy)
                systemBase.homeKeyLongPress.connect(pageObject.destroy)
                switch (newPageIndex) {
                case YEnum.TRAPI_Cover:
                    pageObject.play()
                    id_video_player.hidden()
                    break
                case YEnum.TRAPI_NoContentTip:
                case YEnum.TRAPI_QuizzesTip:
                    pageObject.play()
                    break
                case YEnum.TRAPI_WordCard:
                case YEnum.TRAPI_LargeBook:
                    pageObject.backButtonClicked.connect(closeCurrentComponent)
                    pageObject.play()
                    break
                case YEnum.TRAPI_Learning:
                    pageObject.backButtonClicked.connect(closeCurrentComponent)
                    pageObject.play(theQuizLearningIndexPagePlayCallBack)
                    break
                case YEnum.TRAPI_TouchReading:
                case YEnum.TRAPI_FollowReading:
                    qmlGlobal.requestStopAutoScreenOff()
                    pageObject.enterFollowPage.connect(function(){
                        activePageIndex = YEnum.TRAPI_FollowReading
                    })
                    pageObject.closeFollowPage.connect(function(){
                        activePageIndex = YEnum.TRAPI_TouchReading
                    })
                    pageObject.textReadingFinished.connect(showBookMetal)
                    if (YEnum.TRAPI_TouchReading === newPageIndex) {
                        readingBookReadingManager.enterReading(YEnum.RBT_Touch)
                        pageObject.play()
                    } else {
                        pageObject.enterFollow()
                    }
                    break
                default:
                    break
                }
            } else {
                closeCurrentComponent()
                if (typeof pageObject.destroy != "undefined") {
                    pageObject.destroy()
                }
                console.warn("id_scan_words_result_loader is active")
            }
        }

        YTimer {
            id: id_delay_disabled_timer
            interval: 300
            onTriggered: {
                id_bg.visible = active
            }
        }
    }

    Connections {
        target: readingBookCoverManager
        enabled: isVerifiyFinished
        ignoreUnknownSignals: true
        function onCoverContentChanged() {
            qmlGlobal.requestTouchReadingBookCover()
        }
    }

    Connections {
        target: readingBookReadingManager
        enabled: isVerifiyFinished
        ignoreUnknownSignals: true
        function onReadingContentChanged() {
            id_child_page_container.creatIncubateOpeningItemObject(
                        "YTouchReadingBookPage.qml",
                        readingBookReadingManager.isFollow
                        && (YEnum.RBT_Follow === settingManager.readingBookType)
                        ? YEnum.TRAPI_FollowReading : YEnum.TRAPI_TouchReading)
            if (YEnum.TRAPI_TouchReading === activePageIndex) {
                logManager.touchReadingTouchTextStart()
            }
        }
        function onAudioPlayStateChanged() {
            if (YEnum.STOPPED === readingBookReadingManager.audioPlayState) {
                if (YEnum.FPS_COUNT === readingBookReadingManager.followPageState) {
                    logManager.touchReadingTouchTextEnd()
                }
            }
        }
    }

    Connections {
        target: readingBookManager
        enabled: isVerifiyFinished
        ignoreUnknownSignals: true
        function onNoDataAreaDetect() {
            id_child_page_container.creatIncubateOpeningItemObject(
                        "YNoContentReadingTips.qml", YEnum.TRAPI_NoContentTip)
            id_scan_words_result_loader.hidden()
        }
        function onBookMetalGetReceived(bookId, metalTitle,
                                        metalRoundIcon, metalRectIcon) {
            id_get_medal_tip.bookMetalGetObject = {
                "bookId": bookId,
                "metalRoundIcon": metalRoundIcon.toLoadFileUrl(),
                "metalRectIcon": metalRectIcon.toLoadFileUrl(),
                "metalTitle": metalTitle
            }
        }
        function onPlayGuideFinish() {
            if (id_child_page_container.active) {
                closeCurrentComponent()
            }
        }
    }

    Connections {
        target: systemBase
        enabled: isVerifiyFinished
        ignoreUnknownSignals: true
        function onIsOidStart(isOid) {
            if (!isOid) {
                closeCurrentComponent()
            }
        }
        function onOidStop(bSuccess) {
            if (!bSuccess) {
                closeCurrentComponent()
            }
        }
        function onHomeKeyRelease() {
            if (!qmlGlobal.quickSettingsShowing) {
                id_bg.homeKeyTriggered()
            }
            id_delay_disabled_timer.triggered()
        }
        function onHomeKeyLongPress() {
            id_bg.homeKeyTriggered()
            id_delay_disabled_timer.triggered()
        }
    }

    Connections {
        target: qmlGlobal
        enabled: isVerifiyFinished
        ignoreUnknownSignals: true
        function onShowDictFromTouchReadingBook(word) {
            console.log("YTouchReadingResultLoader.qml===activePageIndex: ", activePageIndex)
            if (YEnum.TRAPI_TouchReading === activePageIndex) {
                if (!resultManager.entryResult(word, "", "", YEnum.PageIndex.Reading)) {
                    baseSignals.showToast(YTranslateText.queryFaildPleaseTryAgain, "#2D2E33")
                } else {
                    qmlGlobal.showDictPage(YEnum.PageIndex.Reading)
                }
            }
        }
        function onRequestInteractiveQuizzesTips() {
            id_child_page_container.creatIncubateOpeningItemObject(
                        "YInteractiveQuizzesIndexGuide.qml",
                        YEnum.TRAPI_QuizzesTip)
        }
        function onRequestTouchReadingBookCover() {
            if (readingBookCoverManager.coverContent.length > 0 ||
                    readingBookCoverManager.coverPractice.length > 0) {
                id_child_page_container.creatIncubateOpeningItemObject(
                            "YTouchReadingResultCover.qml", YEnum.TRAPI_Cover)
            } else {
                console.warn("YTouchReadingResultLoader.qml===readingBookCoverManager.coverContent AND readingBookCoverManager.coverPractice===is empty")
                if (active) {
                    closeCurrentComponent()
                }
            }
        }
        function onRequestWordCardIndex() {
            id_child_page_container.creatIncubateOpeningItemObject(
                        "YWordCardIndex.qml", YEnum.TRAPI_WordCard)
        }
        function onRequestWordLargeBookQuestionIndex() {
            id_child_page_container.creatIncubateOpeningItemObject(
                        "YWordLargeBookQuestionIndex.qml", YEnum.TRAPI_LargeBook)
        }
    }

    Connections {
        target: readingBookContentArrayManager
        enabled: isVerifiyFinished
        ignoreUnknownSignals: true
        function onContentArrayChanged() {
            if (("wordcard_list" === readingBookContentArrayManager.contentArrayType)
                    && (readingBookContentArrayManager.contentArray.length > 0)) {
                qmlGlobal.requestWordCardIndex()
            }
        }
    }

    Connections {
        target: interactiveLearningManager
        enabled: isVerifiyFinished
        ignoreUnknownSignals: true
        function onRequestEnter() {
            id_child_page_container.theQuizLearningIndexPagePlayCallBack = function () {
                interactiveLearningManager.requestInteractiveLearningData()
            }
            id_child_page_container.creatIncubateOpeningItemObject(
                        "YQuizLearningIndex.qml", YEnum.TRAPI_Learning)
        }
        function onXiaoxiangLearning(key) {
            id_child_page_container.theQuizLearningIndexPagePlayCallBack = function () {
                interactiveLearningManager.requestXiaoxiangLearningData(key)
            }
            id_child_page_container.creatIncubateOpeningItemObject(
                        "YQuizLearningIndex.qml", YEnum.TRAPI_Learning)
        }
    }

    Connections {
        target: readingBookQuestionOptionManager
        enabled: isVerifiyFinished
        ignoreUnknownSignals: true
        function onQuestionContentChanged() {
            if (readingBookQuestionOptionManager.questionContent.length > 0) {
                console.warn("YTouchReadingResultLoader.qml===readingBookQuestionOptionManager.questionCode:\n",
                             readingBookQuestionOptionManager.questionCode)
                console.warn("YTouchReadingResultLoader.qml===readingBookQuestionOptionManager.questionContent:\n",
                             readingBookQuestionOptionManager.questionContent)
                qmlGlobal.requestWordLargeBookQuestionIndex() // 66924970
            }
        }
        function onOptionContentChanged() {
            if (readingBookQuestionOptionManager.optionContent.length > 0) {
                optionCode = readingBookQuestionOptionManager.optionCode
                console.warn("YTouchReadingResultLoader.qml===readingBookQuestionOptionManager.questionCode:\n",
                             readingBookQuestionOptionManager.questionCode)
                console.warn("YTouchReadingResultLoader.qml===readingBookQuestionOptionManager.optionContent:\n",
                             readingBookQuestionOptionManager.optionContent)
                // {"option_image":"","option_isTrue":"y","question_code":"66924971"}
                const jsonContent = JSON.parse(readingBookQuestionOptionManager.optionContent)
                closeCurrentComponent(true)
                if ("y" === jsonContent.option_isTrue) {
                    if (YEnum.TRAPI_LargeBook === activePageIndex) {
                        if (readingBookQuestionOptionManager.questionCode
                                === jsonContent.question_code) {
                            wordLargeBookAnswerRight()
                        } else {
                            wordLargeBookAnswerWrong()
                        }
                    } else {
                        wordLargeBookAnswerRight()
                    }
                } else {
                    wordLargeBookAnswerWrong()
                }
            }
        }
    }

    Connections {
        target: readingBookPracticeManager
        enabled: isVerifiyFinished
        ignoreUnknownSignals: true
        function onPracticeListChanged() {
            if (readingBookPracticeManager.practiceList.length > 0) {
                console.warn("YTouchReadingResultLoader.qml===readingBookPracticeManager.practiceList:\n",
                             readingBookPracticeManager.practiceList, "\n\n")
            }
        }
    }

    Connections {
        target: readingBookAudioPlayerManager
        ignoreUnknownSignals: true
        enabled: isVerifiyFinished

        function onGlobeAudioPlayFinished() {
            console.warn("YTouchReadingResultLoader.qml===readingBookAudioPlayerManager=== onGlobeAudioPlayFinished check need showBookMetal or not\n")
            showBookMetal()
        }
    }

    QtObject {
        id: id_get_medal_tip

        property var bookMetalGetObject: null
        property var metalGetObject: null
        property int incubatorCreateCount: 0

        function closeMedal() {
            bookMetalGetObject = null
            if (null !== metalGetObject) {
                metalGetObject.stopGetMedal()
                destroyMetalGetObject()
            }
        }

        function destroyMetalGetObject() {
            if (null !== metalGetObject) {
                metalGetObject.destroy()
                metalGetObject = null
            }
        }

        function showMedal(isFromXiaoXiangCover=false) {
            const newComponent = Qt.createComponent("YTouchReadingFollowGetMedalLoader.qml");
            const incubator = newComponent.incubateObject(id_touch_reading_page)
            if (incubator.status !== Component.Ready) {
                incubator.onStatusChanged = function(status) {
                    if (status === Component.Ready) {
                        if (0 === --incubatorCreateCount) {
                            showMedalFinished(incubator.object, isFromXiaoXiangCover)
                        } else {
                            incubator.object.destroy()
                        }
                    }
                }
                ++incubatorCreateCount
            } else {
                showMedalFinished(incubator.object, isFromXiaoXiangCover)
            }
        }

        function showMedalFinished(incubatorObject, isFromXiaoXiangCover=false) {
            if (null === metalGetObject) {
                metalGetObject = incubatorObject
                closeCurrentComponent()
                incubatorObject.resultShowFinished.connect(destroyMetalGetObject)
                incubatorObject.metalRoundIcon = currentBookMetalValue.metalRoundIcon
                incubatorObject.metalRectIcon = currentBookMetalValue.metalRectIcon
                incubatorObject.metalTitle = currentBookMetalValue.metalTitle
                incubatorObject.isFromXiaoXiangCover = isFromXiaoXiangCover
                incubatorObject.showTips()
                bookMetalGetObject = null
            }
        }
    }
}



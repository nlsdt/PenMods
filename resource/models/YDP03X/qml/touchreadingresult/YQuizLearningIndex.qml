import QtQuick 2.12
import com.youdao.pen 1.0

import BaseQml 1.0
import "../timers"

YBackgroundIgnoreMouseEvent {
    id: id_quiz_learning

    signal backButtonClicked()
    signal callScorePageClicked()

    property bool selectabled: true

    readonly property string contentKey: interactiveLearningManager.currentSearchString
    readonly property string contentType: interactiveLearningManager.contentType
    readonly property string contentModel: interactiveLearningManager.content
    property string xiaoXiangPinyin: ""
    property double startPlayLoadingAnimationMilliseconds: 0

    anchors.fill: parent
    visible: false

    Connections {
        target: interactiveLearningManager
        enabled: id_quiz_learning.visible
        ignoreUnknownSignals: true
        function onAcceptEnter() {
            if (interactiveLearningManager.content.length > 0) {
                YTimers.delayCall(Math.max(40, 5000 - (new Date().getTime() - startPlayLoadingAnimationMilliseconds)), function() {
                    if (interactiveLearningManager.content.length > 0) {
                        id_quiz_learning_view.delegate = null
                        id_quiz_learning_view.model = null
                        console.warn("YQuizLearningIndex.qml===contentKey: ", contentKey)
                        console.warn("YQuizLearningIndex.qml===contentType: ", contentType)
                        console.warn("YQuizLearningIndex.qml===contentModel: ", contentModel)

                        switch (contentType) {
                        case "hanzi":
                            id_quiz_learning_view.model = id_mask_source.hanziExplainsModel()
                            id_quiz_learning_view.delegate = id_quiz_learning_delegate_hanzi
                            break
                        case "pinyin":
                            id_quiz_learning_view.model = id_mask_source.pinyinExplainsModel()
                            id_quiz_learning_view.delegate = id_quiz_learning_delegate_pinyin
                            break
                        case "word":
                            id_quiz_learning_view.model = id_mask_source.wordExplainsModel()
                            id_quiz_learning_view.delegate = id_quiz_learning_delegate_word
                            break
                        case "xiaoxiang":
                            id_quiz_learning_view.model = id_mask_source.xiaoxiangExplainsModel()
                            id_quiz_learning_view.delegate = id_quiz_learning_delegate_xiaoxiang
                            break
                        default:
                            break
                        }
                        if (settingManager.isFirstWordCardReview) {
                            settingManager.setNotIsFirstWordCardReview()
                            wordCardReviewGuide.maskSource = id_mask_source
                            wordCardReviewGuide.play()
                        } else {
                            id_delay_play_timer.restart()
                        }
                        id_quiz_learning_loading_tips.stop()
                        id_quiz_learning_loading_tips.visible = false
                    }
                })
            }
        }
    }

    function play(pagePlayCallBack) {
        startPlayLoadingAnimationMilliseconds = new Date().getTime()
        soundCenter.playMusic(qmlGlobal.touchReadingTipsSoundPath + "quize_loading_tips.mp3")
        id_quiz_learning_loading_tips.play()
        visible = true
        id_delay_show_timer.doShow(pagePlayCallBack)
    }

    function resetCurrentIndex() {
        id_quiz_learning_view.currentIndex = -1
        id_quiz_learning_view.currentIndex = 0
        id_quiz_learning_view.playCurrentItem()
        console.warn("YQuizLearningIndex.qml===resetCurrentIndex===called")
    }

    function stop() {
        qmlGlobal.stopAllAnimationMusic()
    }

    function positionViewToBeginning() {
        id_quiz_learning_view_flickable.contentY = 0
    }

    YTimer {
        id: id_delay_play_timer
        interval: 120
        onTriggered: {
            resetCurrentIndex()
        }
        objectName: "YWordCardIndex.qml_id_delay_play_timer"
    }

    YTimer {
        id: id_delay_show_timer
        interval: 1800
        property var pagePlayCallBack: null
        function doShow(callBack) {
            pagePlayCallBack = callBack
            restart()
        }
        onTriggered: {
            if (null !== pagePlayCallBack) {
                pagePlayCallBack()
            }
        }
        objectName: "YWordCardIndex.qml_id_delay_show_timer"
    }

    YBackground {
        id: id_mask_source
        anchors.fill: parent
        color: parent.color

        function hanziExplainsModel() {
            const hanziContent = JSON.parse(contentModel)
            let hanziExplains = hanziContent.hanzi_explains
            hanziExplains.unshift({
                                      "explain_audio": hanziContent.hanzi_audio,
                                      "explain_text": hanziContent.hanzi_text,
                                      "explain_imgs": [hanziContent.hanzi_img],
                                      "pinyin_text": hanziContent.pinyin_text,
                                      "tran_audio": hanziContent.tran_audio
                                  })

            hanziExplains.push({
                                   "explain_audio": "",
                                   "explain_text": "",
                                   "explain_imgs": "[]",
                                   "last_tip_message": ""
                               })
            return hanziExplains
        }

        function pinyinExplainsModel() {
            const pinyinContent = JSON.parse(contentModel)
            let pinyinExplains = pinyinContent.pinyin_explains
            pinyinExplains.unshift({
                                       "explain_audio": pinyinContent.pinyin_audio,
                                       "explain_text": pinyinContent.pinyin_text,
                                       "explain_img": pinyinContent.pinyin_img,
                                       "tran_audio": pinyinContent.tran_audio
                                   })

            pinyinExplains.push({
                                    "explain_audio": "",
                                    "explain_text": "",
                                    "explain_img": "[]",
                                    "last_tip_message": ""
                                })
            return pinyinExplains
        }

        function wordExplainsModel() {
            const pinyinContent = [('{"content":%1}').arg(contentModel), '{"content":{"word_lan":"en","is_follow":true,"word_text":"","last_tip_message":"","word_audio":""}}']
            return pinyinContent
        }

        function xiaoxiangExplainsModel() {
/*
        {
            "practice_group_name": "学汉字",
            "practice_group_type": "default",
            "practice_list": [
                {
                    "practice_content": {
                        "hanzi_audio": "/userdisk/resource/bookseries/smallelephete/practicePinyinAudio7_0.mp3",
                        "hanzi_img": "",
                        "hanzi_text": "牛",
                        "pinyin_text": "niú"
                    },
                    "practice_type": "pinyin"
                },
                {
                    "practice_content": {
                        "hanzi_audio": "/userdisk/resource/bookseries/smallelephete/practicePinyinAudio7_1.mp3",
                        "hanzi_img": "",
                        "hanzi_text": "奶牛",
                        "pinyin_text": "nǎi niú"
                    },
                    "practice_type": "pinyin"
                },
                {
                    "practice_content": {
                        "hanzi_audio": "/userdisk/resource/bookseries/smallelephete/practicePinyinAudio7_2.mp3",
                        "hanzi_img": "",
                        "hanzi_text": "黄牛",
                        "pinyin_text": "huáng niú"
                    },
                    "practice_type": "pinyin"
                }
            ],
            "practice_type_list": [
                "pinyin",
                "pinyin",
                "pinyin"
            ]
        }
*/
            let xiaoxiangContent = JSON.parse(contentModel)
            xiaoxiangContent.push({
                                      "explain_audio": "",
                                      "explain_text": "",
                                      "explain_img": "[]",
                                      "last_tip_message": ""
                                  })
            return xiaoxiangContent
        }

        Flickable {
            id: id_quiz_learning_view_flickable

            anchors.fill: parent
            anchors.leftMargin: 90
            anchors.rightMargin: 90
            contentHeight: id_column.height

            Column {
                id: id_column
                spacing: 0
                anchors.left: parent.left
                anchors.right: parent.right

                YSpacingForColumn {
                    implicitHeight: 18
                }

                YHorizontalListView {
                    id: id_quiz_learning_view
                    anchors.left: parent.left
                    anchors.right: parent.right
                    height: currentItem.height
                    preferredHighlightBegin: 0.5
                    preferredHighlightEnd: 0.5
                    highlightRangeMode: ListView.StrictlyEnforceRange
                    snapMode: ListView.SnapOneItem
                    clip: false
                    interactive: count > 1
                    readonly property bool currentItemPlayabled: !settingManager.isFirstWordCardReview && (null === wordCardReviewGuide)
                    onCurrentIndexChanged: {
                        console.warn("YQuizLearningIndex.qml===currentIndex: ", currentIndex)
                        if (null === wordCardReviewGuide) {
                            id_quiz_learning_view.playCurrentItem()
                        }
                    }

                    function playCurrentItem() {
                        id_quiz_learning.stop()
                        positionViewToBeginning()
                        if (null !== currentItem) {
                            currentItem.play()
                        }
                    }
                }

                YSpacingForColumn {
                    implicitHeight: 20
                }
            }
        }

        YQuizLearningTitleArea {
            id: id_title_area
            anchors.topMargin: - id_quiz_learning_view_flickable.contentY
            currentIndex: id_quiz_learning_view.currentIndex
            progressIndicator.totalCount: id_quiz_learning_view.count
            progressBarVisible: false
            listennigButtonVisible: (id_quiz_learning_view.count > 0)
                                    && (("word" === contentType)
                                        ? id_quiz_learning_view.currentItem.canPlayAudio
                                        : id_quiz_learning_view.currentItem.hasAudio)
            onCallBack: {
                stop()
                visible = false
                backButtonClicked()
                if ("xiaoxiang" === contentType) {
                    qmlGlobal.requestTouchReadingBookCover()
                }
            }
            onSpeekerCurrentFrameChanged: {
                if (-1 === id_quiz_learning_view.currentItem.currentPlayId) {
                    stopPlay()
                }
            }
        }

        YProgressIndicatorBase {
            id: id_progress_indicator
            anchors.centerIn: undefined
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 4
            currentIndex: id_quiz_learning_view.currentIndex
            totalCount: id_quiz_learning_view.count
        }
    }

    Component {
        id: id_quiz_learning_delegate_hanzi
        YQuizLearningDelegateHanZi {
            id: id_quiz_learning_delegate_hanzi_item
            currentItemPlayabled: id_quiz_learning_view.currentItemPlayabled
            onCurrentPlayIdChanged: {
                if (-1 !== currentPlayId) {
                    id_title_area.play()
                } else {
                    id_title_area.stopPlay()
                }
            }
            Component.onCompleted: {
                id_title_area.validClicked.connect(function(){
                    if (id_quiz_learning_delegate_hanzi_item.visible) {
                        if (-1 === currentPlayId) {
                            id_quiz_learning_delegate_hanzi_item.play()
                        } else {
                            id_quiz_learning_delegate_hanzi_item.stop()
                        }
                    }
                })
            }
        }
    }

    Component {
        id: id_quiz_learning_delegate_pinyin
        YQuizLearningDelegatePinYin {
            id: id_quiz_learning_delegate_pinyin_item
            currentItemPlayabled: id_quiz_learning_view.currentItemPlayabled
            onCurrentPlayIdChanged: {
                if (-1 !== currentPlayId) {
                    id_title_area.play()
                } else {
                    id_title_area.stopPlay()
                }
            }
            Component.onCompleted: {
                id_title_area.validClicked.connect(function(){
                    if (id_quiz_learning_delegate_pinyin_item.visible) {
                        if (-1 === currentPlayId) {
                            id_quiz_learning_delegate_pinyin_item.play()
                        } else {
                            id_quiz_learning_delegate_pinyin_item.stop()
                        }
                    }
                })
            }
        }
    }

    Component {
        id: id_quiz_learning_delegate_word
        YQuizLearningDelegateWord {
            id: id_quiz_learning_delegate_word_item
            currentItemPlayabled: id_quiz_learning_view.currentItemPlayabled
            onCurrentPlayIdChanged: {
                if (-1 !== currentPlayId) {
                    id_title_area.play()
                } else {
                    id_title_area.stopPlay()
                }
            }
            Component.onCompleted: {
                id_title_area.validClicked.connect(function(){
                    if (id_quiz_learning_delegate_word_item.visible) {
                        if (-1 === currentPlayId) {
                            id_quiz_learning_delegate_word_item.play()
                        } else {
                            id_quiz_learning_delegate_word_item.stop()
                        }
                    }
                })
            }
        }
    }

    Component {
        id: id_quiz_learning_delegate_xiaoxiang
        YQuizLearningDelegateXiaoXiang {
            id: id_quiz_learning_delegate_xiaoxiang_item
            currentItemPlayabled: id_quiz_learning_view.currentItemPlayabled
            onCurrentPlayIdChanged: {
                if (-1 !== currentPlayId) {
                    id_title_area.play()
                } else {
                    id_title_area.stopPlay()
                }
            }
            Component.onCompleted: {
                id_title_area.validClicked.connect(function(){
                    if (id_quiz_learning_delegate_xiaoxiang_item.visible) {
                        if (-1 === currentPlayId) {
                            id_quiz_learning_delegate_xiaoxiang_item.play()
                        } else {
                            id_quiz_learning_delegate_xiaoxiang_item.stop()
                        }
                    }
                })
                id_quiz_learning_delegate_xiaoxiang_item.startPlayGame.connect(function() {
                    stop()
                    visible = false
                    backButtonClicked()
                    const coverPracticeData = JSON.parse(readingBookCoverManager.coverPractice)
                    if (coverPracticeData.cover_practice.length > 0) {
                        coverPracticeData.cover_practice.forEach(function(practiceItem) {
                            if ("玩游戏" === practiceItem.practice_name) {
                                readingBookQuizManager.xiaoxiangPlayGames(practiceItem.practice_key)
                                return
                            }
                        })
                    }
                })
            }
        }
    }

    property QtObject wordCardReviewGuide: null

    Component.onCompleted: {
        if (settingManager.isFirstWordCardReview) {
            wordCardReviewGuide
                    = id_word_card_review_guide_component.createObject(
                        id_quiz_learning)
        }
        delayBuild()
    }

    Component {
        id: id_word_card_review_guide_component
        YQuizLearningReviewGuide {
            onClosed: {
                resetCurrentIndex()
                if (null !== wordCardReviewGuide) {
                    wordCardReviewGuide.destroy()
                    wordCardReviewGuide = null
                }
            }
        }
    }

    Component {
        id: id_start_to_answer_questions_component
        YQuizLearningStartToAnswerQuestions {
            onBackButtonClicked: {
                id_title_area.callBack()
            }
        }
    }

    property QtObject quizLearningStartToAnswerQuestions: null
    property int incubatorCreateCount: 0

    function delayBuild() {
        const incubator = id_start_to_answer_questions_component.incubateObject(
                                  id_quiz_learning);
        if (incubator.status !== Component.Ready) {
            incubator.onStatusChanged = function(status) {
                if (status === Component.Ready) {
                    if (0 === --incubatorCreateCount) {
                        quizLearningStartToAnswerQuestions = incubator.object
                    } else {
                        incubator.object.destroy()
                    }
                }
            }
            ++incubatorCreateCount
        } else {
            quizLearningStartToAnswerQuestions = incubator.object
        }
    }

    function startToAnswer() {
        if (null !== quizLearningStartToAnswerQuestions) {
            quizLearningStartToAnswerQuestions.delayPlay()
        }
    }

    YQuizLearningLoadingTips {
        id: id_quiz_learning_loading_tips
    }
}

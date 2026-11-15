import QtQuick 2.12
import com.youdao.pen 1.0

import BaseQml 1.0
import "../timers"

// 互动答题入口

YBackgroundIgnoreMouseEvent {
    id: id_interactive_quizzes

    signal backButtonClicked()
    signal callScorePageClicked()

    property bool isBrowseMode: false
    property bool selectabled: true
    property int correctCount: 0

    state: isBrowseMode ? "browse" : "answer"
    anchors.fill: parent
    visible: false

    function stop() {
        qmlGlobal.stopAllAnimationMusic()
    }

    function resetForTryAgain() {
        stop()
        id_result_view.lastSelectedIndex = 0
        correctCount = 0
        id_title_area.progressIndicator.reset()
        id_interactive_quizzes_pathview.model = null
        id_interactive_quizzes_pathview.model = id_delay_play_timer.quizText
        YTimers.delayCall(120, resetCurrentIndex)
        isBrowseMode = false
    }

    function resetCurrentIndex() {
        id_interactive_quizzes_pathview.currentIndex = -1
        id_interactive_quizzes_pathview.currentIndex = 0
        if (null === interactiveQuizzesReviewGuide) {
            id_interactive_quizzes_pathview.playCurrentItem()
        }
        console.warn("YInteractiveQuizzesIndex.qml===resetCurrentIndex===called")
    }

    function delayPlay() {
        console.warn("YInteractiveQuizzesIndex.qml===readingBookQuizManager.quizText:\n",
                     readingBookQuizManager.quizText, "\n")
        visible = true
        if (settingManager.isFirstEnterQuizPage) {
            settingManager.setNotIsFirstEnterQuizPage()
            interactiveQuizzesScrollGuide.maskSource = id_mask_source
            interactiveQuizzesScrollGuide.play()
        } else {
            id_delay_play_timer.restart()
        }
        id_delay_play_timer.quizText = readingBookQuizManager.quizText
    }

    function positionViewToBeginning() {
        id_quiz_view_flickable.contentY = 0
    }

    YTimer {
        id: id_delay_play_timer
        interval: 120
        property var quizText: null
        onTriggered: {
            resetCurrentIndex()
        }
        objectName: "YInteractiveQuizzesIndex.qml_id_delay_play_timer"
    }

    YBackground {
        id: id_mask_source
        anchors.fill: parent
        color: YColors.touchReadingBg

        Flickable {
            id: id_quiz_view_flickable

            anchors.fill: parent
            anchors.leftMargin: 70
            anchors.rightMargin: 70
            contentHeight: id_column.height

            property bool isFirstQuestion: true
            readonly property bool canFlick: contentHeight > height
            readonly property bool flickTipVisible: canFlick && (0 === contentY)
            onFlickTipVisibleChanged: {
                if (!flickTipVisible && isFirstQuestion){
                    isFirstQuestion = false
                }
            }

            Column {
                id: id_column
                spacing: 0
                anchors.left: parent.left
                anchors.right: parent.right

                YSpacingForColumn {
                    implicitHeight: 76
                }

                PathView {
                    id: id_interactive_quizzes_pathview
                    anchors.left: parent.left
                    anchors.right: parent.right
                    height: currentItem.height
                    preferredHighlightBegin: 0.5
                    preferredHighlightEnd: 0.5
                    highlightRangeMode: PathView.StrictlyEnforceRange
                    snapMode: PathView.SnapOneItem
                    pathItemCount: 1
                    interactive: isBrowseMode
                    movementDirection: PathView.Positive
                    path: Path {
                        startX: 0
                        startY: id_interactive_quizzes_pathview.height/2;
                        PathLine {
                            x: id_interactive_quizzes_pathview.width
                            y: id_interactive_quizzes_pathview.height/2
                        }
                    }
                    model: readingBookQuizManager.quizText
                    delegate: id_interactive_quizzes_delegate
                    readonly property bool currentItemPlayabled: (!settingManager.isFirstFollowReview
                                                                  && (null === interactiveQuizzesReviewGuide))
                                                                 && (!settingManager.isFirstEnterQuizPage
                                                                     && (null === interactiveQuizzesScrollGuide))
                    onCurrentIndexChanged: {
                        if (!isBrowseMode || (null === interactiveQuizzesReviewGuide)) {
                            playCurrentItem()
                        }
                    }

                    function nextQuestion() {
                        if (!isBrowseMode) {
                            if (id_result_view.lastSelectedIndex + 1 < count) {
                                currentIndex = id_result_view.lastSelectedIndex + 1
                            } else {
                                console.warn("YInteractiveQuizzesIndex.qml===play(correctCount, totalCount): ", correctCount, count)
                                id_title_area.visible = false
                                stop()
                                id_result_item.play(correctCount, count)
                            }
                        }
                    }

                    function playCurrentItem() {
                        id_interactive_quizzes.stop()
                        positionViewToBeginning()
                        if (null !== currentItem) {
                            console.log("YInteractiveQuizzesIndex.qml===currentIndex: ", currentIndex)
                            if (isBrowseMode) {
                                const resultObject = id_title_area.progressIndicator.getResultObject(currentIndex)
                                currentItem.answerResult = resultObject.result
                                currentItem.selectedAnswerContentGroup = resultObject.selectedAnswerContentGroup
                            }
                            currentItem.play()
                        }
                    }
                }

                YSpacingForColumn {
                    implicitHeight: 24
                }
            }
        }

        YInteractiveQuizzesIndexTitleArea {
            id: id_title_area
            anchors.topMargin: - id_quiz_view_flickable.contentY
            isBrowseMode: id_interactive_quizzes.isBrowseMode
            currentIndex: id_interactive_quizzes_pathview.currentIndex
            listennigButtonVisible: !id_interactive_quizzes_pathview.currentItem.isFiveType
            progressIndicator.totalCount: readingBookQuizManager.quizCount
            onCallBack: {
                if (isBrowseMode) {
                    stop()
                    callScorePageClicked()
                } else {
                    stop()
                    qmlGlobal.requestTouchReadingBookCover()
                    backButtonClicked()
                }
            }
            onSpeekerCurrentFrameChanged: {
                if (-1 === id_interactive_quizzes_pathview.currentItem.currentPlayId) {
                    stopPlay()
                }
            }
        }

        YLoader {
            anchors.bottom: parent.bottom
            active: id_quiz_view_flickable.isFirstQuestion
                    && (null === interactiveQuizzesScrollGuide)
                    && id_quiz_view_flickable.flickTipVisible
            sourceComponent: YInteractiveQuizzesScrollUpTips {
            }
        }
    }

    Component {
        id: id_interactive_quizzes_delegate
        YInteractiveQuizzesDelegate {
            id: id_interactive_quizzes_item
            selectabled: id_interactive_quizzes.selectabled
            isBrowseMode: id_interactive_quizzes.isBrowseMode
            currentItemPlayabled: id_interactive_quizzes_pathview.currentItemPlayabled
            onSelectedResult: {
                id_title_area.progressIndicator.putResult(index, answerResult, selectedAnswerContentGroup)
                id_result_view.lastSelectedIndex = index
                if ("y" === answerResult) {
                    correctCount += 1
                    id_result_view.requestRightTips()
                } else {
                    id_result_view.requestWrongTips()
                }
            }
            onCurrentPlayIdChanged: {
                if (-1 !== currentPlayId) {
                    id_title_area.play()
                } else {
                    id_title_area.stopPlay()
                }
            }
            Component.onCompleted: {
                id_title_area.validClicked.connect(function(){
                    if (visible) {
                        if (-1 === currentPlayId) {
                            id_interactive_quizzes_item.play()
                        } else {
                            id_interactive_quizzes_item.stop(hasGuideAudio)
                        }
                    }
                })
            }
        }
    }

    states: [
        State {
            name: "answer"
            PropertyChanges { target: id_interactive_quizzes; selectabled: true }
        },
        State {
            name: "browse"
            PropertyChanges { target: id_interactive_quizzes; selectabled: false }
        }
    ]

    YInteractiveQuizzesResultView {
        id: id_result_view
        visible: !isBrowseMode
        onEndPlay: {
            id_interactive_quizzes_pathview.nextQuestion()
        }
    }

    YInteractiveQuizzesScorePageResultAnimation {
        id: id_result_item
        visible: false
        onBackButtonClicked: {
            visible = false
            id_title_area.visible = true
        }
        onCallTryAgain: {
            positionViewToBeginning()
            resetForTryAgain()
        }
        onCallBrowse: {
            positionViewToBeginning()
            if (settingManager.isFirstFollowReview) {
                settingManager.setNotIsFirstFollowReview()
                interactiveQuizzesReviewGuide.play()
            } else {
                id_interactive_quizzes_pathview.currentIndex = 0
            }
            isBrowseMode = true
            resetCurrentIndex()
            id_interactive_quizzes.callScorePageClicked.connect(function() {
                id_title_area.visible = false
                id_result_item.visible = true
            })
            id_result_item.visible = false
            id_title_area.visible = true
        }
    }

    property QtObject interactiveQuizzesReviewGuide: null
    property QtObject interactiveQuizzesScrollGuide: null

    Component.onCompleted: {
        if (settingManager.isFirstEnterQuizPage) {
            interactiveQuizzesScrollGuide
                    = id_interactive_quizzes_scroll_guide.createObject(
                        id_interactive_quizzes)
        }
        if (settingManager.isFirstFollowReview) {
            interactiveQuizzesReviewGuide
                    = id_interactive_quizzes_review_guide.createObject(
                        id_interactive_quizzes)
        }
    }

    Component {
        id: id_interactive_quizzes_scroll_guide
        YInteractiveQuizzesScrollGuide {
            onClosed: {
                id_delay_play_timer.restart()
                if (null !== interactiveQuizzesScrollGuide) {
                    interactiveQuizzesScrollGuide.destroy()
                    interactiveQuizzesScrollGuide = null
                }
            }
        }
    }

    Component {
        id: id_interactive_quizzes_review_guide
        YInteractiveQuizzesReviewGuide {
            onClosed: {
                id_interactive_quizzes_pathview.playCurrentItem()
                if (null !== interactiveQuizzesReviewGuide) {
                    interactiveQuizzesReviewGuide.destroy()
                    interactiveQuizzesReviewGuide = null
                }
            }
        }
    }
}

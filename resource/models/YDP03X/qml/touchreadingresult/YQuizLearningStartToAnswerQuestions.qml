import QtQuick 2.12
import com.youdao.pen 1.0

import BaseQml 1.0
import "../timers"

// 互动学习 进入闯关

YBackgroundIgnoreMouseEvent {
    id: id_start_to_answer_questions

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
        id_result_view.lastSelectedIndex = 0
        correctCount = 0
        id_title_area.progressIndicator.reset()
        id_start_to_answer_questions_pathview.model = null
        console.warn("YQuizLearningStartToAnswerQuestions.qml===interactiveLearningManager.practiceList: \n",
                     interactiveLearningManager.practiceList)
        id_start_to_answer_questions_pathview.model = JSON.parse(interactiveLearningManager.practiceList)

        resetCurrentIndex()
        isBrowseMode = false
    }

    function resetCurrentIndex() {
         id_start_to_answer_questions_pathview.currentIndex = -1
        id_start_to_answer_questions_pathview.currentIndex = 0
        id_start_to_answer_questions_pathview.playCurrentItem()
        console.warn("YQuizLearningStartToAnswerQuestions.qml===resetCurrentIndex===called")
    }

    function delayPlay() {
        resetForTryAgain()
        visible = true
        YTimers.delayCall(120, resetCurrentIndex)
    }

    function positionViewToBeginning() {
        id_quiz_view_flickable.contentY = 0
    }

    YBackground {
        id: id_mask_source
        anchors.fill: parent
        color: parent.color

        Flickable {
            id: id_quiz_view_flickable

            anchors.fill: parent
            anchors.leftMargin: 16
            anchors.rightMargin: 16
            contentHeight: id_column.height

            Column {
                id: id_column
                spacing: 0
                anchors.left: parent.left
                anchors.right: parent.right

                YSpacingForColumn {
                    implicitHeight: 50
                }

                PathView {
                    id: id_start_to_answer_questions_pathview
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
                        startY: id_start_to_answer_questions_pathview.height/2;
                        PathLine {
                            x: id_start_to_answer_questions_pathview.width
                            y: id_start_to_answer_questions_pathview.height/2
                        }
                    }
                    model: readingBookQuizManager.quizText
                    delegate: id_start_to_answer_questions_delegate
                    onCurrentIndexChanged: {
                        playCurrentItem()
                    }

                    function nextQuestion() {
                        if (!isBrowseMode) {
                            if (id_result_view.lastSelectedIndex + 1 < count) {
                                currentIndex = id_result_view.lastSelectedIndex + 1
                            } else {
                                console.warn("YQuizLearningStartToAnswerQuestions.qml===play(correctCount, totalCount): ", correctCount, count)
                                id_title_area.visible = false
                                stop()
                                id_result_item.play(correctCount, count)
                            }
                        }
                    }

                    function playCurrentItem() {
                        id_start_to_answer_questions.stop()
                        positionViewToBeginning()
                        if (null !== currentItem) {
                            console.warn("YQuizLearningStartToAnswerQuestions.qml===currentIndex: ", currentIndex)
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
            isBrowseMode: id_start_to_answer_questions.isBrowseMode
            currentIndex: id_start_to_answer_questions_pathview.currentIndex
            listennigButtonVisible: (id_start_to_answer_questions_pathview.count > 0)
                                    && (isBrowseMode ? id_start_to_answer_questions_pathview.currentItem.hasAudio
                                                     : (id_start_to_answer_questions_pathview.currentItem.hasAudio
                                                        || id_start_to_answer_questions_pathview.currentItem.hasGuideAudio))
            progressIndicator.totalCount: id_start_to_answer_questions_pathview.count
            onCallBack: {
                if (isBrowseMode) {
                    stop()
                    callScorePageClicked()
                } else {
                    stop()
                    backButtonClicked()
                }
            }
            onSpeekerCurrentFrameChanged: {
                if (-1 === id_start_to_answer_questions_pathview.currentItem.currentPlayId) {
                    stopPlay()
                }
            }

            property bool titleStretched: false

            YLoader {
                active: id_title_area.titleStretched
                anchors.top: parent.top
                sourceComponent: YImage {
                    sourceSize: Qt.size(320, 46)
                    imageName: "touchreading/titlebar_mask_bg"
                    YMouseArea {
                        anchors.fill: parent
                        onClicked: {
                            id_title_area.titleStretched = false
                        }
                    }
                }
            }

            TextMetrics {
                id: id_text_metrics
                font: id_title_content.font
                elide: YTextMedium.ElideRight
                elideWidth: id_title_content.width
                readonly property string currentTitleContent: (id_start_to_answer_questions_pathview.count > 0)
                                                              ? id_start_to_answer_questions_pathview.currentItem.questionText : ""
                text: currentTitleContent
            }

            YTextMedium {
                id: id_title_content
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: id_title_area.titleStretched
                              ? parent.left : id_title_area.progressIndicatorBackground.right
                anchors.leftMargin: 10
                anchors.right: (!id_title_area.titleStretched && id_title_area.listennigButton.visible)
                               ? id_title_area.listennigButton.left : parent.right
                anchors.rightMargin: 10
                height: paintedHeight
                horizontalAlignment: id_title_area.titleStretched
                                     ? YTextMedium.AlignHCenter : YTextMedium.AlignRight
                text: id_text_metrics.elidedText
                font.pixelSize: 28 /*{
                    if (id_text_metrics.currentTitleContent.length <= 11) {
                        return 24
                    } else if (id_text_metrics.currentTitleContent.length <= 15) {
                        return 20
                    }
                    return 18
                }*/

                YMouseArea {
                    anchors.fill: parent
                    enabled: id_text_metrics.elidedText !== id_text_metrics.currentTitleContent
                    onClicked: {
                        id_title_area.titleStretched = true
                    }
                }
            }
        }
    }

    Component {
        id: id_start_to_answer_questions_delegate
        YQuizLearningStartToAnswerQuestionsDelegate {
            id: id_start_to_answer_questions_item
            selectabled: id_start_to_answer_questions.selectabled
            isBrowseMode: id_start_to_answer_questions.isBrowseMode
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
                    if (id_start_to_answer_questions_item.visible) {
                        if (-1 === currentPlayId) {
                            id_start_to_answer_questions_item.play()
                        } else {
                            id_start_to_answer_questions_item.stop(true)
                        }
                    }
                })
            }
        }
    }

    states: [
        State {
            name: "answer"
            PropertyChanges { target: id_start_to_answer_questions; selectabled: true }
        },
        State {
            name: "browse"
            PropertyChanges { target: id_start_to_answer_questions; selectabled: false }
        }
    ]

    YInteractiveQuizzesResultView {
        id: id_result_view
        visible: !isBrowseMode
        onEndPlay: {
            id_start_to_answer_questions_pathview.nextQuestion()
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
            id_start_to_answer_questions_pathview.currentIndex = 0
            isBrowseMode = true
            resetCurrentIndex()
            id_start_to_answer_questions.callScorePageClicked.connect(function() {
                id_title_area.visible = false
                id_result_item.visible = true
            })
            id_result_item.visible = false
            id_title_area.visible = true
        }
        closeButtonCallback: function() {
            id_start_to_answer_questions.backButtonClicked()
        }
    }
}

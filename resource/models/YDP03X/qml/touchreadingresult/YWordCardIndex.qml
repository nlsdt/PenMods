import QtQuick 2.12
import com.youdao.pen 1.0

import BaseQml 1.0
import "../timers"

YBackgroundIgnoreMouseEvent {
    id: id_word_card

    signal backButtonClicked()
    signal callScorePageClicked()

    property bool selectabled: true

    anchors.fill: parent
    visible: false

    function play() {
        console.warn("YInteractiveQuizzesIndex.qml===play===readingBookContentArrayManager.contentArray:\n\n\n",
                     readingBookContentArrayManager.contentArray,
                     "\n\n\n")
        id_word_card_pathview.model = null
        id_word_card_pathview.model = readingBookContentArrayManager.contentArray
        visible = true
        if (settingManager.isFirstWordCardReview
                && (readingBookContentArrayManager.contentArray.length > 1)) {
            settingManager.setNotIsFirstWordCardReview()
            wordCardReviewGuide.maskSource = id_mask_source
            wordCardReviewGuide.play()
        } else {
            YTimers.delayCall(120, resetCurrentIndex)
        }
    }

    function resetCurrentIndex() {
        id_word_card_pathview.currentIndex = -1
        id_word_card_pathview.currentIndex = 0
        id_word_card_pathview.playCurrentItem()
    }

    function stop() {
        qmlGlobal.stopAllAnimationMusic()
    }

    function positionViewToBeginning() {
        id_word_card_view_flickable.contentY = 0
    }

    YBackground {
        id: id_mask_source
        anchors.fill: parent
        color: parent.color

        Flickable {
            id: id_word_card_view_flickable

            anchors.fill: parent
            anchors.leftMargin: 70
            anchors.rightMargin: 70
            contentHeight: id_column.height

            Column {
                id: id_column
                spacing: 0
                anchors.left: parent.left
                anchors.right: parent.right

                YSpacingForColumn {
                    implicitHeight: 76
                }

                YHorizontalListView {
                    id: id_word_card_pathview
                    anchors.left: parent.left
                    anchors.right: parent.right
                    height: currentItem.height
                    preferredHighlightBegin: 0.5
                    preferredHighlightEnd: 0.5
                    highlightRangeMode: ListView.StrictlyEnforceRange
                    snapMode: ListView.SnapOneItem
                    boundsMovement: ListView.StopAtBounds
                    clip: false
                    interactive: count > 1
                    delegate: id_word_card_delegate
                    onCurrentIndexChanged: {
                        if (null === wordCardReviewGuide) {
                            playCurrentItem()
                        }
                    }
                    readonly property bool currentItemPlayabled: !settingManager.isFirstWordCardReview && (null === wordCardReviewGuide)

                    function playCurrentItem() {
                        id_word_card.stop()
                        positionViewToBeginning()
                        if (null !== currentItem) {
                            currentItem.play()
                        }
                    }
                }

                YSpacingForColumn {
                    implicitHeight: 24
                }
            }
        }

        YWordCardIndexTitleArea {
            id: id_title_area
            anchors.topMargin: - id_word_card_view_flickable.contentY
            currentIndex: id_word_card_pathview.currentIndex
            listennigButtonVisible: (id_word_card_pathview.count > 0) && id_word_card_pathview.currentItem.hasAudio
            progressBarVisible: id_word_card_pathview.count > 1
            progressIndicator.totalCount: id_word_card_pathview.count
            onCallBack: {
                stop()
                visible = false
                backButtonClicked()
            }
            onSpeekerCurrentFrameChanged: {
                if (-1 === id_word_card_pathview.currentItem.currentPlayId) {
                    stopPlay()
                }
            }
        }
    }

    Component {
        id: id_word_card_delegate
        YWordCardDelegate {
            id: id_word_card_item
            currentItemPlayabled: id_word_card_pathview.currentItemPlayabled
            onCurrentPlayIdChanged: {
                if (-1 !== currentPlayId) {
                    id_title_area.play()
                } else {
                    id_title_area.stopPlay()
                }
            }
            Component.onCompleted: {
                id_title_area.validClicked.connect(function(){
                    if (id_word_card_item.visible) {
                        if (-1 === currentPlayId) {
                            id_word_card_item.play()
                        } else {
                            id_word_card_item.stop()
                        }
                    }
                })
            }
        }
    }

    property QtObject wordCardReviewGuide: null

    Component.onCompleted: {
        if (settingManager.isFirstWordCardReview
                && (readingBookContentArrayManager.contentArray.length > 1)) {
            const component = Qt.createComponent("YWordCardReviewGuide.qml")
            wordCardReviewGuide = component.createObject(id_word_card)
            wordCardReviewGuide.closed.connect(function(){
                id_word_card_pathview.playCurrentItem()
                if (null !== wordCardReviewGuide) {
                    wordCardReviewGuide.destroy()
                    wordCardReviewGuide = null
                }
            })
        }
    }
}

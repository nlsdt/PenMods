import QtQuick 2.12
import com.youdao.pen 1.0

import BaseQml 1.0

YBackgroundIgnoreMouseEvent {
    id: id_touch_reading_follow_page

    anchors.fill: parent

    property bool playbackabled: false

    property int closeMicCount: 0

    function play() {
        id_jumping_animation_text_view.returnToBounds()
        id_jumping_animation_text_view.visible = true
        if (null !== touchReadingFollowPageGuide) {
            settingManager.setNotIsFirstFollowReading()
            touchReadingFollowPageGuide.maskSource = id_mask_source
            touchReadingFollowPageGuide.play()
        } else {
            doPlay()
        }
    }

    function doPlay() {
        readingBookReadingManager.playAudio()
    }

    signal backButtonClicked()

    YBackground {
        id: id_mask_source
        anchors.fill: parent
        color: YColors.touchReadingBg

        YJumpingAnimationTextView {
            id: id_jumping_animation_text_view
            anchors.fill: parent
            anchors.leftMargin: 70
            anchors.rightMargin: 120
            readingBookType: YEnum.RBT_Follow
            visible: false
            isFollowing: !playbackabled
            interactive: (YEnum.FPS_Following !== readingBookReadingManager.followPageState || id_follow_mic.visible)
            onPlayStarIncrease: {
                id_star_count_indicator.playStarIncrease()
            }
            onFollowMoveItem: {
                if (id_mic_container.enabled)
                    posYAtItem(index)
            }
        }

        YTouchReadingFollowPageBackButtonArea {
            onClicked: {
                qmlGlobal.stopAllAnimationMusic()
                readingBookReadingManager.stopAudio()
                playbackabled = false
                backButtonClicked()
                id_mic_container.closeMic()
            }
        }

        YTouchReadingFollowPageStarCount {
            id: id_star_count_indicator
            text: (readingBookReadingManager.historicalFollowStars
                   + readingBookReadingManager.followStars).padZero(5)

            // private:
            function resultPageCreateFinished(pageObject) {
                pageObject.endPlay.connect(function() {
//                    readingBookReadingManager.resetFollow()
                    if ((YEnum.PageIndex.Reading === qmlGlobal.currentPageIndex)
                            && (null !== touchReadingFollowPlayBackGuide)) {
                        settingManager.setNotIsFirstFollowReplay()
                        touchReadingFollowPlayBackGuide.maskSource = id_mask_source
                        touchReadingFollowPlayBackGuide.play()
                    } else {
                       id_star_count_indicator.doAfterResultTipsShow()
                    }
                    logManager.sendHttpLog("action=touchreading_txt_readfollow_reflect_broadcasting")
                })
                pageObject.play()
            }

            function doAfterResultTipsShow() {
                qmlGlobal.requestStartAutoScreenOff()
                if (isBookMetalGet) {
                    showBookMetal()
                } else {
                    playbackabled = true
                    id_jumping_animation_text_view.returnToBounds()
                }
            }
        }

        Rectangle {
            implicitWidth: 70
            implicitHeight: id_translate_button.visible
                            && id_playback_button.visible ? 148 : 70
            anchors.right: parent.right
            anchors.rightMargin: 8
            anchors.bottom: parent.bottom
            anchors.bottomMargin: id_translate_button.visible
                                  && id_playback_button.visible ? 8 : 86
            color: playbackabled ? "#262752" : YColors.transparent
            radius: width/2

            YTouchReadingResultTranslateButton {
                id: id_translate_button
                visible: !readingBookReadingManager.translationDataEmpty
                         && !id_follow_mic.running
                         && (!playbackabled || id_playback_button.isStopped)
            }

            YPlayBackButton {
                id: id_playback_button
                visible: playbackabled
            }
        }

        YBackButtonBase {
            id: id_mic_container
            enabled: false
            onTriggered: {
                id_mic_container.enabled = false
                id_delay_enabled_timer.stop()
                closeMic()
            }
            width: 140
            height: 150
            anchors.right: parent.right
            anchors.bottom: parent.bottom

            function closeMic() {
                id_mic_container.enabled = false
                id_check_mic_hidden_timer.restart()
                id_follow_mic.runExit()
                ++closeMicCount
                Qt.callLater(readingBookReadingManager.stopFollow)
            }

            YFollowMicTip {
                id: id_follow_mic
                visible: false
                onExitAnimatedImagePlayEnd: {
                    id_follow_mic.stopPlay()
                    id_follow_mic.visible = false
                }
            }

            YTimer {
                id: id_check_mic_hidden_timer
                interval: 1200
                onTriggered: {
                    if (id_follow_mic.visible) {
                        id_follow_mic.stopPlay()
                        id_follow_mic.visible = false
                    }
                }
                objectName: "YTouchReadingFollowPage.qml_id_check_mic_hidden_timer"
            }

            YTimer {
                id: id_delay_enabled_timer
                interval: 2400
                onTriggered: {
                    id_mic_container.enabled = true
                }
                objectName: "YTouchReadingFollowPage.qml_id_delay_enabled_timer"
            }

            function showMic() {
                id_check_mic_hidden_timer.stop()
                id_mic_container.enabled = false
                id_jumping_animation_text_view.updateContentYBySentenceIndex(
                            readingBookReadingManager.activeSentenceIndex)
                readingBookReadingManager.startFollow()
                id_follow_mic.visible = true
                id_follow_mic.play()
                id_delay_enabled_timer.restart()
                console.warn("YTouchReadingFollowPage.qml===showMic()===called")
            }
            objectName: "YTouchReadingFollowPage.qml_id_mic_container"
        }

        YTouchReadingFollowResultLoader {
            id: id_touch_reading_follow_result_loader
            onResultShowFinished: {
                if (YEnum.FPS_FollowStop === readingBookReadingManager.followPageState) {
                    showResult()
                } else {
                    readingBookReadingManager.playAudio()
                }
            }

            function updateShow(score) {
                if (closeMicCount > 0) {
                    if (score >= 80) {
                        show(YEnum.TRFRI_Excellent)
                    } else if (score >= 60) {
                        show(YEnum.TRFRI_Great)
                    } else {
                        show(YEnum.TRFRI_ComeOn)
                    }
                }
            }
        }
    }

    property int incubatorCreateCount: 0
    function showResult() {
        const component = Qt.createComponent("YFollowMattiReadingFinishedTips.qml");
        const incubator = component.incubateObject(id_touch_reading_follow_page);
        if (incubator.status !== Component.Ready) {
            incubator.onStatusChanged = function(status) {
                if (status === Component.Ready) {
                    if (0 === --incubatorCreateCount) {
                        id_star_count_indicator.resultPageCreateFinished(incubator.object)
                    } else {
                        incubator.object.destroy()
                    }
                }
            }
            ++incubatorCreateCount
        } else {
            id_star_count_indicator.resultPageCreateFinished(incubator.object)
        }
    }

    Connections {
        target: readingBookReadingManager
        ignoreUnknownSignals: true
        enabled: 0 === YUtils.currentPopId.length
        function onAudioPlayStateChanged() {
            if (YEnum.FPS_Following === readingBookReadingManager.followPageState) {
                if (YEnum.PAUSED === readingBookReadingManager.audioPlayState ||
                        YEnum.STOPPED === readingBookReadingManager.audioPlayState) {
                    console.log("seven:onAudioPlayStateChanged:0:")
//                    id_mic_container.showMic()
                    //读完跟读内容后有一段时间为4秒的背景音乐,所以等待背景音乐读完在启动跟读
                    id_count_down.start()
                }
            }
        }
        function onActiveSentenceIndexChanged() {
            if (YEnum.FPS_Playback === readingBookReadingManager.followPageState) {
                id_jumping_animation_text_view.updateContentYBySentenceIndex(
                            readingBookReadingManager.activeSentenceIndex)
            }
        }
        function onFollowStateChanged() {
            if (YEnum.FollowStateEnd === readingBookReadingManager.followState) {
                id_mic_container.closeMic()
            }
        }
        function onFollowScoreChanged() {
            console.warn("YTouchReadingFollowPage.qml===onFollowScoreChanged===", readingBookReadingManager.followScore)
            id_touch_reading_follow_result_loader.updateShow(
                        readingBookReadingManager.followScore)
        }
    }

    Component {
        id: id_first_follow_tip_component
        YTouchReadingFollowPageGuide {
            onClosed: {
                doPlay()
                if (null !== touchReadingFollowPageGuide) {
                    touchReadingFollowPageGuide.destroy()
                    touchReadingFollowPageGuide = null
                }
            }
        }
    }

    Component {
        id: id_first_play_back_tip_component
        YTouchReadingFollowPlayBackGuide {
            onClosed: {
                id_star_count_indicator.doAfterResultTipsShow()
                if (null !== touchReadingFollowPlayBackGuide) {
                    touchReadingFollowPlayBackGuide.destroy()
                    touchReadingFollowPlayBackGuide = null
                }
            }
        }
    }

    property QtObject touchReadingFollowPageGuide: null
    property QtObject touchReadingFollowPlayBackGuide: null

    Component.onCompleted: {
        if (settingManager.isFirstFollowReading) {
            touchReadingFollowPageGuide = id_first_follow_tip_component.createObject(id_touch_reading_follow_page)
        }
        if (settingManager.isFirstFollowReplay) {
            touchReadingFollowPlayBackGuide = id_first_play_back_tip_component.createObject(id_touch_reading_follow_page)
        }
    }

    Timer {
        id:id_count_down;
        interval: 4000
        repeat: false
        onTriggered: {
//            backButtonClicked()
            id_mic_container.showMic()
        }
    }
}

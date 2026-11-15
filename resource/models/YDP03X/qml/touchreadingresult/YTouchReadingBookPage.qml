import QtQuick 2.12
import com.youdao.pen 1.0

import BaseQml 1.0
import "../timers"

YBackground {
    id: id_touch_reading_book_page
    anchors.fill: parent

    signal enterFollowPage()
    signal closeFollowPage()
    signal textReadingFinished()

    property bool pageEnabled: false
    property QtObject touchReadingEnterFollowSpeechGuide: null

    function play() {
        pageEnabled = true
        YTimers.delayCall(120, readingBookReadingManager.playAudio)
    }

    function enterFollow() {
        qmlGlobal.stopAllAnimationMusic()
        enterFollowPage()
        readingBookReadingManager.enterReading(YEnum.RBT_Follow)
        id_touch_reading_follow_page_loader.active = true
        pageEnabled = false
        logManager.sendHttpLog("action=touchreading_txt_readfollow_click")
    }

    function closeFollow() {
        readingBookReadingManager.enterReading(YEnum.RBT_Touch)
        id_jumping_animation_text_view.returnToBounds()
        pageEnabled = true
        closeFollowPage()
        id_touch_reading_follow_page_loader.active = false
    }

    YBackground {
        id: id_mask_source
        anchors.fill: parent
        color: YColors.touchReadingBg

        YJumpingAnimationTextView {
            id: id_jumping_animation_text_view
            anchors.fill: parent
            anchors.leftMargin: 70
            anchors.rightMargin: readingBookReadingManager.translationDataEmpty && !readingBookReadingManager.isFollow ? 70 : 90
            visible: pageEnabled
            onTotalTextReadingFinished: {
                qmlGlobal.requestStartAutoScreenOff()
                YTimers.delayCall(120, textReadingFinished)
            }
        }

        Item {
            implicitWidth: 70
            implicitHeight: parent.height - 16
            anchors.right: parent.right
            anchors.rightMargin: 8
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 8

            YIconButton {
                id: id_follow_button
                implicitWidth: 70
                implicitHeight: 70
                mouseAreaMargins: -8
                radius: width/2
                color: "#333575"
                sourceSize: Qt.size(42, 42)
                imageName: "touchreading/mic_enter_page"
                onClicked: {
                    enterFollow()
                }
                visible: readingBookReadingManager.isFollow && pageEnabled
            }

            YTouchReadingResultTranslateButton {
                id: id_translate_button
                visible: !readingBookReadingManager.translationDataEmpty
                         && pageEnabled
            }
        }
    }

    Component {
        id: id_touch_reading_follow_page
        YTouchReadingFollowPage {
            onBackButtonClicked: {
                closeFollow()
            }
        }
    }

    Component {
        id: id_first_enter_follow_speech_tip_component
        YTouchReadingEnterFollowSpeechGuide {
            onClosed: {
                if (null !== touchReadingEnterFollowSpeechGuide) {
                    touchReadingEnterFollowSpeechGuide.destroy()
                    touchReadingEnterFollowSpeechGuide = null
                }
            }
        }
    }

    Connections {
        target: readingBookReadingManager
        ignoreUnknownSignals: true
        enabled: (0 === YUtils.currentPopId.length)
                 && (YEnum.RBT_Touch === readingBookReadingManager.readingBookType)
                 && readingBookReadingManager.isFollow
        function onAudioPlayStateChanged() {
            if (YEnum.PAUSED === readingBookReadingManager.audioPlayState ||
                    YEnum.STOPPED === readingBookReadingManager.audioPlayState) {
                if ((YEnum.PageIndex.Reading === qmlGlobal.currentPageIndex)
                        && (null !== touchReadingEnterFollowSpeechGuide)) {
                    settingManager.setNotIsFirstEnterFollowSpeech()
                    touchReadingEnterFollowSpeechGuide.maskSource = id_mask_source
                    touchReadingEnterFollowSpeechGuide.play()
                }
            }
        }
    }

    YLoader {
        id: id_touch_reading_follow_page_loader
        anchors.fill: parent
        sourceComponent: id_touch_reading_follow_page
        onLoaded: {
            item.play()
        }
    }

    Component.onCompleted: {
        if (settingManager.isFirstEnterFollowSpeech && readingBookReadingManager.isFollow) {
            touchReadingEnterFollowSpeechGuide
                    = id_first_enter_follow_speech_tip_component.createObject(
                        id_touch_reading_book_page)
        }
    }
}

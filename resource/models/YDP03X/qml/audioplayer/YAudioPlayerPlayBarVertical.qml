import QtQuick 2.12
import com.youdao.pen 1.0

import BaseQml 1.0
import "../i18n"

Item {
    implicitWidth: 112
    height: id_col.height
    anchors.right: parent.right
    anchors.top: parent.top
    anchors.topMargin: 14

    function setFollowEnabledState(enabledState) {
        id_mic_button.visible = false
        if (enabledState) {
            id_follow_button_delay_enabled_timer.restart()
        }
    }

    YTimer {
        id: id_follow_button_delay_enabled_timer
        interval: 720
        onTriggered: {
            id_mic_button.visible = Qt.binding(function(){
                return (mediaPlayerManager.mainLrc.length > 0)
                        && (YEnum.EN_US === qmlTranslator.guessTextLang(mediaPlayerManager.mainLrc))
            })
        }
        objectName: "YAudioPlayerPlayBarVertical.qml_id_follow_button_delay_enabled_timer"
    }

    Column {
        id: id_col
        width: 80
        anchors.right: parent.right
        anchors.rightMargin: 16
        spacing: 8

        YIconCheckedButton {
            id: id_store_button
            implicitWidth: 80
            implicitHeight: 70
            anchors.horizontalCenter: parent.horizontalCenter
            icon: "dict/fav"
            checkedIcon: "dict/fav-stored"
            mouseAreaMargins: -8
            visible:playerMode === YEnum.PM_StoreAudio
            checked:mediaPlayerManager.isSubcribed
            onClicked: {
                mediaPlayerManager.isSubcribed = checked
            }
            
            Connections {
                target: mediaPlayerManager
                ignoreUnknownSignals: true
                function onIsSubcribedChanged() {
                    id_store_button.rebindingCheck()
                }
            }

            function rebindingCheck() {
                checked = Qt.binding(function(){ return mediaPlayerManager.isSubcribed })
            }
        }

        YIconButton {
            id: id_mic_button
            implicitWidth: 80
            implicitHeight: 70
            anchors.horizontalCenter: parent.horizontalCenter
            sourceSize: Qt.size(44, 44)
            imageName: "audioplayer/mic"
            mouseAreaMargins: -8
            visible: false
            onValidClicked: {
                if (qmlGlobal.currentPageIndex === YEnum.PageIndex.TextBook) {
                    logManager.sendHttpLog("action=textbook_broadcast_readfollowing_click")
                }
                enterAudioPlayerFollow()
            }
        }

        YIconButton {
            id: id_repeat_sentence_button
            implicitWidth: 80
            implicitHeight: 70
            visible: playerMode !== YEnum.PM_Homework_Follow && mediaPlayerManager.hasLrc
            anchors.horizontalCenter: parent.horizontalCenter
            sourceSize: Qt.size(44, 44)
            imageName: id_play_bar.truncateAudioState == YEnum.TAS_Sentence ? "audioplayer/cancel_sentence" : "audioplayer/repeating_sentence"
            mouseAreaMargins: -8
            onValidClicked: {
                if (qmlGlobal.currentPageIndex === YEnum.PageIndex.TextBook) {
                    logManager.sendHttpLog("action=textbook_broadcast_repeat_click")
                }
                if (id_play_bar.truncateAudioState == YEnum.TAS_Sentence){
                    baseSignals.showToast(YTranslateText.textbookStopRepeatPlaySentence, YColors.grayButton)
                    id_play_bar.truncateAudioState = YEnum.TAS_STOP
                    mediaPlayerManager.closeRepeat()
                } else {
                    baseSignals.showToast(YTranslateText.textbookStartRepeatPlaySentence, YColors.grayButton)
                    id_play_bar.truncateAudioState = YEnum.TAS_Sentence
                    mediaPlayerManager.repeatSentence()
                }
            }
        }

        YIconButton {
            id: id_lrc_state_button
            implicitWidth: 80
            implicitHeight: 70
            anchors.horizontalCenter: parent.horizontalCenter
            sourceSize: Qt.size(44, 44)
			visible: playerMode !== YEnum.PM_StoreAudio
            imageName: {
                switch (lrcStateList[lrcStateIndex]) {
                case YEnum.LS_ORIGINAL:
                    return "audioplayer/original44"
                case YEnum.LS_TRANS:
                    return "audioplayer/trans44"
                case YEnum.LS_HIDE:
                    return "audioplayer/hide_lrc44"
                case YEnum.LS_BILINGUAL:
                default:
                    return "audioplayer/bilingual44"
                }
            }
            mouseAreaMargins: -8
            onValidClicked: {
                if (qmlGlobal.currentPageIndex === YEnum.PageIndex.TextBook) {
                    logManager.sendHttpLog("action=textbook_broadcast_trans_click")
                }
                lrcStateIndex = (lrcStateIndex + 1) % lrcStateList.length
                // TODO first time toast
                switch (lrcStateList[lrcStateIndex]) {
                case YEnum.LS_BILINGUAL:
                    baseSignals.showToast(YTranslateText.textbookSwitchLrcBilingual, YColors.grayButton)
                    break
                case YEnum.LS_ORIGINAL:
                    baseSignals.showToast(YTranslateText.textbookSwitchLrcOriginal, YColors.grayButton)
                    break
                case YEnum.LS_TRANS:
                    baseSignals.showToast(YTranslateText.textbookSwitchLrcTrans, YColors.grayButton)
                    break
                case YEnum.LS_HIDE:
                default:
                    break
                }
            }
        }
    }
}


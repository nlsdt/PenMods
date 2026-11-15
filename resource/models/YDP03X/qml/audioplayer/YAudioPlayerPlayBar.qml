import QtQuick 2.12
import com.youdao.pen 1.0

import BaseQml 1.0
import "../i18n"

YBackground {
    id: id_back_mask
    anchors.fill: parent
//    visible: opacity > 0
    state: "close"

    readonly property bool isPlaying: YEnum.PLAYING === mediaPlayerManager.playState
    property int truncateAudioState: YEnum.TAS_STOP

    property var audioSequenceIndex: 0
    property var audioSequences: []

    // 倍速设置
    property var rateSettingIndex: 0
    property var rateSettings: [
        {rate: 1.0, title: YTranslateText.prNormal},
        {rate: 0.8, title: YTranslateText.prSlow},
        {rate: 1.2, title: YTranslateText.prHigh},
        {rate: 1.5, title: YTranslateText.prFast}
    ]

    function update() {
        rateSettingIndex = getRateSettingIndex(mediaPlayerManager.playbackRate)
        audioSequenceIndex = getAudioSequenceIndex(settingManager.audioSequence)
    }

    function getAudioSequenceIndex(sequence) {
        if(YEnum.PageIndex.CooXmly == qmlGlobal.currentPageIndex) {
            audioSequences = [YEnum.AS_SINGLE_SHOT, YEnum.AS_SINGLE, YEnum.AS_ORDER]
        } else if (YEnum.PageIndex.TextBook != qmlGlobal.currentPageIndex) {
            audioSequences = [YEnum.AS_SINGLE_SHOT, YEnum.AS_SINGLE, YEnum.AS_ORDER, YEnum.AS_RANDOM]
        } else{
            audioSequences = [YEnum.AS_SINGLE_SHOT, YEnum.AS_ORDER]
        }

        for (let i = 0; i < audioSequences.length; ++i) {
            if (audioSequences[i] === sequence) {
                return i
            }
        }

        settingManager.audioSequence = YEnum.AS_SINGLE_SHOT
        return 0
    }

    function getRateSettingIndex(rate) {
        for (let i = 0; i < rateSettings.length; ++i) {
            if (Math.abs(rateSettings[i].rate - mediaPlayerManager.playbackRate) < 1e-2) {
                return i
            }
        }
        return 0
    }

    function show() {
        state = "show"
    }

    function close() {
        state = "close"
    }

    function callStopRepeat() {
        if (YEnum.TAS_STOP !== truncateAudioState) {
            mediaPlayerManager.closeRepeat()
            truncateAudioState = YEnum.TAS_STOP
        }
    }

    YMouseArea {
        id: id_play_bar
        anchors.left: parent.left
        anchors.right: parent.right
        implicitHeight: 92
        anchors.bottom: parent.bottom

        YImage {
            id: id_more_settings
            sourceSize: Qt.size(800, 84)
            imageName: "audioplayer/more_settings_bg"
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 2

            YImageButton {
                id: id_close_more_settings_button
                sourceSize: Qt.size(28, 28)
                anchors.left: parent.left
                anchors.leftMargin: 21
                anchors.verticalCenter: parent.verticalCenter
                imageName: "audioplayer/more_settings_close"
                mouseAreaMargins: -20
                onClicked: {
                    id_back_mask.close()
                }
            }

            Item {
                id: id_audio_player_container
                anchors {fill: parent; leftMargin: 70;}
                Row {
                    spacing: 120
                    anchors.horizontalCenter: parent.horizontalCenter
                    YAudioPlayerPlayBarSettingItem {
                        id: id_repeat_button
                        visible: playerMode === YEnum.PM_AudioPlayer
                        color: "transparent"
                        imageName: "audioplayer/repeating"
                        textItem.textFormat: YText.RichText
                        text: {
                            switch (truncateAudioState) {
                            case YEnum.TAS_ING:
                                return ("<font color=\"%1\">A</font> - B").arg(YColors.red)
                            case YEnum.TAS_PLAYING:
                                return YTranslateText.tasStop
                            case YEnum.TAS_Sentence:
                            case YEnum.TAS_STOP:
                            default:
                                return YTranslateText.tasPausing
                            }
                        }

                        onClicked: {
                            if (truncateAudioState == YEnum.TAS_STOP) {
                                truncateAudioState = YEnum.TAS_ING
                            } else {
                                truncateAudioState = (truncateAudioState + 1) % YEnum.TAS_COUNT
                            }

                            switch (truncateAudioState) {
                            case YEnum.TAS_ING:
                                mediaPlayerManager.startRepeat()
                                break
                            case YEnum.TAS_PLAYING:
                                mediaPlayerManager.endRepeat()
                                break
                            case YEnum.TAS_Sentence:
                            case YEnum.TAS_STOP:
                            default:
                                mediaPlayerManager.closeRepeat()
                                break
                            }
                        }
                    }
                    YAudioPlayerPlayBarSettingItem {
                        id: id_playback_rate_setting
                        visible: playerMode !== YEnum.PM_AudioPlayer
                        color: "transparent"
                        imageName: "audioplayer/rate%1".arg(rateSettings[rateSettingIndex].rate.toFixed(1))
                        sourceSize: Qt.size(36,36)
                        text: rateSettings[rateSettingIndex].title

                        onClicked: {
                            if (qmlGlobal.currentPageIndex === YEnum.PageIndex.TextBook) {
                                logManager.sendHttpLog("action=textbook_broadcast_more_speed_click")
                            }
                            rateSettingIndex = ((rateSettingIndex + 1) % rateSettings.length)
                            let tmpIsPlaying = isPlaying
                            mediaPlayerManager.playbackRate = rateSettings[rateSettingIndex].rate
                            if (tmpIsPlaying) {
                                mediaPlayerManager.onClickedPlay()
                            }
                        }
                    }
                    YAudioPlayerPlayBarSettingItem {
                        id: id_audio_sequence
                        color: "transparent"
                        imageName: {
                            switch (audioSequences[audioSequenceIndex]) {
                            case YEnum.AS_RANDOM:
                                return "audioplayer/s_random"
                            case YEnum.AS_SINGLE:
                                return "audioplayer/s_cycle"
                            case YEnum.AS_ORDER:
                                return "audioplayer/sequence"
                            case YEnum.AS_SINGLE_SHOT:
                            default:
                                return "audioplayer/s_stop_single"
                            }
                        }

                        text: {
                            switch (audioSequences[audioSequenceIndex]) {
                            case YEnum.AS_ORDER:
                                return YTranslateText.asOrder
                            case YEnum.AS_RANDOM:
                                return YTranslateText.asRandom
                            case YEnum.AS_SINGLE:
                                return YTranslateText.asSingle
                            case YEnum.AS_SINGLE_SHOT:
                            default:
                                return YTranslateText.asSingleShot
                            }
                        }

                        onClicked: {
                            if (qmlGlobal.currentPageIndex === YEnum.PageIndex.TextBook) {
                                logManager.sendHttpLog("action=textbook_broadcast_more_mode_click")
                            }
                            audioSequenceIndex = (audioSequenceIndex + 1 ) % audioSequences.length
                            settingManager.audioSequence = audioSequences[audioSequenceIndex]
                        }
                    }
                }
            }

        }

        YMouseArea {
            id: id_close_mousearea
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.top

            onClicked: {
                close()
            }
        }
    }

    states: [
        State {
            name: "close"
            PropertyChanges { target: id_play_bar; anchors.bottomMargin: -100 }
            PropertyChanges { target: id_close_mousearea; enabled: false }
            PropertyChanges { target: id_close_mousearea; implicitHeight: 0 }
            PropertyChanges { target: id_back_mask; opacity: 0 }
        },
        State {
            name: "show"
            PropertyChanges { target: id_play_bar; anchors.bottomMargin: 0 }
            PropertyChanges { target: id_close_mousearea; enabled: true }
            PropertyChanges { target: id_close_mousearea; implicitHeight: 160 }
            PropertyChanges { target: id_back_mask; opacity: 0.8 }
        }
    ]

    transitions: [
        Transition {
            to: "show"
            NumberAnimation { target: id_back_mask;  properties: "opacity"}
            NumberAnimation { target: id_play_bar; properties: "anchors.bottomMargin" }
        },
        Transition {
            to: "close"
            NumberAnimation { target: id_play_bar; properties: "anchors.bottomMargin" }
            NumberAnimation { target: id_back_mask;  properties: "opacity"}
        }
    ]

    Connections {
        target: mediaPlayerManager
        ignoreUnknownSignals: true
        enabled: id_play_bar.visible
        function onPlayStateChanged() {
            console.log("YAudioPlayerPlayBar.qml===onPlayStateChanged===",
                        mediaPlayerManager.playState)
            if (YEnum.STOPPED === mediaPlayerManager.playState) {
                truncateAudioState = YEnum.TAS_STOP
            }
        }
    }

    Component.onCompleted: {
        update()
    }

    objectName: "YAudioPlayerPlayBar.qml"
}


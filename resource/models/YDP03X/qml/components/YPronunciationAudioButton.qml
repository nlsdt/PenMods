import QtQuick 2.12
import com.youdao.pen 1.0

import BaseQml 1.0

YIconLabelButton {
    id: id_audio_play_icon_label_button

    implicitHeight: 52
    leftMargin: 24
    rightMargin: 24
    spacing: 12
    textColor: YColors.grayText
    textFormat: YText.RichText
    sourceSize: Qt.size(40, 40)
    icon: "dict/pronunciation-animation-2"

    readonly property bool playing: "playing" === id_playing_animation.state

    property int iconChangedAnimationDuration: 300

    property double playId: id_playing_animation.audioPlayId

    function play() {
        id_playing_animation.state = "playing"
        id_playing_animation.running = true
    }

    function stop() {
        id_playing_animation.state = "stop"
        id_playing_animation.running = false
    }

    // 播放单词、句子，句子不需要qsPhonetic及type，对于英文单词qsWord与qsPhonetic相同，type用于区分英音和美音
    // 对于汉字，qsWord是汉字本身，qsPhonetic是汉字的拼音以区分多音字
    function playWord(qsWord, qsLang, qsPhonetic, type) {
//        if (typeof qsPhonetic === undefined) {
//            qsPhonetic = ""
//        }
//        if (typeof type === undefined) {
//            type = 0
//        }
//        id_delay_check_end_timer.restart()
//        if (settingManager.isPepVersion) {
//            playId = soundCenter.playPepPrim(qsWord)
//            qmlGlobal.audioPlayId = playId
//        }
//        else {
//            playId = soundCenter.play(qsWord, qsLang, qsPhonetic, type)
//        }
        console.log("seven:soundCenter:",qsWord,qsLang)
        play()
        playId = soundCenter.play(qsWord, qsLang)
    }

    function playAudioFileData(fileData, beginPos, endPos) {
        id_delay_check_end_timer.restart()
        if (typeof fileData == "undefined") {
            playId = soundCenter.playFileData("/tmp/cursound")
        } else if (typeof beginPos == "undefined") {
            playId = soundCenter.playFileData(fileData)
        } else {
            playId = soundCenter.playMusicPiece(fileData, beginPos, endPos)
        }
    }

    SequentialAnimation {
        id: id_playing_animation
        loops: Animation.Infinite
        alwaysRunToEnd: true
        property string state: "stop"
        property double audioPlayId: 0
        PropertyAction {
            target: id_audio_play_icon_label_button
            property: "icon"
            value: "dict/pronunciation-animation-0"
        }
        PauseAnimation { duration: iconChangedAnimationDuration }
        PropertyAction {
            target: id_audio_play_icon_label_button
            property: "icon"
            value: "dict/pronunciation-animation-1"
        }
        PauseAnimation { duration: iconChangedAnimationDuration }
        PropertyAction {
            target: id_audio_play_icon_label_button
            property: "icon"
            value: "dict/pronunciation-animation-2"
        }
        PauseAnimation { duration: iconChangedAnimationDuration }
        onRunningChanged: {
            if (!running && ("stop" === id_playing_animation.state)) {
                id_audio_play_icon_label_button.icon = "dict/pronunciation-animation-2"
            }
        }
    }

    onValidClicked: {
        if (!playing) {
            play()
        } else if (soundCenter.currentPlayId === playId) {
            qmlGlobal.stopAllAnimationMusic()
        }
    }

    onVisibleChanged: {
        if(!visible) {
            stop()
        }
    }

    YTimer {
        id: id_delay_check_end_timer
        interval: 600
        objectName: "YAudioPlayButton.qml_id_delay_check_end_timer"
    }

    Connections {
        target: soundCenter
        ignoreUnknownSignals: true
        enabled: id_audio_play_icon_label_button.visible
        function onEnd(seq) {
            if (id_audio_play_icon_label_button.playing
                    && !id_delay_check_end_timer.running
                    && (seq == playId)) {
                stop()
            }
        }
        function onSoundSuspend(seq) {
            if (id_audio_play_icon_label_button.playing
                    && !id_delay_check_end_timer.running
                    && (seq == playId)) {
                stop()
            }
        }
    }
}

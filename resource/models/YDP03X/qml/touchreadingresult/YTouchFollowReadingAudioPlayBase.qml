import QtQuick 2.12

import BaseQml 1.0

YMouseArea {
    id: id_touch_follow_reading_audio_play_base
    function playMp3(fileName) {
        const targetName = ("%1%2.mp3").arg(qmlGlobal.touchReadingTipsSoundPath).arg(fileName)
        playingFileName = fileName
        return id_private_data.startPlay(targetName)
    }

    function playMp3Source(source) {
        playingFileName = source
        return id_private_data.startPlay(source)
    }

    function playTTS(words) {
        playingFileName = words
        return id_private_data.startPlayTTS(words)
    }

    readonly property alias currentPlayId: id_private_data.playId
    property string playingFileName: ""
    property int interval: 0

    property string currentPlayingBaseImageName: ""
    property bool endFromUser: false

    signal endPlay()
    signal endPlayFromUserClicked()

    function stop(isEndFromUser = false) {
        endFromUser = isEndFromUser
        qmlGlobal.stopAllAnimationMusic()
    }

    QtObject {
        id: id_private_data
        property double playId: -1

        function startPlay(targetName) {
            if (targetName.length > 0) {
                playId = soundCenter.playMusic(targetName)
                console.warn("YTouchFollowReadingAudioPlayBase.qml===startPlay===playingFileName: ",
                             playingFileName, "===playId: ", playId)
                return playId
            }
        }

        function startPlayTTS(words) {
            if (words.length > 0) {
                playId = soundCenter.play(words, "en", words, settingManager.autoPronounceType + 1)
                console.warn("YTouchFollowReadingAudioPlayBase.qml===startPlayTTS===words: ",
                             playingFileName, "===playId: ", playId)
                return playId
            }
        }

        function playFinished() {
            playId = -1
            if (!endFromUser) {
                endPlay()
            } else {
                endPlayFromUserClicked()
            }
            endFromUser = false
        }
    }

    Connections {
        target: soundCenter
        ignoreUnknownSignals: true
        function onEnd(seq) {
            if (seq === currentPlayId) {
                console.warn("YTouchFollowReadingAudioPlayBase.qml===onEnd===playingFileName: ", playingFileName)
                id_private_data.playFinished()
            }
        }

        function onSoundSuspend(seq) {
            if (seq === currentPlayId) {
                console.warn("YTouchFollowReadingAudioPlayBase.qml===onSoundSuspend===playingFileName: ", playingFileName)
                id_private_data.playFinished()
            }
        }
    }

    objectName: "YTouchFollowReadingAudioPlayBase.qml===YMouseArea"
}

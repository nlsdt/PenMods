import QtQuick 2.12

import BaseQml 1.0

YWordCardDelegate {
    useDefaultLastTipMessage: false
    isEnglish: true
    isFollowEnabled: !isLastTipMessage

    readonly property bool canPlayTTS: (0 === index) && ("word" === interactiveLearningManager.contentType)
                                       && (interactiveLearningManager.currentSearchString.length > 0)
    readonly property bool canPlayAudio: hasAudio || canPlayTTS

    function play() {
        id_delay_play_timer.restart() // 防止重复播放
    }

    YTimer {
        id: id_delay_play_timer
        interval: 120
        onTriggered: {
            if (!isLastTipMessage) {
                if (hasAudio) {
                    if (visible) {
                        playMp3Source(jsonContent.word_audio)
                    }
                } else {
                    qmlGlobal.stopAllAnimationMusic()
                    if (canPlayTTS) {
                        qmlGlobal.audioPlayId = playTTS(interactiveLearningManager.currentSearchString)
                    }
                }
            } else {
                playMp3("reading-question-start")
            }
        }
    }

    YLoader {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.topMargin: -44
        height: 220
        active: isLastTipMessage
        sourceComponent: YQuizLearningStartToAnswerTip {
            onStartToAnswer: {
                id_quiz_learning.startToAnswer()
            }
        }
    }
}

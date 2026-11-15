import QtQuick 2.12
import com.youdao.pen 1.0

import BaseQml 1.0

YTouchFollowReadingAudioPlayBase {
    objectName: "YInteractiveQuizzesResultBase.qml"
    anchors.fill: parent
    visible: false

    property alias frontAnimationFrameSize: id_playing_animation.frameSize

    enum ResultStatus {
        None,
        Right,
        Wrong
    }

    property int currentResultStatus: YInteractiveQuizzesResultBase.Right

    property string audioBaseName: ""
    readonly property alias animationBackgroundItem: id_bg
    readonly property alias animationItem: id_playing_animation

    signal backButtonClicked()

    onEndPlay: {
        if (YInteractiveQuizzesResultBase.Right === currentResultStatus) {
            if ("reading-question-right" === playingFileName) {
                stopAnimation()
            }
        } else if (YInteractiveQuizzesResultBase.Wrong === currentResultStatus) {
            if ("reading-question-wrong" === playingFileName) {
                stopAnimation()
            }
        }
    }

    function play() {
        visible = true
        id_bg.play()
        id_playing_animation.play()
        if (audioBaseName.length > 0) {
            playMp3(audioBaseName)
        } else {
            playMp3((YInteractiveQuizzesResultBase.Right === currentResultStatus)
                    ? "reading-question-right"
                    : "reading-question-wrong")
        }
        id_force_stop_timer.restart()
    }

    function stopAnimation() {
        id_force_stop_timer.stop()
        id_bg.stopPlay()
        id_playing_animation.stopPlay()
        visible = false
        stop()
        backButtonClicked()
    }

    YTimer {
        id: id_force_stop_timer
        interval: 3000
        onTriggered: {
            if (id_playing_animation.running) {
                stopAnimation()
            }
        }
    }

    YAnimatedImagesView {
        id: id_bg
        objectName: "YInteractiveQuizzesResultBase.qml_id_bg"
        frameSize: Qt.size(YBaseEnum.Screen.Width, YBaseEnum.Screen.Height)
        frameCountLoop: 60
        imageNameLoop: (YInteractiveQuizzesResultBase.Right
                        === currentResultStatus) ? "right_bg" : "wrong_bg"
    }

    YAnimatedImagesView {
        id: id_playing_animation
        objectName: "YInteractiveQuizzesResultBase.qml_id_playing_animation"
        frameSize: Qt.size(160, 200)
        anchors.bottom: parent.bottom
        anchors.right: parent.right

        frameCount: 30
        imageName: (YInteractiveQuizzesResultBase.Right
                    === currentResultStatus) ? "right_result" : "wrong_result"
        frameCountLoop: 45
        imageNameLoop: (YInteractiveQuizzesResultBase.Right
                        === currentResultStatus) ? "right_result_loop"
                                                 : "wrong_result_loop"
    }
}

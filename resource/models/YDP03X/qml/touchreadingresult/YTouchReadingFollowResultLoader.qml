import QtQuick 2.12
import com.youdao.pen 1.0

import BaseQml 1.0
import "../timers"

YTouchFollowReadingAudioPlayBase {
    id: id_touch_reading_follow_result_loader
    anchors.fill: parent
    visible: false
    onEndPlay: {
        id_delay_stop_audio_timer.restart()
    }

    property int currentFollowResultIndex: YEnum.TRFRI_COUNT

    signal resultShowFinished()

    function show(followResultIndex) {
        id_delay_stop_audio_timer.stop()
        if (id_top_screen_animation.running) {
            id_top_screen_animation.stopPlay()
        }
        currentFollowResultIndex = followResultIndex

        YTimers.delayCall(120, function(){
            qmlGlobal.stopAllAnimationMusic()
            switch (currentFollowResultIndex) {
            case YEnum.TRFRI_Excellent:
                currentPlayingBaseImageName = "matti_excellent"
                playMp3("follow-excellent-notify")
                id_top_screen_animation.play()
                break
            case YEnum.TRFRI_Great:
                currentPlayingBaseImageName = "matti_great"
                playMp3("follow-great-notify")
                id_top_screen_animation.play()
                break
            case YEnum.TRFRI_ComeOn:
                currentPlayingBaseImageName = "result_come_on"
                playMp3("follow-comeon-notify")
                id_top_screen_animation.play()
                break
            case YEnum.TRFRI_TryAgain:
                currentPlayingBaseImageName = "try_again_result"
                playMp3("follow-comeon-notify")
                id_top_screen_animation.play()
                id_bg_loader.setActive()
                break
            }
            id_touch_reading_follow_result_loader.visible = true
        })
    }

    function close() {
        resultShowFinished()
        stopAnimation()
        id_touch_reading_follow_result_loader.visible = false
    }

    function stopAnimation() {
        id_top_screen_animation.stopPlay()
        id_bg_loader.setInactive()
    }

    YTimer {
        id: id_delay_stop_audio_timer
        interval: 3000
        onTriggered: {
            close()
        }
        objectName: "YTouchReadingFollowResultLoader.qml_id_delay_stop_audio_timer"
    }

    Rectangle {
        id: id_background
        anchors.fill: parent
        color: "#99000000"
    }

    YLoader {
        id: id_bg_loader
        sourceComponent: YAnimatedImagesView {
            objectName: "YTouchReadingFollowResultLoader.qml_id_bg_loader"
            frameSize: Qt.size(YEnum.Screen.Width, YEnum.Screen.Height)
            frameCountLoop: 53
            imageNameLoop: "try_again_result_bg"
        }
        onLoaded: {
            item.play()
        }
    }

    YAnimatedImagesView {
        id: id_top_screen_animation
        anchors.fill: parent
        frameSize: Qt.size(YBaseEnum.Screen.Width, YBaseEnum.Screen.Height)
        objectName: "YTouchReadingFollowResultLoader.qml"
        imageName: {
            switch (currentPlayingBaseImageName) {
            case "matti_excellent":
                return "matti_excellent"
            case "matti_great":
                return "matti_great"
            case "result_come_on":
                return "result_come_on"
            case "try_again_result":
                return "try_again_result"
            default:
                return ""
            }
        }
        imageNameLoop: {
            switch (currentPlayingBaseImageName) {
            case "matti_excellent":
                return "matti_excellent_loop"
            case "matti_great":
                return "matti_great_loop"
            case "result_come_on":
                return "result_come_on_loop"
            case "try_again_result":
                return "try_again_result_loop"
            default:
                return ""
            }
        }
        frameCount: 30
        frameCountLoop: {
            switch (currentPlayingBaseImageName) {
            case "matti_excellent":
                return 20
            case "matti_great":
                return 20
            case "result_come_on":
                return 30
            case "try_again_result":
                return 30
            default:
                return 0
            }
        }
    }

    Connections {
        target: systemBase
        ignoreUnknownSignals: true
        function onHomeKeyRelease() {
            id_top_screen_animation.stopPlay()
        }
    }
}

import QtQuick 2.12
import com.youdao.pen 1.0

import BaseQml 1.0

YTouchFollowReadingAudioPlayBase {
    id: id_get_medal_loader
    anchors.fill: parent
    enabled: "close" !== state
    state: "close"

    property bool isShowing: "close" !== state
    property alias metalRoundIcon: id_follow_get_medal_tips.source
    property alias metalRectIcon: id_follow_get_medal_result.source
    property alias metalTitle: id_follow_get_medal_result.metalTitle
    property bool isFromXiaoXiangCover: false

    signal resultShowFinished()

    function showTips() {
        state = "tips"
        playMp3("reading-finish-tip")
        id_follow_get_medal_tips.play()
        id_checker_timer.restart()
    }

    function showResult() {
        state = "result"
        playMp3("reading-receive-medal")
        id_follow_get_medal_result.play()
    }

    function close() {
        stopGetMedal()
        resultShowFinished()
    }

    function stopGetMedal() {
        qmlGlobal.stopAllAnimationMusic()
        id_follow_get_medal_tips.stopAnimation()
        state = "close"
    }

    onEndPlay: {
        if ("reading-finish-tip" === playingFileName) {
            state = "waiting"
        } else if ("reading-receive-medal" === playingFileName) {
            state = "finished"
        }
    }

    onClicked: {
        if ("waiting" === id_get_medal_loader.state) {
            readingBookManager.confirmBookMedalGet()
            showResult()
        } if ("finished" === id_get_medal_loader.state) {
            close()
            if (!isFromXiaoXiangCover) {
                qmlGlobal.requestShowPage(YEnum.PageIndex.Reading)
            } else {
                readingBookCoverManager.playAudio()
            }
        }
    }

    YTimer {
        id: id_checker_timer
        interval: 6000
        onTriggered: {
            if ("waiting" !== id_get_medal_loader.state) {
                id_get_medal_loader.state = "waiting"
            }
        }
        objectName: "YTouchReadingFollowGetMedalLoader.qml_id_checker_timer"
    }

    YImage {
        sourceSize: Qt.size(800, 254)
        imageName: "touchreading/scan_touch_bg"
        visible: "close" !== id_get_medal_loader.state
    }

    YTouchReadingFollowGetMedalTips {
        id: id_follow_get_medal_tips
        anchors.fill: parent
        opacity: ("tips" === id_get_medal_loader.state) || ("waiting" === id_get_medal_loader.state)
        function stopAnimation() {
            stop()
            id_follow_get_medal_result.stop()
        }
    }

    YTouchReadingFollowGetMedalResult {
        id: id_follow_get_medal_result
        opacity: ("result" === id_get_medal_loader.state) || ("finished" === id_get_medal_loader.state)
        anchors.fill: parent
    }
}

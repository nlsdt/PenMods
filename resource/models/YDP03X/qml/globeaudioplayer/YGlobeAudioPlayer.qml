import QtQuick 2.12
import com.youdao.pen 1.0
import BaseQml 1.0
import "../components"
import "../i18n"
import "../timers"

Item {
    id: id_globe_audio_player_root
    anchors.fill: parent
    visible: false

    readonly property bool isPlaying: YEnum.PLAYING === mediaPlayerManager.playState
    property int currentProgress: mediaPlayerManager.progress
    property int validProgress: 0
    readonly property bool isShowing: "showing" === id_background.state

    signal globeAudioPlayerPageCalled()
    signal closed()

    // 控制音频进度条
    onCurrentProgressChanged: {
        if (0 < currentProgress && currentProgress <= 100) {
            validProgress = currentProgress
        }

        id_audio_progress_bar.progress = validProgress
    }

    function show() {
        id_delay_close.stop()
        id_audio_progress_bar.emptyProgress()
        id_delay_state_changed_timer.stop()
        globeAudioPlayerPageCalled()
        id_pause.visible = false
        visible = true
        id_background.state = "showing"
        qmlGlobal.requestStopAutoScreenOff()

        YTimers.delayCall(100, function(){
            systemBase.wakeUpScreen()
        })
    }

    function close() {
        id_delay_close.restart()
    }

    function mmssString(ms) {
        let seconds = parseInt(ms / 1000);
        let minutes = parseInt(seconds / 60);
        seconds = seconds % 60;
        return ("%1%2:%3%4").arg(minutes > 9 ? "" : "0").arg(minutes).arg(seconds > 9 ? "" : "0").arg(seconds);
    }

    YTimer {
        id: id_delay_close
        interval: 60
        onTriggered: {
            if (isShowing) {
                id_delay_state_changed_timer.restart()
                id_background.state = "hidden"
                mediaPlayerManager.onClickedPause()
                closed()
            }
        }
    }

    Rectangle {
        id: id_background
        anchors.fill: parent
        color: YColors.black
        state: "hidden"

        YTimer {
            id: id_delay_state_changed_timer
            interval: 60
            onTriggered: {
                visible = isShowing
                id_pause.visible = false
                qmlGlobal.requestStartAutoScreenOff()
            }
        }
    }

    // 内容
    YGlobeAudioPlayerContent {
        explainImgs: visible ? "file://"+readingBookAudioPlayerManager.image : ""
        explainText: readingBookAudioPlayerManager.zhTitle
//        explainText: "词"
//         explainText: "词词词词词词词词词词词词词词词词词词词词词"
//        explainText: "词词词词词词词词词词词词词"
        txtLength: explainText.trim().length
    }

    YTimer {
        id: id_delay_show_pause_timer
        interval: 300
        onTriggered: {
            id_pause.visible = true
            id_audio_progress_bar.emptyProgress()
        }
    }

    // 进度条时间
    YBackground {
        id: id_player_progress_timeinfo_item
        anchors.fill: parent
        visible: false
        color: "#CC000000"

        // time
        Row {
            anchors.centerIn: parent
            height: 42
            spacing: 10

            YText {
                id: current_pos_text
                anchors.verticalCenter: rect_icon.verticalCenter
                font.pixelSize: 28
                font.family: fontManager.fontFamilyPinyin
                font.bold: Font.DemiBold
                color: YColors.yellow
                horizontalAlignment: Text.AlignRight
                text: mmssString(mediaPlayerManager.currentPos)
            }

            Item {
                id: rect_icon
                implicitWidth: 13
                implicitHeight: 20

                Rectangle {
                    implicitWidth: 3
                    implicitHeight: 19
                    anchors.centerIn: parent
                    rotation: 30
                    radius: width
                    color: "#808080"
                }
            }

            YText {
                id: duration_pos_text
                anchors.verticalCenter: rect_icon.verticalCenter
                font: current_pos_text.font
                color: YColors.white
                horizontalAlignment: Text.AlignLeft
                text: mmssString(mediaPlayerManager.duration)
            }
        }
    }

    // 进度条
    YProgressBar {
        id: id_audio_progress_bar
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        radius: 0
        height: id_pause.visible? 0 : 8
        color: YColors.audioProgressBarBackGround
        progressColor: YColors.yellow
        progressGradient: Gradient {
            GradientStop { position: 0.0; color: YColors.yellow }
            GradientStop { position: 1.0; color: YColors.yellow }
        }

        onProgressChanged: {
            if (99 === progress || progress === 100) {
                readingBookAudioPlayerManager.globeAudioPlayFinished()
                fullProgress()
                id_delay_show_pause_timer.restart()
            }
        }
    }

    // 触摸
    YGlobeAudioPlayerMouseArea {
        id: id_globe_audio_player_mouse_area
    }

    // 暂停
    YGlobeAudioPlayerPause {
        id: id_pause
        visible: false
        onValidClicked:{
            id_pause.visible = false
            mediaPlayerManager.onClickedPlay()
        }
        onVisibleChanged: {
            if (visible) {
                qmlGlobal.requestStartAutoScreenOff()
            } else {
                qmlGlobal.requestStopAutoScreenOff()
            }
        }
    }

    // 左边bar
    YVerticalTitleBar {
        implicitWidth: 50

        onCallBack: {
            close()
        }
    }
}



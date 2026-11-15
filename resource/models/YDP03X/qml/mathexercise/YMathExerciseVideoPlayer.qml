import QtQuick 2.14
import QtMultimedia 5.15
import QtQuick.Window 2.15
import QtGraphicalEffects 1.0
import QtQuick.Controls 1.2
import com.youdao.pen 1.0

import BaseQml 1.0
import "../i18n"
import "../"

Rectangle {
    id: id_meida_page
    width: 800
    height: 254
    color: "black"
    x: 0
    y: 0
    objectName: "YMathExerciseVideoPlayer.qml"

    property bool isGuideNeeded: true
    property string videoSource: ""
    property var rateSettings: [
        1.0,
        1.5,
        2.0,
        0.8
    ]

    signal closeVideoPage()

    function videoPlay() {
        console.log("YMathExerciseVideoPlayer.qml===videoPlay=== : " + videoUrl)
        if (mediaplayer.playbackState !== MediaPlayer.PlayingState)
            soundCenter.openAudioOutput()
            mediaplayer.play()
    }

    function returnToBound() {
        if (id_test_rect.anchors.verticalCenterOffset > (id_test_rect.scale - 1) * id_meida_page.height / 2) {
            id_test_rect.anchors.verticalCenterOffset = (id_test_rect.scale - 1) * id_meida_page.height / 2
        } else if (id_test_rect.anchors.verticalCenterOffset < (1 - id_test_rect.scale) * id_meida_page.height / 2) {
            id_test_rect.anchors.verticalCenterOffset = (1 - id_test_rect.scale) * id_meida_page.height / 2
        }

        if (id_test_rect.anchors.horizontalCenterOffset > (id_test_rect.scale - 1) * id_meida_page.width / 2) {
            id_test_rect.anchors.horizontalCenterOffset = (id_test_rect.scale - 1) * id_meida_page.width / 2
        } else if (id_test_rect.anchors.horizontalCenterOffset < (1 - id_test_rect.scale) * id_meida_page.width / 2) {
            id_test_rect.anchors.horizontalCenterOffset = (1 - id_test_rect.scale) * id_meida_page.width / 2
        }
    }

    Component.onCompleted: {
        logManager.sendHttpLog("action=math_vedio_show")
        videoPlay()
    }

    Item {
        id: id_container
        anchors.fill: parent

        MediaPlayer {
            id: mediaplayer
            // local
            source: videoSource
            playbackRate: rateSettings[id_rate_setting_button.currentIndex]
//            source: "file://" + "/oem/YoudaoDictPen/output/video_test/test001.mp4"
            // online
//            source: "http://ydlunacommon.nos-jd.163yun.com/1875d66af65c4b83789e139a768afa91.mp4"
//            source: "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4"
//            videoOutput: [v1, v2]
            onPositionChanged: {
                console.log("seven:seek:pos:11111111111111:",position,bufferProgress)
                if(!id_video_player_progress_bar.isMoveing){
                    id_video_player_progress_bar.position = position
                    id_video_player_progress_bar.duration = duration
                    id_video_player_progress_bar.percent = position / duration
                }
            }

            onBufferProgressChanged: {
                onsole.log("seven:seek:pos:onBufferProgressChanged:",bufferProgress)
            }

            onPlaybackStateChanged: {
                // 开始/暂停 播放时，显示控制窗口
                if (mediaplayer.playbackState === MediaPlayer.PlayingState) {
                    id_player_state_mask_show.show()
                    id_player_state_mask_hide.restart()
                }

                if (mediaplayer.playbackState === MediaPlayer.PausedState) {
                    id_player_state_mask_show.show()
                }
            }

            onStatusChanged: {
                //   MediaPlayer.Loading
                if (status === MediaPlayer.Buffered) {
                    id_player_state_mask_show.show()
                    id_player_state_mask_hide.restart()
                }

                if (status === MediaPlayer.EndOfMedia) {
                    id_player_state_mask_show.show()
                    console.log("YMathExerciseVideoPlayer.qml===video end ===")
//                    systemBase.playVideoFinished(lastPlayPath)   //  todo 播放时间埋点
                    mathExerciseManager.processedVideoFinish()
                }
            }

            onPlaybackRateChanged: {
                console.log("YMathExerciseVideoPlayer.qml===onPlaybackRateChanged  ===" + playbackRate)
                id_videoplayer_control_item.showToast()
            }
        }

        Rectangle {
            id: id_test_rect
            width: parent.width * scale
            height: parent.height * scale
            anchors.verticalCenter: parent.verticalCenter
            anchors.horizontalCenter: parent.horizontalCenter
            color: "transparent"

            onScaleChanged: {
                 returnToBound()
            }
        }

        VideoOutput {
            id: v1
            anchors.fill: id_test_rect
            source: mediaplayer
            fillMode: VideoOutput.PreserveAspectFit
            flushMode: VideoOutput.LastFrame
        }

        Window {
            id: id_control_root
            visible: true
            opacity: 0.5
            flags: Qt.FramelessWindowHint
            color: "transparent"
            visibility: Window.Maximized

            YTimer {
                id: id_guide_tip_timer
                interval: 2000
                objectName: "YMathExerciseToast.qml_id_guide_tip_timer"
                onTriggered: {
                    isGuideNeeded = false
                    id_posture_guide_tip.hide()
                }
            }

            PinchArea {
                id: id_test_pinch
                anchors.fill: parent
                pinch.maximumScale: 4
                pinch.minimumScale: 1
                pinch.target: id_test_rect
                enabled: !id_videoplayer_control_item.visible

                pinch.dragAxis: Pinch.XAndYAxis

                onPinchUpdated: {
//                    console.warn("@@@@ scale = " + v1.scale
//                                 + " v1.y = " + v1.y
//                                 + " id_test_rect.y = " + id_test_rect.y
//                                 + " id_test_rect.anchors.verticalCenterOffset" + id_test_rect.anchors.verticalCenterOffset
//                                 + " id_test_rect.height = " + id_test_rect.height)
                }

                Item {
                    id: id_posture_guide_tip
                    visible: false
                    anchors.centerIn: parent
                    width: 420
                    height: 100

                    function show() {
                        visible = true
                        settingManager.setMathVideoPlayCount(settingManager.mathVideoPlayCount + 1)
                    }

                    function hide() {
                        visible = false
                    }

                    Rectangle {
                        id: id_posture_guide_tip_bg
                        width: 420
                        height: 100
                        radius: 26
                        color: "#99000000"
                        smooth: true

                        YImage {
                            anchors.centerIn: parent
                            imageName: "math/posture-guide"
                        }
                    }
                }

                Item {
                    id: id_progress_indicator
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: 113
                    width: parent.width
                    height: 2

                    Rectangle {
                        anchors.bottom: parent.bottom
                        width:  parent.width
                        height: 2
                        color: YColors.white
                        opacity: 0.4
                    }

                    Rectangle {
                        id: id_position_rect
                        anchors.bottom: parent.bottom
                        anchors.left: parent.left
                        width: parent.width * mediaplayer.position / mediaplayer.duration
                        height: parent.height
                        color: "#509DEB"
                    }
                }

                MouseArea {
                    id: id_drag_area
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: 113
                    width: parent.width

                    property int lstMouseX: 0
                    property int lstMouseY: 0

                    property int enterMouseX: 0
                    property int enterMouseY: 0

                    YTimer {
                        id: id_doubleclick_check_timer
                        interval: 500
                        onTriggered: {
                            id_player_state_mask_show.show()
                            id_player_state_mask_hide.restart()
                        }
                        objectName: "YMathExerciseVideoPlayer.qml_id_check_timer"
                    }

                    onEntered: {
                        enterMouseX = mouseX
                        enterMouseY = mouseY
                        lstMouseX = mouseX
                        lstMouseY = mouseY
                    }

                    onPositionChanged: {
                        id_test_rect.anchors.horizontalCenterOffset += mouseX - lstMouseX
                        id_test_rect.anchors.verticalCenterOffset += mouseY - lstMouseY
                        returnToBound()
                        lstMouseX = mouseX
                        lstMouseY = mouseY
                    }

                    onClicked: {
                        if (!id_doubleclick_check_timer.running) {
                            if ((Math.abs(enterMouseX - mouseX)) < 1
                                    && (Math.abs(enterMouseY - mouseY)) < 1) {
                                id_doubleclick_check_timer.restart()
                            }
                        }
                    }

                    onDoubleClicked: {
                        id_doubleclick_check_timer.stop()
                        if (mediaplayer.playbackState === MediaPlayer.PlayingState) {
                            mediaplayer.pause()
                        } else {
                            soundCenter.openAudioOutput()
                            mediaplayer.play()
                        }
                    }
                }
            }

            Item {
                id: id_video_playerloading_item
                anchors.fill: parent
                anchors.top: parent.top
                anchors.topMargin: 113
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 113
                visible: mediaplayer.status === MediaPlayer.Loading || mediaplayer.status === MediaPlayer.InvalidMedia

                YBackgroundIgnoreMouseEvent {
                    id: id_loading_animation
                    anchors.fill: parent
                    opacity: 0.6

                    SequentialAnimation {
                        id: id_video_loading_animation
                        running: id_loading_animation.visible
                        loops: SequentialAnimation.Infinite

                        ParallelAnimation {
                            NumberAnimation { target: id_green_ellipse; property: "width"; to: 20; duration: 1000 }
                            NumberAnimation { target: id_green_ellipse; property: "height"; to: 20; duration: 1000 }
                            NumberAnimation { target: id_green_ellipse; property: "radius"; to: 10; duration: 1000 }
                            NumberAnimation { target: id_orange_ellipse; property: "width"; to: 14; duration: 1000 }
                            NumberAnimation { target: id_orange_ellipse; property: "height"; to: 14; duration: 1000 }
                            NumberAnimation { target: id_orange_ellipse; property: "radius"; to: 7; duration: 1000 }
                        }

                        ParallelAnimation {
                            NumberAnimation { target: id_green_ellipse; property: "width"; to: 14; duration: 1500 }
                            NumberAnimation { target: id_green_ellipse; property: "height"; to: 14; duration: 1500 }
                            NumberAnimation { target: id_green_ellipse; property: "radius"; to: 7; duration: 1500 }
                            NumberAnimation { target: id_orange_ellipse; property: "width"; to: 20; duration: 1500 }
                            NumberAnimation { target: id_orange_ellipse; property: "height"; to: 20; duration: 1500 }
                            NumberAnimation { target: id_orange_ellipse; property: "radius"; to: 10; duration: 1500 }
                        }
                    }
                }

                Rectangle {
                    id: id_green_ellipse
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.horizontalCenterOffset: -13
                    width: 14
                    height: 14
                    radius: width / 2
                    color: "#18E1BD"
                }

                Rectangle {
                    id: id_orange_ellipse
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.horizontalCenterOffset: 13
                    width: 20
                    height: 20
                    radius: width / 2
                    color: "#FA5E3C"
                }

                YVerticalTitleBar {
                    anchors.bottomMargin: 18 + 113
                    onCallBack: {
                        mathExerciseManager.processedVideoFinish()
                        closeVideoPage()
                    }
                } // YVerticalTitleBar
            }

            Item  {
                id: id_videoplayer_control_item
                anchors.fill: parent
                anchors.top: parent.top
                anchors.topMargin: 113
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 113
                visible: !id_video_playerloading_item.visible
                enabled: visible

                signal showToast()

                onShowToast: {
                    id_exercise_videoplayer_toast.showToast(("已切换到<font color=\"%1\">%2X</font>倍速播放").arg("#FF881B").arg(mediaplayer.playbackRate.toFixed(1)), YColors.grayNormal)
                    id_player_state_mask_show.show()
                }

                YTimer {
                    id: id_control_check_timer
                    interval: 500
                    onTriggered: {
                        id_videoplayer_control_item.visible = false
                    }
                    objectName: "YMathExerciseVideoPlayer.qml_id_check_timer"
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        if (!id_control_check_timer.running) {
                            id_control_check_timer.restart()
                        }
                    }

                    onDoubleClicked: {
                        id_control_check_timer.stop()
                        if (mediaplayer.playbackState === MediaPlayer.PlayingState) {
                            mediaplayer.pause()
                        } else {
                            soundCenter.openAudioOutput()
                            mediaplayer.play()
                        }
                    }
                }

                YVerticalTitleBar {
                    id: id_title_bar
                    anchors.bottomMargin: 18 + 113
                    onCallBack: {
                        mathExerciseManager.processedVideoFinish()
                        closeVideoPage()
                    }
                } // YVerticalTitleBar

                YButtonBase {
                    id: id_rate_setting_button
                    color: "#1A1B1F"
                    radius: 16
                    width: 70
                    height: 44
                    anchors.right: parent.right
                    anchors.rightMargin: 16
                    anchors.top: parent.top
                    anchors.topMargin: 18
                    mouseAreaMargins: -18

                    property int currentIndex: 0

                    YText {
                        anchors.centerIn: parent
                        font.pixelSize: 20
                        width: paintedWidth
                        height: paintedHeight
                        color: YColors.white
                        text: rateSettings[id_rate_setting_button.currentIndex].toFixed(1) + "X"//"1.0X"
                    }

                    onClicked: {  
                        console.log("YMathExerciseVideoPlayer.qml===id_rate_setting_button clicked" + id_rate_setting_button.currentIndex)
                        currentIndex = (currentIndex + 1) % 4

                        if (mediaplayer.playbackState !== MediaPlayer.PlayingState) {
                            soundCenter.openAudioOutput()
                            mediaplayer.play()
                        }
                    }
                }

                YVideoProgressBar {
                    id: id_video_player_progress_bar
                    anchors.bottom: parent.bottom
                    anchors.left: parent.left
                    anchors.right: parent.right
                    width: 800
                    height: 100

                    playbackState: mediaplayer.playbackState

                    onPlayVideo: {
                        if (start) {
                            soundCenter.openAudioOutput()
                            mediaplayer.play()
                        } else {
                            mediaplayer.pause()
                        }
                    }

                    onDragStart: {
                        mediaplayer.pause()
                        id_player_state_mask_hide.stop()
                    }

                    onDragStop: {
                        soundCenter.openAudioOutput()
                        mediaplayer.play()
                    }

                    onSetPosition: {
                        console.log("seven:seek:pos:-------------:0:",pos, mediaplayer.seekable)
                        if(mediaplayer.seekable){
                            mediaplayer.seek(pos)
                            console.log("seven:seek:pos:-------------:1:",mediaplayer.bufferProgress)
                        }
                    }
                }

                Rectangle {
                    id: id_player_progress_mask
                    anchors.fill: parent
                    enabled: false
                    color: "transparent"
                    radius: 0

                    QtObject {
                        id: id_player_state_mask_show

                        function hide() {
                            id_player_state_mask_hide.stop()
                            id_videoplayer_control_item.visible = false
                            id_player_progress_mask.opacity = 0
                            id_video_player_progress_bar.opacity = 0
                            id_player_progress_mask.enabled = false
                        }

                        function show() {
                            restart()
                        }

                        function restart() {
                            id_player_state_mask_hide.stop()
                            id_videoplayer_control_item.visible = true
                            id_player_progress_mask.opacity = 0.8
                            id_video_player_progress_bar.opacity = 1
                            id_player_progress_mask.enabled = true
                        }
                    }

                    SequentialAnimation {
                        id: id_player_state_mask_hide
                        ScriptAction {
                            script: {
                                id_player_progress_mask.enabled = false
                            }
                        }
                        ParallelAnimation {
                            NumberAnimation { target: id_player_progress_mask; property: "opacity"; to: 0.8; duration: 3000 }
                        }
                        ScriptAction {
                            script: {
                                id_videoplayer_control_item.visible = false
                                id_player_progress_mask.opacity = 0
                                id_video_player_progress_bar.opacity = 0

                                if ((settingManager.mathVideoPlayCount < 3)
                                        && isGuideNeeded) {
                                    id_posture_guide_tip.show()
                                    id_guide_tip_timer.restart()
                                }
                            }
                        }
                    }
                }

                YMathExerciseToast {
                    id: id_exercise_videoplayer_toast
                }

            }

            Item {
                anchors.fill: parent
                anchors.top: parent.top
                anchors.topMargin: 113
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 113

                YMouseArea {
                    id: id_drag_show_quick_setting
                    anchors.left: parent.left
                    anchors.leftMargin: 180
                    anchors.right: parent.right
                    anchors.rightMargin: 180
                    height: 30

                    onPressed: {
                        qmlGlobal.quickSettingDragEntry(mouseY)
                    }

                    onPositionChanged: {
                        qmlGlobal.quickSettingDragUpdate(mouseY)
                    }

                    onReleased: {
                        qmlGlobal.quickSettingDragExit(mouseY)
                    }

                    onCanceled: {
                        qmlGlobal.quickSettingDragExit(mouseY)
                    }
                }
            }
        }
    }

    Connections {
        target: qmlGlobal
        ignoreUnknownSignals: true
        onQuickSettingStateChanged: {
            id_control_root.visible = !isOpening
        }
    }
}

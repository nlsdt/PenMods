import QtQuick 2.12
import QtMultimedia 5.15
import com.youdao.pen 1.0

import BaseQml 1.0
import "../i18n"

YImage {
    id: id_video_progress_bar_bg
    sourceSize: Qt.size(800, 100)
    imageName: "math/progressbar-bg"

    property var playbackState: MediaPlayer.StoppedState
    property int position: 0
    property int duration: 0

    property double percent: 0.0
    property bool isMoveing: false

    signal playVideo(var start)
    signal setPosition(var pos)
    signal dragStart()
    signal dragStop()

    YImage {
        id: id_play_button
        sourceSize: Qt.size(44, 44)
        anchors.left: parent.left
        anchors.leftMargin: 18
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 8
        imageName: playbackState !== MediaPlayer.PlayingState
                   ? "audioplayer/pause" : "audioplayer/play"

        YMouseArea {
            anchors.fill: parent
            anchors.margins: -20

            onClicked: {
                if (playbackState === MediaPlayer.PlayingState) {
                    playVideo(false)
                } else {
                    playVideo(true)
                }
            }
        }
    }

    YText {
//        anchors.left: parent.left
//        anchors.leftMargin: 24
        anchors.right: id_total.left
        anchors.rightMargin: 12
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 12
        font.pixelSize: 20
        width: paintedWidth
        height: paintedHeight
        color: YColors.white

        text: Qt.formatTime(new Date(position), "mm:ss")
    }

    YText {
//        anchors.right: parent.right
//        anchors.rightMargin: 24
        anchors.left: id_total.right
        anchors.leftMargin: 12
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 12
        font.pixelSize: 20
        width: paintedWidth
        height: paintedHeight
        color: YColors.white

        text: Qt.formatTime(new Date(duration), "mm:ss")
    }

    Rectangle {
        id: id_total
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 22
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.horizontalCenterOffset: 33
        width: 544
        height: 4
        color: YColors.white
        opacity: 0.4

        MouseArea {
            id: id_proogress_drag_area
            anchors.top: parent.top
            anchors.topMargin: -24
            anchors.bottom: parent.bottom
            anchors.bottomMargin: -22
            anchors.left: parent.left
            anchors.right: parent.right
            // drag area
            // 拖拽开始 暂停
            // 拖拽过程 setPosition
            // 拖拽结束 开始播放

            property int lstMouseX: 0

            onEntered: {
                lstMouseX = mouseX
                isMoveing = true
                dragStart()
            }

            function updatePercent(currentOfset){
                if(mouseX <= 0){
                    percent = 0
                } else if(mouseX >= width) {
                    percent = 1
                }else{
                    percent = mouseX / width
                }
            }

            onPositionChanged: {
//                if (mouseX < 0 || mouseX > width) return
//                if (Math.abs(lstMouseX - mouseX) < 20) return
//                var pos = (mouseX ) * duration / width
//                console.log("seven:onPositionChanged", pos)
//                setPosition(pos)
//                lstMouseX = mouseX
                console.log("seven:onPositionChanged", mouseX, width)
                updatePercent(mouseX)
                position = percent * duration
            }

            onPressed: {

            }

            onReleased: {
//                if (mouseX < 0 || mouseX > width) return
//                if (Math.abs(lstMouseX - mouseX) < 20) return
//                var pos = (mouseX ) * duration / width
                console.log("seven:onReleased:", mouseX, width)
                updatePercent(mouseX)
                console.log("seven:onReleased:1", percent)
                setPosition(percent * duration)
            }

            onExited: {
                isMoveing = false
                dragStop()
            }
        }
    }

    Rectangle {
        id: id_position_rect
        anchors.bottom: id_total.bottom
        anchors.left: id_total.left
        anchors.top: id_total.top
        width: id_total.width * percent//position / duration
        height: parent.height
        color: "#509DEB"
    }

    YImage {
        width: 24
        height: 24
        anchors.verticalCenter: id_total.verticalCenter
        anchors.horizontalCenter: id_position_rect.right
        sourceSize: Qt.size(24, 24)
        imageName: "math/progressbar-indicator"
    }
}

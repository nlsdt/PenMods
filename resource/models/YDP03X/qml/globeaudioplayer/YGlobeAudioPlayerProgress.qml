import QtQuick 2.12
import com.youdao.pen 1.0
import BaseQml 1.0
import "../components"

Item {
    id: id_globe_audio_player_progress_item
    anchors.fill: parent
    property alias progress: id_audio_progress_bar.progress

    onProgressChanged: {
        console.log("YGlobeAudioPlayerProgress.qml===progress=="+progress)
    }

    // 进度条
    YProgressBar {
        id: id_audio_progress_bar
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        radius: 0
        height: 8
        color: YColors.audioProgressBarBackGround
        progressColor: YColors.yellow
        progressGradient: Gradient {
            GradientStop { position: 0.0; color: YColors.yellow }
            GradientStop { position: 1.0; color: YColors.yellow }
        }
        progress: 80  // todo
//        progress: mediaPlayerManager.progress

    }

    // 进度条时间
    Item {
        id: id_player_progress_timeinfo_item
        implicitWidth: 113
        implicitHeight: 27
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 5
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.horizontalCenterOffset: id_audio_progress_bar.progress
//        anchors.horizontalCenterOffset: ((mediaPlayerManager.progress - 50) * 0.01 * parent.width).bound(-284, +284)

        YTextMedium {
            anchors.centerIn: parent
            font.pixelSize: 16
            textFormat: Text.RichText
//            text: ('<span style="font-family: %1; color:%2">%3</span> / %4')
//                   .arg(fontManager.fontFamilyEnUs).arg(YColors.blueText)
//                   .arg(mmssString(mediaPlayerManager.currentPos))
//                   .arg(mmssString(mediaPlayerManager.duration))
            text: ('<span style="font-family: %1; color:%2">%3</span> / %4')
                   .arg("Times").arg(YColors.orange)
                   .arg(("00:21"))
                   .arg(("00:27"))
        }
    }

}

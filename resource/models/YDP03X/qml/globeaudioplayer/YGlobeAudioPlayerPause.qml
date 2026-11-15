import QtQuick 2.12
import com.youdao.pen 1.0
import BaseQml 1.0
import "../components"

YBackground {
    id: id_globe_audio_player_pause
    anchors.fill: parent
    color: "#CC000000"

    property alias playerStateCenterIndicatorItem: id_player_state_center_indicator
    property alias playButtonItem: id_play_button

    signal validClicked()

    // 暂停按钮
    Rectangle {
        id: id_player_state_center_indicator
        implicitWidth: 80
        implicitHeight: 80
        anchors.centerIn: parent
        radius: height/2
        gradient: Gradient {
            GradientStop { position: 0.0; color: "#FF7E08" }
            GradientStop { position: 1.0; color: "#FF5C00" }
        }

        YImage {
            id: id_play_button
            sourceSize: Qt.size(44, 44)
            anchors.centerIn: parent
            imageName: visible ? "audioplayer/pause" : ""
        }

        YMouseArea {
            anchors.fill: parent
            anchors.margins: -40
            onClicked: {
                console.log("YGlobeAudioPlayer.qml===id_player_state_center_indicator==clicked==")
                validClicked()
            }
        }
    }

}

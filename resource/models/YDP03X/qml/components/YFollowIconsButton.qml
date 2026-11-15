import QtQuick 2.12
import BaseQml 1.0
import "../animations"
YIconLabelButton {
    id: id_follow_icons_button

    implicitWidth: 44
    implicitHeight: 44
    sourceSize: Qt.size(44, 44)
    leftMargin: 18
    icon: playing ? "" : "follow/play1"
    readonly property alias playing: id_playing_animation.running

    property int iconChangedAnimationDuration: 300

    function play() {
        id_playing_animation.state = "playing"
        id_playing_animation.play()
        id_playing_animation.visible = true
    }

    function stop() {
        id_playing_animation.state = "stop"
        id_playing_animation.stopPlay()
        id_playing_animation.visible = false
    }

    YAudioPlayerIndicatorAnimation {
        id: id_playing_animation
    }
}

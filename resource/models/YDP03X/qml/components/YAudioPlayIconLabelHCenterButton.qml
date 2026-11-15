import QtQuick 2.12
import BaseQml 1.0

YIconLabelHCenterButton {
    id: id_audio_play_icon_label_button
    spacing: 8
    textItem.color: YColors.grayText
    textItem.textFormat: YText.RichText
    iconSource: "dict/sound"
    iconSourceSize: Qt.size(32, 32)

    readonly property alias playing: id_playing_animation.running

    property int iconChangedAnimationDuration: 300

    function play() {
        id_playing_animation.audioPlayId = 0
        id_playing_animation.state = "playing"
        id_playing_animation.running = true
    }

    function stop() {
        id_playing_animation.audioPlayId = 0
        id_playing_animation.state = "stop"
        id_playing_animation.running = false
    }

    SequentialAnimation {
        id: id_playing_animation
        loops: Animation.Infinite
        alwaysRunToEnd: true
        property string state: "stop"
        property double audioPlayId: 0
        PropertyAction {
            target: id_audio_play_icon_label_button
            property: "iconSource"
            value: "dict/sound-1"
        }
        PauseAnimation { duration: iconChangedAnimationDuration }
        PropertyAction {
            target: id_audio_play_icon_label_button
            property: "iconSource"
            value: "dict/sound-2"
        }
        PauseAnimation { duration: iconChangedAnimationDuration }
        PropertyAction {
            target: id_audio_play_icon_label_button
            property: "iconSource"
            value: "dict/sound-3"
        }
        PauseAnimation { duration: iconChangedAnimationDuration }
        onRunningChanged: {
            if (!running && ("stop" === id_playing_animation.state)) {
                id_audio_play_icon_label_button.iconSource = "dict/sound"
            }
        }
    }

    onValidClicked: {
        if (playing) {
            stop()
            soundCenter.stop()
        } else {
            play()
        }
    }

    Connections {
        target: qmlGlobal
        ignoreUnknownSignals: true
        //enabled: id_audio_play_icon_label_button.visible
        function onAudioPlayIdChanged() {
            if (id_audio_play_icon_label_button.playing) {
                id_playing_animation.audioPlayId = qmlGlobal.audioPlayId
            }
        }
    }

    Connections {
        target: soundCenter
        ignoreUnknownSignals: true
        //enabled: id_audio_play_icon_label_button.visible
        function onEnd(seq) {
            if ((id_audio_play_icon_label_button.playing)
                    && (seq == id_playing_animation.audioPlayId)) {
                stop()
            }
        }
    }
}

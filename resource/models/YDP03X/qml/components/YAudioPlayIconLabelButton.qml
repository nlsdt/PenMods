import QtQuick 2.12
import BaseQml 1.0

YIconLabelButton {
    id: id_audio_play_icon_label_button
    implicitHeight: 52
    leftMargin: 20
    rightMargin: 20
    spacing: 12
    textColor: YColors.grayText
    textFormat: YText.RichText
    sourceSize: Qt.size(32, 32)
    icon: "dict/sound"

    readonly property alias playing: id_playing_animation.running

    property int iconChangedAnimationDuration: 300

    function autoplay() {
        id_playing_animation.audioPlayId = 0
        id_playing_animation.state = "playing"
        id_playing_animation.running = true
        id_playing_animation.isAuto = true
    }

    function play() {
        id_playing_animation.audioPlayId = 0
        id_playing_animation.state = "playing"
        id_playing_animation.running = true
        id_playing_animation.isAuto = false
    }

    function stop() {
        id_playing_animation.audioPlayId = 0
        id_playing_animation.state = "stop"
        id_playing_animation.running = false
        id_playing_animation.isAuto = false
    }

    SequentialAnimation {
        id: id_playing_animation
        loops: Animation.Infinite
        alwaysRunToEnd: true
        property string state: "stop"
        property double audioPlayId: 0
        property bool isAuto: false
        PropertyAction {
            target: id_audio_play_icon_label_button
            property: "icon"
            value: "dict/sound-1"
        }
        PauseAnimation { duration: iconChangedAnimationDuration }
        PropertyAction {
            target: id_audio_play_icon_label_button
            property: "icon"
            value: "dict/sound-2"
        }
        PauseAnimation { duration: iconChangedAnimationDuration }
        PropertyAction {
            target: id_audio_play_icon_label_button
            property: "icon"
            value: "dict/sound-3"
        }
        PauseAnimation { duration: iconChangedAnimationDuration }
        onRunningChanged: {
            if (!running && ("stop" === id_playing_animation.state)) {
                id_audio_play_icon_label_button.icon = "dict/sound"
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
            console.log("target: soundCenter" + qmlGlobal.audioAutoPlayId);
            if (id_audio_play_icon_label_button.playing
                    && (seq == id_playing_animation.audioPlayId
                        || ( id_playing_animation.isAuto && seq == qmlGlobal.audioAutoPlayId))) {
                qmlGlobal.audioAutoPlayId = 0;
                console.log(qmlGlobal.audioAutoPlayId);
                stop()
            }
        }
    }
}

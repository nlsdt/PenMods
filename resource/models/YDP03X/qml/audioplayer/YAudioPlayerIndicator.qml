import QtQuick 2.12
import com.youdao.pen 1.0

import BaseQml 1.0
import "../animations"

Item {
    id: id_drag_active_area
    anchors.fill: parent
    anchors.leftMargin: 20
    anchors.rightMargin: 20
    state: "hide"

    readonly property bool isShowing: "show" === state
    readonly property bool isShowingAndExtendState: isShowing && id_drag_target.isExtendState

    property string indicatorSource: ""

    function show() {
        state = "show"
        if (indicatorSource.length > 0) {
            id_indicator_icon.source = indicatorSource
        } else {
            id_indicator_icon.source = "image://icons/audioplayer/indicator/default.png"
        }
    }

    function hide() {
        state = "hide"
    }

    function closeExtendState() {
        id_drag_area.closeExtendState()
    }

    signal clicked()
    signal stopAudio()

    states: [
        State {
            name: "hide"
            PropertyChanges {
                target: id_drag_target
                isExtendState: false
                visible: false
            }
        },
        State {
            name: "show"
            PropertyChanges {
                target: id_drag_target
                visible: true
            }
        }
    ]

    Item {
        id: id_drag_target
        implicitWidth: 100
        implicitHeight: isExtendState ? 180 : 100

        Behavior on height {
            NumberAnimation { duration: 120 }
        }

        property bool isExtendState: false

        Rectangle {
            id: id_drag_target_bg
            implicitWidth: 100
            implicitHeight: 230
            color: id_drag_target.isExtendState ? "#2D2E33" : "#992D2E33"
            radius: width/2
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            anchors.bottomMargin: id_drag_area.adsorbedOnTop ? 0 : (id_drag_target.height - id_drag_target_bg.height)
            visible: !id_drag_area.drag.active

            ColorAnimation on color {
                duration: 120
            }
        }

        Rectangle {
            id: id_drag_target_moving_bg
            implicitWidth: 100
            implicitHeight: 100
            color: "#992D2E33"
            radius: width/2
            visible: id_drag_area.drag.active
        }

        YImage {
            id: id_indicator_icon
            width: 80
            height: 80
            sourceSize: Qt.size(80, 80)
            anchors.centerIn: parent
            anchors.verticalCenterOffset: id_drag_target.isExtendState ? (id_drag_area.adsorbedOnTop ? 40 : -40) : 0

            Behavior on anchors.verticalCenterOffset {
                NumberAnimation { duration: 120 }
            }

            onSourceChanged: {
                console.log("ZDS===YAudioPlayerIndicator.qml===YImage===source:", source)
            }

            Rectangle {
                anchors.fill: parent
                color: "#66000000"
                radius: height/2
                visible: (YEnum.PLAYING !== mediaPlayerManager.playState)
                YImage {
                    anchors.centerIn: parent
                    sourceSize: Qt.size(36, 36)
                    imageName: "audioplayer/authorized_play"
                }
            }

            YAudioPlayerIndicatorAnimation {
                id: id_audio_player_indicator_animation
                readonly property bool playing: isShowing && (YEnum.PLAYING === mediaPlayerManager.playState)
                onPlayingChanged: {
                    if (playing) {
                        id_audio_player_indicator_animation.play()
                    } else {
                        id_audio_player_indicator_animation.stopPlay()
                    }
                }
                visible: id_audio_player_indicator_animation.running
            }
        }


        Drag.active: id_drag_area.drag.active
        Drag.hotSpot.x: id_drag_target.width / 2
        Drag.hotSpot.y: id_drag_target.height / 2
        Drag.supportedActions: Qt.IgnoreAction

        YMouseArea {
            id: id_drag_area
            anchors.fill: parent
            drag.target: parent

            property bool adsorbedOnTop: true

            function updateTargetDirection() {
                adsorbedOnTop = (id_drag_target.y < (id_drag_active_area.height/2 - id_drag_target.height/2))
            }

            function updateTargetPos() {
                id_drag_target.x = Math.max(0, Math.min(id_drag_target.x, id_drag_active_area.width - id_drag_target.width))
                id_drag_target.y = adsorbedOnTop ? 0 : (id_drag_active_area.height - id_drag_target.height)
            }

            function closeExtendState() {
                id_drag_target.isExtendState = false
                updateTargetPos()
            }

            function openExtendState() {
                id_drag_target.isExtendState = true
                updateTargetPos()
            }

            onPositionChanged: {
                if (id_drag_area.drag.active) {
                    id_drag_target.isExtendState = false
                    updateTargetDirection()
                }
            }

            onReleased: {
                updateTargetPos()
            }

            onClicked: {
                if (!id_drag_target.isExtendState) {
                    openExtendState()
                } else {
                    if (adsorbedOnTop) {
                        if (mouseY > 90) {
                            id_drag_active_area.clicked()
                        }
                    } else {
                        if (mouseY < 90) {
                            id_drag_active_area.clicked()
                        }
                    }
                }
            }
            objectName: "YAudioPlayerIndicator.qml_id_drag_area"
        }

        YImage {
            id: id_indicator_close
            width: 36
            height: 36
            sourceSize: Qt.size(36, 36)
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            anchors.topMargin: id_drag_area.adsorbedOnTop ? 16 : 128
            visible: id_drag_target.isExtendState
            imageName: "commons/close"

            YBackButtonBase {
                anchors.fill: parent
                anchors.topMargin: -32
                anchors.leftMargin: -32
                anchors.rightMargin: -32
                anchors.bottomMargin: -16
                onTriggered: {
                    indicatorSource = ""
                    stopAudio()
                    hide()
                }
                objectName: "YAudioPlayerIndicator.qml_id_indicator_close"
            }
        }
    }
}

import QtQuick 2.12

Item {
    id: id_waiting_tips
    width: id_tips.paintedWidth
    height: id_tips.paintedHeight

    readonly property alias tipsItem: id_tips
    readonly property alias tipsAnimationItem: id_tips_animation

    property string text: ""
    property int textChangedDuration: 420
    property alias running: id_tips_animation.running
    property alias font: id_tips.font
    property alias color: id_tips.color
    property alias horizontalAlignment: id_tips.horizontalAlignment
    property alias verticalAlignment: id_tips.verticalAlignment
    property alias textFormat: id_tips.textFormat

    function restart() {
        id_tips_animation.restart()
    }

    function start() {
        id_tips_animation.start()
    }

    function stop() {
        id_tips_animation.stop()
    }

    YText {
        id: id_tips
        anchors.fill: parent
        text: id_waiting_tips.text
        horizontalAlignment: YText.AlignHCenter
    }

    YText {
        id: id_tips_suffix
        anchors.left: id_tips.right
        anchors.verticalCenter: id_tips.verticalCenter
        font: id_tips.font
        color: id_tips.color
    }

    SequentialAnimation {
        id: id_tips_animation
        loops: SequentialAnimation.Infinite
        running: false

        PropertyAction { target: id_tips_suffix; property: "text"; value: "" }
        PauseAnimation { duration: textChangedDuration }
        PropertyAction { target: id_tips_suffix; property: "text"; value: "." }
        PauseAnimation { duration: textChangedDuration }
        PropertyAction { target: id_tips_suffix; property: "text"; value: ".." }
        PauseAnimation { duration: textChangedDuration }
        PropertyAction { target: id_tips_suffix; property: "text"; value: "..." }
        PauseAnimation { duration: textChangedDuration }

        onRunningChanged: {
            if (!running) {
                id_tips_suffix.text = ""
            }
        }
    }
}

import QtQuick 2.12

import BaseQml 1.0

YSpacingForColumn {
    implicitHeight: 128
//    visible: 0 === resultManager.itemCount // if use remove annotation

    onVisibleChanged: {
        if (visible) {
            id_opening_animation.restart()
        } else {
            id_opening_animation.stop()
        }
    }

    YTextMedium {
        id: id_state_tip
        anchors.centerIn: parent
        text: YTranslateText.isTranslating
    }

    YTextMedium {
        id: id_state_tip_waiting
        anchors.verticalCenter: id_state_tip.verticalCenter
        anchors.left: id_state_tip.right
        visible: id_opening_animation.running
    }

    SequentialAnimation {
        id: id_opening_animation
        loops: SequentialAnimation.Infinite
        running: false
        PropertyAction { target: id_state_tip_waiting; property: "text"; value: "..." }
        PauseAnimation { duration: 420 }
        PropertyAction { target: id_state_tip_waiting; property: "text"; value: "" }
        PauseAnimation { duration: 420 }
        PropertyAction { target: id_state_tip_waiting; property: "text"; value: "." }
        PauseAnimation { duration: 420 }
        PropertyAction { target: id_state_tip_waiting; property: "text"; value: ".." }
        PauseAnimation { duration: 420 }
    }
}

import QtQuick 2.12
import com.youdao.pen 1.0

import BaseQml 1.0
import "../i18n"

YLoader {
    id: id_check_update_tip_loader
    anchors.horizontalCenter: parent.horizontalCenter
    active: wifiManager.internetConnect
            && (YEnum.UPDATE_CHECHING === otaStatus)
    sourceComponent: YText {
        font.pixelSize: 28
        text: YTranslateText.updateChecking

        YText {
            id: id_state_tip_waiting
            anchors.left: parent.right
            anchors.verticalCenter: parent.verticalCenter
            font.pixelSize: parent.font.pixelSize
        }

        SequentialAnimation {
            id: id_opening_animation
            loops: SequentialAnimation.Infinite
            running: id_check_update_tip_loader.active
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
}

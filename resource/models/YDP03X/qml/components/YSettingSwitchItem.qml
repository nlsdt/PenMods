import QtQuick 2.12

import BaseQml 1.0
import com.youdao.pen 1.0

YSettingItemBackground {
    id: id_setting_switch_item

    readonly property alias delaySwitchTimerRunning: id_delay_switch_timer.running
    readonly property alias delaySwitchTimerItem: id_delay_switch_timer
    property var backButtonClickedSignal: null

    property alias title: id_title.text
    property alias switchOn: id_switch_state.switchOn
    readonly property alias switchItem: id_switch_state
    property alias interval: id_delay_switch_timer.interval
    property alias titleObj: id_title

    signal clicked()
    signal timerTriggered()

    YTextMedium {
        id: id_title
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        anchors.leftMargin: 20
        textFormat: Text.RichText
    }

    YSwitch {
        id: id_switch_state
        anchors.verticalCenter: parent.verticalCenter
        anchors.right: parent.right
        anchors.rightMargin: 20
    }

    YMouseArea {
        id: id_switch_state_button
        anchors.fill: parent
        onClicked: {
            switchOn = !switchOn
            id_setting_switch_item.clicked()
            //timerTriggered()
            id_delay_switch_timer.restart()
        }
        objectName: "YSettingSwitchItem.qml_YMouseArea"
    }

    YTimer {
        id: id_delay_switch_timer
        interval: 600
        objectName: "YSettingSwitchItem.qml_id_delay_switch_timer"
        onTriggered: {
            timerTriggered()
        }
    }

    Component.onCompleted: {
        if (null !== backButtonClickedSignal) {
            backButtonClickedSignal.connect(function(){
                if (id_delay_switch_timer.running) {
                    id_delay_switch_timer.stop()
                    timerTriggered()
                }
            })
        }
    }
}

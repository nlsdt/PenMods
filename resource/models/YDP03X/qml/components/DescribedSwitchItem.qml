import QtQuick 2.12

import BaseQml 1.0
import "../common"
import "../components"

YSettingItemBackground {
    id: id_described_switch_item
    implicitHeight: Math.max(76, 68 + (id_describe.visible ? id_describe.contentHeight + 4 : 0))
    opacity: !enabled ? 0.6 : id_switch_state_button.pressed ? 0.85 : 1
    scale: (id_switch_state_button.pressed ? 0.99 : 1.0)

    Behavior on opacity {
        NumberAnimation {
            duration: 90
            easing.type: Easing.OutCubic
        }
    }

    Behavior on scale {
        NumberAnimation {
            duration: 90
            easing.type: Easing.OutCubic
        }
    }

    property alias title: id_title.text
    property alias description: id_describe.text
    property alias switchOn: id_switch_state.switchOn
    readonly property alias switchItem: id_switch_state
    readonly property alias describeItem: id_describe
    property bool toggleSwitchOnClick: true
    property alias interval: id_delay_switch_timer.interval

    signal clicked()
    signal timerTriggered()

    YText {
        id: id_title
        anchors.top: parent.top
        anchors.topMargin: 16
        anchors.left: parent.left
        anchors.leftMargin: 20
        font.pixelSize: 28
        width: parent.width - 140
        elide: Text.ElideRight
    }

    YText {
        id: id_describe
        anchors.top: id_title.bottom
        anchors.left: parent.left
        anchors.leftMargin: 20
        color: YColors.grayText
        font.pixelSize: 24
        visible: text.length > 0
        anchors.topMargin: 4
        width: parent.width - 140
        wrapMode: Text.Wrap
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
            if (toggleSwitchOnClick) switchOn = !switchOn
            id_described_switch_item.clicked()
            id_delay_switch_timer.restart()
        }
        objectName: "DescribedSwitchItem.qml_YMouseArea"
    }

    YTimer {
        id: id_delay_switch_timer
        interval: 600
        objectName: "DescribedSwitchItem.qml_id_delay_switch_timer"
        onTriggered: {
            timerTriggered()
        }
    }
}

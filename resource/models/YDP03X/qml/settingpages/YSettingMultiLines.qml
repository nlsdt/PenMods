import QtQuick 2.12

import BaseQml 1.0
import "../components"
import "../i18n"

YSettingItemPage {
    id: id_setting_item
    objectName: "YPage===YSettingMultiLines.qml"

    Item {
        id: id_setting_item_view
        anchors.fill: parent
        anchors.leftMargin: 90
        anchors.rightMargin: 16

        YSettingItemTitle {
            id: id_title_container
            title: YTranslateText.continueScanSetting
        }

        YSettingSwitchItem {
            id: id_switch_state_button_rect
            implicitHeight: 76
            anchors.top: id_title_container.bottom
            title: YTranslateText.continueScan
            switchOn: settingManager.isContinueScan
            interval: 0
            onTimerTriggered: {
                settingManager.isContinueScan = id_switch_state_button_rect.switchOn
            }
        }

        YText {
            id: id_speaking_vocal_label
            anchors.top: id_switch_state_button_rect.bottom
            anchors.topMargin: 10
            anchors.horizontalCenter: parent.horizontalCenter
            horizontalAlignment: YText.AlignHCenter
            font.pixelSize: 26
            textFormat: YText.RichText
            color: YColors.grayText
            text: YTranslateText.continueScanTip
        }
    }

}

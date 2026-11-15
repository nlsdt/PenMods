import QtQuick 2.12

import BaseQml 1.0
import "../components"
import "../i18n"

YSettingItemPage {
    id: id_setting_item
    objectName: "YPage===YSettingHandedness.qml"

    Item {
        id: id_setting_item_view
        anchors.fill: parent
        anchors.leftMargin: 90
        anchors.rightMargin: 16

        YSettingItemTitle {
            id: id_title_container
            title: YTranslateText.handednessSetting
        }

        Row {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: id_title_container.bottom
            spacing: 12

            YPressedButton {
                id: id_righthand_button
                implicitWidth: 341
                clickable: !settingManager.isRightHandMode
                checkedIndicatorScale: settingManager.isRightHandMode
                text: YTranslateText.handednessRight
                onClicked: {
                    settingManager.isRightHandMode = true
                }
            }

            YPressedButton {
                id: id_lefthand_button
                implicitWidth: 341
                clickable: settingManager.isRightHandMode
                checkedIndicatorScale: !settingManager.isRightHandMode
                text: YTranslateText.handednessLeft
                onClicked: {
                    settingManager.isRightHandMode = false
                }
            }
        }
    }
}

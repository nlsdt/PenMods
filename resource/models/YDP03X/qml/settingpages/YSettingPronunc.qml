import QtQuick 2.12
import com.youdao.pen 1.0

import BaseQml 1.0
import "../components"
import "../i18n"

// =====================================================================
// 自动发音设置（PenMods 覆盖版）
//
// 原生开关的 switchOn 是本地状态：点击后 `switchOn = !switchOn` 会打断
// 与 settingManager.isAutoPronounce 的绑定，因此即使 C++ 侧 setter 被
// PenMods「防尴尬→强制禁用自动发音」钩子强制写回 false，开关仍会视觉上
// 停在打开位。这里在锁定期间把开关禁用（置灰）+ 拉回关闭，并给出提示。
// =====================================================================

YSettingItemPage {
    id: id_setting_item
    objectName: "YPage===YSettingPronunc.qml"

    // PenMods 防尴尬「禁用自动发音」是否锁定中
    readonly property bool pronLocked: (typeof antiEmbs === "object" && antiEmbs !== null)
                                       ? antiEmbs.autoPronLocked : false

    Flickable {
        id: id_setting_item_view
        anchors.fill: parent
        anchors.leftMargin: 90
        anchors.rightMargin: 16
        contentHeight: 420

        YSettingItemTitle {
            id: id_title_container
            title: YTranslateText.autoPronounceSetting
        }

        YSettingSwitchItem {
            id: id_switch_state_button_rect
            implicitHeight: 76
            anchors.top: id_title_container.bottom
            title: YTranslateText.autoPronounce
            interval: 0
            enabled: !id_setting_item.pronLocked
            opacity: id_setting_item.pronLocked ? 0.4 : 1.0
            switchOn: settingManager.isAutoPronounce
            onTimerTriggered: {
                if (id_setting_item.pronLocked) {
                    // 被 PenMods 锁定：拉回关闭，不写设置
                    id_switch_state_button_rect.switchOn = false
                    return
                }
                settingManager.isAutoPronounce = id_switch_state_button_rect.switchOn
            }
        }

        Item {
            id: id_speaking_container
            anchors.top: id_switch_state_button_rect.bottom
            visible: settingManager.isAutoPronounce

            YText {
                id: id_speaking_vocal_label
                anchors.left: parent.left
                anchors.top: parent.bottom
                anchors.topMargin: 36
                font.pixelSize: 26
                color: YColors.grayText
                text: YTranslateText.pronounceChoice
            }

            Row {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: id_speaking_vocal_label.bottom
                anchors.topMargin: 20
                spacing: 12
                YPressedButton {
                    id: id_english_button
                    implicitWidth: 341
                    clickable: settingManager.autoPronounceType !== YEnum.UK
                    checkedIndicatorScale: settingManager.autoPronounceType === YEnum.UK
                    text: YTranslateText.pronounceEnglish
                    onClicked: {
                        settingManager.autoPronounceType = YEnum.UK
                    }
                }

                YPressedButton {
                    id: id_american_button
                    implicitWidth: 341
                    clickable: settingManager.autoPronounceType !== YEnum.US
                    checkedIndicatorScale: settingManager.autoPronounceType === YEnum.US
                    text: YTranslateText.pronounceAmerican
                    onClicked: {
                        settingManager.autoPronounceType = YEnum.US
                    }
                }
            }
        }

        // 锁定提示
        YText {
            anchors.top: id_speaking_container.bottom
            anchors.topMargin: 16
            anchors.left: parent.left
            anchors.right: parent.right
            font.pixelSize: 20
            color: YColors.grayText
            wrapMode: Text.Wrap
            visible: id_setting_item.pronLocked
            text: "暂不可修改"
        }
    }
}

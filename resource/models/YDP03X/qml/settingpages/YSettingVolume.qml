import QtQuick 2.12
import com.youdao.pen 1.0

import BaseQml 1.0
import "../components"
import "../i18n"

YPage {
    id: id_setting_item
    objectName: "YPage===YSettingVolume.qml"

    property alias title: id_title_container.title

    Flickable {
        id: id_setting_item_view
        anchors.fill: parent
        anchors.leftMargin: 90
        anchors.rightMargin: 16
        contentHeight: 378
        interactive: !id_slider_moving_timer.running

        Item {
            id: id_title_container
            anchors.left: parent.left
            anchors.right: parent.right
            implicitHeight: 80
            property alias title: id_title_item.text

            YText {
                id: id_title_item
                font.pixelSize: 26
                color: YColors.grayText
                anchors.verticalCenter: parent.verticalCenter
                text: YTranslateText.adjustVolume
            }
        }

        YSettingItemBackground {
            id: id_slider_rect
            implicitHeight: 100
            anchors.top: id_title_container.bottom

            YSlider {
                id: id_slider
                implicitWidth: 440
                anchors.centerIn: parent
                property int spkSettingVolume: settingManager.spkVolume
                onValueChanged: {
                    id_slider_moving_timer.restart()
                    if (spkSettingVolume != value) {
                        settingManager.setSpkVolume(value)
                    }
                }
                onSpkSettingVolumeChanged: {
                    if (spkSettingVolume != value) {
                        value = spkSettingVolume
                    }
                }
                Component.onCompleted: value = spkSettingVolume
            }

            YTimer {
                id: id_slider_moving_timer
                interval: 300
                objectName: "YSettingVolume.qml_id_slider_moving_timer"
            }

            YClickabledImage {
                anchors.verticalCenter: parent.verticalCenter
                anchors.right: id_slider.left
                anchors.rightMargin: 43
                imageName: "settings/sound-dec"
                onClicked: {
                    id_slider.decrementTenValue()
                }
            }

            YClickabledImage {
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: id_slider.right
                anchors.leftMargin: 43
                imageName: "settings/sound-inc"
                onClicked: {
                    id_slider.incrementTenValue()
                }
            }
        }

        YText {
            id: id_speaking_rate_label
            anchors.left: parent.left
            anchors.top: id_slider_rect.bottom
            anchors.topMargin: 36
            font.pixelSize: 26
            color: YColors.grayText
            text: YTranslateText.soundSpeedChoice
        }

        Row {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: id_speaking_rate_label.bottom
            anchors.topMargin: 20
            spacing: 12
            YPressedButton {
                id: id_quickly_button
                implicitWidth: 223
                clickable: settingManager.audioSpeed !== YEnum.SPEED_QUICK
                checkedIndicatorScale: settingManager.audioSpeed === YEnum.SPEED_QUICK
                text: YTranslateText.soundSpeedQuick
                onClicked: {
                    logManager.sendHttpLog("action=setting_sound_f_click")
                    settingManager.audioSpeed = YEnum.SPEED_QUICK
                    soundCenter.play("How are you", "en")
                }
            }

            YPressedButton {
                id: id_middle_button
                implicitWidth: 224
                clickable: settingManager.audioSpeed !== YEnum.SPEED_MID
                checkedIndicatorScale: settingManager.audioSpeed === YEnum.SPEED_MID
                text: YTranslateText.soundSpeedMiddle
                onClicked: {
                    logManager.sendHttpLog("action=setting_sound_m_click")
                    settingManager.audioSpeed = YEnum.SPEED_MID
                    soundCenter.play("How are you", "en")
                }
            }

            YPressedButton {
                id: id_slowly_button
                implicitWidth: 223
                clickable: settingManager.audioSpeed !== YEnum.SPEED_SLOW
                checkedIndicatorScale: settingManager.audioSpeed === YEnum.SPEED_SLOW
                text: YTranslateText.soundSpeedSlow
                onClicked: {
                    logManager.sendHttpLog("action=setting_sound_s_click")
                    settingManager.audioSpeed = YEnum.SPEED_SLOW
                    soundCenter.play("How are you", "en")
                }
            }
        }

    }

    YVerticalTitleBar {
        id: id_title_bar
        onCallBack: {
            soundCenter.stop()
            backButtonClicked()
        }
    }
}


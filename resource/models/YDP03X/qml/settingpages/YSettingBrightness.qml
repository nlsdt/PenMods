import QtQuick 2.12

import BaseQml 1.0
import "../components"
import "../i18n"

YSettingItemPage {
    id: id_setting_item
    objectName: "YPage===YSettingBrightness.qml"
    property alias title: id_title_container.title

    Item {
        anchors.fill: parent
        anchors.leftMargin: 90
        anchors.rightMargin: 16

        YSettingItemTitle {
            id: id_title_container
            title: YTranslateText.brightnessSetting
        }

        YSettingItemBackground {
            id: id_slider_rect
            implicitHeight: 100
            anchors.top: id_title_container.bottom
            anchors.left: id_title_container.left
            anchors.right: id_title_container.right

            YSlider {
                id: id_slider
                implicitWidth: 440
                anchors.centerIn: parent
                property int lcdSettingBrightness: settingManager.lcdBrightness
                onValueChanged: {
                    if (lcdSettingBrightness != value) {
                        settingManager.setLcdBrightness(value)
                    }
                }
                onLcdSettingBrightnessChanged: {
                    if (lcdSettingBrightness != value) {
                        value = lcdSettingBrightness
                    }
                }
                Component.onCompleted: value = settingManager.lcdBrightness
            }

            YClickabledImage {
                anchors.verticalCenter: parent.verticalCenter
                anchors.right: id_slider.left
                anchors.rightMargin: 43
                imageName: "settings/lum-dec"
                onClicked: {
                    id_slider.decrementTenValue()
                }
            }

            YClickabledImage {
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: id_slider.right
                anchors.leftMargin: 43
                imageName: "settings/lum-inc"
                onClicked: {
                    id_slider.incrementTenValue()
                }
            }
        }
    }
}


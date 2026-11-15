import QtQuick 2.12
import com.youdao.pen 1.0

import BaseQml 1.0
import "../i18n"

YSettingItemPage {
    id: id_setting_item
    objectName: "YPage===YSettingStorageInfo.qml"

    readonly property real totalSize:
        settingManager.storageFirmware + settingManager.storageResource
        + settingManager.storageUser + settingManager.storageAvailable

    readonly property real resourcePercentage: (settingManager.storageResource + settingManager.storageUser) * 1.0 / totalSize
    readonly property real systemPercentage: settingManager.storageFirmware * 1.0 / totalSize

    Item {
        anchors.fill: parent
        anchors.leftMargin: 90
        anchors.rightMargin: 20
        YSettingItemTitle {
            id: id_tip
            title: YTranslateText.usedMemory

            YTextMedium {
                id: id_tip_info
                readonly property real spaceUnit: 1024.0
                function usedStorage() {
//                    let fSystemSize = settingManager.storageFirmware / spaceUnit
//                    let fOtherSize = (settingManager.storageUser + settingManager.storageResource) / spaceUnit

//                    if((fSystemSize + fOtherSize).toFixed(2) >= parseInt(settingManager.memoryStorage))
//                        return settingManager.memoryStorage
//                    else
//                        return "" + (fSystemSize + fOtherSize).toFixed(2)

                    let fAvailableSize = settingManager.storageAvailable / spaceUnit

                    if (parseInt(settingManager.memoryStorage) >= fAvailableSize) {
                        return "" + (parseInt(settingManager.memoryStorage) - fAvailableSize).toFixed(2)
                    } else {
                        return settingManager.memoryStorage
                    }
                }
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                font.pixelSize: 24
                textFormat: YTextMedium.RichText
                text: ("%1GB<font color=\"%3\" weight: 400> / %2GB</font>")
                .arg(usedStorage())
                .arg(settingManager.memoryStorage)
                .arg(YColors.grayText)
            }
        }

        Rectangle {
            id: id_part_info
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: id_tip.bottom
            implicitHeight: 46
            color: "#2D2E33"
            radius: height/2
            smooth: true

            Item {
                id: id_progress_resource
                anchors.fill: parent
                smooth: true
                clip: true
                anchors.rightMargin: (1- resourcePercentage - systemPercentage) * id_part_info.width

                Rectangle {
                    id: id_indicator_resource_percentage
                    implicitWidth: id_part_info.width
                    implicitHeight: id_part_info.height
                    anchors.right: parent.right
                    anchors.rightMargin: -parent.anchors.rightMargin
                    color: YColors.red
                    radius: height/2
                    smooth: true
                }
            }

            Item {
                id: id_progress_system
                anchors.fill: parent
                smooth: true
                clip: true
                anchors.rightMargin: (1 - systemPercentage) * id_part_info.width

                Rectangle {
                    id: id_indicator_system_percentage
                    implicitWidth: id_part_info.width
                    implicitHeight: id_part_info.height
                    anchors.right: parent.right
                    anchors.rightMargin: -parent.anchors.rightMargin
                    color: "#878A99"
                    radius: height/2
                    smooth: true
                }
            }
        }

        Rectangle {
            id: id_indicator_system
            implicitWidth: 16
            implicitHeight: 16
            radius: height/2
            color: id_indicator_system_percentage.color
            anchors.left: parent.left
            anchors.leftMargin: 3
            anchors.top: id_part_info.bottom
            anchors.topMargin: 27
        }

        YText {
            id: id_indicator_system_lable
            font.pixelSize: 24
            color: YColors.grayText
            anchors.left: id_indicator_system.right
            anchors.leftMargin: 10
            anchors.verticalCenter: id_indicator_system.verticalCenter
            text: YTranslateText.system
        }

        Rectangle {
            id: id_indicator_resource
            implicitWidth: 16
            implicitHeight: 16
            radius: height/2
            color: id_indicator_resource_percentage.color
            anchors.left: id_indicator_system_lable.right
            anchors.leftMargin: 50
            anchors.verticalCenter: id_indicator_system.verticalCenter
        }

        YText {
            id: id_indicator_resource_lable
            font.pixelSize: 24
            color: YColors.grayText
            anchors.left: id_indicator_resource.right
            anchors.leftMargin: 10
            anchors.verticalCenter: id_indicator_system.verticalCenter
            text: YTranslateText.sourceFiles
        }

        Rectangle {
            id: id_indicator_total
            implicitWidth: 16
            implicitHeight: 16
            radius: height/2
            color: id_part_info.color
            anchors.left: id_indicator_resource_lable.right
            anchors.leftMargin: 50
            anchors.verticalCenter: id_indicator_system.verticalCenter
        }

        YText {
            id: id_indicator_total_lable
            font.pixelSize: 24
            color: YColors.grayText
            anchors.left: id_indicator_total.right
            anchors.leftMargin: 10
            anchors.verticalCenter: id_indicator_system.verticalCenter
            text: YTranslateText.freeMemory
        }
    }
}

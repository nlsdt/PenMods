import QtQuick 2.12
import com.youdao.pen 1.0

import BaseQml 1.0
import "../settingpages"
import "../i18n"
import "../components"

YBackgroundIgnoreMouseEvent {
    id: id_update_os_item
    objectName: "YSettingUpdateStorage.qml"
    anchors.fill: parent

    readonly property real totalSize:
        settingManager.storageFirmware + settingManager.storageResource
        + settingManager.storageUser + settingManager.storageAvailable

    readonly property real resourcePercentage: (settingManager.storageResource + settingManager.storageUser) * 1.0 / totalSize
    readonly property real systemPercentage: settingManager.storageFirmware * 1.0 / totalSize

    property string appName: ""
    property string confirmTip: ""

    signal nextStep()

    function showConfirmDialog(value) {
        appName = value
        confirmTip = YTranslateText.cleanConfirm.arg(appName)
        id_clean_confirm_dialog.show()
    }

    YVerticalTitleBarBase {
        objectName: "YVerticalTitleBar.qml"
        YBackButton {
            id: id_back_button
            onClicked: {
                id_setting_update_os_page.subPageCallBack()
            }
            objectName: "YVerticalTitleBar.qml_" + id_title_container.objectName
        }
    }

    Flickable {
        anchors.fill: parent
        anchors.leftMargin: 90
        anchors.rightMargin: 16
        contentHeight: id_update_prepare_col.height
        boundsBehavior: Flickable.StopAtBounds

        Column {
            id: id_update_prepare_col
            width: parent.width

            YSettingItemTitle {
                id: id_title_container
                title: YTranslateText.cleanStorage

                YTextMedium {
                    id: id_tip_info
                    readonly property real spaceUnit: 1024.0
                    function usedStorage() {
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
                    text: "%1GB<font color=\"%3\" weight: 400> / %2GB</font>".arg(usedStorage()).arg(settingManager.memoryStorage).arg(YColors.grayText)
                }
            }

            Rectangle {
                id: id_part_info
                anchors.left: parent.left
                anchors.right: parent.right
                implicitHeight: 46
                color: YColors.grayButton
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
                        color: YColors.blueRect
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
                        color: "#A8AAB3"
                        radius: height/2
                        smooth: true
                    }
                }
            }

            YSpacingForColumn {
                implicitHeight: 12
            }

            Row {
                width: parent.width
                height: 28
                spacing: 72
                anchors.left: parent.left
                anchors.leftMargin: 8

                Item {
                    width: 64
                    height: parent.height

                    Rectangle {
                        id: id_indicator_system
                        implicitWidth: 12
                        implicitHeight: 12
                        radius: height/2
                        color: id_indicator_system_percentage.color
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    YText {
                        id: id_indicator_system_lable
                        font.pixelSize: 24
                        color: YColors.grayText
                        anchors.right: parent.right
                        anchors.verticalCenter: id_indicator_system.verticalCenter
                        text: YTranslateText.system
                    }
                }

                Item {
                    width: 112
                    height: parent.height

                    Rectangle {
                        id: id_indicator_resource
                        implicitWidth: 12
                        implicitHeight: 12
                        radius: height/2
                        color: id_indicator_resource_percentage.color
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    YText {
                        id: id_indicator_resource_lable
                        font.pixelSize: 24
                        color: YColors.grayText
                        anchors.right: parent.right
                        anchors.verticalCenter: id_indicator_resource.verticalCenter
                        text: YTranslateText.sourceFiles
                    }
                }

                Item {
                    width: 112
                    height: parent.height

                    Rectangle {
                        id: id_indicator_total
                        implicitWidth: 12
                        implicitHeight: 12
                        radius: height/2
                        color: id_part_info.color
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    YText {
                        id: id_indicator_total_lable
                        font.pixelSize: 24
                        color: YColors.grayText
                        anchors.right: parent.right
                        anchors.verticalCenter: id_indicator_total.verticalCenter
                        text: YTranslateText.freeMemory
                    }
                }
            }

            YSpacingForColumn {
                implicitHeight: 12
            }


            Column {
                width: parent.width
                spacing: 12

                YSettingUpdateCleanStorageItem {
                    title: YTranslateText.listeningExercise
                    onButtonClicked: {
                        showConfirmDialog(title)
                    }
                }

                YSettingUpdateCleanStorageItem {
                    title: YTranslateText.textbookSynchronous
                    onButtonClicked: {
                        showConfirmDialog(title)
                    }
                }

                YSettingUpdateCleanStorageItem {
                    title: YTranslateText.touchreading
                    onButtonClicked: {
                        showConfirmDialog(title)
                    }
                }

                YText {
                    width: parent.width
                    height: 26
                    lineHeight: 26
                    font.pixelSize: 22
                    color: YColors.grayText
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "如空间仍不足，请将USB连接电脑，手动删除之前导入词典笔的文件"
                }
            }

            YSpacingForColumn {
                implicitHeight: 28
            }
        }
    }

    YOneButtonDialog {
        id: id_clean_confirm_dialog
        anchors.fill: parent
        tipItem.text: confirmTip
        buttonItem.text: YTranslateText.cleanAll

        onClicked: {
            console.warn("YSettingUpdateStorage.qml===cleanConfirmClicked===  appName: " + appName)
            switch(appName) {
            case YTranslateText.listeningExercise:
                //清除听力练习
                updateOsManager.deleteAudio();
                break;
            case YTranslateText.textbookSynchronous:
                //清除教材同步
                updateOsManager.deleteTextBook();
                break;
            case YTranslateText.touchreading:
                //清除图书点读
                updateOsManager.deleteTouchBook();
                break;
            default:
                break;
            }
            id_clean_confirm_dialog.close()
        }
    }

    YTimer {
        id: id_refresh_storage_timer
        interval: 1000
        repeat: true
        onTriggered: {
            settingManager.updateSystemInfo()
        }
    }

    Component.onCompleted: {
        // 定时刷新容量信息
        id_refresh_storage_timer.restart()
    }

    Component.onDestruction: {
        id_refresh_storage_timer.stop()
    }
}


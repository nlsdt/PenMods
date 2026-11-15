import QtQuick 2.12
import com.youdao.pen 1.0

import BaseQml 1.0
import "../components"
import "../i18n"
import "../update"

YSettingItemPage {
    id: id_setting_item
    objectName: "YPage===YSettingUpdate.qml"

//    readonly property string currentVersion: updateManager.currentVersion
//    readonly property string targetVersion: "YDP021_1.3.5" // updateManager.targetVersion
//    readonly property string updateNote: "1. 「语音翻译」43种语言在线互译\n2. 「拍照翻译」快捷重拍和阅读模式\n3.  下拉菜单支持快捷设置" // updateManager.updateNote
//    readonly property real updateImgSize: 300 // updateManager.updateImgSize
//    readonly property int downloadProgress: 45 // updateManager.downloadProgress
//    readonly property int installProgress: 38 // updateManager.installProgress
//    readonly property int otaStatus: YEnum.UPDATE_HAS_NEW_VERSION // updateManager.otaStatus

    readonly property string currentVersion: updateManager.currentVersion
    readonly property string targetVersion:  updateManager.targetVersion
    readonly property string updateNote: updateManager.updateNote
    readonly property real updateImgSize: updateManager.updateImgSize
    readonly property int downloadProgress: updateManager.downloadProgress
    readonly property int installProgress: updateManager.installProgress
    readonly property int otaStatus: updateManager.otaStatus
    readonly property bool isABSameVersion: updateManager.isABSameVersion

    readonly property bool isOSVersion:  updateManager.isOSVersion //Number(targetVersion.split(".")[0]) >= 3

    function checkUpdate() {
        updateManager.checkOtaUpdate()
    }

    // 开始下载新版本
    function downloadStart() {
        updateManager.downloadStart()
    }

    // 暂停下载新版本
    function downloadPause() {
        updateManager.downloadPause()
    }

    // 恢复下载新版本
    function downloadResume() {
        updateManager.downloadResume()
    }

    // 安装新版本
    function install() {
        updateManager.install()
    }

    // 取消安装新版本
    function cancelInstall() {
//        updateManager.cancelInstall()
    }

    function closeSettingUpdatePage() {
        backButtonClicked()
    }

    Connections {
        target: updateManager
        ignoreUnknownSignals: true
        function onCurrentVersionChanged() {
            console.log("ZDS===YSettingUpdate.qml===onCurrentVersionChanged:",
                        currentVersion)
        }
        function onTargetVersionChanged() {
            console.log("ZDS===YSettingUpdate.qml===targetVersionChanged:",
                        targetVersion)
        }
        function onUpdateNoteChanged() {
            console.log("ZDS===YSettingUpdate.qml===updateNoteChanged:",
                        updateNote)
        }
        function onOtaStatusChanged() {
            console.log("ZDS===YSettingUpdate.qml===onOtaStatusChanged:",
                        otaStatus)
            switch (otaStatus) {
                case YEnum.UPDATE_LATEST_VERSION: // 已安装最新版本，无需升级
                    break
            }
        }

        function onIsOSVersionChanged() {
            console.log("SXR===YSettingUpdate.qml===isOSVersionChanged:",
                        isOSVersion)
        }
    }

    Item {
        id: id_setting_item_view
        anchors.fill: parent
        anchors.leftMargin: 90
        anchors.rightMargin: 16

        YSettingItemTitle {
            id: id_title_container
            title: YTranslateText.update
        }

        YSettingUpdateCheckUpdate {
            anchors.top: id_title_container.bottom
            anchors.topMargin: 40
        }

        YSettingUpdateNoUpdate {
            anchors.top: id_title_container.bottom
            anchors.topMargin: 20
        }

        YSettingUpdateABSyncing {
            anchors.top: id_title_container.bottom
            anchors.topMargin: 40
        }
    }

    YSettingUpdateCheckNetworkLoader {
        id: id_setting_update_check_network_loader
        onCheckNetwork: {
            id_pop_layer.show("settingpages/YSettingWifi")
            id_pop_layer.popItemObject.backButtonClickedCallback.connect(backButtonClicked)
        }
    }

    YSettingUpdateDownloadLoader {
        id: id_setting_update_download_loader
    }

    YSettingUpdateOS {
        id: id_setting_update_os_loader
        active: isOSVersion && isABSameVersion
                && ((YEnum.UPDATE_HAS_NEW_VERSION === otaStatus)
                    || (YEnum.UPDATE_DOWNLOAD_PAUSE === otaStatus)
                    || (YEnum.UPDATE_DOWNLOADING === otaStatus)
                    || (YEnum.UPDATE_ERROR_NO_ENOUGH_MEMORY === otaStatus)
                    || (YEnum.UPDATE_DOWNLOAD_FINISHED === otaStatus)
                    || (YEnum.UPDATE_INSTALLING === otaStatus)
                    || (YEnum.UPDATE_MD5_CHECKING === otaStatus)
                    || (YEnum.UPDATE_MD5_CHECK_SUCCESSFULLY === otaStatus)
                    || (YEnum.UPDATE_ERROR_MD5_CHECK === otaStatus)
                    || (YEnum.UPDATE_INSTALL_FAILED === otaStatus)
                    || (YEnum.UPDATE_INSTALL_SUCCESSFULLY === otaStatus))
    }

    YSettingUpdateLowPowerLoader {
        id: id_setting_update_low_power_loader
    }

    YPopLayer {
        id: id_pop_layer
        onPopItemObjectChanged: {
            if (null !== popItemObject) {
                popItemObject.backButtonClicked.connect(function(){
                    checkUpdate()
                })
            }
        }
    }

    onBackButtonClicked: {
        console.warn("YSettingUpdate.qml===onBackButtonClicked===")
    }
}

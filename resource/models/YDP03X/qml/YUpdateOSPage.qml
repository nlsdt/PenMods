import QtQuick 2.12
import com.youdao.pen 1.0
import QtGraphicalEffects 1.14

import BaseQml 1.0
import "./commons"
import "./components"
import "./settingpages"
import "./timers"
import "./i18n"

YPage {
    id: id_update_OS_page
    objectName: "YPage===YUpdateOSPage.qml"

    property int leftSeconds: updateOsManager.updateTime
    property int currentProgress: Math.min(100, Math.max(0, updateOsManager.updateProgress))
    property int currentStep: updateOsManager.osstate
    property bool updateCheckFailed: false
    property string stepTip: "系统正在升级..."

    function updateTips() {
        let time
        if (leftSeconds > 60) {
            let m = Math.min(132, parseInt(leftSeconds/60))
            time = m + "分钟"
        } else {
            let m = Math.max(1, leftSeconds)
            time = m + "秒钟"
        }
        id_tips.text = ("系统升级中，预计还需要%1，词典笔可能重启多次，请您耐心等待，切勿暴力关机").arg('<font color="%2">%1</font>'.arg(time).arg(YColors.blueText))
    }

    function updateCurrentStep() {
        settingManager.updateSystemInfo()
        let step = ""
        switch (currentStep) {
        case YEnum.StartUpSerDataState:
            step = "开始向服务端同步数据"
            break
        case YEnum.UploadingSerDataStateState:
            step = "正在向服务端同步数据..."
            break
        case YEnum.UploadingSuccessSerDataState:
            step = "同步数据成功"
            break
        case YEnum.StartDowningResourceState:
            step = "开始下载资源包"
            break
        case YEnum.DowningResourceState:
            step = "正在下载资源包..."
            break
        case YEnum.DowningResourceSuccessState:
            step = "下载资源包成功"
            break
        case YEnum.StartBackupingDataState:
            step = "开始备份数据（历史记录、教材同步等数据）"
            break
        case YEnum.BackupingDataState:
            step = "正在备份数据（历史记录、教材同步等数据）..."
            break
        case YEnum.BackupingSuccessDataState:
            step = "备份数据完成"
            break
        case YEnum.StartDowingOtState:
            step = "开始下载新版本安装包"
            break
        case YEnum.DowingOtaState:
            step = "正在下载新版本安装包..."
            break
        case YEnum.DowingOtaSuccessState:
            step = "下载安装包完成"
            break
        case YEnum.InstingOtastate:
            step = "正在安装新版本系统..."
            break
        case YEnum.InstingOtaSuccessState:
            step = "安装成功"
            break
        case YEnum.DowningResourceCheckFailState:
        case YEnum.BackupingCheckFailDataState:
        case YEnum.DowingOtaCheckFailState:
        case YEnum.InstingOtaCheckFailState:
        case YEnum.UploadingCheckFailSerDataState:
            step = "checkFailed"
            break
        case YEnum.DowningResourceFailState:
        case YEnum.BackupingFailDataState:
        case YEnum.DowingOtaFailState:
        case YEnum.InstingOtaFailState:
        case YEnum.UploadingFailSerDataState:
            step = "updateFailed"
            break
        default:
            step = "系统正在升级..."
            break
        }

        if (step === "updateFailed") {
            id_update_failed_dialog.show()
            updateCheckFailed = false
        } else if (step === "checkFailed") {
            updateCheckFailed = true
            id_update_failed_dialog.close()
        } else {
            stepTip = step
            updateCheckFailed = false
            id_update_failed_dialog.close()
        }
    }

    YClickedCountMouseArea {
        anchors.fill: parent
        onTriggered: {
            settingManager.openAdb()
        }
        objectName: "YUpdateOSPage.qml_id_open_adb_button"
    }

    YText {
        id: id_tips
        width: 648
        color: "#A8AAB2"
        font.pixelSize: 28
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: 36
        textFormat: YText.RichText
        wrapMode: YTextBase.Wrap
        horizontalAlignment: YText.AlignHCenter
    }

    Item {
        id: id_progress_indicator
        width: 640
        height: 10
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 58
        property int progress: Math.min(100, Math.max(5, currentProgress))

        Rectangle {
            id: id_background
            width: parent.width
            height: parent.height
            anchors.verticalCenter: parent.verticalCenter
            color: "#1A1B1F"
            radius: 16

            readonly property int stepValue: Math.ceil(width / 100.0)
        }

        Rectangle {
            id: id_foreground
            height: parent.height
            width: Math.min(id_background.stepValue * currentProgress, id_background.width)
            anchors.verticalCenter: parent.verticalCenter
            radius: id_background.radius
            visible: width > 16
            color: "#2D73DC"
        }
    }



    YText {
        id: id_current_step_tip
        color: YColors.white
        font.pixelSize: 26
        anchors.left: parent.left
        anchors.leftMargin: 80
        anchors.bottom: id_progress_indicator.top
        anchors.bottomMargin: 6
        text: stepTip + ("（%1%）").arg(currentProgress)
    }

    YSettingUpdateOS {
        id: id_update_os_suspend_loader
        isUpdateSuspending: true
        active: updateCheckFailed
    }

    YOneButtonDialog {
        id: id_update_failed_dialog
        anchors.fill: parent
        tipItem.text: YTranslateText.updateFailed
        buttonItem.text: YTranslateText.backToHome
        onClicked: {
            id_update_OS_page.close()
            qmlGlobal.backToHomePage()
        }

        onClosed: {
            id_update_OS_page.close()
            qmlGlobal.backToHomePage()
        }
    }

    onLeftSecondsChanged: {
        updateTips()
    }

    onCurrentStepChanged: {
        updateCurrentStep()
    }

    Component.onCompleted: {
        console.log("YUpdateOSPage.qml===Component.onCompleted===called")
        updateTips()
        updateCurrentStep()
    }

    Component.onDestruction: {
        console.log("YUpdateOSPage.qml===Component.onDestruction===called")
    }

    onVisibleChanged: {
        if (visible) {
            qmlGlobal.currentPageIndex = YEnum.PageIndex.UpdateOS
        }
    }
}

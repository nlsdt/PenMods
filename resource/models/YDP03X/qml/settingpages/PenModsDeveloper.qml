import QtQuick 2.12
import com.youdao.pen 1.0
import BaseQml 1.0

PenModsSettingsPage {
    id: page
    title: "开发者选项"

    PenModsSwitchRow { title: "关闭离线资源管理"; checked: developerSettings.offlineRM; onRowToggled: developerSettings.offlineRM = checked }
    PenModsSettingRow { title: "离线教材"; onClicked: page.openPage("PenModsTextbooks") }
    PenModsSwitchRow { title: "提高单次列表加载数量"; checked: columnDb.patch; onRowToggled: columnDb.patch = checked }
    PenModsSettingRow {
        title: "ADB 服务"; value: serviceManager.adbStatus ? "运行中" : "已停止"
        onClicked: { if (serviceManager.adbStatus) serviceManager.stopAdb(); else serviceManager.startAdb(); }
    }
    PenModsSwitchRow { title: "ADB 开机自启"; checked: serviceManager.adbAutoRun; onRowToggled: serviceManager.adbAutoRun = checked }
    PenModsSwitchRow { title: "跳过 ADB 验证"; checked: serviceManager.skipAdbVerification; onRowToggled: serviceManager.skipAdbVerification = checked }
    PenModsSettingRow {
        title: "SSH 服务"; value: serviceManager.sshStatus ? "运行中" : "已停止"
        onClicked: { if (serviceManager.sshStatus) serviceManager.stopSsh(); else serviceManager.startSsh(); }
    }
    PenModsSwitchRow { title: "SSH 开机自启"; checked: serviceManager.sshAutoRun; onRowToggled: serviceManager.sshAutoRun = checked }
    PenModsSettingRow {
        title: "修改 root 密码"
        onClicked: page.editText("请输入新的 root 密码", "", function(text) { return serviceManager.setSshRootPasswd(text); }, true)
    }
    PenModsSettingRow { title: "刷新服务状态"; onClicked: serviceManager.refresh() }
    Component.onCompleted: serviceManager.refresh()

}

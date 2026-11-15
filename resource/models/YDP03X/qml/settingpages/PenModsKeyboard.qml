import QtQuick 2.12
import com.youdao.pen 1.0
import BaseQml 1.0

PenModsSettingsPage {
    id: page
    title: "键盘与输入法"

    PenModsSettingRow { title: "Rime 输入方案"; value: rime.currentSchemaId; onClicked: page.openPage("PenModsRimeSchemas") }
    PenModsSettingRow {
        title: rime.deploying ? "正在重新部署…" : "重新部署 Rime"
        description: "更新输入方案或词库后执行。"
        enabled: !rime.deploying && !rime.syncing
        onClicked: rime.redeploy()
    }
    PenModsSettingRow {
        title: rime.syncing ? "正在同步…" : "同步用户词库"
        enabled: !rime.deploying && !rime.syncing
        onClicked: rime.syncUserData()
    }
    PenModsSettingRow { title: "Rime 数据目录"; description: "/userdisk/Music/Rime"; interactive: false }
    Connections {
        target: rime
        function onDeployFinished(success) { baseSignals.showToast(success ? "Rime 部署完成" : "Rime 部署失败", success ? "#64D99A" : "#E9900C"); }
        function onSyncFinished(success) { baseSignals.showToast(success ? "词库同步完成" : "词库同步失败", success ? "#64D99A" : "#E9900C"); }
    }

}

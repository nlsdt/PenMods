import QtQuick 2.12
import com.youdao.pen 1.0

PenModsSettingsPage {
    id: page
    title: "更新与维护"
    PenModsSettingRow { title: "当前 PenMods 版本"; value: updater.currentVersion; interactive: false }
    PenModsSettingRow {
        title: "三代更新源"; description: updater.source.length ? updater.source : "填写三代独立更新清单地址"
        enabled: !updater.busy
        onClicked: page.editText("三代更新清单 URL（可留空）", updater.source, function(text) {
            updater.source = text;
            return updater.source === text.trim();
        }, false, true)
    }
    PenModsSettingRow {
        title: updater.statusText
        value: updater.busy ? updater.progress + "%" : updater.targetVersion
        description: updater.note
        interactive: false
    }
    PenModsSettingRow { title: "检查更新"; enabled: !updater.busy && updater.source.length > 0; onClicked: updater.check() }
    PenModsSettingRow { title: "下载更新"; visible: updater.canDownload; onClicked: updater.download() }
    PenModsSettingRow {
        title: "安装更新"; visible: updater.canInstall
        onClicked: page.confirmAction("安装已下载的三代 PenMods 更新？", function() { updater.install(); })
    }
    PenModsSettingRow {
        title: "重新启动应用"; enabled: !updater.busy
        onClicked: page.confirmAction("重新启动词典笔应用？", function() { mod.softReboot(); })
    }
    PenModsSettingRow {
        title: "重新启动设备"; enabled: !updater.busy
        onClicked: page.confirmAction("重新启动设备？", function() { mod.reboot(); })
    }
    PenModsSettingRow {
        title: "卸载 PenMods"; enabled: !updater.busy
        description: "从本机备份恢复原程序，扩展功能将停用。"
        onClicked: page.confirmAction("恢复原程序并卸载 PenMods？", function() { mod.uninstall(); })
    }
}

import QtQuick 2.12
import com.youdao.pen 1.0
import BaseQml 1.0

PenModsSettingsPage {
    id: page
    title: "PenMods 设置"

    function protectedPage(name, scene) {
        if (locker.enabled && (!scene || locker.getScene(scene))) {
            editText("请输入安全锁密码", "", function(text) {
                if (text !== locker.password) {
                    baseSignals.showToast("密码错误，请重试", "#E9900C");
                    return false;
                }
                page.openPage(name);
            }, true);
        } else openPage(name);
    }
    PenModsSettingRow { title: "息屏与电源"; value: screenManager.autoSleepDuration; onClicked: page.openPage("PenModsPower") }
    PenModsSettingRow { title: "音乐与播放"; onClicked: page.openPage("PenModsMusic") }
    PenModsSettingRow { title: "键盘与输入法"; onClicked: page.openPage("PenModsKeyboard") }
    PenModsSettingRow { title: "查询设置"; onClicked: page.openPage("QuerySettingPage") }
    PenModsSettingRow { title: "自定义词典"; value: customDict.dictionaries.length + " 本"; onClicked: page.openPage("CustomDictPage") }
    PenModsSettingRow { title: "单词本"; onClicked: page.openPage("PenModsWordbook") }
    PenModsSettingRow { title: "网络与代理"; value: networkSettings.proxyEnabled ? "代理已启用" : ""; onClicked: page.openPage("PenModsNetwork") }
    PenModsSettingRow { title: "防尴尬"; onClicked: page.openPage("PenModsAntiEmbs") }
    PenModsSettingRow { title: "安全锁"; value: locker.enabled ? "已启用" : "未启用"; onClicked: page.protectedPage("PenModsLocker", "") }
    PenModsSettingRow { title: "日志与隐私"; onClicked: page.openPage("PenModsLogger") }
    PenModsSettingRow { title: "壁纸"; onClicked: page.openPage("WallpaperSettingPage") }
    PenModsSettingRow { title: "电池信息"; onClicked: page.openPage("PenModsBattery") }
    PenModsSwitchRow { title: "手电筒"; checked: torch.switch; onRowToggled: torch.switch = checked }
    PenModsSettingRow { title: "实验性功能"; onClicked: page.openPage("PenModsExperimental") }
    PenModsSettingRow { title: "开发者选项"; onClicked: page.protectedPage("PenModsDeveloper", "dev_setting") }
    PenModsSettingRow { title: "更新与维护"; onClicked: page.protectedPage("PenModsMaintenance", "dev_setting") }
    PenModsSettingRow { title: "关于 PenMods"; value: mod.version; onClicked: page.openPage("PenModsAbout") }

}

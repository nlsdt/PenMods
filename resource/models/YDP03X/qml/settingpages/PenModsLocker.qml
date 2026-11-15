import QtQuick 2.12
import com.youdao.pen 1.0
import BaseQml 1.0

PenModsSettingsPage {
    id: page
    title: "安全锁"

    PenModsSwitchRow { title: "启用安全锁"; checked: locker.enabled; onRowToggled: locker.enabled = checked }
    PenModsSettingRow {
        title: "修改密码"; value: locker.password.length ? "已设置" : "未设置"
        onClicked: page.editText("请输入新密码", "", function(text) {
            if (!text.length) return false;
            locker.password = text;
            baseSignals.showToast("安全锁密码已更新", "#64D99A");
        }, true)
    }
    PenModsSettingRow { title: "需要密码的场景"; onClicked: page.openPage("LockSceneSettingPage") }

}

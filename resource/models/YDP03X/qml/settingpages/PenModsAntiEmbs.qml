import QtQuick 2.12
import com.youdao.pen 1.0
import BaseQml 1.0

PenModsSettingsPage {
    id: page
    title: "防尴尬"

    PenModsSwitchRow { title: "蓝牙断连自动静音"; checked: antiEmbs.autoMute; onRowToggled: antiEmbs.autoMute = checked }
    PenModsSwitchRow { title: "强制禁用自动发音"; checked: antiEmbs.autoPronLocked; onRowToggled: antiEmbs.autoPronLocked = checked }
    PenModsSwitchRow { title: "降低最低音量"; checked: antiEmbs.lowVoiceMode; onRowToggled: antiEmbs.lowVoiceMode = checked }
    PenModsSwitchRow { title: "快速静音"; checked: antiEmbs.fastMute; onRowToggled: antiEmbs.fastMute = checked }
    PenModsSwitchRow {
        title: "快速隐藏"; description: "连按 4 次 Home 隐藏文件和扩展入口。"
        checked: antiEmbs.fastHide; onRowToggled: antiEmbs.fastHide = checked
    }
    PenModsSettingRow {
        visible: antiEmbs.active
        title: "退出隐藏模式"
        onClicked: {
            if (locker.enabled && locker.getScene("antiembs_deactivate"))
                page.pageHost.editAntiEmbsUnlock();
            else antiEmbs.deactivate("");
        }
    }

}

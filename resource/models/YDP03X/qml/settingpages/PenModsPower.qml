import QtQuick 2.12
import com.youdao.pen 1.0
import BaseQml 1.0

PenModsSettingsPage {
    id: page
    title: "息屏与电源"

    PenModsSettingRow { title: "自动息屏"; value: screenManager.autoSleepDuration; onClicked: page.openPage("PenModsAutoScreenOff") }
    PenModsSettingRow { title: "自动休眠"; value: batteryInfo.autoSuspendDuration; onClicked: page.openPage("PenModsAutoSuspend") }
    PenModsSettingRow { title: "无操作自动关机"; value: screenManager.autoShutdownDuration; onClicked: page.openPage("PenModsAutoShutdown") }
    PenModsSwitchRow {
        title: "场景保持亮屏"
        description: "查看单词卡或播放歌词时保持亮屏，离开后恢复自动息屏。"
        checked: screenManager.intelSleep
        onRowToggled: screenManager.intelSleep = checked
    }
    PenModsSwitchRow {
        title: "播放音频时保持唤醒"
        description: "保持屏幕点亮并阻止自动休眠、无操作关机。手动设置的音乐关机定时仍会执行。"
        checked: screenManager.intelSleepAudioLock
        onRowToggled: screenManager.intelSleepAudioLock = checked
    }

}

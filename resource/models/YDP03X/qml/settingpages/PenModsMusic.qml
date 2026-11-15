import QtQuick 2.12
import com.youdao.pen 1.0
import BaseQml 1.0

PenModsSettingsPage {
    id: page
    title: "音乐与播放"

    PenModsSwitchRow {
        title: "扫描时暂停播放"
        description: "保留歌曲进度，查询结束后可继续播放。"
        checked: musicPlayer.pauseOnScan
        onRowToggled: musicPlayer.pauseOnScan = checked
    }
    PenModsSwitchRow {
        title: "隐藏音乐悬浮窗"
        description: "关闭播放页后，可从下拉面板继续控制音乐。"
        checked: musicPlayer.hideFloatingWindow
        onRowToggled: musicPlayer.hideFloatingWindow = checked
    }
    PenModsSettingRow {
        title: "定时关机"
        value: !musicPlayer.shutdownTimerEnabled ? "关闭" : musicPlayer.shutdownAfterPlaylist ? "播放结束" : musicPlayer.shutdownTimerMinutes + " 分钟"
        onClicked: page.openPage("PenModsMusicTimer")
    }
    PenModsSettingRow {
        title: "播放顺序"
        value: ["顺序播放", "随机播放", "单曲循环", "单曲播放"][settingManager.audioSequence] || "系统设置"
        onClicked: settingManager.audioSequence = (settingManager.audioSequence + 1) % 4
    }

}

import QtQuick 2.12
import com.youdao.pen 1.0
import BaseQml 1.0

PenModsSettingsPage {
    id: page
    title: "音乐定时关机"

    Repeater {
        model: [0, 15, 20, 30, 45, 60, 120]
        delegate: PenModsSettingRow {
            title: modelData === 0 ? "关闭" : modelData + " 分钟后关机"
            checked: modelData === 0 ? !musicPlayer.shutdownTimerEnabled
                     : musicPlayer.shutdownTimerEnabled && !musicPlayer.shutdownAfterPlaylist && musicPlayer.shutdownTimerMinutes === modelData
            onClicked: musicPlayer.setShutdownTimerMinutes(modelData)
        }
    }
    PenModsSettingRow {
        title: "顺序播放结束后关机"
        description: "播放列表最后一首结束后关机。"
        checked: musicPlayer.shutdownAfterPlaylist && musicPlayer.shutdownTimerEnabled
        onClicked: {
            settingManager.audioSequence = YEnum.AS_ORDER;
            musicPlayer.shutdownAfterPlaylist = true;
        }
    }

}

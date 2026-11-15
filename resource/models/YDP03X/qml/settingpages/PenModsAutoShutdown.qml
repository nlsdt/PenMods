import QtQuick 2.12
import com.youdao.pen 1.0
import BaseQml 1.0

PenModsSettingsPage {
    id: page
    title: "无操作自动关机"

    Repeater {
        model: ["关闭","5分钟","10分钟","20分钟","30分钟","60分钟","120分钟"]
        delegate: PenModsSettingRow {
            title: modelData
            checked: screenManager.autoShutdownDuration === modelData
            onClicked: screenManager.autoShutdownDuration = modelData
        }
    }

}

import QtQuick 2.12
import com.youdao.pen 1.0
import BaseQml 1.0

PenModsSettingsPage {
    id: page
    title: "无操作自动休眠"

    Repeater {
        model: ["5分钟","10分钟","20分钟","40分钟","永不"]
        delegate: PenModsSettingRow {
            title: modelData
            checked: batteryInfo.autoSuspendDuration === modelData
            onClicked: batteryInfo.autoSuspendDuration = modelData
        }
    }

}

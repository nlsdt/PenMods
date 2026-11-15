import QtQuick 2.12
import com.youdao.pen 1.0
import BaseQml 1.0

PenModsSettingsPage {
    id: page
    title: "自动息屏（提前 10 秒变暗）"

    Repeater {
        model: ["30秒","1分钟","2分钟","3分钟","4分钟","5分钟","永不"]
        delegate: PenModsSettingRow {
            title: modelData
            checked: screenManager.autoSleepDuration === modelData
            onClicked: screenManager.autoSleepDuration = modelData
        }
    }

}

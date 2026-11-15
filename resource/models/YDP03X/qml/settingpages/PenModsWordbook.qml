import QtQuick 2.12
import com.youdao.pen 1.0
import BaseQml 1.0

PenModsSettingsPage {
    id: page
    title: "单词本增强"

    PenModsSwitchRow {
        title: "单词与短语分类"; checked: workBookTweaks.phraseTab
        description: "区分单个单词和含空格的短语。重新打开单词本生效。"
        onRowToggled: workBookTweaks.phraseTab = checked
    }
    PenModsSwitchRow {
        title: "忽略大小写"; checked: workBookTweaks.noCaseSensitive
        onRowToggled: workBookTweaks.noCaseSensitive = checked
    }
    PenModsSettingRow {
        title: workBookTweaks.exporting ? "正在导出…" : "导出单词本"
        value: workBookTweaks.exporting ? workBookTweaks.exportProgress + "%" : ""
        enabled: !workBookTweaks.exporting
        onClicked: workBookTweaks.doExport()
    }

}

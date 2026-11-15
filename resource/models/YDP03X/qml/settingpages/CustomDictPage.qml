import QtQuick 2.12
import "../components"
import "../dicts/YDictPenModsBlocks.js" as PenModsBlocks

PenModsSettingsPage {
    id: page
    title: "自定义词典"
    readonly property var recordBlocks: {
        if (!customDict.record.length) return [];
        try { return PenModsBlocks.blocks(JSON.parse(customDict.record)); }
        catch (e) { return [{"type": "raw", "text": customDict.record}]; }
    }
    Component.onCompleted: customDict.refresh()
    PenModsSettingRow { title: "刷新词典列表"; description: customDict.directory; onClicked: customDict.refresh() }
    Repeater {
        model: customDict.dictionaries
        delegate: PenModsSettingRow {
            title: modelData.name
            value: modelData.words + " 词"
            checked: index === customDict.index
            onClicked: customDict.index = index
        }
    }
    PenModsSettingRow {
        title: "输入查询"; value: customDict.word
        enabled: customDict.dictionaries.length > 0
        onClicked: page.editText("请输入要查询的词", customDict.word, function(text) { customDict.lookupWord(text); })
    }
    PenModsSettingRow { title: customDict.status; interactive: false }
    Item {
        width: parent.width
        height: content.height
        YCustomDictContentView {
            id: content
            width: parent.width
            blocks: page.recordBlocks
        }
    }
}

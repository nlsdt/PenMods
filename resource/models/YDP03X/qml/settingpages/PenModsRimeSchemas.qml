import QtQuick 2.12
import com.youdao.pen 1.0
import BaseQml 1.0

PenModsSettingsPage {
    id: page
    title: "选择 Rime 输入方案"

    property var schemas: []
    function reload() {
        try { schemas = JSON.parse(rime.schemaListJson()); }
        catch (e) { schemas = []; }
        rime.refreshCurrentSchema();
    }
    Component.onCompleted: reload()
    PenModsSettingRow { title: "刷新方案列表"; onClicked: page.reload() }
    PenModsSettingRow {
        visible: page.schemas.length === 0
        title: "未找到可用方案"
        description: "将方案放入 Rime 数据目录，返回后重新部署。"
        interactive: false
    }
    Repeater {
        model: page.schemas
        delegate: PenModsSettingRow {
            title: modelData.name
            value: modelData.id
            checked: rime.currentSchemaId === modelData.id
            onClicked: {
                if (!rime.selectSchema(modelData.id))
                    baseSignals.showToast("切换输入方案失败", "#E9900C");
            }
        }
    }

}

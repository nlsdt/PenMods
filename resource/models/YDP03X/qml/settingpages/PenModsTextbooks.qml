import QtQuick 2.12

PenModsSettingsPage {
    id: page
    title: "离线教材"
    PenModsSettingRow { title: "已识别教材"; value: textBookHelper.installedCount + " 本"; interactive: false }
    PenModsSettingRow { title: "教材目录"; description: textBookHelper.directory; interactive: false }
    PenModsSettingRow {
        title: "重新扫描并导入"
        description: "教材包放在教材 ID/package/package.zip，已解压的包可直接识别。"
        onClicked: {
            textBookHelper.onUiCompleted();
            baseSignals.showToast("已识别 " + textBookHelper.installedCount + " 本离线教材", "#64D99A");
        }
    }
}

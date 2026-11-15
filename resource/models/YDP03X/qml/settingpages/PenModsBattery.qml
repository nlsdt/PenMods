import QtQuick 2.12

PenModsSettingsPage {
    id: page
    title: "电池信息"
    PenModsSettingRow { title: "状态"; value: batteryInfo.status; interactive: false }
    PenModsSettingRow { title: "当前电压"; value: batteryInfo.voltage; interactive: false }
    PenModsSettingRow { title: "电池温度"; value: batteryInfo.temperature; interactive: false }
    PenModsSettingRow { title: "电池健康"; value: batteryInfo.health; interactive: false }
    PenModsSettingRow { title: "实时电流"; value: batteryInfo.current; interactive: false }
    PenModsSettingRow { title: "续航预测"; value: batteryInfo.prediction; interactive: false }
    Timer { running: page.visible; repeat: true; triggeredOnStart: true; interval: 3000; onTriggered: batteryInfo.update() }
}

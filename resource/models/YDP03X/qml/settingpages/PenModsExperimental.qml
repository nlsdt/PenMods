import QtQuick 2.12
import com.youdao.pen 1.0
import BaseQml 1.0

PenModsSettingsPage {
    id: page
    title: "实验性功能"

    PenModsSwitchRow {
        title: "屏幕边缘触摸校准"
        description: touchCalibration.supported ? "补偿屏幕边缘触点；切换后重启设备。" : "未检测到支持的触摸屏。"
        checked: touchCalibration.enabled
        enabled: touchCalibration.supported || touchCalibration.enabled
        onRowToggled: {
            var desired = checked;
            page.confirmAction("更改触摸校准并重启设备？", function() { touchCalibration.enabled = desired; });
        }
    }
    PenModsSettingRow { title: "重新检测触摸屏"; onClicked: touchCalibration.refresh() }

}

import QtQuick 2.12
import com.youdao.pen 1.0
import BaseQml 1.0

PenModsSettingsPage {
    id: page
    title: "日志与隐私"

    PenModsSwitchRow { title: "阻止上传行为日志"; checked: loggerMonitor.noUploadUserAction; onRowToggled: loggerMonitor.noUploadUserAction = checked }
    PenModsSwitchRow { title: "阻止上传扫描原图"; checked: loggerMonitor.noUploadRawScanImg; onRowToggled: loggerMonitor.noUploadRawScanImg = checked }
    PenModsSwitchRow { title: "阻止上传 HTTP 日志"; checked: loggerMonitor.noUploadHttplog; onRowToggled: loggerMonitor.noUploadHttplog = checked }

}

import QtQuick 2.12
import com.youdao.pen 1.0
import BaseQml 1.0

PenModsSettingsPage {
    id: page
    title: "网络与代理"

    PenModsSwitchRow { title: "启用代理"; checked: networkSettings.proxyEnabled; onRowToggled: networkSettings.proxyEnabled = checked }
    PenModsSettingRow {
        title: "代理类型"; value: networkSettings.proxyType === 0 ? "SOCKS5" : "HTTP"
        onClicked: networkSettings.proxyType = networkSettings.proxyType === 0 ? 1 : 0
    }
    PenModsSettingRow {
        title: "代理地址"; value: networkSettings.proxyHostName || "未设置"
        onClicked: page.editText("代理服务器地址（不含协议和端口）", networkSettings.proxyHostName, function(text) {
            if (!text.trim().length || /[\r\n]/.test(text)) { baseSignals.showToast("请输入有效的代理地址", "#E9900C"); return false; }
            networkSettings.proxyHostName = text.trim();
        })
    }
    PenModsSettingRow {
        title: "代理端口"; value: String(networkSettings.proxyPort)
        onClicked: page.editText("代理端口：1–65535", String(networkSettings.proxyPort), function(text) {
            if (!/^[0-9]+$/.test(text.trim()) || Number(text) < 1 || Number(text) > 65535) {
                baseSignals.showToast("端口必须为 1–65535", "#E9900C"); return false;
            }
            networkSettings.proxyPort = Number(text);
        })
    }
    PenModsSettingRow {
        title: "代理用户名"; value: networkSettings.proxyUserName || "无"
        onClicked: page.editText("代理用户名（可留空）", networkSettings.proxyUserName, function(text) { networkSettings.proxyUserName = text; }, false, true)
    }
    PenModsSettingRow {
        title: "代理密码"; value: networkSettings.proxyPassword.length ? "已设置" : "无"
        onClicked: page.editText("代理密码（可留空）", "", function(text) { networkSettings.proxyPassword = text; }, true, true)
    }
    PenModsSettingRow { title: "本机 IP"; description: networkSettings.localIpAddress; interactive: false }
    PenModsSettingRow { title: "网关"; description: networkSettings.netGateway; interactive: false }
    PenModsSettingRow { title: "DNS"; description: networkSettings.dns; interactive: false }
    PenModsSettingRow { title: "刷新网络信息"; onClicked: networkSettings.refresh() }
    Component.onCompleted: networkSettings.refresh()

}

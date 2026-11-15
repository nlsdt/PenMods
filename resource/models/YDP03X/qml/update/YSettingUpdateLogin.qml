import QtQuick 2.12
import com.youdao.pen 1.0

import BaseQml 1.0
import "../settingpages"
import "../i18n"
import "../components"

YBackgroundIgnoreMouseEvent {
    id: id_update_os_item
    objectName: "YSettingUpdateLogin.qml"
    anchors.fill: parent

    YVerticalTitleBarBase {
        objectName: "YVerticalTitleBar.qml"
        YBackButton {
            id: id_back_button
            onClicked: {
                id_setting_update_os_page.subPageCallBack()
            }
            objectName: "YVerticalTitleBar.qml_" + id_update_os_item.objectName
        }
    }

    YLoginPageScanQrcodeLoader {
        id: id_not_login_loader
        visible: true
        onRequestLoginPageScanQrcodeLoginTip: {
            id_login_page_scan_qrcode_login_tip.show()
        }
        onQrCodeChanged: {}
    }
    YLoginPageScanQrcodeLoginTip {
        id: id_login_page_scan_qrcode_login_tip
    }

    Connections {
        target: loginManager
        ignoreUnknownSignals: true
        function onStatusChange(event, bSuc) {
            console.warn("YSettingUpdateLogin.qml===LoginEvent: ", event, " bSuc: ", bSuc)
            if (event === YEnum.Login) {
                if (bSuc) {
                    //关闭扫码登录页面
                    id_setting_update_os_page.subPageCallBack()
                } else {
                    baseSignals.showToast(YTranslateText.loginFaildPleaseCheckNetwork, YColors.grayNormal)
                }
            }
        }
    }
}


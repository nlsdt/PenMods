import QtQuick 2.12
import com.youdao.pen 1.0

import BaseQml 1.0
import "./components"
import "./i18n"

YBackButtonPage {
    id: id_setting_item
    objectName: "YPage===YLoginPage.qml"

    YLoginPageScanQrcodeLoader {
        id: id_not_login_loader
        visible: id_setting_item.visible && !loginManager.isLogin
        onRequestLoginPageScanQrcodeLoginTip: {
            id_login_page_scan_qrcode_login_tip.show()
        }
    }

    YLoginPageLoginStatusLoader {
        id: id_has_login_loader
        visible: id_setting_item.visible && loginManager.isLogin
        onRequestLoginPageRealTimeDisplay: {
            id_real_time_display.show()
        }
        onRequestLoginPageLogoutConfirm: {
            id_login_out_confirm.show()
        }
        onRequestAddBindAccountDisplay: {
            id_add_bind_account_display.show()
        }
    }

    YAddBindAccountDisplay {
        id: id_add_bind_account_display
    }

    YLoginPageScanQrcodeLoginTip {
        id: id_login_page_scan_qrcode_login_tip
    }

    YLoginPageRealTimeDisplay {
        id: id_real_time_display
    }

    YLoginPageLogoutConfirm {
        id: id_login_out_confirm
    }

    Connections {
        target: loginManager
        ignoreUnknownSignals: true
        function onStatusChange(event, bSuc) {
            console.warn("YLoginPage.qml===LoginEvent: ", event, " bSuc: ", bSuc)
            switch (event) {
            case YEnum.Login:
                if (bSuc) {
                    loginManager.queryUserInfo()
                } else {
                    baseSignals.showToast(YTranslateText.loginFaildPleaseCheckNetwork, YColors.grayNormal)
                }
                break
            case YEnum.Logout:
                if (bSuc) {
                    backButtonClicked()
                } else {
                    baseSignals.showToast(YTranslateText.logoutFaildPleaseCheckNetwork, YColors.grayNormal)
                }
                break
            }
        }
    }

    Component.onDestruction:  {
        console.warn("YLoginPage.qml===Component.onDestruction===called")
    }

    onBackButtonClicked: {
       //这里停止的话  在登录时候 返回二维码 主页面不会刷新 故不能stop
       // loginManager.stopPollLoginState()
    }

    onVisibleChanged: {
        if (visible) {
            if (loginManager.isLogin) {
                loginManager.queryUserInfo()
            } else {
                loginManager.pollLoginState()
                loginManager.stopPollLoginState()
            }
            qmlGlobal.currentPageIndex = YEnum.PageIndex.UserCenter
        }
    }
}

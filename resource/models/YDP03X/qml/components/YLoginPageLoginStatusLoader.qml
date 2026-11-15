import QtQuick 2.12
import com.youdao.pen 1.0
import BaseQml 1.0

import "../settingpages"
import "../i18n"
Flickable {
    id: id_scan_login_loader
    anchors.fill: parent
    anchors.leftMargin: 90
    anchors.rightMargin: 16
    contentHeight: id_column.height
    signal requestLoginPageRealTimeDisplay()
    signal requestLoginPageLogoutConfirm()
    signal requestAddBindAccountDisplay()
    Column {
        id: id_column
        anchors.left: parent.left
        anchors.right: parent.right
        YSettingItemTitle {
            title: YTranslateText.userCenter
        }
        YSettingAboutItem {
            id: id_user_icon_bg
            implicitHeight: 80
            color: YColors.grayNormal
            titleFontFamily: {
                switch (settingManager.uiLanguage) {
                case YEnum.EN_US:
                    if (!qmlTranslator.textIsEnglishOnly(loginManager.userName)) {
                        return fontManager.fontFamilyZhCn
                    }
                    return fontManager.fontFamilyEnUs
                }
                return fontManager.fontFamilyZhCn
            }
            title: loginManager.isLogin ? loginManager.userName : YTranslateText.unlogin
            value: ""
            YUserPortrait {
                id: id_user_icon
                width: 44
                height: 44
                anchors.verticalCenter: parent.verticalCenter
                anchors.right: parent.right
                anchors.rightMargin: 20
                borderColor: id_user_icon_bg.color
            }
        }
        YSpacingForColumn {
            implicitHeight: 10
        }
        YSettingAboutClickableItem {
            id: id_add_bind_account_bg
            implicitHeight: 80
            color: YColors.grayNormal
            title: YTranslateText.addBindAccount
            value: ""
            source: "login/add-account"
            onClicked: {
                requestAddBindAccountDisplay()
            }
        }
        YSpacingForColumn {
            implicitHeight: 10
        }
        YSettingSwitchItem {
            id: id_switch_state
            implicitHeight: 80
            title: YTranslateText.autoUploadLearningData
            switchOn: settingManager.isAutoUploadData
            interval: 0
            onTimerTriggered: {
                settingManager.isAutoUploadData = switchOn
                switchOn = Qt.binding(function() { return settingManager.isAutoUploadData })
            }
        }
        YSpacingForColumn {
            implicitHeight: 10
        }
        YSettingAboutClickableItem {
            implicitHeight: 80
            opacityChangableWhenPressed: false
            color: pressed ? "#111216" : YColors.grayNormal
            title: YTranslateText.realTimeDisplay
            value: ""
            imageName: blueToothManager.isAppConnected ? "settings/st-check" : "settings/info_more_arrow"
            onClicked: {
                logManager.sendHttpLog("action=account_display_click")
                requestLoginPageRealTimeDisplay()
            }
        }
        YSpacingForColumn {
            implicitHeight: 10
        }
        YButton {
            anchors.left: parent.left
            anchors.right: parent.right
            implicitHeight: 80
            radius: 16
            color: pressed ? "#111216" : YColors.grayNormal
            text: YTranslateText.logout
            textColor: YColors.red
            onClicked: {
                if (!wifiManager.onoff || !wifiManager.link) {
                    baseSignals.showToast(YTranslateText.networkAbnormalPleaseCheck, YColors.grayNormal)
                    return
                }
                 if(!settingManager.readparentcontrols(YEnum.ParentsControlList.UserCenter))
                {
                    baseSignals.showToast(YTranslateText.featuredisabledTips.arg("退出"), YColors.grayNormal)
                    return
                }
                requestLoginPageLogoutConfirm()
            }
        }
        YSpacingForColumn {
            implicitHeight: 30
        }
    }
}

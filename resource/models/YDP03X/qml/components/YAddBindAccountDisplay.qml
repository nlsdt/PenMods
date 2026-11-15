import QtQuick 2.12
import com.youdao.pen 1.0

import BaseQml 1.0
import "../settingpages"
import "../i18n"

YBackButtonPage {
    anchors.fill: parent
    destroyOnBack: false
    property var bindQrCode: ""
    signal requestAddBindAccountTipDisplay()
    readonly property int qrCodeAutoUpdateInterval: 2 * 60 * 1000

    Item {
        anchors.fill: parent
        anchors.leftMargin: 90
        anchors.rightMargin: 16

        YSettingItemTitle {
            title: YTranslateText.addBindAccount
        }

        YImage {
            id: id_dict_logo
            imageName: "login/dict-logo"
            sourceSize: Qt.size(50, 50)
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.topMargin: 122
        }

        YText {
            id: id_dict_name
            font.pixelSize: 39
            font.weight: Font.DemiBold
            font.family: fontManager.fontFamilyZhCn
            textFormat: YTextBase.RichText
            text: YTranslateText.youdaoSmartLearningApp
            anchors.left: id_dict_logo.right
            anchors.leftMargin: 16
            anchors.verticalCenter: id_dict_logo.verticalCenter
        }

        YTextBase {
            id: id_dict_scan_tip
            font.pixelSize: 28
            color: YColors.grayText
            textFormat: YTextBase.RichText
            text: YTranslateText.scanQrCodeBindAccountTip
            anchors.left: id_dict_logo.left
            anchors.top: id_dict_logo.bottom
            anchors.topMargin: 20
        }

        Rectangle {
            implicitWidth: 214
            implicitHeight: 214
            radius: 16
            color: id_qrcode_icon_default.visible ? YColors.grayNormal : YColors.white
            anchors.verticalCenter: parent.verticalCenter
            anchors.right: parent.right
            anchors.rightMargin: 4

            YImageBase {
                id: id_qrcode_icon
                anchors.centerIn: parent
                width: 200
                height: 200
                source: bindQrCode
                visible: bindQrCode.length > 0
            }

            YImage {
                id: id_qrcode_icon_default
                anchors.centerIn: parent
                sourceSize: Qt.size(94, 50)
                imageName: "login/login-default-qr"
                visible: !id_qrcode_icon.visible
            }
        }
    }

    Connections {
        target: loginManager
        ignoreUnknownSignals: true
        function onBindQrReady(qrString) {
            if (visible) {
                if (qrString.length > 0) {
                    bindQrCode = qrString
                    id_update_bind_qrcode_timer.interval = qrCodeAutoUpdateInterval
                } else {
                    baseSignals.showToast(YTranslateText.networkAbnormalPleaseCheck, YColors.grayNormal)
                    id_update_bind_qrcode_timer.interval = 5000
                }
                id_update_bind_qrcode_timer.start()
            }
        }
    }

    YTimer {
        id: id_check_bind_qrcode_state_timer
        interval: 5000
        objectName: "YAddBindAccountDisplay.qml_id_check_bind_qrcode_state_timer"
        onTriggered: {
            if (visible && bindQrCode.length <= 0) {
                loginManager.asyncRequestBindQr()
                id_check_bind_qrcode_state_timer.start()
            }
        }
    }

    YTimer {
        id: id_update_bind_qrcode_timer
        interval: qrCodeAutoUpdateInterval
        objectName: "YAddBindAccountDisplay.qml_id_update_bind_qrcode_timer"
        onTriggered: {
            if (visible && bindQrCode.length > 0) {
                loginManager.asyncRequestBindQr()
            }
        }
    }

    onBackButtonClicked: close()

    onVisibleChanged: {
        if (visible) {
            loginManager.asyncRequestBindQr()
            id_check_bind_qrcode_state_timer.start()
        } else {
            bindQrCode = ""
            id_check_bind_qrcode_state_timer.stop()
            id_update_bind_qrcode_timer.stop()
        }
    }
}

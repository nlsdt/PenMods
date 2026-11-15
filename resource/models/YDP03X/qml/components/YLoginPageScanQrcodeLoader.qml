import QtQuick 2.12
import com.youdao.pen 1.0

import BaseQml 1.0
import "../settingpages"
import "../i18n"
////import "../qqr_js"
//import "../qqr_js/qqr.js"
import "../qqr_js/"
Item {
    id: id_scan_login_loader
    anchors.fill: parent
    anchors.leftMargin: 90
    anchors.rightMargin: 16
    visible: false
    property var qrCode: ""
    readonly property int qrCodeAutoUpdateInterval: 2 * 60 * 1000

    signal requestLoginPageScanQrcodeLoginTip()

    YSettingItemTitle {
        title: YTranslateText.scanQrCodeLogin
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
        text: YTranslateText.scanQrCodeLoginTip
        anchors.left: id_dict_logo.left
        anchors.top: id_dict_logo.bottom
        anchors.topMargin: 20
    }

    YIconButton {
        implicitWidth: 36
        implicitHeight: 36
        radius: height/2
        anchors.left: id_dict_scan_tip.right
        anchors.leftMargin: 12
        anchors.verticalCenter: id_dict_scan_tip.verticalCenter
        iconSourceSize: Qt.size(36, 36)
        icon: "login/scan_tip"
        mouseAreaMargins: -40
        onClicked: {
            requestLoginPageScanQrcodeLoginTip()
        }
    }

    Rectangle {
        implicitWidth: 214
        implicitHeight: 214
        radius: 16
        color: id_qrcode_icon_default.visible ? YColors.grayNormal : YColors.white
        anchors.verticalCenter: parent.verticalCenter
        anchors.right: parent.right
        anchors.rightMargin: 4

//        QRCode {
//            id: id_qrcode_icon
//            anchors.centerIn: parent
//            width: 200
//            height: 200
//            source: qrCode
//            visible: qrCode.length > 0
//        }

        QRCode {
            id: id_qrcode_icon
            width: 200
            height: 200
            anchors.centerIn: parent
            value: qrCode
            visible: qrCode.length > 0
        }

        YImage {
            id: id_qrcode_icon_default
            anchors.centerIn: parent
            sourceSize: Qt.size(94, 50)
            imageName: "login/login-default-qr"
            visible: !id_qrcode_icon.visible
        }

        Connections {
            target: loginManager
            ignoreUnknownSignals: true
            enabled: id_scan_login_loader.visible
            function onQrReady(qrString) {
                if (qrString.length > 0) {
                    qrCode = qrString
                    loginManager.pollLoginState();
                    id_update_qrcode_timer.interval = qrCodeAutoUpdateInterval
                } else {
                    baseSignals.showToast(YTranslateText.networkAbnormalPleaseCheck, YColors.grayNormal)
                    id_update_qrcode_timer.interval = 5000
                }
                id_update_qrcode_timer.start()
            }
        }
    }

    YTimer {
        id: id_check_qrcode_state_timer
        interval: 5000
        objectName: "YLoginPageScanQrcodeLoader.qml_id_check_qrcode_state_timer"
        onTriggered: {
            if (visible && qrCode.length <= 0) {
                loginManager.requestLoginQr()
                id_check_qrcode_state_timer.start()
            }
        }
    }

    YTimer {
        id: id_update_qrcode_timer
        interval: qrCodeAutoUpdateInterval
        objectName: "YLoginPageScanQrcodeLoader.qml_id_update_qrcode_timer"
        onTriggered: {
            if (visible && qrCode.length > 0) {
                loginManager.requestLoginQr()
            }
        }
    }

    onVisibleChanged: {
        if (visible) {
            loginManager.requestLoginQr()
            id_check_qrcode_state_timer.start()
        } else {
            qrCode = ""
            id_check_qrcode_state_timer.stop()
            id_update_qrcode_timer.stop()
        }
    }
}

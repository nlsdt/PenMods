import QtQuick 2.12
import com.youdao.pen 1.0

import BaseQml 1.0
import "../i18n"

Item {
    anchors.fill: parent
    anchors.leftMargin: 20
    anchors.rightMargin: 20

    property color portraitBorderColor: "#000000"

    YUserPortrait {
        id: id_portrait_icon
        anchors.verticalCenter: parent.verticalCenter
        width: 42
        height: 42
        sourceSize: Qt.size(42, 42)
        defaultIconSource: "image://icons/portrait.png"
        borderColor: portraitBorderColor
    }

    YTextMedium {
        id: id_login_state
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: id_portrait_icon.right
        anchors.leftMargin: 10
        font.pixelSize: 26
        font.family: {
            switch (settingManager.uiLanguage) {
            case YEnum.EN_US:
                if (!qmlTranslator.textIsEnglishOnly(loginManager.userName)) {
                    return fontManager.fontFamilyZhCn
                }
                return fontManager.fontFamilyEnUs
            }
            return fontManager.fontFamilyZhCn
        }
        text: loginManager.isLogin ? loginManager.userName : YTranslateText.unlogin
        width: 300
        elide: YTextMedium.ElideRight
        wrapMode: YTextMedium.NoWrap
        height: paintedHeight
        opacity: id_login_button.pressed ? 0.6 : 1
    }

    YMouseArea {
        id: id_login_button
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.right: id_login_state.right
        anchors.rightMargin: -6
        onClicked: {
            if (loginManager.isLogin){
                logManager.sendHttpLog("action=home_account_click")
            } else {
                logManager.sendHttpLog("action=home_login_click")
            }
            qmlGlobal.showLoginPage()
        }
        objectName: "YMainTitleBar.qml_id_login_button"
    }

    Row {
        id: id_icon_container
        spacing: 8
        anchors.verticalCenter: parent.verticalCenter
        anchors.right: id_time.left
        anchors.rightMargin: 8
        height: 28

        YImage {
            id: id_bluetooth_headset_icon
            sourceSize: Qt.size(28, 28)
            imageName: "settings/bluetooth-headset"
            visible: blueToothManager.link  || systemBase.digHeadset
        }

        YImage {
            id: id_bluetooth_icon
            sourceSize: Qt.size(28, 28)
            imageName: "settings/bluetooth"
            visible: blueToothManager.onoff
        }

        YImage {
            id: id_wifi_icon
            sourceSize: Qt.size(28, 28)
            visible: wifiManager.onoff && wifiManager.link
            imageName: {
                if (wifiManager.signalStrength > 70) {
                    return "settings/wifi"
                } else if (wifiManager.signalStrength > 30) {
                    return "settings/wifi-medium"
                } else {
                    return "settings/wifi-low"
                }
            }
        }
    }

    YText {
        id: id_time
        anchors.verticalCenter: parent.verticalCenter
        anchors.right: id_battary_value.left
        anchors.rightMargin: 20
        font.pixelSize: 24
        text: timeManager.currentTime
        width: paintedWidth
        height: paintedHeight
    }

    YText {
        id: id_battary_value
        anchors.verticalCenter: parent.verticalCenter
        anchors.right: id_battary_icon_border.left
        anchors.rightMargin: 4
        font.pixelSize: 24
        text: ("%1%").arg(battaryPercentage)
        width: paintedWidth
        height: paintedHeight
    }

    Rectangle {
        id: id_battary_icon_border
        anchors.verticalCenter: parent.verticalCenter
        anchors.right: battaryChanging ? id_charging_icon.left : parent.right
        anchors.rightMargin: battaryChanging ? 4 : 0
        width: 42
        height: 20
        border.width: 2
        border.color: "#FFFFFF"
        color: "transparent"
        radius: 10
        smooth: true

        Item {
            id: id_battary_icon
            width: 34
            height: 12
            anchors.centerIn: parent
            Item {
                id: id_progress_resource
                anchors.fill: parent
                smooth: true
                clip: true
                anchors.rightMargin: (100 - battaryPercentage) * id_battary_icon.width / 100.0

                Rectangle {
                    id: id_indicator_resource_percentage
                    implicitWidth: id_battary_icon.width
                    implicitHeight: id_battary_icon.height
                    anchors.right: parent.right
                    anchors.rightMargin: -parent.anchors.rightMargin
                    color: {
                        if (battaryChanging) {
                            return (100 > battaryPercentage) ? "#00FF66" : YColors.white
                        }
                        return (20 > battaryPercentage) ? YColors.red : YColors.white
                    }
                    radius: height/2
                    smooth: true
                }
            }
        }
    }

    YImage {
        id: id_charging_icon
        anchors.verticalCenter: parent.verticalCenter
        anchors.right: parent.right
        sourceSize: Qt.size(13, 15)
        imageName: "ic_battery_flash"
        visible: battaryChanging
    }

    readonly property bool needReloadUserPortrait: (wifiManager.internetConnect
                                                    && loginManager.isLogin
                                                    && !qmlGlobal.fileExists(loginManager.iconPath))

    onNeedReloadUserPortraitChanged: {
        if (needReloadUserPortrait) {
            id_reload_user_portrait_timer.restart()
        }
    }

    YTimer {
        id: id_reload_user_portrait_timer
        interval: 3000
        onTriggered: {
            if (needReloadUserPortrait) {
                loginManager.queryUserInfo()
            } else {
                console.warn("YMainTitleBar.qml===no need reload")
            }
        }
        objectName: "YMainTitleBar.qml_id_reload_user_portrait_timer"
    }

    Component.onCompleted: {
        if (needReloadUserPortrait) {
            id_reload_user_portrait_timer.restart()
        }
        qmlGlobal.removeFreeze()
    }
}

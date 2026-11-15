import QtQuick 2.12
import com.youdao.pen 1.0

import BaseQml 1.0
import "../i18n"

YBackButtonPage {
    id: id_real_time_display
    anchors.fill: parent
    destroyOnBack: false
    enabled: "disconnecting" !== id_column.state

    function getCurrentState() {
        if (blueToothManager.isAppConnected) {
            return "connected"
        } else if (blueToothManager.linkApp) {
            return "connect_tip"
        } else {
            return "disconnect"
        }
    }

    Connections {
        target: blueToothManager
        ignoreUnknownSignals: true
        function onIsAppConnectedChanged() {
             console.log("nnnnnnnnnnnn--",blueToothManager.isAppConnected)
            id_column.state = Qt.binding(function(){
                return getCurrentState()
            })
        }
    }

    Column {
        id: id_column
        anchors.fill: parent
        anchors.leftMargin: 90
        anchors.rightMargin: 16
        anchors.left: parent.left
        anchors.right: parent.right
        state: getCurrentState()
        YSpacingForColumn {
            implicitHeight: {
                switch (id_column.state) {
                case "connecting":
                case "disconnect":
                    return 48
                case "connected":
                default:
                    return settingManager.uiLanguage === YEnum.ZH_CN
                            ? 72 : 50
                }
            }
        }

        YText {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.leftMargin: 57
            anchors.rightMargin: 57
            wrapMode: YText.Wrap
            horizontalAlignment: YText.AlignHCenter
            font.pixelSize: 28
            text: {
                switch (id_column.state) {
                case "connecting":
                    return YTranslateText.enterAppHomePage
                case "disconnect":
                    return YTranslateText.checkMoreInfo
                case "connected":
                default:
                    return ""
                }
            }
            visible: {
                switch (id_column.state) {
                case "connecting":
                case "disconnect":
                    return true
                case "connected":
                default:
                    return false
                }
            }
        }

        Row {
            visible: "connected" === id_column.state
            spacing: 12
            anchors.horizontalCenter: parent.horizontalCenter
            height: Math.max(id_tip.contentHeight, id_start_icon.height)
            YImage {
                id: id_start_icon
                sourceSize: Qt.size(40, 40)
                imageName: "login/app-connectted"
                anchors.verticalCenter: parent.verticalCenter
            }
            YTextMedium {
                id: id_tip
                width: settingManager.uiLanguage === YEnum.ZH_CN
                       ? paintedWidth : 439
                wrapMode: YTextBase.Wrap
                text: YTranslateText.hasConnectSuccess
                anchors.verticalCenter: parent.verticalCenter
            }
        }

        YSpacingForColumn {
            implicitHeight: {
                switch (id_column.state) {
                case "connecting":
                    return 38
                case "connected":
                    return settingManager.uiLanguage === YEnum.ZH_CN
                            ? 38 : 18
                case "disconnect":
                default:
                    return 16
                }
            }
        }

        YButton {
            implicitWidth: {
                switch (settingManager.uiLanguage) {
                case YEnum.EN_US:
                    return 60 + textItem.paintedWidth
                }
                return 280
            }
            anchors.horizontalCenter: parent.horizontalCenter
            color: {
                switch (id_column.state) {
                case "connecting":
                case "connected":
                    return YColors.red
                case "disconnect":
                default:
                    return YColors.grayNormal
                }
            }
            text: {
                switch (id_column.state) {
                case "disconnect":
                    return YTranslateText.connectYdDict
                case "connected":
                    return YTranslateText.removeConnection
                case "disconnecting":
                    return YTranslateText.removingConnection
                case "connecting":
                default:
                    return ""
                }
            }
            visible: {
                switch (id_column.state) {
                case "disconnect":
                case "connected":
                    return true
                case "connecting":
                default:
                    return false
                }
            }
            onClicked: {
                switch (id_column.state) {
                case "disconnect":
                    id_column.state = "connecting"
                    blueToothManager.connectToApp()
                    break
                case "connected":
                    id_column.state = "disconnecting"
                    blueToothManager.disconnectApp()
                    break
                }
            }
            mouseAreaMargins: -6
        }

        YImage {
            sourceSize: Qt.size(36, 36)
            imageName: "login/waiting"
            anchors.horizontalCenter: parent.horizontalCenter
            visible: "connecting" === id_column.state
            NumberAnimation on rotation {
                from: 0
                to: 360
                duration: 1920
                running: "connecting" === id_column.state
                loops: NumberAnimation.Infinite
            }
        }
    }


    YIconButton {
        implicitWidth: 44
        implicitHeight: 44
        radius: height/2
        anchors.left: parent.left
        anchors.leftMargin: 16
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 18
        iconSourceSize: Qt.size(36, 36)
        icon: "login/scan_tip"
        mouseAreaMargins: -26
        onClicked: {
            id_real_time_display_connect_tip.show()
        }
    }


    YLoginPageRealTimeDisplayConnectTip {
        id: id_real_time_display_connect_tip
    }

    onBackButtonClicked: close()
}

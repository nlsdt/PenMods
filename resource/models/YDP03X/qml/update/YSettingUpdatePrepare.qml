import QtQuick 2.12
import com.youdao.pen 1.0

import BaseQml 1.0
import "../settingpages"
import "../i18n"
import "../components"

YBackgroundIgnoreMouseEvent {
    id: id_update_os_item
    objectName: "YSettingUpdatePrepare.qml"
    anchors.fill: parent

    property bool isSuspending: false
   // readonly property real storageLimit: isSuspending ? updateOsManager.updateSize : (5 * 1024)
    readonly property real storageLimit:  updateOsManager.updateSize
    readonly property real spaceUnit: 1024.0
    readonly property real storageTip: Math.max(0.5, (storageLimit / spaceUnit).toFixed(1))

    property int incubatorCreateCount: 0

    function storageSufficient() {
        return (settingManager.storageAvailable) >= storageLimit// / spaceUnit >= storageLimit
    }

    function prepareFinished() {
        return wifiManager.internetConnect
                && loginManager.isLogin
                && batteryManager.charging
                && storageSufficient()
    }

    function configNetwork() {
        function newComponentInit(incubatorObject) {
            function close() {
                incubatorObject.destroy()
                delayRequestWifi()
            }
            id_back_button.clicked.connect(close)
            incubatorObject.backButtonClicked.connect(close)
            systemBase.homeKeyPress.connect(close)
            incubatorObject.show()
        }

        const incubator = id_config_wifi_component.incubateObject(
                            id_update_os_item)

        if (incubator.status !== Component.Ready) {
            incubator.onStatusChanged = function(status) {
                if (status === Component.Ready) {
                    if (0 === --incubatorCreateCount) {
                        // 异步重入只显示最后一个创建的对象
                        newComponentInit(incubator.object)
                    } else {
                        incubator.object.destroy()
                    }
                }
            }
            ++incubatorCreateCount
        } else {
            newComponentInit(incubator.object)
        }
    }

    signal cleanStorage()
    signal scanToLogin()

    YVerticalTitleBarBase {
        objectName: "YVerticalTitleBar.qml"
        YBackButton {
            id: id_back_button
            visible: !isSuspending
            onClicked: {
                id_setting_update_os_page.subPageCallBack()
            }
            objectName: "YVerticalTitleBar.qml_" + id_title_container.objectName
        }
    }

    Flickable {
        anchors.fill: parent
        anchors.leftMargin: 90
        anchors.rightMargin: 16
        contentHeight: id_update_prepare_col.height
        boundsBehavior: Flickable.StopAtBounds

        Column {
            id: id_update_prepare_col
            width: parent.width

            YSettingItemTitle {
                id: id_title_container
                title: YTranslateText.prepareUpdate
            }

            Column {
                width: parent.width
                spacing: 10

                YSettingUpdatePrepareItem {
                    title: YTranslateText.prepareInternet
                    buttonText: YTranslateText.connectInternet
                    isDone: wifiManager.internetConnect
                    onButtonClicked: {
                        configNetwork()
                    }
                }

                YSettingUpdatePrepareItem {
                    title: YTranslateText.prepareLongIn
                    buttonText: YTranslateText.longIn
                    isDone: loginManager.isLogin
                    onButtonClicked: {
                        scanToLogin()
                    }
                }

                YSettingUpdatePrepareItem {
                    title: YTranslateText.prepareBattery
                    isDone: batteryManager.charging
                }

                YSettingUpdatePrepareItem {
                    title: YTranslateText.prepareStorage.arg(storageTip)
                    tip: YTranslateText.storageTip
                    buttonText: YTranslateText.gotoCleanStorage
                    isDone: storageSufficient()
                    visible: storageLimit > 0
                    onButtonClicked: {
                        cleanStorage()
                    }
                }
            }

            YSpacingForColumn {
                implicitHeight: 28
            }

            YButtonBase {
                anchors.horizontalCenter: parent.horizontalCenter
                width: 360
                height: 80
                radius: height/2
                color: enabled ? YColors.red : "#A8AAB3"
                enabled: prepareFinished()
                visible: !isSuspending

                YTextMedium {
                    id: id_button_tip
                    anchors.top: parent.top
                    anchors.topMargin: 10
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: YTranslateText.startUpdate
                }

                YText {
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: 5
                    anchors.horizontalCenter: parent.horizontalCenter
                    font.pixelSize: 20
                    text: YTranslateText.oneHourNeeded
                }

                onClicked: {
                    // start update OS
                    logManager.sendHttpLog("action=update_begin_click")
                    console.warn("YSettingUpdatePrepare.qml===startUpdateClicked=== wifi: " + wifiManager.internetConnect
                                 + " login: " + loginManager.isLogin
                                 + " charging: " + batteryManager.charging
                                 + " storageAvailable: " + settingManager.storageAvailable
                                 + " storageLimit: " + storageLimit)
                    updateOsManager.startUpdateOS()
//                    qmlGlobal.requestShowUpdateOSPage()
//                    closeSettingUpdatePage()
                }
            }

            YButtonBase {
                anchors.horizontalCenter: parent.horizontalCenter
                width: 360
                height: 80
                radius: height/2
                color: enabled ? YColors.red : "#A8AAB3"
                enabled: prepareFinished()
                visible: isSuspending

                YTextMedium {
                    anchors.centerIn: parent
                    text: YTranslateText.continueUpdate
                }

                onClicked: {
                    // continue update OS
                    logManager.sendHttpLog("action=update_continue_click")
                    console.warn("YSettingUpdatePrepare.qml===startUpdateClicked=== wifi: " + wifiManager.internetConnect
                                 + " login: " + loginManager.isLogin
                                 + " charging: " + batteryManager.charging
                                 + " storageAvailable: " + settingManager.storageAvailable
                                 + " storageLimit: " + storageLimit)
                    updateOsManager.startUpdateOS("1")
//                    closeSettingUpdatePage()
                }
            }

            YSpacingForColumn {
                implicitHeight: 28
            }
        }
    }

    Component {
        id: id_config_wifi_component

        YSettingWifi {
            id: id_setting_wifi_view
        }
    }



    YPopLayer {
        id: id_pop_layer
//        onPopItemObjectChanged: {
//            if (null !== popItemObject) {
//                popItemObject.backButtonClicked.connect(function(){
//                })
//            }
//        }
    }
}


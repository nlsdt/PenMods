import QtQuick 2.12
import com.youdao.pen 1.0
import BaseQml 1.0

import "../components"
import "../i18n"

YSettingItemPage {
    id: id_setting_wifi
    objectName: "YPage===YSettingWifi.qml"

    readonly property bool wifiManagerOnoff: wifiManager.onoff
    readonly property bool wifiOnOffFinished: ("wifi_opening" !== wifiManager.currentState)
                                              && ("wifi_searching" !== wifiManager.currentState)

    property bool backButtonVisible: true

    function tryScan() {
        if (wifiManagerOnoff) {
            console.log("YSettingWifi.qml tryScan === ")
            id_setting_wifi_container.refreshButtonItem.clickable = false
            wifiManager.tryScan()
        }
    }

    Item {
        id: id_setting_wifi_container
        anchors.fill: parent
        anchors.leftMargin: 90
        anchors.rightMargin: 16

        property QtObject refreshButtonItem: null

        YBaseListView {
            id: id_setting_wifi_view
            anchors.fill: parent
            model: (wifiManager.onoff && wifiOnOffFinished) ? wifiManager : null
            opacity: YInputProperty.inputPageShowing ? 0 : 1
            Behavior on opacity {
                NumberAnimation {
                    duration: 480
                }
            }

            Connections {
                target: wifiManager
                ignoreUnknownSignals: true
                function onTurnOnResult(bSuc) {
                    console.warn("YSettingWifi.qml onTurnOnResult === ", bSuc)
                    if (bSuc && ("wifi_searching" !== wifiManager.currentState)) {
                        tryScan()
                    } else {
                        baseSignals.showToast(YTranslateText.connectFaild, "#E9900C")
                    }
                }
                function onScanFinished() {
                    id_setting_wifi_container.refreshButtonItem.rebinding()
                }
            }

            delegate: (wifiManager.onoff && wifiOnOffFinished) ?
                          id_wifi_item_component : id_wifi_item_null_component

            Component {
                id: id_wifi_item_null_component
                Item {
                    width: id_setting_wifi_view.width
                    implicitHeight: 76
                }
            }

            Component {
                id: id_wifi_item_component
                YMouseArea {
                    id: id_wifi_item
                    width: id_setting_wifi_view.width
                    height: 90
                    opacity: id_wifi_item.pressed ? 0.6 : 1
                    objectName: "YSettingWifi.qml_id_wifi_item_index" + index
                    YSettingItemBackground {
                        anchors.fill: parent
                        anchors.bottomMargin: 10

                        Column {
                            anchors.left: parent.left
                            anchors.leftMargin: 20
                            anchors.right: id_state_icon.visible
                                           ? id_state_icon.left : parent.right
                            anchors.rightMargin: id_state_icon.visible ? 34 : 20
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 8

                            YTextMedium {
                                text: model.modelData.ssid
                                anchors.left: parent.left
                                anchors.right: parent.right
                                elide: YText.ElideRight
                            }

                            YText {
                                font.pixelSize: 24
                                color: YColors.grayText
                                visible: (YEnum.LINKED === model.modelData.linkStatus)
                                         || (YEnum.LINKING === model.modelData.linkStatus)
                                         || (YEnum.DISCONNECTING === model.modelData.linkStatus)
                                text: {
                                    switch (model.modelData.linkStatus) {
                                    case YEnum.LINKED:
                                        return YTranslateText.connectSuccess
                                    case YEnum.LINKING:
                                        return YTranslateText.connetingWifi
                                    case YEnum.DISCONNECTING:
                                        return YTranslateText.disconnetingWifi
                                    default:
                                        return ""
                                    }
                                }
                            }
                        }

                        YImage {
                            id: id_state_icon
                            anchors.right: parent.right
                            anchors.rightMargin: 20
                            anchors.verticalCenter: parent.verticalCenter
                            sourceSize: Qt.size(44, 44)
                            visible: (model.modelData.security !== "NONE") || (YEnum.LINKED === model.modelData.linkStatus)
                            imageName: visible ? ((YEnum.LINKED === model.modelData.linkStatus) ? "settings/st-check" : "settings/st-lock") : ""
                        }
                    }

                    onClicked: {
                        switch (model.modelData.linkStatus) {
                        case YEnum.LINKED:
                            id_wifi_detail_loader.wifiName = model.modelData.ssid
                            id_wifi_detail_loader.active = true
                            break
                        case YEnum.UNLINK:
                            if (!wifiManager.connectting) {
                                if (model.modelData.security === "NONE") {
                                    wifiManager.tryConnect(model.modelData.ssid, "")
                                    id_setting_wifi_view.positionViewAtBeginning()
                                } else if (model.modelData.password !== "") {
                                    wifiManager.tryConnect(model.modelData.ssid, model.modelData.password)
                                    id_setting_wifi_view.positionViewAtBeginning()
                                } else {
                                    requestKeyboard(model.modelData.ssid)
                                }
                            } else {
                                baseSignals.showToast(YTranslateText.connetingWifi, "#E9900C")
                            }
                            break
                        case YEnum.LINKING:
                            baseSignals.showToast(YTranslateText.connetingWifi, "#E9900C")
                            break
                        case YEnum.DISCONNECTING:
                            baseSignals.showToast(YTranslateText.disconnetingWifi, "#E9900C")
                            break
                        }
                        // todo 无连接时
                    }
                }
            }

            header: Item {
                width: id_setting_wifi_view.width
                height: 170

                YSettingItemTitle {
                    title: YTranslateText.configWifi
                }

                YSettingSwitchItem {
                    id: id_switch_state
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: 10
                    title: YTranslateText.sysWifi
                    switchOn: wifiManager.onoff
                    enabled: "wifi_opening" !== wifiManager.currentState
                    interval: 540
                    backButtonClickedSignal: backButtonClicked
                    onTimerTriggered: {
                        if (id_switch_state.switchOn) {
                            wifiManager.turnOn()
                        } else {
                            wifiManager.turnOff()
                        }
                    }
                }
            }

            footer: YSpacing {
                width: id_setting_wifi_view.width
                height: 8
            }
        }

        YWaitingTipsText {
            id: id_state_tip
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 44
            visible: false
            font.pixelSize: 26
            color: YColors.grayText
            textFormat: YText.RichText
        }

        YSettingWifiDetailLoader {
            id: id_wifi_detail_loader
            onActiveChanged: {
                if (active) {
                    id_setting_wifi_container.refreshButtonItem.clickable = false
                } else {
                    id_setting_wifi_container.refreshButtonItem.rebinding()
                }
            }
        }
    }

    YRefreshButton {
        id: id_refresh_button
        anchors.left: parent.left
        anchors.leftMargin: 16
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 18
        clickable: false
        iconOpacity: clickable ? 1 : 0.3
        onRefresh: {
            tryScan()
        }
        function rebinding() {
            clickable = Qt.binding(function(){
                return !id_setting_wifi.animationRunning
                        && wifiManager.onoff
                        && !wifiManager.scanning
            })
        }
        Component.onCompleted: {
            id_setting_wifi_container.refreshButtonItem = id_refresh_button
        }
    }

    YPagePopHelper {
        id: id_page_pop_helper
        isShowing: YInputProperty.inputPageShowing
        objectName: "from_YSettingWifi.qml"

        property string ssid: ""

        function inputPageCreated(incubatorObject, ssid) {
            id_page_pop_helper.ssid = ssid
            incubatorObject.backButtonClicked.connect(function(){
                YInputProperty.inputPageShowing = false
                incubatorObject.todoDestroy()
                incubatorObject = null
            })
            incubatorObject.inputFinished.connect(function(pwd){
                wifiManager.tryConnect(id_page_pop_helper.ssid, pwd)
                id_setting_wifi_view.positionViewAtBeginning()
            })
            incubatorObject.placeHolderText = YTranslateText.inputTip
            incubatorObject.show()
            YInputProperty.inputPageShowing = true
        }
    }

    property int incubatorCreateCount: 0
    function requestKeyboard(ssid) {
        let component = qmlCreateComponent("input/YInputPage")
        if (Component.Ready === component.status) {

            var incubator = component.incubateObject(id_page_pop_helper.containerItem);
            if (incubator.status !== Component.Ready) {
                incubator.onStatusChanged = function(status) {
                    if (status === Component.Ready) {
                        if (0 === --incubatorCreateCount) {
                            id_page_pop_helper.inputPageCreated(incubator.object, ssid)
                        } else {
                            incubator.object.destroy()
                        }
                    }
                }
                ++incubatorCreateCount
            } else {
                id_page_pop_helper.inputPageCreated(incubator.object, ssid)
            }
        }
        else if (Component.Error === component.status)
        {
            console.log("qmlCreateComponent error : ", component.errorString())
        }
    }

    state: wifiManager.currentState
    states: [
        State {
            name: "wifi_off"
            PropertyChanges {
                target: id_state_tip
                text: YTranslateText.openingWifiTip
                textFormat: YText.RichText
                running: false
                visible: true
            }
        },
        State {
            name: "wifi_opening"
            PropertyChanges {
                target: id_state_tip
                text: YTranslateText.openingWifi
                textFormat: YText.PlainText
                running: true
                visible: true
            }
        },
        State {
            name: "wifi_searching"
            PropertyChanges {
                target: id_state_tip
                text: YTranslateText.searchingWifi
                textFormat: YText.PlainText
                running: true
                visible: true
            }
        },
        State {
            name: "wifi_search_finished"
            PropertyChanges {
                target: id_state_tip
                text: ""
                textFormat: YText.PlainText
                running: false
                visible: false
            }
        },
        State {
            name: "wifi_connected"
            PropertyChanges {
                target: id_state_tip
                text: ""
                textFormat: YText.PlainText
                running: false
                visible: false
            }
        },
        State {
            name: "wifi_disconnected"
            PropertyChanges {
                target: id_state_tip
                text: ""
                textFormat: YText.PlainText
                running: false
                visible: true
            }
        },
        State {
            name: "wifi_empty"
            PropertyChanges {
                target: id_state_tip
                text: YTranslateText.noFindWifi
                textFormat: Text.PlainText
                running: false
                visible: true
            }
        }
    ]

    Component.onCompleted: {
        wifiManager.enableModelUpdate(true)
        tryScan()
    }

    onBackButtonClicked: {
        wifiManager.enableModelUpdate(false)
    }
}

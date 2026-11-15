import QtQuick 2.12
import com.youdao.pen 1.0
import QtQuick.Layouts 1.15
import BaseQml 1.0
import "../components"
import "../i18n"

YSettingItemPage {
    id: id_setting_bluetooth
    objectName: "YPage===YSettingBluetooth.qml"
    property bool bluetoothSwitchOn: blueToothManager.onoff
    function tryScan() {
        if (blueToothManager.onoff) {

            id_delay_check_timer.restart();
            console.log("YSettingBluetooth.qml tryScan === ")
            id_refresh_button.clickable = false;
            id_setting_bluetooth.state = "bluetooth_searching"
            blueToothManager.tryScan()
        }
    }
    function reConnect() {
        if (blueToothManager.onoff) {
            console.log("YSettingBluetooth.qml reConnect === ")
            id_setting_bluetooth.state = "bluetooth_reconnect"
            blueToothManager.reConnectHistoricalDevice()
        }
    }
    Item {
        id: id_mask_source
        anchors.fill: parent
        anchors.leftMargin: 90
        anchors.rightMargin: 16
        Flickable
        {
            anchors.fill: parent
            contentHeight:id_tbale_content_bg_colum.height
            Column
            {

                id:id_tbale_content_bg_colum
                width: parent.width
                spacing: 10
                YSettingItemTitle {
                    id:settingItemTitle
                    title: YTranslateText.configBluetooth
                }

                YSettingSwitchItem {
                    id: id_switch_state
                    title: YTranslateText.bluetooth
                    switchOn: blueToothManager.onoff
                    backButtonClickedSignal: backButtonClicked
                    enabled: ("bluetooth_opening" !== id_setting_bluetooth.state)
                             && ("bluetooth_offing" !== id_setting_bluetooth.state)
                             && ("bluetooth_open_failed" !== id_setting_bluetooth.state)
                    onClicked: {
                        console.log("onTimerTriggered............>>>",id_switch_state.switchOn,blueToothManager.onoff)
                         id_refresh_button.clickable = false;
                        if (id_switch_state.switchOn) {
                            id_setting_bluetooth.state = "bluetooth_opening"
                        } else {
                            id_setting_bluetooth.state = "bluetooth_offing"
                        }
                    }
                    onTimerTriggered: {
                        console.log("onTimerTriggered............",id_switch_state.switchOn)
                        if (id_switch_state.switchOn) {
                            blueToothManager.turnOn()
                        } else {
                            blueToothManager.turnOff()
                        }
                    }

                }

                YWaitingTipsText {
                    id: id_state_tip
                    anchors.horizontalCenter: parent.horizontalCenter
                    color: YColors.grayText
                }
                YText {
                    id:mydevtxt
                    visible: (blueToothManager.pairedScanCount !== 0) && blueToothManager.onoff
                    anchors.left: parent.left
                    font.pixelSize: 24
                    color: "white"//Colors.grayText
                    text: "我的设备"
                }
                Repeater
                {
                    id:repeater_dev
                    visible: false
                    width:parent.width
                    model: blueToothManager

                    onCountChanged: {
                        if (repeater_dev.count > 0) {
                            id_setting_bluetooth.state = "bluetooth_search_finished"
                        }
                    }

                    YSettingItemBackground {
                        width: parent.width
                        height:  90
                        visible:  model.modelData.paired === "true"
                        Column {
                            anchors.left: parent.left
                            anchors.leftMargin: 20
                            anchors.right : parent.right
                            anchors.rightMargin: 80
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 8
                            YTextMedium {
                                text: model.modelData.devName
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
                                         || (YEnum.UNLINK === model.modelData.linkStatus   )
                                text: {
                                    switch (model.modelData.linkStatus) {
                                    case YEnum.LINKED:
                                        return YTranslateText.connectSuccess
                                    case YEnum.LINKING:
                                        return YTranslateText.conneting
                                    case YEnum.DISCONNECTING:
                                        return YTranslateText.disconneting + "..."
                                    case YEnum.UNLINK:
                                        return YTranslateText.notconnet
                                    default:
                                        return ""
                                    }
                                }


                            }
                        }
                        MouseArea
                        {
                            anchors.fill: parent
                            enabled: model.modelData.linkStatus === YEnum.UNLINK
                            onClicked:
                            {
                                blueToothManager.tryConnect(model.modelData.addr,model.modelData.devName)

                            }

                        }
                        Rectangle
                        {
                            width:100
                            height: parent.height
                            color: YColors.grayNormal
                            anchors.right: parent.right
                            anchors.rightMargin: 10
                            YImage {
                                id: id_state_icond_dev
                                anchors.right: parent.right
                                anchors.rightMargin: 20
                                anchors.verticalCenter: parent.verticalCenter
                                sourceSize: Qt.size(50, 50)
                                imageName: "settings/ic_about"
                                visible:  true

                            }
                            MouseArea
                            {
                                anchors.fill: parent
                                onClicked:
                                {
                                    id_bluetooth_detail_loader.devName = model.modelData.devName
                                    id_bluetooth_detail_loader.addrName = model.modelData.addr
                                    id_bluetooth_detail_loader.linkStatus = model.modelData.linkStatus
                                    id_bluetooth_detail_loader.active = true
                                }
                            }

                        }

                    }
                }
                YText {
                    id:otherdevtxt
                    visible:  (blueToothManager.pairedScanCount !== 0) && blueToothManager.onoff
                    anchors.left: parent.left
                    font.pixelSize: 24
                    color:  "white" //Colors.grayText
                    text: "其他设备"
                }
                Repeater {
                    id: id_setting_bluetooth_view
                    width: parent.width
                    model: blueToothManager

                    onCountChanged: {
                        if (id_setting_bluetooth_view.count > 0) {
                            id_setting_bluetooth.state = "bluetooth_search_finished"
                        }
                    }
                    delegate: (bluetoothSwitchOn && ("bluetooth_opening" !== id_setting_bluetooth.state))
                              ? id_bluetooth_item_component : id_bluetooth_item_null_component

                    Component {
                        id: id_bluetooth_item_null_component
                        Item {
                            width: id_setting_bluetooth_view.width
                            implicitHeight: 76
                        }
                    }
                    Component {
                        id: id_bluetooth_item_component
                        YMouseArea {
                            id: id_bluetooth_item
                            width: id_setting_bluetooth_view.width
                            height:90
                            opacity: id_bluetooth_item.pressed ? 0.6 : 1
                            objectName: "YSettingBluetooth.qml_id_bluetooth_item_index" + index
                            visible:model.modelData.paired === "false"
                            YSettingItemBackground {
                                anchors.fill: parent
                              //  anchors.bottomMargin: 10
                                Column {
                                    anchors.left: parent.left
                                    anchors.leftMargin: 20
                                    anchors.right:  parent.right
                                    anchors.rightMargin:  34
                                    anchors.verticalCenter: parent.verticalCenter
                                    spacing: 8
                                    YTextMedium {
                                        text: model.modelData.devName
                                        anchors.left: parent.left
                                        anchors.right: parent.right
                                        elide: YText.ElideRight
                                    }

                                    YText {
                                        font.pixelSize: 24
                                        color: YColors.grayText
                                        visible: YEnum.LINKING === model.modelData.linkStatus
                                        text: {
                                            switch (model.modelData.linkStatus) {
                                            case YEnum.LINKED:
                                                return YTranslateText.connectSuccess
                                            case YEnum.LINKING:
                                                return YTranslateText.conneting
                                            case YEnum.DISCONNECTING:
                                                return YTranslateText.disconneting + "..."
                                            case YEnum.UNLINK:
                                                return YTranslateText.notconnet
                                            default:
                                                return ""
                                            }
                                        }
                                    }
                                }

                            }
                            onClicked: {
                                switch (model.modelData.linkStatus) {
                                case YEnum.UNLINK:
                                    blueToothManager.tryConnect(model.modelData.addr,model.modelData.devName)
                                    break
                                case YEnum.LINKING:
                                    baseSignals.showToast(YTranslateText.connecting, "#E9900C")
                                    break
                                }
                            }
                        }
                    }
                }


            }

        }
        Connections {
            target: blueToothManager
            ignoreUnknownSignals: true
            function onTurnOnResult(bSuc) {
                console.log("onTurnOnResult---",bSuc)
                if (bSuc) {
                    console.log("zypper onTurnOnResult tryScan")
                    blueToothManager.onoff = true
                    tryScan()
                } else {
                    id_setting_bluetooth.state = "bluetooth_open_failed"
                    blueToothManager.onoff = false
                }
            }

            function onTurnOffResult(bSuc) {

                console.log("onTurnOffResult---",bSuc)
                if(bSuc)
                {
                    blueToothManager.onoff = false
                    id_refresh_button.clickable = false
                    id_setting_bluetooth.state = "bluetooth_off"
                }
                else
                {
                    blueToothManager.onoff = true
                    id_switch_state.switchOn = true
                    id_setting_bluetooth.state = "bluetooth_search_finished"

                }
            }
            function onScanningChanged() {
                console.log("onScanningChanged .....",blueToothManager.scanning)
                if (!blueToothManager.scanning)
                {
                    id_delay_check_timer.running = false;
                    id_setting_bluetooth.state = "bluetooth_search_finished"
                }
                else
                {
                    id_setting_bluetooth.state = "bluetooth_searching"
                }
                id_refresh_button.rebinding()

            }
            function onConnectFinished(addr, bSuc) {
                if (!bSuc) {
                    baseSignals.showToast(YTranslateText.connectFaild, "#E9900C")
                } else {
                    id_setting_bluetooth_view.positionViewAtBeginning()
                }
                id_refresh_button.rebinding()
            }

            function onPairedCountChanged()
            {
                console.log("onPairedScanCountChanged----",blueToothManager.pairedScanCount)
                if(blueToothManager.pairedScanCount === 0)
                {
                    mydevtxt.visible = false;
                    otherdevtxt.visible = false;
                    repeater_dev.visible = false;
                }
                else
                {

                    mydevtxt.visible = true;
                    otherdevtxt.visible = true;
                    repeater_dev.visible = true;

                }


            }

        }
        YSettingBluetoothDetailLoader {
            id: id_bluetooth_detail_loader
            onCallPositionViewAtBeginning: {
                id_setting_bluetooth_view.positionViewAtBeginning()
            }
            onCallback:
            {
                id_bluetooth_detail_loader.active = false
            }

        }
    }

    //刷新
    YRefreshButton {
        id: id_refresh_button
        anchors.left: parent.left
        anchors.leftMargin: 16
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 18
        clickable:  true
        iconOpacity: clickable ? 1 : 0.3
        onRefresh: {
            if(blueToothManager.bdosomthing())
              return ;
           id_delay_try_scan_timer.restart()
        }

        function rebinding() {
            clickable = Qt.binding(function(){
                console.log("rebinding...",blueToothManager.onoff,"  ",id_setting_bluetooth.state)
                return blueToothManager.onoff
                       && ("bluetooth_opening" !== id_setting_bluetooth.state)
                       && ("bluetooth_searching" !== id_setting_bluetooth.state)
            })
        }

//       Component.onCompleted:
//       {
//           id_refresh_button.clickable = Qt.binding(function(){
//               console.log("rebinding...",blueToothManager.onoff,"  ",id_setting_bluetooth.state)
//               return blueToothManager.onoff
//                       && ("bluetooth_opening" !== id_setting_bluetooth.state)
//                       && ("bluetooth_searching" !== id_setting_bluetooth.state)
//           });
//       }
    }
    state: {
        if (!blueToothManager.onoff) {
            return "bluetooth_off"
        } else {
            if (blueToothManager.link || blueToothManager.linkApp) {
                return "bluetooth_search_finished"
            } else {
                return "bluetooth_searching"
            }
        }
    }
    states: [
        State {
            name: "bluetooth_off"
            PropertyChanges {
                target: id_state_tip
                text: YTranslateText.openBluetoothTip
                textFormat: YText.RichText
                running: false
                visible: true
            }
        },
        State {
            name: "bluetooth_offing"
            PropertyChanges {
                target: id_state_tip
                text: YTranslateText.offingBluetooth
                textFormat: YText.RichText
                running: true
                visible: true
            }
        },
        State {
            name: "bluetooth_opening"
            PropertyChanges {
                target: id_state_tip
                text: YTranslateText.openingBluetooth
                textFormat: YText.PlainText
                running: true
                visible: true
            }
        },
        State {
            name: "bluetooth_open_failed"
            PropertyChanges {
                target: id_state_tip
                text: YTranslateText.openBluetoothFailed
                textFormat: YText.PlainText
                running: false
                visible: true
            }
        },
        State {
            name: "bluetooth_searching"
            PropertyChanges {
                target: id_state_tip
                text: YTranslateText.searchingDevice
                textFormat: YText.PlainText
                running: true
                visible: true
            }
        },
        State {
            name: "bluetooth_search_finished"
            PropertyChanges {
                target: id_state_tip
                text: ""
                textFormat: YText.PlainText
                running: false
                visible: false
            }
        },
        State {
            name: "bluetooth_search_failed"
            PropertyChanges {
                target: id_state_tip
                text: YTranslateText.noBluetoothDevice
                textFormat: YText.PlainText
                running: false
                visible: true
            }
        },
        State {
            name: "bluetooth_reconnect"
            PropertyChanges {
                target: id_state_tip
                text: YTranslateText.reconnecting
                textFormat: YText.PlainText
                running: true
                visible: true
            }
        }
    ]

    onStateChanged: {
        console.log("ZDS===YSettingBluetooth.qml===onStateChanged:", state)
    }

    Component.onCompleted: {
        console.log("enter.............bluepage",blueToothManager.onoff,id_switch_state.switchOn,blueToothManager.pairedScanCount)
        blueToothManager.enableModelUpdate(true)
        id_delay_try_scan_timer.restart()
    }
    Component.onDestruction:
    {
        console.log("close.............bluepage",blueToothManager.onoff,id_switch_state.switchOn)
         blueToothManager.enableModelUpdate(false)
        if (id_setting_bluetooth_view.bluetoothSwitchOn) {
            blueToothManager.closeScan();

        }

    }
    onBackButtonClicked: {
        blueToothManager.enableModelUpdate(false)
    }
    YTimer {
        id: id_delay_try_scan_timer
        interval: 360
        objectName: "YSettingBluetooth.qml_id_delay_try_scan_timer"
        onTriggered: {
            if (blueToothManager.onoff) {
                tryScan()
            }
        }
    }
    YTimer {
        id: id_delay_check_timer
        interval: 1000*10
        objectName: "YSettingBluetooth.qml_id_delay_check_scan_timer"
        onTriggered: {

            //没有扫描到任何设备
            id_setting_bluetooth.state = "bluetooth_search_failed"
        }
    }
}

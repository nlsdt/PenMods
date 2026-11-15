import QtQuick 2.12
import com.youdao.pen 1.0
import QtGraphicalEffects 1.14
import QtQuick.Window 2.15

import BaseQml 1.0
import "./components"
import "./settingpages"
import "./timers"

Window {
    id: id_quick_setting_layer_container
    visible: false
    opacity: 0
    flags: Qt.FramelessWindowHint
    color: "transparent"
    x: 0
    y: 113
    width: YBaseEnum.Screen.Width
    height: 1

    property var deltY: 0

    readonly property bool isOpening: ("open" === id_quick_setting_layer_root.state)
    property alias layerY: id_quick_setting_layer_root.y
    property alias fastBlurTarget: id_fast_blur.source
    property alias dragTarget: id_quick_setting_layer_root

    function open() {
        show()
        height = YBaseEnum.Screen.Height
        id_quick_setting_layer_root.open()
    }

    function reopen() {
        show()
        height = YBaseEnum.Screen.Height
        id_quick_setting_layer_root.reopen()
    }

    function forceClose() {
        id_quick_setting_layer_root.forceClose()
    }

    Item {
        id: id_quick_setting_layer_root
        width: id_quick_setting_layer_container.width
        height: YBaseEnum.Screen.Height//id_quick_setting_layer_container.height
        property bool showingMusicControls: false
        readonly property bool pluginMusicAvailable: !antiEmbs.active && mediaSession.active
        readonly property bool hostMusicAvailable: !antiEmbs.active && musicPlayer.hideFloatingWindow && mediaPlayerManager.title.length > 0
        readonly property bool musicControlsAvailable: pluginMusicAvailable || hostMusicAvailable
        onMusicControlsAvailableChanged: {
            if (!musicControlsAvailable) showingMusicControls = false;
        }
        function showMusic(value) {
            showingMusicControls = value && musicControlsAvailable;
            musicPlayer.quickPanelMusicView = showingMusicControls;
        }

        state: "close"
        visible: false
        clip: true
        y: - id_quick_setting_layer_root.height

//        readonly property bool isOpening: ("open" === state)

//        property alias fastBlurTarget: id_fast_blur.source

        function close() {
            if ("open" === state) {
                forceClose()
            }
        }

        function open() {
            if ("close" === state) {
                logManager.sendHttpLog("action=quick_card_view")
                reopen()
            }
        }

        function reopen() {
            showingMusicControls = musicControlsAvailable && musicPlayer.quickPanelMusicView;
            visible = true
            state = "openning"
            id_open_close_animator.to = 0
            id_open_close_animator.restart()
            settingManager.updateVolumeAndLcd()
        }

        function forceClose() {
            state = "closing"
            id_volum_setting.rebinding()
            id_lum_setting.rebinding()
            id_open_close_animator.to = - id_quick_setting_layer_root.height
            id_open_close_animator.restart()
        }

        YMouseArea {
            anchors.fill: parent
            drag.target: id_quick_setting_layer_root
            drag.axis: Drag.YAxis
            drag.minimumY: - id_quick_setting_layer_root.height
            drag.maximumY: 0
            objectName: "YQuickSettingLayer.qml_YMouseArea"

            property real pressedY: 0

            onPressed: {
                pressedY = id_quick_setting_layer_root.y
                id_check_timer.restart()
            }

            onReleased: {
                doReleased()
            }

            onCanceled: {
                doReleased()
            }

            YTimer {
                id: id_check_timer
                interval: 300
                objectName: "YQuickSettingLayer.qml_id_check_timer"
            }

            function doReleased() {
                if ((mouseX >=370 && mouseX <= 430) && (mouseY >=230 && mouseY <= 254)) {
                    if (id_check_timer.running) {
                        close()
                    } else {
                        reopen()
                    }
                } else {
                    if (id_quick_setting_layer_root.y < - id_quick_setting_layer_root.height / 5
                            || (id_check_timer.running
                                && (pressedY - id_quick_setting_layer_root.y > 10))) {
                        id_quick_setting_layer_root.forceClose()
                    } else {
                        id_quick_setting_layer_root.reopen()
                    }
                }
            }
        }

        PropertyAnimation {
            id: id_open_close_animator
            target: id_quick_setting_layer_root
            property: "y"
            from: id_quick_setting_layer_root.y
            to: - id_quick_setting_layer_root.height
            duration: 120
            running: false
            alwaysRunToEnd: true
            onRunningChanged: {
                if (!running) {
                    if ("openning" === id_quick_setting_layer_root.state) {
                        id_quick_setting_layer_root.state = "open"
                    } else if ("closing" === id_quick_setting_layer_root.state) {
                        id_quick_setting_layer_root.state = "close"
                        id_quick_setting_layer_container.height = 1
                        id_quick_setting_layer_container.hide()
                    }
                }
            }
        }

        FastBlur {
            id: id_fast_blur
            width: YBaseEnum.Screen.Width
            height: YBaseEnum.Screen.Height
            y: - id_quick_setting_layer_root.y
            radius: 16
        }

        Rectangle {
            anchors.fill: parent
            color: "#E6000000"
        }

        Item {
            anchors.fill: parent
            visible: !id_quick_setting_layer_root.showingMusicControls
            property date currentTime: new Date()
            Timer {
                interval: 1000
                repeat: true
                running: id_quick_setting_layer_root.visible
                onTriggered: parent.currentTime = new Date()
            }
            Text {
                font.family: fontManager.fontFamily
                x: 18
                y: 2
                font.pixelSize: 16
                color: "#D7DCE5"
                visible: !antiEmbs.active
                text: Qt.formatDateTime(parent.currentTime, "MM/dd  hh:mm")
            }
            YPenModsBatteryIndicator {
                objectName: "PenModsQuickSettingsBattery"
                anchors.right: parent.right
                anchors.rightMargin: 18
                y: 0
                power: batteryManager.power
                charging: batteryManager.charging
                visible: !antiEmbs.active
            }
        YVolmueAdjustor {
            id: id_volum_setting
            anchors.top: parent.top
            anchors.topMargin: 22
            anchors.right: parent.right
            anchors.rightMargin: 80
        }

        YTouchRegulator {
            id: id_lum_setting
            anchors.top: id_volum_setting.bottom
            anchors.topMargin: 20
            anchors.left: id_volum_setting.left
            property int lcdSettingBrightness: settingManager.lcdBrightness
            YImage {
                sourceSize: Qt.size(44, 44)
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.leftMargin: 24
                imageName: {
                    if (0 === id_lum_setting.value) {
                        return "slide/lum_off"
                    } else if (id_lum_setting.value <= 50) {
                        return "slide/lum_half"
                    }  else {
                        return "slide/lum"
                    }
                }
            }
            onValueChanged: {
                if (lcdSettingBrightness != value) {
                    settingManager.setLcdBrightness(value)
                }
            }
            onLcdSettingBrightnessChanged: {
                if (lcdSettingBrightness != value) {
                    value = lcdSettingBrightness
                }
            }

            function rebinding() {
                value = Qt.binding(function(){ return lcdSettingBrightness })
            }

            Component.onCompleted: rebinding()
        }

        YSlideWifiSetting {
            id: id_slide_wifi
        }

        YSlideBluetoothSetting {
            id: id_slide_bluetooth
            anchors.left: id_slide_wifi.right
            anchors.leftMargin: 20
        }

        YIconButton {
            implicitWidth: 120
            implicitHeight: 92
            radius: height/2
            anchors.left: id_slide_wifi.left
            anchors.top: id_slide_wifi.bottom
            anchors.topMargin: 20
            color: "#383940"
            sourceSize: Qt.size(44, 44)
            imageName: "slide/setting"
            mouseAreaMargins: -5
            onClicked: {
                qmlGlobal.requestSettingPage()
            }
        }

            Rectangle {
                anchors.right: parent.right
                anchors.rightMargin: 18
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 8
                width: 88
                height: 34
                radius: 8
                color: "#343840"
                visible: id_quick_setting_layer_root.musicControlsAvailable
                Text { font.family: fontManager.fontFamily; anchors.centerIn: parent; text: "音乐"; font.pixelSize: 20; color: "white" }
                MouseArea {
                    anchors.fill: parent
                    onClicked: id_quick_setting_layer_root.showMusic(true)
                }
            }
        }
        YQuickMusicPlayer {
            anchors.fill: parent
            visible: id_quick_setting_layer_root.showingMusicControls
            onAdjustSettingsRequested: id_quick_setting_layer_root.showMusic(false)
            onPlayerRequested: {
                id_quick_setting_layer_root.forceClose();
                baseSignals.showAudioPlayer();
            }
        }

        Item {
            implicitWidth: 58
            implicitHeight: 6
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 6
            YRectangle {
                implicitWidth: parent.width/2 + 3
                implicitHeight: 6
                radius: height/2
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                color: "#383940"
                rotation: {
                    switch (id_quick_setting_layer_root.state) {
                    case "open":
                        return -10
                    case "openning":
                        return 10
                    default:
                        return 0
                    }
                }
                transformOrigin: Rectangle.Center
            }

            YRectangle {
                implicitWidth: parent.width/2 + 3
                implicitHeight: 6
                radius: height/2
                anchors.verticalCenter: parent.verticalCenter
                color: "#383940"
                rotation: {
                    switch (id_quick_setting_layer_root.state) {
                    case "open":
                        return 10
                    case "openning":
                        return -10
                    default:
                        return 0
                    }
                }
                transformOrigin: Rectangle.Center
                anchors.right: parent.right
            }
        }


        onStateChanged: {
            if ("close" === state) {
                YTimers.delayCall(200, function() {
                    if ("close" === id_quick_setting_layer_root.state) {
                        id_quick_setting_layer_root.visible = false
                    }
                })
            }
        }
    }

}

import QtQuick 2.12
import com.youdao.pen 1.0

import BaseQml 1.0

YThreeStatesButton {
    id: id_slide_wifi
    anchors.top: parent.top
    anchors.topMargin: 22
    anchors.left: parent.left
    anchors.leftMargin: 80
    imageName: "slide/wifi_off"
    state: wifiLink ? "on" : "off"

    readonly property bool wifiLink: wifiManager.onoff && wifiManager.link

    onCallOn: {
        turnOnTimeoutTimer.restart()
        wifiManager.turnOn()
        console.log("YSlideWifiSetting.qml===onCallOn===")
    }

    onCallOff: {
        setOff()
        wifiManager.turnOff()
        console.log("YSlideWifiSetting.qml===onCallOff===")
    }

    onStateChanged: {
        switch(state) {
        case "on":
            id_middle_state_animation.stop()
            imageName = "slide/wifi_on"
            break
        case "off":
            id_middle_state_animation.stop()
            imageName = "slide/wifi_off"
            break
        case "middle":
            id_middle_state_animation.restart()
            break
        }
    }

    onWifiLinkChanged: {
        if (wifiLink) {
            if (turnOnTimeoutTimer.running) {
                turnOnTimeoutTimer.stop()
            }
            if (id_slide_wifi.state !== "on") {
                setOn()
            }
        } else {
            setOff()
        }
    }

    onTurnOnTimeout: {
        if (wifiManager.onoff) {
            setOn()
        }
    }

    SequentialAnimation {
        id: id_middle_state_animation
        loops: SequentialAnimation.Infinite
        PropertyAction { target: id_slide_wifi; property: "imageName";
            value: "slide/wifi_middle_low" }
        PauseAnimation { duration: waitingDuration }
        PropertyAction { target: id_slide_wifi; property: "imageName";
            value: "slide/wifi_middle_mid" }
        PauseAnimation { duration: waitingDuration }
        PropertyAction { target: id_slide_wifi; property: "imageName";
            value: "slide/wifi_middle_high" }
        PauseAnimation { duration: waitingDuration }
    }

    onPressAndHold: {
        qmlGlobal.requestSettingPage(YEnum.SettingIndex.Network)
    }
}

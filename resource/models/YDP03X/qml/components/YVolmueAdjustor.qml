import QtQuick 2.12
import com.youdao.pen 1.0

import BaseQml 1.0

YTouchRegulator {
    id: id_volmue_adjustor

    readonly property int spkSettingVolume: settingManager.spkVolume

    property alias iconWidth: id_icon.width
    property alias iconHeight: id_icon.height
    property alias iconLeftMargin: id_icon.anchors.leftMargin
    property alias iconVisible: id_icon.visible

    YImage {
        id: id_icon
        sourceSize: Qt.size(44, 44)
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        anchors.leftMargin: 24

        // PenMods 防尴尬「快速静音」：开启后点一下音量图标即静音（复刻 2 代）
        YMouseArea {
            anchors.fill: parent
            enabled: (typeof antiEmbs === "object" && antiEmbs !== null) ? antiEmbs.fastMute : false
            onClicked: {
                settingManager.setSpkVolume(0)
            }
        }

        imageName: {
            if (0 === id_volmue_adjustor.value) {
                return "slide/volum_off"
            } else if (id_volmue_adjustor.value <= 50) {
                return "slide/volum_half"
            } else {
                return "slide/volum"
            }
        }
    }

    onValueChanged: {
        if (spkSettingVolume != value) {
            settingManager.setSpkVolume(value)
        }
    }

    onSpkSettingVolumeChanged: {
        if (spkSettingVolume !== value) {
            value = spkSettingVolume
        }
    }

    function rebinding() {
        value = Qt.binding(function(){ return spkSettingVolume })
    }

    Component.onCompleted: rebinding()
}

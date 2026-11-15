import QtQuick 2.12
import QtGraphicalEffects 1.14

Item {
    readonly property alias maskItem: id_mask_bg
    property alias blurRadius: id_fast_blur.radius
    property alias source: id_fast_blur.source

    Rectangle {
        id: id_mask_bg
        anchors.fill: parent
        color: "#99494A70"
        radius: height/2
        visible: false
    }

    FastBlur {
        id: id_fast_blur
        anchors.fill: id_mask_bg
        source: id_mask_bg
        radius: 64
        visible: false
    }

    Rectangle {
        id: id_opacity_mask_bg
        anchors.fill: parent
        radius: id_mask_bg.radius
        visible: false
    }

    OpacityMask {
        anchors.fill: parent
        source: id_fast_blur
        maskSource: id_opacity_mask_bg
    }
}

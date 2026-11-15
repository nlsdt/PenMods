import QtQuick 2.12
import QtGraphicalEffects 1.14

import "../common"

Item {
    id: id_blur_mask_rectangle
    opacity: !enabled ? 0.6 : 1
    implicitHeight: 28

    // must be set properties
    property alias sourceItem: id_shader_effect_source.sourceItem
    property alias sourceRect: id_shader_effect_source.sourceRect

    // other properties
    property alias radius: id_progress_mask.radius

    property alias blurRadius: id_gaussian_blur.radius

    default property alias content: id_container.data

    ShaderEffectSource {
        id: id_shader_effect_source
        anchors.fill: parent
        visible: false
    }

    FastBlur {
        id: id_gaussian_blur
        anchors.fill: parent
        source: id_shader_effect_source
        radius: 64
        visible: false

        Item {
            id: id_container
            anchors.fill: parent
        }
    }

    Rectangle {
        id: id_progress_mask
        anchors.fill: parent
        radius: height/2
        visible: false
    }

    OpacityMask {
        anchors.fill: parent
        source: id_gaussian_blur
        maskSource: id_progress_mask
    }
}

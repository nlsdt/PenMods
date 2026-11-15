import QtQuick 2.12
import QtGraphicalEffects 1.14

import BaseQml 1.0

Item {
    id: id_opacity_mask_image
    smooth: true

    readonly property alias imageItem: id_source_icon
    readonly property alias maskItem: id_mask_icon

    property alias source: id_source_icon.source
    property alias radius: id_mask_icon.radius

    YAspectFitAlignCenterImage {
        id: id_source_icon
        anchors.fill: parent
        fillMode: YImage.PreserveAspectCrop
        visible: false
    }

    Rectangle {
        id: id_mask_icon
        anchors.fill: parent
        radius: 20
        visible: false
    }

    OpacityMask {
        anchors.fill: parent
        source: id_source_icon
        maskSource: id_mask_icon
    }
}

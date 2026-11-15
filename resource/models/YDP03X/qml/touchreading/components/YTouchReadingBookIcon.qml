import QtQuick 2.12
import QtGraphicalEffects 1.14

import BaseQml 1.0

Item {
    implicitWidth: 100
    implicitHeight: 103

    property alias source: id_icon.source

    YImage {
        id: id_icon
        anchors.fill: parent
        fillMode: YImage.PreserveAspectCrop
        horizontalAlignment: YImage.AlignHCenter
        verticalAlignment: YImage.AlignVCenter
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
        source: id_icon
        maskSource: id_mask_icon
    }
}

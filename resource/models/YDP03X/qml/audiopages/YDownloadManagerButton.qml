import QtQuick 2.12

import BaseQml 1.0

YIconButton {
    implicitWidth: 44
    implicitHeight: 44
    radius: height/2
    mouseAreaMargins: -25
    iconSourceSize: Qt.size(36, 36)
    icon: "commons/download"

    anchors.left: parent.left
    anchors.leftMargin: 16
    anchors.bottom: parent.bottom
    anchors.bottomMargin: 18
}

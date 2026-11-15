import QtQuick 2.12
import BaseQml 1.0

YIconButton {
    width: 56
    height: 44
    radius: 12
    sourceSize: Qt.size(32, 32)
    color: "#1A1B1F"
    border.width: 1
    border.color: "#515259"
    scale: pressed ? 0.99 : 1
    Behavior on scale { NumberAnimation { duration: 90; easing.type: Easing.OutCubic } }
}

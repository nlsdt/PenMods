import QtQuick 2.12

YIconButton {
    implicitWidth: 44
    implicitHeight: 44
    radius: height/2
    mouseAreaMargins: -25

    iconSourceSize: Qt.size(36, 36)
    icon: "settings/refresh"

    signal refresh()

    onClicked: {
        refresh()
    }
}

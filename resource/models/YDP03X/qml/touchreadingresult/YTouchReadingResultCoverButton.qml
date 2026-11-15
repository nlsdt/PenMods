import QtQuick 2.12

import BaseQml 1.0

YButtonBase {
    implicitWidth: 84
    implicitHeight: 76
    radius: height/2

    property alias text: id_content.text
    property alias imageName: id_icon.imageName
    property alias imageVisible: id_icon.visible
    property alias spacing: id_row.spacing

    Row {
        id: id_row
        anchors.centerIn: parent
        height: 38
        spacing: 0

        YImage {
            id: id_icon
            sourceSize: Qt.size(38, 38)
            anchors.verticalCenter: parent.verticalCenter
        }

        YTextMedium {
            id: id_content
            width: paintedWidth
            height: paintedHeight
            anchors.verticalCenter: parent.verticalCenter
            font.pixelSize: 26
        }
    }
}

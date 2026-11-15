import QtQuick 2.12

import BaseQml 1.0

YButtonBase {
    id: id_icon_label_button_bg
    implicitWidth: 240
    implicitHeight: 84
    mouseAreaMargins: 0
    radius: 0

    property alias imageName: id_button_icon.imageName
    property alias sourceSize: id_button_icon.sourceSize

    property int spacing: 9
    property alias text: id_label.text
    readonly property alias textItem: id_label

    Item {
        anchors.centerIn: parent
        width: id_button_icon.width + spacing + id_label.width
        implicitHeight: 28

        YImage {
            id: id_button_icon
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            sourceSize: Qt.size(28, 28)
        }

        YText {
            id: id_label
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            font.pixelSize: 24
            color: YColors.grayText
            width: paintedWidth
            height: paintedHeight
        }
    }
}

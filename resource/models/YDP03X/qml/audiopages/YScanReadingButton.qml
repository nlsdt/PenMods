import QtQuick 2.12

import BaseQml 1.0

YButtonBase {
    anchors.top: parent.top
    anchors.right: parent.right
    implicitWidth: 378
    implicitHeight: 106

    property alias name: id_text.text
    property alias count: id_item_total.text

    YImage {
        anchors.left: parent.left
        anchors.leftMargin: 30
        anchors.verticalCenter: parent.verticalCenter
        sourceSize: Qt.size(50, 50)
        imageName: "audiopage/scan_audio"
    }

    Column {
        id: id_text_container
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.leftMargin: 110
        anchors.rightMargin: 30
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 16
        spacing: 8

        YTextMedium {
            id: id_text
            anchors.left: parent.left
            anchors.right: parent.right
            height: paintedHeight
            font.bold: true
        }

        YText {
            id: id_item_total
            anchors.left: parent.left
            anchors.right: parent.right
            font.pixelSize: 22
            color: "#99FFFFFF"
            height: paintedHeight
        }
    }
}


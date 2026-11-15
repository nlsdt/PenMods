import QtQuick 2.12

import BaseQml 1.0
import com.youdao.pen 1.0

Rectangle {
    width: 694
    height: 80
    anchors.left: parent.left
    anchors.right: parent.right
    color: YColors.grayNormal
    radius: 16

    property alias title: id_title.text
    property alias tip: id_tip.text
    property alias buttonText: id_button_text.text
    property bool isDone: false

    signal buttonClicked()

    Column {
        id: id_text_col
        anchors.left: parent.left
        anchors.leftMargin: 20
        anchors.verticalCenter: parent.verticalCenter
        width: 494

        YTextMedium {
            id: id_title
            anchors.left: parent.left
            textFormat: Text.RichText
        }

        YText {
            id: id_tip
            anchors.left: parent.left
            font.pixelSize: 24
            color: YColors.grayText
        }
    }

    Rectangle {
        id: id_config_button
        width: 170
        height: 60
        anchors.verticalCenter: parent.verticalCenter
        anchors.right: parent.right
        anchors.rightMargin: 20
        color: "#2D2E33"
        radius: 16
        visible: !isDone && id_button_text.text.length > 0

        YText {
            id: id_button_text
            anchors.centerIn: parent
            font.pixelSize: 24
        }

        YMouseArea {
            anchors.fill: parent
            onClicked: buttonClicked()
        }
    }

    YImage {
        width: 36
        height: 36
        anchors.verticalCenter: parent.verticalCenter
        anchors.right: id_config_button.right
        sourceSize: Qt.size(36, 36)
        imageName: isDone ? "update/update_check_pass" : "update/update_check_no_pass"
        visible: !id_config_button.visible
    }
}

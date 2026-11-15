import QtQuick 2.12

import BaseQml 1.0
import com.youdao.pen 1.0
import "../i18n"

Rectangle {
    width: 694
    height: 80
    anchors.left: parent.left
    anchors.right: parent.right
    color: YColors.grayNormal
    radius: 16

    property alias title: id_title.text

    signal buttonClicked()

    YTextMedium {
        id: id_title
        anchors.left: parent.left
        anchors.leftMargin: 20
        anchors.verticalCenter: parent.verticalCenter
        textFormat: Text.RichText
    }

    YText {
        anchors.right: parent.right
        anchors.rightMargin: 20
        anchors.verticalCenter: parent.verticalCenter
        textFormat: Text.RichText
        font.pixelSize: 24
        color: YColors.red
        text: YTranslateText.clean
    }

    YMouseArea {
        width: 88
        anchors.top: parent.top
        anchors.bottom:  parent.bottom
        anchors.right: parent.right
        onClicked: buttonClicked()
    }
}

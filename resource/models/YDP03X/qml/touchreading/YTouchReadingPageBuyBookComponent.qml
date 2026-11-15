import QtQuick 2.12

import BaseQml 1.0
import "../components"
import "../i18n"

Item {
    id: id_buy_book_component

    property alias source: id_icon.source
    property alias title: id_title.text

    YTextMedium {
        id: id_title
        anchors.left: parent.left
        anchors.leftMargin: 288
        anchors.right: parent.right
        anchors.rightMargin: 40
        anchors.top: parent.top
        anchors.topMargin: 40
        font.pixelSize: 32
        elide: YTextMedium.ElideRight
        font.family: fontManager.fontFamilyZhCn
    }

    YPointText {
        id: id_point_text_0
        spacing: 6
        pointItem.color: "#3FDCFF"
        pointItem.anchors.topMargin: 8
        textItem.text: YTranslateText.buyBookScanQrCodeTip
        textItem.font.family: fontManager.fontFamilyZhCn
        textItem.color: "#B3FFFFFF"
        anchors.left: parent.left
        anchors.leftMargin: 288
        anchors.right: parent.right
        anchors.rightMargin: 40
        anchors.top: parent.top
        anchors.topMargin: 112
    }

    YPointText {
        id: id_point_text_1
        spacing: 6
        pointItem.color: "#3FDCFF"
        pointItem.anchors.topMargin: 8
        textItem.text: YTranslateText.buyBookTip
        textItem.font.family: fontManager.fontFamilyZhCn
        textItem.color: "#B3FFFFFF"
        anchors.left: parent.left
        anchors.leftMargin: 288
        anchors.right: parent.right
        anchors.rightMargin: 40
        anchors.top: id_point_text_0.bottom
        anchors.topMargin: 10
    }

    Rectangle {
        implicitWidth: 176
        implicitHeight: 176
        anchors.left: parent.left
        anchors.leftMargin: 78
        anchors.verticalCenter: parent.verticalCenter
        radius: 12
        YImage {
            id: id_icon
            width: 160
            height: 160
            anchors.centerIn: parent
        }
    }
}

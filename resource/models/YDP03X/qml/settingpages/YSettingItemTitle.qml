import QtQuick 2.12

import BaseQml 1.0

Item {
    id: id_title_container
    anchors.left: parent.left
    anchors.right: parent.right
    height: id_title_item.height + 48

    property alias title: id_title_item.text
    property alias titleFontFamily: id_title_item.font.family
    property int titlePixelSize: 26

    YText {
        id: id_title_item
        font.pixelSize: titlePixelSize
        color: YColors.grayText
        textFormat: YTextBase.RichText
        wrapMode: YText.Wrap
        anchors.top: parent.top
        anchors.topMargin: 24
        lineHeightMode: YTextBase.FixedHeight
        lineHeight: 32
        width: parent.width
    }
}


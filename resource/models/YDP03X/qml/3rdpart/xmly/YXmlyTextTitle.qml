import QtQuick 2.12
import BaseQml 1.0

Item {
    id: id_title_container
    anchors.left: parent.left
    anchors.right: parent.right
    implicitHeight: 80

    property alias title: id_title_item.text
    property alias titleFontFamily: id_title_item.font.family

    YText {
        id: id_title_item
        font.pixelSize: 26
        color: YColors.grayText
        textFormat: YText.RichText
//        wrapMode: YText.Wrap
        anchors.top: parent.top
        anchors.topMargin: 26
        lineHeightMode: YText.FixedHeight
        lineHeight: 34
        width: parent.width
        elide:YText.ElideRight
    }
}

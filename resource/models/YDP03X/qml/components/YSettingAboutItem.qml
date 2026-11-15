import QtQuick 2.12

import BaseQml 1.0

YSettingItemBackground {
    implicitHeight: 76

    property alias title: id_title.text
    property alias titleColor: id_title.color
    property alias titlePixelSize: id_title.font.pixelSize
    property alias titleFontFamily: id_title.font.family
    property int titleRightMargin: 20
    property int titleLeftMargin: 20

    property alias value: id_value.text
    property alias valueColor: id_value.color
    property alias valuePixelSize: id_value.font.pixelSize
    // PenMods3 补：二代 YSettingAboutItem 暴露 valueItem 供 ChatAssistantSettings 调样式
    property alias valueItem: id_value
    property int valueRightMargin: 20

    YTextMedium {
        id: id_title
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        anchors.leftMargin: titleLeftMargin
        width: 500
        elide: YTextMedium.ElideRight
    }

    YText {
        id: id_value
        color: YColors.grayText
        anchors.verticalCenter: parent.verticalCenter
        anchors.right: parent.right
        anchors.rightMargin: valueRightMargin
        font.pixelSize: 26
        visible: text.length > 0
    }
}

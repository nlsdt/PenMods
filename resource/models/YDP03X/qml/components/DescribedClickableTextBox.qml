import QtQuick 2.12

import BaseQml 1.0
import "../common"
import "../components"

YSettingItemBackground {
    id: id_described_clickable_item
    implicitHeight: Math.max(76, 68 + (id_describe.visible ? id_describe.contentHeight + 4 : 0))
    opacity: !enabled ? 0.6 : opacityChangableWhenPressed && id_button.pressed ? 0.85 : 1
    scale: (id_button.pressed) ? 0.99 : 1.0

    Behavior on opacity {
        NumberAnimation {
            duration: 90
            easing.type: Easing.OutCubic
        }
    }

    Behavior on scale {
        NumberAnimation {
            duration: 90
            easing.type: Easing.OutCubic
        }
    }

    property alias title: id_title.text
    property alias describe: id_describe.text
    property alias value: id_value.text

    property alias pressed: id_button.pressed
    property bool opacityChangableWhenPressed: true

    property alias describeItem: id_describe

    signal clicked()

    YText {
        id: id_title
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.topMargin: 16
        anchors.leftMargin: 20
        font.pixelSize: 28
        width: parent.width - 40 - (id_value.visible ? id_value.width + 20 : 0)
        elide: Text.ElideRight
    }

    YText {
        id: id_describe
        anchors.top: id_title.bottom
        anchors.left: parent.left
        anchors.leftMargin: 20
        color: YColors.grayText
        font.pixelSize: 24
        visible: text.length > 0
        anchors.topMargin: 4
        width: parent.width - 40 - (id_value.visible ? id_value.width + 20 : 0)
        wrapMode: Text.Wrap
    }

    YText {
        id: id_value
        color: YColors.grayText
        anchors.verticalCenter: parent.verticalCenter
        anchors.right: parent.right
        anchors.rightMargin: 20
        font.pixelSize: 26
        width: Math.min(implicitWidth, parent.width * 0.4)
        elide: Text.ElideMiddle
        visible: text.length > 0
    }

    YMouseArea {
        id: id_button
        anchors.fill: parent
        onClicked: {
            id_described_clickable_item.clicked()
        }
        objectName: "DescribedClickableTextBox_YMouseArea"
    }

}

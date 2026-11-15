import QtQuick 2.12

import BaseQml 1.0

Item {
    width: id_point.width + spacing + id_label.width
    height: id_label.height

    readonly property alias pointItem: id_point
    readonly property alias textItem: id_label

    property int spacing: 16

    Rectangle {
        id: id_point
        implicitWidth: 6
        implicitHeight: 6
        radius: height/2
        color: YColors.grayText
        anchors.top: parent.top
        anchors.topMargin: 13
        anchors.left: parent.left
    }

    YTextBase {
        id: id_label
        width: parent.width - spacing - id_point.width
        height: paintedHeight
        anchors.right: parent.right
        wrapMode: YTextBase.Wrap
        color: YColors.grayText
        font.pixelSize: 24
    }
}

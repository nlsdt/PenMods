import QtQuick 2.12

import BaseQml 1.0

Rectangle {
    anchors.left: parent.left
    anchors.right: parent.right
    implicitHeight: 50
    color: "#BD1A1B1F"
    radius: height/2

    property string content: ""
    property string count: ""
    property string unit: ""

    YTextMedium {
        anchors.left: parent.left
        anchors.leftMargin: 18
        anchors.verticalCenter: parent.verticalCenter
        font.pixelSize: 18
        font.family: fontManager.fontFamilyZhCn
        text: content
    }

    Row {
        anchors.right: parent.right
        anchors.rightMargin: 18
        anchors.verticalCenter: parent.verticalCenter
        spacing: 4

        YTextMedium {
            font.pixelSize: 16
            font.family: fontManager.fontFamilyZhCn
            anchors.verticalCenter: parent.verticalCenter
            color: YColors.yellow
            text: count
        }

        YTextMedium {
            font.pixelSize: 18
            font.family: fontManager.fontFamilyZhCn
            anchors.verticalCenter: parent.verticalCenter
            text: unit
        }
    }
}

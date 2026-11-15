import QtQuick 2.12

import BaseQml 1.0
import "../components"

Item {
    anchors.left: parent.left
    anchors.leftMargin: 8
    anchors.top: parent.top
    anchors.topMargin: 8

    width: id_back_button.width + 8 + id_index_count_indicator.width + 20
    height: 60

    signal clicked()

    YTouchReadingModuleBackButton {
        id: id_back_button
        anchors.topMargin: showMargin - parent.anchors.leftMargin
        anchors.leftMargin: showMargin - parent.anchors.rightMargin
        opacity: id_back_button_mouse_area.pressed ? 0.6 : 1
    }

    YButtonBase {
        id: id_index_count_indicator
        width: id_row.width + 28
        implicitHeight: 42
        anchors.left: id_back_button.right
        anchors.leftMargin: 8
        radius: height/2
        color: "#1B1C30"
        border.width: 3
        border.color: "#21223A"
        opacity: id_back_button_mouse_area.pressed ? 0.6 : 1

        Row {
            id: id_row
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenterOffset: 2
            spacing: 0

            YTextBase {
                width: paintedWidth
                height: paintedHeight
                color: "#3E406B"
                font.family: fontManager.fontFamilyPinyin
                font.weight: Font.Bold
                font.pixelSize: 24
                text: readingBookReadingManager.activeSentenceIndex + 1
                anchors.verticalCenter: parent.verticalCenter
            }

            YSpacing {
                implicitWidth: 12
                implicitHeight: 24
                anchors.verticalCenter: parent.verticalCenter
                Rectangle {
                    implicitWidth: 3
                    implicitHeight: 12
                    anchors.centerIn: parent
                    radius: 2
                    color: "#2B2C4B"
                    rotation: 30
                }
            }

            YTextBase {
                width: paintedWidth
                height: paintedHeight
                color: "#3E406B"
                font.family: fontManager.fontFamilyPinyin
                font.weight: Font.Bold
                font.pixelSize: 24
                text: readingBookReadingManager.sentenceCount
                anchors.verticalCenter: parent.verticalCenter
            }
        }
    }

    YBackButtonBase {
        id: id_back_button_mouse_area
        anchors.fill: parent
        objectName: "YTouchReadingFollowPageBackButtonArea.qml_id_back_button_mouse_area"
        onTriggered: {
            parent.clicked()
        }
    }
}

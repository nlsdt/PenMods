import QtQuick 2.12

import BaseQml 1.0

Item {
    id: id_touch_reading_result_tips
    implicitWidth: 320
    implicitHeight: 76
    anchors.bottom: parent.bottom
    anchors.horizontalCenter: parent.horizontalCenter

    property alias text: id_content.text

    YImage {
        id: id_bg
        anchors.fill: parent
        sourceSize: Qt.size(320, 76)
        imageName: "touchreading/tips_bg"
        asynchronous: false

        YTextMedium {
            id: id_content
            font.pixelSize: 18
            anchors.centerIn: parent
            horizontalAlignment: YTextMedium.AlignHCenter
            font.family: fontManager.fontFamilyZhCn
            textFormat: YTextMedium.RichText
        }
    }
}

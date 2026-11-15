import QtQuick 2.12

import BaseQml 1.0

Item {
    implicitWidth: 208
    implicitHeight: 76
    property bool checked: false
    readonly property alias blurMaskRectangleItem: id_blur_mask_rectangle
    readonly property alias iconLabelButtonItem: id_icon_lable_button

    property alias sourceItem: id_blur_mask_rectangle.sourceItem
    property alias sourceRect: id_blur_mask_rectangle.sourceRect


    signal clicked()

    YBlurMaskRectangle {
        id: id_blur_mask_rectangle
        anchors.fill: parent
        visible: !checked

        Rectangle {
            anchors.fill: parent
            color: "#AA32325E"
            radius: height/2
        }
    }

    YIconLabelButton {
        id: id_icon_lable_button
        anchors.fill: parent
        color: checked ? "#644FEC" : "transparent"
        sourceSize: Qt.size(38, 38)
        onClicked: {
            parent.clicked()
        }
    }
}

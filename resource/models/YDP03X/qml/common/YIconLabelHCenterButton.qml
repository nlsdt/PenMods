import QtQuick 2.12

YButtonBase {
    id: id_icon_label_button_bg
    implicitWidth: 124
    implicitHeight: 50
    radius: height/2
    mouseAreaMargins: -5

    property alias iconSource: id_button_icon.imageName
    property alias iconSourceSize: id_button_icon.sourceSize
    property alias spacing: id_label.anchors.leftMargin
    property alias text: id_label.text
    readonly property alias iconItem: id_button_icon
    readonly property alias textItem: id_label

    Row {
        height: parent.height
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: 6

        YImage {
            id: id_button_icon
            anchors.verticalCenter: parent.verticalCenter
            cache: true
        }

        YText {
            id: id_label
            anchors.verticalCenter: parent.verticalCenter
        }
    }
}

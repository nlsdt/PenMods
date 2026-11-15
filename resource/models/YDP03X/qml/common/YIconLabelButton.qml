import QtQuick 2.12

YButtonBase {
    id: id_icon_label_button_bg
    width: visible ? (id_button_icon.width + leftMargin + spacing + rightMargin
           + id_label.width) : 0
    implicitHeight: 48
    radius: height/2
    mouseAreaMargins: -5

    property alias icon: id_button_icon.imageName
    property alias source: id_button_icon.imageName
    property alias imageName: id_button_icon.imageName

    property alias iconSourceSize: id_button_icon.sourceSize
    property alias sourceSize: id_button_icon.sourceSize

    property alias leftMargin: id_button_icon.anchors.leftMargin
    property alias spacing: id_label.anchors.leftMargin
    property int rightMargin: 20

    property alias text: id_label.text
    property alias pixelSize: id_label.font.pixelSize
    property alias textColor: id_label.color
    property alias textFormat: id_label.textFormat
    property alias textFontFamily: id_label.font.family
    property alias textFontWeight: id_label.font.weight
    property alias textLineHeight: id_label.lineHeight
    property alias textWrapMode: id_label.wrapMode
    property int realHeight: id_label.contentHeight
    readonly property alias textItem: id_label
    readonly property alias imageItem: id_button_icon

    property alias iconVisible: id_button_icon.visible

    YImage {
        id: id_button_icon
        anchors.left: parent.left
        anchors.leftMargin: 20
        anchors.verticalCenter: parent.verticalCenter
        cache: true
    }

    YText {
        id: id_label
        anchors.left: id_button_icon.right
        anchors.leftMargin: 6
        anchors.verticalCenter: parent.verticalCenter
        font.pixelSize: 26
        width: paintedWidth
        height: paintedHeight
    }
}

import QtQuick 2.12

YPressedBaseButton {
    implicitHeight: 80
    radius: height/2
    color: YColors.grayNormal

    property int pixelSize: 28
    readonly property alias textItem: id_button_tip
    property alias text: id_button_tip.text
    property alias textColor: id_button_tip.color
    property alias textWidth: id_button_tip.contentWidth
    property alias textFormat: id_button_tip.textFormat

    YTextMedium {
        id: id_button_tip
        anchors.centerIn: parent
        horizontalAlignment: Text.AlignHCenter
        font.pixelSize: pixelSize
    }
}

import QtQuick 2.12

Rectangle {
    id: id_button_bg
    opacity: (opacityOnPressed && id_button.pressed) || !enabled ? 0.6 : 1
    smooth: true
    color: YColors.grayNormal
    radius: 16

    readonly property alias mouseAreaItem: id_button
    property alias mouseAreaMargins: id_button.anchors.margins
    property alias mouseAreaLeftMargin: id_button.anchors.leftMargin
    property alias mouseAreaTopMargin: id_button.anchors.topMargin
    property alias mouseAreaRightMargin: id_button.anchors.rightMargin
    property alias mouseAreaBottomMargin: id_button.anchors.bottomMargin
    property alias clickable: id_button.enabled
    property alias pressed: id_button.pressed

    property alias hotAreaTesting: id_button.hotAreaTesting
    property alias buttonTimer: id_button.buttonTimer

    property bool opacityOnPressed: true

    signal clicked()
    signal validClicked()
    signal pressAndHold()

    YButtonBaseMouseArea {
        id: id_button
        anchors.fill: parent
        onClicked: {
            id_button_bg.clicked()
        }
        onValidClicked: {
            id_button_bg.validClicked()
        }
        onPressAndHold: {
            parent.pressAndHold()
        }
        objectName: "YButtonBase.qml_id_button"
    }
}

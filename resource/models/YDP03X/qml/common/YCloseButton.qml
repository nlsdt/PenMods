import QtQuick 2.12

Item {
    id: id_close_button_root
    objectName: "YCloseButton.qml"

    width: 28
    height: 28

    readonly property alias iconButtonBackgroundItem: id_close_button_bg
    readonly property alias closeButtonMouseAreaItem: id_close_button

    signal clicked()

    YIconButton {
        id: id_close_button_bg
        implicitWidth: 28
        implicitHeight: 28
        anchors.centerIn: parent
        color: YColors.yellow
        radius: 14
        icon: "commons/close"
        iconSourceSize: Qt.size(20, 20)
    }

    YMouseArea {
        id: id_close_button
        anchors.fill: parent
        anchors.margins:-5

        signal triggered()

        onClicked: {
            id_close_button_root.clicked()
        }
        objectName: "YMouseArea_" + id_close_button_root.objectName
    }
}

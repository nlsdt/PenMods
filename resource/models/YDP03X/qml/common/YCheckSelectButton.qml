import QtQuick 2.12

Item {
    id: id_check_button_root
    objectName: "YCheckSelectButton.qml"

    width: 28
    height: 28

    readonly property alias iconButtonBackgroundItem: id_check_button_bg
    readonly property alias checkButtonMouseAreaItem: id_check_button

    signal clicked()

    YIconButton {
        id: id_check_button_bg
        implicitWidth: 28
        implicitHeight: 28
        anchors.centerIn: parent
        color: enabled ? YColors.yellow : "#262626"
        radius: 14
        icon: enabled ? "textbook/select-check" : "textbook/select-check-unable"
        iconSourceSize: Qt.size(20, 20)
    }

    YMouseArea {
        id: id_check_button
        anchors.fill: parent
        anchors.margins: -5

        signal triggered()

        onClicked: {
            id_check_button_root.clicked()
        }
        objectName: "YMouseArea_" + id_check_button_root.objectName
    }
}

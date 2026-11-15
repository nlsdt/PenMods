import QtQuick 2.12

Item {
    id: id_back_button_root
    objectName: "YBackButton.qml"

    implicitWidth: 80
    implicitHeight: 80
    opacity: (opacityChangabled && (id_back_button.pressed || !enabled)) ? 0.6 : 1

    readonly property alias iconButtonBackgroundItem: id_back_button_bg
    readonly property alias backButtonMouseAreaItem: id_back_button
    property bool opacityChangabled: true

    signal clicked()

    YBackIconItem {
        id: id_back_button_bg
        anchors.horizontalCenter: parent.horizontalCenter
    }

    YBackButtonBase {
        id: id_back_button
        anchors.fill: parent
        anchors.topMargin: -20
        anchors.leftMargin: -20
        onTriggered:  {
            id_back_button_root.clicked()
        }
        objectName: "YBackButtonBase_" + id_back_button_root.objectName
    }
}


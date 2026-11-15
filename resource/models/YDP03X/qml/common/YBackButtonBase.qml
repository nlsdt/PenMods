import QtQuick 2.12

YMouseArea {
    id: id_back_button
    objectName: "YBackButtonBase.qml"

    signal triggered()

    onClicked: {
        triggered()
    }
}

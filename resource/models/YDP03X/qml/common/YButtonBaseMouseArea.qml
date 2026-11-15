import QtQuick 2.12

YMouseArea {
    id: id_button
    anchors.fill: parent
    signal validClicked()

    readonly property alias buttonTimer: id_button_timer

    onClicked: {
        if (!id_button_timer.running) {
            validClicked()
            id_button_timer.restart()
        }
    }
    objectName: "YButtonBaseMouseArea.qml_id_button"

    YTimer {
        id: id_button_timer
        interval: 500
        objectName: "YButtonBaseMouseArea.qml_id_button_timer"
    }
}

import QtQuick 2.12

YImage {
    opacity: id_image_button_ma.pressed ? 0.6 : 1

    property alias mouseAreaMargins: id_image_button_ma.anchors.margins
    signal clicked()
    YMouseArea {
        id: id_image_button_ma
        anchors.fill: parent
        onClicked: {
            parent.clicked()
        }
        objectName: "YImageButton.qml_id_image_button_ma"
    }
}

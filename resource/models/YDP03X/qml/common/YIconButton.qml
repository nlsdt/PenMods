import QtQuick 2.12

YButtonBase {
    id: id_icon_button

    property alias icon: id_button_icon.imageName
    property alias source: id_button_icon.imageName
    property alias imageName: id_button_icon.imageName
    property alias realSource: id_button_icon.source

    property alias iconSourceSize: id_button_icon.sourceSize
    property alias sourceSize: id_button_icon.sourceSize
    property alias iconOpacity: id_button_icon.opacity
    property alias asynchronous: id_button_icon.asynchronous

    readonly property QtObject buttonIconItem: id_button_icon

    YImage {
        id: id_button_icon
        anchors.centerIn: parent
    }
}

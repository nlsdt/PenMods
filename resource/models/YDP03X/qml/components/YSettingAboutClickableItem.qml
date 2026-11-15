import QtQuick 2.12

import BaseQml 1.0

YSettingAboutItem {
    id: id_setting_about_clickable_item
    opacity: (opacityChangableWhenPressed && (id_button.pressed || !enabled)) ? 0.6 : 1
    valueRightMargin: 8 + id_button_icon_loader.item.width + 20

    property alias icon: id_setting_about_clickable_item.source
    property string source: ""
    property alias imageName: id_setting_about_clickable_item.source

    property alias iconSourceSize: id_setting_about_clickable_item.sourceSize
    property size sourceSize: Qt.size(36, 36)
    property alias pressed: id_button.pressed
    property bool opacityChangableWhenPressed: true

    property alias iconComponent: id_button_icon_loader.sourceComponent
    property alias iconLoaded: id_button_icon_loader.isLoaded

    property alias titlePixelSize: id_setting_about_clickable_item.titlePixelSize
    property alias valuePixelSize: id_setting_about_clickable_item.valuePixelSize

    signal clicked()

    YLoader {
        id: id_button_icon_loader
        active: true
        anchors.verticalCenter: parent.verticalCenter
        anchors.right: parent.right
        anchors.rightMargin: 20
        sourceComponent: YImage {
            sourceSize: id_setting_about_clickable_item.sourceSize
            imageName: id_setting_about_clickable_item.source
        }
    }

    YButtonBaseMouseArea {
        id: id_button
        anchors.fill: parent
        onValidClicked: {
            id_setting_about_clickable_item.clicked()
        }
        objectName: "YSettingAboutClickableItem.qml_YMouseArea"
    }
}

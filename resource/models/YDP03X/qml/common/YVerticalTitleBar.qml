import QtQuick 2.12

YVerticalTitleBarBase {
    id: id_title_bar
    objectName: "YVerticalTitleBar.qml"

    signal callBack()

    readonly property alias backButtonItem: id_back_button
    readonly property alias iconButtonBackgroundItem: id_back_button.iconButtonBackgroundItem

    YBackButton {
        id: id_back_button
        onClicked: {
            callBack()
        }
        objectName: "YVerticalTitleBar.qml_" + id_title_bar.objectName
    }
}

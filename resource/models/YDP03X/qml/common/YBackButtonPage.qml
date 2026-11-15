import QtQuick 2.12

YPage {
    id: id_back_button_page
    objectName: "YBackButtonPage.qml"

    property bool ignoreDefaultBackButtonClicked: false
    signal backButtonClickedCallback()
    readonly property alias defaultTitleBar: id_title_bar

    YVerticalTitleBar {
        id: id_title_bar
        onCallBack: {
            if (!ignoreDefaultBackButtonClicked) {
                id_back_button_page.backButtonClicked()
                console.warn("YBackButtonPage.qml===backButtonClicked===objectName:",
                             id_back_button_page.objectName)
            }
            backButtonClickedCallback()
        }
        objectName: "YBackButtonPage.qml_" + id_back_button_page.objectName
    }
}

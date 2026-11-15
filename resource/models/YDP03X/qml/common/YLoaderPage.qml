import QtQuick 2.12

YLoader {
    id: id_loader_page
    state: "close"

    readonly property bool isShowing: ("show" === state) && isLoaded
    property string pageName: "loader_page"

    signal closed(string pageName)
    signal backButtonClicked()

    function show() {
        state = "show"
        active = true
    }

    function close() {
        state = "close"
        if (isLoaded) {
            item.opacity = 0
        }
        closed(pageName)
    }

    YVerticalTitleBar {
        id: id_title_bar
        visible: isShowing && !YInputProperty.inputPageShowing
        z: id_loader_page.isLoaded && (id_loader_page.item !== null) ? (id_loader_page.item.z + 1) : 0
        onCallBack: {
            backButtonClicked()
            console.log("YLoaderPage.qml===onCallBack===backButtonClicked")
        }
    }
}

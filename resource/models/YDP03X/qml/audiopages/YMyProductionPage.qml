import QtQuick 2.12

Loader {
    id: id_my_production_entry
    anchors.fill: parent

    signal backButtonClicked()

    sourceComponent: hiddenAll ? id_original_scan_audio_component : id_plugin_manager_component

    readonly property bool hiddenAll: typeof fileManager === "object"
                                      && fileManager !== null
                                      && fileManager.hiddenAll

    function show() {
        visible = true
        if (item && typeof item.show === "function") {
            item.show()
        }
    }

    onLoaded: {
        if (item && item.backButtonClicked && typeof item.backButtonClicked.connect === "function") {
            item.backButtonClicked.connect(backButtonClicked)
        }
    }

    Component {
        id: id_original_scan_audio_component
        YMyProductionPageComponent {}
    }

    Component {
        id: id_plugin_manager_component
        YPluginManagerPage {}
    }
}

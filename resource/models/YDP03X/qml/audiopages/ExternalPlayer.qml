import QtQuick 2.12
import "../common"

YBackButtonPage {
    id: page
    objectName: "YPage===ExternalPlayer.qml"

    // Compatibility with callers that pass a filename instead of opening it first.
    property string path: ""
    property bool initialized: false

    function activate() {
        if (!initialized || !visible)
            return;
        if (path.length) {
            externalPlayer.open(path);
            path = "";
        }
        if (typeof soundCenter !== "undefined") {
            soundCenter.stop();
            soundCenter.openAudioOutput();
        }
        content.start();
    }

    Component.onCompleted: {
        initialized = true;
        defaultTitleBar.visible = false;
        activate();
    }
    onVisibleChanged: {
        if (visible)
            activate();
        else if (initialized)
            content.stop();
    }
    Component.onDestruction: content.stop()

    ExternalPlayerContent {
        id: content
        anchors.fill: parent
        backend: externalPlayer
        onExitRequested: page.backButtonClicked()
    }
}

import QtQuick 2.12

// Keep the optional native import inside a Loader so missing/incompatible plugins
// can fall back without preventing this page (or the file manager) from loading.
Rectangle {
    id: content
    color: "black"
    clip: true

    property var backend
    property url embeddedSource: Qt.resolvedUrl("ExternalPlayerEmbedded.qml")
    property int requestId: 0
    property bool active: false
    property bool fallbackPending: false
    property bool fallbackDone: false
    property string fallbackReason: ""
    readonly property real uiScale: Math.max(0.5, Math.min(width / 320, height / 170))
    readonly property string statusText: {
        if (!backend || !backend.path.length)
            return "未选择视频";
        if (backend.fallbackError.length)
            return backend.fallbackError;
        if (backend.fallbackActive)
            return "已切换到 MPV 播放";
        return fallbackPending ? "正在切换播放器…" : "正在打开视频…";
    }

    signal exitRequested()

    function start() {
        if (active || !backend || !backend.path.length)
            return;
        requestId = backend.requestId;
        active = true;
        fallbackPending = false;
        fallbackDone = false;
        if (!backend.hasEmbeddedPlayer) {
            fallback("Embedded player is not installed");
            return;
        }
        startupTimer.start();
        embedded.setSource(embeddedSource, {
            "mediaUrl": backend.path,
            "subtitleUrl": backend.subtitlePath,
            "displayTitle": backend.title
        });
    }

    function stop() {
        active = false;
        fallbackPending = false;
        startupTimer.stop();
        if (embedded.item)
            embedded.item.stop();
        embedded.source = "";
        if (backend && requestId)
            backend.close(requestId);
    }

    function fallback(reason) {
        if (!active || fallbackPending || fallbackDone || requestId !== backend.requestId)
            return;
        fallbackPending = true;
        fallbackReason = reason;
        startupTimer.stop();
        // Stop and unload after the plugin's error callback returns. Its ALSA
        // output must be released before MPV tries to open the same device.
        Qt.callLater(performFallback);
    }

    function performFallback() {
        if (!active || !fallbackPending || requestId !== backend.requestId)
            return;
        var position = embedded.item ? embedded.item.position : 0;
        if (embedded.item)
            embedded.item.stop();
        embedded.source = "";
        fallbackDone = true;
        backend.fallbackToMpv(requestId, fallbackReason, position);
        fallbackPending = false;
    }

    Component.onDestruction: stop()

    Connections {
        target: content.backend
        function onMediaChanged() {
            if (content.active && content.requestId !== content.backend.requestId) {
                content.stop();
                content.exitRequested();
            }
        }
    }

    Text {
        font.family: fontManager.fontFamily
        anchors.centerIn: parent
        width: parent.width * 0.8
        text: content.statusText
        textFormat: Text.PlainText
        color: "#e6eaf0"
        font.pixelSize: 14 * content.uiScale
        horizontalAlignment: Text.AlignHCenter
        wrapMode: Text.Wrap
    }

    PlayerButton {
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.margins: 8 * content.uiScale
        width: 32 * content.uiScale
        height: width
        Accessible.name: "返回文件管理"
        contentItem: Text {
            font.family: fontManager.fontFamily
            text: "×"
            color: "white"
            font.pixelSize: 24 * content.uiScale
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }
        onClicked: { content.stop(); content.exitRequested(); }
    }

    Loader {
        id: embedded
        objectName: "embeddedPlayerLoader"
        anchors.fill: parent
        asynchronous: true
        onLoaded: {
            if (!content.active || content.requestId !== content.backend.requestId) {
                source = "";
                return;
            }
            item.failed.connect(content.fallback);
            item.playbackStarted.connect(function () { startupTimer.stop(); });
            item.exitRequested.connect(function () { content.stop(); content.exitRequested(); });
            item.start();
        }
        onStatusChanged: {
            if (status === Loader.Error)
                content.fallback("Cannot load FFmpeg QML plugin");
        }
    }

    Timer {
        id: startupTimer
        objectName: "embeddedStartupTimer"
        interval: 20000
        onTriggered: content.fallback("Embedded player startup timed out")
    }
}

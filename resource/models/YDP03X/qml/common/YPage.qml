import QtQuick 2.12
import com.youdao.pen 1.0

import "../utils"

YPopItem {
    id: id_ypage_root
    anchors.fill: parent
    objectName: "YPage.qml_YMouseArea"

    signal backButtonClicked()

    property bool animationEnabled: true
    property bool destroyOnBack: true
    property bool indexPageShowAnimationRunning: false
    property bool closabledPageWhileHomeKeyReleased: true

    readonly property bool animationRunning: false

    function show() {
        id_private_data.state = "show"
        visible = true
    }

    function close() {
        todoDestroy()
    }

    function todoDestroy() {
        id_private_data.state = "close"
        id_private_data.todoDestroy()
        visible = false
    }

    onBackButtonClicked: {
        console.warn("YPage.qml===backButtonClicked===objectName: ", objectName)
        close()
        if (typeof id_ypage_root.popId != "undefined") {
            YUtils.removeKey(id_ypage_root.popId)
        }
    }

    YBackground {
        id: id_private_data
        anchors.fill: parent
        state: "close"

        function todoDestroy(){
            if (destroyOnBack && ("close" === state) && (typeof id_ypage_root.visible != "undefined")) {
                id_ypage_root.visible = false
                id_ypage_root.destroy()
                console.warn("YPage.qml===destroy===called")
            }
        }
    }

    Connections {
        target: baseSignals
        ignoreUnknownSignals: true
        enabled: id_ypage_root.visible && closabledPageWhileHomeKeyReleased
        function onClosePageWhileHomeKeyReleased() {
            console.warn("YPage.qml===onClosePageWhileHomeKeyReleased===")
            backButtonClicked()
            id_private_data.todoDestroy()
        }
    }
}

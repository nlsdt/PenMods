import QtQuick 2.12

import "../utils"

YMouseArea {
    id: id_pop_item
    objectName: "YPopItem.qml"
    visible: false

    readonly property string currentPopId: YUtils.currentPopId

    function removeCurrentPopId() {
        if (typeof id_pop_item.popId !== undefined) {
            YUtils.removeKey(id_pop_item.popId, true)
        }
    }

    onCurrentPopIdChanged: {
        if (typeof id_pop_item.popId !== undefined) {
            visible = Qt.binding(function(){
                return currentPopId === id_pop_item.popId
            })
        }
    }

    Component.onDestruction: {
        console.log("YPopItem.qml===Component.onDestruction===called")
    }
}

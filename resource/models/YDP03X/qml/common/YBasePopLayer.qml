import QtQuick 2.12

import "../utils"

QtObject {
    id: id_pop_layer_qml

    property string state: "close"

    readonly property bool isShowing:
        (null !== popItemObject) && (typeof popItemObject.popId != "undefined") && (YUtils.currentPopId.length > 0)
    readonly property QtObject cachePagesMap: YUtils.globalMap
    readonly property QtObject stackPagesMap: YUtils.stackMap
    readonly property string popIdPrefix: "YPopItem_Id_"
    readonly property int count: YUtils.stackMap.count()

    property var popItemObject: null

    function cachePagesCount() {
        return cachePagesMap.size()
    }

    function hasCachePage() {
        return cachePagesCount() > 0
    }

    function showAnimation() {
        state = "show"
    }

    function closeAnimation() {
        state = "close"
    }

    function qmlCreateComponent(qmlName) {
        return Qt.createComponent(qmlName.startsWith("qrc:") ? qmlName: ("qrc:/qml/%1.qml").arg(qmlName))
    }

    function pop() {
        console.warn("YBasePopLayer.qml===YUtils.currentPopId: ", YUtils.currentPopId)
    }
}

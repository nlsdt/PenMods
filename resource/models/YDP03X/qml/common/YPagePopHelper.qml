import QtQuick 2.12

Item {
    id: id_page_pop_helper
    anchors.fill: parent

    readonly property alias busying: id_busy_timer.running
    readonly property alias containerItem: id_container_item

    property alias isShowing: id_container_item.visible

    YTimer {
        id: id_busy_timer
        interval: 120
        objectName: "YPagePopHelper.qml_id_busy_timer"
    }

    Item {
        id: id_container_item
        anchors.fill: parent
        visible: false
        onVisibleChanged: {
            id_busy_timer.restart()
        }
    }
}

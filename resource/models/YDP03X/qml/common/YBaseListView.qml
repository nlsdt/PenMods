import QtQuick 2.12
import QtQuick 2.15
ListView {
    cacheBuffer: 1000
    boundsBehavior: (0 === count) ? ListView.StopAtBounds : ListView.DragAndOvershootBounds

    property alias busyingInterval: id_delay_empty_tip_timer.interval
    readonly property alias busying: id_delay_empty_tip_timer.running
    readonly property alias empty: id_delay_empty_tip_timer.empty

    onCountChanged: {
        if (0 === count) {
            id_delay_empty_tip_timer.restart()
        } else {
            id_delay_empty_tip_timer.stop()
            id_delay_empty_tip_timer.empty = false
        }
    }

    YTimer {
        id: id_delay_empty_tip_timer
        property bool empty: (0 === count)
        interval: 360
        repeat: false
        objectName: "YBaseListView.qml_id_delay_empty_tip_timer"
        onTriggered: {
            empty = true
        }
    }

}

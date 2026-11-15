import QtQuick 2.12

YMouseArea {
    id: id_clicked_count_mouse_area
    objectName: "YClickedCountMouseArea.qml"

    property int count: 5
    property alias duration: id_continue_timer.interval

    signal triggered()

    onClicked: {
        id_continue_timer.restart()
        ++id_continue_timer.times
        if (count <= id_continue_timer.times) {
            id_clicked_count_mouse_area.triggered()
            id_continue_timer.triggered()
            id_continue_timer.stop()
        }
    }

    YTimer {
        id: id_continue_timer
        interval: 600
        objectName: ("%1_id_continue_timer").arg(parent.objectName)
        property int times: 0
        onTriggered: {
            times = 0
        }
    }
}

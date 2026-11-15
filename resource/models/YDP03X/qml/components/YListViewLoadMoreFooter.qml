import QtQuick 2.12

import BaseQml 1.0

Item {
    width: ListView.view.orientation === Qt.Horizontal ? 72 : ListView.view.width
    height: ListView.view.orientation === Qt.Vertical ? 72 : ListView.view.height

    YCircularProgressBar {
        id: id_progress_bar
        anchors.centerIn: parent
        lineCap: "round"
        lineWidth: 6
        progressValue: 25
        size: 40

        NumberAnimation on rotation {
            from: 0
            to: 360
            duration: 1920
            running: id_progress_bar.visible
            loops: NumberAnimation.Infinite
            alwaysRunToEnd: true
        }
    }
}

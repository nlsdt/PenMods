import QtQuick 2.12

Row {
    id: id_progress_indicator
    spacing: 6
    height: 16
    anchors.centerIn: parent

    property int totalCount: 5
    property int currentIndex: -1

    function reset() {
        currentIndex = 0
    }

    Repeater {
        id: id_progress_repeater
        model: totalCount

        Rectangle {
            implicitWidth: 16
            implicitHeight: 16
            radius: height/2
            smooth: true
            color: "#644FEC"

            Rectangle {
                implicitWidth: 18
                implicitHeight: 18
                anchors.centerIn: parent
                color: "transparent"
                radius: height/2
                border.color: "#FFFFFF"
                border.width: 2
                visible: index === currentIndex
            }
        }
    }
}

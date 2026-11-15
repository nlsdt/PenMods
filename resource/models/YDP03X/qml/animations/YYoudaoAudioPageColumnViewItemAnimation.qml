import QtQuick 2.12

import BaseQml 1.0

Item {
    implicitWidth: 36
    implicitHeight: 36

    property int itemWidth: 4
    property color itemColor: YColors.red
    property int interval: 250
    property alias running: id_animation.running

    Row {
        spacing: 5
        height: 24
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 5
        anchors.horizontalCenter: parent.horizontalCenter

        Rectangle {
            id: id_rect_0
            implicitWidth: itemWidth
            anchors.bottom: parent.bottom
            radius: itemWidth/2
            color: itemColor
        }
        Rectangle {
            id: id_rect_1
            implicitWidth: itemWidth
            anchors.bottom: parent.bottom
            radius: itemWidth/2
            color: itemColor
        }
        Rectangle {
            id: id_rect_2
            implicitWidth: itemWidth
            anchors.bottom: parent.bottom
            radius: itemWidth/2
            color: itemColor
        }
    }

    SequentialAnimation {
        id: id_animation
        loops: SequentialAnimation.Infinite
        ParallelAnimation {
            NumberAnimation { target: id_rect_0; property: "height"; to: 18; duration: interval }
            NumberAnimation { target: id_rect_1; property: "height"; to: 24; duration: interval }
            NumberAnimation { target: id_rect_2; property: "height"; to: 18; duration: interval }
        }
        ParallelAnimation {
            NumberAnimation { target: id_rect_0; property: "height"; to: 24; duration: interval }
            NumberAnimation { target: id_rect_1; property: "height"; to: 18; duration: interval }
            NumberAnimation { target: id_rect_2; property: "height"; to: 12; duration: interval }
        }
        ParallelAnimation {
            NumberAnimation { target: id_rect_0; property: "height"; to: 18; duration: interval }
            NumberAnimation { target: id_rect_1; property: "height"; to: 12; duration: interval }
            NumberAnimation { target: id_rect_2; property: "height"; to: 18; duration: interval }
        }
        ParallelAnimation {
            NumberAnimation { target: id_rect_0; property: "height"; to: 12; duration: interval }
            NumberAnimation { target: id_rect_1; property: "height"; to: 18; duration: interval }
            NumberAnimation { target: id_rect_2; property: "height"; to: 24; duration: interval }
        }
    }
}

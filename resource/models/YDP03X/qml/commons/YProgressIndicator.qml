import QtQuick 2.12
import BaseQml 1.0
Item {
    id: id_progress_indicator

    implicitWidth: id_background.width + spacing + id_progress_label.width
    implicitHeight: Math.max(id_background.height, id_progress_label.height)

    property alias backgroundColor: id_background.color
    property alias foregroundColor: id_foreground.color
    property int progress: 0
    property alias progressBarHeight: id_background.height
    property alias progressBarWidth: id_background.width
    property alias progressLabelHeight: id_progress_label.height
    property alias progressLabelWidth: id_progress_label.width
    property alias radius: id_background.radius
    property int spacing: 14

    Rectangle {
        id: id_background
        implicitWidth: 400
        implicitHeight: 10
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        color: "#1A1B1F"
        radius: 16

        readonly property int stepValue: Math.ceil(width / 100.0)
    }

    Rectangle {
        id: id_foreground
        implicitHeight: id_background.height
        width: Math.min(id_background.stepValue * progress, id_background.width)
        anchors.verticalCenter: parent.verticalCenter
        radius: id_background.radius
        visible: width > 16
        color: "#509DEB"
    }

    YText {
        id: id_progress_label
        width: 54
        height: 34
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        font.pixelSize: 26
        color: id_foreground.color
        text: ("%1%").arg(progress)
    }
}

import QtQuick 2.12
import QtGraphicalEffects 1.15

Item {
    property alias source: id_sourceimage.source
    property alias radius: id_mask.radius
    readonly property bool isLoaded: Image.Ready === id_sourceimage.status

    Image {
        id: id_sourceimage
        anchors.fill: parent
        sourceSize: Qt.size(parent.width, parent.height)
        asynchronous: true
        visible: false
    }

    Rectangle {
        id: id_mask
        width: parent.width
        height: parent.height
        radius: height / 2
        visible: false
    }

    OpacityMask {
        anchors.fill: id_sourceimage
        source: id_sourceimage
        maskSource: id_mask
    }
}

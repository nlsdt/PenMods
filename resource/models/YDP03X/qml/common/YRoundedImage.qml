import QtQuick 2.12

Image {
    id: id_image
    asynchronous: true
    sourceSize: Qt.size(44, 44)

    readonly property alias borderItem: id_border
    property color borderColor: YColors.grayNormal

    Rectangle {
        id: id_border
        anchors.fill: parent
        anchors.margins: -9
        color: "transparent"
        border.width: 9
        radius: width/2
        border.color: borderColor
    }
}

import QtQuick 2.12

YBaseListView {
    orientation: Qt.Horizontal
    clip: true
    readonly property bool isMoveToLeft: (horizontalVelocity > 0)
}

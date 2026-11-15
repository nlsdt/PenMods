import QtQuick 2.12

YBackground {
    signal clicked()
    YMouseArea {
        anchors.fill: parent
        onClicked: parent.clicked()
        objectName: "YBackgroundIgnoreMouseEvent.qml_YMouseArea"
    }
}

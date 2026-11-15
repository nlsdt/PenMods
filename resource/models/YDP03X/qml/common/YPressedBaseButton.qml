import QtQuick 2.12

YButtonBase {
    implicitWidth: 100
    implicitHeight: 72
    color: "#36373D"
    mouseAreaMargins: -2
    onClicked: {
        fromUser = true
    }

    readonly property bool checked: 1 === checkedIndicatorScale
    property bool fromUser: false
    property alias checkedIndicatorScale: id_checked_indicator.scale

    Rectangle {
        id: id_checked_indicator
        width: parent.width
        height: parent.height
        anchors.centerIn: parent
        radius: parent.radius
        antialiasing: true
        color: YColors.red
        scale: 0
    }
}

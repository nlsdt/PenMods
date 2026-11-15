import QtQuick 2.12

import BaseQml 1.0

Rectangle {
    id: id_back_button
    anchors.top: parent.top
    anchors.topMargin: showMargin
    anchors.left: parent.left
    anchors.leftMargin: showMargin
    implicitWidth: 115
    implicitHeight: 115
    color: "#20203E"
    radius: height/2
    opacity: id_back_button_ma.pressed ? 0.6 : 1

    Rectangle {
        implicitWidth: parent.width
        implicitHeight: 600
        anchors.bottom: parent.bottom
        anchors.bottomMargin: parent.height/2
        color: parent.color
    }

    property int showMargin: -52

    signal clicked()

    YImage {
        id: id_back_button_icon
        anchors.top: parent.top
        anchors.topMargin: 60
        anchors.left: parent.left
        anchors.leftMargin: 60
        sourceSize: Qt.size(38, 38)
        imageName: "touchreading/medal_set_back"
    }

    YBackButtonBase {
        id: id_back_button_ma
        anchors.fill: parent
        anchors.bottomMargin: -30
        anchors.rightMargin: -10
        objectName: "YTouchReadingModuleBackButton.qml_id_back_button_ma"
        onTriggered: {
            id_back_button.clicked()
        }
    }
}

import QtQuick 2.12

// The value of 'objectName' shoud be set, for hot area test

MouseArea {
    id: id_y_mouse_area
    objectName: "YMouseArea.qml"
    acceptedButtons: Qt.LeftButton
    hoverEnabled: false
    scrollGestureEnabled: false

    property bool hotAreaTesting: false // todo use config file open

    function qmlCreateComponent(qmlName) {
        return Qt.createComponent(("qrc:/qml/%1.qml").arg(qmlName))
    }

    onClicked: {
        console.log("YMouseArea.qml===", objectName, "===clicked")
    }

    YLoader {
        anchors.fill: parent
        active: hotAreaTesting && id_y_mouse_area.enabled
        sourceComponent: Rectangle {
            id: id_hot_area_test
            color: "#80FF0000"
        }
    }

    property bool isPressAndHold: false

    onPressAndHold: {
        isPressAndHold = true
    }

    onReleased: {
        isPressAndHold = false
    }

    onCanceled: {
        isPressAndHold = false
    }
}

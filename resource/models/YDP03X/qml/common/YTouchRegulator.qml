import QtQuick 2.12

Item {
    id: id_touch_regulator_root
    implicitWidth: 320
    implicitHeight: 92

    readonly property int margins: 10
    property int value: 0
    readonly property alias pressed: id_mouse_area.pressed

    onValueChanged: {
        if (value <= 0) {
            //positionPrograssZero()
            id_progress_rect.anchors.rightMargin
                    = id_touch_regulator_root.width
        } else if (value >= 100) {
            //positionPrograssFull()
            id_progress_rect.anchors.rightMargin = 0
        } else {
            id_progress_rect.anchors.rightMargin
                    = id_touch_regulator_root.width - parseInt(value * 3.2) + margins
        }
    }

    YMouseArea {
        id: id_mouse_area
        anchors.fill: parent
        anchors.leftMargin: -margins
        anchors.rightMargin: -margins
        objectName: "YTouchRegulator.qml_YMouseArea"

        Component.onCompleted: {
            id_progress_rect.anchors.rightMargin
                    = id_touch_regulator_root.width - 3.2 * value + margins
        }

        onClicked: {
            positionPrograss(mouseX)
        }

        onMouseXChanged: {
            if (containsPress) {
                positionPrograss(mouseX)
            }
        }

        function positionPrograss(posX) {
            if (posX <= margins) {
                positionPrograssZero()
            } else if (posX >= margins + id_touch_regulator_root.width) {
                positionPrograssFull()
            } else {
                value = parseInt(posX / 3.2)
                id_progress_rect.anchors.rightMargin
                        = id_touch_regulator_root.width - posX + margins
            }
        }

        function positionPrograssZero() {
            value = 0
            id_progress_rect.anchors.rightMargin
                    = id_touch_regulator_root.width
        }

        function positionPrograssFull() {
            value = 100
            id_progress_rect.anchors.rightMargin = 0
        }
    }

    Rectangle {
        anchors.fill: parent
        color: "#77878A99"
        radius: height/2
        smooth: true

        Item {
            id: id_progress_rect
            anchors.fill: parent
            smooth: true
            clip: true

            Rectangle {
                implicitWidth: id_touch_regulator_root.width
                implicitHeight: id_touch_regulator_root.height
                anchors.right: parent.right
                anchors.rightMargin: -parent.anchors.rightMargin
                color: "#FFFFFF"
                radius: height/2
                smooth: true
            }
        }
    }
}

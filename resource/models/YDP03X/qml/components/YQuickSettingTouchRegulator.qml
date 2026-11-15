import QtQuick 2.12
import BaseQml 1.0

Item {
    id: id_touch_regulator_root
    implicitWidth: 288
    implicitHeight: 82

    readonly property int margins: 20
    property int value: 0
    readonly property alias pressed: id_mouse_area.pressed
    property alias progressBackGroundColor: id_progress_background.color
    property alias progressForeGroundColor: id_progress_foreground_rect.color
    readonly property real __coefficient: width*1.0/maxValue
    property int maxValue: 100
    property int minValue: 0

    function decrementTenValue() { // -10 every time
        value = Math.max(minValue, value - 10)
    }

    function incrementTenValue() { // +10 every time
        value = Math.min(maxValue, value + 10)
    }

    onValueChanged: {
        console.log("YTouchRegulator.qml==onValueChanged=1==="+value)
        if (value <= 0) {
            //positionPrograssZero()
            id_progress_foreground_rect.anchors.rightMargin
                    = id_touch_regulator_root.width
        } else if (value >= 100) {
            //positionPrograssFull()
            id_progress_foreground_rect.anchors.rightMargin = 0
        } else {
            id_progress_foreground_rect.anchors.rightMargin
                    = id_touch_regulator_root.width - parseInt(value * __coefficient)
        }
    }

    YMouseArea {
        id: id_mouse_area
        anchors.fill: parent
        anchors.leftMargin: -margins
        anchors.rightMargin: -margins
        objectName: "YTouchRegulator.qml_YMouseArea"

        Component.onCompleted: {
            id_progress_foreground_rect.anchors.rightMargin
                    = id_touch_regulator_root.width - __coefficient * value
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
            if (posX <= margins-5) {
                positionPrograssZero()
            } else if (posX >= id_touch_regulator_root.width) {
                positionPrograssFull()
            } else {
                value = parseInt(posX / __coefficient)
                id_progress_foreground_rect.anchors.rightMargin
                        = id_touch_regulator_root.width - posX
            }
        }

        function positionPrograssZero() {
            value = 0
            id_progress_foreground_rect.anchors.rightMargin
                    = id_touch_regulator_root.width
        }

        function positionPrograssFull() {
            value = 100
            id_progress_foreground_rect.anchors.rightMargin = 0
        }
    }

    Item {
        id: id_progress_item
        anchors.fill: parent
        smooth: true

        Rectangle{
            id: id_progress_background
            anchors.fill: parent
            anchors.leftMargin: -id_touch_regulator_root.height
            color: YColors.touchRegulatorBackground
            radius: height/2
            smooth: true
        }

        Rectangle {
            id: id_progress_foreground_rect
            implicitWidth: id_touch_regulator_root.width
            implicitHeight: id_touch_regulator_root.height
            anchors.left: parent.left
            anchors.leftMargin: -height
            anchors.right: parent.right
            anchors.rightMargin: -parent.anchors.rightMargin
            color: YColors.touchRegulatorForeground
            radius: height/2
            smooth: true
        }

        Rectangle{
            id: id_progress_direction
            anchors.right: id_progress_foreground_rect.right
            anchors.rightMargin: 12
            anchors.verticalCenter: id_progress_foreground_rect.verticalCenter
            implicitWidth: 4
            implicitHeight: 16
            color: YColors.touchRegulatorProgressDirection
            visible: value > 0 ? true: false
        }

    }
}

import QtQuick 2.12

YMouseArea {
    id: id_slider_root
    implicitWidth: 518
    implicitHeight: 100

    readonly property int margins: 22
    readonly property real __coefficient: width*1.0/maxValue

    property int sliderHeight: 8
    property int value: -1
    property int maxValue: 100
    property int minValue: 0

    function bound(min, val, max) {
        return Math.max(min, Math.min(val, max))
    }

    function decrementTenValue() { // -10 every time
        value = Math.max(minValue, value - 10)
    }

    function incrementTenValue() { // +10 every time
        value = Math.min(maxValue, value + 10)
    }

    onValueChanged: {
        if (value === minValue) {
            id_progress_rect.anchors.rightMargin
                    = id_slider_root.width
            id_indicator_rect.x = - margins
        } else if (value === maxValue) {
            id_progress_rect.anchors.rightMargin = 0
            id_indicator_rect.x = id_slider_root.width - margins
        } else {
            id_progress_rect.anchors.rightMargin
                    = id_slider_root.width - __coefficient*value - margins
            id_indicator_rect.x = __coefficient*value
        }
    }
    onClicked: {
        value = bound(minValue, parseInt(mouseX / __coefficient), maxValue)
    }

    Item {
        id: sourceRect
        height: sliderHeight
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter

        Rectangle {
            anchors.fill: parent
            radius: height/2
            color: "#878A99"
        }

        Rectangle {
            id: id_progress_rect
            anchors.fill: parent
            radius: height/2
            color: YColors.blueRect
        }

        Rectangle {
            id: id_indicator_rect
            implicitWidth: 44
            implicitHeight: 44
            radius: width/2
            anchors.verticalCenter: parent.verticalCenter
            color: "#FFFFFF"

            Drag.active: id_drag_area.drag.active
            Drag.hotSpot.x: width / 2
            Drag.hotSpot.y: height / 2
            Drag.supportedActions: Qt.IgnoreAction

            function positionPrograssZero() {
                value = minValue
            }

            function positionPrograssFull() {
                value = maxValue
            }

            onXChanged: {
                if (x <= (-margins)) {
                    positionPrograssZero()
                } else if (x >= (id_slider_root.width - margins)) {
                    positionPrograssFull()
                } else {
                    value = bound(minValue, parseInt(x / __coefficient), maxValue)
                }
            }

            YMouseArea {
                id: id_drag_area
                anchors.fill: parent
                anchors.margins: -margins
                drag.target: parent
                drag.axis: Drag.XAxis
                drag.minimumX: -margins
                drag.maximumX: id_slider_root.width - margins
                objectName: "YSlider.qml_YMouseArea"
            }
        }
    }
    objectName: "YSlider.qml"
}

import QtQuick 2.12

import "../utils"

Item {
    anchors.fill: parent

    readonly property bool currentPopIdValid: YUtils.currentPopId.length > 0

    YMouseArea {
        anchors.fill: parent
        visible: currentPopIdValid
        objectName: "YStackView.qml_event_ignore"
    }

    Rectangle {
        id: id_stack_view_bg
        anchors.fill: parent
        color: "#000000"
        opacity: currentPopIdValid
    }

    Item {
        id: id_stack_view_container
        anchors.fill: parent
        readonly property int childrenCount: children.length
        Component.onCompleted: {
            YUtils.stackView = id_stack_view_container
        }
    }
}

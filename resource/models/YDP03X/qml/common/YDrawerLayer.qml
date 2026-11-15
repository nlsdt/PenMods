import QtQuick 2.12
import com.youdao.pen 1.0

YMouseArea {
    id: id_drawer_layer
    width: YBaseEnum.Screen.Width
    height: YBaseEnum.Screen.Height
    anchors.left: parent.left
    enabled: "show" === state
    objectName: "YDrawerLayer.qml_id_drawer_layer"

    default property alias content: id_drawer_container.data

    property int indicatorLeftMargin: 20
    property int indicatorRightMargin: 42
    property int drawerContainerRightMargin: 40
    property alias containerWidth: id_drawer_container.width
    property bool backIndicatorButtonEnabled: true

    readonly property bool showing: "show" === state

    signal callDrawerLayerBack()

    signal beginToShow()

    function show() {
        beginToShow()
        state = "show"
    }
    function hide() {
        state = "hide"
    }

    YBackground {
        id: id_bg
        anchors.fill: parent
        opacity: 0.7
    }

    YMouseArea {
        id: id_drawer_layer_back_indicator_button
        anchors.fill: parent
        anchors.rightMargin: id_background.width - indicatorLeftMargin
                             - id_drawer_layer_back_indicator.width
        enabled: backIndicatorButtonEnabled
        onClicked: {
            if (backIndicatorButtonEnabled) {
                hide()
                callDrawerLayerBack()
            }
        }
        objectName: "YDrawerLayer.qml_id_drawer_layer_back_indicator_button"
    }

    Rectangle {
        id: id_background
        color: "#16171A"
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        width: (backIndicatorButtonEnabled ? 48 : 0) + indicatorLeftMargin
               + indicatorRightMargin + id_drawer_container.width
               + drawerContainerRightMargin
        radius: 16

        Rectangle {
            id: id_background_top_right
            color: id_background.color
            anchors.right: parent.right
            implicitWidth: 30
            implicitHeight: 30
        }

        Rectangle {
            id: id_background_bottom_right
            color: id_background.color
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            implicitWidth: 30
            implicitHeight: 30
        }

        Rectangle {
            id: id_drawer_layer_back_indicator
            implicitWidth: backIndicatorButtonEnabled ? 46 : 0
            implicitHeight: 70
            radius: 16
            color: "#2D2E33"
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            anchors.leftMargin: indicatorLeftMargin
            YImage {
                sourceSize: Qt.size(36, 36)
                imageName: backIndicatorButtonEnabled ? "commons/drawer_back" : ""
                anchors.centerIn: parent
                visible: backIndicatorButtonEnabled
            }
            opacity: id_drawer_layer_back_indicator_button.pressed ? 0.6 : 1
            visible: backIndicatorButtonEnabled
        }

        Item {
            id: id_drawer_container
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.right: parent.right
            anchors.rightMargin: drawerContainerRightMargin
        }
    }

    state: "hide"
    states: [
        State {
            name: "hide"
            PropertyChanges { target: id_drawer_layer; anchors.leftMargin: width + 6 }
            PropertyChanges { target: id_bg; opacity: 0 }
        },
        State {
            name: "show"
            PropertyChanges { target: id_drawer_layer; anchors.leftMargin: 0 }
            PropertyChanges { target: id_bg; opacity: 0.6 }
        }
    ]
    transitions: [
        Transition {
            NumberAnimation { properties: "anchors.leftMargin, opacity"; duration: 180 }
        }
    ]
}

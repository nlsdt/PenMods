import QtQuick 2.12

YItem {
    id: id_dialog
    visible: isShowing
    default property alias content: id_content.data
    readonly property bool isShowing: "show" === id_bg.state
    readonly property alias fastBlurItem: id_bg
    property bool animationEnabled: true

    signal closed()

    function show() {
        id_bg.state = "show"
    }

    function close() {
        id_bg.state = "close"
    }

    YMouseArea {
        anchors.fill: parent
        visible: isShowing
        objectName: "YDialog.qml_YMouseArea"
    }

    YFastBlurRectangle {
        id: id_bg
        anchors.fill: parent
        maskItem.color: "#E6000000"
        maskItem.radius: 0
        blurRadius: 64
        state: animationEnabled ? "close" : "show"

        states: [
            State {
                name: "show"
                PropertyChanges {
                    target: id_content
                    anchors.topMargin: 0
                }
                PropertyChanges {
                    target: id_bg
                    opacity: 1
                }
            },State {
                name: "close"
                PropertyChanges {
                    target: id_content
                    anchors.topMargin: id_dialog.height
                }
                PropertyChanges {
                    target: id_bg
                    opacity: 0
                }
            }
        ]

        transitions: Transition {
            enabled: animationEnabled
            NumberAnimation {
                properties: "anchors.topMargin, opacity, scale"
                duration: 180
            }
        }
    }

    Item {
        id: id_content
        width: parent.width
        height: parent.height
        anchors.top: parent.top
        anchors.topMargin: id_dialog.height
    }

    objectName: "YDialog.qml"
}

import QtQuick 2.12

Item {
    property int t_interval: 960
    YBackgroundIgnoreMouseEvent {
        anchors.fill: parent
        opacity: 0.3
        visible: id_error_tip_timer.running
    }

    Rectangle {
        id: id_global_toast
        implicitHeight: id_tip_content.lineCount === 1 ? 62 : 84
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        color: "#E9900C"
        visible: false
        property bool showing: false
        function show(qsMsg, clrBg) {
            id_global_toast.color = clrBg
            id_tip_content.text = qsMsg
            showing = true
            visible = true
            anchors.bottomMargin = 0
            id_error_tip_timer.restart()
        }

        function showLoading(qsMsg, clrBg) {
            id_global_toast.color = clrBg
            id_tip_content.text = qsMsg
            showing = true
            visible = true
            anchors.bottomMargin = 0
        }

        YText {
            id: id_tip_content
            width: 740
            anchors.centerIn: parent
            wrapMode: YText.WordWrap
            horizontalAlignment: YText.AlignHCenter
            font.pixelSize: 26
            color: "#FFFFFF"
        }
        Behavior on anchors.bottomMargin {
            NumberAnimation {
                duration: 360
                onStopped: {
                    if (id_global_toast.showing) {
                        id_global_toast.visible = false
                        id_global_toast.showing = false
                    }
                }
            }
        }
        YTimer {
            id: id_error_tip_timer
            interval: t_interval
            objectName: "YToast.qml_id_error_tip_timer"
            onTriggered: {
//                id_global_toast.anchors.bottomMargin = -id_global_toast.height
                hideToast()
            }
        }
    }

    function hideToast(){
        id_global_toast.anchors.bottomMargin = -id_global_toast.height
    }

    Connections {
        target: baseSignals
        ignoreUnknownSignals: true
        function onShowToast(qsMsg, clrBg) {
            t_interval = 960
            id_global_toast.show(qsMsg, clrBg)
        }
        function onShowToastEx(qsMsg, clrBg, toastInterval){
            t_interval = toastInterval
            id_global_toast.show(qsMsg, clrBg)
        }

        function onShowLoading(qsMsg, clrBg) {
            id_global_toast.showLoading(qsMsg, clrBg)
        }

        function onHideLoading(){
            hideToast()
        }
    }
}

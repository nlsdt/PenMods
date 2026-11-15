import QtQuick 2.12

import com.youdao.pen 1.0

import BaseQml 1.0


Rectangle {
    id: id_videoplayer_toast
    implicitHeight: 62
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.bottom: parent.bottom
    color: "#E9900C"
    visible: false
    property bool showing: false

    function showToast(qsMsg, clrBg) {
        id_videoplayer_toast.color = clrBg
        id_tip_content.text = qsMsg
        showing = true
        visible = true
        anchors.bottomMargin = 0
        id_error_tip_timer.restart()
    }

    YText {
        id: id_tip_content
        width: 740
        anchors.centerIn: parent
        wrapMode: YText.WordWrap
        horizontalAlignment: YText.AlignHCenter
        font.pixelSize: 26
        textFormat: YText.RichText
        color: "#FFFFFF"
    }
    Behavior on anchors.bottomMargin {
        NumberAnimation {
            duration: 360
            onStopped: {
                if (id_videoplayer_toast.showing) {
                    id_videoplayer_toast.visible = false
                    id_videoplayer_toast.showing = false
                }
            }
        }
    }
    YTimer {
        id: id_error_tip_timer
        interval: 960
        objectName: "YMathExerciseToast.qml_id_error_tip_timer"
        onTriggered: {
            id_videoplayer_toast.anchors.bottomMargin = - id_videoplayer_toast.height
        }
    }
}

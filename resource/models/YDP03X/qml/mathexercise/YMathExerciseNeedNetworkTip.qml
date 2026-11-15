import QtQuick 2.12
import com.youdao.pen 1.0

import BaseQml 1.0
import "../i18n"

YBackgroundIgnoreMouseEvent {
    id: id_exercise_need_network_tip
    objectName: "YMathExerciseNeedNetworkTip.qml"
    anchors.fill: parent
//    anchors.leftMargin: 80
    visible: false

    signal configWifi()
    signal closed()
    signal backButtonClicked()

    function show() {
        visible = true
    }

    function close() {
        visible = false
    }

    Item {
        anchors.fill: parent

        YText {
            id: id_tip
            font.pixelSize: 28
            anchors.left: parent.left
            anchors.leftMargin: 100
            anchors.right: parent.right
            anchors.rightMargin: 100
            anchors.top: parent.top
            anchors.topMargin: 30
            height: 110
            horizontalAlignment: YText.AlignHCenter
            verticalAlignment: YText.AlignVCenter
            wrapMode: YText.Wrap
            text: YTranslateText.exerciseNeedNetWork
        }

        YButton {
            id: id_refuse_button
            implicitWidth: 240
            anchors.top: id_tip.bottom
            anchors.topMargin: 10
            anchors.left: parent.left
            anchors.leftMargin: 152
            color: YColors.grayNormal
            text: YTranslateText.cancel
            onClicked: {
                close()
            }
        }

        YButton {
            id: id_button
            implicitWidth: 240
            anchors.top: id_tip.bottom
            anchors.topMargin: 10
            anchors.right: parent.right
            anchors.rightMargin: 152
            color: YColors.red
            text: YTranslateText.toConnectNetwork
            onClicked: {
                configWifi()
            }
        }

        YVerticalTitleBar {
            id: id_title_bar
            backButtonItem.iconButtonBackgroundItem.asynchronous: false
            onCallBack: {
                backButtonClicked()
            }
        } // YVerticalTitleBar
    }
}

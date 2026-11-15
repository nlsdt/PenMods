import QtQuick 2.12

import BaseQml 1.0
import "../i18n"

YDrawerLayer {
    id: id_drawer_layer
    indicatorLeftMargin: 16
    indicatorRightMargin: 48
    drawerContainerRightMargin: 30
    containerWidth: 460

    property string columnId: ""
    property string columnTitle: ""

    Flickable {
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        width: containerWidth
        contentHeight: 144 + id_confirm_button.height
                       + id_confirm_button.anchors.bottomMargin

        YText {
            id: id_title
            font.pixelSize: 28
            anchors.bottom: id_confirm_button.top
            anchors.bottomMargin: 20
            width: containerWidth
            height: paintedHeight
            wrapMode: YText.Wrap
            horizontalAlignment: YText.AlignHCenter
            text: YTranslateText.myProductionAudiosFilter.arg(columnTitle)
        }

        YButton {
            implicitWidth: 190
            color: "#2D2E33"
            text: YTranslateText.cancel
            anchors.verticalCenter: id_confirm_button.verticalCenter
            anchors.right: id_confirm_button.left
            anchors.rightMargin: 24
            onClicked: {
                hide()
            }
        }

        YButton {
            id: id_confirm_button
            implicitWidth: 190
            text: YTranslateText.confirm
            anchors.right: parent.right
            anchors.rightMargin: 62 - drawerContainerRightMargin
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 30
            onClicked: {
                logManager.sendHttpLog("action=listening_make_bag_setting_click")
                columnManager.setDefaultScanning(columnId)
                hide()
            }
        }
    }
}

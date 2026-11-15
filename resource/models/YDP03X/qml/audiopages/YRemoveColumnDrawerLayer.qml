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
        contentHeight: 254

        YText {
            id: id_title
            font.pixelSize: 28
            anchors.bottom: id_remove_button.top
            anchors.bottomMargin: (lineCount > 1) ? 20 : 39
            width: containerWidth
            height: paintedHeight
            wrapMode: YText.Wrap
            horizontalAlignment: YText.AlignHCenter
            text: YTranslateText.removeRequest.arg(columnTitle)
        }

        YButton {
            implicitWidth: 190
            color: "#2D2E33"
            text: YTranslateText.cancel
            anchors.verticalCenter: id_remove_button.verticalCenter
            anchors.right: id_remove_button.left
            anchors.rightMargin: 24
            onClicked: {
                hide()
            }
        }

        YButton {
            id: id_remove_button
            implicitWidth: 190
            text: YTranslateText.del
            anchors.right: parent.right
            anchors.rightMargin: 62 - drawerContainerRightMargin
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 30
            onClicked: {
                columnManager.remove(columnId)
                hide()
            }
        }
    }
}

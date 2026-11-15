import QtQuick 2.12

import BaseQml 1.0
import "../i18n"

YDrawerLayer {
    id: id_drawer_layer
    indicatorLeftMargin: 60
    indicatorRightMargin: 0
    drawerContainerRightMargin: 60
    containerWidth: 400

    property var callbackFunction: null

    Flickable {
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        width: containerWidth
        contentHeight: 144 + id_remove_button.height
                       + id_remove_button.anchors.bottomMargin

        YText {
            id: id_title
            font.pixelSize: 28
            anchors.bottom: id_remove_button.top
            anchors.bottomMargin: 22
            width: containerWidth
            height: paintedHeight
            wrapMode: YText.Wrap
            horizontalAlignment: YText.AlignHCenter
            text: YTranslateText.copyrightDescription
        }

        YButton {
            id: id_remove_button
            implicitWidth: 240
            text: YTranslateText.iKnow
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 30
            onClicked: {
                callbackFunction()
                hide()
            }
        }
    }
}

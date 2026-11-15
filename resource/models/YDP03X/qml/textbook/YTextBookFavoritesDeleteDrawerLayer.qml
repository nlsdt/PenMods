import QtQuick 2.12
import com.youdao.pen 1.0

import BaseQml 1.0
import "../i18n"

YDrawerLayer {
    id: id_drawer_layer
    indicatorLeftMargin: 16
    indicatorRightMargin: 50
    drawerContainerRightMargin: 30
    containerWidth: 460
    property string blockTitle: ""
    function updateIndex() {
        currentIndex = 1
    }

    property int currentIndex: 1
    signal filterChanged(bool bdelete)

    Flickable {
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        width: 460
        flickableDirection: Flickable.VerticalFlick
        contentHeight: 24 + 16 + id_title.contentHeight
                       + id_cancel_button.height + 30

        YText {
            id: id_title
            color: YColors.white
            font.pixelSize: 28
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.topMargin: 30
            wrapMode: YText.Wrap
            horizontalAlignment: YText.Center
            width: parent.width
            font.family: fontManager.fontFamilyZhCn
            text: ("确认删除“%1”吗？").arg(blockTitle)
        }

        Row {
            anchors.left: parent.left
            anchors.leftMargin: 32
            anchors.right: parent.right
            anchors.top: id_title.bottom
            anchors.topMargin: 10 + 34
            spacing: 16

            YButton {
                id: id_cancel_button
                implicitWidth: 190
                implicitHeight: 80
                color: 0 === currentIndex ? YColors.red : "#2D2E33"
                textFamily: fontManager.fontFamilyZhCn
                text: ("取消")
                onClicked: {
                    currentIndex = 0
                    filterChanged(false)
                    hide()
                }
            }

            YButton {
                id: id_del_button
                implicitWidth: 190
                implicitHeight: 80
                color: 1 === currentIndex ? YColors.red : "#2D2E33"
                textFamily: fontManager.fontFamilyZhCn
                text: ("删除")
                onClicked: {
                    currentIndex = 1
                    filterChanged(true)
                    hide()
                }
            }
        }
    }
}


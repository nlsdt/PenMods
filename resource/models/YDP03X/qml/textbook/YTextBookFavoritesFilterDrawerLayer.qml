import QtQuick 2.12
import com.youdao.pen 1.0

import BaseQml 1.0
import "../i18n"

YDrawerLayer {
    id: id_drawer_layer
    indicatorLeftMargin: 16
    indicatorRightMargin: 50
    drawerContainerRightMargin: 30
    containerWidth: id_time_button.width

    property int currentIndex: 0
    signal filterChanged(int filterInt)

    Flickable {
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        width: id_time_button.width
        flickableDirection: Flickable.VerticalFlick
        contentHeight: 24 + 16 + id_title.contentHeight
                       + id_time_button.height + id_content_button.height+ 30

        YTextBase {
            id: id_title
            color: YColors.grayText
            font.pixelSize: 26
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.topMargin: 24
            font.family: fontManager.fontFamilyZhCn
            text: YTranslateText.textbookFavoritesChooseSort
        }

        YButton {
            id: id_time_button
            implicitWidth: 450
            color: 0 === currentIndex ? YColors.red : "#2D2E33"
            mouseAreaMargins: -4
            textFamily: fontManager.fontFamilyZhCn
            anchors.left: parent.left
            anchors.top: id_title.bottom
            anchors.topMargin: 16
            text: YTranslateText.textbookFavoritesSortByTime
            onClicked: {
                currentIndex = 0
                filterChanged(currentIndex)
                hide()
            }
        }

        YButton {
            id: id_content_button
            implicitWidth: 450
            color: 1 === currentIndex ? YColors.red : "#2D2E33"
            mouseAreaMargins: -4
            textFamily: fontManager.fontFamilyZhCn
            anchors.left: parent.left
            anchors.top: id_time_button.bottom
            anchors.topMargin: 16
            text: YTranslateText.textbookFavoritesSortByContent
            onClicked: {
                currentIndex = 1
                filterChanged(currentIndex)
                hide()
            }
        }
    }
}


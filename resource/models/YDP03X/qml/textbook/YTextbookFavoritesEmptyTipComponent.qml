import QtQuick 2.12
import com.youdao.pen 1.0

import BaseQml 1.0
import "../i18n"

Column {
    spacing: 10
    anchors.top: parent.top
    anchors.topMargin: 110
    anchors.horizontalCenter: parent.horizontalCenter
    anchors.horizontalCenterOffset: 36

    property bool isWordTab: true

    Row {
        id: id_tip_star
        spacing: 4
        anchors.horizontalCenter: parent.horizontalCenter
        height: Math.max(id_tip.contentHeight, id_start_icon.height)
        YImage {
            id: id_start_icon
            width: 38
            height: 38
            sourceSize: Qt.size(38, 38)
            imageName: "textbook/audio"
            anchors.bottom: parent.bottom
        }
        YTextMedium {
            id: id_tip
            font.family: fontManager.fontFamilyZhCn
            text: YTranslateText.textbookFavoritesEmptyTip
            color: YColors.grayText
            anchors.bottom: parent.bottom
        }
    }

    YTextBase {
        anchors.horizontalCenter: parent.horizontalCenter
        font.family: fontManager.fontFamilyZhCn
        text: YTranslateText.textbookFavoritesEmptyGuideTip
        font.pixelSize: 28
        color: "#909199"
    }
}

import QtQuick 2.12
import com.youdao.pen 1.0

import BaseQml 1.0
import "../i18n"

Column {
    spacing: 10
    anchors.top: parent.top
    anchors.topMargin: 110
    anchors.horizontalCenter: parent.horizontalCenter

    property bool isWordTab: true

    Row {
        id: id_tip_star
        spacing: 4
        anchors.horizontalCenter: parent.horizontalCenter
        height: Math.max(id_tip.contentHeight, id_start_icon.height)
        YTextMedium {
            id: id_tip
            text: YTranslateText.wordbookEmptyTip
            anchors.bottom: parent.bottom
        }
        YImage {
            id: id_start_icon
            width: 38
            height: 38
            sourceSize: Qt.size(38, 38)
            imageName: "wordbook/star"
            anchors.bottom: parent.bottom
        }
    }

    YTextBase {
        anchors.horizontalCenter: parent.horizontalCenter
        text: YTranslateText.wordbookAddTip.arg(
                  (wordBookManager.tabType === YEnum.WGT_Sentence)
                  ? YTranslateText.phraseOrSentence
                  : YTranslateText.word)
        font.pixelSize: 26
        color: "#878A99"
    }
}

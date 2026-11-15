import QtQuick 2.12
import com.youdao.pen 1.0

import BaseQml 1.0
import "../common"
import "../i18n"

// 文本查看器（txt / md 纯文本显示）
YBackButtonPage {
    id: id_text_viewer
    objectName: "YPage===PenModsTextViewer.qml"

    Flickable {
        anchors.fill: parent
        anchors.leftMargin: 54
        anchors.rightMargin: 12
        anchors.topMargin: 12
        anchors.bottomMargin: 12
        contentHeight: id_text_content.height
        clip: true
        pressDelay: 150

        YTextMedium {
            id: id_text_content
            width: id_text_viewer.width - 66
            font.pixelSize: 22
            color: YColors.white
            text: (textReader && textReader.content) ? textReader.content : ""
            wrapMode: YText.Wrap
            textFormat: YText.PlainText
        }
    }
}

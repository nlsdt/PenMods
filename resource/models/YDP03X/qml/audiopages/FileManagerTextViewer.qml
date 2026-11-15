import QtQuick 2.12
import com.youdao.pen 1.0

import BaseQml 1.0
import "../common"
import "../i18n"

// =====================================================================
// 文本查看器（txt / md 预览）—— 绑定 3 代 `textReader`：
//   textReader.content / textReader.title / textReader.isMarkdown
// 纯文本用 PlainText；Markdown 用 MarkdownText 渲染（不支持公式，保持简单）。
// =====================================================================
YBackButtonPage {
    id: id_text_viewer
    objectName: "YPage===FileManagerTextViewer.qml"

    Flickable {
        anchors.fill: parent
        anchors.leftMargin: 54
        anchors.rightMargin: 12
        anchors.topMargin: 12
        anchors.bottomMargin: 12
        contentHeight: id_content.height
        clip: true
        pressDelay: 150

        Column {
            id: id_content
            width: id_text_viewer.width - 66
            spacing: 8

            // 标题
            YTextBase {
                width: parent.width
                color: YColors.grayText
                font.pixelSize: 16
                elide: YTextBase.ElideRight
                text: (textReader && textReader.title) ? textReader.title : ""
                visible: text !== ""
            }

            // 正文
            YTextMedium {
                width: parent.width
                font.pixelSize: 16
                color: YColors.white
                text: (textReader && textReader.content) ? textReader.content : ""
                wrapMode: YText.WrapAnywhere
                textFormat: (textReader && textReader.isMarkdown) ? Text.MarkdownText : Text.PlainText
                lineHeight: 1.2
            }
        }
    }
}

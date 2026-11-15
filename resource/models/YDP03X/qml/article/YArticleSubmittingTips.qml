import QtQuick 2.12

import BaseQml 1.0
import "../i18n"

YBackgroundIgnoreMouseEvent {
    id: id_article_submitting_tips
    objectName: "YArticleSubmittingTips.qml"
    anchors.fill: parent
    color: "#E6000000"
    visible: false

    property alias defaultText: id_waiting_text.text

    YWaitingTipsText {
        id: id_waiting_text
        anchors.centerIn: parent
        text: YTranslateText.articleSubmittingTip
        running: parent.visible
    }
}

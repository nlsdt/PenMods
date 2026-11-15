import QtQuick 2.12
import com.youdao.pen 1.0

import BaseQml 1.0
import "../i18n"

YOneButtonDialog {
    id: id_article_corrections_completed_tip
    objectName: "YArticleCorrectionsCompletedTip.qml"
    anchors.fill: parent
    fastBlurItem.maskItem.color: YColors.black
    tipItem.textFormat: Text.RichText

    property string totalScore: "0"
    property string fullScore: "100"
    property string uniqueKey: ""

    signal showDetail(string uniqKey)

    tipItem.text: {
        const score = Math.round(parseFloat(totalScore)/parseFloat(fullScore))
        if (score > 70) {
            return YTranslateText.articleResultHigh.arg(
                        YColors.green).arg(totalScore).arg(fullScore)
        } else if (score > 50) {
            return YTranslateText.articleResultMiddle.arg(
                        YColors.green).arg(totalScore).arg(fullScore)
        } else {
            return YTranslateText.articleResultLow.arg(
                        YColors.green).arg(totalScore).arg(fullScore)
        }
    }
    buttonItem.text: YTranslateText.articleCorrectionsDetails

    onClicked: {
        id_article_corrections_completed_tip.showDetail(uniqueKey)
        close()
    }
}

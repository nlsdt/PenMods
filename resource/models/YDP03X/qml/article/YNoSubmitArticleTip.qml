import QtQuick 2.12
import com.youdao.pen 1.0

import BaseQml 1.0
import "../i18n"

YTwoButtonDialog {
    id: id_no_submit_article_tip
    anchors.fill: parent

    tipItem.text: YTranslateText.noSubmitArticle
    buttonItemConfirm.text: YTranslateText.noSubmit

    signal noSubmit()

    onClickedConfirm: {
        qmlGlobal.isArticleEditing = false
        close()
        noSubmit()
    }
    onClickedCancel: {
        close()
    }
}

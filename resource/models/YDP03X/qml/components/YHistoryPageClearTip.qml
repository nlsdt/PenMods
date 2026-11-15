import QtQuick 2.12
import com.youdao.pen 1.0

import BaseQml 1.0
import "../i18n"

YOneButtonDialog {
    id: id_real_time_display
    anchors.fill: parent

    tipItem.text: YTranslateText.clearHistoryTip
    buttonItem.text: YTranslateText.clearHistory

    onClicked: {
        historyManager.removeAll()
        logManager.sendHttpLog("action=history_delete_click_confirm")
        close()
    }
}

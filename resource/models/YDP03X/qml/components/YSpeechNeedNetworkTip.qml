import QtQuick 2.12
import com.youdao.pen 1.0

import BaseQml 1.0
import "../i18n"

YOneButtonDialog {
    anchors.fill: parent
    tipItem.text: YTranslateText.speechNeedNetWork
    buttonItem.text: YTranslateText.configWifi
    onClicked: {
        qmlGlobal.requestSettingPage(YEnum.SettingIndex.Network)
        closed()
    }
}

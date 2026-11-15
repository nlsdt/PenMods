import QtQuick 2.12
import com.youdao.pen 1.0

import BaseQml 1.0
import "./i18n"

YPage {
    id: id_power_off_page
    objectName: "YPage===YPowerOffPage.qml"

    YText {
        id: id_power_off_tip
        anchors.centerIn: parent
        font.pixelSize: 30
        text: YTranslateText.powerOffing
    }

    Component.onDestruction: {
        console.log("YPowerOffPage.qml===Component.onDestruction===called")
    }

    onVisibleChanged: {
        if (visible) {
            qmlGlobal.currentPageIndex = YEnum.PageIndex.PowerOff
        }
    }
}

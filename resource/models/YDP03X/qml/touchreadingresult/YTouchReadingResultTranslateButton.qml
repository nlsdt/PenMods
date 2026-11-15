import QtQuick 2.12
import com.youdao.pen 1.0

import BaseQml 1.0

YIconButton {
    id: id_translate_button
    implicitWidth: 70
    implicitHeight: 70
    mouseAreaMargins: -8
    radius: height/2
    color: "#333575"
    sourceSize: Qt.size(42, 42)
    imageName: (YEnum.RBTT_EN_US === settingManager.readingBookTranslateType) ? "touchreading/translate_zh" : "touchreading/translate"
    anchors.bottom: parent.bottom
    onValidClicked: {
        logManager.sendHttpLog("action=touchreading_txt_trans_click")

        settingManager.readingBookTranslateType
                = (settingManager.readingBookTranslateType + 1) % YEnum.RBTT_COUNT
    }
}

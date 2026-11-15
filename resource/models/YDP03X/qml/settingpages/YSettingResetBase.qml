import QtQuick 2.12

import BaseQml 1.0
import "../i18n"

YOneButtonDialog {
    id: id_one_button_dialog
    anchors.fill: parent
    tipItem.text: YTranslateText.resetSystemSettings
    buttonItem.text: YTranslateText.resetSettings
    onClicked: {
        close()
    }
}

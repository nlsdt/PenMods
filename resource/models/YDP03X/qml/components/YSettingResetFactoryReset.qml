import QtQuick 2.12

import BaseQml 1.0
import "../settingpages"
import "../i18n"

YSettingResetBase {
    tipItem.text: YTranslateText.resetFactoryTip
    buttonItem.text: YTranslateText.resetFactory

    onClicked: {
        console.log("YSettingResetSettingsReset.qml===factoryClear")
        settingManager.factoryClear()
    }
}

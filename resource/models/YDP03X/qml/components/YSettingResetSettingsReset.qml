import QtQuick 2.12
import BaseQml 1.0
import "../settingpages"
import "../i18n"

YSettingResetBase {
    onClicked: {
        console.log("YSettingResetSettingsReset.qml===factoryReset")
        settingManager.factoryReset()
    }
}

import QtQuick 2.12

import BaseQml 1.0
import "../i18n"

YOneButtonDialog {
    id: id_battery_power_low_dialog
    anchors.fill: parent

    property int battaryPower: 0

    tipItem.text: YTranslateText.batteryPowerLow.arg(battaryPower)
    buttonItem.text: YTranslateText.ok
    onClicked: {
        close()
    }
}

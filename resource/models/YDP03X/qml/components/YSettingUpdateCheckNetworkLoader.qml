import QtQuick 2.12
import com.youdao.pen 1.0

import BaseQml 1.0
import "../i18n"

YLoader {
    id: id_setting_update_check_network_loader
    anchors.fill: parent
    active: /*!isOSVersion &&*/ !wifiManager.internetConnect
            || (YEnum.UPDATE_ERROR_NO_CONNECTION === otaStatus)
    signal checkNetwork()

    sourceComponent: YOneButtonDialog {
        tipItem.text: YTranslateText.updateNetworkErrorTip
        buttonItem.text: YTranslateText.updateNetworkError
        onClosed: {
            backButtonClicked()
        }
        onClicked: {
            checkNetwork()
            close()
        }
    }
    onLoaded: {
        item.show()
    }
}

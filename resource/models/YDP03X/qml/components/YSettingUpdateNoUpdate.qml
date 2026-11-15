import QtQuick 2.12
import com.youdao.pen 1.0

import BaseQml 1.0
import "../i18n"

YLoader {
    id: id_no_new_version_current_loader
    anchors.horizontalCenter: parent.horizontalCenter
    active: (wifiManager.internetConnect && isABSameVersion
             && ((YEnum.UPDATE_LATEST_VERSION === otaStatus
                  || ((YEnum.UPDATE_ERROR_LOW_BATTERY === otaStatus)
                      && !id_setting_update_low_power_loader.active)
                  || ((YEnum.UPDATE_DOWNLOAD_PAUSE === otaStatus)
                      && !id_setting_update_download_loader.active))))
            || ((YEnum.UPDATE_ERROR_NO_CONNECTION === otaStatus)
                && !id_setting_update_check_network_loader.active)

    sourceComponent: YTextMedium {
        text: currentVersion
        YText {
            anchors.top: parent.bottom
            anchors.topMargin: 16
            anchors.horizontalCenter: parent.horizontalCenter
            color: YColors.grayText
            text: YTranslateText.updateNoNeedUpdate
        }
    }
}

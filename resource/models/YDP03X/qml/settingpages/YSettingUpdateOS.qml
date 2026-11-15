import QtQuick 2.12
import com.youdao.pen 1.0

import BaseQml 1.0
import "../components"
import "../i18n"
import "../update"

YLoader {
    id: id_setting_update_os_page
    anchors.fill: parent
    asynchronous: false

    property bool isUpdateSuspending: false

    property var updateSubPageIndexCur: isUpdateSuspending ? 2 : 0
    property var updateSubPageHistory: []

    function subPageCallBack() {
        if (updateSubPageHistory.length > 0) {
            let popPageIndex = updateSubPageHistory.pop()
            updateSubPageIndexCur = popPageIndex
        } else {
            closeSettingUpdatePage()
        }
    }

    function showSubPage (subPageIndex, bAddHistory) {
        if (updateSubPageIndexCur !== subPageIndex) {
            if (typeof bAddHistory != "undefined" && bAddHistory) {
                let iPosHave = updateSubPageHistory.indexOf(updateSubPageIndexCur)
                if (iPosHave >= 0) {
                    updateSubPageHistory.splice(iPosHave, 1)
                }
                iPosHave = updateSubPageHistory.indexOf(subPageIndex)
                if (iPosHave >= 0) {
                    updateSubPageHistory.splice(iPosHave, 1)
                }
                updateSubPageHistory.push(updateSubPageIndexCur)
            } else {
                updateSubPageHistory = []
            }
            updateSubPageIndexCur = subPageIndex
        }
    }


    sourceComponent: {
        switch (updateSubPageIndexCur) {
        case 0:
            return id_update_os_note_component
        case 1:
            return id_update_os_content_component
        case 2:
            return id_update_os_prepare_component
        case 3:
            return id_update_os_storage_component
        case 4:
            return id_update_os_longin_component
        default:
            return null
        }
    }

    Component {
        id: id_update_os_note_component
        YSettingUpdateNote {
            onNextStep: {
                id_setting_update_os_page.showSubPage(1, true)
            }
        }
    }

    Component {
        id: id_update_os_content_component
        YSettingUpdateNotice {
            onNextStep: {
                settingManager.updateSystemInfo()
                id_setting_update_os_page.showSubPage(2, true)
            }
        }
    }

    Component {
        id: id_update_os_prepare_component
        YSettingUpdatePrepare {
            isSuspending: id_setting_update_os_page.isUpdateSuspending
            onCleanStorage: {
                settingManager.updateSystemInfo()
                id_setting_update_os_page.showSubPage(3, true)
            }

            onScanToLogin: {
                id_setting_update_os_page.showSubPage(4, true)
            }
        }
    }

    Component {
        id: id_update_os_storage_component
        YSettingUpdateStorage {
            //
        }
    }

    Component {
        id: id_update_os_longin_component
        YSettingUpdateLogin {}
    }
}

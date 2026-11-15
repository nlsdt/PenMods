import QtQuick 2.12
import com.youdao.pen 1.0

import BaseQml 1.0
import "./components"
import "./i18n"

YPage {
    id: id_word_book_page
    objectName: "YPage===YWordBookPage.qml"

    YWordBookPageSwitchLoader {
        id: id_switch_loader
        currentPageEnabled: !id_card_view_loader.active
        active: true
        asynchronous: false
        onCallCardView: {
            id_card_view_loader.active = true
            if (settingManager.modelChangeCount < 3) {
                baseSignals.showToast(YTranslateText.switchWordCard, "#2D2E33")
                settingManager.setModelChangeCount(settingManager.modelChangeCount + 1);
            }
            logManager.sendHttpLog("action=wordbook_card_view_click")
        }
    }

    YWordBookPageCardViewLoader {
        id: id_card_view_loader
    }

    onBackButtonClicked: {
        id_card_view_loader.active = false
        soundCenter.stop()
        wordBookManager.wipeData()
    }

    onVisibleChanged: {
        if (visible) {
            qmlGlobal.currentPageIndex = YEnum.PageIndex.Fav
        }
    }

    Connections {
        target: qmlGlobal
        ignoreUnknownSignals: true
        function onRequestShowScanGuide() {
            if (YEnum.PageIndex.Fav === qmlGlobal.currentPageIndex) {
                id_word_book_page.visible = false
            }
        }
        function onRequestHideScanGuide() {
            if (YEnum.PageIndex.Fav === qmlGlobal.currentPageIndex) {
                id_word_book_page.visible = true
                qmlGlobal.backToWordCardView()
            }
        }
    }
}

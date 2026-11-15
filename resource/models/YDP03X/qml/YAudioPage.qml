import QtQuick 2.12
import com.youdao.pen 1.0
import BaseQml 1.0

import "./components"
import "./audiopages"
import "./i18n"

YBackButtonAudioPage {
    id: id_auido_page
    objectName: "YPage===YAudioPage.qml"

    function stateNormal(quicklyEnter) {
    }

    Item {
        id: id_container
        anchors.fill: parent
        anchors.leftMargin: 90
        anchors.topMargin: 16
        anchors.bottomMargin: 16
        anchors.rightMargin: 20

        YYDListeningButton {
            id: id_yd_listening_button
            name: YTranslateText.ydListening
            count: columnManager.listeningCount + YTranslateText.pieces

            function enterPage() {
                qmlGlobal.reinitYDListening()
                id_pop_layer.show("audiopages/YYoudaoAudioPage")
            }

            onValidClicked: {
                enterPage()
            }
        }

        YScanReadingButton {
            id: id_scan_reading_button
            name: YTranslateText.myProductionAudios
            count: columnManager.productionCount + YTranslateText.pieces
            onValidClicked: {
                logManager.sendHttpLog("action=listening_make_click")
                columnManager.loadMore(true, columnManager.domainNameMyProduction)
                id_pop_layer.show("audiopages/YMyProductionPage")
            }
        }

        YMyImportButton {
            id: id_my_imports_button
            name: YTranslateText.myImportAudios
            // 防尴尬模式下文件列表为空，计数同步显示 0，避免与实际列表相反
            count: (typeof antiEmbs !== 'undefined' && antiEmbs.active
                        ? 0
                        : columnManager.importCount) + YTranslateText.pieces
            onValidClicked: {
                mediaManager.launchMyImportMedias()
                id_delay_timer.start()
            }
        }
        YTimer {
            id: id_delay_timer
            interval: 250
            objectName: "YAudioPage.qml_id_delay_timer"
            onTriggered: {
                mediaManager.entryMyImport()
                id_pop_layer.show("audiopages/YMyImportPage")
            }
        }
    }

    YDownloadManagerButton {
        id: id_download_manager_button
        function enterPage() {
            qmlGlobal.reinitAudiosDownloadManager()
            id_pop_layer.show("audiopages/YDownloadAudiosManager")
        }
        onValidClicked: {
            enterPage()
        }
    }

    YPopLayer {
        id: id_pop_layer
    }

    Component.onCompleted: {
        mediaManager.launchMyImportMedias()
    }

    Component.onDestruction: {
        console.log("YAudioPage.qml===Component.onDestruction===called")
    }

    onVisibleChanged: {
        if (visible) {
            qmlGlobal.currentPageIndex = YEnum.PageIndex.Audioplayer
        }
    }

    Connections {
        target: qmlGlobal
        function onQuicklyEnterYDListening() {
            id_yd_listening_button.enterPage()
        }
        function onQuicklyEnterAudiosDownloadManager() {
            id_download_manager_button.enterPage()
        }
        function onReinitYDListening() {
            columnManager.wipeData()
            columnManager.loadMore(false, columnManager.domainNameYdListen)
        }
        function onReinitAudiosDownloadManager() {
            columnManager.wipeData()
            let domains = [columnManager.domainNameYdListen]
            domains.push(columnManager.domainNameMyProduction)
            columnManager.loadMore(true, domains.join(","))
        }
    }
}

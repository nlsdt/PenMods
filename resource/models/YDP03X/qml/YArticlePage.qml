import QtQuick 2.12
import com.youdao.pen 1.0
import BaseQml 1.0

import "./commons"
import "./components"
import "./i18n"
import "./settingpages"
import "./article"
import "./timers"

YBackButtonPage {
    id: id_article_page
    objectName: "YPage===YArticlePage.qml"
    closabledPageWhileHomeKeyReleased: !qmlGlobal.isArticleEditing
    defaultTitleBar.backButtonItem.iconButtonBackgroundItem.asynchronous: false

    YArticleIndexWidget {
        id: id_index_widget
        visible: !articleManager.isChecking
        onRequestHistory: {
            requestShowHistory()
        }
    }

    YArticleLevelFilterButton {
        id: id_filter_button
    }

    YArticleEditWidget {
        id: id_edit_widget
        onRequestEnteredTooLongTip: {
            baseSignals.showToast(YTranslateText.articleRequestEnteredTooLongTip, "#E52D2E33")
        }
    }

    // no wifi tip
    Component {
        id: id_config_wifi_component

        YSettingWifi {
            id: id_setting_wifi_view

            YTimer {
                id: id_check_wifi_state_timer
                interval: 200
                repeat: true
                onTriggered: {
                    if (wifiManager.internetConnect) {
                        id_check_wifi_state_timer.stop()
                        YTimers.delayCall(500, id_setting_wifi_view.close)
                    }
                }
            }

            Component.onCompleted: {
                id_check_wifi_state_timer.start()
            }
        }
    }

    Component.onCompleted: {
        if (settingManager.isFirstEnterArticlePage) {
            function newComponentInit(incubatorObject) {
                incubatorObject.backButtonClicked.connect(incubatorObject.destroy)
                incubatorObject.backButtonClicked.connect(id_article_page.backButtonClicked)
                incubatorObject.closed.connect(incubatorObject.destroy)
                id_edit_widget.newScanArticleAppend.connect(incubatorObject.destroy)
                systemBase.homeKeyPress.connect(incubatorObject.destroy)
                incubatorObject.show()
            }

            const newComponent = Qt.createComponent("./article/YArticleFirstEnterTip.qml")
            if (newComponent.status === Component.Ready) {
                let createdObject = newComponent.createObject(id_article_page)
                newComponentInit(createdObject)
            }
        }

        delayRequestWifi()
    }

    Component.onDestruction: {
        console.log("YArticlePage.qml===Component.onDestruction===called")
        articleManager.wipeData()
        if (qmlGlobal.isArticleEditing) {
            qmlGlobal.isArticleEditing = false
        }
    }

    function requestArticlNeedNetWorkTip() {
        function newComponentInit(incubatorObject) {
            incubatorObject.configWifi.connect(requestArticlNeedNetWorkSetting)
            incubatorObject.configWifi.connect(function() {
                incubatorObject.destroy(1000)
            })
            id_article_page.backButtonClicked.connect(incubatorObject.destroy)
            incubatorObject.show()
        }

        const newComponent = Qt.createComponent(
                               "./article/YArticlNeedNetworkTip.qml")
        if (newComponent.status === Component.Ready) {
            let createdObject = newComponent.createObject(id_article_page)
            newComponentInit(createdObject)
        }
    }

    function requestArticlNeedNetWorkSetting() {
        if (!wifiManager.internetConnect) {
            function newComponentInit(incubatorObject) {
                function close() {
                    incubatorObject.destroy()
                    delayRequestWifi()
                }
                id_article_page.backButtonClicked.connect(close)
                incubatorObject.backButtonClicked.connect(close)
                systemBase.homeKeyPress.connect(close)
                incubatorObject.show()
            }

            const incubator = id_config_wifi_component.incubateObject(
                                id_article_page)
            if (incubator.status !== Component.Ready) {
                incubator.onStatusChanged = function(status) {
                    if (status === Component.Ready) {
                        if (0 === --id_filter_button.incubatorCreateCount) {
                            // 异步重入只显示最后一个创建的对象
                            newComponentInit(incubator.object)
                        } else {
                            incubator.object.destroy()
                        }
                    }
                }
                ++id_filter_button.incubatorCreateCount
            } else {
                newComponentInit(incubator.object)
            }
        }
    }

    function delayRequestWifi() {
        if (!wifiManager.internetConnect) {
            requestArticlNeedNetWorkTip()
        }
    }

    function requestShowHistory() {
        function newComponentInit(incubatorObject) {
            id_article_page.backButtonClicked.connect(incubatorObject.destroy)
            incubatorObject.backButtonClicked.connect(incubatorObject.destroy)
            incubatorObject.showDetail.connect(requestShowDetail)
            id_edit_widget.newScanArticleAppend.connect(incubatorObject.destroy)
            systemBase.homeKeyPress.connect(incubatorObject.destroy)
            systemBase.ocrStart.connect(incubatorObject.destroy)
            systemBase.isOidStart.connect(incubatorObject.destroy)
            incubatorObject.show()
        }

        const newComponent = Qt.createComponent("./article/YArticleHistoryView.qml")
        const incubator = newComponent.incubateObject(id_article_page)
        if (incubator.status !== Component.Ready) {
            incubator.onStatusChanged = function(status) {
                if (status === Component.Ready) {
                    if (0 === --id_filter_button.incubatorCreateHistoryCount) {
                        // 异步重入只显示最后一个创建的对象
                        newComponentInit(incubator.object)
                    } else {
                        incubator.object.destroy()
                    }
                }
            }
            ++id_filter_button.incubatorCreateHistoryCount
        } else {
            newComponentInit(incubator.object)
        }
    }

    function requestShowDetail(uniqueKey) {
        function newComponentInit(incubatorObject) {
            id_article_page.backButtonClicked.connect(incubatorObject.destroy)
            incubatorObject.backButtonClicked.connect(incubatorObject.destroy)
            id_edit_widget.newScanArticleAppend.connect(incubatorObject.destroy)
            systemBase.homeKeyPress.connect(incubatorObject.destroy)
            systemBase.ocrStart.connect(incubatorObject.destroy)
            systemBase.isOidStart.connect(incubatorObject.destroy)
            incubatorObject.show(uniqueKey)
        }

        const newComponent = Qt.createComponent("./article/YArticleCorrectionsCompletedDetailView.qml")
        const incubator = newComponent.incubateObject(id_article_page)
        if (incubator.status !== Component.Ready) {
            incubator.onStatusChanged = function(status) {
                if (status === Component.Ready) {
                    if (0 === --id_filter_button.incubatorCreateCorrectionsCompletedCount) {
                        // 异步重入只显示最后一个创建的对象
                        newComponentInit(incubator.object)
                    } else {
                        incubator.object.destroy()
                    }
                }
            }
            ++id_filter_button.incubatorCreateCorrectionsCompletedCount
        } else {
            newComponentInit(incubator.object)
        }
    }

    onVisibleChanged: {
        if (visible) {
            articleManager.loadData();
            qmlGlobal.currentPageIndex = YEnum.PageIndex.Article
        }
    }

    Connections {
        target: wifiManager
        enabled: visible
        ignoreUnknownSignals: true
        function onInternetConnectChanged() {
            delayRequestWifi()
        }
    }

    Connections {
        target: articleManager
        enabled: visible
        ignoreUnknownSignals: true
        function onSubmitFinished(totalScore, fullScore, uniqueKey) {
            id_edit_widget.closeSubmitingTipsMask()
            requestShowDetail(uniqueKey)

//            function newComponentInit(incubatorObject) {
//                id_article_page.backButtonClicked.connect(incubatorObject.destroy)
//                incubatorObject.closed.connect(incubatorObject.destroy)
//                incubatorObject.showDetail.connect(requestShowDetail)
//                incubatorObject.showDetail.connect(incubatorObject.destroy)
//                id_edit_widget.newScanArticleAppend.connect(incubatorObject.destroy)
//                systemBase.homeKeyPress.connect(incubatorObject.destroy)
//                systemBase.ocrStart.connect(incubatorObject.destroy)
//                systemBase.isOidStart.connect(incubatorObject.destroy)
//                incubatorObject.totalScore = totalScore
//                incubatorObject.fullScore = fullScore
//                incubatorObject.uniqueKey = uniqueKey
//                incubatorObject.show()
//            }

//            const newComponent = Qt.createComponent("./article/YArticleCorrectionsCompletedTip.qml")
//            const incubator = newComponent.incubateObject(id_article_page)
//            if (incubator.status !== Component.Ready) {
//                incubator.onStatusChanged = function(status) {
//                    if (status === Component.Ready) {
//                        if (0 === --id_filter_button.incubatorCreateFinishedCount) {
//                            // 异步重入只显示最后一个创建的对象
//                            newComponentInit(incubator.object)
//                        } else {
//                            incubator.object.destroy()
//                        }
//                    }
//                }
//                ++id_filter_button.incubatorCreateFinishedCount
//            } else {
//                newComponentInit(incubator.object)
//            }
        }

        function onSubmitFailed(submitType, errorMsg) {
            if (1 === submitType) {
                id_edit_widget.closeSubmitingTipsMask()
            }
            if (0 === errorMsg.length) {
                switch (submitType) {
                case 1:
                    baseSignals.showToast(YTranslateText.articleFaildPleaseTryAgain , "#2D2E33")
                    break
                case 2:
                    baseSignals.showToast(YTranslateText.articleOcrFaildPleaseTryAgain, "#2D2E33")
                    break
                default:
                    break
                }
            } else {
                baseSignals.showToast(errorMsg, "#2D2E33")
            }
        }

    }
}

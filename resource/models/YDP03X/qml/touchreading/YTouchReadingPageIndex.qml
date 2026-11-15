import QtQuick 2.12
import com.youdao.pen 1.0

import BaseQml 1.0
import "../components"
import "../i18n"
import "./components"

Rectangle {
    id: id_touch_reading_page_index
    implicitWidth: YBaseEnum.Screen.Width
    implicitHeight: YBaseEnum.Screen.Height
    color: YColors.touchReadingBg

    property int currentTabIndex: YEnum.StoreSeries

    function checkLoadMore() {
        let isDownload = false
        switch (currentTabIndex) {
        case YEnum.ShelfSeries:
            isDownload = true
            break
        case YEnum.MyShelf:
            isDownload = true
            break
        case YEnum.StoreSeries:
        default:
            isDownload = false
            break
        }
        readingSeriesManager.loadMore(isDownload)
    }

    YHorizontalListView {
        id: id_main_touch_reading_list_view
        anchors.fill: parent
        anchors.topMargin: 14
        anchors.bottomMargin:  14
        anchors.leftMargin: 90
        clip: false
        onMovingChanged: {
            if (!moving && atXEnd && readingSeriesManager.hasMore) {
                checkLoadMore()
            }
        }
        model: readingSeriesManager

        delegate: {
            switch (currentTabIndex) {
            case YEnum.ShelfSeries:
                return null
            case YEnum.MyShelf:
                return id_my_shelf_delegate
            case YEnum.StoreSeries:
            default:
                return id_store_series_delegate
            }
        }

        YLoader {
            id: id_shelf_series_list_view_loader
            anchors.fill: parent
            active: YEnum.ShelfSeries === currentTabIndex
            sourceComponent: YBaseListView {
                anchors.fill: parent
                anchors.leftMargin: 38
                anchors.topMargin: 4
                anchors.bottomMargin: 6
                orientation: Qt.Horizontal
                clip: false
                spacing: 30
                model: 3
                delegate: id_shelf_series_delegate
            }
        }

        YTextMedium {
            id: id_empty_tips
            visible: (YEnum.ShelfSeries !== currentTabIndex)
                     && !id_main_touch_reading_list_view.busying
                     && id_main_touch_reading_list_view.empty
            anchors.centerIn: parent
            textFormat: YTextMedium.RichText//(YEnum.StoreSeries === currentTabIndex) ? YTextMedium.RichText : YTextMedium.PlainText
            font.family: fontManager.fontFamilyZhCn
            text: {
                switch (currentTabIndex) {
                    case YEnum.StoreSeries:
                        if (!wifiManager.internetConnect) {
                            return YTranslateText.touchReadingBookStoreNoInternet.arg(YColors.blueText)
                        }
                        return YTranslateText.connetServerError
                    default:
                        return YTranslateText.noTouchReadingBooks
                }
            }
            horizontalAlignment: YTextMedium.AlignHCenter
            YButtonBaseMouseArea {
                anchors.fill: parent
                anchors.margins: -20
                enabled: YEnum.StoreSeries === currentTabIndex
                onValidClicked: {
                    qmlGlobal.requestSettingPage(YEnum.SettingIndex.Network)
                }
            }
        }
    }

    YTouchReadingPageIndexTabView {
        id: id_tab_bar
        enabled: !id_opening_item.isBusyCreating
    }


    onCurrentTabIndexChanged: {
        readingSeriesManager.wipeData()
        checkLoadMore()
    }

    YTouchReadingPageOpeningItem {
        id: id_opening_item
        property var currentOpeningItem: null
        property real posX: 0
        currentTabIndex: id_touch_reading_page_index.currentTabIndex
        onBackButtonClicked: {
            if ((null !== currentOpeningItem) && currentOpeningItem.layerShowing) {
                currentOpeningItem.shrink()
            } else {
                id_opening_item.hide()
                if (null !== currentOpeningItem) {
                    currentOpeningItem.destroy()
                    currentOpeningItem = null
                }
            }
        }

        onCreatIncubateOpeningItemObjectFinished: {
            currentOpeningItem = incubatorObject
            if (YEnum.ShelfSeries === currentTabIndex) {
                currentOpeningItem.callBack.connect(function(){
                    backButtonClicked()
                    readingSeriesManager.reload(true)
                })
            } else if (YEnum.StoreSeries === currentTabIndex) {
                currentOpeningItem.progress = Qt.binding(function() {
                    return id_main_touch_reading_list_view.currentItem.downloadProgress
                })
                currentOpeningItem.downloadState = Qt.binding(function() {
                    return id_main_touch_reading_list_view.currentItem.downloadState
                })
            } else if (YEnum.MyShelf === currentTabIndex) {
                if (currentOpeningItem.hasOwnProperty("callBack")) {
                    currentOpeningItem.callBack.connect(function(){
                        qmlGlobal.stopAllAnimationMusic()
                        backButtonClicked()
                        readingSeriesManager.reload(true)
                    })
                }
            }
            currentOpeningItem.initData(paramsObj)
            id_opening_item.show(posX)
            id_opening_item.setIdle()
        }
    }

    Component {
        id: id_store_series_delegate
        YTouchReadingViewDelegateStoreSeries {
            onClicked: {
                if (id_opening_item.isBusyCreating) {
                    return
                }
                id_opening_item.isBusyCreating = true
                id_main_touch_reading_list_view.currentIndex = index
                id_opening_item.posX = delegateItem.mapToItem(id_touch_reading_page_index, 0, 0).x
                const component = qmlCreateComponent("touchreading/YTouchReadingOpeningContentStoreSeries")
                id_opening_item.creatIncubateOpeningItemObject(
                            component, model.modelData)
            }
        }
    }

    Component {
        id: id_my_shelf_delegate
        YTouchReadingViewDelegateShelfSeries {
            onClicked: {
                if (id_opening_item.isBusyCreating) {
                    return
                }
                id_opening_item.isBusyCreating = true
                id_main_touch_reading_list_view.currentIndex = index
                id_opening_item.posX = delegateItem.mapToItem(id_touch_reading_page_index, 0, 0).x
                let component = null
                if (isEidt) {
                    component = qmlCreateComponent("touchreading/YTouchReadingOpeningContentShelfSeriesEdit")
                } else {
                    component = qmlCreateComponent("touchreading/YTouchReadingOpeningContentShelfSeriesView")
                    logManager.sendHttpLog("action=touchreading_shelf_seriesdetail_click&name=%1".arg(model.modelData.title))
                }
                id_opening_item.creatIncubateOpeningItemObject(
                            component, model.modelData)
            }
        }
    }

    Component {
        id: id_shelf_series_delegate
        YTouchReadingViewDelegateAchievement {
            onClicked: {
                if (id_opening_item.isBusyCreating) {
                    return
                }
                if (1 === readingIndex || 2 === readingIndex) {
                    id_opening_item.isBusyCreating = true
                }
                id_main_touch_reading_list_view.currentIndex = index
                id_opening_item.posX = delegateItem.mapToItem(id_touch_reading_page_index, 0, 0).x
                let component = null
                let paramsObj = null
                switch (readingIndex) {
                case 0:
                    currentTabIndex = YEnum.MyShelf
                    return
                case 1:
                    logManager.sendHttpLog("action=touchreading_achieve_medalset_click")
                    component = qmlCreateComponent("touchreading/YTouchReadingOpeningContentMedalSetView")
                    break
                case 2:
                    logManager.sendHttpLog("action=touchreading_achieve_wall_click")
                    component = qmlCreateComponent("touchreading/YTouchReadingOpeningContentResultWallView")
                    break
                default:
                    break
                }
                id_opening_item.creatIncubateOpeningItemObject(
                            component, model.modelData)
            }
        }
    }

}

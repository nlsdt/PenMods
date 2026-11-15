import QtQuick 2.12

import BaseQml 1.0
import "../components"

Item {
    id: id_opening_content_shelf_series_view

    anchors.fill: parent

    property string onlyId: ""
    property int interval: 180

    readonly property alias layerShowing: id_opening_item.isShowing

    function shrink() {
        if (id_opening_item.isShowing) {
            id_opening_item.hide()
        }
    }

    function initData(paramsObj) {
        onlyId      = paramsObj.id
        readingBookManager.entrySeries(onlyId)
    }

    YHorizontalListView {
        id: id_main_touch_reading_list_view
        anchors.fill: parent
        anchors.topMargin: 18
        anchors.bottomMargin: 18
        anchors.leftMargin: 63 // back_bg.png width
        delegate: id_delegate_component
        clip: false
        model: readingBookManager

        onMovingChanged: {
            if (!moving && atXEnd && readingBookManager.hasMore) {
                readingBookManager.loadMore()
            }
        } // todo 细化 loadMore 逻辑
    }

    YTouchReadingOpeningContentShelfSeriesDetail {
        id: id_opening_item

        onBackButtonClicked: {
            shrink()
        }
    }

    Component {
        id: id_delegate_component
        YTouchReadingOpeningContentShelfSeriesViewItem {
            onClicked: {
                const curItem = delegateItem.mapToItem(id_opening_content_shelf_series_view, 0, 0)
                id_opening_item.initData(model.modelData)
                id_opening_item.show(curItem.x)
                logManager.sendHttpLog("action=touchreading_shelf_seriesdetail_book_click&name=%1".arg(model.modelData.title))
            }
        }
    }

    Component.onDestruction: {
        readingBookManager.wipeData()
        console.log("YTouchReadingOpeningContentShelfSeriesView.qml===Component.onDestruction")
    }
}

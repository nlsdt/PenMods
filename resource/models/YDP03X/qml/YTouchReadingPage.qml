import QtQuick 2.12
import com.youdao.pen 1.0

import BaseQml 1.0
import "./touchreading"

// 图书点读页面
YPage {
    id: id_touch_reading_page
    objectName: "YPage===YTouchReadingPage.qml"

    property alias currentTabIndex: id_touch_reading_page_index.currentTabIndex

    YTouchReadingPageIndex {
        id: id_touch_reading_page_index
        anchors.fill: parent
    }

    Component.onCompleted: {
        id_touch_reading_page_index.checkLoadMore()
    }

    Component.onDestruction: {
        readingSeriesManager.wipeData()
        console.log("YTouchReadingPage.qml===Component.onDestruction===called")
    }

    onVisibleChanged: {
        if (visible) {
            qmlGlobal.currentPageIndex = YEnum.PageIndex.BookStore
        }
    }
}

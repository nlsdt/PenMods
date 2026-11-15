import QtQuick 2.12
import com.youdao.pen 1.0
import QtGraphicalEffects 1.14

import BaseQml 1.0

YImage {
    id: id_tab_bar
    sourceSize: Qt.size(76, YBaseEnum.Screen.Height)
    imageName: "touchreading/tab_bg"

    Item {
        implicitWidth: 46
        implicitHeight: 46
        anchors.top: parent.top
        anchors.topMargin: 28
        anchors.horizontalCenter: parent.horizontalCenter
        YImage {
            sourceSize: Qt.size(38, 38)
            anchors.centerIn: parent
            imageName: "touchreading/back"
        }
    }

    YTouchReadingPageIndexTabButton {
        id: id_tab_store_series
        anchors.verticalCenter: parent.verticalCenter
        imageName: YEnum.StoreSeries === currentTabIndex ?
                       "touchreading/library_checked" : "touchreading/library"
        visible: (YEnum.StoreSeries === currentTabIndex)
                 || (YEnum.ShelfSeries === currentTabIndex)
                 || (YEnum.MyShelf === currentTabIndex)
    }

    YTouchReadingPageIndexTabButton {
        id: id_tab_shelf_series
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 28
        imageName: (YEnum.ShelfSeries === currentTabIndex)
                   || (YEnum.MyShelf === currentTabIndex) ?
                       "touchreading/bookshelf_checked" : "touchreading/bookshelf"
        visible: (YEnum.StoreSeries === currentTabIndex)
                 || (YEnum.ShelfSeries === currentTabIndex)
                 || (YEnum.MyShelf === currentTabIndex)
    }

    YMouseArea {
        anchors.fill: parent
        onClicked: {
            if (mouseY < YBaseEnum.Screen.Height/3) {
                if (YEnum.MyShelf === currentTabIndex) {
                    currentTabIndex = YEnum.ShelfSeries
                } else {
                    id_touch_reading_page.backButtonClicked()
                }
            } else if ((mouseY < YBaseEnum.Screen.Height*2/3) && id_tab_store_series.visible) {
                currentTabIndex = YEnum.StoreSeries
            } else if ((mouseY < YBaseEnum.Screen.Height) && id_tab_shelf_series.visible) {
                if (YEnum.MyShelf !== currentTabIndex) {
                    logManager.sendHttpLog("action=touchreading_achieve_medalset_click")
                    currentTabIndex = YEnum.ShelfSeries
                }
            }
        }
        objectName: "YTouchReadingPageIndexTabView.qml_YMouseArea"
    }
}

import QtQuick 2.12
import QtGraphicalEffects 1.14
import BaseQml 1.0

import com.youdao.pen 1.0
import XmPresenter 1.0
import "i18n"

YPage {
    id: id_home_page

    function enterBlockView(type, jumpValue, title) {
        const TYPE_NAMES = ["", "album", "subject", "activity"]
        xmLogManager.clickEvent(XmTrace.ClickHomeCard,
                                JSON.stringify({"itemType": TYPE_NAMES[type], "itemVal": title}))
        var qmlName = ""
        switch (type) {
        case 1:
            qmlName = "3rdpart/xmly/YXmlyAlbumDetail"
            break
        case 2:
            qmlName = "3rdpart/xmly/YXmlySubject"
            break
        case 3:
            qmlName = "3rdpart/xmly/YXmlyQRcodePay"
            showPage(qmlName, false, {
                         "sourceId": 4,
                         "title": jumpValue
                     })
            return
        }
        showPage(qmlName, false, {
                     "sourceId": jumpValue,
                     "title": title
                 })
    }

    XmHomePresenter {
        id: xmHomePresenter
    }

    Item {
        id: id_book_view_container
        anchors.fill: parent
        anchors.leftMargin: 90
        anchors.rightMargin: 16

        YHorizontalListView {
            id: id_book_view
            anchors.fill: parent
            anchors.topMargin: 16
            anchors.bottomMargin: 16
            spacing: 12
            // clip: false  //配合标题栏透明效果
            model: ListModel {
                id: bookList
            }

            delegate: YXmlyAlbumViewDelegate {
                YImage {
                    anchors.left: parent.left
                    sourceSize: Qt.size(89, 36)
                    imageName: (resType === 1) ? "3rdpart/xmly/tab_album_vip" : (resType === 2 ? "3rdpart/xmly/tab_album_quality" : "")
                }
                YMouseArea {
                    anchors.fill: parent
                    onClicked: {
                        enterBlockView(jumpType, jumpValue, title)
                    }
                }
            }
            onMovingChanged: {
                if (!moving && atXEnd && xmHomePresenter.canLoadNextPage()) {
                    xmHomePresenter.loadNextPage()
                }
            }

            footer: (bookList.count > 0 && xmHomePresenter.canLoadNextPage(
                         )) ? id_listview_loading_footer : null

            Component {
                id: id_listview_loading_footer
                YListViewLoadMoreFooter {}
            }
        }
    }

    YXmlyLoadingView {
        id: id_loading_tip
        anchors.fill: parent
        visible: bookList.count === 0
        retryEnable: true
        onRetryClicked: {
            xmHomePresenter.loadFirstPage()
        }
    }

    Item {
        id: id_title_bar_holder
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        implicitWidth: 80

        ShaderEffectSource {
            id: id_effect_source
            anchors.fill: parent
            sourceItem: id_book_view_container
            sourceRect: Qt.rect(x - 90, y, width, height)
        }

        FastBlur {
            anchors.fill: parent
            source: id_effect_source
            radius: 32
        }

        Rectangle {
            anchors.fill: parent
            color: "#4D000000"
            anchors.top: parent.top
            anchors.bottom: parent.bottom
        }
    }

    YVerticalTitleBar {
        id: id_title_bar
        iconButtonBackgroundItem.color: id_book_view.contentX
                                        > 30 ? "#991A1B1F" : YColors.grayNormal
        onCallBack: {
            backButtonClicked()
        }

        YIconButton {
            id: id_category_button_bg
            opacity: mouseAreaItem.pressed || !enabled ? 0.2 : 1
            implicitWidth: 44
            implicitHeight: 44
            radius: height / 2
            mouseAreaMargins: -25
            anchors.left: parent.left
            anchors.leftMargin: 16
            anchors.verticalCenter: parent.verticalCenter
            sourceSize: Qt.size(44, 44)
            imageName: "3rdpart/xmly/ic_all"
            onValidClicked: {
                showPage("3rdpart/xmly/YXmlyCategoryList", true, {
                             "xmHomePresenter": xmHomePresenter
                         })
                xmLogManager.clickEvent(XmTrace.ClickHomeFilter)
            }
        }

        YIconButton {
            id: id_more_button_bg
            opacity: mouseAreaItem.pressed || !enabled ? 0.2 : 1
            implicitWidth: 44
            implicitHeight: 44
            radius: height / 2
            mouseAreaMargins: -25
            anchors.left: parent.left
            anchors.leftMargin: 16
            anchors.bottom: parent.bottom
            sourceSize: Qt.size(44, 44)
            imageName: "3rdpart/xmly/ic_more"
            onValidClicked: {
                showPage("3rdpart/xmly/YXmlyPersonalRecord")
                xmLogManager.clickEvent(XmTrace.ClickHomeUser)
            }
        }
    }

    Connections {
        target: xmHomePresenter
        ignoreUnknownSignals: true

        function onLoadSuccess() {
            var list = xmHomePresenter.getCardList()
            for (var index = 0, len = list.length; index < len; index++) {
                bookList.append(list[index])
            }
        }
        function onLoadFailure(errorCode, errorMsg) {
            if (bookList.count > 0) {
                baseSignals.showToast(YXmlyTranslateText.loadingError(errorCode), YColors.grayNormal)
                return
            }
            id_loading_tip.text = YXmlyTranslateText.loadingError(errorCode)
        }
        function onSelectTagIdChanged() {
            id_loading_tip.loading = true
            bookList.clear()
            xmHomePresenter.loadFirstPage()
        }
    }

    Connections {
        target: qmlGlobal
        ignoreUnknownSignals: true
        function onCurrentPageIndexChanged() {
            if (qmlGlobal.currentPageIndex === YEnum.PageIndex.CooXmly) {
                console.warn("enter xmly") //此处通知c++开启toast开关
                xmLogManager.notifyEnterMainPage()
            } else {
                console.warn("leave xmly") //此处通知c++关闭toast开关
                xmLogManager.notifyExitMainPage()
            }
        }
    }

    Component.onCompleted: {
        xmHomePresenter.loadFirstPage()
    }

    onVisibleChanged: {
        if (visible) {
            xmLogManager.showPage(XmTrace.PageHome)
        } else {
            xmLogManager.hidePage(XmTrace.PageHome)
        }
    }
}

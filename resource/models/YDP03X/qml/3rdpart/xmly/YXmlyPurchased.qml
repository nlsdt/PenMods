import QtQuick 2.12
import BaseQml 1.0

import com.youdao.pen 1.0
import XmPresenter 1.0
import "i18n"

YBackButtonPage {
    id: id_purchased_root

    function append() {
        var list = xmPaidPresenter.getList()
        for (var index = 0, len = list.length; index < len; index++) {
            listModel.append(list[index])
        }
        console.log("purchased list success append() " + list.length)
    }

    XmPaidPresenter {
        id: xmPaidPresenter
    }

    YText {
        id: id_loading_tip
        anchors.centerIn: parent
        color: YColors.white
        text: qsTr("loading...")
        visible: listModel.count === 0
    }

    YHorizontalListView {
        id: id_purchased_listview
        anchors.fill: parent
        anchors.leftMargin: 90
        anchors.topMargin: 16
        anchors.bottomMargin: 16
        model: ListModel {
            id: listModel
        }
        spacing: 12
        onMovingChanged: {
            if (!moving && atXEnd && xmPaidPresenter.canLoadNextPage()) {
                xmPaidPresenter.loadNextPage()
            }
        }

        delegate: YXmlyAlbumViewDelegate {
            YImage {
                anchors.left: parent.left
                sourceSize: Qt.size(89, 36)
                imageName: (albumType === 1) ? "3rdpart/xmly/tab_album_vip" : (albumType === 2 ? "3rdpart/xmly/tab_album_quality" : "")
            }
            YMouseArea {
                anchors.fill: parent
                onClicked: {
                    showPage("3rdpart/xmly/YXmlyAlbumDetail", false, {
                                 "sourceId": albumId,
                                 "title": title
                             })
                    xmLogManager.clickEvent(XmTrace.ClickPurchasedItem,
                                            JSON.stringify({
                                                               "itemType": albumId,
                                                               "itemVal": title
                                                           }))
                }
            }
        }

        footer: (listModel.count > 0 && xmPaidPresenter.canLoadNextPage(
                     )) ? id_listview_loading_footer : null

        Component {
            id: id_listview_loading_footer
            YListViewLoadMoreFooter {}
        }
    }

    Connections {
        target: xmPaidPresenter
        function onLoadSuccess() {
            append()
            if (listModel.count == 0) {
                id_loading_tip.text = YXmlyTranslateText.noPurchased
            }
        }
        function onLoadFailure(errorCode, errorMsg) {
            if (listModel.count > 0) {
                baseSignals.showToast(YXmlyTranslateText.loadingError(errorCode), YColors.grayNormal)
                return
            }
            id_loading_tip.text = YXmlyTranslateText.loadingError(errorCode)
        }
    }

    Connections {
        target: xmAccountManager
        function onPurchase() {
            id_loading_tip.text = qsTr("loading...")
            listModel.clear()
            xmPaidPresenter.loadFirstPage()
        }
    }

    Component.onCompleted: {
        if (!xmAccountManager.hasLogin()) {
            id_loading_tip.text = YXmlyTranslateText.afterLogin
            return
        }
        xmPaidPresenter.loadFirstPage()
    }

    onVisibleChanged: {
        if (visible) {
            xmLogManager.showPage(XmTrace.PagePurchased)
        } else {
            xmLogManager.hidePage(XmTrace.PagePurchased)
        }
    }
}

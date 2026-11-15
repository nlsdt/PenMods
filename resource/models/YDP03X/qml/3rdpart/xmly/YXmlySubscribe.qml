import QtQuick 2.12
import BaseQml 1.0

import com.youdao.pen 1.0
import XmPresenter 1.0
import "i18n"

YBackButtonPage {
    id: id_subscribe_root

    function append() {
        var list = subscribePresenter.getList()
        for (var index = 0, len = list.length; index < len; index++) {
            listModel.append(list[index])
        }
        console.log("subscribe list success append() " + list.length)
    }

    XmSubscribePresenter {
        id: subscribePresenter
    }

    YText {
        id: id_loading_tip
        anchors.centerIn: parent
        color: YColors.white
        text: qsTr("loading...")
        visible: listModel.count === 0
    }

    YHorizontalListView {
        id: id_subscribe_listview
        anchors.fill: parent
        anchors.leftMargin: 90
        anchors.topMargin: 16
        anchors.bottomMargin: 16
        model: ListModel {
            id: listModel
        }
        spacing: 12
        onMovingChanged: {
            if (!moving && atXEnd && subscribePresenter.canLoadNextPage()) {
                subscribePresenter.loadNextPage()
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
                    xmLogManager.clickEvent(XmTrace.ClickSubscriptionItem,
                                            JSON.stringify({
                                                               "itemType": albumId,
                                                               "itemVal": title
                                                           }))
                }
            }
        }

        footer: (listModel.count > 0 && subscribePresenter.canLoadNextPage(
                     )) ? id_listview_loading_footer : null

        Component {
            id: id_listview_loading_footer
            YListViewLoadMoreFooter {}
        }
    }

    Connections {
        target: subscribePresenter
        function onLoadSuccess() {
            append()
            if (listModel.count == 0) {
                id_loading_tip.text = YXmlyTranslateText.noSubscrible
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
        target: xmSubscribeManager
        function onSubscribeChanged() {
            id_loading_tip.text = qsTr("loading...")
            listModel.clear()
            subscribePresenter.loadFirstPage()
        }
    }

    Component.onCompleted: {
        if (!xmAccountManager.hasLogin()) {
            id_loading_tip.text = YXmlyTranslateText.afterLogin
            return
        }
        subscribePresenter.loadFirstPage()
    }

    onVisibleChanged: {
        if (visible) {
            xmLogManager.showPage(XmTrace.PageSubscription)
        } else {
            xmLogManager.hidePage(XmTrace.PageSubscription)
        }
    }
}

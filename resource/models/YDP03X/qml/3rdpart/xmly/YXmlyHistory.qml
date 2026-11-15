import QtQuick 2.12
import BaseQml 1.0

import com.youdao.pen 1.0
import XmPresenter 1.0
import "i18n"

YBackButtonPage {
    id: id_history_root

    function append() {
        var list = xmPlayRecordPresenter.getList()
        for (var index = 0, len = list.length; index < len; index++) {
            listModel.append(list[index])
        }
        console.log("purchased list success append() " + list.length)
    }

    XmPlayRecordPresenter {
        id: xmPlayRecordPresenter
    }

    YText {
        id: id_loading_tip
        anchors.centerIn: parent
        color: YColors.white
        text: qsTr("loading...")
        visible: listModel.count === 0
    }

    YHorizontalListView {
        id: id_history_listview
        anchors.fill: parent
        anchors.leftMargin: 90
        anchors.topMargin: 16
        anchors.bottomMargin: 16
        model: ListModel {
            id: listModel
        }
        spacing: 12
        onMovingChanged: {
            if (!moving && atXEnd && xmPlayRecordPresenter.canLoadNextPage()) {
                xmPlayRecordPresenter.loadNextPage()
            }
        }

        delegate: YXmlyHistoryViewDelegate {
            name: albumTitle
            source: albumImgUrl
            YImage {
                anchors.left: parent.left
                sourceSize: Qt.size(89, 36)
                imageName: (albumType === 1) ? "3rdpart/xmly/tab_album_vip" : (albumType === 2 ? "3rdpart/xmly/tab_album_quality" : "")
            }
            YMouseArea {
                anchors.fill: parent
                onClicked: {
                    if (!wifiManager.isOnline()) {
                        baseSignals.showToast(YXmlyTranslateText.networkBroken,
                                              YColors.grayNormal)
                        return
                    }
                    xmPlayerManager.playTrack(playContent)
                    baseSignals.showAudioPlayer()
                    if (YBaseEnum.PLAYING !== mediaPlayerManager.playState) {
                        mediaPlayerManager.onClickedPlay()
                    }
                    console.warn("play track:" + playContent)
                    xmLogManager.clickEvent(XmTrace.ClickPlayHistoryItem,
                                            JSON.stringify({
                                                               "itemType": albumId,
                                                               "itemVal": albumTitle
                                                           }))
                }
            }
        }

        footer: (listModel.count > 0 && xmPlayRecordPresenter.canLoadNextPage(
                     )) ? id_listview_loading_footer : null

        Component {
            id: id_listview_loading_footer
            YListViewLoadMoreFooter {}
        }
    }

    Connections {
        target: xmPlayRecordPresenter
        function onLoadSuccess() {
            append()
            if (listModel.count == 0) {
                id_loading_tip.text = YXmlyTranslateText.noHistory
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
        target: xmPlayerManager
        function onTrackChanged() {
            id_loading_tip.text = qsTr("loading...")
            listModel.clear()
            xmPlayRecordPresenter.loadFirstPage()
        }
    }

    Component.onCompleted: {
        if (!xmAccountManager.hasLogin()) {
            id_loading_tip.text = YXmlyTranslateText.afterLogin
            return
        }
        xmPlayRecordPresenter.loadFirstPage()
    }

    onVisibleChanged: {
        if (visible) {
            xmLogManager.showPage(XmTrace.PagePlayHistory)
        } else {
            xmLogManager.hidePage(XmTrace.PagePlayHistory)
        }
    }
}

import QtQuick 2.12
import BaseQml 1.0
import com.youdao.pen 1.0
import XmPresenter 1.0
import "i18n"

YBackButtonPage {
    id: id_album_detail_root

    property string sourceId: "" // 专辑ID是字符串类型
    property int albumPayType: 0 // 专辑的付费类型，0=免费，1=VIP，2=付费
    property string title: ""

    function append() {
        var list = albumPresenter.getList()
        var count = listModel.count
        for (var index = 0, len = list.length; index < len; index++) {
            listModel.append(list[index])
            if (list[index].trackId === xmPlayerManager.getTrackId()) {
                id_album_listview.currentIndex = count + index
            }
        }
        console.log("album list success append() " + list.length)
    }

    XmAlbumPresenter {
        id: albumPresenter
    }

    YText {
        id: id_loading_tip
        anchors.centerIn: parent
        color: YColors.white
        text: qsTr("loading...")
        visible: listModel.count === 0
    }

    YBaseListView {
        id: id_album_listview
        anchors.fill: parent
        anchors.leftMargin: 90
        anchors.rightMargin: 16
        model: ListModel {
            id: listModel
        }
        orientation: Qt.Vertical
        clip: true
        spacing: 10
        currentIndex: -1
        onMovingChanged: {
            if (!moving && atYEnd && albumPresenter.canLoadNextPage()) {
                albumPresenter.loadNextPage()
            }
        }
        onCurrentIndexChanged: {
            positionViewAtIndex(currentIndex, ListView.Center)
        }
        Component.onCompleted: {
            positionViewAtIndex(currentIndex, ListView.Center)
        }
        header: YXmlyTextTitle {
            title: id_album_detail_root.title
        }

        delegate: YXmlyListItemBackground {
            id: id_delegate_item
            height: 76

            YText {
                id: id_album_title
                anchors.left: parent.left
                anchors.leftMargin: 19
                anchors.verticalCenter: parent.verticalCenter
                color: id_delegate_item.ListView.isCurrentItem ? YColors.blueText : YColors.white
                font.pixelSize: 26
                text: title
            }

            YImage {
                anchors.left: id_album_title.right
                anchors.leftMargin: 12
                anchors.verticalCenter: parent.verticalCenter
                sourceSize: Qt.size(64, 28)
                imageName: {
                    if (authorized || type === 0) {
                        ""
                    } else if (type === 1) {
                        "3rdpart/xmly/tab_list_audition"
                    } else {
                        if (albumPayType === 1) {
                            "3rdpart/xmly/tab_list_vip"
                        } else {
                            "3rdpart/xmly/tab_list_quality"
                        }
                    }
                }
            }

            YMouseArea {
                anchors.fill: parent
                onClicked: {
                    if (!wifiManager.isOnline()) {
                        baseSignals.showToast(YXmlyTranslateText.networkBroken,
                                              YColors.grayNormal)
                        return
                    }
                    if (canPlay) {
                        xmPlayerManager.playTrack(playContent)
                        baseSignals.showAudioPlayer()
                        if (YBaseEnum.PLAYING !== mediaPlayerManager.playState) {
                            mediaPlayerManager.onClickedPlay()
                        }
                        console.warn("play track:" + playContent)
                    } else {
                        showPage("3rdpart/xmly/YXmlyQRcodePay", false, {
                                     "sourceId": albumPresenter.getPayType(),
                                     "title": albumPresenter.getPayContent()
                                 })
                    }
                    xmLogManager.clickEvent(XmTrace.ClickAlbumItem,
                                            JSON.stringify({"itemType": (canPlay ? "play" : "pay"), "itemVal": trackId}))
                }
            }
        }

        footer: (listModel.count > 0 && albumPresenter.canLoadNextPage(
                     )) ? id_listview_loading_footer : null

        Component {
            id: id_listview_loading_footer
            YListViewLoadMoreFooter {}
        }
    }

    Connections {
        target: albumPresenter
        function onLoadSuccess() {
            albumPayType = albumPresenter.getPayType()
            append()
        }
        function onLoadFailure(errorCode, errorMsg) {
            if (listModel.count > 0) {
                baseSignals.showToast(YXmlyTranslateText.loadingError(errorCode), YColors.grayNormal)
                return
            }
            id_loading_tip.text = YXmlyTranslateText.loadingError(errorCode)
        }
        // 付费专辑当用户扫码支付成功后，重新刷新列表
        function onPurchaseAlbum() {
            id_loading_tip.text = qsTr("loading...")
            listModel.clear()
            albumPresenter.loadFirstPage()
        }
    }

    Connections {
        target: xmPlayerManager
        function onTrackChanged() {
            // 当专辑不同时直接返回，减少不必须要的页面刷新
            if (sourceId !== xmPlayerManager.getAlbumId()) {
                return
            }
            for (var index = 0, len = listModel.count; index < len; index++) {
                if (listModel.get(index).trackId === xmPlayerManager.getTrackId()) {
                    id_album_listview.currentIndex = index
                }
            }
            console.warn("album onTrackChanged()")
        }
    }

    Component.onCompleted: {
        albumPresenter.setAlbumId(sourceId)
        albumPresenter.loadFirstPage()
    }

    onVisibleChanged: {
        if (visible) {
            xmLogManager.showPage(XmTrace.PageAlbum,
                                  JSON.stringify({"pageVal": sourceId}))
        } else {
            xmLogManager.hidePage(XmTrace.PageAlbum,
                                  JSON.stringify({"pageVal": sourceId}))
        }
    }
}

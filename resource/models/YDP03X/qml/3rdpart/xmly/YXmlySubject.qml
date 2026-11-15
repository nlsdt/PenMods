import QtQuick 2.12
import BaseQml 1.0

import com.youdao.pen 1.0
import XmPresenter 1.0
import "i18n"

YBackButtonPage {
    id: id_subject_list_root

    property string sourceId: ""
    property string title: ""

    function append() {
        var list = subjectPresenter.getList()
        for (var index = 0, len = list.length; index < len; index++) {
            listModel.append(list[index])
        }
        console.log("subject list success append() " + list.length)
    }

    XmSubjectPresenter {
        id: subjectPresenter
    }

    YText {
        id: id_loading_tip
        anchors.centerIn: parent
        color: YColors.white
        text: qsTr("loading...")
        visible: listModel.count === 0
    }

    YHorizontalListView {
        id: id_subject_listview
        anchors.fill: parent
        anchors.leftMargin: 90
        anchors.topMargin: 16
        anchors.bottomMargin: 16
        model: ListModel {
            id: listModel
        }
        spacing: 12
        onMovingChanged: {
            if (!moving && atXEnd && subjectPresenter.canLoadNextPage()) {
                subjectPresenter.loadNextPage()
            }
        }

        delegate: YXmlyAlbumViewDelegate {
            YImage {
                anchors.left: parent.left
                sourceSize: Qt.size(89, 36)
                imageName: {
                    if (limitFreeType === 0) {
                        if (albumType === 1) {
                            "3rdpart/xmly/tab_album_vip"
                        } else if (albumType === 2) {
                            "3rdpart/xmly/tab_album_quality"
                        } else {
                            ""
                        }
                    } else {
                        "3rdpart/xmly/tab_album_limit_free"
                    }
                }
            }

            YMouseArea {
                anchors.fill: parent
                onClicked: {
                    if (limitFreeType === 1) {
                        showPage("3rdpart/xmly/YXmlyQRcodePay", false, {
                                     "sourceId": 5,
                                     "title": limitContent
                                 })
                    } else {
                        showPage("3rdpart/xmly/YXmlyAlbumDetail", false, {
                                     "sourceId": albumId,
                                     "title": title
                                 })
                    }
                    xmLogManager.clickEvent(XmTrace.ClickSubjectItem,
                                            JSON.stringify({
                                                               "itemType": ((limitFreeType === 1) ? "limitFree" : "album"),
                                                               "itemVal": albumId
                                                           }))
                }
            }
        }

        footer: (listModel.count > 0 && subjectPresenter.canLoadNextPage(
                     )) ? id_listview_loading_footer : null

        Component {
            id: id_listview_loading_footer
            YListViewLoadMoreFooter {}
        }
    }

    Connections {
        target: subjectPresenter
        function onLoadSuccess() {
            append()
            if (listModel.count == 0) {
                id_loading_tip.text = YXmlyTranslateText.noSubject
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

    Component.onCompleted: {
        subjectPresenter.setSubjectId(sourceId)
        subjectPresenter.loadFirstPage()
    }

    onVisibleChanged: {
        if (visible) {
            xmLogManager.showPage(XmTrace.PageSubject, JSON.stringify({
                                                                          "pageVal": sourceId
                                                                      }))
        } else {
            xmLogManager.hidePage(XmTrace.PageSubject, JSON.stringify({
                                                                          "pageVal": sourceId
                                                                      }))
        }
    }
}

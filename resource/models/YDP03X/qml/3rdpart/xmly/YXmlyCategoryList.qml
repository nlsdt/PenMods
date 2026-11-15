import QtQuick 2.12
import BaseQml 1.0

import XmPresenter 1.0
import "i18n"

YBackButtonPage {
    id: id_category_list_root

    property variant xmHomePresenter: null
    property int tagIndex: -1

    function append(model, list) {
        tagIndex = -1
        for (var index = 0, len = list.length; index < len; index++) {
            model.append(list[index])
            if (list[index].id === xmHomePresenter.getSelectedTagId()) {
                tagIndex = index
            }
        }
    }

    YXmlyUserAvatar {
        id: id_user_icon
        anchors.left: parent.left
        anchors.leftMargin: 17
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 18
    }

    YXmlyTabTitle {
        id: id_tab_title
        anchors.leftMargin: 90
        anchors.topMargin: 19
        model: ListModel {
            Component.onCompleted: {
                append({
                           "name": YXmlyTranslateText.hotList
                       })
                append({
                           "name": YXmlyTranslateText.allList
                       })
            }
        }

        onCurrentIndexChanged: {
            if (currentIndex === 0) {
                id_category_list_loader.sourceComponent = id_hotList_view
            } else {
                id_category_list_loader.sourceComponent = id_allList_view
            }
        }
    }

    YLoader {
        id: id_category_list_loader
        anchors.fill: parent
        anchors.leftMargin: 90
        anchors.topMargin: 72
    }

    Component {
        id: id_hotList_view

        YXmlyCategoryView {
            model: ListModel {
                id: listModel
            }

            onSelectTagId: {
                xmHomePresenter.selectTagId(tagId)
                backButtonClicked()
                xmLogManager.clickEvent(XmTrace.ClickHomeFilterItem,
                                        JSON.stringify({"itemType": "hot", "itemVal": tagTitle}))
            }

            Component.onCompleted: {
                append(listModel, xmHomePresenter.getHotList())
                currentIndex = tagIndex
                positionViewAtIndex(currentIndex, ListView.Center)
            }

            Connections {
                target: xmHomePresenter
                function onLoadSuccess() {
                    if (listModel.count > 0) {
                        return
                    }
                    append(listModel, xmHomePresenter.getHotList())
                    currentIndex = tagIndex
                    positionViewAtIndex(currentIndex, ListView.Center)
                }
            }
        }
    }

    Component {
        id: id_allList_view

        YXmlyCategoryView {
            model: ListModel {
                id: listModel
            }

            onSelectTagId: {
                xmHomePresenter.selectTagId(tagId)
                backButtonClicked()
                xmLogManager.clickEvent(XmTrace.ClickHomeFilterItem,
                                        JSON.stringify({"itemType": "category", "itemVal": tagTitle}))
            }

            Component.onCompleted: {
                append(listModel, xmHomePresenter.getCategoryList())
                currentIndex = tagIndex
                positionViewAtIndex(currentIndex, ListView.Center)
            }

            Connections {
                target: xmHomePresenter
                function onLoadSuccess() {
                    if (listModel.count > 0) {
                        return
                    }
                    append(listModel, xmHomePresenter.getCategoryList())
                    currentIndex = tagIndex
                    positionViewAtIndex(currentIndex, ListView.Center)
                }
            }
        }
    }

    Component.onCompleted: {
        id_category_list_loader.sourceComponent = id_hotList_view
        id_category_list_loader.active = true
    }

    onVisibleChanged: {
        if (visible) {
            xmLogManager.showPage(XmTrace.PageHomeFilter)
        } else {
            xmLogManager.hidePage(XmTrace.PageHomeFilter)
        }
    }
}

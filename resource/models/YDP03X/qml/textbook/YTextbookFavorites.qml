import QtQuick 2.12
import com.youdao.pen 1.0

import BaseQml 1.0
import "../components"
import "../i18n"

Item {
    id: id_textbook_favorites_page
    anchors.fill: parent
    objectName: "YTextbookFavorites.qml"
    property string bookId: settingManager.studyingBookId

    YLoader {
        id: id_textbook_favorites_loader
        anchors.fill: parent
        active: true
        asynchronous: false
        property bool editing: false

        onLoaded: {
            textBookBlockManager.entryBook(bookId,"",true, true)
        }

        sourceComponent: YBackgroundIgnoreMouseEvent {
            id: id_source_component
            anchors.fill: parent
            anchors.right: parent.right
            anchors.rightMargin: 16

            property string curblockId: ""

            readonly property bool favoritesListEmpty:
                (0 === id_textbook_favorites_loader_listview.count)

            function showFilter() {
                id_textbook_favorites_filter_drawer_layer.show()
            }

            function showDelete(blockId, blockTitle) {
                curblockId = blockId
                id_textbook_favorites_delete_drawer_layer.blockTitle = blockTitle
                id_textbook_favorites_delete_drawer_layer.updateIndex()
                id_textbook_favorites_delete_drawer_layer.show()
            }

            // 标题栏
            YVerticalTitleBar {
                id: id_title_bar
                onCallBack: {
                    textBookBlockManager.wipeData()
                    showSubPage(YEnum.Textbook_Home, true)
                }

                YIconButton {
                    id: id_more_button_bg
                    enabled: id_textbook_page.isSelectEnabled
                    implicitWidth: 44
                    implicitHeight: 44
                    mouseAreaMargins: -18
                    radius: height/2
                    anchors.left: parent.left
                    anchors.leftMargin: 16
                    anchors.bottom: parent.bottom
                    sourceSize: Qt.size(36, 36)
                    imageName: "textbook/switch"

                    onClicked: {
                        showSubPage(YEnum.Textbook_MyTextbook, true)
                    }
                }
            } // YVerticalTitleBar

            // 有收藏音频
            YBaseListView {
                id: id_textbook_favorites_loader_listview
                anchors.fill: parent
                anchors.leftMargin: 90
                spacing: 10
                model: textBookBlockManager
                onMovingChanged: {
                    if (!moving && atYEnd && textBookBlockManager.hasMore) {
                        textBookBlockManager.loadMore()
                    }
                }

                delegate: id_normal_delegate
                header: id_header

                footer: (textBookBlockManager.itemCount > 0 && textBookBlockManager.hasMore)
                        ? id_listview_loading_footer : null

                Component {
                    id: id_listview_loading_footer

                    YListViewLoadMoreFooter {}
                }

                Component.onCompleted: {
                }
            }// YBaseListView

            // 没有收藏音频
            YTextbookFavoritesEmptyTipComponent {
                id: id_empty_tip
                visible: favoritesListEmpty

                YTimer {
                    id: id_delay_check_empty_timer
                    interval: 300

                    function recheck() {
                        id_empty_tip.visible = false
                        restart()
                    }

                    function reshow() {
                        id_empty_tip.visible = Qt.binding(function(){
                            return (0 === id_word_book_page_switch_listview.count)
                        })
                    }

                    onTriggered: {
                        reshow()
                    }
                }
            }// YTextbookFavoritesEmptyTipComponent

            // 选择排序方式
            YTextBookFavoritesFilterDrawerLayer {
                id: id_textbook_favorites_filter_drawer_layer
                onFilterChanged: {
                    if(filterInt === 0){
                        textBookBlockManager.entryBook(bookId,"",true, true) //按加入时间排序
                    }else{
                        textBookBlockManager.entryBook(bookId,"",true, false) //按单元内容排序
                    }
                }
            }

            // 确认是否删除
            YTextBookFavoritesDeleteDrawerLayer {
                id: id_textbook_favorites_delete_drawer_layer
                onFilterChanged: {
                    if(bdelete){
                        textBookBlockManager.cancel(curblockId, true)
                        id_check_editing_after_remove_timer.restart()
                    }
                }
            }

        } // sourceComponent

        Component {
            id: id_normal_delegate
            Item {
                width: ListView.view.width
                height: 76

                YTextbookListenToAudioColumnViewItem {
                    id: id_textbook_favorites_page_column_view_item
                    implicitHeight: 76
                    title:  model.modelData.title  // unit_title
                    titleFontFamily: fontManager.fontFamilyZhCn
                    value: model.modelData.mmssString // 分秒格式化文本 mm:ss
                    sourceSize: Qt.size(36, 36)
                    imageName: "ic_delete"
                    onLeftClicked: {
                        textBookBlockManager.clickMedia(model.modelData.blockId)
                        if (YEnum.PLAYING !== mediaPlayerManager.playState) {
                            mediaPlayerManager.onClickedPlay()
                        }
                    }
                    onRightClicked: {
                        // 是否删除
                        id_textbook_favorites_loader.item.showDelete(model.modelData.blockId, model.modelData.title)
                    }
                }
            }

        }// Component

        Component {
            id: id_header
            Item {
                id: id_title_bar
                width: ListView.view.width
                implicitHeight: 80

                YTextBase {
                    color: YColors.grayText
                    font.pixelSize: 26
                    font.family: fontManager.fontFamilyZhCn
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.right: parent.right
                    elide: YTextBase.ElideRight
                    //text: YTranslateText.textbookMyFavorites
                    text: {
                        if(id_textbook_favorites_loader.item.favoritesListEmpty)
                            return YTranslateText.textbookMyFavorites
                        else
                            return settingManager.studyingBookPublisher + settingManager.studyingBookTitle
                    }
                }

                YTextBase {
                    id: id_switching_unit_label
                    color: YColors.blueText
                    font.pixelSize: 24
                    font.family: fontManager.fontFamilyZhCn
                    anchors.verticalCenter: parent.verticalCenter
                    text: YTranslateText.textbookFavoritesSort
                    anchors.right:  parent.right
                    anchors.rightMargin: 20
                    width: paintedWidth
                    height: paintedHeight
                    opacity: id_switching_unit_button.pressed ? 0.6 : 1
                }

                YMouseArea {
                    id: id_switching_unit_button
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    anchors.left: id_switching_unit_label.left
                    anchors.leftMargin: -30
                    anchors.right: parent.right
                    anchors.rightMargin: -16
                    // visible: id_download_manager_label.visible
                    //enabled: id_download_manager_label.enabled
                    onClicked: {
                        // 排序方式
                        id_textbook_favorites_loader.item.showFilter()
                    }
                    objectName: "YMouseArea_id_switching_unit_button"
                }
            }
        } // Component

        YTimer {
            id: id_check_editing_after_remove_timer
            interval: 600
            onTriggered: {
                if (id_empty_tip.visible) {
                    editing = false
                }
            }
        }
    }

}


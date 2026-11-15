import QtQuick 2.0
import com.youdao.pen 1.0

import BaseQml 1.0
import "../components"
import "../i18n"

YBackgroundIgnoreMouseEvent {
    id: id_textbook_listentoaudio_page_column_view_root

    property alias model: id_textbook_listentoaudio_page_column_view.model

    YBaseListView {
        id: id_textbook_listentoaudio_page_column_view
        anchors.fill: parent
        spacing: 10
        model : textBookBlockManager
        onMovingChanged: {
            if (!moving && atYEnd && textBookBlockManager.hasMore) {
                textBookBlockManager.loadMore()
            }
        }

        delegate: id_normal_delegate
        header: id_header_component

        footer: (textBookBlockManager.itemCount > 0 && textBookBlockManager.hasMore)
                ? id_listview_loading_footer : id_listview_loaded_footer

        Component {
            id: id_listview_loading_footer

            YListViewLoadMoreFooter {}
        }

        Component {
            id: id_listview_loaded_footer

            YSpacing {
                width: id_textbook_listentoaudio_page_column_view.width
                implicitHeight: 12
            }
        }
    } // YBaseListView

    Component {
        id: id_normal_delegate
        Item {
            width: id_textbook_listentoaudio_page_column_view.width
            implicitHeight: 76

            YTextbookListenToAudioColumnViewItem {
                id: id_textbook_listentoaudio_page_column_view_item
                property var stored: model.modelData.isStored

                anchors.fill: parent

                title:  model.modelData.title  // unit_title
                titleFontFamily: fontManager.fontFamilyZhCn
                value: model.modelData.mmssString // 分秒格式化文本 mm:ss
                imageName: stored ? "textbook/collect-stored": "textbook/collect"
                onLeftClicked: {
                    textBookBlockManager.clickMedia(model.modelData.blockId)
                    if (YEnum.PLAYING !== mediaPlayerManager.playState) {
                        mediaPlayerManager.onClickedPlay()
                    }
                }

                onRightClicked: {
                    if(!stored){
                        textBookBlockManager.store(model.modelData.blockId)
                    } else {
                        textBookBlockManager.cancel(model.modelData.blockId)
                    }
                }
                onStoredChanged: {
                    console.log("YTextbookListenToAudioColumnView.qml ===stored ", stored)
                }

            }
        }
    } // Component

    Component {
        id: id_header_component
        Item {
            width: id_textbook_listentoaudio_page_column_view.width
            implicitHeight: 80

            YTextBase {
                color: YColors.grayText
                font.pixelSize: 26
                font.family: fontManager.fontFamilyZhCn
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.right: parent.right
                elide: YTextBase.ElideRight
                text: YTranslateText.textbookListenToAudio
            }

            YTextBase {
                id: id_switching_unit_label
                color: YColors.blueText
                font.pixelSize: 24
                font.family: fontManager.fontFamilyZhCn
                anchors.verticalCenter: parent.verticalCenter
                text: YTranslateText.textbookSwitchUnit
                anchors.right:  parent.right
                anchors.rightMargin: 6
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
                    // 切换单元
                     logManager.sendHttpLog("textbook_listening_change-unit_click")
                    id_textbook_home_filter_drawer_layer.show()
                }
                objectName: "YMouseArea_id_switching_unit_button"
            }
        }
    } // Component

}


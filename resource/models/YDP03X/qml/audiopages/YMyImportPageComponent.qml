import QtQuick 2.12
import com.youdao.pen 1.0

import BaseQml 1.0
import "../components"
import "../i18n"

YBackButtonAudioPage {
    id: id_container_index

    property bool isChildDir: false
    property string titleName: ""

    ignoreDefaultBackButtonClicked: true

    onBackButtonClickedCallback: {
        if (visible && isChildDir) {
            closeChildDir()
        } else {
            backButtonClicked()
            mediaManager.wipeData()
        }
    }

    function closeChildDir() {
        mediaManager.wipeData()
        isChildDir = false
        mediaManager.entryMyImport()
    }

    YBaseListView {
        id: id_import_page_column_view
        anchors.fill: parent
        anchors.leftMargin: 90
        anchors.rightMargin: 16
        model: mediaManager
        onMovingChanged: {
            if (!moving && atYEnd && mediaManager.hasMore) {
                mediaManager.loadMore(YEnum.DS_ALL, !isChildDir)
            }
        } // todo 细化 loadMore 逻辑

        header: id_header_component

        Component {
            id: id_header_component
            Item {
                width: id_import_page_column_view.width
                implicitHeight: 80

                YTextBase {
                    color: YColors.grayText
                    font.pixelSize: 26
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.rightMargin: 20
                    elide: YTextBase.ElideRight
                    text: isChildDir ? titleName : YTranslateText.myImportAudios
                }
            }
        }

        delegate: Item {
            width: id_import_page_column_view.width
            implicitHeight: 86
            YMyImportPageComponentViewItem {
                readonly property bool isPlaying: (YEnum.PLAYING === mediaPlayerManager.playState)
                                                  && (mediaManager.playingMediaId === model.modelData.id)
                implicitHeight: 76
                title: (index + 1) + ". " + model.modelData.title
                titleColor: (!isDir && isPlaying) ? YColors.red : YColors.grayText
                value: isDir ? "" : model.modelData.sizeString
                valueColor: titleColor

                function playAudio() {
                    qmlGlobal.audioPlayingColomnId = "myimport"
                    mediaManager.clickMedia(model.modelData.id)
                    baseSignals.showAudioPlayer();
                    if (YEnum.PLAYING !== mediaPlayerManager.playState) {
                        mediaPlayerManager.onClickedPlay()
                    }
                }

                onClicked: {
                    if (isDir) {
                        isChildDir = true
                        titleName = model.modelData.title
                        mediaManager.entryMyImportDir(model.modelData.title)
                    } else {
                        playAudio()
                    }
                }
            }
        }

        footer: (mediaManager.itemCount > 0 && mediaManager.hasMore)
                ? id_listview_loading_footer : id_listview_loaded_footer

        Component {
            id: id_listview_loading_footer

            YListViewLoadMoreFooter {}
        }

        Component {
            id: id_listview_loaded_footer

            YSpacing {
                width: id_import_page_column_view.width
                implicitHeight: 18
            }
        }

        onBusyingChanged: {
            if (!busying) {
                id_import_page_column_view.positionViewAtBeginning()
            }
        }
    }

    YMyImportPageComponentEmpty {
        id: id_import_page_column_view_empty_tip
        anchors.fill: parent
        visible: columnManager.importCount == 0
    }
}


import QtQuick 2.12
import com.youdao.pen 1.0

import BaseQml 1.0
import "../i18n"

YDrawerLayer {
    id: id_drawer_layer
    indicatorLeftMargin: 16
    indicatorRightMargin: 50
    drawerContainerRightMargin: 30
    containerWidth: id_list_container.width

    function playAudio(columnId, mediaId) {
        qmlGlobal.audioPlayingColomnId = columnId
        mediaManager.clickMedia(mediaId)
        baseSignals.showAudioPlayer();
        if (YEnum.PLAYING !== mediaPlayerManager.playState) {
            mediaPlayerManager.onClickedPlay()
        }
    }

    function updateModel() {
        let list = mediaManager.getScanningSearchResults()
        console.log("YMyProductionPageFilterDrawerLayer.qml===count ", list.length)
        id_list_container_repeater.model = list
    }

    Flickable {
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        width: id_list_container.width
        contentHeight: 24 + 16 + id_title.contentHeight
                       + id_list_container.height + 30
        YTextBase {
            id: id_title
            color: YColors.grayText
            font.pixelSize: 26
            anchors.left: parent.left
            anchors.leftMargin: 4
            anchors.top: parent.top
            anchors.topMargin: 24
            text: YTranslateText.myProductionAudiosContent
        }

        Column {
            id: id_list_container
            anchors.top: id_title.bottom
            anchors.topMargin: 16
            width: 558
            spacing: 10

            Repeater {
                id: id_list_container_repeater

                YButton {
                    implicitWidth: 558
                    readonly property bool isPlaying: (YEnum.PLAYING === mediaPlayerManager.playState)
                                                      && (mediaManager.playingMediaId === model.modelData.id)
                    color: isPlaying ? YColors.red : "#2D2E33"
                    mouseAreaMargins: -4
                    textItem.width: 500

                    TextMetrics {
                        id: textMetrics
                        font.family: fontManager.fontFamily
                        font.pixelSize: 28
                        elide: Text.ElideRight
                        elideWidth: 500
                    }
                    textItem.text:
                    {
                        textMetrics.text = model.modelData.title
                        return textMetrics.elidedText
                    }
                    onClicked: {
                        playAudio(model.modelData.columnId, model.modelData.id)
                    }
                }
            }
        }

    }
}

import QtQuick 2.12
import com.youdao.pen 1.0

import BaseQml 1.0
import "../i18n"

YDrawerLayer {
    id: id_drawer_layer
    indicatorLeftMargin: 16
    indicatorRightMargin: 50
    drawerContainerRightMargin: 30
    containerWidth: 558

    function updateModel() {
        let list = textBookBlockManager.getSearchedBlocks()
        console.log("YTextBookScanReadFilterDrawerLayer.qml===count:", list.length)
        id_list_container_repeater.model = list
    }

    property int currentIndex: 0
    property int currentPage: 0

    Flickable {
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        flickableDirection: Flickable.VerticalFlick
        width: id_list_container.width
        contentHeight: 24 + 16 + id_title.contentHeight + id_title_tip.contentHeight
                       + id_list_container.height + 30

        YTextBase {
            id: id_title
            color: YColors.grayText
            font.pixelSize: 26
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.topMargin: 24
            font.family: fontManager.fontFamilyZhCn
            text: (YTranslateText.textbookScanReadFilterTitle).arg(currentPage)
        }

        YTextBase {
            id: id_title_tip
            color: YColors.grayText
            font.pixelSize: 26
            anchors.left: parent.left
            anchors.top: id_title.bottom
            anchors.topMargin: 16
            font.family: fontManager.fontFamilyZhCn
            text: YTranslateText.textbookScanReadFilterTip
        }

        Column {
            id: id_list_container
            anchors.top: id_title_tip.bottom
            anchors.topMargin: 16
            width: 558
            spacing: 10

            Repeater {
                id: id_list_container_repeater

                YButton{
                    implicitWidth: 558
                    color: currentIndex===index ? YColors.red : "#2D2E33"
                    mouseAreaMargins: -4
                    textFamily: fontManager.fontFamilyZhCn
                    text: model.modelData.title

                    onClicked: {
                        console.log("YTextBookScanReadFilterDrawerLayer.qml===model.modelData.page:", model.modelData.page)

                        currentIndex = index
                        console.log("YTextBookScanReadFilterDrawerLayer.qml===onClicked===blockId: ", model.modelData.blockId)
                        textBookBlockManager.clickMedia(model.modelData.blockId)
                        if (YEnum.PLAYING !== mediaPlayerManager.playState) {
                            mediaPlayerManager.onClickedPlay()
                        }
                    }
                }

            } // Repeater
        }
    }
}


import QtQuick 2.12
import com.youdao.pen 1.0

import BaseQml 1.0
import "../i18n"

YDrawerLayer {
    id: id_drawer_layer
    indicatorLeftMargin: 16
    indicatorRightMargin: 50
    drawerContainerRightMargin: 30
    containerWidth: id_grid_container.width

    property int currentIndex: YEnum.AudioFilters.AllAudio
    signal filterChanged(string filterString)

    Flickable {
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        width: id_grid_container.width
        contentHeight: 24 + 16 + id_title.contentHeight
                       + id_grid_container.height + 30
        YTextBase {
            id: id_title
            color: YColors.grayText
            font.pixelSize: 26
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.topMargin: 24
            text: YTranslateText.ydListeningChoice
        }
        Grid {
            id: id_grid_container
            anchors.top: id_title.bottom
            anchors.topMargin: 16
            width: 558
            columns: 3
            spacing: 12
            Repeater {
                id: id_grid_container_repeater
                YButton {
                    implicitWidth: 178
                    color: index === currentIndex ? YColors.red : "#2D2E33"
                    mouseAreaMargins: -4
                    textFamily: fontManager.fontFamilyZhCn
                    text: model.modelData
                    onClicked: {
                        if (currentIndex !== index) {
                            currentIndex = index
                            if (0 === index) {
                                filterChanged("全部")
                            } else {
                                filterChanged(model.modelData)
                            }
                            hide()
                        }
                    }
                }
            }
        }
    }

    Component.onCompleted: {
        const columnFilterList = [YTranslateText.all].concat(settingManager.columnFilterList)
        id_grid_container_repeater.model = columnFilterList
    }
}

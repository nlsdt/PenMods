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

    property int currentIndex: 0
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
            text: "选择你的题目"
        }
        Grid {
            id: id_grid_container
            anchors.top: id_title.bottom
            anchors.topMargin: 16
            width: 558
            columns: 2
            spacing: 12
            Repeater {
                id: id_grid_container_repeater
                YButton {
                    implicitWidth: 260
                    color: index === currentIndex ? YColors.red : "#2D2E33"
                    mouseAreaMargins: -4
                    textFamily: fontManager.fontFamilyZhCn
                    text: model.modelData
                    onClicked: {
                        if (currentIndex !== index) {
                            currentIndex = index
                            if (0 === index) {
                                filterChanged("")
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
        id_grid_container_repeater.model = [
                    "全部",
                    "知识点未掌握",
                    "粗心大意",
                    "思路错误",
                    "理解错误",
                    "顽固错题"
                ]
    }
}

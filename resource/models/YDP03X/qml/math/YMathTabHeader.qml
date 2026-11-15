import QtQuick 2.12
import BaseQml 1.0

YItem {
    id: id_math_tab_header
    property var titles: null
    property int currentIdx: 0
    property int itemMargin: 70
    property int leftMargin: 20
    signal itemClicked(int idx)

    Row {
        id: id_math_tab_row
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.leftMargin: id_math_tab_header.leftMargin
        anchors.bottom: parent.bottom

        Repeater {
            model: {
                if (id_math_tab_header.titles == null) { return 0 }
                return id_math_tab_header.titles.length
            }

            YItem {
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                width: id_title_label.width + id_math_tab_header.itemMargin*2

                YText {
                    id: id_title_label
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    horizontalAlignment: Text.AlignLeft
                    color: {
                        if (id_math_tab_header.currentIdx === index) {
                            return YColors.red
                        } else {
                            return YColors.grayText
                        }
                    }
                    font.pixelSize: 26
                    text: id_math_tab_header.titles[index]
                }
                YImage {
                    sourceSize: Qt.size(100, 2)
                    anchors.left: id_title_label.right
                    anchors.leftMargin: 20
                    anchors.verticalCenter: id_title_label.verticalCenter
                    imageName: "math/wrong-tab-line"
                    visible: index < id_math_tab_header.titles.length - 1
                }
                Rectangle {
                    id: id_bottom_bar
                    color: YColors.red
                    radius: 4
                    anchors.top: id_title_label.bottom
                    anchors.topMargin: 2
                    anchors.horizontalCenter: id_title_label.horizontalCenter
                    width: 24
                    height: 4
                    visible: titles.length !== 1 && id_math_tab_header.currentIdx === index
                }
                YMouseArea {
                    anchors.fill: parent
                    onClicked: {
                        itemClicked(index)
                    }
                }
            }
        }
    }
}

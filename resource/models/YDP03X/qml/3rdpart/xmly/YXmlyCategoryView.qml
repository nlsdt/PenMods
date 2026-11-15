import QtQuick 2.12

import BaseQml 1.0

GridView {
    id: id_category_view_root
    anchors.fill: parent
    anchors.leftMargin: 10
    clip: true
    cellWidth: 230
    cellHeight: 90
    cacheBuffer: 100
    signal selectTagId(string tagId, string tagTitle)

    delegate: YMouseArea {
        id: id_delegate_item
        width: 218
        height: 80

        Rectangle {
            anchors.fill: parent
            radius: 40
            color: id_delegate_item.GridView.isCurrentItem ? "#ff683d" : "#2d2e33"

            Item {
                anchors.centerIn: parent
                width: id_text.width + id_icon.width

                YImageBase {
                    id: id_icon
                    anchors.left: parent.left
                    anchors.verticalCenter: id_text.verticalCenter
                    width: 32
                    height: 32
                    source: imgUrl
                    cache: true
                    YImage {
                        id: id_icon_default
                        anchors.fill: parent
                        sourceSize: Qt.size(parent.width, parent.height)
                        imageName: "3rdpart/xmly/ic_default_category"
                        visible: !id_icon.isLoaded
                    }
                }

                YText {
                    id: id_text
                    anchors.left: id_icon.right
                    leftPadding: 10
                    anchors.verticalCenter: parent.verticalCenter
                    font.pixelSize: 26
                    font.family: fontManager.fontFamilyZhCn
                    text: title
                }
            }
        }

        onClicked: {
            currentIndex = index
            selectTagId(id, title)
        }
    }
}

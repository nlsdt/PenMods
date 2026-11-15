import QtQuick 2.12

import BaseQml 1.0

YBaseListView {
    id: id_tab_title_root
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.top: parent.top
    implicitHeight: 40
    orientation: Qt.Horizontal
    delegate: id_delegate
    highlight: id_highlight
    highlightFollowsCurrentItem: false
    spacing: 60
    focus: true

    Component {
        id: id_delegate

        YMouseArea {
            id: id_wrapper
            width: id_text.contentWidth
            height: id_text.contentHeight

            YText {
                id: id_text
                anchors.verticalCenter: parent.verticalCenter
                width: contentWidth
                height: contentHeight
                font.pixelSize: 26
                font.family: fontManager.fontFamilyZhCn
                text: name
                color: id_wrapper.ListView.isCurrentItem ? "#ff683d" : "#909199"
            }

            onClicked: {
                currentIndex = index
            }
        }
    }

    Component {
        id: id_highlight

        Rectangle {
            width: 40
            height: 4
            radius: 2
            y: id_tab_title_root.currentItem.y + id_tab_title_root.currentItem.height + 4
            anchors.horizontalCenter: id_tab_title_root.currentItem.horizontalCenter
            color: "#ff683d"
        }
    }
}

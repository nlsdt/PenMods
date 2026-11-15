import QtQuick 2.0
import com.youdao.pen 1.0
import BaseQml 1.0
import "../i18n"

YSpacingForColumn {
    id: id_guide_cell
    property var yModel: null
    height: {
        return getHeight()
    }

    Rectangle{
        id: id_example_text_rect
        anchors.fill: parent
        anchors.bottomMargin: 10 // Bottom Line
        radius: 16
        color: YColors.grayNormal
        YImage {
            id: id_arrow_img
            sourceSize: Qt.size(36, 36)
            anchors.verticalCenter: id_title_label.verticalCenter
            anchors.right: parent.right
            anchors.rightMargin: 22
            imageName: getIconImg()
        }
        YText {
            id: id_title_label
            anchors.top: parent.top
            anchors.topMargin: 22
            anchors.left: parent.left
            anchors.leftMargin: 20
            horizontalAlignment : YText.AlignLeft
            font.pixelSize: 28
            font.weight: Font.Medium
            color: YColors.grayText
            text: yModel.title
        }
        YImage {
            id: id_items_list
            anchors.top: parent.top
            anchors.topMargin: 81
            anchors.left: parent.left
            anchors.leftMargin: 20
            width: {
                if (yModel === null) { return 0}
                return yModel.size.width
            }
            height: {
                if (yModel === null) { return 0}
                return yModel.size.height
            }
            fillMode: YImage.Stretch
            imageName: {
                if (yModel === null) { return "" }
                return "math/guide/"+yModel.content
            }
            visible: {
                if (yModel === null) { return false }
                return yModel.isOpen
            }
        }
    }
    YMouseArea {
        anchors.fill: id_guide_cell
        onClicked: {
            yModel.isOpen = !yModel.isOpen
            id_items_list.visible = yModel.isOpen
            id_guide_cell.height = getHeight()
            id_arrow_img.imageName = getIconImg()
        }
    }

    function getHeight() {
        if (yModel === null) { return 80}
        let closedHeight = 80
        if (yModel.isOpen) {
            return yModel.openHeight + 10
        } else {
            return closedHeight + 10
        }
    }

    function getIconImg() {
        if (yModel === null) { return "math/guide-close" }
        if (yModel.isOpen) {
            return "math/guide-close"
        } else {
            return "math/guide-open"
        }
    }
}

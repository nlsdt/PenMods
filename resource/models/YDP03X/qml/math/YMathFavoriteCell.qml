import QtQuick 2.12
import com.youdao.pen 1.0
import BaseQml 1.0

Item {
    id: id_favorite_cell
    anchors.left: parent.left
    anchors.right: parent.right
    height: 76
    property bool isInEditing: false
    property string text: ""
    signal cellDidClicked()
    signal cellDeleteDidClicked()

    Rectangle{
        id: id_bg_rect
        anchors.fill: parent
        radius: 16
        color: YColors.grayNormal
        YTextBase {
            anchors.left: parent.left
            anchors.leftMargin: 20
            anchors.right: parent.right
            anchors.rightMargin: 82
            anchors.verticalCenter: parent.verticalCenter
            color: YColors.white
            font.pixelSize: 26
            elide: Text.ElideRight
            horizontalAlignment : YText.AlignLeft
            verticalAlignment: YText.AlignVCenter
            opacity: {
                if (id_favorite_cell.isInEditing) {
                    return 0.6
                } else {
                    return 1
                }
            }
            text: id_favorite_cell.text
        }
        MouseArea {
            anchors.fill: parent
            onClicked:  {
                if (id_favorite_cell.isInEditing) { return }
                cellDidClicked()
            }
        }
        YIconButton {
            id: id_delete_btn
            implicitWidth: 36
            implicitHeight: 36
            anchors.right: parent.right
            anchors.rightMargin: 20
            anchors.verticalCenter: parent.verticalCenter
            mouseAreaMargins: -20
            iconSourceSize: Qt.size(36, 36)
            icon: "math/fav-item-delete"
            visible: id_favorite_cell.isInEditing
            onClicked: {
                cellDeleteDidClicked()
            }
        }
    }
}

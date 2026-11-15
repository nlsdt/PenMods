import QtQuick 2.12
import com.youdao.pen 1.0
import BaseQml 1.0
import "../components"

Item {
    id: id_globe_content
    anchors.left: parent.left
    anchors.leftMargin: 90
    anchors.right: parent.right
    anchors.rightMargin: 40
    implicitHeight: 202
    anchors.verticalCenter: parent.verticalCenter

    property string explainImgs: ""
    property string explainText: ""
    property alias iconItem: id_icon_left
    property alias textItem: id_text
    property int txtLength: 3

    YOpacityMaskImage {
        id: id_icon_left
        width: visible ? 202 : 0
        height: visible ? 202 : 0
        anchors.left: parent.left
        maskItem.radius: 38
        source: visible && explainImgs.length ? explainImgs : ""
    }

    YTextMedium {
        id: id_text
        anchors.right: parent.right
        anchors.left: id_icon_left.right
        anchors.leftMargin: 40
        anchors.verticalCenter: parent.verticalCenter
        height: 202
        font.family: fontManager.fontFamilyZhCn
        font.pixelSize: {
            if (txtLength <= 3) {
                return 60
            } else if (txtLength <= 7) {
                return 48
            }
            return 40
        }
        textFormat: YTextMedium.RichText
        text: explainText.length ? explainText : ""
        wrapMode: Text.WordWrap
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignLeft
        elide: Text.ElideRight
    }
}

import QtQuick 2.12
import BaseQml 1.0
import XmPresenter 1.0
import "i18n"

Item {
    id: id_delegate_item
    implicitWidth: 180
    implicitHeight: ListView.view.height

    property alias source: id_delegate_item_bg.source
    property alias name: id_item_title.text
    Column {
        spacing: 14

        YXmlyRoundedImage {
            id: id_delegate_item_bg
            width: id_delegate_item.width
            height: width
            radius: 24
            source: imgUrl
            YImage {
                id: id_default_bg
                anchors.fill: parent
                sourceSize: Qt.size(parent.width, parent.height)
                imageName: "3rdpart/xmly/img_default_cover"
                visible: !id_delegate_item_bg.isLoaded
            }
        }
        Rectangle{
            id: id_title_bg
            width: id_delegate_item.width
            anchors.top: id_delegate_item.bottom
            height: 22
            color: "black"
            YShadowText {
                id: id_item_title
                anchors.horizontalCenter: id_title_bg.horizontalCenter
                anchors.verticalCenter: id_title_bg.verticalCenter
                height: id_title_bg.height
                width: id_delegate_item.width
                font.pixelSize: 22
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                elide: YText.ElideRight
                text: title

            }
        }
    }
}

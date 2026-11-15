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
//    property int   albumCount: 8
//    property string album_title: '<span style="background-color:red;border-radius:4px;font-size:15px">合集</span>'
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
            Rectangle{
                id:id_album_bg
                color: "black"
                opacity: 0.7
                width: id_delegate_item.width
                height: 40
                anchors.bottom: id_delegate_item_bg.bottom
                visible: jumpType===2 && albumCount > 0

                YShadowText {
                    id: id_album_count
                    text: "共" + albumCount + "本"
                    color: "white"
                    font.pixelSize: 20
                    anchors.fill: parent
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
            }
        }
        Rectangle{
            id: id_title_bg
            width: id_delegate_item.width
            anchors.top: id_delegate_item.bottom
            height: 22
            color: "black"
            clip: true
            YShadowText {
                id: id_item_title
                anchors.horizontalCenter: id_title_bg.horizontalCenter
                anchors.verticalCenter: id_title_bg.verticalCenter
                anchors.horizontalCenterOffset: jumpType===2 ? 20 : 0
                height: id_title_bg.height
                font.pixelSize: 22
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                elide: YText.ElideRight
                text: getAlbumTitle()
                textFormat:Text.RichText

                function getAlbumTitle(){
                    if(id_album_title.visible){
                        if(title.length > 5) return title.substring(0,4)
                        return title
                    }else{
                        if(title.length > 6) return title.substring(0,5)
                        return title
                    }
                }
            }

            Rectangle{
                id:id_album_title
                width: 40
                height: id_title_bg.height;
                color: "red"
                anchors.right: id_item_title.left
                anchors.rightMargin: 4
                anchors.verticalCenter: id_item_title.verticalCenter
                radius: 7
                visible: jumpType===2 //albumCount > 0
                YShadowText {
                    anchors.fill: parent
                    font.pixelSize: 15
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    elide: YText.ElideRight
                    text: YXmlyTranslateText.albumIdentity
                }
            }
        }
    }
}

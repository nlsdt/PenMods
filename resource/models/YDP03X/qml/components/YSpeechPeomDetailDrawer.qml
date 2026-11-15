import QtQuick 2.12
import com.youdao.pen 1.0

import BaseQml 1.0

YDrawerLayer {
    id: id_drawer_layer
    indicatorLeftMargin: 16
    indicatorRightMargin: 58
    drawerContainerRightMargin: 40
    containerWidth: id_column.width

    property var title;
    property var detail;

    Flickable{
        id: id_flickable
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        width: 500
        contentHeight: id_column.height
        Column {
            id: id_column
            anchors.left: parent.left
            anchors.right: parent.right
            width: 400
            YSpacingForColumn {
                implicitHeight: 24
            }

            YTextCH {
                id: id_title
                color: "#ffffff"
                font.pixelSize: 32
                anchors.left: parent.left
                anchors.leftMargin: 4
                anchors.right: parent.right
                anchors.rightMargin: 20
                wrapMode: YTextBase.Wrap
                font.bold: true
                textFormat : YTextBase.RichText
                text: title
                onVisibleChanged: {
                    if (visible) {
                        //speechManager.saveSpeechDebugInfo("dictpenResDetail: " + title)
                    }
                }


            }

            YSpacingForColumn {
                implicitHeight: 16
            }
            YTextCH {
                id: id_detail
                color: "#ffffff"
                font.pixelSize: 28
                anchors.left: parent.left
                anchors.leftMargin: 4
                anchors.right: parent.right
                anchors.rightMargin: 20
                wrapMode: YTextBase.Wrap
                textFormat : YTextBase.RichText
                text: detail
                onVisibleChanged: {
                    if (visible) {
                        //speechManager.saveSpeechDebugInfo("dictpenResDetail: " + detail)
                    }
                }



            }
        }
    }



}

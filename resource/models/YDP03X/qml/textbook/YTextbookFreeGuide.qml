import QtQuick 2.12
import com.youdao.pen 1.0

import BaseQml 1.0
import "../i18n"

YBackgroundIgnoreMouseEvent {
    id: id_textbook_operation_item
    objectName: "YTextbookFreeGuide.qml"
    anchors.fill: parent

    Row {
        anchors.fill: parent
        anchors.leftMargin: 90
        spacing: 30

        YImage {
            id: id_free_guide_wx_public_qrcode
            sourceSize: Qt.size(210, 210)
            anchors.verticalCenter: parent.verticalCenter
            imageName: "textbook/youdao_wx_public"
        }

        YImage {
            id: id_free_guide_wx_public_brief
            sourceSize: Qt.size(430, 194)
            imageName: "textbook/youdao_public_brief"
            anchors.verticalCenter: parent.verticalCenter
        }
    }


    YVerticalTitleBar {
        onCallBack: {
           id_textbook_operation_item.visible = false
        }
        objectName: "YBackButtonPage.qml_" + id_textbook_operation_item.objectName
    }

    Component.onCompleted: {

    }
}


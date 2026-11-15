import QtQuick 2.12
import BaseQml 1.0

import XmPresenter 1.0
import "i18n"

YBackButtonPage {
    id: id_qrcode_info_root

    property alias title: id_qrcode_info_title.title
    property alias tip: id_dict_scan_tip.text
    property alias qrCode: id_qrcode_icon.source

    YXmlyTextTitle {
        id: id_qrcode_info_title
        anchors.left: parent.left
        anchors.leftMargin: 90
    }

    Item {
        anchors.fill: parent
        anchors.leftMargin: 90
        YImage {
            id: id_dict_logo
            imageName: "3rdpart/xmly/ic_ting"
            sourceSize: Qt.size(50, 50)
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.topMargin: 100
        }

        YText {
            id: id_qrcode_main_text
            font.pixelSize: 37
            font.weight: Font.DemiBold
            font.family: fontManager.fontFamilyZhCn
            textFormat: YText.RichText
            text: YXmlyTranslateText.xmlyChildrenApp
            anchors.left: id_dict_logo.right
            anchors.leftMargin: 10
            anchors.verticalCenter: id_dict_logo.verticalCenter
        }

        YText {
            id: id_dict_scan_tip
            width: 470
            anchors.left: id_dict_logo.left
            anchors.top: id_dict_logo.bottom
            anchors.topMargin: 17
            wrapMode: YTextBase.Wrap
            font.pixelSize: 26
            color: YColors.grayText
            textFormat: YText.RichText
        }
    }

    Rectangle {
        implicitWidth: 174
        implicitHeight: 174
        radius: 16
        color: id_qrcode_icon_default.visible ? YColors.grayNormal : YColors.white
        anchors.verticalCenter: parent.verticalCenter
        anchors.right: parent.right
        anchors.rightMargin: 44

        YImageBase {
            id: id_qrcode_icon
            anchors.centerIn: parent
            width: 160
            height: 160
        }

        YImage {
            id: id_qrcode_icon_default
            anchors.centerIn: parent
            sourceSize: Qt.size(94, 50)
            imageName: "3rdpart/xmly/login-default-qr"
            visible: !id_qrcode_icon.visible
        }
    }

    onVisibleChanged: {
        if (visible) {
            xmLogManager.showPage(XmTrace.PageUserProtocol,
                                  JSON.stringify({"pageType": title}))
        } else {
            xmLogManager.hidePage(XmTrace.PageUserProtocol,
                                  JSON.stringify({"pageType": title}))
        }
    }
}

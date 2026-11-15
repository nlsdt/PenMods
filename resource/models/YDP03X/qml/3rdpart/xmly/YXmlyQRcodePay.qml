import QtQuick 2.12
import BaseQml 1.0

import XmPresenter 1.0
import "i18n"

YBackButtonPage {
    id: id_qrcode_pay_root

    property int sourceId: 0
    property string title: ""
    property string qrCode: ""
    property bool isLoginPage: false

    XmQRCodePresenter {
        id: qrcodePresenter
    }

    YXmlyTextTitle {
        id: id_qrcode_pay_title
        anchors.left: parent.left
        anchors.leftMargin: 90
        visible: !isLoginPage
        title: xmAccountManager.hasLogin() ? xmAccountManager.getNickname(
                                                 ) : YXmlyTranslateText.notLogin
    }

    YLoader {
        id: id_content_loader
        anchors.fill: parent
        anchors.leftMargin: 90
    }

    Component {
        id: id_pay_for_album
        Item {
            YXmlyRoundedImage {
                id: id_album_cover
                anchors.left: parent.left
                anchors.top: parent.top
                anchors.topMargin: 80
                width: 50
                height: 50
                radius: 8
                source: qrcodePresenter.getAlbumImgUrl()
                YImage {
                    id: id_icon_default
                    anchors.fill: parent
                    sourceSize: Qt.size(parent.width, parent.height)
                    imageName: "3rdpart/xmly/ic_ting"
                    visible: !id_album_cover.isLoaded
                }
            }

            YText {
                id: id_qrcode_main_text
                width: 400
                font.pixelSize: 32
                font.weight: Font.DemiBold
                font.family: fontManager.fontFamilyZhCn
                // RichText 不兼容 elide 属性
//                textFormat: YText.RichText
                elide: Text.ElideRight
                text: qrcodePresenter.getAlbumTitle()
                anchors.left: id_album_cover.right
                anchors.leftMargin: 10
                anchors.top: id_album_cover.top
            }

            Column {
                width: 400
                anchors.left: id_qrcode_main_text.left
                anchors.top: id_qrcode_main_text.bottom
                anchors.topMargin: 16
                spacing: 16

                Item {
                    width: 400
                    height: 32
                    visible: !xmAccountManager.isAccountVip()
                    id: id_album_price
                    YText {
                        id: id_album_price_label
                        font.pixelSize: 24
                        color: YColors.white
                        textFormat: YText.RichText
                        text: YXmlyTranslateText.albumPrice
                    }

                    YText {
                        id: id_album_price_value
                        anchors.left: parent.left
                        anchors.leftMargin: 150
                        anchors.verticalCenter: id_album_price_label.verticalCenter
                        font.pixelSize: 24
                        color: YColors.white
                        textFormat: YText.RichText
                        text: "￥" + qrcodePresenter.getAlbumPrice()
                    }
                }

                Item {
                    width: 400
                    height: 32
                    id: id_album_price_vip
                    YText {
                        id: id_album_price_vip_label
                        font.pixelSize: 24
                        color: "#ff7422"
                        textFormat: YText.RichText
                        text: YXmlyTranslateText.albumPriceVip
                    }

                    YText {
                        id: id_album_price_vip_value
                        anchors.left: parent.left
                        anchors.leftMargin: 150
                        anchors.verticalCenter: id_album_price_vip_label.verticalCenter
                        font.pixelSize: 24
                        color: "#ff7422"
                        textFormat: YText.RichText
                        text: "￥" + qrcodePresenter.getAlbumVipPrice()
                    }
                }

                Item {
                    width: 400
                    height: 32
                    id: id_album_price_origin
                    visible: !id_album_price.visible
                    YText {
                        id: id_album_price_origin_label
                        font.pixelSize: 24
                        color: YColors.grayText
                        textFormat: YText.RichText
                        text: YXmlyTranslateText.albumPriceOrigin
                    }

                    YText {
                        id: id_album_price_origin_value
                        anchors.left: parent.left
                        anchors.leftMargin: 150
                        anchors.verticalCenter: id_album_price_origin_label.verticalCenter
                        font.pixelSize: 24
                        color: YColors.grayText
                        font.strikeout: true
                        textFormat: YText.RichText
                        text: "￥" + qrcodePresenter.getAlbumPrice()
                    }
                }
            }
        }
    }

    Component {
        id: id_pay_for_vip
        Item {
            YImage {
                id: id_dict_logo
                imageName: "3rdpart/xmly/ic_ting"
                sourceSize: Qt.size(50, 50)
                anchors.left: parent.left
                anchors.top: parent.top
                anchors.topMargin: isLoginPage ? 80 : 100
            }

            YText {
                id: id_qrcode_main_text
                width: 400
                anchors.left: id_dict_logo.right
                anchors.leftMargin: 10
                anchors.verticalCenter: id_dict_logo.verticalCenter
                elide: Text.ElideRight
                font.pixelSize: 37
                font.weight: Font.DemiBold
                font.family: fontManager.fontFamilyZhCn
                text: qrcodePresenter.getQRCodeTitle()
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
                text: qrcodePresenter.getQRCodeDesc()
            }
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
            source: qrCode
            visible: qrCode.length > 0
        }

        YImage {
            id: id_qrcode_icon_default
            anchors.centerIn: parent
            sourceSize: Qt.size(94, 50)
            imageName: "3rdpart/xmly/login-default-qr"
            visible: !id_qrcode_icon.visible
        }
    }

    Connections {
        target: qrcodePresenter
        function onLoadQRCodeSuccess() {
            qrCode = qrcodePresenter.getQRCodeURL()
        }
        function onLoadSuccess() {
            if (isLoginPage) {
                backButtonClicked()
                showPage("3rdpart/xmly/YXmlyLoginPage")
            } else {
                backButtonClicked()
            }
        }
        function onLoadFailure(errorCode, errorMsg) {
            backButtonClicked()
            baseSignals.showToast(YXmlyTranslateText.loadingError(errorCode), YColors.grayNormal)
        }
        function onNetworkSlow(level) {
            console.warn("onNetworkSlow " + level)
            if (level >= 3) {
                baseSignals.showToast(YXmlyTranslateText.networkSlow, YColors.grayNormal)
            }
        }
    }

    Connections {
        target: xmAccountManager
        function onLogin() {
            id_qrcode_pay_title.title = xmAccountManager.getNickname()
        }
    }

    Component.onCompleted: {
        console.log("sourcId = " + sourceId)
        qrcodePresenter.setQRCodeType(sourceId)
        qrcodePresenter.setQRCodeContent(title)
        qrcodePresenter.start()

        if (sourceId === 2) {
            id_content_loader.sourceComponent = id_pay_for_album
        } else {
            id_content_loader.sourceComponent = id_pay_for_vip
        }
        id_content_loader.active = true
    }

    onVisibleChanged: {
        if (visible) {
            xmLogManager.showQRCodePage(sourceId, title)
        } else {
            xmLogManager.hideQRCodePage(sourceId, title)
        }
    }
}

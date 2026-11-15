import QtQuick 2.12
import BaseQml 1.0
import XmPresenter 1.0
import "i18n"

YBackButtonPage {
    id: id_login_page_root

    property bool isExpiredVip: !xmAccountManager.isAccountVip()
                                && xmAccountManager.getVipExpiryTime() !== ""

    property bool isNeverVip: xmAccountManager.getVipExpiryTime() === ""

    property bool logout_bg_isVisible: false

    Flickable {
        id: id_logged_in_loader
        anchors.fill: parent
        anchors.leftMargin: 90
        anchors.rightMargin: 16
        contentHeight: id_column.height
        clip: true
        Column {
            id: id_column
            anchors.left: parent.left
            anchors.right: parent.right
            spacing: 10

            YXmlyTextTitle {
                height: 70
                title: YXmlyTranslateText.accountInfo
            }

            YXmlyListItemBackground {
                id: id_user_icon_bg

                YXmlyRoundedImage {
                    id: id_user_icon
                    width: 50
                    height: 50
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.leftMargin: 20
                    source: xmAccountManager.getAvatarUrl()

                    YXmlyRoundedImage {
                        anchors.fill: parent
                        source: "image://icons/3rdpart/xmly/ic_personal_off.png"
                        visible: !id_user_icon.isLoaded
                    }
                }

                YText {
                    id: id_user_nickname
                    width: Math.min(150, contentWidth)
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: id_user_icon.right
                    anchors.leftMargin: 10
                    text: xmAccountManager.getNickname()
                    color: YColors.white
                    font.pixelSize: 28
                    visible: text.length > 0
                    elide: contentWidth > width ? YText.ElideRight : YText.ElideNone
                }

                YText {
                    id: id_user_uid
                    text: "(" + xmAccountManager.getUid() + ")"
                    color: YColors.grayText
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: id_user_nickname.right
                    font.pixelSize: 26
                    visible: text.length > 0
                }

                YImage {
                    id: id_vip_logo
                    anchors.left: id_user_uid.right
                    anchors.leftMargin: 4
                    anchors.verticalCenter: parent.verticalCenter
                    sourceSize: Qt.size(44, 44)
                    imageName: isExpiredVip ? "3rdpart/xmly/ic_vip_gray" : "3rdpart/xmly/ic_vip_light"
                    visible: !isNeverVip
                }

                YText {
                    id: id_user_vip_period
                    text: xmAccountManager.getVipExpiryTime() + "到期"
                    color: YColors.white
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.right: parent.right
                    anchors.rightMargin: 20
                    font.pixelSize: 26
                    visible: xmAccountManager.isAccountVip()
                }

                YImageButton {
                    id: id_open_vip_arrow
                    anchors.right: parent.right
                    anchors.rightMargin: 20
                    anchors.verticalCenter: parent.verticalCenter
                    sourceSize: Qt.size(36, 36)
                    mouseAreaMargins: -10
                    imageName: "3rdpart/xmly/list_ic_arrow_more"
                    visible: !id_user_vip_period.visible
                    onClicked: id_open_vip_button.clicked()
                }

                YButton {
                    id: id_open_vip_button
                    anchors.right: id_open_vip_arrow.left
                    anchors.rightMargin: 10
                    implicitWidth: 85
                    pixelSize: 24
                    text: isNeverVip ? YXmlyTranslateText.openVip : YXmlyTranslateText.renewVip
                    textColor: "#ff7422"
                    color: YColors.grayNormal
                    visible: id_open_vip_arrow.visible
                    onClicked: {
                        showPage("3rdpart/xmly/YXmlyQRcodePay", false, {
                                     "sourceId": 1
                                 })
                        xmLogManager.clickEvent(XmTrace.ClickAccountInfoVip)
                    }
                }
            }

            YXmlyListItemBackground {
                id: id_user_contract

                YText {
                    id: id_user_contract_text
                    text: YXmlyTranslateText.userContract
                    color: YColors.white
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.leftMargin: 20
                    font.pixelSize: 28
                    visible: text.length > 0
                }

                YImageButton {
                    id: id_user_contract_arrow
                    anchors.right: parent.right
                    anchors.rightMargin: 20
                    anchors.verticalCenter: parent.verticalCenter
                    sourceSize: Qt.size(36, 36)
                    mouseAreaMargins: -10
                    imageName: "3rdpart/xmly/list_ic_arrow_more"
                }

                YMouseArea {
                    anchors.fill: parent
                    onClicked: {
                        showPage("3rdpart/xmly/YXmlyQRcodeInfo", false, {
                                     "title": YXmlyTranslateText.userContract,
                                     "tip": YXmlyTranslateText.userContractTip,
                                     "qrCode": xmSDK.getUserServiceProtocolUrl()
                                 })
                    }
                }
            }

            YXmlyListItemBackground {
                id: id_vip_contract

                YText {
                    id: id_vip_contract_text
                    text: YXmlyTranslateText.vipContract
                    color: YColors.white
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.leftMargin: 20
                    font.pixelSize: 28
                    visible: text.length > 0
                }

                YImageButton {
                    id: id_vip_contract_arrow
                    anchors.right: parent.right
                    anchors.rightMargin: 20
                    anchors.verticalCenter: parent.verticalCenter
                    sourceSize: Qt.size(36, 36)
                    mouseAreaMargins: -10
                    imageName: "3rdpart/xmly/list_ic_arrow_more"
                }

                YMouseArea {
                    anchors.fill: parent
                    onClicked: {
                        showPage("3rdpart/xmly/YXmlyQRcodeInfo", false, {
                                     "title": id_vip_contract_text.text,
                                     "tip": YXmlyTranslateText.vipContractTip,
                                     "qrCode": xmSDK.getMemberProtocolUrl()
                                 })
                    }
                }
            }

            YXmlyListItemBackground {
                id: id_version

                YText {
                    id: id_version_text
                    text: YXmlyTranslateText.version
                    color: YColors.white
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.leftMargin: 20
                    font.pixelSize: 28
                    visible: text.length > 0
                }

                YText {
                    id: id_version_dig
                    anchors.right: parent.right
                    anchors.rightMargin: 20
                    anchors.verticalCenter: parent.verticalCenter
                    font.pixelSize: 28
                    visible: text.length > 0
                    text: "v" + xmSDK.getVersionName()
                }
            }

            YButton {
                anchors.left: parent.left
                anchors.right: parent.right
                implicitHeight: 80
                radius: 16
                color: pressed ? "#111216" : YColors.grayNormal
                text: YXmlyTranslateText.logout
                textColor: YColors.red
                onClicked: {
                    if (typeof wifiManager !== "undefined" && !wifiManager.isOnline()) {
                        baseSignals.showToast(YXmlyTranslateText.networkBroken,
                                              YColors.grayNormal)
                        return
                    }
                    logout_bg_isVisible = true
                }
            }

            Item {
                id: footer_span
                width: parent.width
                height: 12
            }
        }
    }
    Rectangle{
        id:id_logout_bg
        anchors.fill: parent
        color: "black"
        visible: logout_bg_isVisible
        MouseArea{
            anchors.fill: parent
            onPressed:{
                mouse.accepted = true
            }
        }

        YText {
            id: id_tip_text
            font.pixelSize: 28
            font.family: fontManager.fontFamilyZhCn
            width: parent.width
            anchors.centerIn: parent
            horizontalAlignment: YText.AlignHCenter
            verticalAlignment: YText.AlignVCenter
            wrapMode: YText.Wrap
            textFormat: Text.RichText
            text: YXmlyTranslateText.logoutWillNotBeAbleToSync
        }
        YButton {
            anchors.bottom: id_logout_bg.bottom
            anchors.horizontalCenter: id_logout_bg.horizontalCenter
            anchors.bottomMargin:10
            implicitWidth: 320
            text: YXmlyTranslateText.logout
            onClicked: {
                xmAccountManager.logoutAccount()
                xmLogManager.clickEvent(XmTrace.ClickAccountInfoLogout)
                logout_bg_isVisible = false
            }
        }
        YIconButton {
            id: id_close_button
            implicitWidth: 44
            implicitHeight: 44
            radius: height/2
            color: YColors.grayNormal
            mouseAreaMargins: -22
            imageName: "3rdpart/xmly/close"
            anchors.top: parent.top
            anchors.topMargin: 18
            anchors.left: parent.left
            anchors.leftMargin: 16
            onClicked: {
                logout_bg_isVisible = false
            }
        }

    }
    Connections {
        target: xmAccountManager
        function onLogin() {}
        function onLogout() {
            backButtonClicked()
        }
        function onPurchase() {
            isExpiredVip = !xmAccountManager.isAccountVip()
                    && xmAccountManager.getVipExpiryTime() !== ""
            isNeverVip = xmAccountManager.getVipExpiryTime() === ""
            id_user_vip_period.text = xmAccountManager.getVipExpiryTime() + "到期"
            id_user_vip_period.visible = xmAccountManager.isAccountVip()
        }
    }

    Component.onCompleted: {

    }

    onVisibleChanged: {
        if (visible) {
            xmLogManager.showPage(XmTrace.PageAccountInfo)
        } else {
            xmLogManager.hidePage(XmTrace.PageAccountInfo)
        }
    }
}

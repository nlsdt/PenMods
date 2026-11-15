import QtQuick 2.12

import BaseQml 1.0

YXmlyRoundedImage {
    id: id_user_icon
    width: 42
    height: 42

    signal iconClicked

    onVisibleChanged: {
        if (visible) {
            source = xmAccountManager.hasLogin(
                        ) ? xmAccountManager.getAvatarUrl(
                                ) : "image://icons/3rdpart/xmly/ic_personal_off.png"
        }
    }

    YXmlyRoundedImage {
        anchors.fill: parent
        source: "image://icons/3rdpart/xmly/ic_personal_off.png"
        visible: !id_user_icon.isLoaded
    }

    YMouseArea {
        anchors.fill: parent
        anchors.margins: -25
        onClicked: {
            if (!xmAccountManager.hasLogin()) {
                showPage("3rdpart/xmly/YXmlyQRcodePay", false, {
                             "sourceId": 3,
                             "isLoginPage": true
                         })
            } else {
                showPage("3rdpart/xmly/YXmlyLoginPage")
            }
            id_user_icon.iconClicked()
        }
    }
}

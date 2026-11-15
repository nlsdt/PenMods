import QtQuick 2.12
import BaseQml 1.0
import com.youdao.pen 1.0
import XmPresenter 1.0
import "i18n"

YBackButtonPage {
    id: id_personal_record

    YXmlyUserAvatar {
        id: id_user_icon
        anchors.left: parent.left
        anchors.leftMargin: 17
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 18
        onIconClicked: {
            if (!xmAccountManager.hasLogin()) {
                xmLogManager.clickEvent(XmTrace.ClickUserCenterLogin,
                                            JSON.stringify({"itemType": "userIcon"}))
            } else {
                xmLogManager.clickEvent(XmTrace.ClickUserCenterUserIcon)
            }
        }
    }

    Grid {
        id: id_personal_record_grid
        anchors.fill: parent
        anchors.leftMargin: 90
        anchors.rightMargin: 20
        anchors.topMargin: 16
        anchors.bottomMargin: 16
        clip: true
        columns: 2
        rowSpacing: 12
        columnSpacing: 10

        Repeater {
            model: id_content_model
            Rectangle {
                width: 339
                height: 106
                radius: 16
                color: YColors.grayNormal

                YImage {
                    anchors.left: parent.left
                    anchors.leftMargin: 20
                    anchors.verticalCenter: parent.verticalCenter
                    sourceSize: Qt.size(50, 50)
                    imageName: icon
                }

                YText {
                    anchors.left: parent.left
                    anchors.leftMargin: 90
                    anchors.verticalCenter: parent.verticalCenter
                    text: name
                }

                YMouseArea {
                    anchors.fill: parent
                    onClicked: {
                        if (index !== 0 && !xmAccountManager.hasLogin()) {
                            showPage("3rdpart/xmly/YXmlyQRcodePay", false, {
                                         "sourceId": 3,
                                         "isLoginPage": true
                                     })
                            const PAGE_NAMES = ["", "subscription", "playHistory", "purchased"]
                            xmLogManager.clickEvent(XmTrace.ClickUserCenterLogin,
                                                    JSON.stringify({"itemType": PAGE_NAMES[index]}))
                            return
                        }
                        switch (index) {
                        case 0:
                            if (xmPlayerManager.play()) {
                                baseSignals.showAudioPlayer()
                            } else {
                                baseSignals.showToast(YXmlyTranslateText.tipNotPlaying, YColors.grayNormal)
                            }
                            xmLogManager.clickEvent(XmTrace.ClickUserCenterPlayer)
                            break
                        case 1:
                            showPage("3rdpart/xmly/YXmlySubscribe")
                            xmLogManager.clickEvent(XmTrace.ClickUserCenterSubscription)
                            break
                        case 2:
                            showPage("3rdpart/xmly/YXmlyHistory")
                            xmLogManager.clickEvent(XmTrace.ClickUserCenterPlayHistory)
                            break
                        case 3:
                            showPage("3rdpart/xmly/YXmlyPurchased")
                            xmLogManager.clickEvent(XmTrace.ClickUserCenterPurchased)
                            break
                        }
                    }
                }
            }
        }

        ListModel {
            id: id_content_model

            Component.onCompleted: {
                append({
                           "name": YXmlyTranslateText.playing,
                           "icon": "3rdpart/xmly/ic_center_playing"
                       })
                append({
                           "name": YXmlyTranslateText.myCollection,
                           "icon": "3rdpart/xmly/ic_center_college"
                       })
                append({
                           "name": YXmlyTranslateText.playHistory,
                           "icon": "3rdpart/xmly/ic_center_history"
                       })
                append({
                           "name": YXmlyTranslateText.bought,
                           "icon": "3rdpart/xmly/ic_center_my"
                       })
            }
        }
    }

    onVisibleChanged: {
        if (visible) {
            xmLogManager.showPage(XmTrace.PageUserCenter)
        } else {
            xmLogManager.hidePage(XmTrace.PageUserCenter)
        }
    }
}

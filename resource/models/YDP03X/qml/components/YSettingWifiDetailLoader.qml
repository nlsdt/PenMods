import QtQuick 2.12

import BaseQml 1.0
import "../i18n"

YLoader {
    id: id_connect_wifi_loader
    anchors.fill: parent

    property string wifiName: ""

    sourceComponent: YBackgroundIgnoreMouseEvent {

        Item {
            id: id_title_bar
            anchors.left: parent.left
            anchors.right: parent.right
            implicitHeight: 80

            YText {
                font.pixelSize: 26
                color: YColors.grayText
                anchors.verticalCenter: parent.verticalCenter
                text: YTranslateText.configWifi
            }
        }

        YSettingItemBackground {
            id: id_connect_wifi_item
            implicitHeight: 80
            anchors.top: id_title_bar.bottom

            Column {
                anchors.left: parent.left
                anchors.leftMargin: 20
                anchors.right: id_connect_wifi_icon.left
                anchors.rightMargin: 34
                anchors.verticalCenter: parent.verticalCenter
                spacing: 8

                YTextMedium {
                    text: wifiName
                    anchors.left: parent.left
                    anchors.right: parent.right
                    elide: YText.ElideRight
                }

                YText {
                    font.pixelSize: 24
                    color: YColors.grayText
                    text: YTranslateText.connectSuccess
                }
            }

            YImage {
                id: id_connect_wifi_icon
                anchors.right: parent.right
                anchors.rightMargin: 20
                anchors.verticalCenter: parent.verticalCenter
                sourceSize: Qt.size(44, 44)
                imageName: "settings/st-check"
            }
        }

        onClicked: {
            id_connect_wifi_loader.active = false
        }

        YButton {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: id_connect_wifi_item.bottom
            anchors.topMargin: 10
            text: YTranslateText.ignoreThisWifi
            onClicked: {
                wifiManager.ignore(wifiName)
                active = false
            }
        }
    }
}

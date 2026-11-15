import QtQuick 2.12

import BaseQml 1.0
import "../settingpages"
import "../i18n"

YBackButtonPage {
    anchors.fill: parent
    destroyOnBack: false

    Flickable {
        anchors.fill: parent
        anchors.leftMargin: 90
        anchors.rightMargin: 16
        contentHeight: id_column.height
        Column {
            id: id_column
            spacing: 0
            anchors.left: parent.left
            anchors.right: parent.right

            YSettingItemTitle {
                title: YTranslateText.connectYdDict
            }

            YText {
                font.pixelSize: 26
                anchors.left: parent.left
                anchors.right: parent.right
                wrapMode: YTextBase.Wrap
                text: YTranslateText.connectYdDictTip1
                height: contentHeight
            }

            YSpacingForColumn {
                implicitHeight: 12
            }

            YSpacingForColumn {
                implicitHeight: 140
                YImage {
                    sourceSize: Qt.size(694, 188)
                    imageName: "login/tip_0"
                    anchors.centerIn: parent
                }
            }

            YSpacingForColumn {
                implicitHeight: 40
            }

            YText {
                font.pixelSize: 26
                anchors.left: parent.left
                anchors.right: parent.right
                wrapMode: YTextBase.Wrap
                text: YTranslateText.connectYdDictTip2
                height: contentHeight
            }

            YSpacingForColumn {
                implicitHeight: 12
            }

            YImage {
                sourceSize: Qt.size(694, 140)
                imageName: "login/tip_3"
                anchors.left: parent.left
                anchors.right: parent.right
                height: 140
            }

            YSpacingForColumn {
                implicitHeight: 40
            }

            YText {
                font.pixelSize: 26
                anchors.left: parent.left
                anchors.right: parent.right
                wrapMode: YTextBase.Wrap
                text: YTranslateText.connectYdDictTip3
                height: contentHeight
            }

            YSpacingForColumn {
                implicitHeight: 40
            }

            YText {
                font.pixelSize: 26
                anchors.left: parent.left
                anchors.right: parent.right
                wrapMode: YTextBase.Wrap
                text: YTranslateText.connectYdDictTip4
                height: contentHeight
            }

            YSpacingForColumn {
                implicitHeight: 40
            }
        }
    }
    onBackButtonClicked: close()
}

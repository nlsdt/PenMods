import QtQuick 2.12
import com.youdao.pen 1.0

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
                titleFontFamily: fontManager.fontFamilyZhCn
                title: YTranslateText.loginYdLearningApp
            }

            YText {
                font.pixelSize: 26
                font.family: fontManager.fontFamilyZhCn
                anchors.left: parent.left
                anchors.right: parent.right
                wrapMode: YTextBase.Wrap
                text: YTranslateText.loginYdLearningAppTip1
                height: contentHeight
            }

            YSpacingForColumn {
                implicitHeight: 12
            }

            YImage {
                sourceSize: Qt.size(694, 140)
                imageName: "login/tip_6"
                anchors.left: parent.left
                anchors.right: parent.right
                height: 140
            }

            YSpacingForColumn {
                implicitHeight: 40
            }

            YText {
                font.pixelSize: 26
                font.family: fontManager.fontFamilyZhCn
                anchors.left: parent.left
                anchors.right: parent.right
                wrapMode: YTextBase.Wrap
                text: YTranslateText.loginYdLearningAppTip2
                height: contentHeight
            }

            YSpacingForColumn {
                implicitHeight: 12
            }


            YSpacingForColumn {
                id: id_tip
                implicitHeight: 140
                anchors.left: parent.left
                anchors.right: parent.right

                YImage {
                    sourceSize: Qt.size(694, 140)
                    imageName: "login/tip_5"
                    anchors.centerIn: parent

                    YClickedCountMouseArea {
                        anchors.fill: parent
                        onTriggered: {
                            showPageByVerfyState(YEnum.Verify_Verifying)
                            verifyManager.startVerify()
                        }
                    }
                }
            }

            YSpacingForColumn {
                implicitHeight: 40
            }

            YText {
                font.pixelSize: 26
                font.family: fontManager.fontFamilyZhCn
                anchors.left: parent.left
                anchors.right: parent.right
                wrapMode: YTextBase.Wrap
                text: YTranslateText.loginYdLearningAppTip3
                height: contentHeight
            }

            YSpacingForColumn {
                implicitHeight: 50
            }
        }
    }

    onBackButtonClicked: close()
}

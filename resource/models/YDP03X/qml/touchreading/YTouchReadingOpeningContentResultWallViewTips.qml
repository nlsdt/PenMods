import QtQuick 2.12

import BaseQml 1.0
import "../i18n"

YTouchReadingPageOpeningItem {
    id: id_opening_content_result_wall_view_tips
    backButtonIcon: "touchreading/medal_set_back"

    Flickable {
        clip: true
        anchors.fill: parent
        anchors.leftMargin: 58
        anchors.rightMargin: 58
        contentHeight: id_col.height

        Column {
            id: id_col
            spacing: 0
            anchors.left: parent.left
            anchors.right: parent.right

            YSpacingForColumn {
                implicitHeight: 40
            }

            Row {
                anchors.horizontalCenter: parent.horizontalCenter
                height: 34
                spacing: 30

                YImage {
                    anchors.verticalCenter: parent.verticalCenter
                    sourceSize: Qt.size(48, 17)
                    imageName: "touchreading/tip_left"
                }

                YTextBase {
                    id: id_tip_txt_icon
                    height: 34
                    font.pixelSize: 34
                    font.family: fontManager.fontFamilyPinyin
                    font.weight: Font.Bold
                    color: "#FFFFFF"
                    text: "TIPS"
                }

                YImage {
                    anchors.verticalCenter: parent.verticalCenter
                    sourceSize: Qt.size(48, 17)
                    imageName: "touchreading/tip_right"
                }
            }

            YSpacingForColumn {
                implicitHeight: 24
            }

            Repeater {
                model: 3
                delegate: Column {
                    anchors.left: id_col.left
                    anchors.right: id_col.right
                    spacing: 2

                    Rectangle {
                        implicitWidth: 8
                        implicitHeight: 4
                        radius: height/2
                        color: "#644FEC"
                    }

                    YText {
                        anchors.left: parent.left
                        anchors.right: parent.right
                        font.pixelSize: 22
                        font.family: fontManager.fontFamilyZhCn
                        wrapMode: YTextBase.Wrap
                        opacity: 0.6
                        text: {
                            switch (index) {
                            case 0:
                                return YTranslateText.starGetRuleTip1
                            case 1:
                                return YTranslateText.starGetRuleTip2
                            case 2:
                                return YTranslateText.starGetRuleTip3
                            default:
                                return ""
                            }
                        }
                    }

                    YSpacingForColumn {
                        implicitHeight: 18
                    }
                }
            }
        }
    }

    onBackButtonClicked: {
        id_opening_content_result_wall_view_tips.hide()
        id_opening_content_result_wall_view_tips.destroy()
    }
}

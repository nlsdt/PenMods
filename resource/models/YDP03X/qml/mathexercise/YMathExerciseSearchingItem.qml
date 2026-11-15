import QtQuick 2.12
import com.youdao.pen 1.0

import BaseQml 1.0
import "../i18n"

Flickable {
    id: id_container_flickable
    anchors.fill: parent
    anchors.leftMargin: 90
    anchors.rightMargin: 80
    contentHeight: id_searching_content_col.height

    property var content: ""
    property var containWidth: 694

    contentY: (contentHeight > YBaseEnum.Screen.Height)
              ? contentHeight - YBaseEnum.Screen.Height : 0

    Column {
        id: id_searching_content_col
        anchors.left: parent.left
        anchors.right: parent.right
        spacing: 0

        YSpacingForColumn {
            implicitHeight: 20
        }

        Item {
            id: id_rect_item
            width: id_word_bg.implicitRectWidth
            height: id_word_bg.height
            clip: true

            Rectangle {
                id:id_word_bg

                width: implicitRectWidth
                anchors.left: parent.left
                height: id_calc_small_text.isWarp ? (id_word.contentHeight + 2) : 40
                color: "transparent"

                property int leftAndRightMargin: 8
                property int leftMove: 5
                property int implicitRectWidth: id_word.width
                property int textPixelSize: id_word.font.pixelSize
                property int textLineCount: id_word.lineCount

                YTextBase {
                    id: id_calc_small_text
                    visible: false
                    property bool isWarp: width > containWidth
                    text: content
                    font.family: id_word.font.family
                    font.letterSpacing: id_word.font.letterSpacing
                    width: contentWidth - font.letterSpacing
                    font.weight: id_word.font.weight
                    font.pixelSize: 28
                }

                YTextBase {
                    id: id_word
                    verticalAlignment: Text.AlignVCenter
                    anchors.left: parent.left
                    anchors.leftMargin: 0
                    font.family: fontManager.fontFamily
                    font.letterSpacing: 0
                    textFormat: YText.RichText
                    width: id_calc_small_text.isWarp ? containWidth : id_calc_small_text.width
                    anchors.horizontalCenterOffset: id_calc_small_text.isWarp ? 8 : 0
                    wrapMode: id_calc_small_text.isWarp ? YText.Wrap : YText.NoWrap
                    font.pixelSize: 28
                    color: YColors.white
                    font.weight: Font.Normal
                    text: content

                    Component.onCompleted: {
                        if (contentHeight > parent.height) {
                            anchors.verticalCenter = undefined
                        } else {
                            anchors.verticalCenter = parent.verticalCenter
                        }
                    }
                }
            }
        }

        YSpacingForColumn {
            implicitHeight: 16
        }

        YWaitingTipsText {
            id: id_searching
            anchors.left: parent.left
            horizontalAlignment: Text.AlignLeft
            font.family: fontManager.fontFamilyZhCn
            implicitHeight: 34
            font.pixelSize: 28
            color: YColors.grayText
            font.weight: Font.Normal
            text: YTranslateText.exerciseSearching
            running: false
            visible: true
        }

        YSpacingForColumn {
            implicitHeight: 20
        }
    }
}

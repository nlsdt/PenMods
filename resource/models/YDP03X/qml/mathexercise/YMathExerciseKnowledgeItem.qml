import QtQuick 2.12
import com.youdao.pen 1.0

import BaseQml 1.0
import "../i18n"

Item {
    id: id_exercise_knowledge_title_item
    property alias title: id_content_title.text
    property string content: ""
    property alias imageSource: id_video_icon.imageName
    property bool lineVisible: true

    width: 694
    height: id_result_content_item_col.height

    signal clickToPlayVideo()

    Column {
        id: id_result_content_item_col
        width: parent.width
        spacing: 0

        Row {
            id: id_title_row
            visible: id_exercise_knowledge_title_item.title !== ""
            height: 34
            spacing: 8

            Rectangle {
                anchors.verticalCenter: parent.verticalCenter
                width: 4
                height: 20
                radius: 2
                color: "#F03043"
            }

            YTextBase {
                id: id_content_title
                font.pixelSize: 26
                color: "#A8AAB2"
                height: contentHeight
            }
        }

        YSpacingForColumn {
            implicitHeight: id_title_row.visible ? 16 : 18
        }

        YText {
            lineHeight: 42
            lineHeightMode: Text.FixedHeight
            wrapMode: YText.WordWrap
            height: contentHeight
            width: parent.width
            text: visible ? id_exercise_knowledge_title_item.content : ""
        }

        YSpacingForColumn {
            implicitHeight: id_video_icon.visible ? 18 : 0
        }

        YImage {
            id: id_video_icon
            anchors.horizontalCenter: parent.horizontalCenter
            width: 440
            height: 250
            sourceSize: Qt.size(440, 250)
            visible: imageName !== ""

            YMouseArea {
                anchors.fill: parent
                onClicked: {
                    clickToPlayVideo()
                }
            }
        }

        YSpacingForColumn {
            implicitHeight: 29
            visible: lineVisible
        }

        YExerciseDividingLine {
            sourceSize: Qt.size(694, 2)
            visible: lineVisible
        }

        YSpacingForColumn {
            implicitHeight: 29
            visible: lineVisible
        }
    }
}

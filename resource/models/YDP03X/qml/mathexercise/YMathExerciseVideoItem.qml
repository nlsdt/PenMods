import QtQuick 2.12
import com.youdao.pen 1.0

import BaseQml 1.0
import "../i18n"

Item {
    id: id_video_item
    property alias title: id_content_title.text
    property alias imageSource: id_video_icon.imageName
    property bool lineVisible: true

    signal clickToPlayVideo()

    width: 694
    height: id_video_item_col.height

    Column {
        id: id_video_item_col
        width: parent.width
        spacing: 0

        Row {
            id: id_title_row
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
            implicitHeight: 12
        }

        YImage {
            id: id_video_icon
            anchors.horizontalCenter: parent.horizontalCenter

            width: 440
            height:250
            sourceSize: Qt.size(440, 250)

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

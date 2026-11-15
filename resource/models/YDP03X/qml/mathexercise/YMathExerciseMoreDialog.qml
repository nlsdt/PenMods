import QtQuick 2.12
import com.youdao.pen 1.0

import BaseQml 1.0
import "../i18n"

YImage {
    id: id_more_dialog_bg
    sourceSize: Qt.size(403, 112)
    imageName: "math/exercise-more-dialog"

    property int count: 0
    property int currentIndex: 0

    signal selectResult(var index)

    Row {
        id: id_more_button_row
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        anchors.rightMargin: 15
        height: 100
        Repeater {
            model: id_more_dialog_bg.count

            Item {
                width: 90
                height: 100
                anchors.verticalCenter: parent.verticalCenter
                YImage {
                    anchors.centerIn: parent
                    sourceSize: currentIndex === index ? Qt.size(76, 88) : Qt.size(60, 60)
                    imageName: currentIndex === index ? "math/exercise-green-bg" : "math/exercise-gray-bg"

                    Text {
                        anchors.centerIn: parent
                        width: contentWidth
                        text: index + 1
                        font.pixelSize: 22
                        color: YColors.white
                    }

                    YMouseArea {
                        anchors.fill: parent
                        onClicked: {
                            id_more_dialog_bg.visible = false
                            selectResult(index)
                        }
                    }
                }
            }
        }
    }

    YTextBase {
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 31
        anchors.right: id_more_button_row.left
        anchors.rightMargin: 47 - 15
        font.pixelSize: 28
        color: "black"
        font.family: fontManager.fontFamilyZhCn
        text: "结果"
    }

    YImage {
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 38
        anchors.right: id_more_button_row.left
        anchors.rightMargin: 26 - 15
        sourceSize: Qt.size(1, 24)
        imageName: "math/exercise-rect"
    }
}

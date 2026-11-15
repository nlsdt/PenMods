import QtQuick 2.12
import com.youdao.pen 1.0

import BaseQml 1.0
import "../i18n"

Item {
    id: id_association_item

    property alias title: id_content_title.text
    property bool lineVisible: true
    property var model: null
    property var titleList: [
        "精选例题1",
        "精选例题2",
        "精选例题3"
    ]

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
            visible: false

            Rectangle {
                anchors.verticalCenter: parent.verticalCenter
                width: 4
                height: 20
                radius: 2
                color: "#F03043"
            }

            YTextBase {
                id: id_content_title
                anchors.verticalCenter: parent.verticalCenter
                font.pixelSize: 26
                color: "#A8AAB2"
                height: contentHeight
            }
        }

        Repeater {
            id: id_associated_repeater_container
            model: id_association_item.model
            delegate: Item  {
                id: id_associated_repeater_item
                width: id_association_item.width
                height: id_example_title_row.height + 16 + id_associated_title.height + 12 + 60
                        + (id_dividing_line.visible ? 60 : 0)

                Row {
                    id: id_example_title_row
                    anchors.top: parent.top
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
                        font.pixelSize: 26
                        color: "#A8AAB2"
                        height: contentHeight
                        text: titleList[index]
                    }
                }

                YText {
                    id: id_associated_title
                    anchors.top: id_example_title_row.bottom
                    anchors.topMargin: 16
                    anchors.left: parent.left
                    height: contentHeight
                    width: parent.width
                    font.pixelSize: 28
                    lineHeight: 42
                    lineHeightMode: Text.FixedHeight
                    wrapMode: YText.WordWrap
                    text: model.modelData.text
                }

                YPressedBaseButton {
                    anchors.top: id_associated_title.bottom
                    anchors.topMargin: 12
                    anchors.left: parent.left
                    radius: 16
                    color: YColors.grayNormal
                    implicitWidth: 200
                    implicitHeight: 60

                    YTextMedium {
                        id: id_button_tip
                        anchors.left: parent.left
                        anchors.leftMargin: 30
                        anchors.verticalCenter: parent.verticalCenter
                        horizontalAlignment: Text.AlignHCenter
                        font.pixelSize: 28
                        text: YTranslateText.mathJumpToQuesAnalysis
                        color: "#A8AAB2"
                    }

                    YImage {
                        anchors.right: parent.right
                        anchors.rightMargin: 20
                        anchors.verticalCenter: parent.verticalCenter
                        sourceSize: Qt.size(30, 30)
                        imageName: "math/ic-view-detail"
                    }

                    onClicked: {
                        mathExerciseManager.queryDetail(model.modelData.mathId, model.modelData.mathType, true)
                        logManager.sendHttpLog("action=math_more_click")
                    }
                }

                YExerciseDividingLine {
                    id: id_dividing_line
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: 29
                    sourceSize: Qt.size(694, 2)
                    visible: (index < (id_associated_repeater_container.count - 1)) || lineVisible
                }
            }
        }
    }
}

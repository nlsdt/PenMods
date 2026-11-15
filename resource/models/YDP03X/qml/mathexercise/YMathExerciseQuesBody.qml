import QtQuick 2.12
import com.youdao.pen 1.0

import BaseQml 1.0
import "../i18n"

Item {
    id: id_exercise_ques_body_item
    property int type: 0
    property alias title: id_content_title.text
    property string content: ""
    property bool lineVisible: false
    property bool isSplitNeed: false
    property var strs: null

    width: 694
    height: id_result_content_item_col.height

    signal collectButtonClicked()
    signal editButtonClicked()
    signal showCombineTip()

    function splitOriginQuesBody() {
        strs = new Array
        strs = content.split("\n")
        if (settingManager.isFirstShowCombine && (strs.length > 1)) {
            showCombineTip()
        }

//        for (var i = 0; i < strs.length; i++) {}
    }

    function deleteWrap(index) {
        var ret = ""
        for (var i = 0; i < strs.length; i++) {
            if (i !== 0 && i !== index) {
                ret = ret + "\n"
            }
            ret = ret + strs[i]
        }
        content = ret
        mathExerciseManager.updateCurrentResultModel(content, mathExerciseManager.exerciseResult)
    }

    onContentChanged: {
        if (isSplitNeed && (type === 1)) {
            splitOriginQuesBody()
        }
    }

    Column {
        id: id_result_content_item_col
        width: parent.width
        spacing: 0

        Row {
            id: id_title_row
            visible: id_exercise_ques_body_item.title !== ""
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
            implicitHeight: id_title_row.visible ? 16 : 0
        }

        Image {
            anchors.leftMargin: 20
            anchors.rightMargin: 10
            visible: type === 2
            source: visible ? 'data:image/jpeg;base64,%1'.arg(id_exercise_ques_body_item.content)
                            : ""
        }

        Image {
            anchors.leftMargin: 20
            anchors.rightMargin: 10
            visible: type === 3
            source: visible ? ("file://%1").arg(mathExerciseManager.currentLatexImagePath())
                            : ""
        }

        YText {
            lineHeight: 42
            lineHeightMode: Text.FixedHeight
            wrapMode: YText.WrapAnywhere
            height: contentHeight
            width: parent.width
            visible: (type === 1) && !isSplitNeed
            text: visible ? id_exercise_ques_body_item.content : ""
        }

        Column {
            id: id_origin_quesbody_col
            width: 694
            spacing: 16
            visible: (type === 1) && (strs !== null) && isSplitNeed
            Repeater {
                model: strs
                delegate: Row {
                    height: id_split_text_item.height
                    spacing: 18
                    YImage {
                        anchors.top: parent.top
                        visible: index > 0
                        imageName: "math/ic-combine-btn"
                        sourceSize: Qt.size(40, 40)

                        YMouseArea {
                            anchors.fill: parent

                            onClicked: {
                                id_exercise_ques_body_item.deleteWrap(index)
                                logManager.sendHttpLog("action=math_merge_click")
                            }
                        }
                    }

                    YText {
                        id: id_split_text_item
                        lineHeight: 42
                        lineHeightMode: Text.FixedHeight
                        wrapMode: YText.WrapAnywhere
                        height: contentHeight
                        width: index === 0 ? 694 : 620
                        text: model.modelData
                    }
                }
            }
        }

        YSpacingForColumn {
            implicitHeight: (id_math_exercise_result_item.isOriginMode && isSplitNeed) ? 35 : 12
        }

        Row {
            height: 60
            spacing: 16

            YPressedBaseButton {
                radius: 16
                color: YColors.grayNormal
                implicitWidth: 100 + id_button_tip.width
                implicitHeight: 60

                YImage {
                    anchors.left: parent.left
                    anchors.leftMargin: 26
                    anchors.verticalCenter: parent.verticalCenter
                    sourceSize: Qt.size(30, 30)
                    imageName: mathExerciseManager.isInFavorites ? "math/ic-remove-fav" : "math/ic-add-fav"
                }

                YTextMedium {
                    id: id_button_tip
                    anchors.left: parent.left
                    anchors.leftMargin: 70
                    anchors.verticalCenter: parent.verticalCenter
                    horizontalAlignment: Text.AlignHCenter
                    font.pixelSize: 26
                    text: mathExerciseManager.isInFavorites ? "已加入好题本" : "加入好题本"
                    color: "#A8AAB2"
                }

                onClicked: {
                    if (!mathExerciseManager.isInFavorites) {
                        logManager.sendHttpLog("action=math_fav_click")
                    }
                    collectButtonClicked()
                }
            }

            YIconButton {
                id: id_switch_edit_button_bg
                implicitWidth: 60
                implicitHeight: 60
                mouseAreaMargins: -5
                sourceSize: Qt.size(36, 36)
                imageName: "math/exercise-edit"
                visible: id_math_exercise_result_item.isOriginMode
                onClicked: {
                    editButtonClicked()
                    logManager.sendHttpLog("action=math_edit_click")
                }
            }
        }

        YSpacingForColumn {
            implicitHeight: 29
            visible: lineVisible
        }

        YExerciseDividingLine {
            sourceSize: Qt.size(694, 2)
            visible: lineVisible && !id_math_exercise_result_item.isOriginMode
        }

        YImage {
            anchors.horizontalCenter: parent.horizontalCenter
            sourceSize: Qt.size(694, 28)
            imageName: "math/ic-origin-dividingline"
            visible: lineVisible && id_math_exercise_result_item.isOriginMode
        }

        YSpacingForColumn {
            implicitHeight: 29
            visible: lineVisible
        }
    }
}

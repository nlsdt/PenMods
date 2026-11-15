import QtQuick 2.12
import com.youdao.pen 1.0

import BaseQml 1.0
import "../i18n"

Item {
    id: id_exercise_ques_body_item
    property string content: ""

    property int count: 0
    property var model: null

    width: 485
    height: id_result_content_item_col.height
    anchors.left: parent.left
    anchors.leftMargin: 11

    onCountChanged: {
        console.warn("****************************" + count
                     + "      " + JSON.stringify(mathManager.mathExerciseScorer.scoringProcess))
    }

    Column {
        id: id_result_content_item_col
        width: parent.width
        spacing: 0

        Repeater {
            model: id_exercise_ques_body_item.count

            Item {
                anchors.left: parent.left
                anchors.right: parent.right
                height: 50 + 16

                Rectangle {
                    id: id_answer_index
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter

                    width: 30
                    height: 30
                    radius: height / 2
                    color: "#2D2E33"

                    YTextBase {
                        anchors.centerIn: parent
                        font.pixelSize: 20
                        lineHeight: 27
                        lineHeightMode: Text.FixedHeight
                        wrapMode: YText.WordWrap
                        height: contentHeight
                        width: contentWidth
                        color: "#909199"
                        text: index
                    }
                }

                Rectangle {
                    anchors.left: id_answer_index.right
                    anchors.leftMargin: 16
                    anchors.verticalCenter: parent.verticalCenter
                    width: 386
                    height: 50
                    radius: 8

                    YTextBase {
                        anchors.left: parent.left
                        anchors.verticalCenter: parent.verticalCenter
                        font.pixelSize: 20
                        lineHeight: 27
                        lineHeightMode: Text.FixedHeight
                        wrapMode: YText.WordWrap
                        height: contentHeight
                        width: contentWidth
                        color: "black"
                        text:  id_exercise_ques_body_item.model.itemAt(index).userAnswer
                    }
                }

                YImage {
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    imageName: {
                        if (id_exercise_ques_body_item.model.itemAt(index).isRight) {
                            return "math/result-right-mini"
                        } else if (id_exercise_ques_body_item.model.itemAt(index).isWrong) {
                            return "math/result-wrong-mini"
                        } else if (id_exercise_ques_body_item.model.itemAt(index).isNotSure) {
                            return "math/result-warn-mini"
                        } else {
                            return ""
                        }
                    }
                    sourceSize: Qt.size(32, 32)
                }
            }
        }

        YSpacingForColumn {
            implicitHeight: 30
        }
    }
}

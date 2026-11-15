import QtQuick 2.12
import com.youdao.pen 1.0

import BaseQml 1.0
import "../i18n"

Item {
    id: id_answer_item
    property var analysis: null
    property var analysisType: null
    property var answer: null
    property var answerType: null
    property bool lineVisible: true

    width: 694
    height: id_answer_item_col.height

    Column {
        id: id_answer_item_col
        width: parent.width
        spacing: 0

        Row {
            id: id_answer_title_row
            visible: (answer != null) && (answer !== "")
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
                id: id_answer_title
                font.pixelSize: 26
                color: "#A8AAB2"
                height: contentHeight
                text: "答案"
            }
        }

        YSpacingForColumn {
            implicitHeight: 16
            visible: id_answer_title_row.visible
        }

        Image {
            width: parent.width
            visible: answerType === 2
            source: visible ? 'data:image/jpeg;base64,%1'.arg(answer) : ""
        }

        YText {
            lineHeight: 42
            lineHeightMode: Text.FixedHeight
            wrapMode: YText.WordWrap
            height: contentHeight
            width: parent.width
            visible: answerType === 1
            text: visible ? answer : ""
        }

        YSpacingForColumn {
            implicitHeight: 29
            visible: id_dividing_line.visible
        }

        YExerciseDividingLine {
            id: id_dividing_line
            sourceSize: Qt.size(694, 2)
            visible: id_answer_title_row.visible && id_analysis_title_row.visible
        }

        YSpacingForColumn {
            implicitHeight: 29
            visible: id_dividing_line.visible
        }

        Row {
            id: id_analysis_title_row
            visible: (analysis != null) && (analysis !== "")
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
                id: id_analysis_title
                font.pixelSize: 26
                color: "#A8AAB2"
                height: contentHeight
                text: "解析"
            }
        }

        YSpacingForColumn {
            implicitHeight: 16
            visible: id_analysis_title_row.visible
        }

        Image {
            width: parent.width
            visible: analysisType === 2
            source: visible ? 'data:image/jpeg;base64,%1'.arg(analysis) : ""
        }

        YText {
            lineHeight: 42
            lineHeightMode: Text.FixedHeight
            wrapMode: YText.WordWrap
            height: contentHeight
            width: parent.width
            visible: analysisType === 1
            text: visible ? analysis : ""
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

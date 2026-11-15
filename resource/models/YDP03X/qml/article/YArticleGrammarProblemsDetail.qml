import QtQuick 2.12

import BaseQml 1.0
import "../components"
import "../i18n"

YBackgroundIgnoreMouseEvent {
    id: id_grammar_problems_detail
    objectName: "YArticleGrammarProblemsDetail.qml"
    anchors.fill: parent
    visible: false

    function show(problemsDetail) {
        id_text_error.text = problemsDetail.orgChunk
        id_text_label.text = problemsDetail.lableModify
        id_text_right.errorTypeIsDeleted = problemsDetail.errorTypeIsDeleted
        id_text_right.text = problemsDetail.correctChunk
        id_grammar_problems_item_text.detailReason = problemsDetail.detailReason
        id_grammatical_points_text.text = problemsDetail.knowledgeExp
        id_example_sentences_repeater.model = problemsDetail.exampleCases
        visible = true
    }

    signal backButtonClicked()

    Flickable {
        id: id_history_listview
        anchors.fill: parent
        anchors.leftMargin: 90
        anchors.rightMargin: 16
        contentHeight: id_column.height

        Column {
            id: id_column
            anchors.left: parent.left
            anchors.right: parent.right
            spacing: 0

            YSpacingForColumn {
                implicitHeight: 22
            }

            Item {
                id: id_title
                anchors.left: parent.left
                anchors.right: parent.right
                height: id_title_flow.height

                Flow {
                    id: id_title_flow
                    anchors.left: parent.left
                    anchors.right: parent.right
                    spacing: 8

                    YText {
                        id: id_del_text_label
                        font.pixelSize: 26
                        text: YTranslateText.del
                        width: paintedWidth + 4
                        horizontalAlignment: YText.AlignHCenter
                        height: 38
                        verticalAlignment: YText.AlignVCenter
                        visible: !id_text_right.correctChunkVisible
                    }

                    YTextMedium {
                        id: id_text_error
                        color: YColors.red
                        width: Math.min(parent.width, paintedWidth)
                        height: Math.max(38, paintedHeight)
                        verticalAlignment: YTextMedium.AlignVCenter
                        wrapMode: YTextMedium.Wrap
                    }

                    YText {
                        id: id_text_label
                        font.pixelSize: 22
                        width: paintedWidth + 8
                        horizontalAlignment: YText.AlignHCenter
                        height: 38
                        verticalAlignment: YText.AlignVCenter
                        visible: id_text_right.correctChunkVisible
                    }

                    YTextMedium {
                        id: id_text_right
                        property bool errorTypeIsDeleted: false
                        readonly property bool correctChunkVisible: !errorTypeIsDeleted
                        visible: correctChunkVisible
                        color: YColors.green
                        width: Math.min(parent.width, paintedWidth)
                        height: Math.max(38, paintedHeight)
                        verticalAlignment: YTextMedium.AlignVCenter
                        wrapMode: YTextMedium.Wrap
                    }
                }
            }

            YSpacingForColumn {
                implicitHeight: 8
            }

            YTextMedium {
                anchors.left: parent.left
                anchors.leftMargin: 24
                color: YColors.grayText
                font.pixelSize: 22
                text: YTranslateText.articleLableModifyReason
                height: paintedHeight

                Rectangle {
                    implicitWidth: 6
                    implicitHeight: 6
                    radius: 4
                    color: YColors.grayText
                    anchors.left: parent.left
                    anchors.leftMargin: -9
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            YSpacingForColumn {
                implicitHeight: 10
            }

            YText {
                id: id_grammar_problems_item_text
                anchors.left: parent.left
                anchors.leftMargin: 24
                anchors.right: parent.right
                font.pixelSize: 26
                height: paintedHeight
                wrapMode: YText.Wrap
                textFormat: YText.RichText
                property string detailReason: ""
                text: {
                    if (detailReason.length > 0) {
                        let reason = detailReason
                        reason = reason.replaceAll("〖", (" <font color=\"%1\">").arg(YColors.red))
                        reason = reason.replaceAll("〗", "</font> ")
                        reason = reason.replaceAll("【", (" <font color=\"%1\">").arg(YColors.green))
                        reason = reason.replaceAll("】", "</font> ")
                        return reason
                    } else {
                        return ""
                    }
                }
            }

            YSpacingForColumn {
                implicitHeight: 20
            }

            YTextMedium {
                anchors.left: parent.left
                anchors.leftMargin: 24
                color: YColors.grayText
                font.pixelSize: 28
                text: YTranslateText.articleLableGrammaticalPoints
                height: paintedHeight

                Rectangle {
                    implicitWidth: 6
                    implicitHeight: 6
                    radius: 4
                    color: YColors.grayText
                    anchors.left: parent.left
                    anchors.leftMargin: -9
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            YSpacingForColumn {
                implicitHeight: 10
            }

            YText {
                id: id_grammatical_points_text
                anchors.left: parent.left
                anchors.leftMargin: 24
                anchors.right: parent.right
                font.pixelSize: 26
                height: paintedHeight
                wrapMode: YText.Wrap
            }

            YSpacingForColumn {
                implicitHeight: 20
            }

            YTextMedium {
                anchors.left: parent.left
                anchors.leftMargin: 24
                color: YColors.grayText
                font.pixelSize: 28
                text: YTranslateText.exampleSentences
                height: paintedHeight

                Rectangle {
                    implicitWidth: 6
                    implicitHeight: 6
                    radius: 4
                    color: YColors.grayText
                    anchors.left: parent.left
                    anchors.leftMargin: -9
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            YSpacingForColumn {
                implicitHeight: 6
            }

            Repeater {
                id: id_example_sentences_repeater

                Item {
                    anchors.left: id_column.left
                    anchors.leftMargin: 24
                    anchors.right: id_column.right
                    height: id_example_sentences_item_column.height + 10

                    Column {
                        id: id_example_sentences_item_column
                        anchors.left: parent.left
                        anchors.right: parent.right
                        spacing: 0

                        YTextEnUs {
                            anchors.left: parent.left
                            anchors.right: parent.right
                            font.pixelSize: 26
                            height: paintedHeight
                            wrapMode: YText.Wrap
                            color: YColors.green
                            text: model.modelData.right
                        }

                        YTextEnUs {
                            anchors.left: parent.left
                            anchors.right: parent.right
                            font.pixelSize: 26
                            height: paintedHeight
                            wrapMode: YText.Wrap
                            color: YColors.red
                            text: model.modelData.error
                        }

                        YSpacingForColumn {
                            implicitHeight: 4
                        }

                        YTextCH {
                            id: id_example_sentences_item
                            anchors.left: parent.left
                            anchors.right: parent.right
                            font.pixelSize: 26
                            height: paintedHeight
                            wrapMode: YText.Wrap
                            color: YColors.white
                            text: model.modelData.rightTranslate
                        }
                    }
                }
            }

            YSpacingForColumn {
                implicitHeight: 24
            }
        }
    }

    YVerticalTitleBar {
        id: id_title_bar
        onCallBack: {
            backButtonClicked()
        }
    }
}

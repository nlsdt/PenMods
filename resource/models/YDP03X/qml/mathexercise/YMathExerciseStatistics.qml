import QtQuick 2.12
import QtGraphicalEffects 1.0
import com.youdao.pen 1.0

import BaseQml 1.0
import "../components"
import "../i18n"

Item {
    id: id_statistics_select_item
    objectName: "YMathExerciseStatistics.qml"
    anchors.fill: parent
    property bool isIntroductionShow: false
    property bool isKnowledge: true
    property int knowCount: mathManager.mathExerciseDB.reportListModel.count
    property int quesCount: {
        var ret = 0
        for (var i = 0; i < mathManager.mathExerciseDB.reportListModel.count ; i++) {
            var modeldata = mathManager.mathExerciseDB.reportListModel[i]
            ret = ret + modeldata.count
        }
        return ret
    }

    Item {
        id: id_effect_item
        implicitWidth: 80
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        z: id_mathexercise_statistics_content_container.z + 1

        ShaderEffectSource {
            id: id_effect_source
            anchors.fill: parent
            sourceItem: id_mathexercise_statistics_content_container
            sourceRect: Qt.rect(x - 80, y - 16, width, height)
        }

        FastBlur {
            anchors.fill: parent
            source: id_effect_source
            radius: 32
        }

        Rectangle {
            anchors.fill: parent
            color: "#4D000000"
            anchors.top: parent.top
            anchors.bottom: parent.bottom
        }
    }

    YVerticalTitleBar {
        z: id_effect_item.z + 1
        iconButtonBackgroundItem.icon: "ic_back"
        onCallBack: {
            id_math_tutor_page.subPageCallBack()
        }
        objectName: "YBackButtonPage.qml_" + id_statistics_select_item.objectName
    }

    Item {
        id: id_mathexercise_statistics_content_container
        anchors.fill: parent
        anchors.leftMargin: 80
        anchors.rightMargin: 20
        anchors.topMargin: 16
        anchors.bottomMargin: 16

        Flickable {
            id: id_statistics_container_flickable
            anchors.fill: parent
            contentWidth: id_statistics_content_row.width
            flickableDirection: Flickable.Flickable.HorizontalFlick

            Row {
                id: id_statistics_content_row
                anchors.top: parent.top
                anchors.left: parent.left
                height: parent.height
                spacing: 10

                YImage {
                    width: 320
                    height: 222
                    antialiasing: true
                    sourceSize: Qt.size(320, 222)
                    imageName: "math/exercise-report-bg"

                    YText {
                        id: id_report_title_text
                        anchors.top: parent.top
                        anchors.topMargin: 22
                        anchors.horizontalCenter: parent.horizontalCenter
                        width: 202
                        height: 34
                        font.pixelSize: 26
                        text: "AI学情统计(本周)"
                    }

                    YImage {
                        id: id_divide_line_icon
                        anchors.bottom: parent.bottom
                        anchors.bottomMargin: 30
                        anchors.horizontalCenter: parent.horizontalCenter
                        sourceSize: Qt.size(2, 80)
                        imageName: "math/exercise-divide-line"
                    }

                    Rectangle {
                        anchors.bottom: id_divide_line_icon.bottom
                        anchors.horizontalCenter: parent.horizontalCenter
                        width: 220
                        height: 97
                        color: "transparent"

                        YText {
                            anchors.top: parent.top
                            anchors.horizontalCenter: id_know_count_title.horizontalCenter
                            height: 63
                            width: paintedWidth
                            font.pixelSize: 42
                            font.bold: true
                            font.family: "Poppins"
                            font.italic: true
                            text: mathManager.mathExerciseDB.reportKnowCount
                        }

                        YText {
                            anchors.top: parent.top
                            anchors.horizontalCenter: id_ques_count_title.horizontalCenter
                            height: 63
                            width: paintedWidth
                            font.pixelSize: 42
                            font.bold: true
                            font.family: "Poppins"
                            font.italic: true
                            text: mathManager.mathExerciseDB.reportQuesCount
                        }

                        YText {
                            id: id_know_count_title
                            anchors.left: parent.left
                            anchors.bottom: parent.bottom
                            width: 72
                            height: 28
                            font.pixelSize: 24
                            text: "薄弱点"   //mathManager.mathExerciseDB.reportKnowCount
                        }
                        YText {
                            id: id_ques_count_title
                            anchors.right: parent.right
                            anchors.bottom: parent.bottom
                            width: 72
                            height: 28
                            font.pixelSize: 24
                            text: "摘题数"   //mathManager.mathExerciseDB.reportQuesCount
                        }
                    }
                }

                Rectangle {
                    id: id_content_containter
                    width: 690
                    height: 222
                    radius: 20
                    color: YColors.grayNormal

                    YBaseListView {
                        id: id_statistic_listview
                        anchors.fill: parent
                        clip: true

                        model: isKnowledge ? mathManager.mathExerciseDB.reportListModel
                                           : mathExerciseManager.recommendListModel

                        delegate: id_list_view_component

                        header: YMathExerciseTabsTitleBar {
                            id: hearder
                            namesArray: ["薄弱点分析", "每日AI推题"]

                            onCurrentIndexChanged: {
                                id_statistics_select_item.isKnowledge = (currentIndex === 0)
                            }

                            onShowIntroduction: {
                                id_intro_dialog.show()
                            }
                        }

                        YText {
                            id: id_statistic_listview_empty_tip
                            anchors.centerIn: parent
                            anchors.verticalCenterOffset: 12
                            font.pixelSize: 26
                            color: YColors.grayText
                            text: {
                                if (isKnowledge) return YTranslateText.weaknessKnowledgeEmpty
                                if (!mathExerciseManager.isNetworkConnect) return YTranslateText.recommendNeedNetWork
                                if (!mathExerciseManager.isLogin)  return YTranslateText.recommendNeedLogin
                                return YTranslateText.recommendEmpty
                            }
                            visible: id_statistic_listview.empty

                            YTimer {
                                id: id_delay_check_empty_timer
                                interval: 300

                                function recheck() {
                                    id_statistic_listview_empty_tip.visible = false
                                    restart()
                                }

                                onTriggered: {
                                    id_statistic_listview_empty_tip.visible = Qt.binding(function(){
                                        return 0 === id_statistic_listview.count
                                    })
                                }
                                objectName: "YMathExerciseStatistics.qml_id_delay_check_empty_timer"
                            }
                        }
                    }
                }
            }
        }

    }

    YDialog {
        id: id_intro_dialog
        anchors.fill: parent
        z: id_effect_item.z + 1

        Column {
            anchors.top: parent.top
            anchors.topMargin: 24
            anchors.left: parent.left
            anchors.leftMargin: 90
            width: 680

            YTextMedium {
                anchors.left: parent.left
                font.pixelSize: 26
                color: YColors.grayText
                width: parent.width
                text: "薄弱点分析："
            }

            YSpacingForColumn {
                height: 6
            }

            YText {
                anchors.left: parent.left
                width: parent.width
                wrapMode: YText.WordWrap
                text: "本周存在的知识点弱项，点击进入强化学习。"
            }

            YSpacingForColumn {
                height: 20
            }

            YTextMedium {
                anchors.left: parent.left
                font.pixelSize: 26
                color: YColors.grayText
                width: parent.width
                text: "每日AI推题："
            }

            YSpacingForColumn {
                height: 6
            }

            YText {
                anchors.left: parent.left
                width: parent.width
                wrapMode: YText.WordWrap
                text: "基于你的摘题数据，AI老师为你定制的练习题，点击即进入学习。"
            }
        }

        YIconButton {
            id: id_close_button
            implicitWidth: 44
            implicitHeight: 44
            radius: height / 2
            color: YColors.grayNormal
            mouseAreaMargins: -22
            imageName: "commons/close"
            anchors.top: parent.top
            anchors.topMargin: 18
            anchors.left: parent.left
            anchors.leftMargin: 16
            onClicked: {
                id_intro_dialog.close()
                id_intro_dialog.closed()
            }
        }
    }

    Component.onCompleted: {
        mathManager.mathExerciseDB.generateAIReport()
        mathExerciseManager.requestRecommend()
    }

    Component.onDestruction: {
        mathManager.mathExerciseDB.wipeData(true)
    }

    Component {
        id: id_list_view_component

        Item {
            id: id_container_item
            anchors.left: parent.left
            anchors.leftMargin: 30
            width: 630
            height: 77

            property int starsNum: {
                if (model.modelData.count <= 2) {
                    return 1
                } else if (model.modelData.count <= 4) {
                    return 2
                } else {
                    return 3
                }
            }

            YExerciseDividingLine {
                sourceSize: Qt.size(630, 2)
                visible: index !== 0
            }

            YText {
                id: id_title_text
                anchors.top: parent.top
                anchors.topMargin: 20
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.rightMargin: isKnowledge ? 180 : 50
                elide: Text.ElideRight
                height: 37
                horizontalAlignment : YText.AlignLeft
                verticalAlignment: YText.AlignVCenter
                text: isKnowledge ? model.modelData.title : model.modelData.quesText

                Row {
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.right
                    anchors.leftMargin: parent.paintedWidth - parent.width + 30
                    spacing: 2
                    visible: isKnowledge

                    Repeater {
                        model: 3

                        YImage {
                            sourceSize: Qt.size(32, 32)
                            imageName: id_container_item.starsNum >= (index + 1) ?
                                           "math/ic-star-highlighted" : "math/ic-star"
                        }
                    }
                }
            }

            YImage {
                sourceSize: Qt.size(24, 24)
                imageName: "wordbook/word_detail"
                anchors.verticalCenter: parent.verticalCenter
                anchors.right: parent.right
            }

            YMouseArea {
                anchors.fill: parent
                onClicked:  {
                    if (isKnowledge) {
                        let result = mathManager.mathExerciseDB.prepareShowKnowledge(model.modelData)
                        if (!result) { return }
                        entryKnowledge()
                        logManager.sendHttpLog("action=math_report_know_click")
                    } else {
                        mathExerciseManager.queryDetail(model.modelData.questionCode, model.modelData.mathType, true)
                        logManager.sendHttpLog("action=math_report_quest_click")
                    }
                }
            }
        }
    }
}

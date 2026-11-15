import QtQuick 2.12
import com.youdao.pen 1.0
import QtGraphicalEffects 1.14

import BaseQml 1.0
import "../i18n"

Item {
    id: id_math_exercise_home_item
    objectName: "YMathExerciseHome.qml"
    anchors.fill: parent

    property int newContentCount:  mathManager.mathExerciseDB.newContentCount//mathExerciseManager.newContentCount

    function show(){
        id_math_exercise_home_item.visible = true
    }

    function hidden(){
        id_math_exercise_home_item.visible = false
    }

    function mathexerciseHomeMenuClicked(index) {
        console.warn("YMathExerciseHome.qml===mathexerciseHomeMenuClicked===index: ", index)
        let component = null
        switch (index) {
        case YEnum.Mathexercise_Fav:
            logManager.sendHttpLog("action=math_goodbook_click")
            showSubPage(YEnum.Mathexercise_Fav, true)
            break
        case YEnum.Mathexercise_Report:
            logManager.sendHttpLog("action=math_report_click")
            showSubPage(YEnum.Mathexercise_Report, true)
            break
        default:
            break
        }
    }

    Item {
        id: id_mathexercise_home_list_view_container
        anchors.fill: parent
        anchors.topMargin: 62
        anchors.bottomMargin: 62
        anchors.leftMargin: 80

        YHorizontalListView {
            id: id_mathexercise_home_list_view
            model: mainMenuModel
            spacing: 10
            anchors.fill: parent
            rightMargin: 30

            header: YText {
                id: id_result_study_tip
                anchors.leftMargin: 90
                anchors.verticalCenter: parent.verticalCenter
                font.pixelSize: 32
                width: 330
                textFormat: YTextMedium.RichText
                lineHeight: 42
                lineHeightMode: YTextMedium.FixedHeight
                text: ("请扫描录入<font color=\"%1\">数学题目</font>").arg(YColors.red)
            }

            delegate: Item {
                id: id_item_delegate
                width: id_mathexercise_home_menu_button.width
                height: parent.height
                anchors.verticalCenter: parent.verticalCenter

                YButtonBase {
                    id: id_mathexercise_home_menu_button
                    anchors.centerIn: parent
                    width: id_mathexercise_home_exercise_count.visible ?
                               id_mathexercise_home_menu_text.width + id_mathexercise_home_exercise_count.width + 10 + 40 * 2 :
                               id_mathexercise_home_menu_text.width + 50 * 2
                    height: 130
                    antialiasing: true
                    opacity: id_mathexercise_home_button.pressed ? 0.6 : 1
                    anchors.verticalCenter: parent.verticalCenter

                    YTextMedium {
                        id: id_mathexercise_home_menu_text
                        anchors.left: parent.left
                        anchors.leftMargin: id_mathexercise_home_exercise_count.visible ? 40 : 50
                        textFormat: YTextBase.RichText
                        anchors.verticalCenter: parent.verticalCenter
                        font.family: fontManager.fontFamilyZhCn
                        width: contentWidth
                        text: {
                            switch (pageIndex) {
                            case YEnum.Mathexercise_Fav:
                                return YTranslateText.mathGoodProblemBook
                            case YEnum.Mathexercise_Report:
                                return YTranslateText.mathExerciseReport
                            default:
                                return ""
                            }
                        }
                    }

                    YRectangle {
                        id: id_mathexercise_home_exercise_count
                        anchors.left: id_mathexercise_home_menu_text.right
                        anchors.leftMargin: 10
                        anchors.verticalCenter: parent.verticalCenter
                        width: 18 + (id_mathexercise_home_exercise_count_text.width > 14
                                     ? id_mathexercise_home_exercise_count_text.width : 14)
                        height: 30
                        radius: height
                        visible: YEnum.Mathexercise_Fav === pageIndex && newContentCount > 0
                        gradient: Gradient {
                            GradientStop { position: 0.0; color: "#4D94FF" }
                            GradientStop { position: 1.0; color: "#457AE5" }
                        }

                        YTextMedium {
                            id: id_mathexercise_home_exercise_count_text
                            width: contentWidth
                            height: 33
                            anchors.centerIn: parent
                            font.pixelSize: 22
                            font.family: fontManager.fontFamilyZhCn
                            text: newContentCount
                        }
                    }

                    YMouseArea {
                        id: id_mathexercise_home_button
                        anchors.fill: parent
                        objectName: "YMathExerciseHome_id_mathexercise_home_list_view_pageIndex" + pageIndex
                        onClicked: {
                            mathexerciseHomeMenuClicked(pageIndex)
                        }
                    }
                }
            }

            ListModel {
                id: mainMenuModel
                Component.onCompleted: {
                    append({pageIndex: YEnum.Mathexercise_Fav})
                    append({pageIndex: YEnum.Mathexercise_Report})
                }
            }
        }

        YSpacing {
            anchors {left:; right: parent.right; rightMargin: 24}
        }
    }

    YVerticalTitleBar {
        id: id_title_bar
        backButtonItem.iconButtonBackgroundItem.asynchronous: false
        onCallBack: {
            backButtonClicked()
        }

        YIconButton {
            id: id_guide_button_bg
            asynchronous: false
            implicitWidth: 44
            implicitHeight: 44
            mouseAreaMargins: -18
            anchors.left: parent.left
            anchors.leftMargin: 16
            anchors.bottom: parent.bottom
            sourceSize: Qt.size(36, 36)
            imageName: "math/exercise-guide"
            onClicked: {
                id_mathexercise_guide.visible = true
//                showSubPage(YEnum.Mathexercise_Guide, true)
            }
        }
    } // YVerticalTitleBar

    YMathExerciseGuide {
        id: id_mathexercise_guide
        visible: false
    }

    onVisibleChanged: {
        if (visible) mathManager.mathExerciseDB.getNewContentCount()
    }
}


import QtQuick 2.12
import com.youdao.pen 1.0
import QtGraphicalEffects 1.14

import BaseQml 1.0
import "../i18n"

YBackgroundIgnoreMouseEvent {
    id: id_math_exercise_know_page
    objectName: "YMathExerciseKnowledge.qml"
    anchors.fill: parent

    property bool isAssociationNeed: true
    property int currentIndex: 0
    property int currentTab: 0
    property var tabViewList: [
        YTranslateText.mathExerciseCurrentKnowledge,
        YTranslateText.mathExerciseBoutique,
        YTranslateText.mathExerciseAssociatedKnowledge
    ]
    property string videoUrl: ""
    property var resultModel: mathManager.mathExerciseDB.knowShowModel

    property bool simQuesListVisible: false
    property bool associationVisible: false
    property bool videoVisible: value

    signal backButtonClicked()

    onResultModelChanged: {
        positionViewToBeginning()
        parseResultModel()
        console.warn("@@" + JSON.stringify(resultModel))
        updateNavigationModel()

    }

    function playVideo(url) {
        id_math_exercise_navigation.packUpNavigation()
        if (!wifiManager.internetConnect) {
            baseSignals.showToast(YTranslateText.networkAbnormalPleaseCheck, YColors.grayNormal)
            return
        }
        videoUrl = url
        video_loader.active = true
    }

    function parseResultModel() {
        if (!resultModel) return
        simQuesListVisible = resultModel.simQuesList !== null && resultModel.simQuesList.length > 0
        associationVisible = isAssociationNeed
                ? ((resultModel.parents !== null && resultModel.parents.length > 0) || (resultModel.children !== null && resultModel.children.length > 0))
                : false
        videoVisible = (typeof(resultModel.video) !== "undefined") && (resultModel.video !== "")

        id_repeater_list_model.clear()
        id_repeater_list_model.append({"title": YTranslateText.mathExerciseCurrentKnowledge})
        if (simQuesListVisible) id_repeater_list_model.append({"title": YTranslateText.mathExerciseBoutique})
        if (associationVisible) id_repeater_list_model.append({"title": YTranslateText.mathExerciseAssociatedKnowledge})
    }

    function positionViewToBeginning() {
        id_content_view.contentY = 0
        updateNavigation()
    }

    function updateNavigationModel() {
        id_math_exercise_navigation.navigationModel.clear()
        for (var i = 0; i < id_repeater_list_model.count; i++) {
            id_math_exercise_navigation.navigationModel.append(id_repeater_list_model.get(i))
        }
    }

    function positionViewToLocation(index) {
        id_content_view.contentY = id_result_content_view_repeater.itemAt(index).y
    }

    function updateNavigation() {
        for (var i = 0; i < id_math_exercise_navigation.navigationModel.count; ++i) {
            var itemY = id_result_content_view_repeater.itemAt(i).y
            if (itemY >= id_content_view.contentY && itemY < (id_content_view.contentY + id_content_view.height)) {
                id_math_exercise_navigation.setCurrentIndex(i)
                break
            }
        }
    }

    ListModel {
        id: id_repeater_list_model
    }

    Flickable {
        id: id_content_view
        anchors.fill: parent
        anchors.leftMargin: 90
        anchors.rightMargin: 80
        contentHeight: id_column.height

        onMovementEnded: {
            updateNavigation()
        }

        Column {
            id: id_column
            anchors.left: parent.left
            anchors.right: parent.right
            spacing: 0

            YSpacingForColumn {
                implicitHeight: 24
            }

            Repeater {
                id: id_result_content_view_repeater
                model: id_repeater_list_model

                delegate: YLoader {
                    id: id_result_content_view_delegate
                    asynchronous: false
                    active: true

                    sourceComponent: {
                        switch (title) {
                        case YTranslateText.mathExerciseCurrentKnowledge:
                            return id_knowledge_component
                        case YTranslateText.mathExerciseBoutique:
                            return id_association_component
                        case YTranslateText.mathExerciseAssociatedKnowledge:
                            return id_association_knowledges_component
                        default:
                            return null
                        }
                    }


                    Component {
                        id: id_knowledge_component
                        YMathExerciseKnowledgeItem {
                            title: YTranslateText.mathExerciseCurrentKnowledge
                            content: resultModel.title
                            lineVisible: simQuesListVisible || associationVisible
                            imageSource: videoVisible ? "math/exercise_point_video_icon" : ""

                            onClickToPlayVideo: {
                                var url = resultModel.video
                                playVideo(url)
                            }
                        }
                    }

                    Component {
                        id: id_association_component
                        YMathExerciseAssociation {
                            title: YTranslateText.mathExerciseBoutique
                            model: resultModel.simQuesList
                            lineVisible: associationVisible
                        }
                    }

                    Component {
                        id: id_association_knowledges_component
                        YMathKnowledgeAssociation {
                            title: YTranslateText.mathExerciseAssociatedKnowledge
                            currentName: resultModel.title
                            parentsModel: resultModel.parents
                            childrenModel: resultModel.children
                        }
                    }
                }
            }

            YSpacingForColumn {
                implicitHeight: 30
            }
        }

        Component.onCompleted: updateNavigationModel()
    }

    YVerticalTitleBar {
        id: id_title_bar
        onCallBack: {
            backButtonClicked()
        }

        YIconButton {
            id: id_top_button_bg
            implicitWidth: 44
            implicitHeight: 44
            mouseAreaMargins: -18
            anchors.left: parent.left
            anchors.leftMargin: 16
            anchors.bottom: parent.bottom
            sourceSize: Qt.size(36, 36)
            imageName: "math/result-up"
            visible: id_content_view.contentY > YBaseEnum.Screen.Height
            onClicked: {
                positionViewToBeginning()
            }
        }
    } // YVerticalTitleBar

    YLoader {
        id: video_loader
        active: false
        asynchronous: false
        sourceComponent: id_video_player_component

        Component {
            id: id_video_player_component
            YMathExerciseVideoPlayer {
                id: id_math_exercise_video_player
                videoSource: id_math_exercise_know_page.videoUrl
                onCloseVideoPage: {
                    video_loader.active = false
                    mathExerciseManager.processedVideoFinish()
                }
            }
        }
    }

    Item {
        id: id_inner_item
        anchors.fill: parent
    }

    ShaderEffectSource {
        id: id_effect_source
        anchors.top: parent.top
        anchors.right: parent.left
        anchors.bottom: parent.bottom
        width: id_math_exercise_navigation.width
        sourceItem: id_inner_item
        sourceRect: Qt.rect(0, 0, width, height)
        visible: false
    }

    YMathExerciseNavigation {
        id: id_math_exercise_navigation

        fastBlurTarget: id_effect_source
        visible: true

        onNavigationSendToPage: {
             id_math_exercise_know_page.positionViewToLocation(index)
        }
    }

    Connections {
        target: qmlGlobal
        ignoreUnknownSignals: true
        onCurrentPageIndexChanged: {
            if ((qmlGlobal.currentPageIndex !== YEnum.PageIndex.MathTutor)
                    && video_loader.active) {
                video_loader.active = false
                mathExerciseManager.processedVideoFinish()
            }
        }
    }
}

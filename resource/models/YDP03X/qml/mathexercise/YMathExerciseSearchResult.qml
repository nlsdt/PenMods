import QtQuick 2.12
import com.youdao.pen 1.0
import QtGraphicalEffects 1.14

import BaseQml 1.0
import "../i18n"

YBackgroundIgnoreMouseEvent/*Item*/ {
    id: id_math_exercise_result_item
    objectName: "YMathExerciseSearchResult.qml"
    anchors.fill: parent

    property bool isSimQuesNeed: true // to delete
    property bool isTabBarNeed: true   // to delete
    property bool isOriginMode: true
    property bool isSearchMode: true
    property int currentIndex: 0
    property int currentTab: 0
    property var tabViewList: [
        YTranslateText.mathExerciseTitle,
        YTranslateText.mathExerciseVideo,
        YTranslateText.mathExerciseKnowledge,
        YTranslateText.mathExerciseKnowledgeVideo,
        YTranslateText.mathExerciseBoutique
    ]

    property var resultModel: null
    property var knowledge: null
    property string videoUrl: ""

    property bool videoVisible: false
    property bool answerVisible: false
    property bool knowledgeVisible: false
    property bool knowVideoVisible: false
    property bool simQuesListVisible: false

    property bool isFav: false

    ListModel {
        id: id_repeater_list_model
    }

    signal backButtonClicked()

    onResultModelChanged: {
//        console.warn(JSON.stringify(resultModel))
        if (id_edit_widget.visible) id_edit_widget.close()
        positionViewToBeginning()
        parseResultModel()
        updateNavigationModel()
    }

    onIsSearchModeChanged: {
        currentTab = 0
        positionViewToBeginning()
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
        id_repeater_list_model.clear()
        isOriginMode = (resultModel.mathType === 2)
        knowledge = (typeof resultModel.knowledge !== "undefined") && (resultModel.knowledge !== "")
                ? JSON.parse(resultModel.knowledge) : null
        videoVisible = !isOriginMode && (resultModel.quesVideo !== "")
        answerVisible = !isOriginMode && (((typeof resultModel.answer !== "undefined") && (resultModel.answer !== ""))
                                          || ((typeof resultModel.analysis !== "undefined") && (resultModel.analysis !== "")))
        knowledgeVisible = knowledge !== null
                && (typeof knowledge.knowId !== "undefined")
                && (typeof knowledge.knowName !== "undefined")
                && (knowledge.knowName !== "")
        knowVideoVisible = knowledge !== null
                && (typeof knowledge.knowVideo === "string")
                && (knowledge.knowVideo !== "")
        simQuesListVisible = isOriginMode /*&& isSimQuesNeed*/ && (resultModel.simQuesList !== null) && (resultModel.simQuesList.length > 0)

        id_repeater_list_model.append({"title": YTranslateText.mathExerciseTitle})

        if (videoVisible) id_repeater_list_model.append({"title": YTranslateText.mathExerciseVideo})
        if (answerVisible) id_repeater_list_model.append({"title": YTranslateText.mathExerciseAnswer})
        if (knowledgeVisible) id_repeater_list_model.append({"title": YTranslateText.mathExerciseKnowledge})
        if (knowVideoVisible) id_repeater_list_model.append({"title": YTranslateText.mathExerciseKnowledgeVideo})
        if (simQuesListVisible) id_repeater_list_model.append({"title": YTranslateText.mathExerciseBoutique})
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
            if (itemY >= id_content_view.contentY && itemY < (id_content_view.contentY + id_content_view.height)){
                id_math_exercise_navigation.setCurrentIndex(i)
                break
            }
        }
    }

    Flickable {
        id: id_content_view
        anchors.fill: parent
        anchors.leftMargin: 90
        anchors.rightMargin: 16
        contentHeight: id_column.height

        visible: !id_searching_item.visible

        onMovementEnded: {
            updateNavigation()
        }

        Column {
            id: id_column
            anchors.left: parent.left
            anchors.right: parent.right
            spacing: 0

            YSpacingForColumn {
                implicitHeight: 18
            }

            Repeater {
                id: id_result_content_view_repeater
                model: id_repeater_list_model

                delegate: YLoader {
                    id: id_result_content_view_delegate
                    asynchronous: false
                    active: true
                    height: sourceComponent === null ? 0 : sourceComponent.height

                    sourceComponent: {
                        /*if (isOriginMode) {
                            return id_origin_component
                        } else */{
                            switch (title) {
                            case YTranslateText.mathExerciseTitle:
                                return id_quesbody_component
                            case YTranslateText.mathExerciseVideo:
                                return id_ques_video_component
                            case YTranslateText.mathExerciseAnswer:
                                return id_answer_component
                            case YTranslateText.mathExerciseKnowledge:
                                return id_knowledge_component
                            case YTranslateText.mathExerciseKnowledgeVideo:
                                return id_point_video_component
                            case YTranslateText.mathExerciseBoutique:
                                return id_association_component
                            default:
                                return null
                            }
                        }
                    }

                    Component {
                        id: id_origin_component
                        YMathExerciseQuesBody {
                            type: typeof(resultModel.contentType) !== null ?  resultModel.contentType : 1
                            content: typeof(resultModel.content) !== null ? resultModel.content : resultModel.quesText
                            lineVisible: false
                        }
                    }

                    Component {
                        id: id_quesbody_component
                        YMathExerciseQuesBody {
                            type: typeof(resultModel.contentType) !== null ?  resultModel.contentType : 1
                            content: typeof(resultModel.content) !== null ? resultModel.content : ""
                            lineVisible: knowledgeVisible || knowVideoVisible
                                         || simQuesListVisible
                                         || videoVisible || answerVisible
                            isSplitNeed: !mathExerciseManager.isFromFav && isOriginMode

                            onCollectButtonClicked: {
                                isSplitNeed = false
                                if (!mathExerciseManager.isInFavorites) {
                                    id_label_edit_dialog.clearLabelRecord()
                                    id_label_edit_dialog.show()
                                } else {
                                    mathExerciseManager.deleteFromFavorites(resultModel.questionCode)
                                    baseSignals.showToast(YTranslateText.removeFavSucceed, YColors.grayNormal)
                                }
                            }

                            onEditButtonClicked: {
                                isSplitNeed = false
                                id_edit_widget.submitText = resultModel.content
                                id_edit_widget.show()
                                mathExerciseManager.setIsEditing(true)
                            }

                            onShowCombineTip: {
                                id_combine_tip_dialog.show()
                            }
                        }
                    }

                    Component {
                        id: id_ques_video_component
                        YMathExerciseVideoItem {
                            title: YTranslateText.mathExerciseVideo
                            imageSource: "math/exercise_ques_video_icon"
                            lineVisible: answerVisible || knowledgeVisible || knowVideoVisible

                            onClickToPlayVideo: {
                                var url = resultModel.quesVideo
                                playVideo(url)
                            }
                        }
                    }

                    Component {
                        id: id_answer_component
                        YMathExerciseAnswerItem {
                            analysisType: typeof(resultModel.analysisType) !== null ? resultModel.answerType : 1
                            analysis: resultModel.analysis
                            answerType: typeof(resultModel.answerType) !== null ? resultModel.answerType : 1
                            answer: resultModel.answer
                            lineVisible: knowledgeVisible || knowVideoVisible
                        }
                    }

                    Component {
                        id: id_knowledge_component

                        YMathExerciseKnowledgeItem {
                            title: YTranslateText.mathExerciseKnowledge
                            content: knowledgeVisible ? knowledge.knowName : ""
                            lineVisible: knowVideoVisible || simQuesListVisible
                        }
                    }

                    Component {
                        id: id_point_video_component
                        YMathExerciseVideoItem {
                            title: YTranslateText.mathExerciseKnowledgeVideo
                            imageSource: "math/exercise_point_video_icon"
                            lineVisible: simQuesListVisible

                            onClickToPlayVideo: {
                                var url = knowledge.knowVideo
                                playVideo(url)
                            }
                        }
                    }

                    Component {
                        id: id_association_component
                        YMathExerciseAssociation {
                            title: YTranslateText.mathExerciseBoutique
                            model: resultModel.simQuesList
                            lineVisible: false
                        }
                    }
                }
            }

            YSpacingForColumn {
                implicitHeight: 30
            }
        }

        Component.onCompleted:  updateNavigationModel()
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
                videoSource: id_math_exercise_result_item.videoUrl

                onCloseVideoPage: {
                    video_loader.active = false
                    mathExerciseManager.processedVideoFinish()
                }
            }
        }
    }

    YMathExerciseSearchingItem {
        id: id_searching_item
        visible: mathExerciseManager.isSearching
        content: mathExerciseManager.currentOcrResult
    }

    YMathLabelEditDialog {
        id: id_label_edit_dialog

        onSubmit: {
            mathExerciseManager.addToFavorites(value, resultModel)
            id_label_edit_dialog.close()
        }
    }

    YMathExerciseEditWidget {
        id: id_edit_widget

        onRequestEnteredTooLongTip: {
            baseSignals.showToast(YTranslateText.articleRequestEnteredTooLongTip, "#E52D2E33")
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
        visible: id_content_view.visible
                 && !id_label_edit_dialog.isShowing
                 && !id_edit_widget.visible

        onNavigationSendToPage: {
             id_math_exercise_result_item.positionViewToLocation(index)
        }
    }

    YDialog {
        id: id_combine_tip_dialog
        anchors.fill: parent

        YImage {
            anchors.centerIn: parent
            imageName: "math/ic-combine_tip"
            sourceSize: Qt.size(471, 56)
        }

        YMouseArea {
            anchors.fill: parent

            onClicked: {
                settingManager.isFirstShowCombine = false
                id_combine_tip_dialog.close()
            }
        }
    }

    Connections {
        target: qmlGlobal
        ignoreUnknownSignals: true
        function onCurrentPageIndexChanged() {
            if ((qmlGlobal.currentPageIndex !== YEnum.PageIndex.MathTutor)
                    && video_loader.active) {
                video_loader.active = false
                mathExerciseManager.processedVideoFinish()
            }
        }
    }
}

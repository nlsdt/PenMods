import QtQuick 2.12
import com.youdao.pen 1.0

import BaseQml 1.0
import "./mathexercise"
import "./i18n"
import "./settingpages"
import "./timers"

YPage {
    id: id_math_tutor_page
    objectName: "YPage===YMathExercisePage.qml"

    signal showSubPage(var subPageIndex, var bAddHistory)

    signal entryFavResult()

    signal entryKnowledge()

    property int incubatorCreateCount: 0

    property var exerciseSubPageHistory: []

    property var mathexerciseSubPageIndexCur: {
//        return YEnum.Mathexercise_Guide
        return YEnum.Mathexercise_Home
//        YEnum.Mathexercise_Fav
//        YEnum.Mathexercise_Correct
//        return YEnum.Mathexercise_Search
    }

    Component.onCompleted: {
        delayRequestWifi()
    }

    function subPageCallBack() {
        if (exerciseSubPageHistory.length > 0) {
            let popPageIndex = exerciseSubPageHistory.pop()
            mathexerciseSubPageIndexCur = popPageIndex
            if (mathexerciseSubPageIndexCur === YEnum.Mathexercise_Home) {
                mathManager.mathExerciseDB.getNewContentCount()
            }
        } else {
            backButtonClicked()
        }
    }

    function requestArticlNeedNetWorkTip() {
        function newComponentInit(incubatorObject) {
            incubatorObject.configWifi.connect(requestArticlNeedNetWorkSetting)
            incubatorObject.configWifi.connect(function() {
                incubatorObject.destroy(1000)
            })
            incubatorObject.backButtonClicked.connect(subPageCallBack)
            id_math_tutor_page.backButtonClicked.connect(incubatorObject.destroy)
            systemBase.ocrStart.connect(incubatorObject.destroy)
            incubatorObject.show()
        }

        const newComponent = Qt.createComponent(
                               "./mathexercise/YMathExerciseNeedNetworkTip.qml")
        if (newComponent.status === Component.Ready) {
            let createdObject = newComponent.createObject(id_math_tutor_page)
            newComponentInit(createdObject)
        }
    }

    function requestArticlNeedNetWorkSetting() {
        if (!wifiManager.internetConnect) {
            function newComponentInit(incubatorObject) {
                function close() {
                    incubatorObject.destroy()
                    // 配置网络返回，不再检查网络状态，直接回功能首页
//                    delayRequestWifi()
                }
                id_math_tutor_page.backButtonClicked.connect(close)
                incubatorObject.backButtonClicked.connect(close)
                systemBase.homeKeyPress.connect(close)
                systemBase.ocrStart.connect(close)
                incubatorObject.show()
            }

            const incubator = id_config_wifi_component.incubateObject(
                                id_math_tutor_page)
            if (incubator.status !== Component.Ready) {
                incubator.onStatusChanged = function(status) {
                    if (status === Component.Ready) {
                        if (0 === --incubatorCreateCount) {
                            // 异步重入只显示最后一个创建的对象
                            newComponentInit(incubator.object)
                        } else {
                            incubator.object.destroy()
                        }
                    }
                }
                ++incubatorCreateCount
            } else {
                newComponentInit(incubator.object)
            }
        }
    }

    function delayRequestWifi() {
        if (!wifiManager.internetConnect) {
            requestArticlNeedNetWorkTip()
        }
    }

    Connections {
        target: mathExerciseManager

        function onExerciseResultChanged() {
            id_know_view_loader.active = false
            id_know_query_view_loader.active = false
            id_ques_query_view_loader.active = false
            id_ques_view_loader.active = true
            mathExerciseManager.setCurrentKey(mathExerciseManager.exerciseResult.questionCode)
        }

        function onQueryResultChanged() {
            id_ques_query_view_loader.active = true
            mathExerciseManager.setCurrentKey(mathExerciseManager.queryResult.questionCode)
        }

        function onQueryKnowResultChanged() {
            id_know_query_view_loader.active = true
        }
    }

    Connections {
        target: systemBase
        ignoreUnknownSignals: true

        function onOcrStart() {
            console.warn("YMathExercisePage.qml====onOcrStart")
            mathExerciseManager.entryResult(false)
            if (id_ques_view_loader.active && !mathExerciseManager.isEditing) {
                id_ques_view_loader.active = false
                mathExerciseManager.wipeData()
            }
        }
    }

    onShowSubPage: {
        if (subPageIndex === YEnum.Mathexercise_Home) {
            mathManager.mathExerciseDB.getNewContentCount()
        }

        if (mathexerciseSubPageIndexCur !== subPageIndex) {
            if (typeof bAddHistory != "undefined" && bAddHistory) {
                let iPosHave = exerciseSubPageHistory.indexOf(mathexerciseSubPageIndexCur)
                if (iPosHave >= 0) {
                    exerciseSubPageHistory.splice(iPosHave, 1)
                }
                iPosHave = exerciseSubPageHistory.indexOf(subPageIndex)
                if (iPosHave >= 0) {
                    exerciseSubPageHistory.splice(iPosHave, 1)
                }
                exerciseSubPageHistory.push(mathexerciseSubPageIndexCur)
            } else {
                exerciseSubPageHistory = []
            }
            mathexerciseSubPageIndexCur = subPageIndex
        }
    }

    onEntryFavResult: {
        mathExerciseManager.entryResult(true)
    }

    onEntryKnowledge: {
        id_know_view_loader.active = true
    }

    YLoader {
        id: id_math_tutor_loader
        anchors.fill: parent
        active: true
        asynchronous: false
        sourceComponent: {
            switch (mathexerciseSubPageIndexCur) {
            case YEnum.Mathexercise_Home:
                return id_mathexercise_home_component
            case YEnum.Mathexercise_Search:
                return id_mathexercise_result_component
            case YEnum.Mathexercise_Fav:
                return id_mathexercise_fav_component
            case YEnum.Mathexercise_Report:
                return id_mathexercise_statistics_component
            case YEnum.Mathexercise_Knowledge:
                return id_mathexercise_knowledge_component
            case YEnum.Mathexercise_Correct:
            case YEnum.Mathexercise_Guide:
            default:
                return null
            }
        }

        Component {
            id: id_mathtutor_guide_component
            YDialog {
            }
        }

        Component {
            id: id_mathexercise_home_component
            YMathExerciseHome {}
        }

        Component {
            id: id_mathexercise_result_component
            YMathExerciseSearchResult {
                id: id_result_item
                resultModel: mathExerciseManager.exerciseResult
            }
        }

        Component {
            id: id_mathexercise_knowledge_component
            YMathExerciseKnowledge {}
        }

        Component {
            id: id_mathexercise_fav_component
            YMathExerciseFavoriteView {}
        }

        Component {
            id: id_mathexercise_correct_component
            YMathExerciseCorrectItem {}
        }

        Component {
            id: id_mathexercise_statistics_component
            YMathExerciseStatistics {}
        }
    }

    YLoader {
        id: id_know_view_loader
        anchors.fill: parent
        asynchronous: false
        sourceComponent: YMathExerciseKnowledge {
            resultModel: mathManager.mathExerciseDB.knowShowModel
            onBackButtonClicked: {
                id_know_view_loader.active = false
            }
        }

        onActiveChanged: {
            if (!active) mathExerciseManager.processedVideoFinish()
        }
    }

    YLoader {
        id: id_know_query_view_loader
        anchors.fill: parent
        asynchronous: false
        sourceComponent: YMathExerciseKnowledge {
            isAssociationNeed: false
            resultModel: mathExerciseManager.queryKnowResult
            onBackButtonClicked: {
                id_know_query_view_loader.active = false
            }
        }

        onActiveChanged: {
            if (!active) mathExerciseManager.processedVideoFinish()
        }
    }

    YLoader {
        id: id_ques_view_loader
        anchors.fill: parent
        asynchronous: false
        sourceComponent: YMathExerciseSearchResult {
            resultModel: mathExerciseManager.exerciseResult
            onBackButtonClicked: {
                id_ques_view_loader.active = false
                mathExerciseManager.wipeData()
            }
        }

        onActiveChanged: {
            if (!active) mathExerciseManager.processedVideoFinish()
        }
    }

    YLoader {
        id: id_ques_query_view_loader
        anchors.fill: parent
        asynchronous: false
        sourceComponent: YMathExerciseSearchResult {
            isSimQuesNeed: false
            isTabBarNeed: false
            resultModel: mathExerciseManager.queryResult
            onBackButtonClicked: {
                id_ques_query_view_loader.active = false
            }
        }

        onActiveChanged: {
            if (!active && id_ques_view_loader.active) {
                mathExerciseManager.setCurrentKey(mathExerciseManager.exerciseResult.questionCode)
            }

            if (!active) mathExerciseManager.processedVideoFinish()
        }
    }

    Component {
        id: id_config_wifi_component

        YSettingWifi {
            id: id_setting_wifi_view

            YTimer {
                id: id_check_wifi_state_timer
                interval: 200
                repeat: true
                onTriggered: {
                    if (wifiManager.internetConnect) {
                        id_check_wifi_state_timer.stop()
                        YTimers.delayCall(500, id_setting_wifi_view.close)
                    }
                }
            }

            Component.onCompleted: {
                id_check_wifi_state_timer.start()
            }
        }
    }

    onVisibleChanged: {
        if (visible) {
            qmlGlobal.currentPageIndex = YEnum.PageIndex.MathTutor
            mathExerciseManager.entryExercise()
        } else {
            mathExerciseManager.setIsEditing(false)
            mathExerciseManager.processedVideoFinish()
        }
    }

    Component.onDestruction: {
        mathExerciseManager.exitExercise()
    }
}

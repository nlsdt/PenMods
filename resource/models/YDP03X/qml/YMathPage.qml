import QtQuick 2.12
import com.youdao.pen 1.0

import BaseQml 1.0
import "./math"
import "./i18n"

YPage {
    id: id_math_page
    objectName: "YPage===YMathPage.qml"
    states: [
        State {
            name: "CalculateGuide"
        },
        State {
            name: "CalculateResult"
        }
    ]
    // 根据 State 控制初始页面, 后续页面逻辑由各子页面控制.
    property var stateViewMap: {
        "CalculateGuide": id_calculate_guide_view,
        "CalculateResult": id_calculate_result_view,
    }

    YLoader {
        id: id_calculate_guide_view
        anchors.fill: parent
        asynchronous: false
        sourceComponent: YMathCalculateGuideView {
            onBackButtonClicked: {
                id_math_page.backButtonClicked()
            }
        }
    }


    YLoader {
        id: id_calculate_result_view
        anchors.fill: parent
        asynchronous: false
        sourceComponent: YMathCalculateResultView {
            yModel: mathManager.mathQueryEngine.calculateResult
            onBackButtonClicked: {
                mathManager.resetRootView()
            }
        }
    }


    function updateState(newState) {
        if (id_math_page.state === newState) {
            return
        }
        id_math_page.state = newState
        updateViews()
    }

    function updateViews() {
        let currentState = id_math_page.state
        if (currentState === "") {
            console.warn("YMathPage.qml===state uninitliazed", id_math_page.objectName)
            return
        }
        let stateViewMap = id_math_page.stateViewMap
        for (let state in stateViewMap) {
            if (state === currentState) {
                stateViewMap[state].active = true
            } else {
                stateViewMap[state].active = false
            }
        }
    }

    Connections {
        target: mathManager
        function onCurrentStateChanged() {
            updateState(mathManager.currentState)
        }
        function onQuestionSearchedFailed() {
            baseSignals.showToast(YTranslateText.mathQuestionNotFound, YColors.grayNormal)
        }
        function onEmptyOCRFound() {
            baseSignals.showToast(YTranslateText.cannotFindContentTryAgain, YColors.grayNormal)
        }
    }

    onVisibleChanged: {
        if (visible) {
            qmlGlobal.currentPageIndex = YEnum.PageIndex.Math
            updateState(mathManager.currentState)
        }
    }

    onBackButtonClicked: {
        mathManager.quitMath()
    }

    Component.onCompleted: {
        console.warn("YMathPage.qml===Component.onCompleted===called")
        updateState(mathManager.currentState)
    }

    Component.onDestruction: {
        console.warn("YMathPage.qml===Component.onDestruction===called")
    }
}

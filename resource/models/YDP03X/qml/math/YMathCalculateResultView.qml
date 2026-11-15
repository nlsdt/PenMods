import QtQuick 2.12
import BaseQml 1.0
import "../i18n"

YBackButtonView {
    id: id_calculate_result_view
    property var yModel: null

    YIconButton {
        id: id_scrollup_btn
        implicitWidth: 44
        implicitHeight: 44
        radius: 22
        anchors.horizontalCenter: id_calculate_result_view.backBar.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 18
        mouseAreaMargins: -20
        icon: "math/result-up"
        iconSourceSize: Qt.size(36, 36)
        visible: {
            if (!shouldShowWrongView()) { return false }
            return id_content_view.contentY > id_calculate_result_view.height
        }
        onClicked: {
            scrollUp()
        }
    }

    Flickable {
        id: id_content_view
        anchors.fill: parent
        anchors.leftMargin: 90
        anchors.rightMargin: 16
        contentHeight: id_column.height
        interactive: shouldShowWrongView()

        Column {
            id: id_column
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            spacing: 0

            YSpacingForColumn {
                implicitHeight: 22
            }
            Item {
                id: id_ocr_content
                anchors.left: parent.left
                anchors.right: parent.right
                height: 37
                Image {
                    id: id_ocr_latex
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    visible: {
                        if (yModel === null) { return false }
                        return yModel.ocrLatexImg.length > 0
                    }
                    source: {
                        if (yModel === null) {
                            return ""
                        } else {
                            return yModel.ocrLatexImg
                        }
                    }
                }
                YText {
                    id: id_cor_text
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    elide: YText.ElideRight
                    font.pixelSize: 28
                    color: YColors.grayText
                    visible: {
                        if (yModel === null) { return false }
                        return yModel.ocrLatexImg.length === 0
                    }
                    text: {
                        if (yModel === null) {
                            return ""
                        } else {
                            return yModel.ocrContent
                        }
                    }
                }
            }
            YSpacingForColumn {
                implicitHeight: 20
            }
            Item {
                id: id_error_content_view
                anchors.left: parent.left
                anchors.right: parent.right
                height: id_tab_result_view.tabViewHeight + 26
                visible: shouldShowWrongView()

                Rectangle {
                    id: id_bg_container
                    anchors.fill: parent
                    color: YColors.grayNormal
                    radius: 16
                }

                YTabView {
                    id: id_tab_result_view
                    anchors.fill: parent
                    anchors.bottomMargin: 20
                    headerViewHeight: 86
                    currentIdx: 0
                    headerComponent: id_tab_header

                    // Tab 栏的显示会根据 model 的删减子 Tab. YTabView 内部根据 validIndexes 处理 Idx 变化
                    // 默认该值为 所有 childrend 的 0..<length 的索引
                    headerTitles: {
                        if (hasRightAnswer() && hasErrorReason()) {
                            return [YTranslateText.mathRightAnswer,
                                    YTranslateText.mathWrongAnalysis]
                        } else if (hasRightAnswer()) {
                            return [YTranslateText.mathRightAnswer]
                        } else if (hasErrorReason()) {
                            return [YTranslateText.mathWrongAnalysis]
                        } else {
                            return []
                        }
                    }
                    controlValidSubView: true
                    validSubviews: {
                        if (hasRightAnswer() && hasErrorReason()) {
                            return [0, 1]
                        } else if (hasRightAnswer()) {
                            return [0]
                        } else if (hasErrorReason()) {
                            return [1]
                        } else {
                            return []
                        }
                    }

                    Image {
                        anchors.rightMargin: 12
                        anchors.leftMargin: 5
                        source: {
                            if (yModel === null) {
                                return ""
                            } else {
                                return yModel.rightAnswerImg
                            }
                        }
                    }
                    YText {
                        anchors.leftMargin: 20
                        anchors.rightMargin: 20
                        color: YColors.white
                        font.pixelSize: 28
                        wrapMode: Text.WrapAnywhere
                        textFormat: Text.RichText
                        text: {
                            if (yModel === null) {
                                return ""
                            } else {
                                return yModel.errorReason
                            }
                        }
                    }
                }
            }
            YSpacingForColumn {
                implicitHeight: 24
                visible: shouldShowWrongView()
            }
        }

        YMathCalculateTipBanner {
            id: id_result_banner
            visible: {
                if (yModel === null) {
                    return false
                }
                let state =  getAnswerState()
                if (yModel.isFromDB() && state !== YMathCalculateTipBanner.AnswerWrongNoAnswer) {
                    return false
                }
                if (state === YMathCalculateTipBanner.NoAnswerInCalculate ||
                    state === YMathCalculateTipBanner.PatternNotSupport) {
                    return false
                }
                return true
            }
            answerState: getAnswerState()
            onTipAnimationNeedShow: {
                sendLogAction()
                if (id_result_banner.answerState !== YMathCalculateTipBanner.NoAnswerInCalculate &&
                    id_result_banner.answerState !== YMathCalculateTipBanner.PatternNotSupport) {
                    return
                }

                id_math_no_answer_in_calculate_tips_dialog.active = false
                id_math_pattern_not_support_dialog.active = false

                if (yModel.isFromDB()) { return }

                if (id_result_banner.answerState === YMathCalculateTipBanner.NoAnswerInCalculate) {
                    id_math_no_answer_in_calculate_tips_dialog.active = true
                } else if (id_result_banner.answerState === YMathCalculateTipBanner.PatternNotSupport) {
                    id_math_pattern_not_support_dialog.active = true
                }
            }
        }
    }

    Component {
        id: id_tab_header
        YMathTabHeader{}
    }

    YLoader {
        id: id_math_no_answer_in_calculate_tips_dialog
        asynchronous: false
        anchors.fill: parent
        sourceComponent: YOneButtonDialog {
            anchors.fill: parent
            tipItem.text: YTranslateText.mathCalcAnswerEmpty
            buttonItem.text: YTranslateText.confirm
        }
        onLoaded: {
            item.closed.connect(popToRootView)
            item.clicked.connect(popToRootView)
            item.show()
        }
    }

    YLoader {
        id: id_math_pattern_not_support_dialog
        asynchronous: false
        anchors.fill: parent
        sourceComponent: YOneButtonDialog {
            anchors.fill: parent
            tipItem.text: YTranslateText.mathCalcAnswerUnsupport
            buttonItem.text: YTranslateText.confirm
        }
        onLoaded: {
            item.closed.connect(popToRootView)
            item.clicked.connect(popToRootView)
            item.show()
        }
    }

    function getAnswerState() {
        let currentModel = yModel
        if (currentModel === null) {
            return YMathCalculateTipBanner.NoAnswerInCalculate
        }
        if (currentModel.isRight()) {
            return YMathCalculateTipBanner.AnswerRight
        } else if (currentModel.isFracunreduced()) {
            return YMathCalculateTipBanner.AnswerFracunreduced
        } else if (currentModel.isWrong()) {
            if (!hasRightAnswer() && !hasErrorReason()) {
                return YMathCalculateTipBanner.AnswerWrongNoAnswer
            } else {
                return YMathCalculateTipBanner.AnswerWrong
            }
        } else if (currentModel.isUnAnswer()) {
            return YMathCalculateTipBanner.NoAnswerInCalculate
        } else if (currentModel.isUnSupport()) {
            return YMathCalculateTipBanner.PatternNotSupport
        } else {
            return YMathCalculateTipBanner.PatternNotSupport
        }
    }

    function hasRightAnswer() {
        if (yModel === null) { return false }
        return yModel.rightAnswerImg.length > 0
    }

    function hasErrorReason() {
        if (yModel === null) { return false }
        return yModel.errorReason.length > 0
    }

    function isWrongAnswer() {
        if (yModel === null) { return false }
        return yModel.isWrong()
    }

    function shouldShowWrongView() {
        return isWrongAnswer() && (hasRightAnswer()  || hasErrorReason())
    }

    function scrollUp() {
        id_content_view.contentY = 0
    }

    function popToRootView() {
        mathManager.resetRootView()
    }

    function sendLogAction() {
        if (yModel.isFromDB()) { return }

        logManager.sendHttpLog("action=math_result_show")

        switch (id_result_banner.answerState) {
        case YMathCalculateTipBanner.NoAnswerInCalculate:
            logManager.sendHttpLog("action=math_result_noscan_show")
            break
        case YMathCalculateTipBanner.AnswerRight:
            logManager.sendHttpLog("action=math_result_yes_show")
            break
        case YMathCalculateTipBanner.AnswerFracunreduced:
            logManager.sendHttpLog("action=math_result_yes_show")
            break
        case YMathCalculateTipBanner.AnswerWrong:
            logManager.sendHttpLog("action=math_result_no_show")
            break
        case YMathCalculateTipBanner.AnswerWrongNoAnswer:
            logManager.sendHttpLog("action=math_result_no_show")
            break
        case YMathCalculateTipBanner.PatternNotSupport:
            logManager.sendHttpLog("action=math_result_notext_show")
            break
        default:
            break
        }
    }

}

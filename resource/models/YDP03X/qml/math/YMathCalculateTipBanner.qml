import QtQuick 2.12
import com.youdao.pen 1.0
import BaseQml 1.0
import "../i18n"

Item {
    enum AnswerState {
        Invalid,
        NoAnswerInCalculate,
        AnswerRight,
        AnswerFracunreduced,
        AnswerWrong,
        AnswerWrongNoAnswer,
        PatternNotSupport
    }

    id: id_tip_banner
    property string bannerTip: YTranslateText.mathCalcAnswerEmpty
    property int answerState: YMathCalculateTipBanner.Invalid
    signal tipAnimationNeedShow()

    anchors.top: parent.top
    anchors.topMargin: 16
    anchors.right: parent.right
    anchors.rightMargin: 16
    width: {
        let widthWithOutLabel = 88
        return widthWithOutLabel + id_content_label.width
    }
    height: {
        let singleLineTextHeight = 50
        let doubleLineTextHeight = 82
        if (answerState === YMathCalculateTipBanner.AnswerFracunreduced) {
            return doubleLineTextHeight
        } else {
            return singleLineTextHeight
        }
    }

    Item {
        id:id_text_container
        anchors.fill: parent

        Rectangle {
            id: id_gray_bg
            anchors.fill: parent
            radius: id_tip_banner.height / 2
            color: YColors.grayButton
            opacity: 0.6
        }
        YImage {
            id: id_state_icon
            asynchronous: false
            anchors.left: parent.left
            anchors.leftMargin: 24
            anchors.verticalCenter: parent.verticalCenter
            sourceSize: Qt.size(28, 28)
            imageName: {
                switch (id_tip_banner.answerState) {
                case YMathCalculateTipBanner.NoAnswerInCalculate:
                    return "math/result-warn-mini"
                case YMathCalculateTipBanner.AnswerRight:
                    return "math/result-right-mini"
                case YMathCalculateTipBanner.AnswerFracunreduced:
                    return "math/result-right-mini"
                case YMathCalculateTipBanner.AnswerWrong:
                    return "math/result-wrong-mini"
                case YMathCalculateTipBanner.AnswerWrongNoAnswer:
                    return "math/result-warn-mini"
                case YMathCalculateTipBanner.PatternNotSupport:
                    return "math/result-warn-mini"
                default:
                    return "math/result-warn-mini"
                }
            }
        }
        YText {
            id: id_content_label
            anchors.left: id_state_icon.right
            anchors.leftMargin: 10
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 8
            color: YColors.white
            font.pixelSize: 26
            text: id_tip_banner.bannerTip
        }
        YText {
            id: id_content_extra_label
            anchors.bottom: id_content_label.top
            anchors.bottomMargin: 0
            anchors.left: id_content_label.left
            color: YColors.white
            font.pixelSize: 26
            // 目前仅在约分问题上展示.
            visible: answerState === YMathCalculateTipBanner.AnswerFracunreduced
            text: YTranslateText.mathCalcAnswerRight + "!"
        }
    }

    onAnswerStateChanged: {
        if (answerState === YMathCalculateTipBanner.NoAnswerInCalculate) {
            bannerTip = YTranslateText.mathCalcAnswerEmpty
        } else if (answerState === YMathCalculateTipBanner.AnswerRight) {
            bannerTip = YTranslateText.mathCalcAnswerRight
        } else if (answerState === YMathCalculateTipBanner.AnswerFracunreduced){
            bannerTip = YTranslateText.mathCalcAnswerFrcunreduce
        } else if (answerState === YMathCalculateTipBanner.AnswerWrong) {
            bannerTip = YTranslateText.mathCalcAnswerWrong
        } else if (answerState === YMathCalculateTipBanner.AnswerWrongNoAnswer) {
            bannerTip = YTranslateText.mathCalcAnswerWrongNoAnswer
        } else {
            bannerTip = YTranslateText.mathCalcAnswerUnsupport
        }

        id_tip_banner.tipAnimationNeedShow()
    }
}

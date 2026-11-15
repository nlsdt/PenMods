import QtQuick 2.12
import com.youdao.pen 1.0

import BaseQml 1.0
import "../components"
import "../i18n"

YAnswerQuestionDelegateItem {
    id: id_interactive_quizzes_delegate
    height: id_container.height

    readonly property var jsonModelData: model.modelData
    readonly property var jsonContent: jsonModelData.practice_content
    readonly property bool hasAudio: jsonContent.question_audio.length > 0
    readonly property bool hasGuideAudio: ("undefined" != typeof jsonContent.exam_guide.guide_audio) && (jsonContent.exam_guide.guide_audio.length > 0)
    readonly property string questionText: jsonContent.question_text
    readonly property bool isFiveType: "five" === state
    readonly property string contentType: interactiveLearningManager.contentType
    readonly property int optionsCount: jsonContent.question_options.length
    readonly property int columnsCount: id_grid_container.columns

    readonly property int currentTextLength: {
        let tmpLength = 0
        jsonContent.question_options.forEach(function(optionItem){
            tmpLength = Math.max(optionItem.option_text.length, tmpLength)
        })
        return tmpLength
    }

    state: jsonModelData.practice_type

    function play() {
        id_delay_play_timer.restart()
    }

    YTimer {
        id: id_delay_play_timer
        interval: 360
        onTriggered: {
            if (visible) {
                if (!isBrowseMode) {
                    if (hasGuideAudio) {
                        playMp3Source(jsonContent.exam_guide.guide_audio)
                    }
                } else {
                    playQuestionAudio()
                }
            }
        }

        function playQuestionAudio() {
            if (hasAudio) {
                playMp3Source(jsonContent.question_audio)
            } else if ("word" === contentType) {
                playTTS(interactiveLearningManager.currentSearchString)
            }
        }
    }

    onEndPlay: {
        if (visible && !isBrowseMode
                && (jsonContent.exam_guide.guide_audio === playingFileName)
                && (selectabled && (0 === answerResult.length))) {
            id_delay_play_timer.playQuestionAudio()
        }
    }

    YLoader {
        id: id_five_type_title_icon_loader
        anchors.verticalCenter: id_container.verticalCenter
        active: "five" === id_interactive_quizzes_delegate.state
        sourceComponent: Item {
            implicitWidth: 214
            implicitHeight: 214
            Rectangle {
                anchors.fill: parent
                color: "#27282C"
                radius: id_icon.maskItem.radius
            }
            YOpacityMaskImage {
                id: id_icon
                anchors.fill: parent
                maskItem.radius: 28
                source: ("undefined" != typeof jsonContent.question_image) ? jsonContent.question_image.toLoadFileUrl() : ""
            }
        }
    }

    Column {
        id: id_container
        anchors.left: parent.left
        anchors.leftMargin: "five" === id_interactive_quizzes_delegate.state ? 230 : 0
        anchors.right: parent.right

        YSpacingForColumn {
            implicitHeight: {
                switch (id_interactive_quizzes_delegate.state) {
                case "one":
                    return 0
                case "two":
                    return -6
                case "three":
                    if ("word" === contentType) {
                        return 4
                    }
                    return 0
                case "four":
                    return 4
                case "five":
                    return 0
                }
            }
        }

        Grid {
            id: id_grid_container
            anchors.left: parent.left
            anchors.leftMargin: {
                switch (id_interactive_quizzes_delegate.state) {
                case "one":
                case "two":
                    return 3 === optionsCount ? -6 : 40
                case "three":
                    if ("word" === contentType) {
                        return 4
                    }
                    return 3 === optionsCount ? -6 : 40
                case "five":
                    return 0
                case "four":
                    return 40
                }
            }
            anchors.right: parent.right
            anchors.rightMargin: {
                switch (id_interactive_quizzes_delegate.state) {
                case "one":
                case "two":
                    return 3 === optionsCount ? -6 : 40
                case "three":
                    if ("word" === contentType) {
                        return 4
                    }
                    return 3 === optionsCount ? -6 : 40
                case "five":
                    return 0
                case "four":
                    return 40
                }
            }

            columns: {
                switch (id_interactive_quizzes_delegate.state) {
                case "one":
                case "two":
                    return optionsCount
                case "three":
                    if ("word" === contentType) {
                        return 1
                    }
                    return optionsCount
                case "five":
                    return 1
                case "four":
                    return 2
                }
            }

            spacing: {
                switch (id_interactive_quizzes_delegate.state) {
                case "five":
                    return 10
                default:
                    return 40
                }
            }

            Repeater {
                id: id_question_repeater
                model: jsonContent.question_options
                delegate: {
                    switch (id_interactive_quizzes_delegate.state) {
                    case "one":
                    case "three":
                    case "five":
                        return id_question_one_type
                    case "two":
                    case "four":
                        return id_question_two_type // same as two type
                    }
                }
            }
        }
    }

    Component {
        id: id_question_one_type
        YQuizLearningStartToAnswerTextQuestionItem {
            onClicked: {
                positionItemIntoView(this)
            }
        }
    }

    Component {
        id: id_question_two_type
        YQuizLearningStartToAnswerImageQuestionItem {
            onClicked: {
                positionItemIntoView(this)
            }
        }
    }

    function positionItemIntoView(item) {
        const posY = item.mapToItem(id_quiz_view_flickable, 0, 0).y
        if (posY < 0) {
            id_quiz_view_flickable.contentY -= Math.abs(posY)
        } else {
            if ((posY + item.height) > id_quiz_view_flickable.height) {
                id_quiz_view_flickable.contentY += ((posY + item.height) - id_quiz_view_flickable.height)
            }
        }
    }

    Component.onCompleted: {
        console.warn("YInteractiveQuizzesDelegate.qml===id_interactive_quizzes_delegate.state: ",
                     id_interactive_quizzes_delegate.state)
    }
}

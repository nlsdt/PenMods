import QtQuick 2.12
import com.youdao.pen 1.0

import BaseQml 1.0
import "../components"
import "../i18n"

YAnswerQuestionDelegateItem {
    id: id_interactive_quizzes_delegate
    height: id_container.height

    readonly property var jsonContent: JSON.parse(model.modelData)
    readonly property bool isFiveType: ("five" === state) || (("elephant_eight" === state) && !hasGuideAudio && !hasQuestionAudio)
    readonly property bool isLookImageSelectAnswer: ("five" === state) || ("elephant_eight" === state)
    readonly property bool isElephantQuestionType: ("elephant_four" === state) || ("elephant_eight" === state)
    readonly property bool hasGuideAudio: ("undefined" != typeof jsonContent.exam_guide) && (jsonContent.exam_guide.guide_audio.length > 0)
    readonly property bool hasQuestionAudio: ("undefined" != typeof jsonContent.question_audio) && (jsonContent.question_audio.length > 0)

    property bool currentItemPlayabled: true

    state: jsonContent.exam_type

    function play() {
        id_delay_play_timer.restart()
    }

    YTimer {
        id: id_delay_play_timer
        interval: 360
        onTriggered: {
            if (hasGuideAudio) {
                if (visible) {
                    playMp3Source(jsonContent.exam_guide.guide_audio)
                }
            } else if (hasQuestionAudio) {
                if (visible) {
                    playMp3Source(jsonContent.question_audio)
                }
            } else {
                qmlGlobal.stopAllAnimationMusic()
            }
        }
    }

    onEndPlay: {
        if (visible && hasGuideAudio && hasQuestionAudio
                && (jsonContent.exam_guide.guide_audio === playingFileName)
                && (selectabled && (0 === answerResult.length))) {
            playMp3Source(jsonContent.question_audio)
        }
    }

    onVisibleChanged: {
        if (visible && currentItemPlayabled) {
            play()
        }
    }

    Column {
        id: id_container
        anchors.left: parent.left
        anchors.right: parent.right

        Item {
            anchors.left: parent.left
            anchors.right: parent.right
            height: 120
            visible: {
                if (isLookImageSelectAnswer) {
                    return !id_five_type_title_icon_loader.isLoaded
                }
                return !id_other_type_title_icon_loader.isLoaded
            }
        }

        YLoader {
            id: id_five_type_title_icon_loader
            anchors.horizontalCenter: parent.horizontalCenter
            active: isLookImageSelectAnswer
            sourceComponent: YOpacityMaskImage {
                implicitWidth: 214
                implicitHeight: 214
                maskItem.radius: 28
                source: {
                    if ("undefined" != typeof jsonContent.question_image) {
                        return jsonContent.question_image.toLoadFileUrl()
                    }
                    return ""
                }
            }
        }

        YLoader {
            id: id_other_type_title_icon_loader
            active: !isLookImageSelectAnswer
            anchors.left: parent.left
            anchors.right: parent.right
            sourceComponent: Rectangle {
                height: id_title_content_container.height
                radius: 40
                color: "#993C3C72"

                Column {
                    id: id_title_content_container
                    anchors.left: parent.left
                    anchors.right: parent.right

                    YSpacingForColumn {
                        implicitHeight: 30
                    }

                    YTextMedium {
                        id: id_title
                        anchors.left: parent.left
                        anchors.leftMargin: 30
                        anchors.right: parent.right
                        anchors.rightMargin: 30
                        font.weight: Font.ExtraBold
                        font.family: {
                            if (text.match(/[\u3400-\u9FBF]/)) {
                                return fontManager.fontFamilyZhCn
                            }
                            return fontManager.fontFamilyEnUs
                        }
                        text: {
                            if (YEnum.QLT_RedRocket === qmlGlobal.currentQuizLearningType) {
                                if (("undefined" != typeof jsonContent.question_text)
                                        && (jsonContent.question_text.length > 0)) {
                                    return jsonContent.question_text.trim()
                                }
                                return "听一听，选一选"
                            } else {
                                switch (id_interactive_quizzes_delegate.state) {
                                case "one":
                                case "two":
                                    return jsonContent.question_text.trim()
                                case "elephant_four":
                                    const questionContent = jsonContent.question_text.trim()
                                    return questionContent.length > 0 ? questionContent : "听一听，选一选"
                                default:
                                    return "听一听，选一选"
                                }
                            }
                        }
                        wrapMode: YTextMedium.Wrap
                        horizontalAlignment: (1 === lineCount)
                                             ? YTextMedium.AlignHCenter
                                             : YTextMedium.AlignLeft
                        font.pixelSize: 28
                    }

                    YSpacingForColumn {
                        implicitHeight: 30
                    }
                }
            }
        }

        YSpacingForColumn {
            implicitHeight: id_five_type_title_icon_loader.active ? 34 : 24
        }

        YImage {
            width: 168
            height: 24
            anchors.horizontalCenter: parent.horizontalCenter
            sourceSize: Qt.size(168, 24)
            imageName: "touchreading/quiz_div_line"
        }

        YSpacingForColumn {
            implicitHeight: 12
        }

        Grid {
            anchors.horizontalCenter: parent.horizontalCenter

            columns: {
                switch (id_interactive_quizzes_delegate.state) {
                case "one":
                case "three":
                case "five":
                    return 1
                case "two":
                case "four":
                case "elephant_four":
                case "elephant_eight":
                    return 3
                }
            }

            spacing: {
                switch (id_interactive_quizzes_delegate.state) {
                case "one":
                case "three":
                case "five":
                    return 8
                case "two":
                case "four":
                case "elephant_four":
                case "elephant_eight":
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
                    case "elephant_four":
                    case "elephant_eight":
                        return id_question_two_type // same as two type
                    }
                }
            }
        }
    }

    Component {
        id: id_question_one_type
        YInteractiveQuizzesTextQuestionItem {
            onClicked: {
                positionItemIntoView(this)
            }
        }
    }

    Component {
        id: id_question_two_type
        YInteractiveQuizzesImageQuestionItem {
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

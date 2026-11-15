import QtQuick 2.12
import com.youdao.pen 1.0

import BaseQml 1.0
import "../i18n"

YTouchFollowReadingAudioPlayBase {
    id: id_result_item
    implicitWidth: YBaseEnum.Screen.Width
    implicitHeight: YBaseEnum.Screen.Height

    enum StarCount {
        SC_One = 1,
        SC_Two,
        SC_Three
    }

    signal backButtonClicked()
    signal callBrowse()
    signal callTryAgain()

    property string todoPlayingMp3Filename: ""
    property alias lastImage: id_last_image.imageName
    property var closeButtonCallback: null

    function playAnimation() {
        id_last_image.visible = false
        id_buttons_bg.waittingShow = true
        id_top_screen_animation.play()
        id_delay_show_timer.restart()
    }

    function stopAnimation() {
        currentPlayingBaseImageName = ""
        id_buttons_bg.waittingShow = false
        id_top_screen_animation.stopPlay()
        id_last_image.visible = true
    }

    function play(correctCount, totalCount) {
        id_star_image.starCount = YInteractiveQuizzesScorePageResultAnimation.StarCount.SC_One
        if (correctCount !== totalCount) {
            const score = correctCount * 100.0/ totalCount
            if (score >= 80) {
                id_star_image.starCount = YInteractiveQuizzesScorePageResultAnimation.StarCount.SC_Three
            } else if (score >= 60) {
                id_star_image.starCount = YInteractiveQuizzesScorePageResultAnimation.StarCount.SC_Two
            }
        } else {
            id_star_image.starCount = YInteractiveQuizzesScorePageResultAnimation.StarCount.SC_Three
        }

        const randomNumber = Math.randomInt(2)

        switch (id_star_image.starCount) {
        case YInteractiveQuizzesScorePageResultAnimation.StarCount.SC_One:
            if (0 === randomNumber) {
                currentPlayingBaseImageName = "score_not_bad"
                todoPlayingMp3Filename = "reading-answer-onestar1"
                lastImage = "large_animation/score_not_bad_last"
            } else {
                currentPlayingBaseImageName = "score_try_again"
                todoPlayingMp3Filename = "reading-answer-onestar2"
                lastImage = "large_animation/score_try_again_last"
            }
            break
        case YInteractiveQuizzesScorePageResultAnimation.StarCount.SC_Two:
            if (0 === randomNumber) {
                currentPlayingBaseImageName = "score_good_job"
                todoPlayingMp3Filename = "reading-answer-twostar1"
                lastImage = "large_animation/score_good_job_last"
            } else {
                currentPlayingBaseImageName = "score_very_good"
                todoPlayingMp3Filename = "reading-answer-twostar2"
                lastImage = "large_animation/score_very_good_last"
            }
            break
        case YInteractiveQuizzesScorePageResultAnimation.StarCount.SC_Three:
            if (0 === randomNumber) {
                currentPlayingBaseImageName = "score_excellent"
                todoPlayingMp3Filename = "reading-answer-threestar1"
                lastImage = "large_animation/score_excellent_last"
            } else {
                currentPlayingBaseImageName = "score_perfect"
                todoPlayingMp3Filename = "reading-answer-threestar2"
                lastImage = "large_animation/score_perfect_last"
            }
            break
        }
        playAnimation()
        readingBookQuizManager.quizStars = id_star_image.starCount
    }

    onEndPlay: {
        if (visible && (todoPlayingMp3Filename === playingFileName)) {
            stopAnimation()
        }
    }

    YBackground {
        anchors.fill: parent
        color: YColors.touchReadingBg
    }

    YImage {
        id: id_buttons_bg
        width: 770
        height: 96
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        sourceSize: Qt.size(770, 96)
        imageName: "touchreading/score_buttons_bg"

        property bool waittingShow: false

        Row {
            anchors.centerIn: parent
            spacing: 30

            YButton {
                id: id_browse_button
                implicitWidth: 310
                implicitHeight: 72
                color: "#644FEC"
                pixelSize: 26
                textFamily: fontManager.fontFamilyZhCn
                text: YTranslateText.answerDetail
                onClicked: {
                    stopAnimation()
                    stop()
                    callBrowse()
                }
            }

            YButton {
                id: id_try_again_button
                implicitWidth: 310
                implicitHeight: 72
                color: "#644FEC"
                pixelSize: 26
                textFamily: fontManager.fontFamilyZhCn
                text: YTranslateText.tryAgain
                onClicked: {
                    stopAnimation()
                    stop()
                    callTryAgain()
                    backButtonClicked()
                }
            }
        }
    }

    YImage {
        id: id_last_image
        anchors.horizontalCenter: parent.horizontalCenter
        sourceSize: Qt.size(700, 180)
        visible: false

        YImage {
            id: id_star_image
            anchors.horizontalCenter: parent.horizontalCenter
            sourceSize: Qt.size(200, 90)
            anchors.top: parent.top
            anchors.topMargin: 2
            property int starCount: 0
            imageName: {
                switch (starCount) {
                case YInteractiveQuizzesScorePageResultAnimation.StarCount.SC_One:
                    return "touchreading/report_one_star"
                case YInteractiveQuizzesScorePageResultAnimation.StarCount.SC_Two:
                    return "touchreading/report_two_stars"
                case YInteractiveQuizzesScorePageResultAnimation.StarCount.SC_Three:
                    return "touchreading/report_three_stars"
                default:
                    return ""
                }
            }
        }
    }

    Rectangle {
        id: id_back_button
        anchors.top: parent.top
        anchors.topMargin: showMargin
        anchors.right: parent.right
        anchors.rightMargin: showMargin
        implicitWidth: 115
        implicitHeight: 115
        color: "#663C3C72"
        radius: 58
        visible: !id_buttons_bg.waittingShow

        opacity: id_back_button_ma.pressed ? 0.6 : 1
        property int showMargin: -52

        YImage {
            anchors.top: parent.top
            anchors.topMargin: 60
            anchors.right: parent.right
            anchors.rightMargin: 60
            sourceSize: Qt.size(38, 38)
            imageName: "touchreading/medal_set_close"
        }

        YBackButtonBase {
            id: id_back_button_ma
            anchors.fill: parent
            anchors.bottomMargin: -60
            anchors.leftMargin: -60
            objectName: "YInteractiveQuizzesScorePageResultAnimation.qml_id_back_button"
            onTriggered: {
                id_top_screen_animation.stopPlay()
                stop()
                if (null === closeButtonCallback) {
                    qmlGlobal.requestTouchReadingPage(YEnum.ShelfSeries)
                } else {
                    closeButtonCallback()
                }
            }
        }
    }

    YAnimatedImagesView {
        id: id_top_screen_animation
        objectName: "YInteractiveQuizzesScorePageResultAnimation.qml"
        anchors.fill: parent
        frameCountLoop: 90
        imageNameLoop: currentPlayingBaseImageName
    }

    Connections {
        target: systemBase
        ignoreUnknownSignals: true
        function onHomeKeyRelease() {
            id_top_screen_animation.stopPlay()
        }
    }

    YTimer {
        id: id_delay_show_timer
        interval: 900
        onTriggered: {
            id_result_item.visible = true
            playMp3(todoPlayingMp3Filename)
        }
    }
}

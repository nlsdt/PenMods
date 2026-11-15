import QtQuick 2.12
import com.youdao.pen 1.0

import BaseQml 1.0
import "../i18n"

YMouseArea {
    id: id_touch_cover_interactive_quizzes_tips
    objectName: "YInteractiveQuizzesIndexGuide.qml_object"
    enabled: !id_delay_clickable_timer.running
    anchors.fill: parent

    function play() {
        id_reading_animation.play()
    }

    function stop() {
        // do not stop here, click screen stop
    }

    signal backButtonClicked()

    onClicked: {
        if (YEnum.QLT_Default === qmlGlobal.currentQuizLearningType) {
            readingBookQuizManager.enterQuiz()
        }
        if (null !== interactiveQuizzesIndex) {
            qmlGlobal.stopAllAnimationMusic()
            interactiveQuizzesIndex.delayPlay()
            id_reading_animation.stopPlay()
            tip_item.visible = false
        }
    }

    Item {
        id: tip_item
        anchors.fill: parent

        YImage {
            sourceSize: Qt.size(800, 254)
            imageName: "touchreading/scan_touch_bg"

            YAnimatedImagesView {
                id: id_reading_animation
                objectName: "YInteractiveQuizzesIndexGuide.qml"
                frameSize: Qt.size(420, 240)
                anchors.right: parent.right
                anchors.rightMargin: 34
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 14
                frameCount: 46
                imageName: "matti_high_five"
                frameCountLoop: 46
                imageNameLoop: "matti_high_five_loop"
            }
        }

        YImage {
            id: id_scan_touch_tips_intersperse
            sourceSize: Qt.size(31, 10)
            imageName: "touchreading/scan_touch_tips_intersperse"
            anchors.left: parent.left
            anchors.leftMargin: 60
            anchors.top: parent.top
            anchors.topMargin: 88
        }

        YTextMedium {
            id: id_title
            anchors.left: parent.left
            anchors.leftMargin: 56
            anchors.top: id_scan_touch_tips_intersperse.bottom
            anchors.topMargin: 8
            font.pixelSize: 38
            font.wordSpacing: 2
            text: YTranslateText.quizzesTogether
            font.family: fontManager.fontFamilyZhCn
        }

        YText {
            anchors.left: id_title.left
            anchors.top: id_title.bottom
            anchors.topMargin: 20
            font.pixelSize: 22
            text: YTranslateText.highFiveWithMatti
            font.family: fontManager.fontFamilyZhCn
        }
    }

    Item {
        id: id_interactive_quizzes_index_container
        anchors.fill: parent
    }

    Component {
        id: id_interactive_quizzes_index_component
        YInteractiveQuizzesIndex {
            onBackButtonClicked: {
                id_touch_cover_interactive_quizzes_tips.backButtonClicked()
            }
        }
    }

    property var interactiveQuizzesIndex: null
    property int incubatorCreateCount: 0

    function delayBuild() {
        const incubator = id_interactive_quizzes_index_component.incubateObject(
                                  id_interactive_quizzes_index_container);
        if (incubator.status !== Component.Ready) {
            incubator.onStatusChanged = function(status) {
                if (status === Component.Ready) {
                    if (0 === --incubatorCreateCount) {
                        interactiveQuizzesIndex = incubator.object
                    } else {
                        incubator.object.destroy()
                    }
                }
            }
            ++incubatorCreateCount
        } else {
            interactiveQuizzesIndex = incubator.object
        }
    }

    Component.onCompleted: {
        Qt.callLater(delayBuild)
        id_delay_clickable_timer.restart()
    }

    YTimer {
        id: id_delay_clickable_timer
        interval: 600
    }
}

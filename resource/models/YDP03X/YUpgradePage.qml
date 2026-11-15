import QtQuick 2.12
import com.youdao.pen 1.0
import BaseQml 1.0
import "./qml/commons"
// import "./qml/utils/utils.js" as UTILS
import "./qml/i18n"
//import "./qml/timers"

YWindow {
    // property int leftSeconds: 900
    // property int currentProgress: 0

    property int leftSeconds: resourceMananger.timeLeft
    property int currentProgress: resourceMananger.progress


    function updateTips() {
        let time
        if (leftSeconds > 60) {
            let m = Math.min(30, parseInt(leftSeconds/60))
            switch (qmlTranslator.showLanguage) {
            case YEnum.EN_US:
                time = m + " minutes"
                break
            default:
                time = m + "分钟"
                break
            }
        } else {
            let m = Math.max(1, leftSeconds)
            switch (qmlTranslator.showLanguage) {
            case YEnum.EN_US:
                time = m + " seconds"
                break
            default:
                time = m + "秒钟"
                break
            }
        }
        id_tips.text = YTranslateText.upgradeTips.arg(time)
    }

    YBackground {
        id: id_background
        anchors.fill: parent

        YClickedCountMouseArea {
            anchors.fill: parent
            onTriggered: {
                resourceMananger.exportLogFile()
            }
            objectName: "YUpgradePage.qml_id_log_output_button"
        }

        YProgressIndicator {
            id: id_progress_indicator
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            anchors.topMargin: 40
            progress: Math.min(100, Math.max(5, currentProgress))
        }

        YText {
            id: id_tips
            color: "#909199"
            font.pixelSize: {
                switch (qmlTranslator.showLanguage) {
                case YEnum.EN_US:
                    return 24
                }
                return 26
            }
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: id_progress_indicator.bottom
            anchors.topMargin: {
                switch (qmlTranslator.showLanguage) {
                case YEnum.EN_US:
                    return 8
                }
                return 6
            }
        }

//        YAnimatedImagesView {
//            id: id_animation
//            objectName: "YUpgradePage.qml"
//            implicitWidth: 520
//            implicitHeight: 130
//            frameSize: Qt.size(520, 130)
//            anchors.horizontalCenter: parent.horizontalCenter
//            anchors.bottom: parent.bottom
//            frameCountLoop: 90
//            imageNameLoop: "ota_upgrade"
//            clip: false
//        }

        YImage {
            width: 520
            height: 130
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            sourceSize: Qt.size(520, 130)
            imageName: "ota_loading"
        }
    }

    onLeftSecondsChanged: {
        updateTips()
    }

//    YTimer {
//        id: id_test_timer
//        interval: 3000
//        repeat: true
//        onTriggered: {
//            currentProgress += 10
//            leftSeconds -= 100
//            if (!id_animation.running) {
//                id_animation.play()
//            }
//        }
//    }

//    Connections
//    {
//        target: resourceMananger
//       function onStateChanged(state)
//       {


//       }
//    }

    Component.onCompleted: {
        updateTips()
//        YTimers.delayCall(120, id_animation.play)

        console.log("wangqiang------------------resourceMananger.timeLeft", resourceMananger.timeLeft)
        console.log("wangqiang------------------resourceMananger.progress", resourceMananger.progress)

        // id_test_timer.restart()
    }
}

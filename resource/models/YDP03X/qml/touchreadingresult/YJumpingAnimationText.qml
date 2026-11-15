import QtQuick 2.12
import com.youdao.pen 1.0

import BaseQml 1.0

Item {
    id: id_jumping_animation_text

    height: isTranslateType ? (isTranslateShowing ? id_content_text.paintedHeight : 1) : 56
    width: isTranslateType || ("zh-CHS" === readingBookReadingManager.originLanguage) ? ( !readingBookReadingManager.isFollow ? 680 : 640)
                                                                             : (id_content_text.initWidth + 20)

    property int interval: 1000
    property alias content: id_content_text.text
    property int playState: 0
    property bool isActive: false
    property int textType: 0
    property bool playabled: true
    property bool followHitState: false
    property int readingBookType: YEnum.RBT_Touch
    property bool audioPlayStateIsFinished: false

    readonly property bool isTranslateType: YEnum.AniTextTypeTrans === textType
    readonly property bool isReadingBookTypeIsTouch: YEnum.RBT_Touch === readingBookType
    readonly property bool isPlaying: playabled && (isReadingBookTypeIsTouch ? (YEnum.AnimationStart === playState) : followHitState)
    readonly property bool isTranslateShowing: !readingBookReadingManager.translationDataEmpty
                                               && (YEnum.RBTT_ZH_CN === settingManager.readingBookTranslateType)

    signal callMonkeyRejump()
    signal textAnimationStart()
    signal textAnimationFinished()

    function restart() {
        callMonkeyRejump();
        id_content_text_animation.restart()
    }

    function stopAnimation() {
        id_content_text_animation.stop()
    }

    YTextBase {
        id: id_content_text
        font.family: (isTranslateType
                      || ("zh-CHS" === readingBookReadingManager.originLanguage))
                     ? fontManager.fontFamilyZhCn : fontManager.fontFamilyEnUs
        font.pixelSize: {
            if (isTranslateType) {
                return 26
            }
            return 34
        }
        font.weight: {
            if (isTranslateType) {
                return Font.Normal
            }
            return Font.Bold
        }
        anchors.left: parent.left
        anchors.leftMargin: isTranslateType ? 10 : 0
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        wrapMode: {
            if (isTranslateType) {
                return YTextBase.Wrap
            }
            return YTextBase.NoWrap
        }
        horizontalAlignment: {
            if (isTranslateType) {
                return YTextBase.AlignLeft
            }
            return YTextBase.AlignHCenter
        }
        color: {
            if (isTranslateType) {
                if (isTranslateShowing) {
                    return isActive ? "#B9B7E7" : "#1EB9B7E7"
                }
                return "transparent"
            }
            if (isReadingBookTypeIsTouch) {
                switch (playState) {
                case YEnum.AnimationStart:
                    restart()
                    return "#557AFF"
                case YEnum.AnimationEnd:
                    stopAnimation()
                    return isActive ? "#557AFF" : "#1EFFFFFF"
                case YEnum.AnimationNormal:
                default:
                    break
                }
            } else {
                if (isFollowing && followHitState) {
                    restart()
                    return "#557AFF"
                }
            }
            stopAnimation()
            return isActive ? "#FFFFFF" : "#1EFFFFFF"
        }

        property int initWidth: 20

        SequentialAnimation {
            id: id_content_text_animation
            alwaysRunToEnd: true
            ScriptAction {
                script: textAnimationStart()
            }
            PropertyAnimation {
                target: id_content_text
                property: "anchors.bottomMargin"
                to: 20
                duration: 240
            }
            ScriptAction {
                script: textAnimationFinished()
            }
            PropertyAnimation {
                target: id_content_text
                property: "anchors.bottomMargin"
                to: 0
                duration: 240
            }
        }

        YMouseArea {
            id: id_jumping_animation_text_mouse_area
            anchors.fill: parent
            anchors.margins: -5
            enabled: audioPlayStateIsFinished && isReadingBookTypeIsTouch && !isTranslateType
            onClicked: {
                qmlGlobal.stopAllAnimationMusic()
                readingBookReadingManager.stopAudio()
                playabled = false
                stopAnimation()
                qmlGlobal.showDictFromTouchReadingBook(id_content_text.text)
            }
            objectName: "id_jumping_animation_text_mouse_area"
        }

        Component.onCompleted: {
            initWidth = paintedWidth
        }
    }
}



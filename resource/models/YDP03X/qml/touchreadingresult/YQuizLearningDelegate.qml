import QtQuick 2.12
import com.youdao.pen 1.0

import BaseQml 1.0
import "../components"
import "../i18n"

YTouchFollowReadingAudioPlayBase {
    id: id_word_card_item
    width: ListView.view.width
    height: isLastTipMessage ? 100 : 216
    visible: index === ListView.view.currentIndex

    readonly property var jsonContent: model.modelData
    property var explainImgs: jsonContent.explain_imgs
    property int explainImgsCount: explainImgs.length
    readonly property bool isLastTipMessage: ("undefined" != typeof jsonContent.last_tip_message)
    readonly property bool hasTranAudio: ("undefined" != typeof jsonContent.tran_audio)
    property alias sourceComponent: id_content_loader.sourceComponent
    readonly property bool hasAudio: ("undefined" != typeof jsonContent.explain_audio) && (jsonContent.explain_audio.length > 0)
    property bool currentItemPlayabled: true

    function play() {
        id_delay_play_timer.restart()
    }

    YTimer {
        id: id_delay_play_timer
        interval: 120
        onTriggered: {
            if (!isLastTipMessage) {
                if (hasAudio) {
                    if (visible) {
                        playMp3Source(jsonContent.explain_audio)
                    }
                } else {
                    qmlGlobal.stopAllAnimationMusic()
                }
            } else {
                playMp3("reading-question-start")
            }
        }
    }

    onEndPlay: {
        if (visible && hasTranAudio
                && (jsonContent.explain_audio === playingFileName)) {
            playMp3Source(jsonContent.tran_audio)
        }
    }

    onVisibleChanged: {
        if (visible && currentItemPlayabled) {
            play()
        }
    }

    YLoader {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.topMargin: -44
        height: 220
        active: isLastTipMessage
        sourceComponent: YQuizLearningStartToAnswerTip {
            onStartToAnswer: {
                id_quiz_learning.startToAnswer()
            }
        }
    }

    YLoader {
        id: id_content_loader
        anchors.fill: parent
        active: !isLastTipMessage
        sourceComponent: Rectangle {
            color: YColors.grayNormal
            radius: 28

            Row {
                id: id_row_images
                anchors.verticalCenter: parent.verticalCenter
                spacing: explainImgsCount > 1 ? 6 : 0

                Item {
                    implicitWidth: 6
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    visible: (explainImgsCount > 1) && id_icon_left.visible
                             && id_icon_right.visible
                }

                YOpacityMaskImage {
                    id: id_icon_left
                    width: explainImgsCount > 1 ? 86 : 110
                    height: explainImgsCount > 1 ? 86 : 110
                    maskItem.radius: explainImgsCount > 1 ? 16 : 28
                    source: {
                        if (explainImgsCount > 0
                                && explainImgs[0].length > 0
                                && qmlGlobal.fileExists(explainImgs[0])) {
                            return explainImgs[0].toLoadFileUrl()
                        }
                        return ""
                    }
                    visible: source.toString().length
                }

                YOpacityMaskImage {
                    id: id_icon_right
                    width: 86
                    height: 86
                    maskItem.radius: 16
                    source: {
                        if (explainImgsCount > 1
                                && explainImgs[1].length > 0
                                && qmlGlobal.fileExists(explainImgs[1])) {
                            return explainImgs[1].toLoadFileUrl()
                        }
                        return ""
                    }
                    visible: source.toString().length
                }
            }

            Item {
                id: id_text_container
                implicitHeight: 110
                width: parent.width - ((id_icon_left.visible || id_icon_right.visible)
                                       ? id_row_images.width : 0)
                anchors.right: parent.right

                Column {
                    id: id_column_text
                    spacing: 0
                    width: Math.max(id_pinyin.width, id_text.width)
                    anchors.centerIn: parent

                    YText {
                        id: id_pinyin
                        font.family: fontManager.fontFamilyEnUs
                        font.weight: Font.DemiBold
                        font.pixelSize: 24
                        text: {
                            if ("undefined" != typeof jsonContent.pinyin_text) {
                                return jsonContent.pinyin_text
                            }
                            return ""
                        }
                        visible: text.length > 0
                        wrapMode: Text.NoWrap
                        anchors.horizontalCenter: parent.horizontalCenter
                    }

                    YTextMedium {
                        id: id_text
                        width: paintedWidth
                        height: paintedHeight
                        font.family: fontManager.fontFamilyZhCn
                        font.pixelSize: 54
                        textFormat: YTextMedium.RichText
                        text: {
                            const sourceText = jsonContent.explain_text
                            if (sourceText.length > 1) {
                                return sourceText.replaceAll(id_quiz_learning.contentKey,
                                                             ('<font color="#FF7E08">%1</font>').arg(
                                                                 id_quiz_learning.contentKey))
                            }
                            return sourceText
                        }
                        wrapMode: Text.NoWrap
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                }
            }
        }
    }

}

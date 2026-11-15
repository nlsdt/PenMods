import QtQuick 2.12
import com.youdao.pen 1.0

import BaseQml 1.0
import "../components"

YBackgroundIgnoreMouseEvent {
    id: id_word_large_book_question
    anchors.fill: parent
    visible: false

    signal backButtonClicked()

    // {"option_code":["66924972","66924973","66924974"],
    //  "question_audio":"/tmp/questionAudio.wav",
    //  "question_text":"Yellow and blue makes..."}
    readonly property var jsonContent: JSON.parse(readingBookQuestionOptionManager.questionContent)
    readonly property bool hasAudio: ("undefined" != typeof jsonContent.question_audio)
                                     && (jsonContent.question_audio.length > 0)
    readonly property bool hasIcon: ("undefined" != typeof jsonContent.question_image)
                                    && (jsonContent.question_image.length > 0)

    function play() {
        visible = true
        id_container.playQuestionAudio()
    }

    function stop() {
        qmlGlobal.stopAllAnimationMusic()
    }

    YTouchFollowReadingAudioPlayBase {
        id: id_container
        anchors.fill: parent

        function playQuestionAudio() {
            if (hasAudio) {
                playMp3Source(jsonContent.question_audio)
                id_listennig_button.play()
            }
        }

        Flickable {
            id: id_word_large_book_question_view_flickable

            anchors.fill: parent
            anchors.leftMargin: 68
            anchors.rightMargin: 68
            contentHeight: id_column.height

            Column {
                id: id_column
                spacing: 0
                anchors.left: parent.left
                anchors.right: parent.right

                YSpacingForColumn {
                    implicitHeight: 72
                }

                Item {
                    id: id_word_large_book_question_view
                    anchors.left: parent.left
                    anchors.right: parent.right
                    height: hasIcon ? Math.max(id_question_icon.height, id_text_item.height)
                                    : Math.max(110, id_text_item.height)

                    YOpacityMaskImage {
                        id: id_question_icon
                        implicitWidth: 140
                        implicitHeight: 140
                        maskItem.radius: 28
                        source: hasIcon ? jsonContent.question_image.toLoadFileUrl() : ""
                        visible: hasIcon
                    }

                    YTextBase {
                        id: id_text_item
                        anchors.right: parent.right
                        anchors.rightMargin: 6
                        anchors.left: hasIcon ? id_question_icon.right : parent.left
                        anchors.leftMargin: hasIcon ? 20 : 0
                        height: paintedHeight
                        font.family: fontManager.fontFamilyZhCn
                        font.weight: Font.Bold
                        font.pixelSize: 34
                        color: YColors.white
                        wrapMode: YTextEnUs.Wrap
                        horizontalAlignment: lineCount > 1 ? Text.AlignLeft : Text.AlignHCenter
                        anchors.verticalCenter: parent.verticalCenter
                        text: jsonContent.question_text
                    }
                }

                YSpacingForColumn {
                    implicitHeight: 16
                }

                YTextMedium {
                    id: id_tips
                    anchors.left: parent.left
                    anchors.right: parent.right
                    height: 20
                    horizontalAlignment: YTextMedium.AlignHCenter
                    font.family: fontManager.fontFamilyZhCn
                    textFormat: YTextMedium.RichText
                    text: '接下来<font color="#FF7E08">点击书本</font>进行答题吧!'
                }

                YSpacingForColumn {
                    implicitHeight: 12
                }
            }
        }

        YTitleAreaBase {
            id: id_title_area
            anchors.topMargin: - id_word_large_book_question_view_flickable.contentY

            onCallBack: {
                stop()
                id_word_large_book_question.visible = false
                backButtonClicked()
            }

            YListennigButton {
                id: id_listennig_button
                onCurrentFrameChanged: {
                    if (-1 === id_container.currentPlayId) {
                        stopPlay()
                    }
                }
            }
        }

        Component.onCompleted: {
            id_listennig_button.validClicked.connect(function() {
                if (-1 === currentPlayId) {
                    playQuestionAudio()
                } else {
                    id_container.stop()
                }
            })
        }
    }

}

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

    readonly property var jsonObject: model.modelData
    readonly property var jsonContent: jsonObject.practice_content
    readonly property bool hasAudio: ("undefined" != typeof jsonContent.hanzi_audio) && (jsonContent.hanzi_audio.length > 0)
    property bool currentItemPlayabled: true
    readonly property bool isLastTipMessage: ("undefined" != typeof jsonObject.last_tip_message)

    function play() {
        id_delay_play_timer.restart()
    }

    signal startPlayGame()

    YTimer {
        id: id_delay_play_timer
        interval: 360
        onTriggered: {
            if (!isLastTipMessage && hasAudio) {
                if (visible) {
                    playMp3Source(jsonContent.hanzi_audio)
                }
            } else {
                qmlGlobal.stopAllAnimationMusic()
            }
        }
    }

    onVisibleChanged: {
        if (visible && currentItemPlayabled) {
            if (isLastTipMessage) {
                startPlayGame()
            }
            play()
        }
    }

    YLoader {
        id: id_content_loader
        anchors.fill: parent
        active: !isLastTipMessage
        sourceComponent: Rectangle {
            id: id_content
            anchors.left: parent.left
            anchors.right: parent.right
            height: Math.max(id_column_text.height + 10, 110)
            color: YColors.grayNormal
            radius: 28

            Column {
                id: id_column_text
                spacing: 0
                anchors.left: parent.left
                anchors.leftMargin: 25
                anchors.right: parent.right
                anchors.rightMargin: 25
                anchors.verticalCenter: parent.verticalCenter

                YTextMedium {
                    id: id_pinyin
                    font.family: fontManager.fontFamilyPinyin
                    font.pixelSize: ("undefined" != typeof jsonContent.pinyin_text) && jsonContent.pinyin_text.length > 14 ? 32 : 40
                    textFormat: YTextMedium.RichText

                    function indexesOfAll(source, search, caseSensitive) {
                        const searchLength = search.length;
                        if (0 === searchLength) {
                            return [];
                        }
                        let startIndex = 0, index, indexes = [];
                        if (!caseSensitive) {
                            source = source.toLowerCase();
                            search = search.toLowerCase();
                        }
                        while ((index = source.indexOf(search, startIndex)) > -1) {
                            indexes.push(index);
                            startIndex = index + searchLength;
                        }
                        return indexes;
                    }

                    text: {
                        if ("undefined" != typeof jsonContent.pinyin_text) {
                            if (0 === index) {
                                id_quiz_learning.xiaoXiangPinyin = jsonContent.pinyin_text
                            }
                            const sourceText = jsonContent.hanzi_text
                            if (sourceText.length > 0) {
                                const arrHighlightIndexes = indexesOfAll(sourceText, id_quiz_learning.contentKey)
                                jsonContent.pinyin_text.trim()
                                let arrPinyins = jsonContent.pinyin_text.split(/\s+/)
                                arrHighlightIndexes.forEach(function(hIndex){
                                    const tmpPinyin = arrPinyins[hIndex]
                                    arrPinyins[hIndex] = ('<font color="#FF7E08">%1</font>').arg(tmpPinyin)
                                })
                                const pinyinText = arrPinyins.join(" ")
                                return pinyinText
                            }
                        }
                        return ""
                    }
                    visible: (text.length > 0) && (jsonContent.hanzi_text.length <= 4)
                    wrapMode: Text.NoWrap
                    anchors.horizontalCenter: parent.horizontalCenter
                }

                YTextMedium {
                    id: id_text
                    width: paintedWidth
                    height: paintedHeight
                    font.family: fontManager.fontFamilyZhCn
                    font.pixelSize: (jsonContent.hanzi_text.length < 6) ? 72 : 56
                    textFormat: YTextMedium.RichText
                    text: {
                        const sourceText = jsonContent.hanzi_text
                        if (sourceText.length > 0) {
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

import QtQuick 2.12
import com.youdao.pen 1.0

import BaseQml 1.0
import "../components"
import "../i18n"

YTouchFollowReadingAudioPlayBase {
    id: id_word_card_item
    width: ListView.view.width
    height: isLastTipMessage ? 156 : id_container.height
    visible: index === ListView.view.currentIndex

    readonly property var jsonObject: JSON.parse(model.modelData)
    readonly property var jsonContent: jsonObject.content
    readonly property bool isLastTipMessage: ("undefined" != typeof jsonContent.last_tip_message)
    readonly property bool hasAudio: ("undefined" != typeof jsonContent.word_audio) && (jsonContent.word_audio.length > 0)
    property bool isEnglish: "en" === jsonContent.word_lan

    property bool isSpellEnabled: isEnglish && ("undefined" != typeof jsonContent.phonics)
    property bool isFollowEnabled: (("undefined" != typeof jsonContent.follow) && jsonContent.follow)
                                            || (("undefined" != typeof jsonContent.is_follow) && jsonContent.is_follow)

    property bool useDefaultLastTipMessage: true
    property bool currentItemPlayabled: true

    readonly property string wordText: ("undefined" != typeof jsonContent.word_text)
                                       ? jsonContent.word_text.trim() : (("undefined" != typeof jsonContent.word) ? jsonContent.word.trim() : "")

    function play() {
        id_delay_play_timer.restart()
    }

    YTimer {
        id: id_delay_play_timer
        interval: 360
        onTriggered: {
            if (!isLastTipMessage) {
                if (hasAudio) {
                    if (visible) {
                        playMp3Source(jsonContent.word_audio)
                    }
                } else {
                    qmlGlobal.stopAllAnimationMusic()
                }
            } else {
                playMp3("reading-guide-tip")
            }
        }
    }

    onVisibleChanged: {
        if (visible && currentItemPlayabled) {
            play()
        }
    }

    onEndPlay: {
        if (isBookMetalGet && isEnglish && (1 === ListView.view.count)) {
            showBookMetal() // for word large book get medal
        }
    }

    YLoader {
        anchors.left: parent.left
        anchors.leftMargin: 56 - 70
        anchors.right: parent.right
        anchors.rightMargin: 29 - 70
        anchors.top: parent.top
        active: useDefaultLastTipMessage && isLastTipMessage
        sourceComponent: Item {
            implicitHeight: id_word_card_item.height

            YImage {
                width: 271
                height: 155
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                sourceSize: Qt.size(271, 155)
                imageName: "wordcards/word_cards_last_tip"
            }

            Column {
                anchors.left: parent.left
                spacing: 6
                anchors.verticalCenter: parent.verticalCenter

                YImage {
                    sourceSize: Qt.size(31, 10)
                    imageName: "touchreading/scan_touch_tips_intersperse"
                    anchors.left: parent.left
                    anchors.leftMargin: 4
                }

                YTextMedium {
                    id: id_tips
                    font.pixelSize: 32
                    font.family: fontManager.fontFamilyZhCn
                    textFormat: YTextMedium.RichText
                    text: '你真棒！<br>用词典笔<font color="#FF7E08">点击书上文字/图片</font><br>开启阅读呦!'
                }
            }

        }
    }

    Item {
        id: id_container
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.rightMargin: 112 - 70
        height:id_icon.visible ?  Math.max(id_column_text.height, id_icon.height) : id_column_text.height

        YOpacityMaskImage {
            id: id_icon
            width: 164
            height: 164
            maskItem.radius: 28
            source: {
                if ("undefined" != typeof jsonContent.word_image) {
                    return jsonContent.word_image.toLoadFileUrl()
                }
                return ""
            }
            visible: source.toString().length
        }

        Column {
            id: id_column_text
            anchors.left: id_icon.visible ? id_icon.right : parent.left
            anchors.leftMargin: 28
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            spacing: 0

            TextMetrics {
                id: id_text_metrics
                font: id_text.font
                elide: id_text.elide
                elideWidth: id_text.width
                text: wordText
            }

            YText {
                id: id_text
                width: 396
                font.family: isEnglish ? fontManager.fontFamilyEnUs : fontManager.fontFamilyZhCn
                font.weight: Font.DemiBold
                text: wordText
                Component.onCompleted: {
                    font.pixelSize = (id_text_metrics.elidedText === text) ? (text.length <= 12 ? 48 : 32) : 26
                }
                elide: Text.ElideRight
                maximumLineCount: {
                    if (isEnglish) {
                        return isSpellEnabled || isFollowEnabled ? 2 : 3
                    }
                    return isFollowEnabled ? 2 : 3
                }
                wrapMode: Text.Wrap
            }

            YSpacingForColumn {
                implicitHeight: 20
            }

            Column {
                id: id_word_tran_column
                anchors.left: parent.left
                anchors.right: parent.right
                spacing: 12
                visible: isEnglish && (id_word_dicts.count > 0) && !id_word_dicts.isEmptyData

                Repeater {
                    id: id_word_dicts
                    model: isEnglish ? jsonContent.word_dicts : null

                    property bool isEmptyData: false

                    Item {
                        width: id_word_tran_column.width
                        height: Math.max(id_word_speech_container.height, id_word_tran.height)

                        Item {
                            id: id_word_speech_container
                            implicitHeight: 37
                            width: id_word_speech.width

                            YText {
                                id: id_word_speech
                                font.family: fontManager.fontFamilyClass
                                font.pixelSize: 24
                                color: YColors.grayText
                                textFormat: YTextBase.RichText
                                width: paintedWidth
                                height: 30
                                text: '<span style="font-style: italic">' + model.modelData.word_speech + ' </span>'
                                anchors.bottom: parent.bottom
                                anchors.left: parent.left
                                anchors.leftMargin: 2
                            }
                        }

                        YText {
                            id: id_word_tran
                            font.family: fontManager.fontFamilyZhCn
                            font.pixelSize: 28
                            color: YColors.white
                            wrapMode: YTextBase.Wrap
                            height: paintedHeight
                            text: Array.isArray(model.modelData.word_tran) ? model.modelData.word_tran.join("；") : model.modelData.word_tran
                            anchors.left: id_word_speech_container.right
                            anchors.leftMargin: 12
                            anchors.right: parent.right
                            anchors.bottom: parent.bottom
                        }

                        Component.onCompleted: {
                            if ((0 === index)
                                    && (0 === model.modelData.word_speech.length)
                                    && (0 === id_word_tran.text.length)) {
                                id_word_dicts.isEmptyData = true
                            }
                        }
                    }
                }
            }

            YLoader {
                active: isEnglish && (id_word_dicts.count > 0) && !id_word_dicts.isEmptyData
                anchors.left: parent.left
                anchors.right: parent.right
                sourceComponent: YSpacingForColumn {
                    implicitHeight: 20
                }
            }
        }
    }

    YLoader {
        active: isEnglish && !isLastTipMessage
        anchors.top: parent.top
        anchors.topMargin: 92 - 76
        anchors.right: parent.right
        anchors.rightMargin: 16 - 70
        sourceComponent: Item {
            implicitWidth: 80
            implicitHeight: 148

            YIconButton {
                implicitWidth: 80
                implicitHeight: 70
                sourceSize: Qt.size(44, 44)
                icon: "dict/follow-pron"
                visible: isFollowEnabled
                onValidClicked: {
                    followManager.ukPhonetic = "";
                    followManager.usPhonetic = "";
                    followManager.content = wordText
                    followManager.classLog = ""
                    //logManager.sendHttpLog("action=listening_broadcasting_readfollow_click")
                    followManager.clearResult()
                    qmlGlobal.showFollowPage(false)
                }
            }

            YIconButton {
                implicitWidth: 80
                implicitHeight: 70
                anchors.bottom: parent.bottom
                sourceSize: Qt.size(44, 44)
                icon: "dict/spelling"
                visible: isSpellEnabled
                onValidClicked: {
                    console.log("YWordCardDelegate.qml_spell_clicked")
                    spellManager.phonics  = JSON.stringify(jsonContent.phonics)
                    soundCenter.stop();
                    spellManager.content = wordText
                    spellManager.richContent = wordText
                    spellManager.reset();
                    qmlGlobal.showSpellPage('{"ukSoundButtonVisible": "false",' +
                                            ' "usSoundButtonVisible": "false",' +
                                            ' "spellButtonVisible": "false",' +
                                            ' "followButtonVisible": "false" }');
                }
            }
        }
    }

}

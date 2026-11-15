import QtQuick 2.12
import QtQml.Models 2.12
import com.youdao.pen 1.0

import BaseQml 1.0
import "../i18n"

Item {
    id: id_content_container
    anchors.fill: parent
    anchors.leftMargin: 90
    anchors.rightMargin: 112
    readonly property bool isPlaying: YEnum.PLAYING === mediaPlayerManager.playState
    readonly property bool noLrcTip: isShowing && ((YEnum.LS_HIDE === lrcStateList[lrcStateIndex])
                                                   || !mediaPlayerManager.hasLrc)

    function show() {
        id_delay_show_lrc_timer.restart()
        id_delay_play_state_pause_confirm_timer.restart()
    }

    function playStatePauseConfirm() {
        if (!isPlaying) {
            id_player_state_mask_show.reshow()
        }
    }

    onNoLrcTipChanged: {
        if (noLrcTip) {
            id_delay_show_tip_timer.restart()
        } else {
            id_delay_show_tip_timer.stop()
            id_delay_show_tip.visible = false
        }
    }

    YBaseListView {
        id: id_lrc_main_show
        anchors {fill: parent}
        spacing: 16
        currentIndex: mediaPlayerManager.currentSentenceId >= 0? mediaPlayerManager.currentSentenceId : 0
        model: id_lrc_filter_model
        header: id_header_component
        footer: id_footer_component
        onCurrentIndexChanged: {
            positionViewAtIndex(currentIndex, ListView.Center)
        }
        Component.onCompleted: {
            positionViewAtIndex(currentIndex, ListView.Center)
        }

        onContentHeightChanged: {
            positionViewAtIndex(currentIndex, ListView.Center)
        }

        NumberAnimation { target: id_lrc_main_show; property: "contentY"; duration: 1000 }
    }

    Component {
        id: id_header_component
        Item {
            width: id_lrc_main_show.width
            implicitHeight: 80
            YBackground {
                id: id_title_area
                implicitHeight: 80
                anchors.left: parent.left
                anchors.right: parent.right

                YText {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    font.pixelSize: 26
                    color: YColors.grayText
                    elide: YText.ElideRight
                    font.family: fontManager.fontFamilyZhCn
                    text: mediaPlayerManager.title
                }
            }
        }
    }

    Component {
        id: id_footer_component
        Item {
            width: id_lrc_main_show.width
            implicitHeight: 80
            YBackground {
                anchors.fill: parent
            }

        }
    }

    DelegateModel {
        id: id_lrc_filter_model
        model: mediaPlayerManager

        delegate: Item {
            width: id_lrc_main_show.width
            height: id_sentence_column.implicitHeight
            anchors {left: parent.left; right: parent.right}

            property string mainLrc: model.modelData.mainLrc
            property string transLrc: model.modelData.transLrc
            property bool isCurrentLrc: model.modelData.id === mediaPlayerManager.currentSentenceId
            property bool hasKeyPoint: model.modelData.hasKeyPoint

            function getCompactFontFamily(lrc) {
                if (mediaPlayerManager.playerMode === YEnum.PM_AudioPlayer)
                    return fontManager.fontFamilyZhCn // 都用中文字体，避免显示异常
                else
                    return fontManager.fontFamilyEnUs // 教材同步用英文字体
//                let lrcfamily = fontManager.fontFamilyEnUs
//                switch (qmlTranslator.guessTextLang(lrc)) {
//                case YEnum.ZH_CN:
//                    lrcfamily = fontManager.fontFamilyZhCn
//                    break
//                default:
//                    break
//                }
//                return lrcfamily
            }

            Column {
                id: id_sentence_column
                spacing: 4
                anchors {left: parent.left; right: parent.right; top: parent.top}

                YTextMedium {
                    id: id_sentence_main_lrc
                    width: parent.width
                    lineHeightMode: Text.FixedHeight
                    lineHeight: 42
                    wrapMode: TextEdit.Wrap
                    font.pixelSize: 30
                    textFormat: YText.RichText
                    font.bold: false
                    opacity: isCurrentLrc ? 1.0 : 0.16
                    visible: isShowing && !id_delay_show_lrc_timer.running && mediaPlayerManager.hasLrc &&
                             ((YEnum.LS_BILINGUAL === lrcStateList[lrcStateIndex]) || (YEnum.LS_ORIGINAL === lrcStateList[lrcStateIndex]))
                    text: {
                        let txt = ''
                        if (visible) {
                            let lrcfamily = getCompactFontFamily(mainLrc)
                            if (isCurrentLrc) {
                                let endIndex = mediaPlayerManager.sentencePlayingEnd > 0 ? mediaPlayerManager.sentencePlayingEnd :
                                                                                           (hasKeyPoint? 0: mainLrc.length)
                                let playedTxt = mainLrc.substring(0, endIndex)
                                txt += ('<span style="font-family: %1; color:%2">%3</span>')
                                .arg(lrcfamily).arg(YColors.blueText).arg(playedTxt)

                                if (endIndex < mainLrc.length) {
                                    txt += ('<span style="font-family: %1; color:%2">%3</span>')
                                    .arg(lrcfamily).arg(YColors.white).arg(mainLrc.substring(endIndex))
                                }
                            } else {
                                txt += ('<span style="font-family: %1">%2</span>')
                                .arg(lrcfamily).arg(mainLrc)
                            }
                        }
                        return txt
                    }
                }

                YText {
                    id: id_sentence_trans_lrc
                    width: parent.width
                    lineHeightMode: Text.FixedHeight
                    lineHeight: 40
                    wrapMode: TextEdit.Wrap
                    anchors.topMargin: 6
                    textFormat: YText.RichText
                    opacity: isCurrentLrc ? 1.0 : 0.16
                    visible: isShowing && !id_delay_show_lrc_timer.running && mediaPlayerManager.hasLrc &&
                             ((YEnum.LS_BILINGUAL === lrcStateList[lrcStateIndex]) || (YEnum.LS_TRANS === lrcStateList[lrcStateIndex]))
                             && transLrc.length > 0
                    text: {
                        let txt = ''
                        if (visible) {
                            let lrcfamily = getCompactFontFamily(transLrc)
                            if (isCurrentLrc) {
                                if (id_sentence_main_lrc.visible) {
                                    txt += ('<span style="font-family: %1; color:%2">%3</span>')
                                    .arg(lrcfamily).arg(YColors.grayText).arg(transLrc)
                                } else {
                                    txt += ('<span style="font-family: %1; color:%2">%3</span>')
                                    .arg(lrcfamily).arg(YColors.blueText).arg(transLrc)
                                }
                            }
                            else {
                                txt += ('<span style="font-family: %1">%2</span>')
                                .arg(lrcfamily).arg(transLrc)
                            }
                        }
                        return txt
                    }
                }
            }
        }
    }

    YTimer {
        id: id_delay_show_lrc_timer
        interval: 900
    }

    YTimer {
        id: id_delay_play_state_pause_confirm_timer
        interval: 120
        onTriggered: {
            playStatePauseConfirm()
        }
    }

    YAudioPlayerLrcMouseArea {
        objectName: "YAudioPlayer.qml_YText_hasLrc_YMouseArea"
    }

    Item {
        id: id_content_column
        anchors {fill: parent; topMargin: 80}

        YTimer {
            id: id_delay_show_tip_timer
            interval: 500
            onTriggered: {
                if (noLrcTip) {
                    id_delay_show_tip.visible = true
                }
            }
        }

        YSpacingForColumn {
            id: id_delay_show_tip
            implicitHeight: 254 - 80
            visible: false

            YMouseArea {
                anchors.fill: parent
                anchors.topMargin: -80
                anchors.bottomMargin: -30
                objectName: "YAudioPlayer.qml_id_no_any_lrc"
                enabled: !id_player_state_mask_container.visible
                onClicked: {
                    id_player_state_mask_show.show()
                }
            }

            Item {
                id: id_no_lrc_show_container
                anchors.top: parent.top
                anchors.topMargin: 40
                anchors.horizontalCenter: parent.horizontalCenter

                width: id_button_icon.width + 9 + id_label.width
                implicitHeight: 36

                YImage {
                    id: id_button_icon
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    sourceSize: Qt.size(36, 36)
                    imageName: {
                        if (!mediaPlayerManager.hasLrc) {
                            return "audioplayer/no_lrc"
                        }
                        if (YEnum.LS_HIDE === lrcStateList[lrcStateIndex]) {
                            return "audioplayer/hide_lrc"
                        }
                        return ""
                    }
                }

                YText {
                    id: id_label
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    color: YColors.grayText
                    width: paintedWidth
                    height: paintedHeight
                    text: {
                        if (!mediaPlayerManager.hasLrc) {
                            return YTranslateText.noSubtitles
                        }
                        if (YEnum.LS_HIDE === lrcStateList[lrcStateIndex]) {
                            return YTranslateText.subtitleHidden
                        }
                        return ""
                    }
                }

                YAudioPlayerLrcMouseArea {
                    objectName: "YAudioPlayer.qml_YText_noLrc_YMouseArea"
                }
            }
        }
    }

    Item {
        id: id_player_state_mask_container
        anchors.fill: parent
        visible: false

        Rectangle {
            id: id_player_state_mask
            anchors.fill: parent
            enabled: false
            color: "#000000"
            radius: 0

            QtObject {
                id: id_player_state_mask_show

                function show() {
                    mediaPlayerManager.onClickedPause()
                    reshow()
                }

                function reshow() {
                    id_player_state_mask_hide.stop()
                    id_player_state_mask_container.visible = true
                    id_player_state_mask.opacity = 0.8
                    id_player_state_center_indicator.opacity = 1
                    id_player_state_mask.enabled = true
                }
            }

            SequentialAnimation {
                id: id_player_state_mask_hide
                ScriptAction {
                    script: {
                        id_player_state_mask.enabled = false
                    }
                }
                ParallelAnimation {
                    NumberAnimation { target: id_player_state_mask; property: "opacity"; to: 0; duration: 1200 }
                    NumberAnimation { target: id_player_state_center_indicator; property: "opacity"; to: 0; duration: 1200 }
                }
                ScriptAction { script: id_player_state_mask_container.visible = false }
            }
        }

        Rectangle {
            id: id_player_state_center_indicator
            implicitWidth: 80
            implicitHeight: 80
            anchors.centerIn: parent
            radius: height/2
            color: YColors.red

            YImage {
                id: id_play_button
                sourceSize: Qt.size(44, 44)
                anchors.centerIn: parent
                imageName: !isPlaying ? "audioplayer/pause" : "audioplayer/play"
            }

            YMouseArea {
                anchors.fill: parent
                anchors.margins: -20
                onClicked: {
                    mediaPlayerManager.onClickedPlay()
                }
            }

            YImage {
                id: id_play_previous_button
                sourceSize: Qt.size(54, 54)
                anchors.right: parent.left
                anchors.rightMargin: 80
                anchors.verticalCenter: parent.verticalCenter
                imageName: "audioplayer/previous54"

                YMouseArea {
                    anchors.fill: parent
                    anchors.margins: -20
                    onClicked: {
                        console.log("YAudioPlayerLrcContent.qml === id_play_previous_button.onClicked")
                        mediaPlayerManager.onClickedPrev()
                    }
                }
            }

            YImage {
                id: id_play_next_button
                sourceSize: Qt.size(54, 54)
                anchors.left: parent.right
                anchors.leftMargin: 80
                anchors.verticalCenter: parent.verticalCenter
                imageName: "audioplayer/next54"

                YMouseArea {
                    anchors.fill: parent
                    anchors.margins: -20
                    onClicked: {
                        console.log("YAudioPlayerLrcContent.qml === id_play_previous_button.onClicked")
                        mediaPlayerManager.onClickedNext()
                    }
                }
            }

        }
    }

    onIsPlayingChanged: {
        if (isPlaying) {
            id_player_state_mask_hide.restart()
        }
        else {
            id_player_state_mask_show.reshow()
        }
    }

    
    Connections {
        target: wifiManager
        enabled: playerMode === YEnum.PM_StoreAudio
        ignoreUnknownSignals: true
        function onInternetConnectChanged() {
            if(!wifiManager.internetConnect) {
                 id_player_state_mask_show.show()
            }
        }
    }
}


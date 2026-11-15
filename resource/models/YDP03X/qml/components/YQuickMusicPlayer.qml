import QtQuick 2.12
import com.youdao.pen 1.0
import BaseQml 1.0
import com.github.penuniverse 1.0

import "../common"

Item {
    id: id_quick_music_player
    readonly property real uiScale: Math.max(0.75, Math.min(width / 320, height / 170))
    anchors.fill: parent

    signal adjustSettingsRequested()
    signal playerRequested()

    property bool showProgress: true

    // 插件媒体会话优先，否则用宿主播放器
    readonly property bool pluginSession: typeof mediaSession !== "undefined" && mediaSession.active

    readonly property bool isPlaying: pluginSession
                                      ? mediaSession.playState === MediaSession.Playing
                                      : mediaPlayerManager.playState === YEnum.PLAYING
    readonly property string currentTitle: pluginSession ? (mediaSession.title || "")
                                                         : (mediaPlayerManager.title || "")
    readonly property var currentSentenceData: id_lrc_view.currentItem ? id_lrc_view.currentItem["lyricData"] : null
    readonly property string currentMainLyric: pluginSession
                                               ? (mediaSession.hasLyrics ? (mediaSession.mainLyric || "") : "")
                                               : (!mediaPlayerManager.hasLrc
                                                  ? ""
                                                  : (currentSentenceData && currentSentenceData.mainLrc
                                                     ? currentSentenceData.mainLrc
                                                     : (mediaPlayerManager.mainLrc || "")))
    readonly property string currentTranslationLyric: pluginSession
                                                      ? (mediaSession.hasLyrics ? (mediaSession.transLyric || "") : "")
                                                      : (currentSentenceData && currentSentenceData.transLrc
                                                         ? currentSentenceData.transLrc
                                                         : "")
    // 0 ~ 100
    readonly property real currentProgress: {
        if (pluginSession) {
            if (mediaSession.duration <= 0) return 0
            return Math.max(0, Math.min(100, mediaSession.position * 100 / mediaSession.duration))
        }
        return Math.max(0, Math.min(100, mediaPlayerManager.progress))
    }

    // 极简进度条：贴在面板顶部，蓝色
    Rectangle {
        id: id_progress_track
        visible: id_quick_music_player.showProgress
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        height: 2 * id_quick_music_player.uiScale
        color: "#2EFFFFFF"

        Rectangle {
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            width: parent.width * id_quick_music_player.currentProgress / 100.0
            color: YColors.blueText
        }
    }

    ListView {
        id: id_lrc_view
        width: 1 * id_quick_music_player.uiScale
        height: 1 * id_quick_music_player.uiScale
        visible: true
        opacity: 0
        interactive: false
        currentIndex: !pluginSession && mediaPlayerManager.currentSentenceId >= 0 ? mediaPlayerManager.currentSentenceId : 0
        model: pluginSession ? null : mediaPlayerManager
        delegate: Item {
            property var lyricData: model.modelData
        }
    }

    Item {
        id: id_title
        anchors.left: parent.left
        anchors.leftMargin: 16 * id_quick_music_player.uiScale
        anchors.right: id_adjust_button.left
        anchors.rightMargin: 6 * id_quick_music_player.uiScale
        anchors.top: parent.top
        anchors.topMargin: 8 * id_quick_music_player.uiScale
        height: 22 * id_quick_music_player.uiScale
        clip: true

        YTextMedium {
            id: id_title_text
            height: parent.height
            width: paintedWidth
            verticalAlignment: YTextMedium.AlignVCenter
            font.pixelSize: 16 * id_quick_music_player.uiScale
            elide: Text.ElideNone
            wrapMode: Text.NoWrap
            text: currentTitle
            onTextChanged: {
                x = 0
                if (id_title_text.paintedWidth > id_title.width)
                    id_title_marquee.restart()
            }

            SequentialAnimation {
                id: id_title_marquee
                loops: Animation.Infinite
                running: id_title_text.paintedWidth > id_title.width
                NumberAnimation {
                    target: id_title_text
                    property: "x"
                    from: 0
                    to: -(id_title_text.paintedWidth - id_title.width)
                    duration: Math.max(1500, (id_title_text.paintedWidth - id_title.width) * 28)
                    easing.type: Easing.Linear
                }
                PauseAnimation { duration: 700 }
                PropertyAction { target: id_title_text; property: "x"; value: 0 }
                PauseAnimation { duration: 700 }
            }
        }
    }

    YIconButton {
        id: id_adjust_button
        anchors.right: parent.right
        anchors.rightMargin: 10 * id_quick_music_player.uiScale
        anchors.top: parent.top
        anchors.topMargin: 8 * id_quick_music_player.uiScale
        implicitWidth: 30 * id_quick_music_player.uiScale
        implicitHeight: 30 * id_quick_music_player.uiScale
        radius: 8 * id_quick_music_player.uiScale
        mouseAreaMargins: -4
        sourceSize: Qt.size(20, 20)
        imageName: "audioplayer/more_settings"
        onValidClicked: adjustSettingsRequested()
        objectName: "YQuickMusicPlayer.qml_id_adjust_button"
    }

    Item {
        id: id_lyric
        anchors.left: parent.left
        anchors.leftMargin: 16 * id_quick_music_player.uiScale
        anchors.right: id_adjust_button.left
        anchors.rightMargin: 8 * id_quick_music_player.uiScale
        anchors.top: id_title.bottom
        anchors.topMargin: 1 * id_quick_music_player.uiScale
        height: 38 * id_quick_music_player.uiScale
        Item {
            id: id_main_lyric_view
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            height: 18 * id_quick_music_player.uiScale
            clip: true

            YText {
                id: id_main_lyric_text
                height: parent.height
                width: paintedWidth
                verticalAlignment: YText.AlignVCenter
                color: YColors.grayText
                font.pixelSize: 14 * id_quick_music_player.uiScale
                elide: Text.ElideNone
                wrapMode: Text.NoWrap
                text: currentMainLyric.length > 0 ? currentMainLyric
                                                   : (currentTranslationLyric.length > 0 ? "" : "暂无歌词")
                onTextChanged: {
                    x = 0
                    if (id_main_lyric_text.paintedWidth > id_main_lyric_view.width)
                        id_main_lyric_marquee.restart()
                }

                SequentialAnimation {
                    id: id_main_lyric_marquee
                    loops: Animation.Infinite
                    running: id_main_lyric_text.paintedWidth > id_main_lyric_view.width
                    NumberAnimation {
                        target: id_main_lyric_text
                        property: "x"
                        from: 0
                        to: -(id_main_lyric_text.paintedWidth - id_main_lyric_view.width)
                        duration: Math.max(1500, (id_main_lyric_text.paintedWidth - id_main_lyric_view.width) * 28)
                        easing.type: Easing.Linear
                    }
                    PauseAnimation { duration: 700 }
                    PropertyAction { target: id_main_lyric_text; property: "x"; value: 0 }
                    PauseAnimation { duration: 700 }
                }
            }
        }

        Item {
            id: id_translation_lyric_view
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: id_main_lyric_view.bottom
            height: 18 * id_quick_music_player.uiScale
            clip: true
            visible: currentTranslationLyric.length > 0

            YText {
                id: id_translation_lyric_text
                height: parent.height
                width: paintedWidth
                verticalAlignment: YText.AlignVCenter
                color: YColors.grayText
                font.pixelSize: 14 * id_quick_music_player.uiScale
                elide: Text.ElideNone
                wrapMode: Text.NoWrap
                text: currentTranslationLyric
                onTextChanged: {
                    x = 0
                    if (id_translation_lyric_text.paintedWidth > id_translation_lyric_view.width)
                        id_translation_lyric_marquee.restart()
                }

                SequentialAnimation {
                    id: id_translation_lyric_marquee
                    loops: Animation.Infinite
                    running: id_translation_lyric_text.paintedWidth > id_translation_lyric_view.width
                    NumberAnimation {
                        target: id_translation_lyric_text
                        property: "x"
                        from: 0
                        to: -(id_translation_lyric_text.paintedWidth - id_translation_lyric_view.width)
                        duration: Math.max(1500, (id_translation_lyric_text.paintedWidth - id_translation_lyric_view.width) * 28)
                        easing.type: Easing.Linear
                    }
                    PauseAnimation { duration: 700 }
                    PropertyAction { target: id_translation_lyric_text; property: "x"; value: 0 }
                    PauseAnimation { duration: 700 }
                }
            }
        }
    }

    YMouseArea {
        id: id_open_player_area
        anchors.left: parent.left
        anchors.leftMargin: 8 * id_quick_music_player.uiScale
        anchors.right: id_adjust_button.left
        anchors.rightMargin: 4 * id_quick_music_player.uiScale
        anchors.top: parent.top
        anchors.bottom: id_lyric.bottom
        z: 2
        onClicked: playerRequested()
        objectName: "YQuickMusicPlayer.qml_id_open_player_area"
    }

    Row {
        id: id_control_row
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 30 * id_quick_music_player.uiScale
        spacing: 8

        YIconButton {
            implicitWidth: 34 * id_quick_music_player.uiScale
            implicitHeight: 34 * id_quick_music_player.uiScale
            radius: 10 * id_quick_music_player.uiScale
            mouseAreaMargins: -3
            sourceSize: Qt.size(24, 24)
            imageName: "audioplayer/previous54"
            onValidClicked: {
                if (pluginSession) mediaSession.prevRequested()
                else mediaPlayerManager.onClickedPrev()
            }
            objectName: "YQuickMusicPlayer.qml_id_previous_button"
        }

        YIconButton {
            implicitWidth: 42 * id_quick_music_player.uiScale
            implicitHeight: 42 * id_quick_music_player.uiScale
            radius: 12 * id_quick_music_player.uiScale
            anchors.verticalCenter: id_control_row.verticalCenter
            mouseAreaMargins: -3
            sourceSize: Qt.size(28, 28)
            imageName: !isPlaying ? "audioplayer/pause" : "audioplayer/play"
            onValidClicked: {
                if (isPlaying) {
                    if (pluginSession) mediaSession.pauseRequested()
                    else mediaPlayerManager.onClickedPause()
                } else {
                    if (pluginSession) mediaSession.playRequested()
                    else mediaPlayerManager.onClickedPlay()
                }
            }
            objectName: "YQuickMusicPlayer.qml_id_play_button"
        }

        YIconButton {
            implicitWidth: 34 * id_quick_music_player.uiScale
            implicitHeight: 34 * id_quick_music_player.uiScale
            radius: 10 * id_quick_music_player.uiScale
            mouseAreaMargins: -3
            sourceSize: Qt.size(24, 24)
            imageName: "audioplayer/next54"
            onValidClicked: {
                if (pluginSession) mediaSession.nextRequested()
                else mediaPlayerManager.onClickedNext()
            }
            objectName: "YQuickMusicPlayer.qml_id_next_button"
        }

        YIconButton {
            implicitWidth: 34 * id_quick_music_player.uiScale
            implicitHeight: 34 * id_quick_music_player.uiScale
            radius: 10 * id_quick_music_player.uiScale
            mouseAreaMargins: -3
            sourceSize: Qt.size(22, 22)
            imageName: "commons/close"
            onValidClicked: {
                if (pluginSession) mediaSession.stopRequested()
                else musicPlayer.stop()
            }
            objectName: "YQuickMusicPlayer.qml_id_stop_button"
        }
    }
}

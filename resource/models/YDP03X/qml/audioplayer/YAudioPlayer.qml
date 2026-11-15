import QtQuick 2.12
import com.youdao.pen 1.0

import BaseQml 1.0
import "../i18n"
import "../textbook"

Item {
    id: id_audio_player
    anchors.fill: parent
    state: "close"

    readonly property bool isShowing: (("show" === state) || id_audio_player_indicator.isShowing)
    readonly property int playerMode: mediaPlayerManager.playerMode
    readonly property bool isHidden: isShowing && !visible
    readonly property var lrcStateList: {
        switch (mediaPlayerManager.lrcState) {
        case YEnum.LS_BILINGUAL:
            return [YEnum.LS_BILINGUAL, YEnum.LS_ORIGINAL, YEnum.LS_TRANS, YEnum.LS_HIDE]
        case YEnum.LS_ORIGINAL:
            return [YEnum.LS_ORIGINAL, YEnum.LS_HIDE]
        case YEnum.LS_TRANS:
            return [YEnum.LS_TRANS, YEnum.LS_HIDE]
        case YEnum.LS_HIDE:
        default:
            return [YEnum.LS_HIDE]
        }
    }
    property int lrcStateIndex: 0
    function reportLrcScene() {
        screenManager.reportAction(visible && state === "show" && mediaPlayerManager.hasLrc
            && mediaPlayerManager.lrcState !== YEnum.LS_HIDE ? "musicplayer_lrc_show" : "musicplayer_lrc_hide");
    }
    onStateChanged: reportLrcScene()
    onVisibleChanged: reportLrcScene()
    Connections {
        target: mediaPlayerManager
        function onLrcStateChanged() { id_audio_player.reportLrcScene(); }
        function onHasLrcChanged() { id_audio_player.reportLrcScene(); }
    }
    Connections {
        target: musicPlayer
        function onHideFloatingWindowChanged() {
            if (id_audio_player.state !== "close") return;
            if (musicPlayer.hideFloatingWindow) id_audio_player_indicator.hide();
            else if (mediaPlayerManager.playState !== YEnum.STOPPED) id_audio_player_indicator.show();
        }
        function onStopRequested() { id_audio_player_indicator.hide(); }
    }

    function show() {
        state = "show"
        if (id_audio_player_indicator.isShowing) {
            id_audio_player_indicator.hide()
        }
        if (qmlGlobal.currentPageIndex === YEnum.PageIndex.TextBook) {
            logManager.sendHttpLog("action=textbook_broadcast_show")
        } else if (qmlGlobal.currentPageIndex === YEnum.PageIndex.Audioplayer) {
            logManager.sendHttpLog("action=listening_broadcasting_view")
        }
        id_ver_play_bar.setFollowEnabledState(true)
        id_play_bar.update()
        id_content_container.show()
    }

    function close() {
        console.warn("YAudioPlayer.qml===close()")
        closeAudioPlayerFollow()
        id_audioplayer_submithomework_dialog_loader.active = false
        state = "close"
        if ((YEnum.PM_AudioPlayer === playerMode || YEnum.PM_StoreAudio === playerMode) && YEnum.STOPPED !== mediaPlayerManager.playState) {
            if (musicPlayer.hideFloatingWindow) id_audio_player_indicator.hide()
            else id_audio_player_indicator.show()
            id_audio_player_indicator.closeExtendState()
        } else {
            mediaPlayerManager.onClickedPause()
            musicPlayer.releaseAudioAfterHide()
        }
        id_ver_play_bar.setFollowEnabledState(false)
        raise()
    }

    function hidden() {
        console.warn("YAudioPlayer.qml===hidden()")
        closeAudioPlayerFollow()
        id_audioplayer_submithomework_dialog_loader.active = false
        visible = false
        playStatePauseConfirm()
        musicPlayer.releaseAudioAfterHide()
    }

    function raise() {
        visible = true
    }

    function playStatePauseConfirm() {
        id_content_container.playStatePauseConfirm()
    }

    function mmssString(ms) {
        let seconds = parseInt(ms / 1000);
        let minutes = parseInt(seconds / 60);
        seconds = seconds % 60;
        return ("%1%2:%3%4").arg(minutes > 9 ? "" : "0").arg(minutes).arg(seconds > 9 ? "" : "0").arg(seconds);
    }

    function enterAudioPlayerFollow() {
        console.warn("YAudioPlayer.qml===enterAudioPlayerFollow()")
        mediaPlayerManager.onClickedPause();
        mediaPlayerManager.onResetPlayer();

        followManager.ukPhonetic = "";
        followManager.usPhonetic = "";
        followManager.content = mediaPlayerManager.mainLrc
        if (columnManager.columnIsScanning(mediaPlayerManager.ownerId()).length > 0) {
            logManager.sendHttpLog("action=listening_make_broadcasting_readfollow_click")
            followManager.classLog = "&resource_bookname=" + columnManager.columnIsScanning(mediaPlayerManager.ownerId())
                    + "&resource_Lischaptername=" + mediaPlayerManager.title
        } else {
            followManager.classLog = ""
        }
        logManager.sendHttpLog("action=listening_broadcasting_readfollow_click")
        followManager.clearResult()

        id_audioplayer_followpage_loader.active = true
    }

    function closeAudioPlayerFollow() {
        console.warn("YAudioPlayer.qml===closeAudioPlayerFollow()")
        id_audioplayer_followpage_loader.active = false
    }

    function submitHomework() {
        console.warn("YAudioPlayer.qml===submitHomework()")
        id_audioplayer_submithomework_dialog_loader.active = true
    }

    YBackgroundIgnoreMouseEvent {
        anchors.fill: parent
        opacity: id_audio_player_indicator.isShowingAndExtendState ? 0.6 : 0
        visible: opacity > 0.05
        onClicked: {
            id_audio_player_indicator.closeExtendState()
        }
        Behavior on opacity {
            NumberAnimation { duration: 120 }
        }
    }

    YBackgroundIgnoreMouseEvent {
        id: id_audio_player_container
        width: parent.width
        height: parent.height
        anchors.centerIn: parent
        enabled: scale > 0.5
        visible: scale > 0.1
        YVerticalTitleBar {
            onCallBack: {
                close()
            }
            YIconButton {
                implicitWidth: 44
                implicitHeight: 44
                radius: height/2
                mouseAreaMargins: -25
                iconSourceSize: Qt.size(36, 36)
                imageName: "audioplayer/more_settings"
                anchors.left: parent.left
                anchors.leftMargin: 16
                anchors.bottom: parent.bottom
                onValidClicked: {
                    if (qmlGlobal.currentPageIndex === YEnum.PageIndex.TextBook) {
                        logManager.sendHttpLog("action=textbook_broadcast_more_click")
                    }
                    id_play_bar.show()
                }
            }
        }
        // 上一首 下一首 按钮
        YAudioPlayerLrcContent {
            id: id_content_container
            anchors.fill: parent
        }

        YAudioPlayerPlayBarVertical {
            id: id_ver_play_bar
        }

        YAudioPlayerPlayBar {
            id: id_play_bar
        }

        YProgressBar {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            height: 2
            color: YColors.black
            progressColor: YColors.blueText
            progressGradient: Gradient {
                GradientStop { position: 0.0; color: YColors.blueText }
                GradientStop { position: 1.0; color: YColors.blueText }
            }
            progress: mediaPlayerManager.progress

            Rectangle {
                id: id_repeat_progress
                visible: {
                    switch (id_play_bar.truncateAudioState) {
                    case YEnum.TAS_ING:
                    case YEnum.TAS_PLAYING:
                    case YEnum.TAS_Sentence:
                        return true
                    case YEnum.TAS_STOP:
                    default:
                        return false
                    }
                }
                anchors.left: parent.left
                anchors.leftMargin: {
                    switch (id_play_bar.truncateAudioState) {
                    case YEnum.TAS_ING:
                    case YEnum.TAS_PLAYING:
                    case YEnum.TAS_Sentence:
                        return id_play_bar.width/100.0 * mediaPlayerManager.progress
                    case YEnum.TAS_STOP:
                    default:
                        return 0
                    }
                }
                anchors.right: parent.right
                anchors.rightMargin: {
                    switch (id_play_bar.truncateAudioState) {
                    case YEnum.TAS_ING:
                        return id_play_bar.width/100.0 * (100 - mediaPlayerManager.progress)
                    case YEnum.TAS_PLAYING:
                    case YEnum.TAS_Sentence:
                        return id_play_bar.width/100.0 * (100 - mediaPlayerManager.progressRepeatB) - 8
                    case YEnum.TAS_STOP:
                    default:
                        return 0
                    }
                }
                implicitHeight: 2
                color: "black"
                Rectangle {
                    anchors.fill: parent
                    color: YColors.red
                }
            }
        }
    }

    Item {
        id: id_player_progress_timeinfo_item
        implicitWidth: 200
        implicitHeight: 54
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 10
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.horizontalCenterOffset: ((mediaPlayerManager.progress - 50) * 0.01 * parent.width).bound(-284, +284)
        visible: false

        YBlurMaskRectangle {
            id: id_blur_mask_rectangle
            anchors.fill: parent
            sourceItem: id_audio_player_container
            sourceRect: Qt.rect(parent.x, parent.y, width, height)
            blurRadius: 48

            Rectangle {
                anchors.fill: parent
                color: YColors.white
                opacity: 0.14
                radius: height/2
            }
        }

        YTextMedium {
            anchors.centerIn: parent
            font.pixelSize: 26
            textFormat: Text.RichText
            text: ('<span style="font-family: %1; color:%2">%3</span> / %4')
            .arg(fontManager.fontFamilyEnUs).arg(YColors.blueText)
            .arg(mmssString(mediaPlayerManager.currentPos))
            .arg(mmssString(mediaPlayerManager.duration))
        }
        }

            //快捷播放器
            YAudioPlayerIndicator {
                id: id_audio_player_indicator
                onClicked: {
                    id_audio_player.show()
                }
                onStopAudio: {
                    mediaPlayerManager.onClickedPause()
                }
            }

            YLoader {
                id: id_audioplayer_followpage_loader
                anchors.fill: parent
                sourceComponent: id_audioplayer_follow_page_component
            }

            YLoader {
                id: id_audioplayer_submithomework_dialog_loader
                anchors.fill: parent
                sourceComponent: id_audioplayer_submithomework_dialog_component
                onLoaded: {
                    item.show()
                }
            }

            Component {
                id: id_audioplayer_follow_page_component
                YAudioPlayerFollowPage {
                    onBackButtonClicked: {
                        console.log("YAudioPlayer.qml === id_audioplayer_follow_page_component.onBackButtonClicked");
                        closeAudioPlayerFollow()
                        if (id_audio_player.playerMode === YEnum.PM_Homework_Follow) {
                            close()
                        } else {
                            console.log("YAudioPlayer.qml === id_audioplayer_follow_page_component.onBackButtonClicked before onClickedPlay");
                            // TODO 设置播放位置为currentLrcEntityIndex
                            mediaPlayerManager.onFastGotoSentence(currentLrcEntityIndex)
                            mediaPlayerManager.onClickedPlay()
                            console.log("YAudioPlayer.qml === id_audioplayer_follow_page_component.onBackButtonClicked after onClickedPlay");
                        }
                    }
                }
            }

            Component {
                id: id_audioplayer_submithomework_dialog_component
                YTextbookSubmitHomeworkDialog {
                    id: id_audioplayer_submithomework_dialog
                    anchors.fill: parent
                    submitTipString: {
                        switch (id_audio_player.playerMode) {
                        case YEnum.PM_Homework_Follow:
                            return (YTranslateText.textbookFollowSubmitTip).arg(YColors.red).arg(mediaPlayerManager.getFollowResultAverageScore())
                        case YEnum.PM_Homework_Listen:
                            return (YTranslateText.textbookListenSubmitTip).arg((textBookTaskManager.learningDuarition / 60).toFixed(2))
                        default:
                            return ""
                        }
                    }
                    onSubmitHomework: {
                        mediaPlayerManager.commitFollowResult()
                    }
                    onRedoHomework: {
                        textBookTaskManager.retryLearning()
                        id_audioplayer_followpage_loader.active = false
                        id_audioplayer_submithomework_dialog.close()
                        id_audioplayer_submithomework_dialog_loader.active = false
                    }
                    onSubmitFinished: {
                        id_audioplayer_submithomework_dialog.close()
                        id_audioplayer_submithomework_dialog_loader.active = false
                        id_audio_player.close()
                    }
                    onClosed: {
                        id_audioplayer_submithomework_dialog.close()
                        id_audioplayer_submithomework_dialog_loader.active = false
                        if (id_audio_player.playerMode === YEnum.PM_Homework_Listen) {
                            id_audio_player.close()
                        }
                    }
                }
            }

            states: [
                State {
                    name: "close"
                    PropertyChanges { target: id_audio_player_container; scale: 0 }
                },
                State {
                    name: "show"
                    PropertyChanges { target: id_audio_player_container; scale: 1 }
                }
            ]

            //    transitions: Transition {
            //        NumberAnimation { properties: "scale"; easing.type: Easing.InOutQuad }
            //    }

            onIsShowingChanged: {
                qmlGlobal.isInPlayerCenterPage = isShowing
            }

            Connections {
                target: textBookTaskManager
                ignoreUnknownSignals: true
                function onLearningDuaritionChanged() {
                    if (id_audio_player.playerMode !== YEnum.PM_Homework_Follow) {
                        id_audio_player.submitHomework()
                    }
                }
                function onUploadLearningDataFinished(taskId, success, errCode, errMsg) {
                    if (id_audioplayer_submithomework_dialog_loader.isLoaded) {
                        id_audioplayer_submithomework_dialog_loader.item.submitDoing = false
                        if (success) {
                            id_audioplayer_submithomework_dialog_loader.item.submitDone = true
                        } else {
                            baseSignals.showToast(errMsg, YColors.grayNormal)
                        }
                    }
                }
                function onUploadOralAudioFinished(taskId, success, errCode, errMsg) {
                    console.log("YAudioPlayer.qml===onUploadOralAudioFinished", success, errMsg)
                    if (id_audioplayer_submithomework_dialog_loader.isLoaded) {
                        if (!success) {
                            baseSignals.showToast(errMsg.length > 0 ? errMsg: YTranslateText.textbookHomeworkOralUploadFailed, YColors.grayNormal)
                        }
                    }
                }
            }
            Connections {
                target: qmlGlobal
                ignoreUnknownSignals: true
                function onAudioPlayingColomnIdChanged() {
                    if (qmlGlobal.audioPlayingColomnId.length > 0) {
                        const qrcColumnId = ("qrc:/images/audioplayer/indicator/%1.png").arg(qmlGlobal.audioPlayingColomnId)
                        console.log("ZDS=================qrcColumnId: ", qrcColumnId, qmlGlobal.fileExists(qrcColumnId))
                        if (qmlGlobal.fileExists(qrcColumnId)) {
                            id_audio_player_indicator.indicatorSource = qrcColumnId
                        } else {
                            if (qmlGlobal.fileExists(qmlGlobal.audioPlayingColomnId)) {
                                id_audio_player_indicator.indicatorSource = qmlGlobal.audioPlayingColomnId
                            } else {
                                id_audio_player_indicator.indicatorSource = ""
                            }
                        }
                    } else {
                        id_audio_player_indicator.indicatorSource = ""
                    }
                }

                function onCurrentPageIndexChanged() {
                    if (qmlGlobal.currentPageIndex !== YEnum.PageIndex.Dict && musicPlayer.isScanPauseActive())
                        musicPlayer.finishScanPause();
                    if (qmlGlobal.currentPageIndex === YEnum.PageIndex.MathTutor
                            || qmlGlobal.currentPageIndex === YEnum.PageIndex.UpdateOS) {
                        console.log("YAudioPlayer.qml====onCurrentPageIndexChanged")
                        if (id_audio_player_indicator.isShowing) {
                            id_audio_player.close();
                            id_audio_player_indicator.indicatorSource = ""
                            id_audio_player_indicator.stopAudio()
                            id_audio_player_indicator.hide()
                        }
                    }
                }
            }
            Connections {
                target: systemBase
                ignoreUnknownSignals: true
                enabled: "show" === id_audio_player.state
                function onHomeKeyLongPress() {
                    console.log("YAudioPlayer.qml====onHomeKeyLongPress")
                    id_audio_player.close()
                }
            }
            Connections {
                target: baseSignals
                ignoreUnknownSignals: true

                function onShowGlobeAudioPlayer() {
                    if (id_audio_player_indicator.isShowing) id_audio_player_indicator.hide()
                }
            }
            Connections
            {
                target: websocketManager
                enabled: loginManager.isLogin && wifiManager.link
                function onEnanle_featureid(featid,fenable)
                {
                    console.log("onEnanle_featureid>==>",featid,fenable)
                    //104 教材同步
                    //107 听力练习
                    //111 喜马拉雅
                    if((featid === 104 && qmlGlobal.currentPageIndex === YEnum.PageIndex.TextBook)
                            ||(featid === 107 && qmlGlobal.currentPageIndex === YEnum.PageIndex.Audioplayer)
                            ||(featid === 111 && qmlGlobal.currentPageIndex === YEnum.PageIndex.CooXmly)
                            ||qmlGlobal.currentPageIndex === YEnum.PageIndex.NonePage)
                    {
                        if(!fenable){
                            if (id_audio_player_indicator.isShowing)
                            {
                                id_audio_player_indicator.indicatorSource = ""
                                id_audio_player_indicator.stopAudio()
                                id_audio_player_indicator.hide()
                                id_deley_showhomepage.restart();
                            }
                            else
                            {
                                id_audio_player.close();
                                id_audio_player_indicator.indicatorSource = ""
                                id_audio_player_indicator.stopAudio()
                                id_audio_player_indicator.hide()
                                id_deley_showhomepage.restart();

                            }
                        }
                    }
                }
            }

            YTimer {
                id: id_deley_showhomepage
                interval: 100
                onTriggered: {
                    systemBase.homeKeyRelease();
                }

            }

        }

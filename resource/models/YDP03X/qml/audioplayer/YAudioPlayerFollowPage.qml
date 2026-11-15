import QtQuick 2.12
import com.youdao.pen 1.0

import BaseQml 1.0
import "../components"
import "../i18n"
import "../textbook"

YBackgroundIgnoreMouseEvent {
    id: id_audioplayer_followpage
    anchors.fill: parent

    property var lastsegid : 0;
    property var recognisePersistant : new Array;
    property var recogniseTmp : new Array;
    property alias score_on : id_follow_star_on.model;
    property alias score_off : id_follow_star_off.model;
    property var currentLrcEntityIndex: 0
    property var lrcEntity: null
    readonly property var followResult: followManager.result
    readonly property bool followIsRecording: followManager.isRecording

    onCurrentLrcEntityIndexChanged: {
        console.log("YAudioPlayerFollowPage.qml === onCurrentLrcEntityIndexChanged() currentLrcEntityIndex", currentLrcEntityIndex)
        soundCenter.suspend()
        id_follow_content_pron_playbtn.stop()
        id_follow_mypron.stop()
        lrcEntity = mediaPlayerManager.get(currentLrcEntityIndex)
        updateContentByFollowResult()
    }

    onFollowResultChanged: {
        updateContentByFollowResult()
    }

    onFollowIsRecordingChanged: {
        updateContentByFollowResult()
    }

    signal backButtonClicked()

    function updateOralScore(score) {
        if (score < 0) {
            return
        }

        if (score > 90){
            score_off = 0
        }
        else if (score >80){
            score_off = 1
        }
        else if (score >60){
            score_off = 2
        }
        else if (score >40){
            score_off = 3
        }
        else {
            score_off = 4
        }
        score_on = 5 - score_off
        id_score_animation.start()
    }

    function updateContentByFollowResult() {
        console.log("YAudioPlayerFollowPage.qml === updateContentByFollowResult() followresult:", followResult)

        try{
            var phoneticSymbolJson = JSON.parse(followResult);
        } catch(e){ }
        var res = "";
        if (typeof phoneticSymbolJson != "undefined"){
            let lrcOrignal = lrcEntity.mainLrc
            let indexLrcOrignal = 0
            //最终结果
            let mistakewords = ""
            if (typeof phoneticSymbolJson.words != "undefined" && !followIsRecording){
                for (var i = 0; i < phoneticSymbolJson.words.length; i++){
                    var indexLrcOrignalCur = lrcOrignal.indexOf(phoneticSymbolJson.words[i].word, indexLrcOrignal)
                    if (indexLrcOrignalCur > indexLrcOrignal) {
                        res += lrcOrignal.substring(indexLrcOrignal, indexLrcOrignalCur)
                        indexLrcOrignal = indexLrcOrignalCur
                    }
                    indexLrcOrignal += phoneticSymbolJson.words[i].word.length
                    if (phoneticSymbolJson.words[i].pronunciation < 60){
                        res += ('<font color="%2">%1</font>'.arg(phoneticSymbolJson.words[i].word).arg(YColors.red));
                        mistakewords += phoneticSymbolJson.words[i].word + "_"
                    } else {
                        res += (phoneticSymbolJson.words[i].word);
                    }
                }
                res += lrcOrignal.substring(indexLrcOrignal)
                if (followManager.classLog.length > 0) {
                    let qsLog = "resource_spesentence=" + followManager.content +
                            "&resource_sentence_pronunciation_view=" + phoneticSymbolJson.pronunciation +
                            "&resource_sentence_fluency_view=" + phoneticSymbolJson.fluency +
                            "&resource_sentence_integrity_view=" + phoneticSymbolJson.integrity +
                            "&resource_sentence_overall_view=" + phoneticSymbolJson.overall +
                            "&resource_repeat_speed_view=" + phoneticSymbolJson.speed +
                            "&resource_wrong_sentencepronunciation_view=" + mistakewords + followManager.classLog;
                    console.log(qsLog);
                    logManager.sendClassAudioLogToServer(qsLog);
                }
                updateOralScore(phoneticSymbolJson.overall)

                // 记录成绩
                let resultObj = new Object
                resultObj["content"] = phoneticSymbolJson.refText
                resultObj["accuracy"] = phoneticSymbolJson.pronunciation //??
                resultObj["speedRate"] = phoneticSymbolJson.speed
                resultObj["overallScore"] = phoneticSymbolJson.overall
                resultObj["integrity"] = phoneticSymbolJson.integrity
                resultObj["fluency"] = phoneticSymbolJson.fluency
                resultObj["index"] = currentLrcEntityIndex
                mediaPlayerManager.handleFollowResult(currentLrcEntityIndex, phoneticSymbolJson.overall, res, JSON.stringify(resultObj))
            }
            //中间结果
            if (typeof phoneticSymbolJson[0] != "undefined")
            {
                if (phoneticSymbolJson[0].seg_id !== lastsegid){
                    recognisePersistant = recognisePersistant.concat(recogniseTmp);
                    lastsegid = phoneticSymbolJson[0].seg_id;
                }
                recogniseTmp = [];
                for (var i = 0; i < phoneticSymbolJson[0].st.ws.length; i++){
                    recogniseTmp.push(phoneticSymbolJson[0].st.ws[i].w);
                }

                var recogniseWords = recogniseTmp.concat(recognisePersistant);
                let lrcOrignalLow = lrcOrignal.toLowerCase()
                for (var lrcOrignalIndex = 0; lrcOrignalIndex < lrcOrignal.length;) {
                    let matchIndex = -1
                    let matchLength = 1
                    for (var wordIndex = 0; wordIndex < recogniseWords.length; wordIndex++){
                        if (recogniseWords[wordIndex] === lrcOrignalLow.substring(lrcOrignalIndex, lrcOrignalIndex + recogniseWords[wordIndex].length)) {
                            if (matchIndex < 0 || matchLength < recogniseWords[wordIndex].length) {
                                matchIndex = wordIndex
                                matchLength = recogniseWords[wordIndex].length
                            }
                        }
                    }
                    if (matchIndex >= 0) {
                        recogniseWords.splice(matchIndex, 1)
                        res += ('<font color="%2">%1</font>'.arg(lrcOrignal.substring(lrcOrignalIndex, lrcOrignalIndex + matchLength)).arg(YColors.blueText))
                    } else {
                        res += lrcOrignal.charAt(lrcOrignalIndex)
                    }
                    lrcOrignalIndex += matchLength
                }
            }
        }
        if (res.length === 0 && lrcEntity !== null) {
            console.log("YAudioPlayerFollowPage.qml === updateContentByFollowResult() evaluateLrc, oralScore :", lrcEntity.evaluateLrc, lrcEntity.oralScore)
            if (!id_sound_play.playing && lrcEntity.evaluateLrc.length > 0) {
                res = lrcEntity.evaluateLrc
            } else {
                res = lrcEntity.mainLrc
            }
        }
        id_text_follow_content.text = res
    }

    YVerticalTitleBar {
        id: id_title_bar
        onCallBack: {
            mediaPlayerManager.stopFollowSentence()
            lrcEntity = null
            backButtonClicked()
        }
    }

    Flickable {
        anchors.left: parent.left
        anchors.leftMargin: 90
        anchors.right: parent.right
        anchors.rightMargin: 160
        contentHeight: id_column_main.height
        anchors.verticalCenter: parent.verticalCenter
        height: Math.min(id_audioplayer_followpage.height - 40, id_column_main.height)

        Column {
            id: id_column_main
            anchors.left: parent.left
            anchors.right: parent.right
            spacing: 16

            Row {
                id: id_row_follow_content
                anchors.left: parent.left
                anchors.right: parent.right
                height: id_text_follow_content.height
                spacing: 12

                YAudioPlayButton {
                    id: id_follow_content_pron_playbtn
                    implicitWidth: 32
                    implicitHeight: 32
                    anchors.top: parent.top
                    anchors.topMargin: 5
                    leftMargin: 0
                    rightMargin: 0
                    spacing: 0
                    color: YColors.black
                    enabled: !id_sound_play.playing && mediaPlayerManager.srcAudioVisble()
                    onValidClicked: {
                        if (playing) {
                            if (mediaPlayerManager.playerMode !== YEnum.PM_AudioPlayer)
                                playAudioFileData(mediaPlayerManager.getPlayingMediaLocalFile(), lrcEntity.startTime, lrcEntity.endTime)
                            else {
                                playWord(lrcEntity.mainLrc, "en", lrcEntity.mainLrc)
                            }
                        }
                        id_follow_mypron.stop()
                    }
                }

                YText {
                    id: id_text_follow_content
                    lineHeightMode: Text.FixedHeight
                    lineHeight: 42
                    font.pixelSize: 30

                    font.family: fontManager.fontFamilyEnUs
                    textFormat: YText.RichText
                    wrapMode: YTextBase.Wrap
                    font.weight: Font.Bold
                    width: 500
                    text: lrcEntity === null ? "" : lrcEntity.mainLrc
                }
            }

            YAudioPlayButton {
                id: id_follow_mypron
                implicitHeight : 34
                textFontFamily: fontManager.fontFamily
                textFormat: YText.PlainText
                textColor: YColors.grayText
                text: YTranslateText.mySpoken
                leftMargin: 0
                spacing: 12
                rightMargin: 0
                color: YColors.black
                visible: !id_sound_play.playing
                onValidClicked: {
                    if (playing) {
                        playAudioFileData(lrcEntity.oralAudio)
                    }
                    id_follow_content_pron_playbtn.stop()
                }
            }

            Row {
                id: id_row_score
                height: 36
                width: 1
                spacing: 1
                clip: true
                visible: width > 1

                Repeater {
                    id : id_follow_star_on
                    YImage {
                        anchors.verticalCenter: id_row_score.verticalCenter
                        sourceSize: Qt.size(33, 32)
                        imageName: "follow/star_on"
                    }
                }

                Repeater {
                    id : id_follow_star_off
                    YImage {
                        anchors.verticalCenter: id_row_score.verticalCenter
                        sourceSize: Qt.size(33, 32)
                        imageName: "follow/star_off"
                    }
                }
            }
            SequentialAnimation {
                id: id_score_animation
                loops: 1
                running: false
                PropertyAction { target: id_row_score; property: "width"; value: 1; }
                PauseAnimation { duration: 100 }
                PropertyAction { target: id_row_score; property: "width"; value: 32 }
                PauseAnimation { duration: 80 }
                PropertyAction { target: id_row_score; property: "width"; value: 64 }
                PauseAnimation { duration: 80 }
                PropertyAction { target: id_row_score; property: "width"; value: 96 }
                PauseAnimation { duration: 80 }
                PropertyAction { target: id_row_score; property: "width"; value: 135 }
                PauseAnimation { duration: 80 }
                PropertyAction { target: id_row_score; property: "width"; value: 170 }
            }
        }
    }

    YFollowIconsButton {
        id: id_sound_play
        anchors.right: parent.right
        anchors.rightMargin: 30
        anchors.verticalCenter: parent.verticalCenter
        color: YColors.red
        height: 80
        width: 80
        radius: 40
        mouseAreaMargins: -10
        onValidClicked: {
            console.log("YAudioPlayerFollowPage.qml === id_sound_play.onValidClicked currentLrcEntityIndex:", currentLrcEntityIndex);
            if (playing) {

                stop();
                mediaPlayerManager.stopFollowSentence()
                lastsegid = 0;
                recognisePersistant = [];
                recogniseTmp = [];
                id_sound_play.visible = false
            } else {
                play()
                id_row_score.width = 1
                mediaPlayerManager.startFollowSentence(currentLrcEntityIndex)
            }
        }
    }

    Item {
        id: id_follow_button_list
        implicitWidth: 112
        height: id_follow_button_column.height
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.topMargin: 14
        visible: !id_sound_play.visible

        Column {
            id: id_follow_button_column
            width: 80
            anchors.right: parent.right
            anchors.rightMargin: 16
            spacing: 8

            YIconButton {
                id: id_mic_button
                implicitWidth: 80
                implicitHeight: 70
                anchors.horizontalCenter: parent.horizontalCenter
                sourceSize: Qt.size(44, 44)
                imageName: "audioplayer/mic"
                mouseAreaMargins: -8
                enabled: true // TODO 若已有成绩且不是其中最后一条则不可再读
                onValidClicked: {
                    soundCenter.stop();
                    id_sound_play.visible = true
                    id_sound_play.validClicked();
                }
            }

            YIconButton {
                id: id_pre_button
                implicitWidth: 80
                implicitHeight: 70
                anchors.horizontalCenter: parent.horizontalCenter
                sourceSize: Qt.size(44, 44)
                imageName: "audioplayer/previous"
                mouseAreaMargins: -8
                enabled: currentLrcEntityIndex > 0
                onValidClicked: {
                    followManager.clearResult()
                    if (currentLrcEntityIndex > 0) {
                        currentLrcEntityIndex -= 1
                        lrcEntity = mediaPlayerManager.get(currentLrcEntityIndex)
                        console.log("YAudioPlayerFollowPage.qml === id_pre_button.onClicked after reset currentLrcEntityIndex");
                        followManager.content = lrcEntity.mainLrc
                        if (lrcEntity.evaluateLrc.length <= 0) {
                            id_sound_play.visible = true
                            id_sound_play.validClicked();
                        }
                        else {
                            updateOralScore(lrcEntity.oralScore)
                        }
                    }
                }
            }

            YIconButton {
                id: id_next_button
                implicitWidth: 80
                implicitHeight: 70
                anchors.horizontalCenter: parent.horizontalCenter
                sourceSize: Qt.size(44, 44)
                enabled: (currentLrcEntityIndex < (mediaPlayerManager.itemCount - 1))
                visible: enabled || (id_audio_player.playerMode !== YEnum.PM_Homework_Follow)
                imageName: "audioplayer/next"
                mouseAreaMargins: -8
                onClicked: {
                    followManager.clearResult()
                    if (currentLrcEntityIndex < (mediaPlayerManager.itemCount - 1)) {
                        currentLrcEntityIndex += 1
                        lrcEntity = mediaPlayerManager.get(currentLrcEntityIndex)
                        console.log("YAudioPlayerFollowPage.qml === id_next_button.onClicked after reset currentLrcEntityIndex");
                        followManager.content = lrcEntity.mainLrc
                        if (lrcEntity.evaluateLrc.length <= 0) {
                            id_sound_play.visible = true
                            id_sound_play.validClicked();
                        }
                        else {
                            updateOralScore(lrcEntity.oralScore)
                        }
                    }
                }
            }

            YIconButton {
                id: id_submit_button
                implicitWidth: 80
                implicitHeight: 70
                anchors.horizontalCenter: parent.horizontalCenter
                sourceSize: Qt.size(44, 44)
                visible: !id_next_button.visible
                imageName: "textbook/submit"
                mouseAreaMargins: -8
                onClicked: {
                    id_audio_player.submitHomework()
                }
            }
        }
    }

    Connections {
        target: followManager
        ignoreUnknownSignals: true
        function onVadStop(taskId) {
            if (id_sound_play.playing) {
                id_sound_play.validClicked()
            }
        }
    }

    Component.onCompleted: {
        if (id_audio_player.playerMode === YEnum.PM_Homework_Follow) {
            currentLrcEntityIndex = 0
        } else {
            currentLrcEntityIndex = mediaPlayerManager.currentSentenceId
        }
        id_sound_play.validClicked();
    }

    Component.onDestruction: {
        console.log("YAudiuPlayerFollowPage.qml===Component.onDestruction===called")
        lrcEntity = null
    }
}


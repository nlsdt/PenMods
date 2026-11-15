import QtQuick 2.12
import com.youdao.pen 1.0

import BaseQml 1.0
import "./components"
import "./i18n"

YBackButtonPage {
    id: id_follow_item
    objectName: "YPage===YFollowPage.qml"

    property var lastsegid : 0;
    property var recognisePersistant : new Array;
    property var recogniseTmp : new Array;
    property alias score_on : id_follow_star_on.model;
    property alias score_off : id_follow_star_off.model;
    readonly property var wordslist : followManager.content.split(/([\ |\~|\`|\!|\@|\#|\$|\%|\^|\&|\*|\(|\)|\-|\_|\+|\=|\||\\|\[|\]|\{|\}|\;|\:|\"|\'|\,|\<|\.|\>|\/|\?|\s+])/g);

    YIconButton {
        id: id_spell_switch
        implicitWidth: 44
        implicitHeight: 44
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 18
        anchors.left: parent.left
        anchors.leftMargin: 16
        enabled: (followManager.ukPhonetic.length > 0 && followManager.usPhonetic.length > 0) && !id_sound_play.playing
        visible: !settingManager.isPepVersion
        sourceSize: Qt.size(36, 36)
        imageName: "/follow/switch"
        mouseAreaMargins: -10
        radius: 22
        onClicked: {
            id_follow_drawer_layer.show();
        }
    }

    Flickable {
        anchors.left: parent.left
        anchors.leftMargin: 90
        anchors.right: parent.right
        anchors.rightMargin: 160
        contentHeight: id_col.height
        anchors.verticalCenter: parent.verticalCenter
        height: Math.min(id_follow_item.height - 40, id_col.height)

        Column {
            id: id_col
            anchors.left: parent.left
            anchors.right: parent.right

            Row {
                id: id_row_content
                anchors.left: parent.left
                anchors.right: parent.right
                height: Math.max(id_follow_content.height, id_follow_content_pron.height)
                spacing: -20
                YAudioPlayButton {
                    id: id_follow_content_pron
                    textFontFamily: fontManager.fontFamilyEnUs
                    textFormat: YText.PlainText
                    leftMargin: 0
                    anchors.verticalCenter: parent.verticalCenter
                    color: YColors.black
                    enabled: !id_sound_play.playing
                    text: ""
                    visible: !(followManager.ukPhonetic.length > 0 || followManager.usPhonetic.length > 0)
                    onValidClicked: {
                        if (playing) {
                            playWord(followManager.content, "en",
                                     followManager.content,
                                     followManager.isUk ? 1 : 2)
                        }
                        id_follow_mypron.stop()
                    }
                }
                YText {
                    id: id_follow_content
                    height: contentHeight
                    font.pixelSize: {
                        if (followManager.ukPhonetic.length === 0
                                &&followManager.usPhonetic.length === 0)
                            return 30
                        else
                            return 32
                    }
                    textFormat: YText.RichText
                    wrapMode: YTextBase.Wrap
                    anchors.verticalCenter: parent.verticalCenter
                    font.bold: Font.DemiBold
                    width: 500
                    text: {
                        try{
                            var phoneticSymbolJson = JSON.parse(followManager.result);
                        } catch(e){}
                        var res = "";
                        console.log(phoneticSymbolJson);
                        if (typeof phoneticSymbolJson != "undefined"
                                && followManager.ukPhonetic.length === 0
                                &&followManager.usPhonetic.length === 0 ){
                            //最终结果
                            let mistakewords = ""
                            if (typeof phoneticSymbolJson.words != "undefined" && !followManager.isRecording){
                                for (var i = 0; i < phoneticSymbolJson.words.length; i++){
                                    if (phoneticSymbolJson.words[i].pronunciation < 60){
                                        res += ('<font color="%2">%1</font>'.arg(phoneticSymbolJson.words[i].word).arg(YColors.red));
                                        mistakewords += phoneticSymbolJson.words[i].word + "_"
                                    } else {
                                        res += (phoneticSymbolJson.words[i].word);
                                    }
                                    res += " "
                                }
                                if (followManager.classLog.length > 0) {
                                    let qsLog = "resource_spesentence=" + followManager.content +
                                            "&resource_sentence_pronunciation_view=" + phoneticSymbolJson.pronunciation +
                                            "&resource_sentence_fluency_view=" + phoneticSymbolJson.fluency +
                                            "&resource_sentence_integrity_view=" + phoneticSymbolJson.integrity +
                                            "&resource_sentence_overall_view=" + phoneticSymbolJson.overall +
                                            "&resource_repeat_speed_view=" + phoneticSymbolJson.speed +
                                            "&resource_wrong_sentencepronunciation_view=" + mistakewords;
                                            + followManager.classLog;
                                    console.log(qsLog);
                                    logManager.sendClassAudioLogToServer(qsLog);
                                }
                            }
                            //中间结果
                            if (typeof phoneticSymbolJson[0] != "undefined")
                            {
                                if (phoneticSymbolJson[0].seg_id !== lastsegid){
                                    recognisePersistant = recognisePersistant.concat(recogniseTmp);
                                    lastsegid = phoneticSymbolJson[0].seg_id;
                                }
                                recogniseTmp = [];
                                for (i = 0; i < phoneticSymbolJson[0].st.ws.length; i++){
                                    recogniseTmp.push(phoneticSymbolJson[0].st.ws[i].w);
                                }

                                var recogniseWords = recogniseTmp.concat(recognisePersistant);
                                for (i = 0; i < wordslist.length; i++){
                                    if (recogniseWords.length === 0){
                                        res += wordslist[i];
                                    } else {
                                        var index = recogniseWords.indexOf(wordslist[i].toLowerCase());
                                        if (index >= 0){
                                            recogniseWords.splice(index, 1);
                                            res += ('<font color="%2">%1</font>'.arg(wordslist[i]).arg(YColors.blueText));
                                        }else {
                                            res += wordslist[i];
                                        }
                                    }
                                }
                            }
                        }
                        if (res.length === 0) {
                            res = followManager.content;
                        }
                        return ('<span style="font-family: %1;">%2</span>')
                        .arg(fontManager.fontFamilyEnUk).arg(res)
                    }
                }
            }
            Row {
                id: id_row_pron
                anchors.left: parent.left
                anchors.right: parent.right
                height: Math.max(id_follow_pron.height, id_follow_phonetic.height)
                visible: followManager.ukPhonetic.length > 0 || followManager.usPhonetic.length > 0
                spacing: -20
                YAudioPlayButton {
                    id: id_follow_pron
                    textFontFamily: fontManager.fontFamily
                    leftMargin: 0
                    anchors.verticalCenter: parent.verticalCenter
                    textFormat: YText.PlainText
                    color: YColors.black
                    textColor: YColors.grayText
                    enabled: !id_sound_play.playing
                    text: followManager.isUk ? YTranslateText.shorthandEN
                                             : YTranslateText.shorthandUS
                    onValidClicked: {
                        if (playing) {
                            playWord(followManager.content, "en",
                                     followManager.content,
                                     followManager.isUk ? 1 : 2)
                        }
                        id_follow_mypron.stop()
                    }
                }
                YText {
                    id: id_follow_phonetic
                    anchors.verticalCenter: parent.verticalCenter
                    textFormat: YText.RichText
                    wrapMode: YTextBase.WrapAnywhere
                    color: YColors.grayText
                    width: 450
                    text: {
                        if (followManager.result !== "") {
                            var phoneticSymbolJson = JSON.parse(followManager.result);
                            if (typeof phoneticSymbolJson.words != "undefined" && !followManager.isRecording){
                                var res = "";
                                let mistakeWords = ""
                                for (let m = 0; m < phoneticSymbolJson.words.length; m++) {
                                    for (var i = 0;i < phoneticSymbolJson.words[m].phonemes.length ; i++){
                                        if (phoneticSymbolJson.words[m].phonemes[i].pronunciation < 60){
                                            res += ('<font color="%2">%1</font>'.arg(phoneticSymbolJson.words[m].phonemes[i].phoneme).arg(YColors.red));
                                        } else {
                                            res += (phoneticSymbolJson.words[m].phonemes[i].phoneme);
                                        }
                                        mistakeWords += phoneticSymbolJson.words[m].phonemes[i].phoneme
                                    }
                                    if (m !== phoneticSymbolJson.words.length -1)
                                        res += " "
                                }

                                if (followManager.isUk && followManager.ukPhonetic.length !== 0) {
                                    var pos = followManager.ukPhonetic.indexOf(mistakeWords.trim())
                                    if(pos === -1) {
                                        //res = followManager.ukPhonetic + res
                                    } else {
                                        res = followManager.ukPhonetic.substr(0,pos) + res + followManager.ukPhonetic.substr(pos+mistakeWords.length)
                                    }
                                } else if (followManager.usPhonetic.length !== 0) {
                                    var pos = followManager.usPhonetic.indexOf(res.trim())
                                    if(pos === -1) {
                                        //res = followManager.usPhonetic + res
                                    } else {
                                        res = followManager.usPhonetic.substr(0,pos) + res + followManager.usPhonetic.substr(pos+mistakeWords.length)
                                    }
                                }
                                let score = phoneticSymbolJson.overall;
                                if (score > 90){
                                    score_off = 0
                                    score_on = 5
                                }
                                else if (score >80){
                                    score_off = 1
                                    score_on = 4
                                }
                                else if (score >60){
                                    score_off = 2
                                    score_on = 3
                                }
                                else if (score >40){
                                    score_off = 3
                                    score_on = 2
                                }
                                else {
                                    score_off = 4
                                    score_on = 1
                                }
                                id_score_animation.start()
                                if (followManager.isUk){
                                    return ('&nbsp;/<span style="font-family: %1;">%2</span>/')
                                    .arg(fontManager.fontFamilyEnUk).arg(res)
                                }
                                else{
                                    return ('&nbsp;/<span style="font-family: %1; ">%2</span>/')
                                    .arg(fontManager.fontFamilyEnUs).arg(res)
                                }
                            }
                        }
                        else
                        {
                            if (followManager.isUk && followManager.ukPhonetic.length !== 0) {
                                return ('&nbsp;/<span style="font-family: %1;">%2</span>/')
                                .arg(fontManager.fontFamilyEnSymbol).arg(followManager.ukPhonetic)
                            } else if (followManager.usPhonetic.length !== 0) {
                                return ('&nbsp;/<span style="font-family: %1;">%2</span>/')
                                .arg(fontManager.fontFamilyEnSymbol).arg(followManager.usPhonetic)
                            } else
                                return ""
                        }
                    }
                }
            }
            YAudioPlayButton {
                id: id_follow_mypron
                implicitHeight : 52
                textFontFamily: fontManager.fontFamily
                textFormat: YText.PlainText
                textColor: YColors.grayText
                text: YTranslateText.mine
                leftMargin : 0
                color: YColors.black
                visible: !id_sound_play.playing
                onValidClicked: {
                    if (playing) {
                        playAudioFileData("/tmp/cursound")
                    }
                    id_follow_content_pron.stop()
                    id_follow_pron.stop()
                }
            }

            Row {
                id: id_score
                height: 40
                width: 1
                clip: true
                visible: width != 1
                Repeater {
                    id : id_follow_star_on
                    YImage {
                        sourceSize: Qt.size(33, 32)
                        imageName: "follow/star_on"
                    }
                }
                Repeater {
                    id : id_follow_star_off
                    YImage {
                        sourceSize: Qt.size(33, 32)
                        imageName: "follow/star_off"
                    }
                }
            }
            SequentialAnimation {
                id: id_score_animation
                loops: 1
                running: false
                PropertyAction { target: id_score; property: "width"; value: 1; }
                PauseAnimation { duration: 100 }
                PropertyAction { target: id_score; property: "width"; value: 32 }
                PauseAnimation { duration: 80 }
                PropertyAction { target: id_score; property: "width"; value: 64 }
                PauseAnimation { duration: 80 }
                PropertyAction { target: id_score; property: "width"; value: 96 }
                PauseAnimation { duration: 80 }
                PropertyAction { target: id_score; property: "width"; value: 135 }
                PauseAnimation { duration: 80 }
                PropertyAction { target: id_score; property: "width"; value: 170 }
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
            if (playing) {
                soundCenter.stop();
                stop();
                followManager.stopFollow();
                lastsegid = 0;
                recognisePersistant = [];
                recogniseTmp = [];
            }
            else {
                id_follow_content_pron.stop()
                id_follow_pron.stop()
                soundCenter.stop();
                play()
                id_score.width = 1
                followManager.startFollow(followManager.content,
                                            followManager.isUk ? followManager.ukPhonetic : followManager.usPhonetic, 200);

            }
        }
    }

    YFollowLangSwitch {
        id: id_follow_drawer_layer
        onFilterChanged: {
            id_score.width = 1
            followManager.isUk = langType == YEnum.UK
        }
    }

    Connections {
        target: followManager
        ignoreUnknownSignals: true
        function onVadStop(taskId) {
            id_sound_play.validClicked();
        }
    }
    Component.onCompleted: {
        id_sound_play.validClicked();
        id_sound_play.play()
    }

    onBackButtonClicked: {
        soundCenter.stop()
        followManager.stopFollow();
    }
    Component.onDestruction: {
        console.log("YFollowPage.qml===Component.onDestruction===called")
    }

    onVisibleChanged: {
        if (visible) {
            qmlGlobal.currentPageIndex = YEnum.PageIndex.Follow
        }
    }
}


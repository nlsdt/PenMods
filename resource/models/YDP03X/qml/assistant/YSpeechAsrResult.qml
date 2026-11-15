import QtQuick 2.12
import com.youdao.pen 1.0

import BaseQml 1.0
import "../i18n"
/*
    显示流式ARS正在识别的结果
*/

YLoader {
    id: id_asr_result_loader
    anchors.fill: parent
    signal callback();
    property int showIndex: 0
    property bool forwardToChat: false
    property var forwardAsrResult: null

    YPopLayer {
        id: id_pop_layer_asr
        function showPage(qrcqml, properties) {
            console.warn("chenjunhao==================================qrcqml： ", qrcqml)
            show(qrcqml, false, false, properties)
            currentShowPage = popItemObject
            currentShowPage.backButtonClicked.connect(function(){
                currentShowPage = null
                speechAsrResultLoader.active = false
                speech_guide_rect.visible = false
                 callback()
            })
        }
    }
    property var currentShowPage: null
    sourceComponent:  YBackgroundIgnoreMouseEvent
    {
        property string arsresult_type: "recording";
        anchors.fill: parent
        YVerticalTitleBar {
            id: id_title_bar
            onCallBack: {
                speechManager.recognizing = YEnum.AS_ASTip
                arsresult_type = "recording";
                callback();
            }
        }

        YText {
            id: id_result_empty_tip
            font.pixelSize: settingManager.uiLanguage === YEnum.EN_US ? 28 : 32
            anchors.left: parent.left
            anchors.leftMargin: 90
            anchors.top: parent.top
            anchors.topMargin: 22
            width: settingManager.uiLanguage === YEnum.EN_US ? 350 : 230
            textFormat: YTextMedium.RichText
            lineHeight: settingManager.uiLanguage === YEnum.EN_US ? 24 : 36
            lineHeightMode: YTextMedium.FixedHeight
            wrapMode: YTextBase.Wrap
            horizontalAlignment:  YText.AlignLeft
        }
        TextEdit {
            id: id_asr_result_appand_area
            anchors.top: parent.top
            anchors.topMargin: 22
            anchors.left: id_title_bar.right
            anchors.leftMargin: 10
            // anchors.bottom: parent.bottom
            width: 694
            height: YEnum.Screen.Height - 80
            wrapMode: TextEdit.Wrap
            textFormat: TextEdit.PlainText
            color: "#A8AAB3";
            font.pixelSize: 30
            font.family:fontManager.fontFamilyEnUs
            onTextChanged: {
                id_result_empty_tip.visible = false
            }
            font.weight: Font.Bold
            cursorPosition: text.length
            YTimer {
                id: id_show_timer
                interval: 12
                repeat: true
                onTriggered: {
                    showIndex++
                    id_asr_result_appand_area.text =  speechManager.asrResult.substring(0,showIndex)
                    if (showIndex >  speechManager.asrResult.length) {
                        stop()
                    }
                }
            }

            //点击空白处也可以查询
            MouseArea
            {
                anchors.fill: parent
                onClicked:
                {
                    if(id_asr_result_appand_area.text === "")
                    {
                       soundCenter.playMusic(qmlGlobal.tipsAudioPath + "speech_no_result.mp3");
                       baseSignals.showToast(YTranslateText.tryaskAgain, YColors.grayNormal)
                       speechManager.recognizing = YEnum.AS_ASTip
                       callback();
                       return ;
                    }
                    speechManager.stopAsrRecord()// 停止录音
//                    id_query_animation.running = true
//                    id_top_screen_animation.stopPlay()
                      arsresult_type = "querying"
                }
            }
        }
        Connections {
            target: speechManager
            ignoreUnknownSignals: true
            function onAsrResultChanged() {
                console.log("************onAsrResultChanged enter",speechManager.asrResult)
                 id_asr_result_appand_area.text = speechManager.asrResult;
//                if (showIndex > speechManager.asrResult.length) {
//                    showIndex = speechManager.asrResult.length
//                }
//                if (speechManager.asrResult.length >= showIndex ) {
//                    id_show_timer.start()
//                }
            }
            function onRecognizingChanged() {

                console.log("speechManager.recognizing-------------result",speechManager.recognizing)
                if (speechManager.recognizing === YEnum.AS_ASRBegin ){
                     arsresult_type = "recording"
                    speechAsrResultLoader.active = true


                } else if (speechManager.recognizing === YEnum.AS_ASREnd || speechManager.recognizing === YEnum.AS_QueryBeign) {
//                    id_query_animation.running = true
//                    id_top_screen_animation.stopPlay()
                       arsresult_type = "querying"
                }
                else {
                    if (speechManager.recognizing === YEnum.AS_ASTip) {
                        //arsresult_type = "recording"
                        id_asr_result_loader.active = false

                    }

                }
            }

            function onContentChanged() {
                query_timeout.running = false
                if (id_asr_result_loader.forwardToChat) {
                    if (id_asr_result_loader.forwardAsrResult)
                        id_asr_result_loader.forwardAsrResult();
                    return;
                }
                //console.warn("YSpeechPage.qml===", speechManager.content);
                let resJson = JSON.parse(speechManager.content);
                speechManager.saveSpeechDebugInfo("content:" + speechManager.content)
                let resType = 0;
                let playTextInfo = "";
                console.log("speechManager.content.......:",speechManager.content)
                console.log("speechManager.content.......>>>:",resJson.message)
                if (typeof resJson.chatName != "undefined"&& typeof resJson.detail != "undefined" && resJson.detail !== null ){
                    console.log("resJson.detail" + resJson.chatName)
                    if (resJson.detail.keyword == "unknow")
                        resType = YEnum.IntroductionResult
                    switch (resJson.detail.intent)
                    {
                    case 0://设置音量、亮度
                    {
                        switch (resJson.detail.action)
                        {
                        case 1:{
                            // 音量
                            id_pop_layer_asr.showPage("settingpages/YSettingVolume");

                            if (null !== currentShowPage) {
                                switch (resJson.detail.keyword)
                                {
                                case 1:{
                                    let res = Math.max(0, settingManager.spkVolume - 10)
                                    settingManager.setSpkVolume(res)
                                    if (res == 0)
                                        currentShowPage.title = YTranslateText.volumeMin
                                    else
                                        currentShowPage.title = YTranslateText.volumeDown
                                }
                                break;
                                case 2:{
                                    let res = Math.min(100, settingManager.spkVolume + 10)
                                    settingManager.setSpkVolume(Math.min(100,settingManager.spkVolume + 10))
                                    if (res == 100)
                                        currentShowPage.title = YTranslateText.volumeMax
                                    else
                                        currentShowPage.title = YTranslateText.volumeUp
                                }
                                break;
                                case 3:{
                                    settingManager.setSpkVolume(100)
                                    currentShowPage.title = YTranslateText.volumeMax
                                }
                                break;
                                case 4:{
                                    settingManager.setSpkVolume(1)
                                    currentShowPage.title = YTranslateText.volumeMin
                                }
                                break;
                                case 5:{
                                    settingManager.setSpkVolume(0)
                                    currentShowPage.title = YTranslateText.volumeMute
                                }
                                break;
                                case 6:{
                                    settingManager.setSpkVolume(80)
                                    currentShowPage.title = YTranslateText.volumeAdjust
                                }
                                break;
                                }
                            }
                            return;
                        }
                        case 2:{
                            // 亮度
                            id_pop_layer_asr.showPage("settingpages/YSettingBrightness");
                            if (null !== currentShowPage) {
                                switch (resJson.detail.keyword)
                                {
                                case 1:
                                    let res = Math.min(100, settingManager.lcdBrightness + 10)
                                    settingManager.setLcdBrightness(res)
                                    if (res === 100)
                                        currentShowPage.title = YTranslateText.brightnessMax
                                    else
                                        currentShowPage.title = YTranslateText.brightnessUp
                                    break;
                                case 2:
                                    settingManager.setLcdBrightness(Math.max(0, settingManager.lcdBrightness - 10))
                                    if (res === 0)
                                        currentShowPage.title = YTranslateText.brightnessMin
                                    else
                                        currentShowPage.title = YTranslateText.brightnessDown
                                    break;
                                case 3:
                                    settingManager.setLcdBrightness(100)
                                    currentShowPage.title = YTranslateText.brightnessMax
                                    break;
                                case 4:
                                    settingManager.setLcdBrightness(0)
                                    currentShowPage.title = YTranslateText.brightnessMin
                                    break;
                                case 5:
                                    settingManager.setLcdBrightness(80)
                                    currentShowPage.title = YTranslateText.brightnessAdjust
                                    break;
                                }
                            }
                            return;
                        }
                        default:
                            resType = YEnum.IntroductionResult
                        }


                    }
                    case 1://查询天气
                        resType = YEnum.WeatherResult
                        break;
                    case 3://计算
                        resType = YEnum.CalcResult
                        break;
                    case 6://百科
                        resType = YEnum.WikiResult
                        break;
                    default:
                        resType = YEnum.IntroductionResult
                    }
                } else {
                    if (resJson == null)
                        resType = YEnum.RefreshResult
                    else{
                        if (typeof resJson.result == "undefined") {
                            resType = YEnum.RefreshResult

                        }
                        else if (resJson.result === null) {
                            resType = YEnum.IntroductionResult
                        }
                        else if (resJson.result === "error") {
                            resType = YEnum.IntroductionResult
                        }
                        else
                        {
                            let sShow = resJson.result[0].show;
                            let sType = resJson.result[0].type;

                            console.log(sShow, sType, "##########");
                            if (sShow === "INTRODUCTION") {
                                resType = YEnum.IntroductionResult;
                            }
                            else if (sShow === "SENTENCES") {
                                resType = YEnum.SentenceResult;
                            }
                            else if (sShow === "PRONOUNCE") {
                                resType = YEnum.PronounceResult;
                            }
                            else if (sShow === "DETAILS") {
                                if (sType === "POEM"){
                                    resType = YEnum.PoemResult;
                                }
                                else if (sType === "AUTHOR") {
                                    resType = YEnum.AuthorResult;
                                }
                                else if (sType === "WORD" || sType === "IDIOM"){
                                    resType = YEnum.WordCHDetailResult;
                                }
                                else if (sType === "CHAR") {
                                    resType = YEnum.CharDetailResult;
                                }
                                else if (sType === "EN_WORD" || sType === "CN_EN") {
                                    resType = YEnum.WordENDetailResult;
                                }
                                else if (sType === null){
                                    resType = YEnum.ExplainDetailResult;
                                }
                            }
                            else if (sShow === "MEANING") {
                                if (sType === "IDIOM") {
                                    resType = YEnum.IdiomMeanResult;
                                }
                                else if (sType === "WORD" || sType === "CHAR") {
                                    playTextInfo = resJson.result[0].title
                                    resType = YEnum.WordCHMeanResult;
                                }
                                else if(sType === "EN_WORD") {
                                    // playTextInfo = resJson.result[0].title
                                    resType = YEnum.WordENMeanResult;
                                }
                            }
                            else if (sShow === "TEXT") {
                                if (resJson.result[0].speech !== null) {
                                    playTextInfo = resJson.result[0].speech;
                                    resType = YEnum.CommonTextResult;
                                }
                                if (sType === "EN_WORD" || sType === "CHAR") {
                                    resType = YEnum.WordTextResult;
                                }
                            }
                            else
                                resType = YEnum.CommonTextResult;
                        }
                        console.log("####################",resType)
                    }
                }
                if (playTextInfo.length == 0){

                    playTextInfo = resJson.message;
                }
                console.log("speechManager.content.......>>>11111:")
                efficiencyReport.addClock("speech_start_tts");
                efficiencyReport.printReport()
                speechManager.saveSpeechDebugInfo("type:" + resType)
                speechManager.saveSpeechDebugInfo("tts:" + playTextInfo)
                qmlGlobal.audioPlayId = soundCenter.play(playTextInfo, "ch");
                id_pop_layer_asr.showPage("assistant/YSpeechDetail", {"resType": resType})
                logManager.sendHttpLog("view=assistant_right_view&query=%1".arg(speechManager.asrResult))

            }
            //查词翻译 card json
            //            {
            //                "metadata": {
            //                    "args": {
            //                        "attribute": "meaning",
            //                        "attribute_zh": "含义",
            //                        "text": "apple"
            //                    },
            //                    "func": "ec_dict.query"
            //                },
            //                "name": "command"
            //            }

            // message card josn
            //            {
            //                 "metadata":{
            //                  "msg":"下午好，有什么可以为您效劳"
            //                   },
            //                "name":"message",
            //                "speak":"下午好，有什么可以为您效劳"
            //            }

            // not_support card json
            //            {
            //             "metadata":{
            //             "msg":"小道没听懂，你可以换一种问法哦"
            //              },
            //             "name":"not_support",
            //              "speak":"小道没听懂，你可以换一种问法哦"
            //             }

            function onNewcontentChanged()
            {
                query_timeout.running = false
                if (id_asr_result_loader.forwardToChat) {
                    if (id_asr_result_loader.forwardAsrResult)
                        id_asr_result_loader.forwardAsrResult();
                    return;
                }
                let cardJson = JSON.parse(speechManager.newcontent);
                console.log("cvvvvvvvvvvvvvvvvv",speechManager.newcontent)
                let cardname = cardJson.name
                if(cardname === "command"){
                    var funcstr = cardJson.metadata.func
                    if(funcstr.search("_dict") != -1)
                    {
                        let dictstr = cardJson.metadata.args.text
                        if (!resultManager.entryResult(dictstr, "", "", YEnum.Speech, 1, false)) {
                            baseSignals.showToast(YTranslateText.queryFaildPleaseTryAgain, "#1A1B1F")
                        } else {
                            qmlGlobal.showDictPage(YEnum.PageIndex.Speech)
                            callback();
                        }

                    }
                    else if(funcstr.search("system.volume") != -1)
                    {

                        id_pop_layer_asr.showPage("settingpages/YSettingVolume");

                        if (null !== currentShowPage) {
                            switch (funcstr)
                            {
                            case "system.volume_down":{
                                let res = Math.max(0, settingManager.spkVolume - 10)
                                settingManager.setSpkVolume(res)
                                if (res == 0)
                                    currentShowPage.title = YTranslateText.volumeMin
                                else
                                    currentShowPage.title = YTranslateText.volumeDown
                            }
                            break;
                            case "system.volume_up":{
                                let res = Math.min(100, settingManager.spkVolume + 10)
                                settingManager.setSpkVolume(Math.min(100,settingManager.spkVolume + 10))
                                if (res == 100)
                                    currentShowPage.title = YTranslateText.volumeMax
                                else
                                    currentShowPage.title = YTranslateText.volumeUp
                            }
                            break;
                            case "system.volume_max":{
                                settingManager.setSpkVolume(100)
                                currentShowPage.title = YTranslateText.volumeMax
                            }
                            break;
                            case "system.volume_min":{
                                settingManager.setSpkVolume(1)
                                currentShowPage.title = YTranslateText.volumeMin
                            }
                            break;
                            case "system.volume_off":{
                                settingManager.setSpkVolume(0)
                                currentShowPage.title = YTranslateText.volumeMute
                            }
                            break;
                            case"system.volume_set":{
                                settingManager.setSpkVolume(80)
                                currentShowPage.title = YTranslateText.volumeAdjust
                            }
                            break;
                            }
                        }
                        return;
                    }
                    else if(funcstr.search("system.brightness") != -1)
                    {
                        // 亮度
                        id_pop_layer_asr.showPage("settingpages/YSettingBrightness");
                        if (null !== currentShowPage) {
                            switch (funcstr)
                            {
                            case "system.brightness_up":
                                let res = Math.min(100, settingManager.lcdBrightness + 10)
                                settingManager.setLcdBrightness(res)
                                if (res === 100)
                                    currentShowPage.title = YTranslateText.brightnessMax
                                else
                                    currentShowPage.title = YTranslateText.brightnessUp
                                break;
                            case "system.brightness_down":
                                settingManager.setLcdBrightness(Math.max(0, settingManager.lcdBrightness - 10))
                                if (res === 0)
                                    currentShowPage.title = YTranslateText.brightnessMin
                                else
                                    currentShowPage.title = YTranslateText.brightnessDown
                                break;
                            case "system.brightness_max":
                                settingManager.setLcdBrightness(100)
                                currentShowPage.title = YTranslateText.brightnessMax
                                break;
                            case "system.brightness_min":
                                settingManager.setLcdBrightness(0)
                                currentShowPage.title = YTranslateText.brightnessMin
                                break;
                            case "system.brightness_set":
                                settingManager.setLcdBrightness(80)
                                currentShowPage.title = YTranslateText.brightnessAdjust
                                break;
                            }
                        }
                        return;

                    }
                    else //不支持的fuc 不支持的问法
                    {
                        cardname = "message"
                        var speakTextInfo = YTranslateText.notsupport
                        var notsupport = {
                            "metadata":{
                                "msg":YTranslateText.notsupport
                            },
                            "name":"message",
                            "speak":YTranslateText.notsupport
                        }
                        speechManager.setNewContent(JSON.stringify(notsupport));
                        qmlGlobal.audioPlayId = soundCenter.play(speakTextInfo, "ch");
                        id_pop_layer_asr.showPage("assistant/YSpeechNewDetail", {"resType": cardname})

                    }

                }
                else //message not_support
                {
                    //  var cardType = cardname
                    var speakTextInfo = cardJson.speak
                    qmlGlobal.audioPlayId = soundCenter.play(speakTextInfo, "ch");
                    id_pop_layer_asr.showPage("assistant/YSpeechNewDetail", {"resType": cardname})

                }

            }

        }
        YTimer {  //查询超时定时器
            id:query_timeout
            interval: 2500
            //repeat: true
            //running: arsresult_type === "querying"
            running:false
            onTriggered: {
                soundCenter.playMusic(qmlGlobal.tipsAudioPath+ "speech_no_result.mp3");
                baseSignals.showToast(YTranslateText.querytimeout, YColors.grayNormal)
                speechManager.recognizing = YEnum.AS_ASTip
                callback();
            }
        }
        YText {
            id: id_result_query_tip
            font.pixelSize: settingManager.uiLanguage === YEnum.EN_US ? 28 : 32
            anchors.bottom:parent.bottom
            anchors.bottomMargin:30
            width:180
            anchors.horizontalCenter: parent.horizontalCenter
            textFormat: YTextMedium.RichText
            lineHeight: settingManager.uiLanguage === YEnum.EN_US ? 24 : 36
            lineHeightMode: YTextMedium.FixedHeight
            wrapMode: YTextBase.Wrap
            horizontalAlignment:  YText.AlignLeft
            color: YColors.blueText

        }
        SequentialAnimation { // 你说我在听...
            id: id_listening_animation
            loops: SequentialAnimation.Infinite
            running: true
            PropertyAction { target: id_result_empty_tip; property: "text"; value: YTranslateText.imListening + "..." }
            PauseAnimation { duration: 420 }
            PropertyAction { target: id_result_empty_tip; property: "text"; value: YTranslateText.imListening }
            PauseAnimation { duration: 420 }
            PropertyAction { target: id_result_empty_tip; property: "text"; value: YTranslateText.imListening + "." }
            PauseAnimation { duration: 420 }
            PropertyAction { target: id_result_empty_tip; property: "text"; value: YTranslateText.imListening + ".." }
            PauseAnimation { duration: 420 }
        }
//        SequentialAnimation { //正在查询
//            id: id_query_animation
//            loops: SequentialAnimation.Infinite
//            running: false
//            PropertyAction { target: id_result_query_tip; property: "text"; value: YTranslateText.imQuerying + "..." }
//            PauseAnimation { duration: 420 }
//            PropertyAction { target: id_result_query_tip; property: "text"; value: YTranslateText.imQuerying }
//            PauseAnimation { duration: 420 }
//            PropertyAction { target: id_result_query_tip; property: "text"; value: YTranslateText.imQuerying + "." }
//            PauseAnimation { duration: 420 }
//            PropertyAction { target: id_result_query_tip; property: "text"; value: YTranslateText.imQuerying + ".." }
//            PauseAnimation { duration: 420 }
//        }
        YImage{
            id: id_more_text
            visible:arsresult_type === "recording"
            anchors.bottom:id_top_screen_animation.top
            anchors.bottomMargin:-80
            anchors.horizontalCenter: parent.horizontalCenter
            imageName: "assistant/recording"
            sourceSize: Qt.size(180, 100)
        }
        YAnimatedImagesView {
            id: id_top_screen_animation
            anchors.bottom:parent.bottom
            anchors.horizontalCenter: parent.horizontalCenter
            frameSize:arsresult_type === "recording"? Qt.size(180, 80) :Qt.size(240, 80)
            objectName:   "id_asr_result_loader.qml"
            imageName:  arsresult_type === "recording"? "asr_recording" :"asr_querying"  //id_query_animation.running ? "":"asr_recording"
            imageNameLoop: arsresult_type === "recording"? "asr_recording" :"asr_querying" //id_query_animation.running ? "": "asr_recording"
            frameCount: arsresult_type === "recording"? 79 :93
            frameCountLoop:  arsresult_type === "recording"? 79 :93
            YButtonBaseMouseArea {
                id: id_button
               // enable:arsresult_type === "recording"
                anchors.fill: parent
                onValidClicked: {
                    if(id_asr_result_appand_area.text === "")
                    {
                        soundCenter.playMusic(qmlGlobal.tipsAudioPath+ "speech_no_result.mp3");
                        baseSignals.showToast(YTranslateText.tryaskAgain, YColors.grayNormal)
                        speechManager.recognizing = YEnum.AS_ASTip
                        callback();
                        return ;
                    }
                     speechManager.stopAsrRecord()// 停止录音
                   // id_query_animation.running = true
                   //id_top_screen_animation.stopPlay()
                    arsresult_type = "querying"
                    query_timeout.restart();
                }
                objectName: "YListennigButton.qml_id_button"
            }

//            YTimer {
//                interval: 200
//                repeat: false
//                 running: true
//                onTriggered: { //延迟200ms 显示动画
//                    id_top_screen_animation.visible = true
//                }
//            }

        }


        Component.onCompleted:
        {
            id_top_screen_animation.play()
        }
    }
}

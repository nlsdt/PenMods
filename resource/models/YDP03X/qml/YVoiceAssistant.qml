import QtQuick 2.12
import com.youdao.pen 1.0

import BaseQml 1.0
import "./i18n"
import "./components"
import "./assistant"
// 新版语音助手 语音助手页面
YPage {
    id: id_touch_talk_page
    objectName: "YPage===YVoiceAssistant.qml"
    property string currentPlayingBaseImageName: "asr_starting"
    property var enterTimestamp: null
    readonly property bool forwardVoiceToChat: !antiEmbs.active && mod.voiceChatEnabled
    property bool voiceChatForwarded: false
    property bool voiceChatCancelled: false
    property int voiceChatSequence: 0

    function cancelVoiceChat() {
        voiceChatCancelled = true;
        ++voiceChatSequence;
    }

    function forwardAsrResultToChat() {
        if (!visible || !forwardVoiceToChat || voiceChatCancelled || voiceChatForwarded)
            return false;
        if (speechManager.recognizing !== YEnum.AS_ASREnd
                && speechManager.recognizing !== YEnum.AS_QueryBeign)
            return false;
        var text = speechManager.asrResult.trim();
        if (text.length === 0)
            return false;
        voiceChatForwarded = true;
        mod.pendingVoiceChatText = text;
        backButtonClicked();
        qmlGlobal.requestShowThirdQML("ChatAssistant");
        return true;
    }

    function scheduleVoiceChat() {
        var sequence = voiceChatSequence;
        Qt.callLater(function() {
            if (sequence === voiceChatSequence)
                forwardAsrResultToChat();
        });
    }
    YVerticalTitleBar {
        id: id_title_bar
        onCallBack: {
            backButtonClicked();
        }
    }
    YText {
        anchors.top: parent.top
        anchors.topMargin: 22
        anchors.left: parent.left
        anchors.leftMargin: 90
        wrapMode: YText.Wrap
        text: "您可以这样问"// YTranslateText.aivoiceassistant
        font.family: fontManager.fontFamilyZhCn
        font.pixelSize: 28
    }
    YPopLayer {
        id: id_pop_layer
        function showPage(qrcqml, properties) {
            console.warn("chenjunhao==================================qrcqml： ", qrcqml)
            show(qrcqml, false, false, properties)
            popcurrentShowPage = popItemObject
            popcurrentShowPage.backButtonClicked.connect(function(){
                popcurrentShowPage = null
                speechAsrResultLoader.active = false
                speech_guide_rect.visible = false
            })
            qmlGlobal.requestSpeechPageClosed.connect(function(){
                popcurrentShowPage.backButtonClicked()
                popcurrentShowPage = null
                speechAsrResultLoader.active = false
                speech_guide_rect.visible = false
            })
        }
    }
    property var popcurrentShowPage: null
    YText {
        anchors.top: parent.top
        anchors.topMargin: 22
        anchors.right: parent.right
        anchors.rightMargin:30
        horizontalAlignment: YText.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        textFormat: Text.RichText
        text: YTranslateText.allvoiceask.arg(YColors.blueText)
        font.pixelSize: 28
        YButtonBaseMouseArea {
            id: all_id_button
            anchors.fill: parent
            onValidClicked: {
                console.log("show all ask page....");
                id_pop_layer.showPage("assistant/YAllVoiceQuestions")
            }
        }
    }
    YIconButton {
        id: id_more_button_bg
        implicitWidth: 44
        implicitHeight: 44
        mouseAreaMargins: -18
        radius: height/2
        anchors.left: parent.left
        anchors.leftMargin: 16
        anchors.bottom: parent.bottom
        anchors.bottomMargin:6
        sourceSize: Qt.size(13, 21)
        imageName: "commons/help"
        onClicked: {
            id_pop_layer.showPage("components/YSpeechPageguide");
        }
    }
    Rectangle
    {
        width: parent.width
        height: 52
        color: YColors.black
       anchors.top: parent.top
       anchors.topMargin: 90
        Flickable {
            id: imageload
            contentWidth: image.width;
            contentHeight: image.height
            flickDeceleration:Flickable.HorizontalFlick
            YImage
            {
                id: image
                asynchronous : true //异步加载,默认为false,如果是加载网络资源(例如HTTP)的图像,那么必须为true
                imageName : "large_animation/speech_guide/voicegui"
                cache: false
                fillMode: Image.Pad
                onStatusChanged: {
                    if (image.status == Image.Error)
                        console.log("加载图片失败");
                }
                SequentialAnimation on x {
                    running: !imageload.dragging
                    id:p2
                    loops: Animation.Infinite

                    PropertyAnimation {
                        from:  0
                        to:  -4816//-image.paintedWidth
                        duration: 60*1000 * 2
                    }
                }

            }
            YImage
            {
                id: image2
                anchors.left: image.right
                anchors.leftMargin: 30
                asynchronous : true
                imageName : "large_animation/speech_guide/voicegui"
                cache: false
                fillMode: Image.Pad
                onStatusChanged: {
                    if (image.status == Image.Error)
                        console.log("加载图片失败");
                }

                SequentialAnimation on x {
                    id:p1
                    running: !imageload.dragging
                    loops: Animation.Infinite

                    PropertyAnimation {
                        from: 4816 + 30//image.paintedWidth
                        to: 0
                        duration: 60*1000*2
                    }
                }

            }

        }
    }



    YImage
    {

        anchors.bottom:parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        imageName: "assistant/asr_starting"
        sourceSize: Qt.size(192, 100)

        YButtonBaseMouseArea {
            id: id_button
            anchors.fill: parent
            onValidClicked: {
                if (!wifiManager.internetConnect)
                {
                    baseSignals.showToast(YTranslateText.articleNeedNetWork, YColors.grayNormal)
                    return;
                }
                if(recordpagetimer.running || speechAsrResultLoader.active )
                {
                    return
                }

                recordpagetimer.restart();

            }
            objectName: "YListennigButton.qml_id_button"
        }

    }

    YTimer {
        id:recordpagetimer
        interval: 300
        repeat: false
        running: false
        onTriggered: { //延迟400ms 显示录音页面
            speechAsrResultLoader.active = true
           speechManager.startAsrRecord()// 开始录音
        }
    }
    Rectangle
    {
        id:speech_guide_rect
        anchors.fill: parent
        color: "black"
        opacity: 0.7
        visible: settingManager.enterSpeechPageTimes() > 0 ? false : true //引导页只显示一次
        //鼠标事件不传递给父对象
        MouseArea
        {
            anchors.fill: parent
            onPressed: {
                mouse.accepted = true
            }
        }
        YIconButton {
            id: id_more_button_rect
            implicitWidth: 44
            implicitHeight: 44
            mouseAreaMargins: -18
            radius: height/2
            anchors.left: parent.left
            anchors.leftMargin: 16
            anchors.bottom: parent.bottom
            sourceSize: Qt.size(13, 21)
            imageName: "commons/help"
            onClicked: {
                id_pop_layer.showPage("components/YSpeechPageguide");

            }
        }
        YImage {
            id:id_more_button_duide
            //anchors.horizontalCenter: parent.horizontalCenter
            anchors.left: id_more_button_rect.right
            anchors.leftMargin: 16
            anchors.bottom: parent.bottom
            anchors.bottomMargin:6
            sourceSize: Qt.size(55, 39)
            imageName: "assistant/Vector"
        }
        YText {
            anchors.left: id_more_button_duide.right
            anchors.leftMargin: 16
            anchors.bottom: parent.bottom
            anchors.bottomMargin:8
            color:YColors.white
            font.pixelSize: 26
            text: YTranslateText.howtouserassistant;
        }
    }
    Component.onCompleted:
    {
        if(settingManager.enterSpeechPageTimes() <3)
            settingManager.setSpeechPageTimes();

    }
    //显示正在说的内容
    YSpeechAsrResult
    {
        id:speechAsrResultLoader
        forwardToChat: id_touch_talk_page.forwardVoiceToChat
        forwardAsrResult: id_touch_talk_page.forwardAsrResultToChat
        active: false
        asynchronous: false
        onCallback:
        {
            id_touch_talk_page.cancelVoiceChat();
            popcurrentShowPage = null
            speechAsrResultLoader.active = false
            //speechAsrResultLoader.sourceComponent = undefined
            speechManager.stopAsrRecord()// 结束录音
        }
    }
    Connections {
        target: speechManager
        ignoreUnknownSignals: true
        enabled: id_touch_talk_page.visible
        function onAsrResultChanged() {
            if (speechManager.recognizing === YEnum.AS_ASREnd
                    || speechManager.recognizing === YEnum.AS_QueryBeign)
                id_touch_talk_page.scheduleVoiceChat();
        }
        function onRecognizingChanged() {
            console.log("speechManager.recognizing-------------11",speechManager.recognizing)
            if (speechManager.recognizing === YEnum.AS_ASRBegin ){
                ++id_touch_talk_page.voiceChatSequence;
                id_touch_talk_page.voiceChatForwarded = false;
                id_touch_talk_page.voiceChatCancelled = false;
                speechAsrResultLoader.active = true
                //  soundCenter.playMusic(qmlGlobal.tipsAudioPath+ "listen.mp3");
            } else if (speechManager.recognizing === YEnum.AS_ASREnd || speechManager.recognizing === YEnum.AS_QueryBeign) {
                speechAsrResultLoader.active = true
                id_touch_talk_page.scheduleVoiceChat();
            }
            else {
                if (speechManager.recognizing === YEnum.AS_ASTip) {
                    speechAsrResultLoader.active = false

                }

            }
        }
    }
    Connections {
        target: qmlGlobal
        ignoreUnknownSignals: true
        function onBackToSpeechPage()
        {
            speechAsrResultLoader.sourceComponent = undefined
        }

        function onRequestSpeechPageClosed() {
            id_touch_talk_page.backButtonClicked()
        }
    }
    onVisibleChanged: {
        if (visible) {
            qmlGlobal.currentPageIndex = YEnum.PageIndex.Speech
            logManager.sendHttpLog("view=assistant_view&query=%1".arg(speechManager.asrResult))
            enterTimestamp = new Date()
        } else {
            cancelVoiceChat();
        }
    }
    Component.onDestruction: {
        console.log("YSpeechPage.qml===Component.onDestruction===called")
        if (enterTimestamp !== null) {
            logManager.sendHttpLog("action=assistant_stay_time&duration=%1".arg(Math.floor(new Date() - enterTimestamp) / 1000))
            enterTimestamp = null
        }
    }
}

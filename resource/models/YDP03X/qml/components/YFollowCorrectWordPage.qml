import QtQuick 2.12
import com.youdao.pen 1.0
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
import BaseQml 1.0
import "../i18n"
YPage {
    anchors.fill: parent
    YIconButton {
        id: id_spell_switch
        implicitWidth: 44
        implicitHeight: 44
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.leftMargin: 16
        anchors.topMargin: 18
        enabled: true
        visible: true
        sourceSize: Qt.size(36, 36)
        imageName: "commons/close"
        mouseAreaMargins: -10
        radius: 22
        onClicked: {
//            isBacked = true
//            soundCenter.stop()
//            speellStop()
//            backButtonClicked()
            back()
        }
    }
    property var correctComparePageId: null
    YPopLayer {
        id: id_pop_layer
        function showPage(qrcqml, properties) {
            show(qrcqml, false, false, properties)
            correctComparePageId = popItemObject
            correctComparePageId.backButtonClicked.connect(function(){
                correctComparePageId = null
                if(isBackRoot){
//                    isBacked = true
//                    soundCenter.stop()
//                    speellStop()
//                    backButtonClicked()
                    back()
                }
            })
        }
    }

    function back(){
        if(newPronunciation)
            updatePrePage(newPronunciation)
        isBacked = true
        soundCenter.stop()
        speellStop()
        backButtonClicked()
    }

    signal updatePrePage(var correct)

    property bool isBackRoot: false
    property int currentIndex: -1
    property var currentWordJson: null
    property bool isReaded: false
    property string guideTitle: "发音示范中..."
    property int newPronunciation: 0
    property int isCorrect: 0

    property bool  isStartFollow : false
    property bool isFollowed: false
    property int soundTaskId: -1
    property bool isBacked: false

    property int oldPronunciation : 0
    onCurrentWordJsonChanged: {
//        console.log("seven:updateWordStatus:0")
        oldPronunciation = currentWordJson.pronunciation
        setSetp(currentIndex)
    }

    function setSetp(index){
        id_status_bar.updateSetp(index ==-1 ? 0: index)
        switch(index) {
        case -1:
            guideTitle = "发音示范中..."
            console.log("seven:onEnd:00:",currentIndex,soundTaskId)
            soundTaskId = soundCenter.playMusic(qmlGlobal.tipsAudioPath+ "follow_guide_1.mp3")
            console.log("seven:onEnd:00000000000:",currentIndex,soundTaskId)
            updateWordStatus(index)
            break
        case 0:
            guideTitle = "发音示范中..."
//            a&phonetic=eɪ&type=2 en 5
//            colour&phonetic=kʌlər&type=2
//            console.log("seven:orgPhoneme:", currentWordJson.orgPhoneme)
//            if(currentWordJson.orgPhoneme && currentWordJson.orgPhoneme.length > 0){
//                soundTaskId = soundCenter.play(currentWordJson.word, "en")
//                var temp_phonetic_info = currentWordJson.word + "&phonetic="
//                temp_phonetic_info += currentWordJson.orgPhoneme
//                temp_phonetic_info += "&type="
//                if(settingManager.autoPronounceType) temp_phonetic_info += "2"
//                else temp_phonetic_info += "1"
//                console.log("seven:orgPhoneme:1:", temp_phonetic_info)
//                soundTaskId = soundCenter.play(temp_phonetic_info,
//                                                         "en",
//                                                         temp_phonetic_info,
//                                                         5)
//            }else{
//                soundTaskId = soundCenter.play(currentWordJson.word, "en")
//            }
            soundTaskId = soundCenter.play(currentWordJson.word, "en")
            updateWordStatus(index)
            break
        case 1:
            guideTitle = "发音讲解中..."
            soundTaskId = soundCenter.play(currentWordJson.lowestpPhone,
                                                    "en",
                                                    currentWordJson.lowestpPhone, 7)
            updateWordStatus(index)
            break
        case 2:
            guideTitle = "请再读一遍"
            soundCenter.playMusic(qmlGlobal.tipsAudioPath+ "follow_guide_2.mp3")
            updateWordStatus(index)
            break
        default:
            guideTitle = ""
        }
        console.log("seven:setSetp:",index)

    }

    function updateWordStatus(index){
        console.log("seven:updateWordStatus:",index,currentWordJson.word,currentWordJson.richContent)
//        id_first_loader.item.symbolWord =currentWordJson.wordEx//currentWordJson.word
        switch (index){
        case -1:
        case 0:
//            id_first_loader.item.symbolPhonetic = currentWordJson.phonemes
            break;
        case 1:
            id_first_loader.item.symbolPhonetic = currentWordJson.richTextPhonemes
            break
        case 2:
            id_first_loader.item.symbol_Word_Phonetic = currentWordJson.richContent
            break
        default:

        }
    }

    Item {
        id: id_right_menu_bar
        width: rightBarWidth
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.topMargin: 3
        anchors.bottomMargin: 3

        Column {
            width: parent
            spacing: 20
            visible: {
                if(!isFollowed) return false
                else return !isStartFollow
            }
            YFollowMedalButton {
                width: 70
                height: 70
                medal_width: 70
                mdeal_height: 70
                mdeal_title_font: 27
                mdeal_title_v_ofset: 5
                mdeal_title_text: newPronunciation//overall
                onMedalClick: {
                    jumpCorrectComparePage()
                    serResultData(false)
                }
            }

            Rectangle {
                width: 70
                height: 70
                color: "transparent"
                visible: false
                YImage {
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.verticalCenter: parent.verticalCenter
                    width: 68
                    height: 68
                    sourceSize: Qt.size(width, height)
                    imageName: "dict/follow_ai_icon"
                    fillMode: Image.PreserveAspectFit
                }
                MouseArea{
                    anchors.fill: parent
                    onClicked: {
                    }
                }
            }
        }
    }

    YFollowStatusBar {
        id: id_status_bar
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.rightMargin: 16
        anchors.topMargin: 19
        anchors.bottomMargin: 19
        width: 6
        visible: currentIndex !== 3
        Component.onCompleted: {

        }
    }


    Column {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.leftMargin: 60
        anchors.rightMargin: 22
        anchors.topMargin: 26

        //发音示范中 (指导标题)
        YText {
            id: id_guide_title
            font.family: "OPPOSans"
            height: 29
            width: parent.width
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment  : Text.AlignHCenter
            font.pixelSize: 22
            color: "#A8AAB2"
            visible: currentIndex !== 3 //guideTitle.length
            text: guideTitle
        }

        YSpacingForColumn{
            height: 43
            visible: currentIndex !== 3
        }

        // 第一步
        YLoader {
            width: parent.width
            id: id_first_loader
            asynchronous: false
            active: true
            sourceComponent:{
                console.log("seven:sourceComponent:0:",currentIndex)
                switch(currentIndex){
                case -1:
                case 0:
                    return id_first_componet
                case 1:
                    return id_second_componet
                case 2:
                    return id_third_conponet
                default:
                    if(isBackRoot){
                        return null
                    }
                    return id_fourth_componet
                }
            }
        }

        //发音示范中
        Component {
            id: id_first_componet
            Rectangle {
                property alias symbolWord:id_symbol_word.text
                property alias symbolPhonetic: id_symbol_phonetic.text
                width: parent.width
                height: 75
                color: "transparent"
                YText {
                    id: id_symbol_word
                    font.family: "OPPOSans"
                    width: parent.width
                    height: {
                        if(currentWordJson.word.length > followManager.getFullWordLength()) return 30
                        return 40
                    }
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment  : Text.AlignHCenter
                    font.pixelSize: {
                        if(currentWordJson.word.length > followManager.getFullWordLength()) return 30
                        return 40
                    }
                    font.bold: true
                    color: "#FFFFFF"
                    text: currentWordJson.wordCompleteEx//""
                }
                YText {
                    id: id_symbol_phonetic
                    font.family: "OPPOSans"
                    anchors.top:id_symbol_word.bottom
                    anchors.topMargin: {
                        if(currentWordJson.phonemes.length > followManager.getFullWordLength()) return 50
                        return 5
                    }
                    width: parent.width
                    height: 30
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment  : Text.AlignHCenter
                    font.pixelSize: 30
                    color: "#878A99"
                    text: currentWordJson.phonemes//""
                }
            }
        }

        //发音讲解中
        Component {
            id: id_second_componet
            Rectangle {
                property alias symbolWord:id_symbol_word.text
                property alias symbolPhonetic: id_symbol_phonetic.text
                width: parent.width
                height: 96
                color: "transparent"
                Row {
                    width: parent.width
                    height: id_symbol_detail.contentHeight + 28 //parent.height
                    Rectangle {
                        width: parent.width / 2 - 40
                        height: 75//parent.height
                        anchors.verticalCenter: parent.verticalCenter
                        color: "transparent"
                        YText {
                            id: id_symbol_word
                            font.family: "OPPOSans"
                            width: parent.width
                            height:{
                                if(currentWordJson.word.length > followManager.getWordLength()) return 30
                                return 40
                            }
                            verticalAlignment: Text.AlignVCenter
                            horizontalAlignment  : Text.AlignHCenter
                            font.pixelSize: {
                                if(currentWordJson.word.length > followManager.getWordLength()) return 30
                                return 40
                            }//40
                            font.bold: true
                            color: "#FFFFFF"
                            text: currentWordJson.wordEx//""
                        }
                        YText {
                            id: id_symbol_phonetic
                            font.family: "OPPOSans"
                            anchors.top:id_symbol_word.bottom
                            anchors.topMargin: {
                                if(currentWordJson.phonemes.length > followManager.getWordLength()) return 50
                                return 5
                            }
                            width: parent.width
                            height: 30
                            verticalAlignment: Text.AlignVCenter
                            horizontalAlignment  : Text.AlignHCenter
                            textFormat: Text.RichText
                            font.pixelSize: 30
                            color: "#878A99"
                            text: ""
                        }

                    }

                    Rectangle {
                        width: parent.width / 2 + 40
                        height: parent.height
                        color: "transparent"
                        Rectangle {
                            anchors.left: parent.left
                            anchors.bottom: parent.bottom
                            anchors.top: parent.top
                            anchors.right: parent.right
                            anchors.rightMargin: 40
                            color: "#081C2D"
                            radius: 12
                            YText {
                                id: id_symbol_detail
                                anchors.left: parent.left
                                anchors.right: parent.right
                                anchors.bottom: parent.bottom
                                anchors.top: parent.top
                                anchors.leftMargin: 30
                                anchors.rightMargin: 30
                                anchors.topMargin: 14
                                anchors.bottomMargin: 14
                                font.family: "OPPOSans"
                                verticalAlignment: Text.AlignVCenter
                                horizontalAlignment  : Text.AlignHCenter
                                wrapMode: Text.WordWrap
//                                textFormat: Text.RichText
//                                elide: Text.ElideRight
                                font.pixelSize: 26
                                color: "#878A99"
                                text: currentWordJson.phone_guide//.length > 22 ? (currentWordJson.phone_guide.substring(0,22) + "...") : currentWordJson.phone_guide
                            }
                        }

                    }
                }
            }
        }

        //再读一边
        Component {
            id: id_third_conponet
            Rectangle {
                property alias symbol_Word_Phonetic: id_symbol_phonetic.text
                width: parent.width
                height: 40
                color: "transparent"
                YText {
                    id: id_symbol_phonetic
                    anchors.fill: parent
                    font.family: "OPPOSans"
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment  : Text.AlignHCenter
                    wrapMode: Text.WordWrap
                    textFormat: Text.RichText
                    font.bold :true
                    font.pixelSize: 40
                    color: "#FFFFFF"
                    text: {
                        console.log("seven:followResults:onResultChanged:correct:7:")
                        if(isReaded) return currentWordJson.richHighlightedContent
                        return currentWordJson.richContent
                    }
                }


            }
        }

        Component {
            id: id_fourth_componet
            Rectangle {
                width: parent.width
                height: id_pronunciation_colum.height
                color: "transparent"
                Column {
                    id: id_pronunciation_colum
                    width: parent.width
                    YFollowPronunciation {
                        width: parent.width
                        followEnable: !isStartFollow
                        wordText:{
                            if(isReaded) return currentWordJson.richContentPhHighlightedType
                            return currentWordJson.richContentPhType
                        }
                    }
                }
            }
        }
    }
    //60 22
    Row {
        id: id_my_follow_row
        spacing: 20
        width: 118 + 20 + 124
        height: 45
        anchors.verticalCenter: parent.verticalCenter
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.horizontalCenterOffset: 19
        visible:{
            if(currentIndex !== 3) return false
            return !isStartFollow
            /*isStartFollow*/
        }
        //我的发音
        YMyFollowAudioButton{
            id: id_my_audio_button
            visible: parent.visible
        }
        //AI纠音
        Rectangle {
            width: 124
            height: 45
            color: "#5278FF"
            radius: 16
            visible: parent.visible
            YText {
                id: id_symbol_phonetic
                anchors.fill: parent
                font.family: "OPPOSans"
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment  : Text.AlignHCenter
                font.pixelSize: 28
                color: "#FFFFFF"
                text: "AI纠音"
            }

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    soundTaskId = -1
                    currentIndex = -1
                    isStartFollow = false
                    isFollowed = false
                    id_status_bar.resetStatusbar()
                    setSetp(currentIndex)

                }
            }
        }
    }

    //发音控制条
    YRecordAnimationComponet {
        visible: currentIndex === 2 || currentIndex === 3
        anchors.bottom: parent.bottom
//        anchors.horizontalCenter: parent.horizontalCenter
        anchors.horizontalCenter: id_my_follow_row.horizontalCenter
//        anchors.horizontalCenterOffset: {
//            if(isStartFollow) return 0
//            return 20
//        }
        onRecordStart: {
            isStartFollow = true
            isFollowed = true
            isReaded = false
            speellStart()
        }
        onRecordStop: {
            isStartFollow = false
            jumpCorrectComparePage()
            speellStop()
            updateStep()
            console.log("seven:jumpCorrectComparePage:0")

        }
    }

    onUpdatePrePage:{
        isCorrect = correct
    }

    function speellStart(){
        console.log("seven:followResults:onResultChanged:correct:0",currentWordJson.word,currentWordJson.orgPhoneme)
        followManager.startFollow(currentWordJson.word,
                                  currentWordJson.orgPhoneme, 200);
    }

    function speellStop(isJump = true){
        id_my_audio_button.isSentenceFollow = false
        console.log("seven:isSentenceFollow:",id_my_audio_button.isSentenceFollow)
        followManager.stopFollow("/tmp/cursoundWord");
    }

    function jumpCorrectComparePage(){
        console.log("seven:jumpCorrectComparePage:1")
        id_pop_layer.showPage("components/YFollowComparePage")
        console.log("seven:jumpCorrectComparePage:2")
    }

    Timer {
        property alias secondsinterval: id_countDown.interval
        id:id_countDown;
//        interval: 3000
        repeat: false
        onTriggered: {
            updateStep()
        }
    }

    function startTime(seconds){
        id_countDown.secondsinterval = seconds
        id_countDown.start()
    }

    function updateStep(){
        if(currentIndex < 3)
            currentIndex ++
        console.log("seven:onEnd:2:",currentIndex)
        setSetp(currentIndex)
    }

    Connections {
        target: soundCenter
        ignoreUnknownSignals: true
//        enabled: id_audio_play_icon_label_button.visible
        function onEnd(seq) {
            console.log("seven:onEnd:1:",currentIndex,seq,soundTaskId)
            if(!isBacked && seq === soundTaskId){
                soundTaskId = -1
                updateStep()
            }
        }
        function onSoundSuspend(seq) {

        }
    }


    Connections {
        target: followManager
        ignoreUnknownSignals: true
        function onVadStop(taskId) {
            console.log("seven:followResults:onVadStop:",followManager.result)
        }

        onResultChanged:{
            console.log("seven:followResults:onResultChanged:correct:1:",followManager.result)
//            if(!isReceive) return
            try{
                var phoneticSymbolJson = JSON.parse(followManager.result);
            } catch(e){}
            console.log("seven:followResults:onResultChanged:correct:2:",followManager.result)
            if(typeof phoneticSymbolJson != "undefined"){
                console.log("seven:followResults:onResultChanged:correct:3:",followManager.result)
                if(phoneticSymbolJson.constructor === Array &&
                   phoneticSymbolJson.length > 0 ){
                    console.log("seven:followResults:onResultChanged:correct:4:",followManager.result)
                    if(phoneticSymbolJson[0].st.ws.constructor === Array &&
                       phoneticSymbolJson[0].st.ws.length > 0){
                        console.log("seven:followResults:onResultChanged:correct:5:",followManager.result)
                        if(phoneticSymbolJson[0].st.ws[0].w.toLowerCase() === currentWordJson.word.toLowerCase()) {
                            console.log("seven:followResults:onResultChanged:correct:6:",followManager.result)
                            isReaded = true
                        }
                    }

                }else {
                    if(phoneticSymbolJson.pronunciation){
                        newPronunciation = phoneticSymbolJson.pronunciation
                        serResultData()
                    }
                }
            }
        }
    }

    function serResultData(isautuClose = true){
//        updatePrePage(newPronunciation)
        correctComparePageId.setResultsData(currentWordJson.wordEx,
                                            currentWordJson.phonemes,
                                            /*currentWordJson.pronunciation*/oldPronunciation,
                                            newPronunciation,
                                            isautuClose)
    }

    Connections {
        target: systemBase
        ignoreUnknownSignals: true
        //enabled: id_dict_page.visible
        function onOcrStart() {
//            back()
        }
        function onOcrStop(scanType) {
            back()
        }
    }
}

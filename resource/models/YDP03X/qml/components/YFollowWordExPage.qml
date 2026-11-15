import QtQuick 2.12
import com.youdao.pen 1.0
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
import BaseQml 1.0
import "../i18n"

YPage {
    id: id_follw_word_read_page
    anchors.fill: parent
    YVerticalTitleBar {
        id: id_title_bar
        onCallBack: {
            speellStop(false)
            backButtonClicked()
        }
        YIconButton {
            id: id_spell_switch
            implicitWidth: 44
            implicitHeight: 44
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.leftMargin: 16
            enabled: true
            visible: false
            sourceSize: Qt.size(36, 36)
            imageName: "/follow/switch"
            mouseAreaMargins: -10
            radius: 22
            onClicked: {
                console.log("seven:/follow/switch")
            }
        }
    }

    function back(){
        speellStop(false)
        backButtonClicked()
    }

    function getPhoneType(){
        if(settingManager.autoPronounceType){
            if(!phoneticJsonObj.usphone) return ""
            return phoneticJsonObj.usphone.length > 0 ? "美" : ""
        }
        if(!phoneticJsonObj.ukphone) return ""
        return phoneticJsonObj.ukphone.length > 0 ? "英" : ""
    }

    function queryWordInfo(){
        console.log("seven:queryWordInfo:0")
        word = {}
        var wordObj = {}
        console.log("seven:queryWordInfo:1:",followManager.content)
        phoneticJsonObj = getPhoneWord()
        console.log("seven:queryWordInfo:2:",followManager.content)
        console.log("seven:queryWordInfo:3")
        var phoneStr = phoneticJsonObj.usphone
        if(/*followManager.isUk*/settingManager.autoPronounceType === 0)
            phoneStr = phoneticJsonObj.ukphone

        wordObj.word = followManager.content
        console.log("seven:queryWordInfo:4:",followManager.content)
        wordObj.pronunciation = 0
        wordObj.orgPhoneme = phoneStr ? phoneStr : ""
        wordObj.phonemes = phoneStr ? ("/" + phoneStr + "/" ): ""
        console.log("seven:queryWordInfo:5")
        //分值标红
        wordObj.richTextPhonemes = "/" + "<>" + "/"
        //未读
        var temp_phones = getPhoneType().length ? (getPhoneType() + wordObj.phonemes) : ""
        console.log("seven:queryWordInfo:6", temp_phones)
        var temp_space = " "
        if((wordObj.word + temp_phones).length > 40) temp_space = " <br/> "
        wordObj.richContent = '<font color="%1">%2</font>'.arg("#FFFFFF").arg(wordObj.word) + temp_space + '<font size="30px" color="%1">%2</font>'.arg("#878A99").arg(temp_phones)
        console.log("seven:wordObj.richContent",wordObj.richContent)
        //已读
        wordObj.richHighlightedContent = ""
        var phType = "美"
        if(/*followManager.isUk*/settingManager.autoPronounceType) phType = "英"
        wordObj.richContentPhType = ""
        wordObj.richContentPhHighlightedType = ""
        word = wordObj
        console.log("seven:queryWordInfo:7",wordObj.richContent)
    }

    property var currentPageID: null
    YPopLayer {
        id: id_pop_layer
        function showPage(qrcqml, properties) {
            show(qrcqml, false, false, properties)
            currentPageID = popItemObject
        }
    }

    property int rightBarWidth: 80

    property int topSpaceHeight: 60

    property int bottomSpaceHeight: 80

    property bool isReaded: false
    property int fluency : 0
    property int integrity : 0
    property int overall : 0
    property int pronunciation : 0
    property var words: []
    property int seg_rang: 0 ////断句标志
    property bool isReceive: true
    property bool isError: false // 分析结果

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
            visible: isReaded
            YFollowMedalButton {
                width: 70
                height: 70
                medal_width: 70
                mdeal_height: 70
                mdeal_title_font: 27
                mdeal_title_v_ofset: 5
                mdeal_title_text: overall
                onMedalClick: {
                    jupToFFollowScorePage(false)
//                    showScorePage(false)
                    jumpFollowWordScorePage(false)
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
//                        isReceive = false
//                        jumpToFollowCorrectWordListPage()
//                        correctPageId.setCorrectWordlistData(words)

                    }
                }
            }
        }
    }


    Item {
        id: id_content_center
        anchors.left: id_title_bar.right
        anchors.top: parent.top
        anchors.right: id_right_menu_bar.left
        anchors.bottom: parent.bottom

        Column {
            id: id_word_colum
            width: parent.width
            YSpacingForColumn{
                height: isReaded ? 30 : 67
                visible: true
            }
            YFollowPronunciation {
                followEnable: !isFollow
                wordText: {
                    if(isReaded) word.richContentPhType
                    return word.richContent
                }
                width: parent.width
            }
        }
    }

    Row {
        spacing: 20
        width: 118 + 20 + 124
        height: 45
        anchors.verticalCenter: parent.verticalCenter
        anchors.horizontalCenter: parent.horizontalCenter
        visible: isReaded
        YMyFollowAudioButton{
            id: id_my_audio_button
            visible: isReaded
            followEnable: !isFollow
        }
        Rectangle {
            width: 124
            height: 45
            color: "#5278FF"
            radius: 16
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
                    if(isError){
                        baseSignals.showToastEx("AI纠音还在学习中...", "#2D2E33", 1500)
                        return;
                    }
                    jumpToCorrectWordPage()
                    currentPageID.isBackRoot = true
                    currentPageID.currentWordJson = word  //id_word_correct_list_model.get(index)
                }
            }
        }
    }

    //发音控制条
    YRecordAnimationComponet {
        visible: true
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.horizontalCenterOffset: 15
        onRecordStart: {
            isReaded = false
            isFollow = true
            speellStart()
        }
        onRecordStop: {
            isReaded = true
            isFollow = false
            speellStop()
        }
    }

    YLoader {
        id: id_guide_loader
        anchors.fill: parent
        asynchronous: false
        active: isReaded
        sourceComponent:id_follow_guide
    }

    onIsReadedChanged: {
//        if(isReaded && settingManager.followPageCount() < 3){
//            settingManager.setFollowCount(settingManager.followPageCount() + 1)
//            if(isReaded) id_guide_loader.sourceComponent = id_follow_guide
//        }else{
//            id_guide_loader.sourceComponent = null
//        }
        id_guide_loader.sourceComponent = null
    }

    Component {
        id: id_follow_guide
        YFollowGuidePage {
            MouseArea {
                anchors.fill: parent
                onClicked: {
                    id_guide_loader.sourceComponent = null
                }
            }
        }
    }

    property bool isFollow : false
    property var phoneticJsonObj : null
    property var word: {}
    function getPhoneWord(){
        var temp_word = followManager.content

        var queryWordStr = resultManager.queryPureEnglishAndExample(followManager.content)
        console.log("seven:queryWordInfo:11",queryWordStr)
        if(!queryWordStr.length)
            return {
                "phone" : "",
                "ukphone" : "",
                "usphone" : ""
            }
        let dictJsonSimple = JSON.parse(queryWordStr)
        var temp_phoneticJsonObj = {}
        for(var key in dictJsonSimple.pure){
            var t_word = key.substring(0,followManager.content.length)
            if((key.indexOf("\t") !== -1 || key.indexOf("	") !== -1) &&
               t_word.toLowerCase() === followManager.content.toLowerCase() &&
               typeof dictJsonSimple.pure[key].word !== "string"){
                console.log("seven:followResults:onResultChanged::::::4")
                var c_word = dictJsonSimple.pure[key].word
                if(c_word.phone) temp_phoneticJsonObj.phone = c_word.phone
                else temp_phoneticJsonObj.phone = ""
                if(c_word.ukphone) temp_phoneticJsonObj.ukphone = c_word.ukphone
                else temp_phoneticJsonObj.ukphone = ""
                if(c_word.usphone) temp_phoneticJsonObj.usphone = c_word.usphone
                else temp_phoneticJsonObj.usphone = ""
            }
        }
        console.log("seven:followResults:onResultChanged::::333:",temp_phoneticJsonObj.phone,temp_phoneticJsonObj.ukphone,temp_phoneticJsonObj.usphone)
//        console.log("seven:followResults:onResultChanged:333:",resultManager.queryEnPolyPhoneEx(followManager.content))
        return temp_phoneticJsonObj
    }

    function getSendPhones(phoneticSymbols){
        console.log("seven:getSendPhones:1:",phoneticSymbols)
        if(!phoneticSymbols) return ""
        var phones = phoneticSymbols.split("; ")
        var temp_phone = ""
        for(var i = 0 ; i < phones.length ; ++i){
            if(i !== (phones.length - 1))
                temp_phone += (phones[i] + "||")
            else
               temp_phone +=  phones[i]
        }
        console.log("seven:getSendPhones:3:",temp_phone)
        return temp_phone
    }

    function getPhoneTypeSymbol(){
        var temp_type = getPhoneType()
        return settingManager.autoPronounceType ?  temp_type + getSendPhones(phoneticJsonObj.usphone) : temp_type + getSendPhones(phoneticJsonObj.ukphone)
    }

    function speellStart(){
        if(!phoneticJsonObj)
            phoneticJsonObj = getPhoneWord()
        qmlGlobal.stopAllAnimationMusic()
        var senPhone = settingManager.autoPronounceType ? getSendPhones(phoneticJsonObj.usphone) : getSendPhones(phoneticJsonObj.ukphone)
        console.log("seven:followManager.startFollow:", senPhone)
        followManager.startFollow(followManager.content,
//                                  getPhoneTypeSymbol(),
                                  senPhone,
                                  200);
    }

    function speellStop(isJump = true){
        if(isJump)
            jupToFFollowScorePage()
        soundCenter.stop();
        followManager.stopFollow();
        console.log("seven:follow:result:",followManager.result)
    }

    function jupToFFollowScorePage(isAutoClose = true){
        id_pop_layer.showPage("components/YFollowWordScorePage");
        currentPageID.setSpeelResultData(overall,isAutoClose)
    }

    function jumpToCorrectWordPage(data){
        id_pop_layer.showPage("components/YFollowCorrectWordPage")
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
//                    console.log("seven:followResults:onResultChanged:correct:4:",followManager.result)
//                    if(phoneticSymbolJson[0].st.ws.constructor === Array &&
//                       phoneticSymbolJson[0].st.ws.length > 0){
//                        console.log("seven:followResults:onResultChanged:correct:5:",followManager.result)
//                        if(phoneticSymbolJson[0].st.ws[0].w.toLowerCase() === currentWordJson.word.toLowerCase()) {
//                            console.log("seven:followResults:onResultChanged:correct:6:",followManager.result)
//                            isReaded = true
//                        }
//                    }

                }else if(phoneticSymbolJson.words && phoneticSymbolJson.words.length > 0){
                    var wordObj = {}
                    wordObj.richContent = word.richContent
                    word = {}
                    console.log("seven:followResults:onResultChanged:correct:4:")
//                    phoneticSymbolJson.words.forEach(function(wd){
                    isError = false
                    for(var wordIndex = 0; wordIndex < phoneticSymbolJson.words.length; ++wordIndex){
                        var wd = phoneticSymbolJson.words[wordIndex]
                        console.log("seven:followResults:onResultChanged:correct:5:",wd.word)
                        wordObj.word = wd.word
                        if(wd.word.length > followManager.getFullWordLength())
                            wordObj.wordCompleteEx = insertStr(wd.word, wd.word.length / 2, "-\n")
                        else wordObj.wordCompleteEx = wd.word
                        if(wd.word.length > followManager.getWordLength())
                            wordObj.wordEx = insertStr(wd.word, wd.word.length / 2, "-\n")
                        else wordObj.wordEx = wd.word
                        wordObj.pronunciation = wd.pronunciation
                        var temp_phoneme = ""
                        wd.phonemes.forEach(function(phonemeObj){
                            temp_phoneme += phonemeObj.phoneme
                        })
                        wordObj.orgPhoneme = temp_phoneme
                        wordObj.phonemes = "/" + temp_phoneme + "/"
                        if(wordObj.phonemes.length > followManager.getFullWordLength())
                            wordObj.phonemes = insertStr(wordObj.phonemes, wordObj.phonemes.length / 2, "-\n")

                        temp_phoneme = ""
                        var minScor = wd.phonemes[0]
                        for(var i = 1; i < wd.phonemes.length ;++i){
                            if(minScor.pronunciation > wd.phonemes[i].pronunciation) minScor = wd.phonemes[i]
                        }
                        console.log("seven:followResults:onResultChanged:correct:6:",minScor.phoneme)
                        console.log("seven:followResults:onResultChanged:correct:autoType:", settingManager.autoPronounceType)
                        wordObj.lowestpPhone = /*followManager.isUk*/settingManager.autoPronounceType ? (minScor.phoneme + "&type=2") : (minScor.phoneme + "&type=1")
                        wordObj.phone_guide = getPhoneGuide(wordObj.lowestpPhone)
                        if(wordObj.phone_guide.length === 0) {
                            isError = true
                        }
                        console.log("seven:followResults:onResultChanged:correct:7:",wordObj.lowestpPhone,)
                        var index = 0
                        wd.phonemes.forEach(function(phonemeObj){
                            if(phonemeObj.pronunciation === minScor.pronunciation){
                                temp_phoneme += '<font color="%1">%2</font>'.arg("#F04C42").arg(phonemeObj.phoneme)
                            }else{
                                temp_phoneme += phonemeObj.phoneme
                            }
//                            console.log("seven:wordObj.richTextPhonemes:", wd.phonemes.length > followManager.getWordLength(), wd.phonemes.length / 2, index)
                            if(wd.phonemes.length > followManager.getWordLength() && parseInt(wd.phonemes.length / 2) === index)
                                temp_phoneme += "-<br/>"
                            index ++
                        })
                        wordObj.richTextPhonemes = "/" + temp_phoneme + "/"
                        console.log("seven:wordObj.richTextPhonemes:", wordObj.richTextPhonemes)
                        //未读
//                        wordObj.richContent = '<font color="%1">%2</font>'.arg("#FFFFFF").arg(wd.word) + " " + '<font size="30px" color="%1">%2</font>'.arg("#878A99").arg(getPhoneType() + wordObj.phonemes)
                        //已读
                        wordObj.richHighlightedContent = '<font color="%1">%2</font>'.arg("#45C7FF").arg(wd.word) + " " + '<font size="30px" color="%1">%2</font>'.arg("#878A99").arg(getPhoneType() + wordObj.phonemes)
                        var phType = "英"
                        if(settingManager.autoPronounceType) phType = "美"
                        wordObj.richContentPhType = '<font color="%1">%2</font>'.arg("#FFFFFF").arg(wd.word) + " " + '<font size="30px" color="%1">%2</font>'.arg("#878A99").arg(getPhoneType() + wordObj.phonemes)
                        wordObj.richContentPhHighlightedType = '<font color="%1">%2</font>'.arg("#45C7FF").arg(wd.word) + " " + '<font size="30px" color="%1">%2</font>'.arg("#878A99").arg(getPhoneType() + wordObj.phonemes)
//                    })
                    }
                    console.log("seven:followResults:onResultChanged:correct:8:")
                    word = wordObj
                    overall = word.pronunciation
                    currentPageID.setSpeelResultData(overall,true)
//                    if(!isCorrect) {
//                        console.log("seven:followResults:onResultChanged:correct:9:")
//                        isReaded = false
//                        isFollow = true
//                    }
                }
            }
        }
    }

    function insertStr(soure, start, newStr){
       return soure.slice(0, start) + newStr + soure.slice(start);
    }

    function getPhoneGuide(key){
        var guideJson = resultManager.queryPronunciationGuideText(key)
        if(guideJson.length <= 0) return ""
        return JSON.parse(guideJson).text
//         return JSON.parse(resultManager.queryPronunciationGuideText(key)).text
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

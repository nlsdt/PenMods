import QtQuick 2.12
import com.youdao.pen 1.0
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
import BaseQml 1.0
import "../components"
import "../i18n"

YPage {
    id: id_follw_read_page
    anchors.fill: parent

    property var scorePageId: null //打分结果页面
    property var correctPageId: null// 纠音列表



    YPopLayer {
        id: id_ai_pop_layer
        function showPage(qrcqml, properties) {
            show(qrcqml, false, false, properties)
            scorePageId = popItemObject
        }
    }

    YPopLayer {
        id: id_coreect_pop_layer
        function showPage(qrcqml, properties) {
            show(qrcqml, false, false, properties)
            correctPageId = popItemObject
            correctPageId.backButtonClicked.connect(function(){
                correctPageId = null
                isReceive = true
            })
        }
    }
    //打分结果页面
    function jupToFFollowScorePage(){
        id_ai_pop_layer.showPage("follow/YFollowScorePage");
    }

    //纠音列表页面
    function jumpToFollowCorrectWordListPage(){
        id_coreect_pop_layer.showPage("components/YFollowCorrectWordListPage");
    }

    YVerticalTitleBar {
        id: id_title_bar
        onCallBack: {
//            speellStop(false)
//            backButtonClicked()
            back()
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


    property int rightBarWidth: 80

    property int topSpaceHeight: 60

    property int bottomSpaceHeight: 80

    property bool isFollow: false

    function recordFollowLog(){
        console.log("seven:followManager:info:",followManager.content,followManager.isUk,followManager.ukPhonetic,followManager.usPhonetic)
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
                    jupToFFollowScorePage()
                    showScorePage(false)
                }
            }

            Rectangle {
                width: 70
                height: 70
                color: "transparent"
                visible: sentence_words.count
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
                        isReceive = false
                        jumpToFollowCorrectWordListPage()
                        correctPageId.setCorrectWordlistData(sentence_words)
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
        Flickable {
            id: id_follow_sentence_flickable
            anchors.fill: parent
            contentHeight: id_sentence_colum.height
            Column{
                id: id_sentence_colum
                anchors.left: parent.left
                anchors.right: parent.right
                //上边距
                Rectangle {
                    width: parent.width
                    height: topSpaceHeight
                    color: "transparent"
                }

                Rectangle {
                    width: parent.width
                    height: {
//                        if(isReaded) return id_sentence_text.contentHeight + 16 + id_my_audio_button.height
                        return id_sentence_text.contentHeight + 45
                    }
                    color: "transparent"
                    Rectangle {
                        id: id_sentence_sound_bg
                        anchors.left: parent.left
                        anchors.top: parent.top
                        anchors.topMargin: 8
                        width: 32
                        height: 32
                        color: "#46ABFD"
                        radius: 12

                        YFollowAudioButton {
                            id: id_audio_pron
                            textFontFamily: fontManager.fontFamilyEnUs
                            textFormat: YText.PlainText
                            leftMargin: -3
                            width: 24
                            height: 24
                            anchors.verticalCenter: parent.verticalCenter
                            radius: 12
                            anchors.fill: parent
                            color: "transparent"
                            enabled: !isFollow
                            text: ""
                            visible: true
                            onValidClicked: {
                                playJap()
                            }
                            function playJap(){
                                console.log("seven:playJap:1:")
                                followManager.content = resultManager.currentQuery
                                playWord(followManager.content, "en")
                            }
                        }
                    }
                    Text {
                        id: id_sentence_text
                        anchors.left: id_sentence_sound_bg.right
                        anchors.top: parent.top
                        anchors.right: parent.right
                        anchors.bottom: parent.bottom
                        anchors.leftMargin: 10
                        wrapMode: Text.WordWrap
                        textFormat: Text.RichText
                        font.family: "Nunito Sans"
                        font.bold :true
                        font.pixelSize: 30
                        color: "#FFFFFF"
                        text: {
                            return readWordProgress
                        }
                    }

                    YMyFollowAudioButton{
                        id: id_my_audio_button
                        anchors.left: id_sentence_text.left
                        anchors.top: id_sentence_text.bottom
                        anchors.topMargin: -35
                        visible: isReaded
                        myFollownabled: !isFollow
                    }
                }

                //下边距
                Rectangle {
                    width: parent.width
                    height: bottomSpaceHeight
                    color: "transparent"
                }
            }
        }

        //发音控制条
        YRecordAnimationComponet {
            anchors.bottom: parent.bottom
            anchors.horizontalCenter: parent.horizontalCenter

            onRecordStart: {
                speellStart()
                placedTop()
            }

            onRecordStop: {
                speellStop()
                placedBottom()
            }
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
        if(isReaded && settingManager.followPageCount() < 3){
            settingManager.setFollowCount(settingManager.followPageCount() + 1)
            if(isReaded) id_guide_loader.sourceComponent = id_follow_guide
        }else{
            id_guide_loader.sourceComponent = null
        }
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

    function placedTop(){
        id_follow_sentence_flickable.contentY = 0
    }

    function placedBottom(){
        id_follow_sentence_flickable.contentY = id_follow_sentence_flickable.contentHeight - YBaseEnum.Screen.Height
    }

    property var wordStatusList : {
        //var wordslist = followManager.content.split(/([\ |\~|\`|\!|\@|\#|\$|\%|\^|\&|\*|\(|\)|\-|\_|\+|\=|\||\\|\[|\]|\{|\}|\;|\:|\"|\'|\,|\<|\.|\>|\/|\?|\s+])/g)
        var wordslist = followManager.content.split(/([\ |\~|\`|\!|\@|\#|\$|\%|\^|\&|\*|\(|\)|\-|\_|\+|\=|\||\\|\[|\]|\{|\}|\;|\:|\"||\,|\<|\.|\>|\/|\?|\s+])/g)
        var tempList = []
        for(var i = 0; i < wordslist.length; ++i){
            console.log("seven:word_value:",wordslist[i])
            tempList.push({
                              "word" : wordslist[i],
                              "readed" : 0, // 0 未读  1 已读
                              "seg_id" : 0,
                              "score" : 0
                          })
        }
        return tempList

    }

    property bool isReaded: false
    property int fluency : 0
    property int integrity : 0
    property int overall : 0
    property int pronunciation : 0
    property var words: []
//    property var sentence_words: []
    property int seg_rang: 0 ////断句标志
    property bool isReceive: true
    property string readWordProgress: {
        return getSpeellContent(followManager.content)
    }

    ListModel {
        id: sentence_words
    }

    function resetSpeellData(){
        seg_rang  = 0
        for(var i = 0; i < wordStatusList.length; ++i){
            wordStatusList[i].readed = 0
        }
    }

    function speellStart(){
//        console.log("seven:start:follow:content:", followManager.content, resultManager.currentQuery)
        followManager.content = resultManager.currentQuery;
        recordFollowLog()
        readWordProgress = getSpeellContent(followManager.content)
        resetSpeellData()
        isReaded = false
        isFollow = true
        qmlGlobal.stopAllAnimationMusic()
        console.log("seven:startFollow:",followManager.content)
        followManager.startFollow(followManager.content,
                                  /*followManager.isUk ? followManager.ukPhonetic : followManager.usPhonetic*/"", 200);
    }

    function speellStop(isJump = true){
        if(isJump)
            jupToFFollowScorePage()
        soundCenter.stop();
        followManager.stopFollow();
        isReaded = true
        isFollow = false
        console.log("seven:follow:result:",followManager.result)
    }

    function getSpeellContent(res){
        return ('<span style="font-family: %1;">%2</span>').arg(fontManager.fontFamilyEnUk).arg(res)
    }

    function showScorePage(isAutoClose){
        scorePageId.setSpeelResultData(fluency, integrity, overall, pronunciation, isAutoClose)
    }


    function getSendPhones(phoneticSymbols){
        var phones = phoneticSymbols.split("; ")
        var temp_phone = ""
        for(var i = 0 ; i < phones.length ; ++i){
            if(i !== (phones.length - 1))
                temp_phone += (phones[i] + "||")
            else
               temp_phone +=  phones[i]
        }
        return temp_phone
    }


    function getscoreResults(){
        resetSpeellData()
        var res = ""
        words.forEach(function(wordObj){

            for(var i = 0 ; i < wordStatusList.length; ++i){
                var t_wordObj = wordStatusList[i]
                if(t_wordObj.readed === 0 &&
                   t_wordObj.word.toLowerCase() === wordObj.word.toLowerCase()){
                    wordStatusList[i].readed = 1
                    wordStatusList[i].score = wordObj.pronunciation
                    break
                }
            }


        })

        for(var i = 0 ; i < wordStatusList.length; ++i){
//            var t_wordObj = wordStatusList[i]
            var colorString = "#FFFFFF"
            var temp_score = wordStatusList[i].score
            if(temp_score < 60)
                colorString = "#F04C42"
            else if(temp_score >= 60 && temp_score < 80)
                colorString = "#E9900C"
            else
                colorString = "#FFFFFF"
            var temp_sapce = " "
            if(i === (wordStatusList.length - 1))
                temp_sapce = ""
            res += (('<font color="%1">%2</font>'.arg(colorString)).arg(wordStatusList[i].word) + temp_sapce)
        }

        if (res.length === 0) {
            res = followManager.content;
        }
        console.log("seven:getscoreResults:0:",res)
        return getSpeellContent(res)
    }

    function getLowerScoreWord(wordList){
        var temp_wordList = wordList
        temp_wordList.sort(function(a, b){
            return a.pronunciation - b.pronunciation
        })
//        var isCompleted = 0
        for(var i = 0; i < temp_wordList.length ; ++i){
            var temp_wordObj = temp_wordList[i]
            if(parseInt(temp_wordObj.pronunciation) < 80){
                console.log("seven:pronunciation:0:",temp_wordObj.word, parseInt(temp_wordObj.pronunciation), temp_wordObj.pronunciation)
                let dictJsonSimple = JSON.parse(resultManager.queryPureEnglishAndExample(temp_wordObj.word))
                var phoneticJsonObj = {
                    "phone" : "",
                    "ukphone" : "",
                    "usphone" : ""
                }
                for(var key in dictJsonSimple.pure){
                    var t_word = key.substring(0,temp_wordObj.word.length)
                    if(key.indexOf("\t") !== -1 &&
                       t_word.toLowerCase() === temp_wordObj.word.toLowerCase() &&
                       typeof dictJsonSimple.pure[key].word !== "string"){
                        console.log("seven:followResults:onResultChanged::::::4")
                        var c_word = dictJsonSimple.pure[key].word
                        if(c_word.phone) phoneticJsonObj.phone = c_word.phone
                        if(c_word.ukphone) phoneticJsonObj.ukphone = c_word.ukphone
                        if(c_word.usphone) phoneticJsonObj.usphone = c_word.usphone
                    }
                }
                console.log("seven:followResults:onResultChanged::::333:",phoneticJsonObj.phone,phoneticJsonObj.ukphone,phoneticJsonObj.usphone)
//                console.log("seven:followResults:onResultChanged:333:",resultManager.queryEnPolyPhoneEx(temp_wordObj.word))
                console.log("seven:followResults:onResultChanged:autoPronounceType:",settingManager.autoPronounceType)
                if(settingManager.autoPronounceType === 0){
                    followManager.getWordScore(temp_wordObj.word, phoneticJsonObj.ukphone ? getSendPhones(phoneticJsonObj.ukphone) : "")
                }else{
                    followManager.getWordScore(temp_wordObj.word, phoneticJsonObj.usphone ? getSendPhones(phoneticJsonObj.usphone) : "")
                }

            }

        }
    }

    function insertStr(soure, start, newStr){
       return soure.slice(0, start) + newStr + soure.slice(start);
    }

    function addToWords(word){
        var wordObj = {}
        wordObj.word = word.word
        if(word.word.length > followManager.getFullWordLength())
            wordObj.wordCompleteEx = insertStr(word.word, word.word.length / 2, "-\n")
        else wordObj.wordCompleteEx = word.word
        if(word.word.length > followManager.getWordLength())
            wordObj.wordEx = insertStr(word.word, word.word.length / 2, "-\n")
        else wordObj.wordEx = word.word
        wordObj.pronunciation = word.pronunciation
        var temp_phoneme = ""
        word.phonemes.forEach(function(phonemeObj){
            temp_phoneme += phonemeObj.phoneme
        })
        wordObj.orgPhoneme = temp_phoneme
        wordObj.phonemes = "/" + temp_phoneme + "/"

        temp_phoneme = ""
        var temp_phonemes = word.phonemes
        var minScor = word.phonemes[0]
        for(var i = 1; i < word.phonemes.length ;++i){
            if(minScor.pronunciation > word.phonemes[i].pronunciation) minScor = word.phonemes[i]
        }
        wordObj.lowestpPhone = settingManager.autoPronounceType ? (minScor.phoneme + "&type=2") : (minScor.phoneme + "&type=1")
        wordObj.phone_guide = getPhoneGuide(wordObj.lowestpPhone)
        var index = 0
        word.phonemes.forEach(function(phonemeObj){
            if(phonemeObj.pronunciation === minScor.pronunciation){
                temp_phoneme += '<font color="%1">%2</font>'.arg("#F04C42").arg(phonemeObj.phoneme)
            }else{
                temp_phoneme += phonemeObj.phoneme
            }
            if(word.phonemes.length > followManager.getWordLength() && parseInt(word.phonemes.length / 2) === index)
                temp_phoneme += "-<br/>"
            index ++
        })
        wordObj.richTextPhonemes = "/" + temp_phoneme + "/"
        console.log("seven:wordObj.richTextPhonemes:", wordObj.richTextPhonemes)
        //未读
        wordObj.richContent = '<font color="%1">%2</font>'.arg("#FFFFFF").arg(word.word) + " " + '<font size="30px" color="%1">%2</font>'.arg("#878A99").arg(wordObj.phonemes)
        //已读
        wordObj.richHighlightedContent = '<font color="%1">%2</font>'.arg("#45C7FF").arg(word.word) + " " + '<font size="30px" color="%1">%2</font>'.arg("#878A99").arg(wordObj.phonemes)
        //带英美音标志
        var phType = "英"
        if(settingManager.autoPronounceType) phType = "美"
        wordObj.richContentPhType = '<font color="%1">%2</font>'.arg("#FFFFFF").arg(word.word) + " " + '<font size="30px" color="%1">%2</font>'.arg("#878A99").arg(phType + wordObj.phonemes)
        wordObj.richContentPhHighlightedType = '<font color="%1">%2</font>'.arg("#45C7FF").arg(word.word) + " " + '<font size="30px" color="%1">%2</font>'.arg("#878A99").arg(phType + wordObj.phonemes)
        console.log("seven:addToWords:3")
//        sentence_words.push(wordObj)
        console.log("seven:pronunciation:1:",wordObj.word, parseInt(wordObj.pronunciation), wordObj.pronunciation)
        if(wordObj.pronunciation < 80)
            sentence_words.append(wordObj)
    }

    function getPhoneGuide(key){
         return JSON.parse(resultManager.queryPronunciationGuideText(key)).text
    }

    Connections {
        target: followManager
        ignoreUnknownSignals: true
        function onVadStop(taskId) {
            console.log("seven:followResults:onVadStop:",followManager.result)
        }

        onResultChanged:{
            console.log("seven:followResults:onResultChanged:-1:",followManager.result)
            if(!isReceive) return
            try{
                var phoneticSymbolJson = JSON.parse(followManager.result);
            } catch(e){}
            console.log("seven:followResults:onResultChanged:0:",followManager.result)

            var res = "";
            var isException = true
            console.log("seven:getscoreResults:-1:",followManager.result)
            if (typeof phoneticSymbolJson != "undefined"
                /*&& followManager.ukPhonetic.length === 0
                &&followManager.usPhonetic.length === 0*/ ){

                //跟读结果
                if (typeof phoneticSymbolJson.words != "undefined"
                    && !followManager.isRecording){
                    isException = false
                    words = []
//                    sentence_words = []
                    sentence_words.clear()
                    fluency = parseInt(phoneticSymbolJson.fluency)
                    integrity = parseInt(phoneticSymbolJson.integrity)
                    overall = parseInt(phoneticSymbolJson.overall)
                    pronunciation = parseInt(phoneticSymbolJson.pronunciation)
                    showScorePage(true)
                    words = phoneticSymbolJson.words
                    getLowerScoreWord(phoneticSymbolJson.words)
                    res = getscoreResults()
                }
                //跟读中
                if (typeof phoneticSymbolJson[0] != "undefined")
                {
                    isException = false
                    var i
                    var seg_id = phoneticSymbolJson[0].seg_id
                    var segArray = phoneticSymbolJson[0].st.ws
                    console.log("seven:followResults:onResultChanged:1---------------",seg_id)
                    var tesetStr = ""
                    var firstStatus = wordStatusList[0]
                    if(seg_id === firstStatus.seg_id){
                        for(i = seg_rang; i < segArray.length; ++i){
                            var wsObj = segArray[i]
                            tesetStr += (wsObj.w + " ")
                            for(var j = 0; j < wordStatusList.length; ++j){
                                var wordObj = wordStatusList[j]
                                if(wordObj.readed === 0 &&
                                   wordObj.word.toLowerCase() === wsObj.w.toLowerCase()){
                                    wordStatusList[j].readed = 1
                                    break
                                }
                            }
                        }
                        seg_rang = segArray.length
                    }else{
                        seg_rang = 0
                        phoneticSymbolJson[0].st.ws.forEach(function(wsObj){
                            tesetStr += (wsObj.w + " ")
                            for(i = 0; i < wordStatusList.length; ++i){
                                var wordObj = wordStatusList[i]
                                if(wordObj.readed === 0 &&
                                   wordObj.word.toLowerCase() === wsObj.w.toLowerCase()){
                                    wordStatusList[i].readed = 1
                                    break
                                }
                            }
                        })
                    }


                    console.log("seven:followResults:onResultChanged:2",tesetStr)
                    for(i = 0; i < wordStatusList.length; ++i){
                        wordStatusList[i].seg_id = seg_id
                        if(wordStatusList[i].readed === 1){
                            res += ('<font color="%1">%2</font>'.arg(YColors.blueText)).arg(wordStatusList[i].word);
                        }else {
                            res += wordStatusList[i].word
                        }
                    }
                }

                //单词结果打分
                if(phoneticSymbolJson.phonemes && phoneticSymbolJson.word){
                    console.log("seven:followResults:onResultChanged::::3333333333333:",phoneticSymbolJson.phonemes,phoneticSymbolJson.word)
                    addToWords(phoneticSymbolJson)
                    return
                }
                if(isException){
                    return
                }

                console.log("seven:getscoreResults:1:",res)
                if (res.length === 0) {
                    res = followManager.content;
                }
                readWordProgress = getSpeellContent(res)
            }

        }
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

import QtQuick 2.12
//import QtQuick.XmlListModel 2.14
import com.youdao.pen 1.0
import BaseQml 1.0
import "../i18n"
import "../../qml/timers"
import "../components"
import "../commons"

YDictTypeBase {
    id: id_dict_type_japTOch
    title: YTranslateText.dtYoudaoJapToCh
    property var wordHeads: []  //分类标签
    property var pronunciationJsons: [] //发音信息
    property var ch_words: []           //释义单词
    property var data_array : []        //双语例句
    property int currentSelectedIndex: 0
    property string currentWord: ""

    property string associat: "" //关联词
    property var homonyms :  [] //同音词

    property var pronunciationBotton: null
    onDictJsonChanged: {
        console.log("seven:japToCh:",JSON.stringify(dictJson))
        if(dictJson.associat){
            associat = dictJson.associat
        }else{
            associat + ""
        }
        dictJson.wordList.forEach(function(wordObj){
            wordHeads.push(wordObj.head.pjm)
        })
        if(dictJson.wordList.length > 0){
            var selectLable = dictJson.wordList[0].head.pjm
            console.log("seven:selectLable:",selectLable)
            getCurrentSelectByLable(selectLable)
        }

    }

    function createContentHighlightKey(key,color){
        var tmp_key = key//.replace(/'/g,"")
        var temp_content = ""
        temp_content += "<a>"
        temp_content += ("<font color=" + color + ">")//"<font color=\"#509DEB\">"
        temp_content += tmp_key
        temp_content += "</font>"
        temp_content += "</a>"

        return " "+temp_content
    }

    property var temp_pronunciationJsons: []
    property var temp_ch_words: []
    property var temp_data_array: []
    property var temp_homonyms :  []

    function resetData(){
        pronunciationJsons = []
        ch_words = []
        data_array = []
    }

    function getCurrentSelectByLable(selectLable, cIndex = 0){
        temp_homonyms = []
        if(dictJson.homonym){
            dictJson.homonym.forEach(function(homonymObj){
                var contenJson = {}
                contenJson.pjm = homonymObj.head.pjm
                contenJson.hw = homonymObj.head.hw
                if(homonymObj.head.tone) contenJson.tone = homonymObj.head.tone
                else contenJson.tone = ""
                if(homonymObj.sense && homonymObj.sense.length > 0){
                    var sensObj = homonymObj.sense[0]
                    var tmp_content = ""
                    if(sensObj.pos) tmp_content += ("[" + sensObj.pos + "]")
                    if(sensObj.phrList && sensObj.phrList.length > 0){
                        tmp_content += sensObj.phrList[0].text
                    }
                    contenJson.content = tmp_content
                }
                console.log("seven:temp_homonyms:")
                temp_homonyms.push(contenJson)
            })
        }
        console.log("seven:temp_homonyms:",JSON.stringify(temp_homonyms))
        homonyms = temp_homonyms

        //映射词(解析变更)
        associat = ""
        var t_index = 0
        dictJson.wordList.forEach(function(wordObj){
            if(/*wordObj.head.pjm === selectLable*/t_index === cIndex && wordObj.head.hw !== resultManager.currentQuery){
                associat = wordObj.head.hw
            }
            t_index++
        })

        if(associat.length === 0){
            if(!homonyms.length){
                parsDictConten(selectLable, cIndex)
            }else{
                resetData()
            }
        }else{
            parsDictConten(selectLable, cIndex)
        }

    }


    function parsDictConten(selectLable, cIndex = 0){
        temp_pronunciationJsons = []
        temp_ch_words = []
        temp_data_array = []
        data_array = []
        console.log("seven:getCurrentSelectByLable:",selectLable)
        var t_index = 0
        dictJson.wordList.forEach(function(wordObj){
            if(/*wordObj.head.pjm === selectLable*/t_index === cIndex){
                currentWord = wordObj.head.hw
                //标签
                var isNumber = 0
                if(wordObj.head.tone) isNumber = 1
                var pjm = wordObj.head.pjm
                if(!pjm)
                    pjm = wordObj.head.hw
                temp_pronunciationJsons.push({
                                                 "content" : pjm,
                                                 "isNumber" : isNumber,
                                                 "tone" : wordObj.head.tone
                                             })
                temp_pronunciationJsons.push({
                                                 "content" : "|",
                                                 "isNumber" : 0
                                             })
                if(wordObj.head.rs)
                    temp_pronunciationJsons.push({
                                                     "content" : wordObj.head.rs,
                                                     "isNumber" : 0
                                                 })

                //释义词组
                if(wordObj.sense){
                wordObj.sense.forEach(function(contetnObj){
                    var pos = ""
                    if(contetnObj.pos !== undefined) pos = ("[" + contetnObj.pos + "]")
                    if(contetnObj.phrList){
                        var phrCount = 0
                        var temp_content = ""
                        temp_content += (pos + " ")
                        contetnObj.phrList.forEach(function(phrListObj){
                            //释意
                            if(contetnObj.phrList.length > 1){
                                phrCount ++
                                temp_content  += (phrCount + "." + phrListObj.text + " ")
                            }else
                                temp_content  += phrListObj.text
                            //例句
                            if(phrListObj.sentences){
    //                            isEgSentence = true
                                var sentence = ""
                                var sentence_org = ""
                                var sentence_trans = ""
                                var sentence_pjm = []
                                phrListObj.sentences.forEach(function(sentencesObj){
                                    if(sentencesObj.sentence) sentence = sentencesObj.sentence
                                    if(sentencesObj["sentence-org"])  sentence_org = sentencesObj["sentence-org"]
                                    if(sentencesObj["sentence-trans"]) sentence_trans = sentencesObj["sentence-trans"]
                                    if(sentencesObj["sentence-pjm"]) sentence_pjm = sentencesObj["sentence-pjm"]
                                })
                                var conetentElement = {"text":phrListObj.text,
                                                       "sentence":sentence,
                                                       "sentence_org" : sentence_org,
                                                       "sentence_trans": sentence_trans,
                                                       "sentence_pjm":sentence_pjm}
                                temp_data_array.push(conetentElement)
                            }
                        })
                        temp_ch_words.push(temp_content)
                    }
                })
                }
            }
            t_index++
        })
        if(dictJson.exam_type){
            dictJson.exam_type.forEach(function(leveObj){
                temp_pronunciationJsons.push({"content" : leveObj,"isNumber" : 0})
            })
        }
        pronunciationJsons = temp_pronunciationJsons
        ch_words = temp_ch_words
        data_array = temp_data_array

        if(/*firstDictType === YEnum.DtJapToCh &&*/ pronunciationBotton){
            pronunciationBotton.playJap()
        }

    }

    Component.onCompleted: {
        console.log("seven:playJap:1:")
    }

    Item {
        width: parent.width
        height: id_jap_content_colum.height
        Column {
            id: id_jap_content_colum
            width: parent.width

            //同音字
            YText {
                id: id_homonym_ytext
                anchors.left: parent.left
                anchors.right: parent.right
                font.pixelSize: 28
                wrapMode: YText.WordWrap
                textFormat: Text.RichText
                color: "#FFFFFF"
                text: "相同的读音的词有："
                visible: id_homonym_repeater.model.length
                onLinkActivated: {
                    console.log("seven:clickText:",link)
                    id_dict_page.clickSearchWord(link)
                }
            }

            YSpacingForColumn{
                height: 18
                visible: id_homonym_ytext.visible
            }

            Repeater {
                id: id_homonym_repeater
                width: parent.width
                model: homonyms
                Column {
                    width: parent.width - 10
                    Row {
                        width: parent.width
                        height: 50
                        spacing: 10
                        clip: true
                        Rectangle {
                            width: id_hw_word_ytext.contentWidth + 8
                            height: parent.height
                            color: "transparent"
                            YText {
                                id: id_hw_word_ytext
                                anchors.left: parent.left
                                anchors.right: parent.right
                                font.pixelSize: 28
//                                wrapMode: YText.WordWrap
//                                textFormat: Text.RichText
                                color: "#509DEB"
                                verticalAlignment: Text.AlignVCenter
                                text: {
                                    console.log("seven:id_homonym_repeater",id_homonym_repeater.model[index].pjm)
                                    return id_homonym_repeater.model[index].pjm
                                }
                                onLinkActivated: {
                                    console.log("seven:clickText:",link)
                                    id_dict_page.clickSearchWord(link)
                                }
                            }
                            Rectangle {
                                width: parent.width
                                height: 1
                                anchors.left: parent.left
                                anchors.right: parent.right
                                anchors.bottom: parent.bottom
                                anchors.rightMargin: 16
                                color: "#509DEB"

                            }

                            Rectangle {
                                width: 16
                                height: 16
                                color: "#2D2E33"
                                anchors.top: parent.top
                                anchors.right: parent.right
                                anchors.rightMargin: -height / 2
                                radius: width / 2
                                visible: id_homonym_repeater.model[index].tone.length !== 0
                                YText {
                                    font.family: fontManager.fontFamilyXinHuaXiHei
                                    anchors.centerIn: parent
                                    font.pixelSize: 16
                                    color: "#FFFFFF"
                                    text:id_homonym_repeater.model[index].tone
                                }
                            }
                            MouseArea{
                                anchors.fill: parent
                                onClicked: {
                                    id_dict_page.clickSearchWord(id_homonym_repeater.model[index].hw)
                                }
                            }
                        }
                        Rectangle {
                            height: parent.height
                            width: id_hw_map_ytext.contentWidth
                            color: "transparent"
                            YText {
                                id: id_hw_map_ytext
                                height: parent.height
                                font.pixelSize: 28
    //                            wrapMode: YText.WordWrap
    //                            textFormat: Text.RichText
                                elide: Text.ElideRight
                                color: "#509DEB"
                                verticalAlignment: Text.AlignVCenter
                                text: "【" + id_homonym_repeater.model[index].hw + " 】"
                                onLinkActivated: {
                                    console.log("seven:clickText:",link)
                                    id_dict_page.clickSearchWord(link)
                                }
                            }

                            MouseArea {
                                anchors.fill:parent
                                onClicked: {
                                    id_dict_page.clickSearchWord(id_homonym_repeater.model[index].hw)
                                }
                            }

                        }


                        YText {
                            id: id_hw_detail_ytext
                            height: parent.height
                            font.pixelSize: 28
//                            wrapMode: YText.WordWrap
//                            textFormat: Text.RichText
                            elide: Text.ElideRight
                            color: "#A8AAB2"
                            verticalAlignment: Text.AlignVCenter
                            text: id_homonym_repeater.model[index].content
                            onLinkActivated: {
                                console.log("seven:clickText:",link)
                                id_dict_page.clickSearchWord(link)
                            }
                        }
                    }

                }

            }

            YSpacingForColumn{
                height: 18
                visible: id_homonym_ytext.visible
            }

            //映射词条
            YText {
                id: id_jap_map_ytext
                anchors.left: parent.left
                anchors.right: parent.right
                font.pixelSize: 28
                wrapMode: YText.WordWrap
                textFormat: Text.RichText
                color: "#FFFFFF"
                text: {
                    var linkstring = '<a href=%1>%2</a>'.arg(associat).arg('<font color=#509DEB>%1</font>'.arg(associat))
                    return "以下为" + linkstring + "的结果"
                }
                visible: associat.length
                onLinkActivated: {
                    console.log("seven:clickText:",link)
                    if(resultManager.currentQuery === link) return
                    id_dict_page.clickSearchWord(link)
                }
            }

            YSpacingForColumn{
                height: 18
                visible: id_jap_map_ytext.visible
            }

            Flickable {
                width: parent.width
                height: 52
                contentWidth: id_jap_pronunciation_list.width
                flickableDirection: Flickable.HorizontalFlick
                visible: {
                    if(id_homonym_ytext.visible) return false
                    return wordHeads.length > 1
                }
                clip: true
                Row{
                    id: id_jap_pronunciation_list
                    height: parent.height
                    spacing: 10
                    anchors.bottom: parent.bottom
                    Repeater {
                        id: id_dict_ch_pinyin_list_repeater
                        model: wordHeads
                        Rectangle{
                            height: id_jap_pronunciation_list.height
                            width: id_wordHeadLable_text.contentWidth + 20
                            radius: 16
                            color: {
                                currentSelectedIndex === index ? "#F03043" : "#1A1B1F"
                            }
                            YText {
                                id: id_wordHeadLable_text
                                font.family: fontManager.fontFamilyXinHuaXiHei
                                anchors.verticalCenter: parent.verticalCenter
                                height: 26
                                anchors.left: parent.left
                                anchors.right: parent.right
                                anchors.leftMargin: 10
                                anchors.rightMargin: 10
                                font.pixelSize: 26
                                color: "white"
                                text: wordHeads[index]
                            }
                            MouseArea{
                                anchors.fill: parent
                                onClicked: {
                                    currentSelectedIndex = index
                                    getCurrentSelectByLable(wordHeads[currentSelectedIndex], currentSelectedIndex)
                                }
                            }
                        }
                    }
                }
            }

            YSpacingForColumn{
                height: 18
                visible: true
            }

            Row {
                width: parent.width
                height: 34
                Rectangle {
                    id: id_audio_button_rectangle
                    width: 40
                    height: 34//parent.height
                    color: "transparent"
                    visible: pronunciationJsons.length
                    YPronunciationAudioButton {
                        id: id_audio_pron
                        textFontFamily: fontManager.fontFamilyEnUs
                        textFormat: YText.PlainText
                        leftMargin: 0
                        anchors.verticalCenter: parent.verticalCenter
                        radius: 12
                        anchors.fill: parent
                        color: "#1A1B1F"
                        enabled: true
                        text: ""
                        visible: true
                        onValidClicked: {
                            playJap()
                        }
                        function playJap(){
                            console.log("seven:playJap:1:")
                            if(pronunciationJsons.length){
                                var proJosn =  pronunciationJsons[0]
                                console.log("seven:playJap:2",proJosn.content)
                                playWord(proJosn.content, "ja")
                            }
                        }
                        Component.onCompleted: {
                            if(firstDictType === YEnum.DtJapToCh && settingManager.isAutoPronounce)
                                playJap()
                            pronunciationBotton = this
                        }
                    }
                }

                Flickable {
                    anchors.left: id_audio_button_rectangle.right
                    anchors.right: parent.right
                    height: parent.height
                    contentWidth: id_pjm_rs_level_row.width
                    flickableDirection: Flickable.HorizontalFlick
                    visible: true
                    clip: true
                    Row{
                        id: id_pjm_rs_level_row
                        height: parent.height
                        spacing: 10
                        anchors.bottom: parent.bottom
                        Repeater {
                            id: id_pjm_rs_level_repeater
                            model: pronunciationJsons
                            Rectangle{
                                height: id_pjm_rs_level_row.height
                                width: id_pjm_rs_level_cell_text.contentWidth + 20
                                color: {
                                    if(index >= 3) return "#3E8BFF"
                                    return "transparent"
                                }
                                radius: 11
                                visible: {
                                    if(id_pjm_rs_level_repeater.model.length < 3 && index === 1) return false
                                    return true
                                }
                                opacity: {
                                    if(index >= 3) return 0.3
                                    return 1
                                }
                                Rectangle {
                                    width: 16
                                    height: 16
                                    color: "#2D2E33"
                                    anchors.top: parent.top
                                    anchors.right: parent.right
                                    anchors.rightMargin: -height / 2
                                    radius: width / 2
                                    visible: {
                                        var tmp_value = id_pjm_rs_level_repeater.model[index]
                                        if(tmp_value.isNumber === 1){
                                            return true
                                        }
                                        return false
                                    }
                                    YText {
                                        font.family: fontManager.fontFamilyXinHuaXiHei
                                        anchors.centerIn: parent
                                        font.pixelSize: 16
                                        color: "#FFFFFF"
                                        text: {
                                            var tmp_value = id_pjm_rs_level_repeater.model[index]
                                            if(tmp_value.isNumber === 1)
                                                return tmp_value.tone
                                        }
                                    }
                                }

                                YText {
                                    id: id_pjm_rs_level_cell_text
                                    font.family: fontManager.fontFamilyXinHuaXiHei
//                                    anchors.verticalCenter: parent.verticalCenter
                                    height: 26
                                    anchors.top: parent.top
                                    anchors.bottom: parent.bottom
                                    anchors.left: parent.left
                                    anchors.right: parent.right
                                    verticalAlignment: Text.AlignVCenter
                                    horizontalAlignment  : Text.AlignHCenter
                                    anchors.leftMargin: 5
                                    anchors.rightMargin: 5
                                    font.pixelSize: 26
                                    color: "white"
                                    text: id_pjm_rs_level_repeater.model[index].content
                                }

                            }
                        }
                    }
                }
            }

            YSpacingForColumn{
                height: 18
                visible: true
            }
            ////释义词
            Repeater {
                id: id_data_array_repeater
                width: parent.width
                model: ch_words
                Column {
                    width: parent.width
                    YText {
                        id: id_paraphrase_ytext
                        anchors.left: parent.left
                        anchors.right: parent.right
                        font.pixelSize: 28
                        wrapMode: YText.WordWrap
                        textFormat: Text.RichText
                        elide: Text.ElideRight
                        visible: text.length
                        color: YColors.white
                        text: id_data_array_repeater.model[index]
                        onLinkActivated: {
                            console.log("seven:clickText:",link)
                            id_dict_page.clickSearchWord(link)
                        }
                    }
                }

            }

            YSpacingForColumn{
                height: 18
                visible: true//id_data_array.length
            }

            Rectangle {
                width: parent.width
                height: 26
                color: "transparent"
                visible: data_array.length
                Rectangle {
                    id: id_indicator_rectangle
                    anchors.verticalCenter: parent.verticalCenter
                    width: 4
                    height: 20
                    radius: 2
                    color: "#F03043"
                }

                YText {
                    anchors.left: id_indicator_rectangle.right
                    anchors.leftMargin: 10
                    height: parent.height
                    font.pixelSize: 26
                    color: "#A8AAB2"
                    verticalAlignment: Text.AlignVCenter
                    text: YTranslateText.bilingualSentences
                    Component.onCompleted: {
                        dictNodeCompleted(text, dictType, 1, this);
                    }
                }
            }

            YSpacingForColumn{
                height: 18
                visible: data_array.length
            }
            Repeater {
                id: id_data_repeater
                width: parent.width
                model: {
                    console.log("seven:data_array:change:")
                    return data_array;
                }
                Rectangle {
                    width: parent.width
                    height: {
                        console.log("seven:data_array:",data_array.length,id_wors_text.contentHeight + id_v_space_rectangle.height + id_sentence_text.contentHeight  + id_trans_text.contentHeight + 14)
                        if(data_array.length){
                            id_wors_text.contentHeight + id_v_space_rectangle.height + id_sentence_text.contentHeight  + id_trans_text.contentHeight + 14
                        }else
                            return 0
                    }
    //                visible: data_array.length
                    color: "transparent"
                    //序列号
                    YText {
                        id: id_num_text
                        width:44
                        font.pixelSize: 28
                        color: "#A8AAB2"
                        text: (index + 1) + "."
                    }
                    //单词
                    YText {
                        id: id_wors_text
                        anchors.top: parent.top
                        anchors.left: id_num_text.right
                        anchors.right: parent.right
                        font.pixelSize: 28
                        wrapMode: YText.WordWrap
                        color: "white"
                        text: id_data_repeater.model[index].text
                    }

                    Rectangle {
                        id: id_v_space_rectangle
                        anchors.top: id_wors_text.bottom
                        height: 14

                    }

    //                //发音按钮
                    Rectangle {
                        width: 40
                        height: 34
                        anchors.top: id_v_space_rectangle.bottom
                        anchors.topMargin: 8
                        color: "transparent"
                        YPronunciationAudioButton {
                            id: id_audio_pron1
                            textFontFamily: fontManager.fontFamilyEnUs
                            textFormat: YText.PlainText
                            leftMargin: 0
                            anchors.verticalCenter: parent.verticalCenter
                            radius: 12
                            anchors.fill: parent
                            color: "#1A1B1F"//YColors.black
                            enabled: true//!id_sound_play.playing
                            text: ""
                            visible: true//!(followManager.ukPhonetic.length > 0 || followManager.usPhonetic.length > 0)
                            onValidClicked: {
                                if (playing) {
                                    var wordModel = id_data_repeater.model[index]
                                    console.log("seven:jap_to_ch:",wordModel.sentence_org)
                                    playWord(wordModel.sentence_org, "ja")
                                }
                            }
                        }
                    }

                    //翻译
                    YText {
                        id: id_trans_text
                        anchors.top: id_v_space_rectangle.bottom
                        anchors.left: id_num_text.right
                        anchors.right: parent.right
                        font.pixelSize: 28
                        wrapMode: YText.WordWrap
                        textFormat: Text.RichText
                        color: "white"
                        function replacelBlable(key){
                            return "<font color=" + "#F03043" + ">" + key + "</font>"
                        }
                        function delHtmlTag(str){
                            return str.replace(/<[^>]+>/g,"");
                        }
                        text: {
                            var wordModel = id_data_repeater.model[index]
                            var temp_content = ""
                            wordModel.sentence_pjm.forEach(function(wordObj){
                                var wordString = delHtmlTag(wordObj.word)
                                if(wordObj.pjm){
                                    temp_content += '<u>%1</u>'.arg(wordString)  //createContentHighlightKey(wordString,"white")
                                    temp_content += ("[" + wordObj.pjm + "]")
                                }else{
                                    temp_content += wordString
                                }
                            })
                            return temp_content.replace(currentWord,'<font color=#F03043>' + currentWord + '</font>')
                        }
                    }

                    //例句
                    YText {
                        id: id_sentence_text
                        anchors.top: id_trans_text.bottom
                        anchors.left: id_num_text.right
                        anchors.right: parent.right
                        font.pixelSize: 26
                        wrapMode: YText.WordWrap
                        color: "#A8AAB2"
                        textFormat: Text.RichText
                        text: id_data_repeater.model[index].sentence_trans
                    }

                }
            }
        }
    }

}

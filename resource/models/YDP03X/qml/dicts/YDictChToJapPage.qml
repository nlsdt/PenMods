import QtQuick 2.12
//import QtQuick.XmlListModel 2.14
import com.youdao.pen 1.0
import BaseQml 1.0
import "../i18n"
import "../../qml/timers"
import "../components"
import "../commons"

YDictTypeBase {
    id: id_dict_type_chTojap
    title: YTranslateText.dtYoudaoChToJap
    property var jap_words: [] //释义词头
    property var id_data_array: [] //例句词头
    property string currentkeyWord: ""
//    property bool isEgSentence: false
    ListModel{
        id: id_data_list_model
    }

    function createContentHighlightKey(key,color,isTruncation = false,truncationNum = 0){
        var tmp_key = key.replace(/'/g,"")
        console.log("seven:createContentHighlightKey",tmp_key)
        var temp_content = ""
        temp_content += "<a href="
        temp_content += tmp_key
        temp_content += ">"
        temp_content += ("<font color=" + color + ">")//"<font color=\"#509DEB\">"
        if(isTruncation)
            if(tmp_key.length > truncationNum)
                temp_content += (tmp_key.substring(0,truncationNum))
            else
                temp_content += tmp_key
        else
            temp_content += tmp_key
        temp_content += "</font>"
        temp_content += "</a>"
        console.log("seven:createContentHighlightKey",temp_content)
        return " "+temp_content
    }

    onDictJsonChanged: {
        console.log("seven:chToJap:",JSON.stringify(dictJson))
        dictJson.wordList.forEach(function (senseObj){
            currentkeyWord = senseObj.head.hw
            senseObj.sense.forEach(function(contetnObj){
                //词性
                var pos = ""
                if(contetnObj.pos !== undefined) pos = ("[" + contetnObj.pos + "]")
                if(contetnObj.phrList !== undefined) {
                    contetnObj.phrList.forEach(function(phrListObj){
                        var temp_content = ""
                        //释意
                        var truncationNum = 20
                        var truncationNumStr = phrListObj.text.substring(0, phrListObj.text.length > truncationNum ? truncationNum : phrListObj.text.length)
                        temp_content  +=  (createContentHighlightKey(phrListObj.text, "#509DEB",true, truncationNum) + " ")
                        if(truncationNumStr.length <= truncationNum){
                            var remaLength = truncationNum - truncationNumStr.length
                            var remaString = pos.substring(0, pos.length > remaLength ? remaLength : pos.length)
                            temp_content += remaString
                            truncationNumStr += remaString
                        }
                        //释义 解释
                        if(phrListObj.textTrans){
                            if(truncationNumStr.length <= truncationNum){
                                remaLength = truncationNum - truncationNumStr.length
                                var transString = " " +phrListObj.textTrans
                                remaString = transString.substring(0, transString.length > remaLength ? remaLength : transString.length)
                                temp_content += remaString
                                truncationNumStr += remaString
                            }
                        }
                        if(truncationNumStr.length >= 16) temp_content += "..."
                        jap_words.push({
                                           "content" : temp_content,
                                           "href" : phrListObj.text.replace(/'/g,"")
                                       })

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
                            id_data_array.push(conetentElement)
                        }

                    })
                }

            })
        })

    }
    Item {
        width: parent.width
        height: id_chtojap_content_colum.height

        Column {
            id: id_chtojap_content_colum
            width: parent.width
            Repeater {
                id: id_data_array_repeater
                width: parent.width
                model: jap_words
                Column {
                    width: parent.width
                    YText {
                        id: id_paraphrase_ytext
                        height: 50
                        clip: true
                        anchors.left: parent.left
                        anchors.right: parent.right
                        font.pixelSize: 28
                        textFormat: Text.RichText
                        elide: Text.ElideRight
                        visible: text.length
                        color: YColors.white
                        verticalAlignment: Text.AlignVCenter
                        text: id_data_array_repeater.model[index].content
                        onLinkActivated: {
                            console.log("seven:clickText:1:",link)
                            console.log("seven:clickText:2:",id_data_array_repeater.model[index])
//                            resultManager.transBtnType = YEnum.TBT_Ch
                            if(id_data_array_repeater.model[index].href === resultManager.currentQuery) return
                            id_dict_page.clickSearchWord(id_data_array_repeater.model[index].href)
                        }
                    }
                }

            }

            YSpacingForColumn{
                height: 18
                visible: id_data_array.length
            }

            Rectangle {
                width: parent.width
                height: 26
                color: "transparent"
                visible: id_data_array.length
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
                visible: id_data_array.length
            }

            Repeater {
                id: id_data_repeater
                width: parent.width
                model: id_data_array
                Rectangle {
                    width: parent.width
                    height: {
                        if(visible){
                            id_wors_text.contentHeight + id_v_space_rectangle.height + id_sentence_text.contentHeight  + id_trans_text.contentHeight + 14
                        }else
                            return 0
                    }
    //                visible: id_sentence_text.text.length
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
                    //例句
                    YText {
                        id: id_sentence_text
                        anchors.top: id_v_space_rectangle.bottom
                        anchors.left: id_num_text.right
                        anchors.right: parent.right
                        font.pixelSize: 26
                        wrapMode: YText.WordWrap
                        color: "#A8AAB2"
                        textFormat: Text.RichText
                        text: id_data_repeater.model[index].sentence.replace(/<b>.*?<\/b>/g, '<font color="%1">%2</font>'.arg(YColors.red).arg(currentkeyWord))
                    }

    //                //发音按钮
                    Rectangle {
                        width: 34
                        height: 34
                        anchors.top: id_sentence_text.bottom
                        anchors.topMargin: 8
                        color: "transparent"
                        YPronunciationAudioButton {
                            id: id_audio_pron
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
    //                            id_follow_mypron.stop()
                            }
                        }
                    }

                    //翻译
                    YText {
                        id: id_trans_text
                        anchors.top: id_sentence_text.bottom
                        anchors.left: id_num_text.right
                        anchors.right: parent.right
                        font.pixelSize: 28
                        wrapMode: YText.WordWrap
                        textFormat: Text.RichText
                        color: "white"
                        function delHtmlTag(str){
                            return str.replace(/<[^>]+>/g,"");
                        }
                        text: {
                            var wordModel = id_data_repeater.model[index]
                            var temp_content = ""
                            wordModel.sentence_pjm.forEach(function(wordObj){
                                var wordString = delHtmlTag(wordObj.word)
                                if(wordObj.pjm){
                                    temp_content += /*wordString*/createContentHighlightKey(wordString,"white")
                                    temp_content += ("[" + wordObj.pjm + "]")
                                }else{
                                    temp_content += wordString//wordObj.word
                                }
                            })
                            return temp_content
                        }
                    }

                }
            }

        }
    }

}

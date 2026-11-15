import QtQuick 2.12
import com.youdao.pen 1.0
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
import BaseQml 1.0
import "../i18n"
YPage {
    anchors.fill: parent
    YVerticalTitleBar {
        id: id_title_bar
        onCallBack: {
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
                id_follow_drawer_layer.show();
            }
        }
    }

    property var correctWordPageId: null
    property int currentIndex: 0
    YPopLayer {
        id: id_pop_layer
        function showPage(qrcqml, properties) {
            show(qrcqml, false, false, properties)
            correctWordPageId = popItemObject
            correctWordPageId.backButtonClicked.connect(function(){
                correctWordPageId = null
            })
            correctWordPageId.updatePrePage.connect(function(correct){
                console.log("seven:updatePrePage:",correct)
//                id_word_correct_list_model.get(currentIndex).isCorrect = correct
                id_word_correct_list_model.get(currentIndex).pronunciation = correct
                if(correct >= 80)
                    id_word_correct_list_model.move(currentIndex,0,1)
            })
        }
    }

    function jumpToCorrectWordPage(data){
        id_pop_layer.showPage("components/YFollowCorrectWordPage")
    }

    YFollowLangSwitch {
        id: id_follow_drawer_layer
        z: 100
        onFilterChanged: {
//            id_score.width = 1
            followManager.isUk = langType == YEnum.UK
        }
    }

    function setCorrectWordlistData(wordList){
        id_word_correct_list_model.clear()
        for(var i = 0; i < wordList.count; ++i){
            var temp_wordObj = wordList.get(i)//wordList[i]
            id_word_correct_list_model.append(temp_wordObj)
//            id_word_correct_list_model.append({
//                                                  "pronunciation" : parseInt(temp_wordObj.pronunciation),
//                                                  "word" : temp_wordObj.word,
//                                                  "orgPhoneme" : temp_wordObj.orgPhoneme,
//                                                  "phonemes" : temp_wordObj.phonemes,
//                                                  "lowestpPhone" : temp_wordObj.lowestpPhone,
//                                                  "phone_guide" : temp_wordObj.phone_guide,
//                                                  "richTextPhonemes" : temp_wordObj.richTextPhonemes,
//                                                  "richContent" : temp_wordObj.richContent,
//                                                  "richHighlightedContent" : temp_wordObj.richHighlightedContent,
//                                                  "richContentPhType" : temp_wordObj.richContentPhType,
//                                                  "richContentPhHighlightedType" : temp_wordObj.richContentPhHighlightedType,
//                                                  "isCorrect" : 0
//                                              })
        }
    }

    ListModel {
        id: id_word_correct_list_model
    }



    Flickable {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.leftMargin: 90
        anchors.rightMargin: 16
        contentHeight: id_word_list_colum.height
        Column {
            id: id_word_list_colum
            width: parent.width
            YSpacingForColumn{
                height: 24
                visible: true
            }
            Text {
                id: id_title
                height: 34
                text: "点击单词，开始纠音"
                verticalAlignment: Text.AlignVCenter
                font.family: "OPPOSans"
                font.pixelSize: 26
                color: "#909199"
            }

            YSpacingForColumn{
                height: 22
                visible: true
            }

            Repeater {
                width: parent.width
                model: id_word_correct_list_model//[1,2,3,4,5]
                Column {
                    width: parent.width
                    Rectangle {
                        width: parent.width
                        height: 76
                        color: "#1A1B1F"
                        radius: 16

                        Rectangle{
                            id: id_score_bg
                            width: 70
                            height: 40
                            color:{
                                if(pronunciation < 60) return "#C5423B"
                                else if(pronunciation >= 60 && pronunciation < 80) return "#BF7810"
                                else return "#363636"
                            }// isCorrect ? "#363636" : "#F04C42"
                            radius: 14
                            anchors.left: parent.left
                            anchors.leftMargin: 20
                            anchors.verticalCenter: parent.verticalCenter
                            clip: true
                            YText {
                                id: id_socre
                                font.family: "OPPOSans"
                                height: 26
                                anchors.top: parent.top
                                anchors.bottom: parent.bottom
                                anchors.left: parent.left
                                anchors.right: parent.right
                                verticalAlignment: Text.AlignVCenter
                                horizontalAlignment  : Text.AlignHCenter
                                font.pixelSize: 22
                                color: "#FFFFFF"
                                text: parseInt(pronunciation) + "分"
                            }
                        }

                        Text {
                            id: id_word
                            anchors.left: id_score_bg.right
                            anchors.top: parent.top
                            anchors.bottom: parent.bottom
                            anchors.leftMargin: 36
                            text: word
                            verticalAlignment: Text.AlignVCenter
                            horizontalAlignment: Text.horizontalCenter
                            font.family: "OPPOSans"
                            font.pixelSize: 22
                            color: "#FFFFFF"
                        }

                        Text {
                            id: id_symbol
                            anchors.left: id_word.right
                            anchors.top: parent.top
                            anchors.bottom: parent.bottom
                            anchors.right: parent.right
                            anchors.rightMargin: 60
                            anchors.leftMargin: 10
                            elide: Text.ElideRight
                            text: {
                                return phonemes
//                                var  symbol = ""
//                                for(var i = 0 ; i < phonemes.count; ++i){
//                                    symbol += phonemes.get(i).phoneme
//                                }
//                                var symbleTypeStrin = "美"
//                                if(followManager.isUk) symbleTypeStrin = "英"
//                                return symbleTypeStrin + "/ " + symbol + " /"
                            }
                            verticalAlignment: Text.AlignVCenter
//                            horizontalAlignment: Text.horizontalCenter
                            font.family: "OPPOSans"
                            font.pixelSize: 22
                            color: "#A8AAB2"
                        }

                        YImage {
                            id: id_status_image
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.right:parent.right
                            anchors.rightMargin: 26
                            width: 30
                            height: 20
                            visible: pronunciation >= 80//isCorrect
                            sourceSize: Qt.size(30, 30)
                            imageName: "dict/follow_word_status"
                            fillMode: Image.PreserveAspectFit
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                jumpToCorrectWordPage()
                                correctWordPageId.currentWordJson = id_word_correct_list_model.get(index)
                                currentIndex = index
                            }
                        }

                    }

                    YSpacingForColumn{
                        height: 10
                        visible: true
                    }
                }

            }
        }
    }

    Connections {
        target: systemBase
        ignoreUnknownSignals: true
        //enabled: id_dict_page.visible
        function onOcrStart() {
//            backButtonClicked()
        }
        function onOcrStop(scanType) {
            backButtonClicked()
        }
    }
}

import QtQuick 2.12
import com.youdao.pen 1.0
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
import BaseQml 1.0
import "../i18n"
Item {
    property alias wordText: id_symbol_phonetic.text
    property alias followEnable: id_audio_pron.enabled
    height: id_symbol_phonetic.contentHeight
    function setPronunciationWord(word_pronunciation){
        id_symbol_phonetic.text = word_pronunciation
    }
    YText {
        id: id_symbol_phonetic
        height: {
            return 32
        }
        width: contentWidth
        anchors.horizontalCenter: parent.horizontalCenter
        horizontalAlignment  : Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        font.family: "OPPOSans"
//        wrapMode: Text.WordWrap
        textFormat: Text.RichText
        font.bold :true
        font.pixelSize: 30
        color: "#FFFFFF"
        text: ""

        YFollowAudioButton {
            id: id_audio_pron
            x: -32 - 14
            width: 32
            height: 32
            leftMargin: -3 //对齐
            textFontFamily: fontManager.fontFamilyEnUs
            textFormat: YText.PlainText
            radius: 12
            color: "#43DCFF"
            enabled: true
            text: ""
            visible: true
            onValidClicked: {
                playJap()
            }
            function playJap(){
                console.log("seven:playJap:1:")
                playWord(followManager.content, "en")
            }
        }

    }

}

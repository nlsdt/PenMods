import QtQuick 2.12
import com.youdao.pen 1.0

import BaseQml 1.0
import "../i18n"
import "../components"

Column {
    spacing: 10
    id: id_idiom_story_dict_column
    YText {
        id: id_author_content_text
        anchors.left: parent.left
        width: parent.width
        height: contentHeight
        clip: true
        font.family: fontManager.fontFamilyZhCn
        font.pixelSize: 28
        color: YColors.white
        wrapMode: YTextBase.Wrap
        text:{
          return  "     "+dictJson.story
        }
        YAudioPlayButton {
            width: 32
            implicitHeight: 32
            sourceSize: Qt.size(32, 32)
            imageName: "dict/sound"
            id: id_sound_icon
            textFontFamily: fontManager.fontFamilyEnUs
            textFormat: YText.PlainText
            leftMargin: 0
            anchors.left: parent.left
            anchors.top:parent.top
            anchors.topMargin: 3
            color: YColors.black
            text: ""
            onValidClicked: {
                if (playing) {
                    playWord(dictJson.story, "zh")
                }
            }
        }
        //                    visible: id_detail_author_text.visible
    }
}

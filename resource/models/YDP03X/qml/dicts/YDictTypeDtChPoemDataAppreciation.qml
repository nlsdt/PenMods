import QtQuick 2.12
import com.youdao.pen 1.0

import BaseQml 1.0
import "../commons"
import "../i18n"
import "../components"

Column {
    id: id_detail_analysis_column
    spacing: 16
    property var jsonPoemData: {
        return dictJson
    }

    YAudioPlayIconLabelButton {
        id: id_sound_org
        textFontFamily: fontManager.fontFamily
        textFormat: YText.PlainText
        text: YTranslateText.appreciation
        onValidClicked: {
            if (playing) {
                qmlGlobal.audioPlayId = soundCenter.play(jsonPoemData.join(""),
                                                         "zh")
            }
        }
    }

    Repeater {
        id: id_detail_analysis_repeater
        model:  {
            return  jsonPoemData
        }
        Column {
            anchors.left: parent.left
            anchors.right: parent.right

            YText {
                anchors.left: parent.left
                width: parent.width
                height: paintedHeight
                font.family: fontManager.fontFamilyZhCn
                font.pixelSize: 28
                color: YColors.white
                wrapMode: YTextBase.Wrap
                text: model.modelData
            }
        }
    }
}


import QtQuick 2.12
import com.youdao.pen 1.0

import BaseQml 1.0
import "../i18n"

YMouseArea {
    width:  id_word_start_bg.width
    height: id_word_start_bg.height
    property var word: ""
    property bool isCHType: false
    property var containWidth: 614
    property bool isAddSpace: true
    //enabled: id_word_bg.clickable
    //z: id_dict_page.z - 1
    //objectName: "YDictPage.qml_id_delegate_index" + index
   //property alias word: id_start_word.text
    Rectangle {
        id: id_word_start_bg
        width: id_start_word.width
        implicitHeight: id_start_word.height
        color:  "transparent"
        radius: 16
        YTextBase {
            id: id_calc_start_word
            anchors.centerIn: parent
            font.family: isCHType ? fontManager.fontFamilyZhCn:fontManager.fontFamilyEnUs
            width: contentWidth + (isAddSpace ? 16 : 0)
            font.pixelSize: 28
            color: YColors.orange
            anchors.left: parent.left
            font.weight: isCHType ? Font.DemiBold : Font.Bold
            text:word
            font.letterSpacing: 2
            visible: false
        }
        YTextBase {
            id: id_start_word
            textFormat: YText.RichText
            anchors.centerIn: parent
            font.family: isCHType ? fontManager.fontFamilyZhCn : fontManager.fontFamilyEnUs
            width:id_calc_start_word.width > containWidth ? containWidth:id_calc_start_word.width
            wrapMode: id_calc_start_word.width > containWidth?YText.WordWrap:Text.NoWrap
            font.pixelSize: 28
            color: YColors.blueText
            anchors.left: parent.left
            font.weight: isCHType ? Font.DemiBold : Font.Bold
            text:word
            font.letterSpacing: isCHType?2:0

        }
        opacity: 1
    }
}

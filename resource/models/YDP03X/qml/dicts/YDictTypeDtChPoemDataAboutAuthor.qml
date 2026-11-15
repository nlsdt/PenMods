import QtQuick 2.12
import com.youdao.pen 1.0

import BaseQml 1.0
import "../commons"
import "../i18n"

Column {
    spacing: 16
    id: id_poem_dict_data_column
    property var jsonPoemData: dictJson.aboutAuthor
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
        text: id_poem_dict_data_column.jsonPoemData
        //                    visible: id_detail_author_text.visible
    }
}


import QtQuick 2.12
import com.youdao.pen 1.0

import BaseQml 1.0
import "../i18n"

Column {
    spacing: 10
    id: id_idiom_source_dict_column
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
        text: dictJson.source
        //                    visible: id_detail_author_text.visible
    }
}

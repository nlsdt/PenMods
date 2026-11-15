import QtQuick 2.12
import com.youdao.pen 1.0

import BaseQml 1.0
import "../i18n"

YDictTypeBase {
    title: YTranslateText.dtPEPPrim

    Item {
        width: parent.width
        height: id_dict_content_column.height

        Column {
            id: id_dict_content_column
            width: parent.width
            spacing: 0

            YText {
                id: id_dict_content
                width: parent.width
                lineHeightMode: Text.FixedHeight
                lineHeight: 34
                wrapMode: YText.Wrap
                font.family: fontManager.fontFamilyZhCn
                text: dictJson.trans
            }

            YSpacingForColumn {
                visible: isFirstDict
                implicitHeight: 6
            }

            YText {
                font.family: fontManager.fontFamilyZhCn
                width: parent.width
                lineHeightMode: Text.FixedHeight
                lineHeight: 29
                wrapMode: YTextBase.Wrap
                color: YColors.grayText
                font.pixelSize: 24
                visible: isFirstDict
                text: ("( %1《%2》)").arg(YTranslateText.exampleSentencesFrom)
                                    .arg(YTranslateText.dtPEPPrim)
            }
        }
    }
}

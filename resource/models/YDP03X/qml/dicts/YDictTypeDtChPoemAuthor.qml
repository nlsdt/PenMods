import QtQuick 2.12

import BaseQml 1.0
import "../i18n"

Column {
    id: id_poem_dict_author
    spacing: 16

    property var jsonAuthorData: null

    YTextBase {
        id: id_author_name_info
        width: parent.width
        height: paintedHeight
        font.family: fontManager.fontFamilyZhCn
        font.pixelSize: 28
        font.weight: Font.Medium
        textFormat: YTextBase.RichText
        wrapMode: YTextBase.Wrap
        color: "#FFFFFF"
        topPadding: 10
        text: {
            let qsText = ('<span style="color: %1">').arg(YColors.grayText) + YTranslateText.dynasty + '&nbsp;</span>' + jsonAuthorData.dynasty
            if (typeof jsonAuthorData.zi != "undefined" && JSON.stringify(jsonAuthorData.zi).replace(/"/g , "").trim().length)
                qsText += ('&nbsp;&nbsp;&nbsp;&nbsp;<span style="color: %1">').arg(YColors.grayText) + YTranslateText.called + '&nbsp;</span>' + jsonAuthorData.zi
            if (typeof jsonAuthorData.hao != "undefined" && JSON.stringify(jsonAuthorData.hao).replace(/"/g , "").trim().length)
                qsText += ('&nbsp;&nbsp;&nbsp;&nbsp;<span style="color: %1">').arg(YColors.grayText) + YTranslateText.designation + '&nbsp;</span>' + jsonAuthorData.hao
            if (typeof jsonAuthorData.knownAs != "undefined" && JSON.stringify(jsonAuthorData.knownAs.replace(/"/g , "").trim()).length)
                qsText += ('&nbsp;&nbsp;&nbsp;&nbsp;<span style="color: %1">').arg(YColors.grayText) + YTranslateText.worldName + '&nbsp;</span>' + jsonAuthorData.knownAs
            return qsText
        }
    } // Text id_author_name_info

    YTextBase {
        font.pixelSize: 26
        font.family: fontManager.fontFamily
        font.weight: Font.Normal
        color: YColors.red
        width: parent.width
        height: contentHeight + 14
        text: YTranslateText.introduction
        topPadding: 14
    }

    YTextMedium {
        width: parent.width
        height: paintedHeight
        font.family: fontManager.fontFamilyZhCn
        wrapMode: YTextBase.Wrap
        text: jsonAuthorData.intro
    }

    readonly property bool havePoems: typeof jsonAuthorData.poems != "undefined" && jsonAuthorData.poems.length

    YTextBase {
        font.pixelSize: 26
        font.family: fontManager.fontFamily
        font.weight: Font.Normal
        color: YColors.red
        width: parent.width
        height: contentHeight + 14
        text: YTranslateText.production
        topPadding: 14
        visible: havePoems
    }

    YTextMedium {
        width: parent.width
        height: paintedHeight
        font.family: fontManager.fontFamilyZhCn
        wrapMode: YTextBase.Wrap
        text: {
            let qsText = ""
            let iFlag = 0
            jsonAuthorData.poems.forEach(function(poemName){
                if (iFlag++ > 0) qsText += '、'
                qsText += '《' + poemName + '》'
            })
            return qsText
        }
        visible: havePoems
    }

}


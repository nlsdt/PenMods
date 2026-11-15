import QtQuick 2.12

import BaseQml 1.0
import "./YDictOxfordUtilities.js" as OxfordUtilities
import "./YDictOxfordModel.js" as OxfordModel

Column {
    id: id_exampleblock_column
    width: parent.width
    spacing: 10
    property var meanDataNgX: null

    YTextMedium {
        width: parent.width
        height: contentHeight
        font.family: fontManager.fontFamilyEnUs
        font.pixelSize: 26
        color: YColors.grayText
        textFormat: YTextBase.RichText
        wrapMode: YTextBase.WordWrap
        text: {
            if (id_exampleblock_column.meanDataNgX === null) {
                return ""
            }
            var vFormatExt = ""
            if (OxfordUtilities.isArrayFn(id_exampleblock_column.meanDataNgX.pt)) {
                vFormatExt += OxfordUtilities.ptToFormatted(id_exampleblock_column.meanDataNgX.pt)
            }
            vFormatExt += OxfordUtilities.grToFormatted(id_exampleblock_column.meanDataNgX)
            if (typeof id_exampleblock_column.meanDataNgX.pvpt == "string") {
                vFormatExt += '[' + id_exampleblock_column.meanDataNgX.pvpt + ']'
            }
            return vFormatExt
        }
        visible: text.length > 0
    }

    Item {
        id: id_word_header_mean_ng_x
        width: parent.width
        height: id_word_header_mean_ng_x_content_column.height
        readonly property var qsMeanNgXEn: (id_exampleblock_column.meanDataNgX !== null
                                            && typeof id_exampleblock_column.meanDataNgX.content == "string")
                                           ? id_exampleblock_column.meanDataNgX.content : ""
        readonly property var qsMeanNgXCh: (id_exampleblock_column.meanDataNgX !== null
                                            && typeof id_exampleblock_column.meanDataNgX.chn != "undefined")
                                           ? id_exampleblock_column.meanDataNgX.chn.content.replace(/<br>/g, "") : ""
        readonly property bool bMeanNgXDel: (id_exampleblock_column.meanDataNgX !== null
                                             && typeof id_exampleblock_column.meanDataNgX.wx == "boolean")
                                            ? id_exampleblock_column.meanDataNgX.wx : false

        YTextMedium {
            id: id_word_header_mean_ng_x_point
            font.family: fontManager.fontFamilyEnUs
            font.weight: Font.Bold
            anchors.left: parent.left
            width: 24
            height: id_word_header_mean_ng_x_content_column.height
            color: YColors.grayText
            text: "· "
            visible: id_word_header_mean_ng_x_en.visible || id_word_header_mean_ng_x_ch.visible
        }

        Column {
            id: id_word_header_mean_ng_x_content_column
            anchors.left: id_word_header_mean_ng_x_point.right
            anchors.right: parent.right
            spacing: 6

            YText {
                id: id_word_header_mean_ng_x_en
                font.family: fontManager.fontFamilyEnUs
                font.strikeout: id_word_header_mean_ng_x.bMeanNgXDel
                width: parent.width
                height: contentHeight
                color: YColors.grayText
                textFormat: YTextBase.RichText
                wrapMode: YTextBase.WordWrap
                text: OxfordUtilities.htmlToFormatted(id_word_header_mean_ng_x.qsMeanNgXEn)
                visible: text.length > 0
            }

            YText {
                id: id_word_header_mean_ng_x_ch
                font.family: fontManager.fontFamilyZhCn
                font.pixelSize: 26
                width: parent.width
                height: contentHeight
                color: YColors.grayText
                textFormat: YTextBase.RichText
                wrapMode: YTextBase.WordWrap
                text: OxfordUtilities.htmlToFormatted(id_word_header_mean_ng_x.qsMeanNgXCh)
                visible: text.length > 0
            }
        }
    }

    YLoader {
        id: id_word_header_mean_ng_x_help_loader
        asynchronous: false
        readonly property int componentWidth: id_exampleblock_column.width
        readonly property var helpObj: id_exampleblock_column.meanDataNgX !== null
                                       && typeof id_exampleblock_column.meanDataNgX.help != "undefined"
                                       ? id_exampleblock_column.meanDataNgX.help : null
        readonly property bool bHasIcon: true
        readonly property var qsCh: OxfordUtilities.helpChToFormatted(helpObj)
        readonly property var qslEn: OxfordUtilities.helpEnToFormatted(helpObj)
        active: qsCh.length > 0 || qslEn.length > 0
        sourceComponent: YDictTypeDtOxfordHelp{}
    }

    Repeater {
        model: {
            if (id_exampleblock_column.meanDataNgX === null
                    || typeof id_exampleblock_column.meanDataNgX.xr1 != "object") {
                return null
            }
            if (OxfordUtilities.isArrayFn(id_exampleblock_column.meanDataNgX.xr1)) {
                return id_exampleblock_column.meanDataNgX.xr1
            } else {
                return [id_exampleblock_column.meanDataNgX.xr1]
            }
        }

        YTextMedium {
            width: id_exampleblock_column.width
            height: contentHeight
            font.family: fontManager.fontFamilyEnUs
            color: YColors.grayText
            textFormat: YTextBase.RichText
            wrapMode: YTextBase.WordWrap
            text: OxfordUtilities.meanNgXrToFormatted(model.modelData, wordText)
            visible: text.length > 0
        }
    }

}


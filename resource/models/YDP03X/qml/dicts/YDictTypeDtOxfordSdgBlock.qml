import QtQuick 2.12

import BaseQml 1.0
import "./YDictOxfordUtilities.js" as OxfordUtilities
import "./YDictOxfordModel.js" as OxfordModel

Column {
    id: id_word_sdgblock_column
    width: parent.width
    spacing: 10
    property var meanData: null
    property bool bForHeader: false

    Item {
        id: id_word_header_mean_sd
        width: parent.width
        height: id_word_header_mean_sd_text.height
        visible: id_word_header_mean_sd_text.visible
        readonly property var meanDataSd: (id_word_sdgblock_column.meanData !== null
                                           && typeof id_word_sdgblock_column.meanData.sd != "undefined")
                                          ? id_word_sdgblock_column.meanData.sd : null

        Item {
            id: id_word_header_mean_sd_icon
            width: 43
            height: id_word_header_mean_sd_text.height
            anchors.left: parent.left
            visible: id_word_header_mean_sd_text.visible
            YImage {
                imageName: "dict/oxford-mean"
                anchors.left: parent.left
                anchors.top: parent.top
                anchors.topMargin: 8
            }
        }

        YText {
            id: id_word_header_mean_sd_text
            anchors.left: id_word_header_mean_sd_icon.right
            anchors.right: parent.right
            height: contentHeight
            color: "#FFFFFF"
            textFormat: YTextBase.RichText
            wrapMode: YTextBase.WordWrap
            text: {
                if (id_word_header_mean_sd.meanDataSd === null) {
                    return ""
                }
                var qsEn = typeof id_word_header_mean_sd.meanDataSd.content != "undefined"
                        ? id_word_header_mean_sd.meanDataSd.content.toUpperCase() : ""
                var qsCh = (typeof id_word_header_mean_sd.meanDataSd.chn != "undefined"
                            && typeof id_word_header_mean_sd.meanDataSd.chn.content != "undefined")
                        ? id_word_header_mean_sd.meanDataSd.chn.content : ""
                if (qsEn.length <= 0 && qsCh.length <= 0) {
                    return ""
                }
                qsEn = OxfordUtilities.htmlToFormatted(qsEn)
                qsCh = OxfordUtilities.htmlToFormatted(qsCh)
                return OxfordUtilities.formatText(qsEn, "#FFFFFF", 500, 30, fontManager.fontFamilyEnUs) + ' '
                        + OxfordUtilities.formatText(qsCh, "#FFFFFF", 400, 30, fontManager.fontFamilyZhCn)
            }
            visible: text.length > 0
        }

    }

    Column {
        id: id_word_header_mean_column
        width: parent.width
        spacing: 20

        Repeater {
            id: id_word_sdgblock_ng_repeater
            model: {
                if (id_word_sdgblock_column.meanData === null) {
                } else if (OxfordUtilities.isArrayFn(id_word_sdgblock_column.meanData["n-g"])) {
                    if (bForHeader) {
                        return [id_word_sdgblock_column.meanData["n-g"][0]]
                    } else {
                        return id_word_sdgblock_column.meanData["n-g"]
                    }
                }
                return null
            }

            Item {
                id: id_word_header_mean_ng
                width: parent.width
                height: id_word_header_mean_ng_column.height
                readonly property var qsPosCur: wordListCount > 1 ? "" : posList[0][currentMeanIdx]
                readonly property var meanDataNg: model.modelData
                readonly property var meanDataNgD: {
                    if (meanDataNg === null) {
                    } else if (typeof meanDataNg.d != "undefined") {
                        return meanDataNg.d
                    } else if (typeof meanDataNg.ud != "undefined") {
                        return meanDataNg.ud
                    }
                    return null
                }

                YText {
                    id: id_word_header_mean_ng_index
                    width: 43
                    topPadding: 4
                    anchors.left: parent.left
                    height: id_word_header_mean_ng_column.height
                    font.family: fontManager.fontFamilyZhCn
                    font.pixelSize: 26
                    color: YColors.grayText
                    text: visible ? (typeof id_word_header_mean_ng.meanDataNg.n == "number" ?
                                         (id_word_header_mean_ng.meanDataNg.n + ".") : "1.") : ""
                    visible: id_word_sdgblock_column.meanData !== null
                             && id_word_header_mean_ng.meanDataNg !== null
                             && id_word_sdgblock_ng_repeater.count > 1
                }

                Column {
                    id: id_word_header_mean_ng_column
                    anchors.left: id_word_header_mean_ng_index.visible ? id_word_header_mean_ng_index.right : parent.left
                    anchors.right: parent.right
                    spacing: 10

                    YTextMedium {
                        width: parent.width
                        height: contentHeight
                        font.family: fontManager.fontFamilyEnUs
                        color: "#FFFFFF"
                        textFormat: YTextBase.RichText
                        wrapMode: YTextBase.WordWrap
                        text: OxfordUtilities.meanNgGrToFormatted(id_word_header_mean_ng.meanDataNg, wordText, id_word_header_mean_ng.qsPosCur, fontManager.fontFamilyZhCn)
                        visible: text.length > 0
                    }

                    Repeater {
                        model: {
                            if (id_word_header_mean_ng.meanDataNgD === null
                                    || typeof id_word_header_mean_ng.meanDataNgD.xr1 != "object") {
                                return null
                            }
                            if (OxfordUtilities.isArrayFn(id_word_header_mean_ng.meanDataNgD.xr1)) {
                                return id_word_header_mean_ng.meanDataNgD.xr1
                            } else {
                                return [id_word_header_mean_ng.meanDataNgD.xr1]
                            }
                        }

                        YTextMedium {
                            width: id_word_header_mean_ng_column.width
                            height: contentHeight
                            font.family: fontManager.fontFamilyEnUs
                            color: YColors.grayText
                            textFormat: YTextBase.RichText
                            wrapMode: YTextBase.WordWrap
                            text: OxfordUtilities.meanNgXrToFormatted(model.modelData, wordText)
                            visible: text.length > 0
                        }
                    }

                    Repeater {
                        id: id_word_header_mean_ng_x_repeater
                        model: {
                            if (meanDataNg === null || typeof meanDataNg.x != "object") {
                            } else if (OxfordUtilities.isArrayFn(meanDataNg.x)) {
                                if (bForHeader) {
                                    return [meanDataNg.x[0]]
                                } else {
                                    return meanDataNg.x
                                }
                            } else {
                                return [meanDataNg.x]
                            }
                            return null
                        }

                        YDictTypeDtOxfordExampleBlock {
                            width: id_word_header_mean_ng_column.width
                            meanDataNgX: model.modelData
                        }
                    }

                    YTextMedium {
                        width: parent.width
                        height: contentHeight
                        font.family: fontManager.fontFamilyEnUs
                        color: YColors.grayText
                        textFormat: YTextBase.RichText
                        wrapMode: YTextBase.WordWrap
                        text: {
                            if (id_word_header_mean_ng.meanDataNg !== null){
                                if (OxfordUtilities.isPtAfterX(wordText, id_word_header_mean_ng.qsPosCur)){
                                    if (OxfordUtilities.isArrayFn(id_word_header_mean_ng.meanDataNg.pt)){
                                        return OxfordUtilities.ptToFormatted(id_word_header_mean_ng.meanDataNg.pt)
                                    }
                                }
                            }
                            return ""
                        }
                        visible: text.length > 0
                    }

                    YTextMedium {
                        width: parent.width
                        height: contentHeight
                        font.family: fontManager.fontFamilyEnUs
                        color: "#FFFFFF"
                        textFormat: YTextBase.RichText
                        wrapMode: YTextBase.WordWrap
                        text: {
                            if (id_word_header_mean_ng.meanDataNg === null) {
                                return ""
                            }
                            return OxfordUtilities.etymToFormatted(id_word_header_mean_ng.meanDataNg.etym, fontManager.fontFamilyZhCn)
                        }
                        visible: text.length > 0
                    }

                    YLoader {
                        id: id_word_header_mean_ng_xr_loader
                        asynchronous: false
                        readonly property int componentWidth: id_word_header_mean_ng_column.width
                        active: id_word_header_mean_ng.meanDataNg !== null && typeof id_word_header_mean_ng.meanDataNg.xr != "undefined"
                        property var xrObj: active ? id_word_header_mean_ng.meanDataNg.xr : null
                        sourceComponent: YDictTypeDtOxfordXr{}
                    }

                    YTextMedium {
                        width: parent.width
                        height: contentHeight
                        font.family: fontManager.fontFamilyEnUs
                        color: YColors.grayText
                        textFormat: YTextBase.RichText
                        wrapMode: YTextBase.WordWrap
                        text: {
                            if (id_word_header_mean_ng.meanDataNg !== null){
                                if (OxfordUtilities.isArrayFn(id_word_header_mean_ng.meanDataNg.pt1)){
                                    return OxfordUtilities.pt1ToFormatted(id_word_header_mean_ng.meanDataNg.pt1)
                                }
                            }
                            return ""
                        }
                        visible: text.length > 0
                    }

                    YLoader {
                        id: id_word_header_mean_ng_help_loader
                        asynchronous: false
                        readonly property int componentWidth: id_word_header_mean_ng_column.width
                        readonly property var helpObj: (id_word_header_mean_ng.meanDataNg !== null
                                                        && typeof id_word_header_mean_ng.meanDataNg.help != "undefined")
                                                       ? id_word_header_mean_ng.meanDataNg.help : null
                        readonly property bool bHasIcon: true
                        readonly property var qsCh: OxfordUtilities.helpChToFormatted(helpObj)
                        readonly property var qslEn: OxfordUtilities.helpEnToFormatted(helpObj)
                        active: qsCh.length > 0 || qslEn.length > 0
                        sourceComponent: YDictTypeDtOxfordHelp{}
                    }

                }
            }
        }
        YLoader {
            id: id_word_header_mean_help_loader
            asynchronous: false
            readonly property int componentWidth: id_word_header_mean_column.width
            readonly property var helpObj: id_word_sdgblock_column.meanData !== null
                                           && typeof id_word_sdgblock_column.meanData.help != "undefined"
                                           ? id_word_sdgblock_column.meanData.help : null
            readonly property bool bHasIcon: true
            readonly property var qsCh: OxfordUtilities.helpChToFormatted(helpObj)
            readonly property var qslEn: OxfordUtilities.helpEnToFormatted(helpObj)
            active: qsCh.length > 0 || qslEn.length > 0
            sourceComponent: YDictTypeDtOxfordHelp{}
        }
    }
}

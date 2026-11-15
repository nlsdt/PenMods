import QtQuick 2.12

import BaseQml 1.0
import "./YDictOxfordUtilities.js" as OxfordUtilities
import "./YDictOxfordModel.js" as OxfordModel

Column {
    id: id_Illustration_ParaList
    width: parent.width
    spacing: 20
    property var paraObjList: []
    property var paraShowIndex: 1
    onParaObjListChanged: {
        paraShowIndex = 1
    }

    Repeater {
        model: paraObjList

        Column {
            width: id_Illustration_ParaList.width
            spacing: 10
            readonly property var paraObj: model.modelData
            readonly property var qsUnsyn: typeof paraObj.unsyn == "string" ? paraObj.unsyn : ""
            readonly property bool needShow: !(typeof paraObj.d == "object" && Object.keys(paraObj.d).length <= 0)
            readonly property bool needShowIndexPart: {
                if (needShow) {
                    if (qsUnsyn.length > 0 || typeof paraObj.d != "undefined" || typeof paraObj.d != "undefined") {
                        return true
                    }
                }
                return false
            }

            YTextMedium {
                width: parent.width
                height: contentHeight
                font.family: fontManager.fontFamilyEnUs
                font.pixelSize: 28
                color: "#FFFFFF"
                wrapMode: YTextBase.Wrap
                textFormat: YTextBase.RichText
                text: needShow ? OxfordUtilities.illTitleToFormatted(paraObj.subhead, fontManager.fontFamilyZhCn) : ""
                visible: text.length > 0
            }

            Item {
                width: parent.width
                height: id_ParaList_item_content.height
                visible: needShowIndexPart

                YText {
                    id: id_ParaList_item_index
                    width: 43
                    topPadding: 4
                    height: id_ParaList_item_content.height
                    anchors.left: parent.left
                    font.family: fontManager.fontFamilyZhCn
                    font.pixelSize: 26
                    color: YColors.grayText
                    visible: needShowIndexPart
                    Component.onCompleted: {
                        if (needShowIndexPart) {
                            text = id_Illustration_ParaList.paraShowIndex + "."
                            id_Illustration_ParaList.paraShowIndex += 1
                        }
                    }
                }

                Column {
                    id: id_ParaList_item_content
                    anchors.left: id_ParaList_item_index.right
                    anchors.right: parent.right
                    spacing: 10

                    YTextMedium {
                        width: parent.width
                        height: contentHeight
                        font.family: fontManager.fontFamilyEnUs
                        font.pixelSize: 28
                        color: "#FFFFFF"
                        wrapMode: YTextBase.Wrap
                        textFormat: YTextBase.RichText
                        text: needShowIndexPart ? qsUnsyn : ""
                        visible: text.length > 0
                    }

                    YTextMedium {
                        width: parent.width
                        height: contentHeight
                        font.family: fontManager.fontFamilyEnUs
                        font.pixelSize: 28
                        color: "#FFFFFF"
                        wrapMode: YTextBase.Wrap
                        textFormat: YTextBase.RichText
                        text: needShowIndexPart ? OxfordUtilities.illTitleToFormatted(paraObj.althead, fontManager.fontFamilyZhCn) : ""
                        visible: text.length > 0
                    }

                    Repeater {
                        id: id_ParaList_item_content_d_repeater
                        model: {
                            if (needShowIndexPart) {
                                var dObj = paraObj.d
                                if (typeof dObj == "object") {
                                    if (OxfordUtilities.isArrayFn(dObj)) {
                                        return dObj
                                    } else {
                                        return [dObj]
                                    }
                                }
                            }
                            return []
                        }

                        Column {
                            id: id_ParaList_item_content_d_column
                            width: id_ParaList_item_content.width
                            spacing: 10
                            readonly property var paraDObj: model.modelData

                            YText {
                                width: parent.width
                                height: contentHeight
                                font.family: fontManager.fontFamilyEnUs
                                font.pixelSize: 28
                                color: "#FFFFFF"
                                wrapMode: YTextBase.Wrap
                                textFormat: YTextBase.RichText
                                text: OxfordUtilities.illTitleToFormatted(paraDObj, fontManager.fontFamilyZhCn)
                                visible: text.length > 0
                            }

                            Repeater {
                                model: {
                                    var exampleListObj = paraDObj.x
                                    if (typeof exampleListObj == "object") {
                                        if (OxfordUtilities.isArrayFn(exampleListObj)) {
                                            return exampleListObj
                                        } else {
                                            return [exampleListObj]
                                        }
                                    }
                                    return []
                                }

                                YDictTypeDtOxfordExampleBlock {
                                    width: id_ParaList_item_content_d_column.width
                                    meanDataNgX: model.modelData
                                }
                            }
                        }
                    }

                    Repeater {
                        id: id_ParaList_item_content_x_repeater
                        model: {
                            if (needShowIndexPart) {
                                var exampleListObj = paraObj.x
                                if (typeof exampleListObj == "object") {
                                    if (OxfordUtilities.isArrayFn(exampleListObj)) {
                                        return exampleListObj
                                    } else {
                                        return [exampleListObj]
                                    }
                                }
                            }
                            return []
                        }

                        YDictTypeDtOxfordExampleBlock {
                            width: id_ParaList_item_content.width
                            meanDataNgX: model.modelData
                        }
                    }
                }
            }

            YDictTypeDtOxfordIllustrationParaTable {
                width: parent.width
                tableObj: needShowIndexPart ? paraObj.table : null
            }

        }
    }
}

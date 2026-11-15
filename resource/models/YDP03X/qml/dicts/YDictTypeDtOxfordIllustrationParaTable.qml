import QtQuick 2.12

import BaseQml 1.0
import "./YDictOxfordUtilities.js" as OxfordUtilities
import "./YDictOxfordModel.js" as OxfordModel

Rectangle {
    id: id_ParaList_table_container
    color: "#141414"
    radius: 8
    width: parent.width
    height: id_ParaList_table.height
    visible: cellObjList.length > 0
    property var tableObj: null
    property bool haveTh: false
    property var cellObjList: []
    onTableObjChanged: {
        let columnCount = 0
        if (tableObj !== null && typeof tableObj != "undefined") {
            if (paraObj.table.tr.length > 0) {
                if (typeof paraObj.table.tr[0].th != "undefined") {
                    columnCount = paraObj.table.tr[0].th.length
                } else {
                    columnCount = paraObj.table.tr[0].td.length
                }
            }
        }
        id_ParaList_table.columns = columnCount
        if (columnCount <= 0) {
            return []
        }
        var thList = []
        var tdList = []
        tableObj.tr.forEach(function(rowObj){
            var bIsTh = typeof rowObj.th != "undefined"
            var cellList = bIsTh ? rowObj.th : rowObj.td
            cellList.forEach(function(cellObj){
                if (bIsTh) {
                    thList.push(cellObj)
                } else {
                    tdList.push(cellObj)
                }
            })
        })
        haveTh = thList.length > 0
        cellObjList = thList.concat(tdList)
    }

    Grid {
        id: id_ParaList_table
        width: parent.width
        padding: 10
        spacing: 10
        verticalItemAlignment: Grid.AlignVCenter
        horizontalItemAlignment: Grid.AlignLeft
        columns: 0
        readonly property var cellWidth: columns > 0 ? ((width - padding * 2 - spacing * (columns - 1)) / columns) : (width - padding * 2)

        Repeater {
            model: id_ParaList_table_container.cellObjList

            Item {
                width: id_ParaList_table.cellWidth
                height: id_ParaList_table_cell_content.height
                readonly property var cellObj: model.modelData
                readonly property bool bIsThObj: id_ParaList_table_container.haveTh && index < id_ParaList_table.columns

                Column {
                    id: id_ParaList_table_cell_content
                    width: parent.width
                    spacing: 10

                    YText {
                        width: parent.width
                        height: contentHeight
                        font.family: fontManager.fontFamilyEnUs
                        font.weight: id_ParaList_table.bIsThObj ? Font.Medium : Font.Normal
                        color: id_ParaList_table.bIsThObj ? YColors.white : YColors.grayText
                        wrapMode: YTextBase.Wrap
                        textFormat: YTextBase.RichText
                        text: {
                            let vFormatted = OxfordUtilities.illTitleToFormatted(cellObj, fontManager.fontFamilyZhCn)
                            console.log("YDictTypeDtOxfordIllustrationParaTable.qml === cell_content_title vFormatted: ", vFormatted)
                            return vFormatted
                        }
                        visible: text.length > 0
                    }

                    Repeater {
                        id: id_ParaList_table_cell_content_x_repeater
                        model: {
                            var exampleListObj = cellObj.x
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
                            width: id_ParaList_table_cell_content.width
                            meanDataNgX: model.modelData
                        }
                    }
                }
            }
        }
    }
}

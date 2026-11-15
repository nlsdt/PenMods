import QtQuick 2.12

import BaseQml 1.0
import "./YDictOxfordUtilities.js" as OxfordUtilities
import "./YDictOxfordModel.js" as OxfordModel

Column {
    id: id_idiom_block_column
    width: parent.width
    spacing: 20
    property string qsPos: ""
    property var meanIdiomList: []
    property var idiomIndex: 1
    onMeanIdiomListChanged: idiomIndex = 1

    YTextMedium {
        width: parent.width
        height: contentHeight
        font.family: fontManager.fontFamilyEnUs
        font.pixelSize: 28
        color: "#E8E8E8"
        wrapMode: YTextBase.Wrap
        textFormat: YTextBase.RichText
        text: {
            var vFormattedText = ""
            let bFlag = false
            meanIdiomList.forEach(function(vObj){
                if (!bFlag && typeof vObj.cm != "undefined") {
                    console.log("YDictTypeDtOxfordDetail.qml === id_meaningblock_MbtIdiom_component render comment for idiom")
                    var vCm = vObj.cm
                    var qsEn = OxfordUtilities.htmlToFormatted(vObj.cm.content)
                    if (qsEn.length > 0) {
                        vFormattedText += qsEn
                    }
                    if (typeof vObj.cm.chn != "undefined") {
                        vFormattedText += "&nbsp;&nbsp;"
                        vFormattedText += OxfordUtilities.formatTextFontFamily(vObj.cm.chn.content, fontManager.fontFamilyZhCn)
                    }
                    bFlag = true
                }
            })
            return vFormattedText
        }
        visible: text.length > 0
    }

    Repeater {
        model: meanIdiomList

        Item {
            id: id_MbtIdiom_object_item
            width: id_idiom_block_column.width
            height: id_MbtIdiom_object_content.height
            readonly property var idiomObj: model.modelData
            readonly property var idiomId: {
                var qsId = ""
                if (OxfordUtilities.isArrayFn(idiomObj.id)) {
                    idiomObj.id.forEach(function(objIdString){
                        if (qsId.length > 0 && objIdString.length > 0) {
                            qsId += " | "
                        }
                        qsId += objIdString
                    })
                } else {
                    qsId = idiomObj.id
                }
                return qsId
            }

            YText {
                id: id_MbtIdiom_object_index
                width: 43
                topPadding: 4
                height: id_MbtIdiom_object_content.height
                anchors.left: parent.left
                font.family: fontManager.fontFamilyZhCn
                font.pixelSize: 26
                color: YColors.grayText
                visible: idiomId.length > 0
                Component.onCompleted: {
                    if (visible) {
                        text = id_idiom_block_column.idiomIndex + "."
                        id_idiom_block_column.idiomIndex += 1
                    }
                }
            }

            Column {
                id: id_MbtIdiom_object_content
                anchors.left: id_MbtIdiom_object_index.right
                anchors.right: parent.right
                spacing: 10

                YText {
                    width: parent.width
                    height: contentHeight
                    font.family: fontManager.fontFamilyEnUs
                    wrapMode: YTextBase.Wrap
                    textFormat: YTextBase.RichText
                    color: YColors.grayText
                    text: {
                        var vFormattedText = ""
                        if (idiomId.length <= 0) {
                            return vFormattedText
                        }
                        vFormattedText += OxfordUtilities.formatText(idiomId, "#FFFFFF", 500) + "&nbsp;&nbsp;"
                        vFormattedText += OxfordUtilities.grToFormatted(idiomObj, false)
                    }
                    visible: text.length > 0
                }

                YDictTypeDtOxfordIdiomNg {
                    width: id_MbtIdiom_object_content.width
                    ngObjList: idiomId.length > 0 && typeof idiomObj["n-g"] != "undefined" ? idiomObj["n-g"] : []
                    qsPosCur: id_idiom_block_column.qsPos
                }

                YLoader {
                    id: id_word_idiom_Xr_loader
                    asynchronous: false
                    readonly property int componentWidth: id_MbtIdiom_object_content.width
                    readonly property string qsPosCur: id_idiom_block_column.qsPos
                    readonly property var xrObj: idiomId.length > 0 && typeof idiomObj.xr != "undefined" ? idiomObj.xr : null
                    active: xrObj !== null
                    sourceComponent: YDictTypeDtOxfordXr{}
                }
            }
        }
    }
}

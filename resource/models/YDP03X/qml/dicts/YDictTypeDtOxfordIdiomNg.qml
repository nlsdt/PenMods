import QtQuick 2.12

import BaseQml 1.0
import "./YDictOxfordUtilities.js" as OxfordUtilities
import "./YDictOxfordModel.js" as OxfordModel

Column {
    id: id_ng_column
    width: parent.width
    spacing: 10
    property var ngObjList: []
    property string qsPosCur: ""

    Repeater {
        model: ngObjList

        Column {
            width: id_ng_column.width
            spacing: 10
            readonly property var ngObj: model.modelData

            YTextMedium {
                width: parent.width
                height: contentHeight
                font.family: fontManager.fontFamilyEnUs
                wrapMode: YTextBase.Wrap
                textFormat: YTextBase.RichText
                color: YColors.grayText
                text: OxfordUtilities.idiomNgToFormatted(ngObj, fontManager.fontFamilyZhCn)
                visible: text.length > 0
            }

            YLoader {
                id: id_word_idiom_ng_d_Xr_loader
                asynchronous: false
                readonly property int componentWidth: id_ng_column.width
                readonly property string qsPosCur: id_ng_column.qsPosCur
                readonly property var xrObj: {
                    var ngDObj = null
                    if (typeof ngObj.d != "undefined") {
                        ngDObj = ngObj.d
                    } else if (typeof ngObj.ud != "undefined") {
                        ngDObj = ngObj.ud
                    }
                    if (ngDObj !== null && typeof ngDObj.xr1 != "undefined") {
                        return ngDObj.xr1
                    }
                    return null
                }
                active: xrObj !== null
                sourceComponent: YDictTypeDtOxfordXr{}
            }

            Repeater {
                id: id_word_header_mean_ng_x_repeater
                model: {
                    var exampleListObj = ngObj.x
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
                    width: id_ng_column.width
                    meanDataNgX: model.modelData
                }
            }

            YTextMedium {
                width: parent.width
                height: contentHeight
                font.family: fontManager.fontFamilyEnUs
                color: "#FFFFFF"
                textFormat: YTextBase.RichText
                wrapMode: YTextBase.WordWrap
                text: OxfordUtilities.etymToFormatted(ngObj.etym, fontManager.fontFamilyZhCn)
                visible: text.length > 0
            }

            YLoader {
                id: id_word_idiom_ng_Xr_loader
                asynchronous: false
                readonly property int componentWidth: id_ng_column.width
                readonly property string qsPosCur: id_ng_column.qsPosCur
                readonly property var xrObj: typeof ngObj.xr != "undefined" ? ngObj.xr : null
                active: xrObj !== null
                sourceComponent: YDictTypeDtOxfordXr{}
            }

        }

    }
}

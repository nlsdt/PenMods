import QtQuick 2.12
import QtQuick.XmlListModel 2.14
import com.youdao.pen 1.0
import BaseQml 1.0
import "../i18n"
import "../../qml/timers"
import "../components"

Column{
    id: id_meanings_repeater
    width: contentWidth
    //anchors.top: parent.top
    property var queryMeanData: ""
    property var contentWidth: 496
    property var meanList: []
    property alias count: id_meanings_repe.count
//义项（释义）
Repeater{
    id: id_meanings_repe
//    property var queryMeanData: ""
//    property var contentWidth: 496
//    property var meanList: []
    model:  meanList

    YLoader {
        id: id_word_loader_component
        active: id_meanings_repeater.count
        asynchronous: false
        sourceComponent: id_word_component
        //property var modeModelData: model.modelData
    }

    Component {
        id: id_word_component
        Item {
            width: contentWidth
            height:id_meaning_column.height /*+ ((index+1) < count) ? 20 : 0*/
            Column {
                id: id_meaning_column
                anchors.left: parent.left
                anchors.right: parent.right
                property var modelModelData: model.modelData
                property var splitMeanList: []

                property bool haveMeanText: {
                    let temp = false
                    try {
                        if( JSON.stringify(id_meaning_column.modelModelData.注).length)
                            temp = true
                    } catch(e) {}

                    try {
                        if( JSON.stringify(id_meaning_column.modelModelData.释义).length)
                            temp = true
                    } catch(e) {}

                    try {
                        if( JSON.stringify(id_meaning_column.modelModelData.比喻).length)
                            temp = true
                    } catch(e) {}

                    try {
                        if( JSON.stringify(id_meaning_column.modelModelData.引申).length)
                            temp = true
                    } catch(e) {}
                    try {
                        if( JSON.stringify(id_meaning_column.modelModelData.例证).length)
                            temp = true
                    } catch(e) {}
                    return temp
                }

                YSpacingForColumn{
                    height: index!==0 && JSON.stringify(id_meaning_column.modelModelData).length ? 20 : 0
                }

                Item{
                    id: id_mean_item
                    anchors.left: parent.left
                    anchors.right: parent.right
                    height: visible ? Math.max(id_number_rectangle.height,id_mean_column.height) : 0
                    visible: id_meaning_column.haveMeanText

                    YDtTypeDtChXinHuaMeanIndexComponent {
                        id: id_number_rectangle
                        visible: JSON.stringify(model.modelData).length && id_meaning_column.haveMeanText && id_meanings_repeater.count >1
                        spliteMean:true
                    }

                    Column {
                        id: id_mean_column
                        anchors.left: id_number_rectangle.right
                        anchors.leftMargin: 18
                        anchors.top: parent.top
                        anchors.right: parent.right
                        property var curIndex: index
                        property var curDataJson: {
                            let temp = ({})
                            let tempTextData = null
                            try {
                                if(typeof id_meaning_column.modelModelData.释义 !== "undefined") {
                                    let m = {}
                                    tempTextData = id_dict_type_ch_ancientword.getAllValueString(id_meaning_column.modelModelData.释义)
                                    if(tempTextData !== null) {
                                        m["释义data"] = tempTextData
                                        temp["释义"] = m
                                    }
                                }
                            } catch(e) {}

                            try {
                                if(typeof id_meaning_column.modelModelData.释义.注 !== "undefined") {
                                    if ( typeof  temp["释义"] === "undefined")
                                        temp["释义"] = {}
                                    if ( typeof  temp["释义"]["注"] === "undefined")
                                        temp["释义"]["注"]  = {}
                                    tempTextData = id_dict_type_ch_ancientword.getAllValueString(id_meaning_column.modelModelData.释义.注)
                                    if(tempTextData !== null)
                                        temp["释义"]["注"]["meanMention"] = tempTextData
                                }
                            } catch(e) {}

                            try {
                                if(typeof id_meaning_column.modelModelData.释义.注.类型 !== "undefined") {
                                    if ( typeof temp["释义"] === "undefined")
                                        temp["释义"] = {}
                                    if ( typeof temp["释义"]["注"] === "undefined")
                                        temp["释义"]["注"]  = {}
                                    tempTextData = id_dict_type_ch_ancientword.getAllValueString(id_meaning_column.modelModelData.释义.注.类型)
                                }
                                if (tempTextData !== null)
                                    temp["释义"]["注"]["类型"] = {"meanMentionType":tempTextData}
                            } catch(e) {}

                            try {
                                if(typeof id_meaning_column.modelModelData.比喻 !== "undefined") {
                                    tempTextData = id_dict_type_ch_ancientword.getAllValueString(id_meaning_column.modelModelData.比喻)
                                    if ( typeof temp["比喻"] === "undefined")
                                    {
                                        if(tempTextData !== null)
                                            temp["比喻"] = {"比喻data":tempTextData}
                                    }
                                    else if(tempTextData !== null)
                                        temp["比喻"]["比喻data"] = tempTextData
                                }
                            } catch(e) {}

                            try {
                                if(typeof id_meaning_column.modelModelData.转化 !== "undefined") {
                                    tempTextData = id_dict_type_ch_ancientword.getAllValueString(id_meaning_column.modelModelData.转化)
                                    if ( typeof temp["转化"] === "undefined") {
                                        if(tempTextData !== null)
                                            temp["转化"] = {"转化data":tempTextData}
                                    }
                                    else if(tempTextData !== null)
                                        temp["转化"]["转化data"] = tempTextData
                                }
                            } catch(e) {}

                            try {
                                if(typeof id_meaning_column.modelModelData.引申 !== "undefined") {
                                    tempTextData = id_dict_type_ch_ancientword.getAllValueString(id_meaning_column.modelModelData.引申)
                                    if ( typeof temp["引申"] === "undefined") {
                                        if(tempTextData !== null)
                                            temp["引申"] = {"引申data":tempTextData}
                                    }
                                    else   if(tempTextData !== null)
                                        temp["引申"]["引申data"] = tempTextData
                                }
                            } catch(e) {}

                            try {
                                if(typeof id_meaning_column.modelModelData.引申.用法 !== "undefined") {
                                    tempTextData = id_dict_type_ch_ancientword.getAllValueString(id_meaning_column.modelModelData.引申.用法)
                                    if(tempTextData !== null)
                                        temp["引申"]["extendedMethod"] = {"extendedMethod":tempTextData}
                                }
                            } catch(e) {}

                            try {
                                if(typeof id_meaning_column.modelModelData.引申.释义 !== "undefined") {
                                    tempTextData = id_dict_type_ch_ancientword.getAllValueString(id_meaning_column.modelModelData.引申.释义)
                                    if(tempTextData !== null)
                                        temp["引申"]["extendedMeanData"] = {"extendedMeanData":tempTextData}
                                }
                            } catch(e) {}

                            try {
                                if(typeof id_meaning_column.modelModelData.引申.例证 !== "undefined") {
                                    tempTextData = id_dict_type_ch_ancientword.getAllValueString(id_meaning_column.modelModelData.引申.例证)
                                    if(tempTextData !== null)
                                        temp["引申"]["extendedExample"] = {"extendedExample":tempTextData}
                                }
                            } catch(e) {}

                            try {
                                if(typeof id_meaning_column.modelModelData.注 !== "undefined") {
                                    tempTextData = id_dict_type_ch_ancientword.getMenteionText(id_meaning_column.modelModelData.注)
                                    if(tempTextData !== null)
                                        temp["注"] = {"oldReading":tempTextData}
                                }
                            } catch(e) {}

                            try {
                                if(typeof id_meaning_column.modelModelData.注.SMALL !== "undefined") {
                                    tempTextData = id_dict_type_ch_ancientword.getAllValueString(id_meaning_column.modelModelData.注.SMALL)
                                    if ( typeof  temp["注"] === "undefined")
                                        temp["注"] = {}
                                    if(tempTextData !== null)
                                        temp["注"]['SMALL'] = {"mentionSmallData":tempTextData}
                                }
                            } catch(e) {}

                            try {
                                if(typeof id_meaning_column.modelModelData.例证 !== "undefined") {
                                    tempTextData = id_dict_type_ch_ancientword.getExampleText(id_meaning_column.modelModelData.例证)
                                    if(tempTextData !== null)
                                        temp["例证"] = {"例证data":tempTextData}
                                }
                            } catch(e) {}


                            try {
                                if(typeof id_meaning_column.modelModelData.引申.分义项 !== "undefined") {
                                    if ( typeof temp["引申"] === "undefined") {
                                        temp["引申"] = {}
                                    }
                                    if ( typeof temp["引申"]["分义项"] === "undefined")
                                        temp["引申"]["分义项"] = []
                                    if((id_meaning_column.modelModelData.引申.分义项).constructor === Array) {
                                        for(let i = 0; i < id_meaning_column.modelModelData.引申.分义项.length; i++)
                                            temp["引申"]["分义项"].push({"extendedMultiMean":id_meaning_column.modelModelData.引申.分义项[i]})
                                    } else {
                                        temp["引申"]["分义项"].push({"extendedMultiMean":id_meaning_column.modelModelData.引申.分义项})
                                    }
                                }
                            } catch(e) {}

                            try {
                                if(typeof id_meaning_column.modelModelData.转化.分义项 !== "undefined") {
                                    if ( typeof temp["转化"] === "undefined") {
                                        temp["转化"] = {}
                                    }
                                    if ( typeof temp["转化"]["分义项"] === "undefined")
                                        temp["转化"]["分义项"] = []
                                    if((id_meaning_column.modelModelData.引申.分义项).constructor === Array) {
                                        for(let i = 0; i < id_meaning_column.modelModelData.转化.分义项.length; i++)
                                            temp["转化"]["分义项"].push({"extendedMultiMean":id_meaning_column.modelModelData.转化.分义项[i]})
                                    } else {
                                        temp["转化"]["分义项"].push({"extendedMultiMean":id_meaning_column.modelModelData.转化.分义项})
                                    }
                                }
                            } catch(e) {}

                            try {
                                if(typeof id_meaning_column.modelModelData.分义项 !== "undefined") {
                                    if((id_meaning_column.modelModelData.分义项).constructor === Array) {
                                        id_meaning_column.splitMeanList = id_meaning_column.modelModelData.分义项
                                    } else {
                                        id_meaning_column.splitMeanList.push(id_meaning_column.modelModelData.分义项)
                                    }
                                }
                            } catch(e) {}

                            return temp

                        }

                        //（旧读fěng） 数据展示
                        YText {
                            id: id_oldReading_value
                            width: visible ? paintedWidth : 0
                            font.family: fontManager.fontFamilyXinHuaXiHei
                            font.pixelSize: 28
                            color: YColors.white
                            textFormat: Text.RichText
                            text: {
                                let textTemp = ""

                                try {
                                    //有small标签，small变小
                                    if( typeof  id_mean_column.curDataJson.注 !== "undefined") {
                                        if(typeof  id_mean_column.curDataJson.注.SMALL !== "undefined") {
                                            let smallPos = id_mean_column.curDataJson.注.oldReading.indexOf(id_mean_column.curDataJson.注.SMALL.mentionSmallData)
                                            if(smallPos !== -1) {
                                                textTemp = id_mean_column.curDataJson.注.oldReading
                                                //有注，短线变红色
                                                if(typeof  id_mean_column.curDataJson.注.oldReading.length) {
                                                    textTemp = textTemp.replace(/\s*/g,"").replace(/\-/g,'<font color="%1">-</font>'.arg(YColors.red))
                                                }

                                                if(id_mean_column.curDataJson.注.SMALL.mentionSmallData.length) {
                                                    textTemp = textTemp.replace(/:/g,"：").replace(/,/g,"，")
                                                    textTemp = textTemp.replace(new RegExp(id_mean_column.curDataJson.注.SMALL.mentionSmallData,'g') ,'<font style="font-size:22px">%1</font>'.arg(id_mean_column.curDataJson.注.SMALL.mentionSmallData.replace(/\s*/g,"")))
                                                }
                                            }

                                        }
                                    }
                                } catch(e) {
                                    console.log("id_oldReading_value text error,e:"+e)
                                    textTemp = typeof  id_mean_column.curDataJson.注 !== "undefined" ? id_mean_column.curDataJson.注.oldReading.replace(/\s*/g,"") : ""
                                }

                                return textTemp
                            }
                            visible: text.length
                        }

                        YSpacingForColumn {
                            height: 16
                            visible: id_meanings_repeater.count && id_mean_item.visible && id_oldReading_value.visible
                        }

                        Flow {
                            id: id_word_mean_flow
                            anchors.left: parent.left
                            width: id_meanings_repeater.contentWidth
                            property var firstMean: ""
                            property var nextMean: ""
                            property bool showCircleRectangle: false
                            property var maoHaoPos: -1

                            YDtTypeDtChXinHuaMeanTextComponent {
                                id: id_mean_text
                            }
                            Item {
                                width: 26
                                height: 37
                                visible: id_word_mean_flow.showCircleRectangle
                                Rectangle {
                                    id: id_connectData_rectangle
                                    height: 26
                                    width: 26
                                    radius: 30
                                    color: YColors.transparent
                                    border.color: YColors.grayText
                                    anchors.top: parent.top
                                    anchors.topMargin: 6
                                    //anchors.verticalCenter: parent.verticalCenter
                                    visible: id_word_mean_flow.showCircleRectangle

                                    YText {
                                        id: id_connectData_text
                                        anchors.centerIn: parent
                                        color: YColors.grayText
                                        font.family: fontManager.fontFamilyXinHuaXiHei
                                        font.pixelSize: 20
                                        text: YTranslateText.connectFont
                                    }
                                }
                            }

                            Repeater {
                                model: {
                                    let modelTemp = []
                                    id_word_mean_flow.maoHaoPos = -1
                                    try {
                                        for(let i = 0; i < id_word_mean_flow.nextMean.length; i++) {
                                            modelTemp.push(id_word_mean_flow.nextMean[i])
                                        }

                                        let maoHaoPos = id_word_mean_flow.nextMean.indexOf(":")
                                        if(maoHaoPos === -1) {
                                            maoHaoPos = id_word_mean_flow.nextMean.indexOf("：")
                                        }

                                        id_word_mean_flow.maoHaoPos = maoHaoPos

                                    } catch(e) {}

                                    return modelTemp
                                }
                                YText {
                                    id: id_next_mean_text
                                    width: visible ? (Math.min(id_meanings_repeater.contentWidth, paintedWidth))  : 0
                                    font.family: fontManager.fontFamilyXinHuaXiHei
                                    verticalAlignment: Text.AlignTop
                                    font.pixelSize: 28
                                    color:  (id_word_mean_flow.maoHaoPos !==-1 ? (index > id_word_mean_flow.maoHaoPos ? YColors.grayText : YColors.white) : YColors.white)
                                    wrapMode: paintedWidth > id_meanings_repeater.contentWidth ? YText.WordWrap : YText.NoWrap
                                    textFormat: YText.RichText
                                    text: {
                                        let textTemp = model.modelData
                                        if(textTemp !== " ")
                                            textTemp = id_dict_type_ch_ancientword.getMeanRichText(textTemp)
                                        textTemp = textTemp.replace(/\|/g," |  ")
                                        //有注，短线变红色
                                        if(id_mean_column.curDataJson["释义"]["注"]['meanMention'].length) {

                                            textTemp = textTemp.replace(/\-/g,'<font color="%1">-</font>'.arg(YColors.red))
                                        }
                                        if(index === 0 ) textTemp = "&nbsp;" + textTemp
                                        try {
                                            if(textTemp[0] === " ") {
                                                textTemp = "&nbsp;" + textTemp.substr(1)
                                            }
                                            let maoHaoPos = textTemp.indexOf(":")
                                            if(maoHaoPos === -1) {
                                                maoHaoPos = textTemp.indexOf("：")
                                            }
                                            if(maoHaoPos !== -1) {
                                                textTemp =  textTemp.slice(0,maoHaoPos+1)+""
                                            }

                                            let rightParentThesesPos = textTemp.indexOf(")")
                                            if(rightParentThesesPos !== -1)
                                                textTemp = textTemp.substr(0,rightParentThesesPos)+ "&nbsp;" + textTemp.substr(rightParentThesesPos)+ " "

                                        } catch(e) {}

                                        textTemp = textTemp.replace(/:/g,"：").replace(/,/g,"，")
                                        return  textTemp
                                    }
                                    visible: text.length
                                }
                            }

                        }

                        YSpacingForColumn {
                            height: 8
                            visible: id_likeData_row.visible
                        }
                        //比喻
                        Row{
                            id: id_likeData_row
                            anchors.left: parent.left
                            anchors.right: parent.right
                            visible: typeof id_mean_column.curDataJson.比喻 !== "undefined" &&  id_mean_column.curDataJson.比喻.比喻data.length
                            Rectangle {
                                id: id_likeData_rectangle
                                height: 26
                                width: 26
                                radius: 30
                                color: YColors.transparent
                                border.color: YColors.grayText
                                anchors.top: parent.top
                                anchors.topMargin: 6
                                //anchors.verticalCenter: parent.verticalCenter
                                visible: id_likeData_mean.visible

                                YText {
                                    id: id_likeData_text
                                    anchors.centerIn: parent
                                    color: YColors.grayText
                                    font.family: fontManager.fontFamilyXinHuaXiHei
                                    font.pixelSize: 20
                                    text: YTranslateText.likeFont
                                }
                            }

                            Item{
                                id: id_likeData_item_space
                                width: 8
                                height: id_likeData_rectangle.height
                                visible: id_likeData_mean.visible
                            }

                            YText {
                                id: id_likeData_mean
                                anchors.verticalCenter: parent.verticalCenter
                                width: id_meanings_repeater.contentWidth-26-8
                                font.family: fontManager.fontFamilyXinHuaXiHei
                                font.pixelSize: 28
                                color: YColors.grayText
                                textFormat: Text.RichText
                                wrapMode: Text.WordWrap
                                visible: text.length
                                text: id_dict_type_ch_ancientword.getMeanRichText(
                                          typeof id_mean_column.curDataJson.比喻 !== "undefined" ? id_mean_column.curDataJson.比喻.比喻data : "") .replace(/:/g,"：").replace(/,/g,"，")
                            }

                        }

                        YSpacingForColumn {
                            height: 8
                            visible: id_extended_row.visible
                        }

                        //引申
                        Row{
                            id: id_extended_row
                            property bool visibleSet: typeof id_mean_column.curDataJson.引申 !== "undefined" && id_mean_column.curDataJson.引申.引申data.length
                            anchors.left: parent.left
                            anchors.right: parent.right
                            visible: id_extended_row.visibleSet
                            //height: id_extended_means.height
                            Rectangle {
                                id: id_extended_rectangle
                                height: 26
                                width: 26
                                radius: 30
                                color: YColors.transparent
                                border.color: YColors.grayText
                                anchors.top: parent.top
                                anchors.topMargin: 6
                                visible: typeof id_mean_column.curDataJson.引申 !== "undefined"

                                YText {
                                    id: id_extended_text
                                    anchors.centerIn: parent
                                    color: YColors.grayText
                                    font.family: fontManager.fontFamilyXinHuaXiHei
                                    font.pixelSize: 20
                                    text: YTranslateText.extended
                                }
                            }

                            Item{
                                width: 8
                                height: id_extended_rectangle.height
                                visible: id_extended_rectangle.visible
                            }



                            Column {
                                id: id_extended_means
                                //                            anchors.top: parent.top
                                //                            anchors.bottom: parent.bottom

                                //引申后还有释义，例证
                                YText {
                                    id: id_extended_mean
                                    font.family: fontManager.fontFamilyXinHuaXiHei
                                    font.pixelSize: 28
                                    color: YColors.grayText
                                    visible: text.length
                                    Component.onCompleted: {
                                        if(paintedWidth > id_meanings_repeater.contentWidth) {
                                            width = id_meanings_repeater.contentWidth
                                            wrapMode = YText.WordWrap
                                        }
                                        else {
                                            width = paintedWidth
                                            wrapMode = YText.NoWrap
                                        }
                                    }

                                    onTextChanged: {
                                        if(paintedWidth > id_meanings_repeater.contentWidth) {
                                            width = id_meanings_repeater.contentWidth
                                            wrapMode = YText.WordWrap
                                        }
                                        else {
                                            width = paintedWidth
                                            wrapMode = YText.NoWrap
                                        }
                                    }
                                    text: typeof id_mean_column.curDataJson.引申 !== "undefined" && typeof id_mean_column.curDataJson.引申.extendedMethod  !== "undefined" ? id_mean_column.curDataJson.引申.extendedMethod.extendedMethod.replace(/:/g,"：").replace(/,/g,"，") : ""
                                }

                                YSpacingForColumn {
                                    id: id_extended_mean_means_space
                                    height: 8
                                    visible: id_extended_mean.visible
                                }

                                YText {
                                    id: id_extendedMean_mean
                                    font.family: fontManager.fontFamilyXinHuaXiHei
                                    font.pixelSize: 28
                                    color: YColors.grayText
                                    textFormat: Text.RichText
                                    Component.onCompleted: {
                                        if(paintedWidth > id_meanings_repeater.contentWidth) {
                                            width = id_meanings_repeater.contentWidth
                                            wrapMode = YText.WordWrap
                                        }
                                        else {
                                            width = paintedWidth
                                            wrapMode = YText.NoWrap
                                        }
                                    }

                                    onTextChanged: {
                                        if(paintedWidth > id_meanings_repeater.contentWidth) {
                                            width = id_meanings_repeater.contentWidth
                                            wrapMode = YText.WordWrap
                                        }
                                        else {
                                            width = paintedWidth
                                            wrapMode = YText.NoWrap
                                        }
                                    }

                                    visible: text.length
                                    text: {
                                        let textTemp = ""
                                        try{
                                            textTemp = ((typeof id_mean_column.curDataJson["引申"] !== "undefined" &&
                                                         typeof id_mean_column.curDataJson["引申"]["extendedMeanData"] !== "undefined") ?
                                                            id_mean_column.curDataJson["引申"]["extendedMeanData"].extendedMeanData.replace(/\s*/g,"") : '') +
                                                    id_dict_type_ch_ancientword.getMeanRichText(((typeof id_mean_column.curDataJson["引申"] !== "undefined" &&
                                                                                                  typeof id_mean_column.curDataJson["引申"]["extendedExample"].extendedExample !== "undefined") ?
                                                                                                     id_mean_column.curDataJson["引申"]["extendedExample"].extendedExample.replace(/\s*/g,"") : ''))
                                        } catch(e) { console.log("YDictTypeDtChXinHuaMeanComponent.qml===id_extendedMean_mean_text_error,e:"+e) }
                                        textTemp = textTemp.replace(/:/g,"：").replace(/,/g,"，")
                                        return textTemp
                                    }
                                }

                                YSpacingForColumn {
                                    id: id_extended_means_space
                                    height: 8
                                    visible: id_extendedMean_mean.visible && id_extended_means_text.count
                                }

                                Repeater {
                                    id: id_extended_means_text
                                    model: typeof id_mean_column.curDataJson.引申 !== "undefined" && typeof id_mean_column.curDataJson.引申.分义项  !== "undefined" ? id_mean_column.curDataJson.引申.分义项 : []
                                    Item {
                                        id: id_extended_means_item
                                        anchors.left: parent.left
                                        //anchors.right: parent.right
                                        width: id_extended_means_index_text.width + id_extended_mean_text.width + id_extended_mean_text.anchors.leftMargin
                                        height: Math.max(id_extended_means_index_text.height,id_extended_mean_text.height)

                                        YText {
                                            id: id_extended_means_index_text
                                            anchors.left: parent.left
                                            font.family: fontManager.fontFamilyXinHuaXiHei
                                            font.pixelSize: 28
                                            color: YColors.grayText
                                            visible: text.length && id_extended_mean_text.visible
                                            text: {
                                                return (index+1)+'.'
                                            }
                                        }

                                        YText {
                                            id: id_extended_mean_text
                                            anchors.left: id_extended_means_index_text.right
                                            anchors.leftMargin: 18
                                            font.family: fontManager.fontFamilyXinHuaXiHei
                                            font.pixelSize: 28
                                            wrapMode: YText.WordWrap
                                            width: 467
                                            color: YColors.grayText
                                            textFormat: YText.RichText
                                            visible: text.length
                                            text: {
                                                return id_dict_type_ch_ancientword.getMeanRichText( typeof model.modelData.extendedMultiMean !== "undefined" ? model.modelData.extendedMultiMean : '').replace(/:/g,"：").replace(/,/g,"，")
                                            }
                                        }

                                    }
                                }

                            }

                        }

                    }
                }

                YSpacingForColumn {
                    height: 8
                    visible: id_split_word_rectangle_repeater.count && id_meaning_column.haveMeanText
                }

                //分义项
                YDictTypeDtChXinHuaShowMeanAndExampleComponent {
                    id: id_split_word_rectangle_repeater
                    contentWidth: id_meanings_repeater.contentWidth
                    meanList: id_meaning_column.splitMeanList
                    //[testJson.义项[index].分义项]
                    queryMeanData: {
                        return id_meanings_repeater.queryMeanData + "["+(id_mean_column.curIndex+1)+"]"+"/分义项"
                    }
                }
            }
        }
    }
}

}


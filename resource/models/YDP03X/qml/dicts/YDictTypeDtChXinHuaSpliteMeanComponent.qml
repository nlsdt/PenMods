import QtQuick 2.12
import QtQuick.XmlListModel 2.14
import com.youdao.pen 1.0
import BaseQml 1.0
import "../i18n"
import "../../qml/timers"
import "../components"


//义项（释义）
Repeater{
    id: id_meanings_repeater
    property var queryMeanData: ""
    property var contentWidth: 538
    property var meanList: []
    model: meanList

    Item {
        //anchors.left: parent.left
        //anchors.right: parent.right
        width: contentWidth
        height:id_meaning_column.height /*+ ((index+1) < count) ? 20 : 0*/
        Column {
            id: id_meaning_column
            anchors.left: parent.left
            anchors.right: parent.right
            property var splitMeanList: []
            property var splitWordMeanList: []
            property var modelModelData: model.modelData
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
                height:  visible ? Math.max(id_number_rectangle.height,id_mean_column.height) : 0
                visible: id_meaning_column.haveMeanText || id_meaning_column.splitWordMeanList.length

                YDtTypeDtChXinHuaMeanIndexComponent {
                    id: id_number_rectangle
                    spliteMean:true
                }

                Column {
                    id: id_mean_column
                    anchors.left: id_number_rectangle.right
                    anchors.leftMargin: 18
                    anchors.top: parent.top
                    anchors.right: parent.right
                    property var curIndex: index
                    property var widthColumn: id_meanings_repeater.contentWidth -  id_mean_column.anchors.leftMargin - id_number_rectangle.width
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
                                if(tempText !== null)
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

                        try {
                            if(typeof id_meaning_column.modelModelData.词目 !== "undefined") {
                                if((id_meaning_column.modelModelData.词目).constructor === Array) {
                                    id_meaning_column.splitWordMeanList = id_meaning_column.modelModelData.词目
                                } else {
                                    id_meaning_column.splitWordMeanList.push(id_meaning_column.modelModelData.词目)
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

//                    //获取释义
//                    XmlListModel{
//                        id:id_get_meanings_mean
//                        property var curSearchPinYinIndex: 0
//                        xml: dictSelectParaphrasesXml
//                        query: queryMeanData + "["+(id_mean_column.curIndex+1)+"]"
//                        //释义
//                        XmlRole { name: "meaning"; query: "释义"+"/string()"
//                        }
//                        //释义/注
//                        XmlRole { name: "meanMention"; query: "释义/注"+"/string()"
//                        }
//                        //释义/注/类型
//                        XmlRole { name: "meanMentionType"; query: "释义/注/@类型"+"/string()"
//                        }
//                        //比喻
//                        XmlRole { name: "likeData"; query: "比喻"+"/string()" }
//                        //转化
//                        XmlRole { name: "transformData"; query: "转化"+"/string()" }
//                        //释义下的例证
//                        XmlRole { name: "meanExample"; query: "例证"+"/string()" }
//                        //引申
//                        XmlRole { name: "extended"; query: "引申"+"/string()" }
//                        //引申用法
//                        XmlRole { name: "extendedMethod"; query: "引申/用法"+"/string()" }
//                        //引申释义
//                        XmlRole { name: "extendedMeanData"; query: "引申/释义"+"/string()" }
//                        //引申例证
//                        XmlRole { name: "extendedExample"; query: "引申/例证"+"/string()" }
//                        //旧读（注）
//                        XmlRole { name: "oldReading"; query: "注"+"/string()" }
//                        //（注/SMALL）
//                        XmlRole { name: "mentionSmallData"; query: "注/SMALL"+"/string()" }

//                        onStatusChanged: {
//                            if(status == XmlListModel.Ready && count > 0)
//                            {
//                                if(id_get_meanings_mean.get(0).meaning){
//                                    let m = {}
//                                    m["释义data"] = id_get_meanings_mean.get(0).meaning
//                                    id_mean_column.curDataJson["释义"] = m
//                                }
//                                //释义/注
//                                if(id_get_meanings_mean.get(0).meanMention){
//                                    if ( typeof  id_mean_column.curDataJson["释义"] === "undefined")
//                                        id_mean_column.curDataJson["释义"] = {}
//                                    if ( typeof  id_mean_column.curDataJson["释义"]["注"] === "undefined")
//                                        id_mean_column.curDataJson["释义"]["注"]  = {}
//                                    id_mean_column.curDataJson["释义"]["注"]["meanMention"] = id_get_meanings_mean.get(0).meanMention
//                                }

//                                //释义/注/类型
//                                if(id_get_meanings_mean.get(0).meanMentionType){
//                                    if ( typeof  id_mean_column.curDataJson["释义"] === "undefined")
//                                        id_mean_column.curDataJson["释义"] = {}
//                                    if ( typeof  id_mean_column.curDataJson["释义"]["注"] === "undefined")
//                                        id_mean_column.curDataJson["释义"]["注"]  = {}
//                                    id_mean_column.curDataJson["释义"]["注"]["类型"] = {"meanMentionType":id_get_meanings_mean.get(0).meanMentionType}
//                                }

//                                if(id_get_meanings_mean.get(0).likeData){
//                                    if ( typeof id_mean_column.curDataJson["比喻"] === "undefined")
//                                        id_mean_column.curDataJson["比喻"] = {"比喻data":id_get_meanings_mean.get(0).likeData}
//                                    else
//                                        id_mean_column.curDataJson["比喻"]["比喻data"] = id_get_meanings_mean.get(0).likeData
//                                }

//                                if(id_get_meanings_mean.get(0).transformData){
//                                    if ( typeof id_mean_column.curDataJson["转化"] === "undefined")
//                                        id_mean_column.curDataJson["转化"] = {"转化data":id_get_meanings_mean.get(0).transformData}
//                                    else
//                                        id_mean_column.curDataJson["转化"]["转化data"] = id_get_meanings_mean.get(0).transformData
//                                }

//                                if(id_get_meanings_mean.get(0).extended){
//                                    if ( typeof id_mean_column.curDataJson["引申"] === "undefined")
//                                        id_mean_column.curDataJson["引申"] = {"引申data":id_get_meanings_mean.get(0).extended}
//                                    else
//                                        id_mean_column.curDataJson["引申"]["引申data"] = id_get_meanings_mean.get(0).extended
//                                }
//                                if(id_get_meanings_mean.get(0).extendedMethod){
//                                    id_mean_column.curDataJson["引申"]["extendedMethod"] = {"extendedMethod":id_get_meanings_mean.get(0).extendedMethod}
//                                }

//                                if(id_get_meanings_mean.get(0).extendedMeanData){
//                                    id_mean_column.curDataJson["引申"]["extendedMeanData"] = {"extendedMeanData":id_get_meanings_mean.get(0).extendedMeanData}
//                                }

//                                if(id_get_meanings_mean.get(0).extendedExample){
//                                    id_mean_column.curDataJson["引申"]["extendedExample"] = {"extendedExample":id_get_meanings_mean.get(0).extendedExample}
//                                }

//                                //注
//                                if(id_get_meanings_mean.get(0).oldReading){
//                                    id_mean_column.curDataJson["注"] = {"oldReading":id_get_meanings_mean.get(0).oldReading}
//                                }
//                                //注/small
//                                if(id_get_meanings_mean.get(0).oldReading){
//                                    if ( typeof  id_mean_column.curDataJson["注"] === "undefined")
//                                        id_mean_column.curDataJson["注"] = {}
//                                    id_mean_column.curDataJson["注"]['SMALL'] = {"mentionSmallData":id_get_meanings_mean.get(0).mentionSmallData}
//                                }


//                                if(id_get_meanings_mean.get(0).meanExample){
//                                    id_mean_column.curDataJson["例证"] = {"例证data":id_get_meanings_mean.get(0).meanExample}
//                                }
//                                let temp = id_mean_column.curDataJson
//                                id_mean_column.curDataJson = []
//                                id_mean_column.curDataJson = temp
//                            }
//                        }
//                    }

//                    //获取引申分义项
//                    XmlListModel{
//                        id:id_get_extend_meanings_mean
//                        property var curSearchPinYinIndex: 0
//                        xml: dictSelectParaphrasesJson
//                        query: queryMeanData+"["+(id_mean_column.curIndex+1)+"]"+"/引申/分义项"
//                        //引申分义项
//                        XmlRole { name: "extendedMultiMean"; query: "string()" }
//                        onStatusChanged: {
//                            if(status == XmlListModel.Ready && count > 0)
//                            {
//                                for(let i = 0; i < count; i++) {
//                                    if(id_get_extend_meanings_mean.get(i).extendedMultiMean){
//                                        if ( typeof id_mean_column.curDataJson["引申"] === "undefined") {
//                                            id_mean_column.curDataJson["引申"] = {}
//                                        }
//                                        if ( typeof id_mean_column.curDataJson["引申"]["分义项"] === "undefined")
//                                            id_mean_column.curDataJson["引申"]["分义项"] = []
//                                        id_mean_column.curDataJson["引申"]["分义项"].push({"extendedMultiMean":id_get_extend_meanings_mean.get(i).extendedMultiMean})
//                                    }
//                                }
//                                let temp = id_mean_column.curDataJson
//                                id_mean_column.curDataJson = []
//                                id_mean_column.curDataJson = temp
//                                //id_mean_text.text = id_mean_column.getMeanRichText()
//                            }
//                        }
//                    }

//                    //转化分义项
//                    XmlListModel{
//                        id:id_get_transform_meanings_mean
//                        property var curSearchPinYinIndex: 0
//                        xml: dictSelectParaphrasesJson
//                        query: queryMeanData + "["+(id_mean_column.curIndex+1)+"]"+"/转化/分义项"
//                        //引申分义项
//                        XmlRole { name: "transformMultiMean"; query: "string()" }
//                        onStatusChanged: {
//                            if(status == XmlListModel.Ready && count > 0)
//                            {
//                                for(let i = 0; i < count; i++) {
//                                    if(id_get_transform_meanings_mean.get(i).transformMultiMean){
//                                        if ( typeof id_mean_column.curDataJson["转化"] === "undefined") {
//                                            id_mean_column.curDataJson["转化"] = {}
//                                        }
//                                        if ( typeof id_mean_column.curDataJson["转化"]["分义项"] === "undefined")
//                                            id_mean_column.curDataJson["转化"]["分义项"] = []
//                                        id_mean_column.curDataJson["转化"]["分义项"].push({"transformMultiMean":id_get_transform_meanings_mean.get(i).transformMultiMean})
//                                    }
//                                }
//                                let temp = id_mean_column.curDataJson
//                                id_mean_column.curDataJson = []
//                                id_mean_column.curDataJson = temp
//                            }
//                        }
//                    }

//                    //分义项
//                    XmlListModel {
//                        id:id_wordList_listmodel
//                        xml: dictSelectParaphrasesJson
//                        query: id_meanings_repeater.queryMeanData + "["+(id_mean_column.curIndex+1)+"]"+"/词目"
//                        XmlRole { name: "posNumber"; query: "string()" }
//                        onStatusChanged: {
//                            if(status == XmlListModel.Ready && count > 0)
//                            {
//                                for(let i = 0; i < count; i++) {
//                                    id_meaning_column.splitMeanList.push(i)
//                                }
//                                let temp = id_meaning_column.splitMeanList
//                                id_meaning_column.splitMeanList = []
//                                id_meaning_column.splitMeanList = temp
//                            }
//                        }
//                    }

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
                            id: id_likeData_item
                            width: 8
                            height: id_likeData_rectangle.height
                            visible: id_likeData_mean.visible
                        }

                        YDictTypeDtChXinHuaExtendMeanComponent{
                            id:id_likeData_mean
                            contentWidth: id_mean_column - (id_likeData_rectangle.width + id_likeData_item.width)
                            meanList: {
                                let temp = []
                                try {
                                    if((id_meaning_column.modelModelData.比喻).constructor === Array)
                                        temp = id_meaning_column.modelModelData.比喻
                                    else {
                                        temp.push(id_meaning_column.modelModelData.比喻)
                                    }
                                } catch(e) {
                                }
                                return temp
                            }
                            queryMeanData: "/字目/释文/义项/比喻"
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
                            id: id_extended_rectangle_item
                            width: 8
                            height: id_extended_rectangle.height
                            visible: id_extended_rectangle.visible
                        }

                        YDictTypeDtChXinHuaExtendMeanComponent{
                            id:id_extend_meanings_repeater
                            contentWidth: id_mean_column.widthColumn - (id_extended_rectangle.width + id_extended_rectangle_item.width)
                            meanList: {
                                let temp = []
                                try {
                                    if((id_meaning_column.modelModelData.引申).constructor === Array)
                                        temp = id_meaning_column.modelModelData.引申
                                    else {
                                        temp.push(id_meaning_column.modelModelData.引申)
                                    }
                                } catch(e) {
                                }
                                return temp
                            }
                            queryMeanData: "/字目/释文/义项/引申"
                        }

                    }

                    YSpacingForColumn {
                        height: 8
                        visible: id_word_rectangle_repeater.count
                    }

                    YDictTypeDtChXinHuaWordsComponent{
                        id: id_word_rectangle_repeater
                        contentWidth: id_meanings_repeater.contentWidth
                        modelList: id_meaning_column.splitWordMeanList
                        queryData: {
                            return id_meanings_repeater.queryMeanData + "["+(id_mean_column.curIndex+1)+"]"+"/词目"
                        }
                    }
                }
            }

            YSpacingForColumn {
                height: 8
                visible: id_transform_row.visible && id_meaning_column.haveMeanText
            }
            //转化
            Row{
                id: id_transform_row
                anchors.left: parent.left
                anchors.right: parent.right
                visible: typeof id_mean_column.curDataJson.转化 !== "undefined" &&  id_transformData_repeater.count
                Rectangle {
                    id: id_transformData_rectangle
                    height: 26
                    width: 26
                    radius: 30
                    color: YColors.transparent
                    border.color: YColors.grayText
                    anchors.top: parent.top
                    anchors.topMargin: 6
                    visible: id_transformData_repeater.count

                    YText {
                        id: id_transformData_key_text
                        anchors.centerIn: parent
                        color: YColors.grayText
                        font.family: fontManager.fontFamilyXinHuaXiHei
                        font.pixelSize: 20
                        text: YTranslateText.transformData
                    }
                }

                Item{
                    id: id_item_space
                    width: 18
                    height: id_transformData_rectangle.height
                    visible: {
                        return  id_transformData_repeater.count
                    }
                }

                YDictTypeDtChXinHuaExtendMeanComponent{
                    id:id_transformData_repeater
                    contentWidth: id_word_rectangle_repeater.contentWidth - (id_transformData_rectangle.width + id_item_space.width)
                    meanList: {
                        let temp = []
                        try {
                            if((id_meaning_column.modelModelData.转化).constructor === Array)
                                temp = id_meaning_column.modelModelData.转化
                            else {
                                temp.push(id_meaning_column.modelModelData.转化)
                            }
                        } catch(e) {
                        }
                        return temp
                    }
                    queryMeanData: "/字目/释文/义项/转化"
                }
            }
        }
    }
}




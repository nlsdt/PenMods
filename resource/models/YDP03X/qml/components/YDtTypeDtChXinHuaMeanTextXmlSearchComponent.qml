import QtQuick 2.12
import QtQuick.XmlListModel 2.14
import com.youdao.pen 1.0
import BaseQml 1.0
import "../i18n"
import "../../qml/timers"
import "../components"


//获取释义
XmlListModel{
    id:id_get_meanings_mean
    property var curSearchPinYinIndex: id_mean_column.curIndex+1
    property var needSetProperty: needSetProperty
    property var xmlString: dictSelectParaphrasesXml
    xml: xmlString
    query: queryMeanData + "["+(curSearchPinYinIndex)+"]"
    //释义
    XmlRole { name: "meaning"; query: "释义"+"/string()"
    }
    //释义/注
    XmlRole { name: "meanMention"; query: "释义/注"+"/string()"
    }
    //释义/注/类型
    XmlRole { name: "meanMentionType"; query: "释义/注/@类型"+"/string()"
    }
    //                        //比喻
    //                        XmlRole { name: "likeData"; query: "比喻"+"/string()" }
    //                        //转化
    //                        XmlRole { name: "transformData"; query: "转化"+"/string()" }
    //释义下的例证
    XmlRole { name: "meanExample"; query: "例证"+"/string()" }
    //                        //引申
    //                        XmlRole { name: "extended"; query: "引申"+"/string()" }
    //                        //引申用法
    XmlRole { name: "extendedMethod"; query: "引申/用法"+"/string()" }
    //引申释义
    XmlRole { name: "extendedMeanData"; query: "引申/释义"+"/string()" }
    //引申例证
    XmlRole { name: "extendedExample"; query: "引申/例证"+"/string()" }
    //旧读（注）
    XmlRole { name: "oldReading"; query: "注"+"/string()" }
    //（注/SMALL）
    XmlRole { name: "mentionSmallData"; query: "注/SMALL"+"/string()" }

    onStatusChanged: {
        if(status == XmlListModel.Ready && count > 0)
        {
            if(id_get_meanings_mean.get(0).meaning){
                let m = {}
                m["释义data"] = id_get_meanings_mean.get(0).meaning
                needSetProperty["释义"] = m
            }
            //释义/注
            if(id_get_meanings_mean.get(0).meanMention){
                if ( typeof  needSetProperty["释义"] === "undefined")
                    needSetProperty["释义"] = {}
                if ( typeof  needSetProperty["释义"]["注"] === "undefined")
                    needSetProperty["释义"]["注"]  = {}
                needSetProperty["释义"]["注"]["meanMention"] = id_get_meanings_mean.get(0).meanMention
            }

            //释义/注/类型
            if(id_get_meanings_mean.get(0).meanMentionType){
                if ( typeof  needSetProperty["释义"] === "undefined")
                    needSetProperty["释义"] = {}
                if ( typeof  needSetProperty["释义"]["注"] === "undefined")
                    needSetProperty["释义"]["注"]  = {}
                needSetProperty["释义"]["注"]["类型"] = {"meanMentionType":id_get_meanings_mean.get(0).meanMentionType}
            }

            if(id_get_meanings_mean.get(0).likeData){
                if ( typeof needSetProperty["比喻"] === "undefined")
                    needSetProperty["比喻"] = {"比喻data":id_get_meanings_mean.get(0).likeData}
                else
                    needSetProperty["比喻"]["比喻data"] = id_get_meanings_mean.get(0).likeData
            }

            if(id_get_meanings_mean.get(0).transformData){
                if ( typeof needSetProperty["转化"] === "undefined")
                    needSetProperty["转化"] = {"转化data":id_get_meanings_mean.get(0).transformData}
                else
                    needSetProperty["转化"]["转化data"] = id_get_meanings_mean.get(0).transformData
            }

            if(id_get_meanings_mean.get(0).extended){
                if ( typeof needSetProperty["引申"] === "undefined")
                    needSetProperty["引申"] = {"引申data":id_get_meanings_mean.get(0).extended}
                else
                    needSetProperty["引申"]["引申data"] = id_get_meanings_mean.get(0).extended
            }
            if(id_get_meanings_mean.get(0).extendedMethod){
                needSetProperty["引申"]["extendedMethod"] = {"extendedMethod":id_get_meanings_mean.get(0).extendedMethod}
            }

            if(id_get_meanings_mean.get(0).extendedMeanData){
                needSetProperty["引申"]["extendedMeanData"] = {"extendedMeanData":id_get_meanings_mean.get(0).extendedMeanData}
            }

            if(id_get_meanings_mean.get(0).extendedExample){
                needSetProperty["引申"]["extendedExample"] = {"extendedExample":id_get_meanings_mean.get(0).extendedExample}
            }

            //注
            if(id_get_meanings_mean.get(0).oldReading){
                needSetProperty["注"] = {"oldReading":id_get_meanings_mean.get(0).oldReading}
            }
            //注/small
            if(id_get_meanings_mean.get(0).oldReading){
                if ( typeof  needSetProperty["注"] === "undefined")
                    needSetProperty["注"] = {}
                needSetProperty["注"]['SMALL'] = {"mentionSmallData":id_get_meanings_mean.get(0).mentionSmallData}
            }


            if(id_get_meanings_mean.get(0).meanExample){
                needSetProperty["例证"] = {"例证data":id_get_meanings_mean.get(0).meanExample}
            }
            let temp = needSetProperty
            needSetProperty = []
            needSetProperty = temp
            //id_mean_text.text = id_mean_column.getMeanRichText()
        }
    }
}







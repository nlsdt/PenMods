import QtQuick 2.12
import com.youdao.pen 1.0

import BaseQml 1.0
import "../components"
import "../i18n"

YPage {
    anchors.fill: parent
    property bool currentPageEnabled: true
    property string currentSelectedTitle: "英语"
    YVerticalTitleBar {
        id: id_title_bar
        onCallBack: {
            backButtonClicked();
        }
    }
    property var asrTypeDataJson: {
        "英语" : [{"title" : "翻译",
                  "arr" : ["翻译今天天气很好", "翻译 I eat an apple"]},
                {"title" : "单词",
                 "arr" : ["苹果用英文怎么说", "apple是什么意思", "take的过去式", "take有哪些固定搭配", "take的同根词", "b-i-g是什么意思", "用apple造句","含有apple的短语"]}],

        "语文" : [{"title" : "拼音",
                    "arr" : ["快乐的乐的拼音","五颜六色的拼音"]},
                  {"title" : "汉字",
                   "arr" : ["快乐的快是什么结构","快乐的快笔画有多少","快乐的快是什么意思","快乐的快部首是什么","三点水右边一个可是什么字","三个口是什么字"]},
                {"title" : "组词造句",
                 "arr" : ["用快乐的乐字组词","用快乐造句"]},
                {"title" : "词语成语",
                 "arr" : ["念念不忘是什么意思","五颜六色的近义词","用五颜六色造句","含有春字的成语","描写春天的成语"]},
                {"title" : "古诗文",
                 "arr" : ["背诵静夜思","白居易的诗","《静夜思》的作者","天生丽质难自弃的作者","介绍一下白居易","天生丽质难自弃的下一句","描写春天的诗句","含有花字的诗句"]}

                ],

        "数学" : [{"title" : "口算",
                    "arr" : ["3+2等于几"]},
                  {"title" : "单位换算",
                   "arr" : ["1米等于多少厘米"]}],

        "功能控制" : [{"title" : "",
                      "arr" : ["声音大一点","调高亮度"]},
                   ],

        "生活助手" : [{"title" : "",
                      "arr" : ["今天几月几号","现在几点了","北京今天的天气"] }]
    }

    Flickable {
        width: parent.width
        anchors.top: parent.top
        anchors.topMargin: 20
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.leftMargin: 80
        anchors.rightMargin: 60
        contentHeight:id_tbale_content_bg_colum.height
        Column {
            id: id_tbale_content_bg_colum
            width: parent.width
            YTabsTitleBar {
                id: id_tab_title_bar
                width: parent.width
                height: 60
                selectColor:"#43A5FF"
                namesArray: ["英语", "语文","数学","功能控制","生活助手"]
                onCurrentIndexChanged: {
                    currentSelectedTitle = namesArray[currentIndex]
                }
            }
            YSpacingForColumn {
                implicitHeight: 8
            }

            Repeater {
                id: id_list_repeater
                width: parent.width
                model: asrTypeDataJson[currentSelectedTitle]//[1,2,3,4]
                Column {
                    width: parent.width
                    Rectangle {
                        id: id_content_rectangle
                        width: parent.width
                        height: id_content_colum.height
                        color: "#000000"
                        radius: 16
                        Column {
                            id: id_content_colum
                            width: parent.width
                            Rectangle {
                                id:titlerect
                                width: parent.width
                                height: 26 + 16 * 2
                                color: "transparent"
                                visible: id_list_repeater.model[index].title === "" ? false:true
                                Rectangle {
                                    id: id_status_title_ranctale
                                    anchors.left: parent.left
                                    anchors.leftMargin: 30
                                    y: (parent.height - height) / 2
                                    width: 4
                                    height: 16
                                    color: "#43A5FF"
                                    radius: height / 2
                                }
                                YText {
                                    id:titletext
                                    anchors.left: id_status_title_ranctale.right
                                    anchors.leftMargin: 8
                                    anchors.top: parent.top
                                    anchors.topMargin: 16
                                    height: 26
                                    verticalAlignment: Text.AlignVCenter
                                    font.pixelSize: 26
                                    color: "white"
                                    text: {
                                        var tiele = id_list_repeater.model[index].title

                                        return tiele
                                    }
                                }
                            }

                            YSpacingForColumn {
                                height: 10
                                visible: true
                            }
                            //内容
                            Flow {
                                anchors.left: parent.left
                                anchors.right: parent.right
                                anchors.leftMargin: 30
                                anchors.rightMargin: 30
                                flow: Flow.LeftToRight
                                layoutDirection: Qt.LeftToRight
                                Repeater {
                                    id: id_content_list
                                    width: parent.width
                                    model: id_list_repeater.model[index].arr//[1,2,3,4,5,6]
                                    Rectangle {
                                        width: {
                                            if(parent.width / 2 > (id_content_title.contentWidth + id_status.width + 14)){
                                                return parent.width / 2
                                            }
                                            return id_content_title.contentWidth + id_status.width
                                        }
                                        height: 40
                                        color: "transparent"
                                        Rectangle {
                                            id: id_status
                                            y: (parent.height - height) / 2
                                            width: 6
                                            height: 6
                                            color: "white"
                                            radius: height / 2


                                        }
                                        YText {
                                            id: id_content_title
                                            anchors.left: id_status.right
                                            anchors.top: parent.top
                                            anchors.bottom: parent.bottom
                                            anchors.leftMargin: 14
                                            height: 26
                                            font.pixelSize: 26
                                            verticalAlignment: Text.AlignVCenter
                                            color: "white"
                                            text: {
                                                return id_content_list.model[index]
                                            }
                                        }
                                    }

                                }
                            }

                            YSpacingForColumn {
                                height: 16
                                visible: true
                            }
                        }
                    }
                    YSpacingForColumn {
                        height: 10
                        visible: true
                    }
                }

            }
        }
    }
}






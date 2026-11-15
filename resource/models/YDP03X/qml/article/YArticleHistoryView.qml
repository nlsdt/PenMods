import QtQuick 2.12
import com.youdao.pen 1.0

import BaseQml 1.0
import "../components"
import "../i18n"

YBackgroundIgnoreMouseEvent {
    id: id_article_history_view
    objectName: "YArticleHistoryView.qml"
    anchors.fill: parent
    visible: false

    function show() {
        visible = true
    }

    signal showDetail(string uniqKey)
    signal backButtonClicked()

    YBaseListView {
        id: id_history_listview
        anchors.fill: parent
        anchors.leftMargin: 90
        anchors.rightMargin: 16
        model: articleManager.histories

        delegate: YMouseArea {
            id: itemDelegate
            width: id_history_listview.width
            height: 129

            Rectangle {
                anchors.left: parent.left
                anchors.right: parent.right
                implicitHeight: 119
                color: YColors.grayNormal
                opacity: parent.pressed ? 0.6 : 1
                radius: 16

                YTextMedium {
                    id: id_word
                    anchors.left: parent.left
                    anchors.leftMargin: 20
                    anchors.right: parent.right
                    anchors.rightMargin: 20
                    anchors.top: parent.top
                    anchors.topMargin: 19
                    font.family: qmlGlobal.fontFamilyEnUs
                    text: model.modelData.rawEssay
                    height: contentHeight
                    wrapMode: YTextMedium.NoWrap
                    elide: YTextMedium.ElideRight
                }

                Rectangle {
                    id: id_st_level_area
                    anchors.top: id_word.bottom
                    anchors.topMargin: 10
                    anchors.left: parent.left
                    anchors.leftMargin: 20
                    width: id_st_level.width + 44
                    height: id_st_level.height + 10
                    radius: height/2
                    color: YColors.blueText
                    YText {
                        id: id_st_level
                        anchors.centerIn: parent
                        font.pixelSize: 18
                        text: {
//                            批改结果学段：stLevel
//                            // 批改时入参stLevel取值[0,9]，返回结果stLevel值是英文[DEFAULT,IELTS]
//                            DEFAULT(0, "默认"),
//                            PRIMARY(1, "小学"),
//                            JUNIOR(2, "初中"),
//                            SENIOR(3, "高中"),
//                            CET4(4, "四级"),
//                            CET6(5, "六级"),
//                            POSTGRADUATE(6, "考研"),
//                            TOEFL(7, "托福"),
//                            GRE(8, "GRE"),
//                            IELTS(9, "雅思");
                            switch (settingManager.uiLanguage) {
                            case YEnum.ZH_CN:
                                switch (model.modelData.stLevel) {
                                case "PRIMARY":
                                    return "小学"
                                case "JUNIOR":
                                    return "初中"
                                case "SENIOR":
                                    return "高中"
                                case "CET4":
                                    return "四级"
                                case "CET6":
                                    return "六级"
                                case "POSTGRADUATE":
                                    return "考研"
                                case "TOEFL":
                                    return "托福"
                                case "IELTS":
                                    return "雅思"
                                case "DEFAULT":
                                default:
                                    return "通用"
                                }
                            case YEnum.EN_US:
                            default:
                                switch (model.modelData.stLevel) {
                                case "PRIMARY":
                                    return "G1-G6"
                                case "JUNIOR":
                                    return "G7-G9"
                                case "HIGH":
                                    return "G10-G12"
                                case "CET4":
                                    return "CET 4"
                                case "CET6":
                                    return "CET 6"
                                case "GRADUATE":
                                    return "NEEP"
                                case "TOEFL":
                                    return "TOEFL"
                                case "IELTS":
                                    return "IELTS"
                                case "DEFAULT":
                                default:
                                    return "General"
                                }
                            }
                        }
                    }
                }

                YText {
                    id: id_word_num
                    font.pixelSize: 18
                    color: YColors.grayText
                    anchors.left: id_st_level_area.right
                    anchors.leftMargin: 10
                    anchors.verticalCenter: id_st_level_area.verticalCenter
                    text: YTranslateText.articleWordNum.arg(model.modelData.wordNum)
                }

                YText {
                    id: id_time
                    font.pixelSize: 18
                    color: YColors.grayText
                    anchors.right: parent.right
                    anchors.rightMargin: 20
                    anchors.verticalCenter: id_st_level_area.verticalCenter
                    width: paintedWidth
                    height: paintedHeight
                    text: model.modelData.time
                }
            }

            onClicked: {
                showDetail(model.modelData.uniqueKey)
                console.warn("YArticleHistoryView.qml====item_clicked: ", model.modelData.uniqueKey)
            }
        }

        header: YSpacing {
            width: id_history_listview.width
            implicitHeight: 80
            YText {
                font.pixelSize: 26
                color: YColors.grayText
                anchors.verticalCenter: parent.verticalCenter
                text: YTranslateText.articleHistory
            }
        }

        footer: YSpacing {
            width: id_history_listview.width
            implicitHeight: 20
        }

        YText {
            id: id_history_listview_empty_tip
            anchors.centerIn: parent
            anchors.horizontalCenterOffset: 5
            font.pixelSize: 28
            color: YColors.grayText
            text: YTranslateText.noHistory
            visible: false

            YTimer {
                id: id_delay_check_empty_timer
                interval: 300

                function recheck() {
                    id_clear_button_bg.enabled = false
                    id_history_listview_empty_tip.visible = false
                    restart()
                }

                onTriggered: {
                    id_history_listview_empty_tip.visible = Qt.binding(function(){
                        return 0 === id_history_listview.count
                    })
                    id_clear_button_bg.enabled = Qt.binding(function(){
                        return id_history_listview.count > 0
                    })
                }
                objectName: "YHistoryPage.qml_id_delay_check_empty_timer"
            }

            YImage {
                anchors.right: parent.left
                anchors.rightMargin: 10
                anchors.verticalCenter: parent.verticalCenter
                imageName: "wordbook/no_content"
                sourceSize: Qt.size(36, 36)
            }
        }
    }

    YIconButton {
        id: id_clear_button_bg
        opacity: mouseAreaItem.pressed || !enabled ? 0.2 : 1
        implicitWidth: 44
        implicitHeight: 44
        radius: height/2
        mouseAreaMargins: -25
        anchors.left: parent.left
        anchors.leftMargin: 16
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 18
        enabled: false
        sourceSize: Qt.size(36, 36)
        imageName: "ic_delete"
        onValidClicked: {
            id_history_clear_tip.show()
        }
    }

    YVerticalTitleBar {
        id: id_title_bar
        onCallBack: {
            backButtonClicked()
        }
    }

    YArticleHistoryClearTip {
        id: id_history_clear_tip
        onClicked: {
            id_delay_check_empty_timer.recheck()
        }
    }

    Component.onCompleted: {
        id_delay_check_empty_timer.recheck()
    }
}

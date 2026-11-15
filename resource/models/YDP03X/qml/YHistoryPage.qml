import QtQuick 2.12
import com.youdao.pen 1.0

import BaseQml 1.0
import "./settingpages"
import "./components"
import "./i18n"

YBackButtonPage {
    id: id_history_page
    objectName: "YPage===YHistoryPage.qml"

    YBaseListView {
        id: id_history_listview
        anchors.fill: parent
        anchors.leftMargin: 90
        anchors.rightMargin: 16
        model: historyManager

        onMovingChanged: {
            if (!moving && atYEnd && historyManager.hasMore) {
                historyManager.loadMore()
            }
        }

        delegate: YMouseArea {
            id: itemDelegate
            width: id_history_listview.width
            height: 86
            objectName: "YHistoryPage.qml_itemDelegate_index" + index
            readonly property var jsonTranslate: {
                //console.log("YHistoryPage.qml === content:", model.modelData.content)
                //console.log("YHistoryPage.qml === translate:", model.modelData.translate)
                //console.log("YHistoryPage.qml === srcLangType:", model.modelData.srcLangType)
                //console.log("YHistoryPage.qml === dstLangType:", model.modelData.dstLangType)
                model.modelData.translate.isJson() ? JSON.parse(model.modelData.translate) : model.modelData.translate
            }
            readonly property var qsWord: model.modelData.content
            readonly property var qsPos: typeof jsonTranslate == "object" ? jsonTranslate.pos : ""
            readonly property var qsTrans: typeof jsonTranslate == "object" ? jsonTranslate.tran : model.modelData.translate

            Rectangle {
                width: id_history_listview.width
                height: 76
                color: YColors.grayNormal
                opacity: parent.pressed ? 0.6 : 1
                radius: 12

                YTextMedium {
                    id: id_word
                    anchors.left: parent.left
                    anchors.leftMargin: 20
                    anchors.verticalCenter: parent.verticalCenter
                    font.family: {
                        let  fontName = qmlGlobal.getFontFamilyNameByLangType(model.modelData.srcLangType)
                        if(fontName == fontManager.fontFamilyZhCn)  fontName = fontManager.fontFamilyXinHuaXiHei
                        return fontName
                    }
                    text: qsWord
                    width: parent.width - 40
                    height: contentHeight
                    elide: YTextEnUs.ElideRight
                }
            }

            onClicked: {
                console.log("YHistoryPage.qml====item_clicked")
                if (!resultManager.entryResult(model.modelData.content,
                                               model.modelData.srcLang,
                                               model.modelData.dstLang,
                                               YEnum.PageIndex.History)) {
                    baseSignals.showToast(YTranslateText.queryFaildPleaseTryAgain, "#2D2E33")
                } else {
                    resultManager.isReturnSearch = false
                    qmlGlobal.showDictPage(YEnum.PageIndex.History)
                }
            }
        }

        header: YSpacing {
            width: id_history_listview.width
            implicitHeight: 18
        }

        footer: (historyManager.itemCount > 0 && historyManager.hasMore)
                ? id_listview_loading_footer : id_listview_loaded_footer

        Component {
            id: id_listview_loading_footer

            YListViewLoadMoreFooter {}
        }

        Component {
            id: id_listview_loaded_footer

            YSpacing {
                width: id_history_listview.width
                implicitHeight: 18
            }
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

    onBackButtonClicked: {
        historyManager.wipeData()
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

    YHistoryPageClearTip {
        id: id_history_clear_tip
        onClicked: {
            id_delay_check_empty_timer.recheck()
        }
    }

    Component.onDestruction: {
        console.log("YHistoryPage.qml===Component.onDestruction===called")
    }

    Component.onCompleted: {
        id_delay_check_empty_timer.recheck()
    }

    onVisibleChanged: {
        if (visible) {
            qmlGlobal.currentPageIndex = YEnum.PageIndex.History
        }
    }
}


import QtQuick 2.12
import com.youdao.pen 1.0

import BaseQml 1.0
import "./textbook"
import "./i18n"

// 教材同步页面
YPage {
    id: id_textbook_page
    objectName: "YPage===YTextbookPage.qml"

    signal showSubPage(var subPageIndex, var bAddHistory)

    property bool isFirstSelect: true
    property bool isContinueBought: false
    property var selectTextbookObj: null
    property var textbookSubPageIndexCur: {
        if (settingManager.studyingBookId.length > 0) {
            return YEnum.Textbook_Home
        } else if (!settingManager.isFirstAddTextbook) {
            return YEnum.Textbook_MyTextbook
        } else {
            return YEnum.Textbook_Guide
        }
    }
    property var textbookSubPageHistory: []
    property bool isSelectEnabled: false

    function closeOperationSubPage() {
        id_textbook_operation_loader.active = false
    }

    function subPageCallBack() {
        if (textbookSubPageHistory.length > 0) {
            let popPageIndex = textbookSubPageHistory.pop()
            if (popPageIndex === YEnum.Textbook_Guide
                    && settingManager.studyingBookId.length > 0) {
                backButtonClicked()
                return
            }

            if (popPageIndex === YEnum.Textbook_Home
                    && textbookSubPageHistory.length === 0
                    && settingManager.studyingBookId.length <= 0) {
                popPageIndex =  YEnum.Textbook_Select
            }
            textbookSubPageIndexCur = popPageIndex
        } else {
            backButtonClicked()
        }
    }

    onShowSubPage: {
        if (subPageIndex === YEnum.Textbook_Operation) {
            textBookManager.syncBookPayInfo(selectTextbookObj.bookId)
            id_textbook_operation_loader.active = true
            return
        }
        closeOperationSubPage()
        if (textbookSubPageIndexCur !== subPageIndex) {
            if (typeof bAddHistory != "undefined" && bAddHistory) {
                let iPosHave = textbookSubPageHistory.indexOf(textbookSubPageIndexCur)
                if (iPosHave >= 0) {
                    textbookSubPageHistory.splice(iPosHave, 1)
                }
                iPosHave = textbookSubPageHistory.indexOf(subPageIndex)
                if (iPosHave >= 0) {
                    textbookSubPageHistory.splice(iPosHave, 1)
                }
                textbookSubPageHistory.push(textbookSubPageIndexCur)
            } else {
                textbookSubPageHistory = []
            }
            if (YEnum.Textbook_Select === subPageIndex) {
                id_textbook_page.isFirstSelect = true
            }
            textbookSubPageIndexCur = subPageIndex
        }
    }

    onTextbookSubPageIndexCurChanged: {
        if (YEnum.Textbook_Home === textbookSubPageIndexCur) {
            isSelectEnabled = false
            id_select_disable_timer.restart()
        }
    }

    YLoader {
        id: id_select_textbook_loader
        anchors.fill: parent
        active: true
        asynchronous: false
        sourceComponent: {
            switch (textbookSubPageIndexCur) {
            case YEnum.Textbook_Guide:
                return id_textbook_guide_component
            case YEnum.Textbook_Select:
                return id_textbook_select_component
            case YEnum.Textbook_Home:
                return id_textbook_home_component
            case YEnum.Textbook_MyTextbook:
                return id_textbook_mytextbook_component
            case YEnum.Textbook_ListenToAudio:
                return id_textbook_listentoaudio_component
            case YEnum.Textbook_Favorites:
                return id_textbook_favorites_component
            case YEnum.Textbook_ScanReadGuide:
                return id_textbook_scanread_guide_component
            case YEnum.Textbook_Homework:
                return id_textbook_homework_component
            default:
                return null
            }
        }

        Component {
            id: id_textbook_guide_component
            YTextbookGuide {}
        }

        Component {
            id: id_textbook_select_component
            YTextbookSelect {}
        }

        Component {
            id: id_textbook_home_component
            YTextbookHome {}
        }

        Component {
            id: id_textbook_mytextbook_component
            YTextBookMyTextBook {}
        }

        Component {
            id: id_textbook_listentoaudio_component
            YTextbookListenToAudio {}
        }

        Component {
            id: id_textbook_favorites_component
            YTextbookFavorites {}
        }

        Component {
            id: id_textbook_scanread_guide_component
            YTextBookScanReadGuide {}
        }

        Component {
            id: id_textbook_homework_component
            YTextbookHomework {}
        }

    }

    YLoader {
        id: id_textbook_operation_loader
        anchors.fill: parent
        asynchronous: false
        sourceComponent: YTextbookOperation {}
    }

    YTextbookScanReadListDialog {
        id: id_textbook_scan_read_list_dialog
        z:id_select_textbook_loader.z + 1
    }

    YTimer {
        id: id_select_disable_timer
        interval: 2000
        objectName: "YTextbookPage.qml_id_select_disable_timer"
        onTriggered: {
            console.warn("YTextbookPage.qml===id_select_disable_timer===triggered")
            isSelectEnabled = true
        }
    }

    Connections {
        target: textBookBlockManager
        ignoreUnknownSignals: true
        enabled: id_select_textbook_loader.isLoaded
        function onLoadBookUnitFinished() {
            console.warn("YTextbookPage.qml===Connections===onLoadBookUnitFinished")
        }



        function onBlocksSearchFound(searchType, page, keyword, isFind) {
            console.warn("YTextbookPage.qml===Connections===onBlocksSearchFound searchType:", searchType, ", page", page, ", isFind:", isFind)
            let list = textBookBlockManager.getSearchedBlocks()
            if (!isFind) {
                if (list.length > 0) {
                    id_textbook_scan_read_list_dialog.close()
                    id_textbook_scan_read_list_dialog.updateModel(keyword, searchType, list)
                    id_textbook_scan_read_list_dialog.show()
                }
                else if (searchType === YEnum.ST_Keyword) {
                    id_textbook_scan_read_list_dialog.close()
                    id_textbook_scan_read_list_dialog.updateModel(keyword, searchType, list)
                    id_textbook_scan_read_list_dialog.show()
                    return
                }

                let notFoundTip = YTranslateText.textbookBlocksSearchNotFound
                if (searchType === YEnum.ST_KeywordPage || searchType === YEnum.ST_Keyword) {
                    notFoundTip = YTranslateText.textbookBlocksSearchPageNotExist
                }
                baseSignals.showToast(notFoundTip, YColors.grayButton)
                return
            }

            if(searchType === YEnum.ST_Page){
                console.log("YTextbookPage.qml===count ", list.length)
                id_textbook_scan_read_list_dialog.close()
                id_textbook_scan_read_list_dialog.updateModel(keyword, searchType, list)
                id_textbook_scan_read_list_dialog.show()
            }
            else if (1 === list.length) {
                // 关键字查询直接播放
                id_textbook_scan_read_list_dialog.close()
                textBookBlockManager.clickMedia(list[0].blockId, true)
                if (YEnum.PLAYING !== mediaPlayerManager.playState) {
                    mediaPlayerManager.onClickedPlay()
                }
            }

            else if(searchType === YEnum.ST_Keyword){
                console.log("YTextbookPage.qml===count ", list.length)


                id_textbook_scan_read_list_dialog.close()
                id_textbook_scan_read_list_dialog.updateModel(keyword, searchType, list)
                id_textbook_scan_read_list_dialog.show()

            } else if(searchType === YEnum.ST_KeywordPage){
                console.log("YTextbookPage.qml===count ", list.length)
                id_textbook_scan_read_list_dialog.close()
                id_textbook_scan_read_list_dialog.updateModel(keyword, searchType, list)
                id_textbook_scan_read_list_dialog.show()

            }
        }
    }

    Component.onDestruction: {
        textBookManager.wipeData()
        textBookBlockManager.wipeData()
        textbookSubPageIndexCur = YEnum.TPI_COUNT
        console.log("YTextbookPage.qml===Component.onDestruction===called")
    }

    onVisibleChanged: {
        if (visible) {
            qmlGlobal.currentPageIndex = YEnum.PageIndex.TextBook
            textBookManager.commitNotifyFailedPepCode()
            textBookManager.launchImportBooks()
        }
    }

}


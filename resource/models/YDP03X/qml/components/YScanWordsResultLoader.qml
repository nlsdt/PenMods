import QtQuick 2.12
import com.youdao.pen 1.0

import BaseQml 1.0
import "../i18n"
/*
    显示查词的空结果和正在扫描的结果
*/

YLoader {
    id: id_scan_result_loader
    anchors.fill: parent

    property bool isVerifiyFinished: false
    property int scanWordType: 1
    property int showIndex: 0
    readonly property alias searchTimerIsRun: id_search_timer.running

    function showEmpty() {
        id_search_timer.stop()
        qmlGlobal.requestShowScanGuide()
        hidden()
    }

    function showEmptyAndToast() {
        if (!isOidScanning) {
            soundCenter.stop()
            showEmpty()
            baseSignals.showToast(YTranslateText.cannotFindContentTryAgain, "#2D2E33")
            qmlGlobal.hideDictPage()
        }
    }

    YTimer {
        id:id_start_delay_hide_dict
        repeat: false
        interval: 500
        onTriggered: {
            if(isOidScanning) {
                qmlGlobal.hideDictPage()
            }
        }
    }

    function startOcrFunction(isStartOid = false) {
        ocrStart(isStartOid)
        if (!isStartOid) {
            show()
        } else {
            //            if(isReStartOid) {
            //                id_start_delay_hide_dict.interval = 0
            //                isReStartOid = false
            //                id_start_delay_hide_dict.restart()
            //            } else {
            //                id_start_delay_hide_dict.interval = 2000
            //                id_start_delay_hide_dict.restart()
            //            }
        }
    }

    function hidden() {
        if (active) {
            active = false
        }
    }

    function show() {
        if (!active) {
            active = true
        }
    }

    signal ocrStart(bool isStartOid)

    sourceComponent: {
        return id_ocr_scan_word_result_component
//        return id_ocr_scan_math_img_component
    }

    // 实时拼图显示组件，现在不使用了
    Component {
        id: id_ocr_scan_math_img_component
        YBackgroundIgnoreMouseEvent {
            Flickable {
                anchors.fill: parent

                Image {
                    id: id_ocr_scan_math_img
                    anchors.top: parent.top
                    anchors.topMargin: 72
                    anchors.left: parent.left
                }

                Row {
                    id: id_row
                    height: 72

                    YBackButton {
                        id: id_result_empty_back_button
                        anchors.top: parent.top
                        anchors.bottom: parent.bottom
                        anchors.topMargin: 18
                        onClicked: {
                            hidden()
                        }
                    }
                }

                Connections {
                    target: mathExerciseManager
                    onCallRefreshOcrImg: {
                        id_ocr_scan_math_img.source = ""
                        id_ocr_scan_math_img.source = "image://ocr/" + Math.random()
                        id_ocr_scan_math_img.sourceSize = Qt.size(width, height)
                        id_ocr_scan_math_img.width = width
                        id_ocr_scan_math_img.height = height
                    }
                }

                Connections {
                    target: systemBase
                    ignoreUnknownSignals: true
                    enabled: isVerifiyFinished
                    function onOcrCompletedResultChanged() {
                        showDictPage("")
                    }
                }
            }
        }
    }

    Component {
        id: id_ocr_scan_word_result_component
        YBackgroundIgnoreMouseEvent {
            Flickable {
                anchors.fill: parent
                contentHeight: id_scan_result_appand_area.contentHeight
                contentY: Math.max(0, id_scan_result_appand_area.contentHeight - 220)
                Row {
                    id: id_row
                    height: parent.height

                    YBackButton {
                        id: id_result_empty_back_button
                        anchors.top: parent.top
                        anchors.bottom: parent.bottom
                        anchors.topMargin: 18
                        onClicked: {
                            hidden()
                        }
                    }

                    YSpacing {
                        implicitWidth: 10
                        anchors.top: parent.top
                        anchors.bottom: parent.bottom
                    }

                    TextEdit {
                        id: id_scan_result_appand_area
                        anchors.top: parent.top
                        anchors.bottom: parent.bottom
                        anchors.topMargin: 22

                        width: 694
                        wrapMode: TextEdit.Wrap
                        textFormat: TextEdit.PlainText
                        color: "white"
                        font.pixelSize: 30
                        font.family: {
                            switch (qmlTranslator.getCharType(systemBase.ocrCompletedResult)) {
                            case YEnum.CT_ENG:
                                return fontManager.fontFamilyEnUs
                            case YEnum.CT_JP:
                                return fontManager.fontFamilyJaJp
                            case YEnum.CT_KO:
                                return fontManager.fontFamilyKoKr
                            default:
                                return fontManager.fontFamilyXinHuaXiHei
                            }
                        }
                        onTextChanged: {
                            if (resultManager.itemCount && active) {
                                resultManager.resetStatus()
                                soundCenter.stop()
                            }
                        }
                        font.weight: Font.Bold
                        cursorPosition: text.length
                        cursorDelegate: Rectangle {
                            id: id_cursor_context
                            width: 4
                            height: 38
                            opacity: 0
                            color: YColors.red
                            SequentialAnimation {
                                running: id_scan_result_appand_area.activeFocus
                                loops: SequentialAnimation.Infinite
                                ScriptAction { script: id_cursor_context.opacity = 1 }
                                PauseAnimation { duration: 600 }
                                ScriptAction { script: id_cursor_context.opacity = 0 }
                                PauseAnimation { duration: 600 }
                            }
                        }
                        YMouseArea {
                            anchors.fill: parent
                            objectName: "YScanWordsResultLoader.qml_id_scan_result_appand_area"
                        }
                        Connections {
                            target: id_scan_result_loader
                            ignoreUnknownSignals: true
                            enabled: isVerifiyFinished
                            function onLoaded() {
                                id_scan_result_appand_area.forceActiveFocus()
                            }
                        }
                        YTimer {
                            id: id_show_timer
                            interval: 12
                            repeat: true
                            onTriggered: {
                                showIndex++
                                if (id_search_timer.running) {
                                    if(systemBase.isButtonRelease)
                                        id_search_timer.restart()
                                    else
                                        id_search_timer.stop()
                                }
                                id_scan_result_appand_area.text = systemBase.ocrCompletedResult.substring(0,showIndex)
                                soundCenter.stop()
                                showDictPage(systemBase.ocrCompletedResult.substring(0,showIndex))
                                if (showIndex > systemBase.ocrCompletedResult.length) {
                                    stop()
                                }
                            }
                        }
                        Connections {
                            target: systemBase
                            ignoreUnknownSignals: true
                            enabled: isVerifiyFinished
                            function onOcrCompletedResultChanged() {
                                console.log("************onOcrCompletedResultChanged enter")
                                if (showIndex > systemBase.ocrCompletedResult.length) {
                                    showIndex = systemBase.ocrCompletedResult.length
                                }
                                if (systemBase.ocrCompletedResult.length >= showIndex || !systemBase.isButtonRelease) {
                                    id_show_timer.start()
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    property bool isOidScanning: false
    property bool isReStartOid: true

    Connections {
        target: resultManager
        ignoreUnknownSignals: true
        enabled: isVerifiyFinished
        function onNoResultSignal() {
            if (!isOidScanning) {
                showEmptyAndToast()
            }
        }
    }

    function showDictPage(content){

        switch (qmlGlobal.currentPageIndex) {
        case YEnum.PageIndex.TextBook:
        case YEnum.PageIndex.Math:
        case YEnum.PageIndex.Audioplayer:
        case YEnum.PageIndex.Article:
        case YEnum.PageIndex.MathTutor:
            visible = true
            break
        default:
            if (content.length) {
                const pageIndex = qmlGlobal.currentPageIndex === YEnum.PageIndex.Fav
                                ? YEnum.PageIndex.Fav : YEnum.PageIndex.NonePage


                qmlGlobal.showDictPage(pageIndex,content)
                resultManager.isReportButtonVisible = true
                visible = false
            }
            break
        }
    }

    function searchWord(){
        var queryWord = systemBase.ocrCompletedResult
        if (resultManager.entryResult(queryWord.trim(), "", "", YEnum.PageIndex.Dict, scanWordType)) {
            if (active) {
                let pageIndex = qmlGlobal.currentPageIndex === YEnum.PageIndex.Fav ? YEnum.PageIndex.Fav
                                                                                   : YEnum.PageIndex.NonePage
                qmlGlobal.showDictPage(pageIndex)
                resultManager.isReportButtonVisible = true
                hidden()
            }
        } else {
            qmlGlobal.canAutoAddToWb = false
            showEmptyAndToast()
        }
    }

    YTimer {
        id: id_search_timer
        interval: 0
        property int timerCount: 0
        onTriggered: {
            if (active && !resultManager.isReturnSearch) {
                searchWord()
            }
        }
    }

    YTimer {
        id:id_start_delay_hide


        repeat: false
        interval: 500
        onTriggered: {
            if(isOidScanning) {
                hidden()
            }
        }
    }

    Connections {
        target: systemBase
        ignoreUnknownSignals: true
        enabled: isVerifiyFinished
        function onIsOidStart(isOid) {

            //正在升级OS 禁用oid（三代固件未暴露 updateOsManager，此处跳过检测）
          console.warn("YTouchReadingResultLoader.qml====IsOidStart: ", isOid)
            resultManager.resetStatus()
            isOidScanning = isOid
            let isReStartOidTmp = isReStartOid
            show()
            ocrStart(isOid);
            //startOcrFunction(isOid)
            //            if (isOidScanning) {
            //                if(isReStartOidTmp) {
            //                    id_start_delay_hide.interval = 0
            //                    id_start_delay_hide.restart()
            //                } else {
            //                    id_start_delay_hide.interval = 2000
            //                    id_start_delay_hide.restart()
            //                }
            //            }
        }

        function onOidStop(bSuccess) {
            console.warn("YScanWordsResultLoader.qml====oid_stop bSuccess: ", bSuccess)
            isReStartOid = bSuccess
            if (!bSuccess) {
                id_start_delay_hide_dict.stop()
                id_start_delay_hide.stop()
                isOidScanning = false // continue scan words function
                startOcrFunction(isOidScanning)
                resultManager.resetStatus()
            } else {
                id_start_delay_hide_dict.interval = 0
                id_start_delay_hide_dict.restart()
                hidden()
            }
        }

        function onHideScanWordResult() {
            console.warn("YScanWordsResultLoader.qml====onHideScanWordResult")
            hidden()
        }

        function onOcrStart(){
            console.warn("YScanWordsResultLoader.qml====onOcrStart")
            //showDictPage("isOcrStart")
            resultManager.isReturnSearch = false
            soundCenter.stop()
            id_search_timer.stop()
        }

        function onOcrStop(scanType) {
            console.warn("YScanWordsResultLoader.qml====ocr_stop scanType: ", scanType)


            qmlGlobal.canAutoAddToWb = true
            id_start_delay_hide_dict.stop()
            scanWordType = scanType
            qmlGlobal.scanOldType = scanType
            if (systemBase.ocrCompletedResult.length === 0) {
                qmlGlobal.canAutoAddToWb = false
                showEmptyAndToast()

            } else {
                if (settingManager.isContinueScan && scanType !== 0 ) {
                    id_search_timer.restart()
                } else {


                    searchWord()
                }
            }
        }

        function onHomeKeyRelease() {
            console.log("YScanWordsResultLoader.qml===onHomeKeyRelease===")
            isOidScanning = false
        }

        function onStopContinueScan() {
            isReStartOid = true
        }
    }
}

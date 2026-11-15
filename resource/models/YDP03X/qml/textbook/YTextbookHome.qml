import QtQuick 2.12
import com.youdao.pen 1.0
import QtGraphicalEffects 1.14

import BaseQml 1.0
import "../i18n"

Item {
    id: id_textbook_home_item
    objectName: "YTextbookHome.qml"
    anchors.fill: parent
    property string bookId: settingManager.studyingBookId
    property int exerciseCount: textBookTaskManager.taskTipCount
    property   bool  en_button_able: false
    function show(){
        id_textbook_home_item.visible = true
    }

    function hidden(){
        id_textbook_home_item.visible = false
    }

    function textbookHomeMenuClicked(index) {
        console.warn("YTextbookHome.qml===textbookHomeMenuClicked===index: ", index)
        let component = null
        switch (index) {
        case YEnum.TextbookHomePageIndex.TextbookHome_Audio:
            logManager.sendHttpLog("action=textbook_listening_click")
            showSubPage(YEnum.Textbook_ListenToAudio, true)
            break
        case YEnum.TextbookHomePageIndex.TextbookHome_Bookmark:
            logManager.sendHttpLog("textbook_collection_click")
            showSubPage(YEnum.Textbook_Favorites, true)
            break
        case YEnum.TextbookHomePageIndex.TextbookHome_Exercisebook:
            showSubPage(YEnum.Textbook_Homework, true)
            break
        }
    }

    Item {
        id: id_textbook_home_list_view_container
        anchors.fill: parent
        anchors.topMargin: 60
        anchors.bottomMargin: 60
        anchors.leftMargin: 80

        YHorizontalListView {
            id: id_textbook_home_list_view
            model: mainMenuModel
            spacing: 12
            anchors.fill: parent
            rightMargin: 24

            header: id_header_component

            Component{
                id: id_header_component
                Column {
                    id: id_textbook_home_column
                    spacing: 10
                    anchors.top: parent.top
                    anchors.topMargin: 20
                    anchors.leftMargin: 90
                    width: 390
                    Row {
                        width: parent.width
                        height: 37
                        anchors.left: parent.left
                        spacing: 8
                        YText {
                            id: id_result_study_tip
                            font.pixelSize: 30
                            width: 300
                            textFormat: YTextMedium.RichText
                            lineHeight: parent.height
                            lineHeightMode: YTextMedium.FixedHeight
                            wrapMode: YTextBase.Wrap
                            font.family: fontManager.fontFamilyZhCn
                            text: YTranslateText.textbookHomeTip.arg(YColors.red)
                        }

                        YIconButton {
                            implicitWidth: 30
                            implicitHeight: 30
                            id: id_result_study_tip_help
                            anchors.verticalCenter: parent.verticalCenter
                            radius: height/2
                            color: YColors.grayNormal
                            sourceSize: Qt.size(30, 30)
                            opacity: id_result_study_tip_help.pressed ? 0.6 : 1
                            imageName: "textbook/help"
                            mouseAreaMargins: -5
                            onClicked: {
                                id_scan_read_guide.visible = true
                            }
                        }
                    }

                    Item {
                        anchors.left: parent.left
                        width: 330
                        implicitHeight: 76
                        YTextBase {
                            id: id_result_study_publisher
                            font.pixelSize: 26
                            anchors.left: parent.left
                            color: YColors.grayText
                            width: parent.width
                            lineHeight: 32
                            lineHeightMode: YTextMedium.FixedHeight
                            wrapMode: YTextBase.Wrap
                            font.family: fontManager.fontFamilyZhCn
                            text: settingManager.studyingBookPublisher
                        }
                        YTextBase {
                            id: id_result_study_title
                            font.pixelSize: 26
                            anchors{left: parent.left; top: id_result_study_publisher.bottom; topMargin: 4}
                            color: YColors.grayText
                            width: parent.width
                            lineHeight: 32
                            lineHeightMode: YTextMedium.FixedHeight
                            wrapMode: YTextBase.Wrap
                            font.family: fontManager.fontFamilyZhCn
                            text: settingManager.studyingBookTitle
                        }
                    }

                }// Column
            }

            delegate: Item {
                id: id_item_delegate
                width: 204
                height: parent.height
                anchors.verticalCenter: parent.verticalCenter

                YButtonBase {
                    id: id_textbook_home_menu_button
                    anchors.centerIn: parent
                    width: parent.width
                    height: 134
                    antialiasing: true
                    opacity: id_textbook_home_button.pressed ? 0.6 : 1
                    anchors.verticalCenter: parent.verticalCenter

                    YImage {
                        id: id_textbook_home_main_icon
                        anchors.left: parent.left
                        anchors.leftMargin: 24
                        anchors.verticalCenter: parent.verticalCenter
                        sourceSize: Qt.size(30, 30)
                        imageName: iconMain
                        visible: !id_textbook_home_exercise_count.visible
                    }

                    YTextMedium {
                        id: id_textbook_home_menu_text
                        anchors.left: id_textbook_home_main_icon.right
                        anchors.leftMargin: 10
                        textFormat: YTextBase.RichText
                        anchors.verticalCenter: parent.verticalCenter
                        font.family: fontManager.fontFamilyZhCn
                        text: {
                            switch (pageIndex) {
                            case YEnum.TextbookHomePageIndex.TextbookHome_Audio:
                                return YTranslateText.textbookListenToAudio
                            case YEnum.TextbookHomePageIndex.TextbookHome_Bookmark:
                                return YTranslateText.textbookBookmark
                            case YEnum.TextbookHomePageIndex.TextbookHome_Exercisebook:
                                return YTranslateText.textbookExercisebook
                            default:
                                return ""
                            }
                        }
                    }

                    YImage {
                        id: id_textbook_home_menu_icon
                        anchors.left: id_textbook_home_menu_text.right
                        anchors.leftMargin: 12
                        anchors.verticalCenter: parent.verticalCenter
                        sourceSize: Qt.size(24, 24)
                        imageName: iconFg
                        visible: !id_textbook_home_exercise_count.visible
                    }

                    YRectangle {
                        id: id_textbook_home_exercise_count
                        anchors.left: id_textbook_home_menu_text.right
                        anchors.leftMargin: 12
                        anchors.verticalCenter: parent.verticalCenter
                        width: 14 + (id_textbook_home_exercise_count_text.width > 14
                                     ? id_textbook_home_exercise_count_text.width : 14)
                        height: 28
                        color: YColors.red
                        radius: height * 0.5
                        visible: YEnum.TextbookHomePageIndex.TextbookHome_Exercisebook === pageIndex && exerciseCount > 0

                        YTextMedium {
                            id: id_textbook_home_exercise_count_text
                            width: contentWidth
                            height: 24
                            anchors.centerIn: parent
                            font.pixelSize: 20
                            font.family: fontManager.fontFamilyZhCn
                            text: exerciseCount
                        }
                    }

                    YMouseArea {
                        id: id_textbook_home_button
                        anchors.fill: parent
                        objectName: "YTextbookHome_id_textbook_home_list_view_pageIndex" + pageIndex
                        onClicked: {
                            if (pageIndex === YEnum.TextbookHomePageIndex.TextbookHome_Exercisebook) {
                                if (!wifiManager.internetConnect) {
                                    baseSignals.showToast(YTranslateText.networkAbnormalPleaseCheck, YColors.grayNormal)
                                    return
                                }
                                if (!loginManager.isLogin) {
                                    baseSignals.showToast(YTranslateText.accountHasUnbundling, YColors.grayNormal)
                                    return
                                }
                            }
                            textbookHomeMenuClicked(pageIndex)
                        }
                    }
                }
            }

            ListModel {
                id: mainMenuModel
                Component.onCompleted: {
                    append({iconMain: "textbook/guid-listen", iconFg: "textbook/enter-icon", pageIndex: YEnum.TextbookHomePageIndex.TextbookHome_Audio})
                    append({iconMain: "textbook/collect", iconFg: "textbook/enter-icon", pageIndex: YEnum.TextbookHomePageIndex.TextbookHome_Bookmark})
                    if (settingManager.isJoinClass) {
                        append({iconMain: "textbook/homework", iconFg: "textbook/enter-icon", pageIndex: YEnum.TextbookHomePageIndex.TextbookHome_Exercisebook})
                    }
                }
            }

//            Connections {
//                target: settingManager
//                ignoreUnknownSignals: true
//                function onIsJoinClassChanged() {
//                    console.log("YTextbookHome.qml===isJoinClass ", settingManager.isJoinClass)
//                    if (settingManager.isJoinClass) {
//                        mainMenuModel.append({iconMain: "textbook/homework", iconFg: "textbook/enter-icon", pageIndex: YEnum.TextbookHomePageIndex.TextbookHome_Exercisebook})
//                    }
//                }
//            }
        }

        YSpacing {
            anchors {left:; right: parent.right; rightMargin: 24}
        }
    }

    Item {
        id: id_title_bar_holder
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        implicitWidth: 80

        ShaderEffectSource {
            id: id_effect_source
            anchors.fill: parent
            sourceItem: id_textbook_home_list_view
            sourceRect: Qt.rect(x - 80, y - 60, width, height)
            visible: false
        }

        FastBlur {
            anchors.fill: parent
            source: id_effect_source
            radius: 64
        }

        Rectangle {
            anchors.fill: parent
            color: "#4D000000"
            anchors.top: parent.top
            anchors.bottom: parent.bottom
        }
    }

    YVerticalTitleBar {
        id: id_title_bar
        onCallBack: {
            backButtonClicked()
        }

        YIconButton {
            id: id_more_button_bg
           // enabled: id_textbook_page.isSelectEnabled
            enabled: en_button_able

            implicitWidth: 44
            implicitHeight: 44
            mouseAreaMargins: -18
            radius: height/2
            anchors.left: parent.left
            anchors.leftMargin: 16
            anchors.bottom: parent.bottom
            sourceSize: Qt.size(36, 36)
            imageName: "textbook/switch"
            onClicked: {
                logManager.sendHttpLog("action=textbook_change_click")
                showSubPage(YEnum.Textbook_MyTextbook, true)
            }
        }
    } // YVerticalTitleBar

    YTwoButtonDialog {
        id: id_tip_dialog
        anchors.fill: parent
        buttonItemConfirm.textFamily: fontManager.fontFamilyZhCn
        buttonItemCancel.textFamily: fontManager.fontFamilyZhCn
        tipItem.font.family: fontManager.fontFamilyZhCn
        tipItem.text: YTranslateText.textbookContinueBoughtTip
        onClickedConfirm: {
            id_tip_dialog.close()
            // 设置教材对象
            id_textbook_page.selectTextbookObj =  textBookManager.getStudyingBook()
            id_textbook_page.isContinueBought = true
            showSubPage(YEnum.Textbook_Operation, true)
        }
        onClickedCancel: {
            id_tip_dialog.close()
        }
    }

    YTextBookScanReadGuide {
        id: id_scan_read_guide
        visible: false
    }

    Component.onCompleted: {
        console.warn("YTextbookHome.qml===Component.onCompleted")

        console.warn("YTextbookHome.qml===Component.onCompleted===settingManager.isFirstFollowScanRead:",settingManager.isFirstFollowScanRead)
        if (settingManager.isFirstFollowScanRead) {
            settingManager.isFirstFollowScanRead = false
            id_scan_read_guide.visible = true
        }
        textBookTaskManager.httpGetOwnerClassStatus()
        // 检查是否即将过期
        textBookManager.loadStudyingBook()

       id_delay_button_enable.restart();
    }

    Connections {
        target: textBookManager
        ignoreUnknownSignals: true
        function onIsNeedRenewTipChanged() {
            if (textBookManager.isNeedRenewTip) {
                id_tip_dialog.show()
                textBookManager.queryBookPrice(bookId)
                textBookManager.setBookRemindedValue(bookId, true)
            }
        }
    }

    Connections {
        target: systemBase
        ignoreUnknownSignals: true
        function onHideTestBookHome() {
            hidden()
            id_delay_timer.start()
        }
    }

    YTimer {
        id: id_delay_timer
        interval: 500
        objectName: "YTextbookHome.qml_id_delay_timer"
        onTriggered: {
            console.warn("YTextbookHome.qml===YTimer===show()")
            show()
        }
    }

    YTimer {
        id: id_delay_button_enable
        interval: 2000
        objectName: "Yid_delay_button_enable"
        onTriggered: {

             console.warn("YTextbookHome.qml========YTimer===show()@@@@@")
            en_button_able = true;
        }
    }
}


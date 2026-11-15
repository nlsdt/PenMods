import QtQuick 2.12
import com.youdao.pen 1.0

import BaseQml 1.0
import "./components"
import "./i18n"

// this is not a YPage

YBackground {
    id: id_container_index
    anchors.fill: parent

    property alias currentIndex: id_main_menu_list_view.currentIndex

    // 教程同步可用与否
    readonly property bool featureTextBookEnabled: qmlGlobal.checkFeature(YEnum.FEATURE_TEXTBOOK)
    // 口算批改可用与否
    readonly property bool featureMathCalculateEnabled: qmlGlobal.checkFeature(YEnum.FEATURE_MATH_CALCULATE)
    // 写作指导可用与否
    readonly property bool featureArticleEnabled: true
    // AI好题本可用与否
    readonly property bool featureMathTutorEnabled: qmlGlobal.checkFeature(YEnum.FEATURE_MATH_EXERCISE)

    property var iconsModel: null

    signal pageIndexClicked(int index)

    function delayInitMainTitleBar(){
        id_main_titlebar_loader.source = "components/YMainTitleBar.qml"
        id_main_titlebar_loader.active = true
    }

    YLoader {
        id: id_main_titlebar_loader
        anchors.left: parent.left
        anchors.right: parent.right
        height: 70
    }

    Connections {
        target: readingBookManager
        ignoreUnknownSignals: true
        function onPlayGuideFinish() {
            logManager.sendHttpLog("action=home_book_touch_reading_click")
            qmlGlobal.requestShowPage(YEnum.PageIndex.Reading)
        }
    }

    function mainMenuClicked(index) {
        console.warn("YIndexPage.qml===mainMenuClicked===index: ", index)
        switch (index) {
        case YEnum.PageIndex.Dict:
            logManager.sendHttpLog("action=home_search_click")
            if (queryTweaks.typeByHand) id_container_index.requestLookupKeyboard()
            else qmlGlobal.requestShowPage(YEnum.PageIndex.Dict)
            break
        case YEnum.PageIndex.UpdateOS:
            logManager.sendHttpLog("action=home_update_click")
            qmlGlobal.requestShowPage(YEnum.PageIndex.UpdateOS)
            break
        case YEnum.PageIndex.Speech:
            logManager.sendHttpLog("action=home_voiceassist_click")
            if (!wifiManager.internetConnect)
            {
                qmlGlobal.requestSpeechNeedNetWork();
                return;
            }

            if (typeof antiEmbs === "object" && antiEmbs !== null && antiEmbs.active) {
                qmlGlobal.requestShowPage(YEnum.PageIndex.Speech)
            } else {
                qmlGlobal.requestShowThirdQML("ChatAssistant")
            }
            break
        case YEnum.PageIndex.Reading:
            //            if (settingManager.showReadingBookGuide) {
            //                readingBookManager.playGuideVideo()
            //            } else {
            logManager.sendHttpLog("action=home_book_touch_reading_click")
            qmlGlobal.requestShowPage(YEnum.PageIndex.Reading)
            //            }
            break
        case YEnum.PageIndex.TextBook:
            logManager.sendHttpLog("action=home_textbook_click")
            qmlGlobal.requestShowPage(YEnum.PageIndex.TextBook)
            break
        case YEnum.PageIndex.Math:
            logManager.sendHttpLog("action=home_math_click")
            qmlGlobal.requestShowPage(YEnum.PageIndex.Math)
            break
        case YEnum.PageIndex.MathTutor:
            logManager.sendHttpLog("action=home_mathexercise_click")
            qmlGlobal.requestShowPage(YEnum.PageIndex.MathTutor)
            break
        case YEnum.PageIndex.Fav:
            logManager.sendHttpLog("action=home_wordbook_click")
            qmlGlobal.requestShowPage(YEnum.PageIndex.Fav)
            break
        case YEnum.PageIndex.Audioplayer:
            logManager.sendHttpLog("action=home_listening_clik")
            qmlGlobal.requestShowPage(YEnum.PageIndex.Audioplayer)
            break
        case YEnum.PageIndex.History:
            logManager.sendHttpLog("action=home_history_click")
            qmlGlobal.requestShowPage(YEnum.PageIndex.History)
            break
        case YEnum.PageIndex.Setting:
            logManager.sendHttpLog("action=home_settings_click")
            qmlGlobal.requestShowPage(YEnum.PageIndex.Setting)
            break
        case 9900:
            // PenMods 插件管理
            qmlGlobal.requestShowThirdQML("PluginManager")
            break
        case YEnum.PageIndex.Article:
            logManager.sendHttpLog("action=home_essay_checker")
            qmlGlobal.requestShowPage(YEnum.PageIndex.Article)
            break
        }
        pageIndexClicked(index)
    }

    // PenMods3: 弹出键盘输入要查的词，确认后直接查词（跳过 OCR 扫描）
    property int incubatorCreateLookupCount: 0

    function requestLookupKeyboard() {
        const component = Qt.createComponent("qrc:/qml/input/YInputPage.qml")
        if (component.status !== Component.Ready) {
            console.warn("YIndexPage.qml===requestLookupKeyboard: component not ready", component.errorString())
            return
        }
        const incubator = component.incubateObject(id_container_index)
        if (incubator.status !== Component.Ready) {
            incubator.onStatusChanged = function (status) {
                if (status === Component.Ready) {
                    if (0 === --id_container_index.incubatorCreateLookupCount) {
                        id_container_index.initLookupKeyboard(incubator.object)
                    } else {
                        incubator.object.destroy()
                    }
                }
            }
            ++id_container_index.incubatorCreateLookupCount
        } else {
            id_container_index.initLookupKeyboard(incubator.object)
        }
    }

    function initLookupKeyboard(keyboardPage) {
        keyboardPage.inputFinished.connect(function (word) {
            if (word.length > 0) {
                console.log("YIndexPage.qml===lookup word:", word)
                // 直接查词（跳过 OCR）：与单词本点词同一套 API
                var res = resultManager.entryResult(word, "", "", YEnum.PageIndex.Dict, 1, false)
                if (!res) {
                    baseSignals.showToast(YTranslateText.queryFaildPleaseTryAgain, "#2D2E33")
                } else {
                    qmlGlobal.showDictPage(YEnum.PageIndex.Dict)
                }
            }
        })
        keyboardPage.placeHolderText = "请输入要查询的单词"
        keyboardPage.show()
    }

    function updateMainMenuModel() {
        mainMenuModel.clear()
        // 查词翻译
        mainMenuModel.append({iconFg: "home-dict", pageIndex: YEnum.PageIndex.Dict,
                                 featureid:YEnum.ParentsControlList.Dict,
                                 enable:settingManager.readparentcontrols(YEnum.ParentsControlList.Dict),
                                 pageVisible:settingManager.readhomepagesettings(YEnum.ParentsControlList.Dict)})

        // 系统升级
        mainMenuModel.append({iconFg: "home-updateos",
                                 iconBg: "home-updateos-bkgd",
                                 iconBgEn: "home-updateos-en-bkgd",
                                 pageIndex: YEnum.PageIndex.UpdateOS,
                                 featureid: YEnum.PageIndex.UpdateOS,
                                 enable: true,
                                 pageVisible: settingManager.osVersionDetected && !settingManager.updateOsRefused})

        // 语音助手
        if (qmlGlobal.checkFeature(YEnum.FEATURE_ASSISTANT) && !settingManager.isPepVersion) {
            mainMenuModel.append({iconFg: "home-speech", pageIndex: YEnum.PageIndex.Speech,
                                     featureid:YEnum.ParentsControlList.Speech,
                                     enable:settingManager.readparentcontrols(YEnum.ParentsControlList.Speech),
                                     pageVisible:settingManager.readhomepagesettings(YEnum.ParentsControlList.Speech)})
        }

        // 教材同步
        if (featureTextBookEnabled) {
            console.log("YIndexPage.qml===settingManager.isPepVersion", settingManager.isPepVersion)
            if (settingManager.isPepVersion) {
                mainMenuModel.insert(0, {iconFg: "home-textbook", pageIndex: YEnum.PageIndex.TextBook,
                                         featureid:YEnum.ParentsControlList.TextBook,
                                         enable:settingManager.readparentcontrols(YEnum.ParentsControlList.TextBook),
                                         pageVisible:settingManager.readhomepagesettings(YEnum.ParentsControlList.TextBook)})
            } else {
                mainMenuModel.append({iconFg: "home-textbook", pageIndex: YEnum.PageIndex.TextBook,
                                         featureid:YEnum.ParentsControlList.TextBook,
                                         enable:settingManager.readparentcontrols(YEnum.ParentsControlList.TextBook),
                                         pageVisible:settingManager.readhomepagesettings(YEnum.ParentsControlList.TextBook)})
            }
        }

        // 写作指导
        if (featureArticleEnabled && !settingManager.isPepVersion) {
            mainMenuModel.append({iconFg: "home-article", pageIndex: YEnum.PageIndex.Article,
                                     featureid:YEnum.ParentsControlList.Article,
                                     enable:settingManager.readparentcontrols(YEnum.ParentsControlList.Article),
                                     pageVisible:settingManager.readhomepagesettings(YEnum.ParentsControlList.Article)})
        }

        // AI好题本
        if (featureMathTutorEnabled && !settingManager.isPepVersion) {
            mainMenuModel.append({iconFg: "home-mathtutor", pageIndex: YEnum.PageIndex.MathTutor
                                     ,featureid:YEnum.ParentsControlList.MathTutor,
                                     enable:settingManager.readparentcontrols(YEnum.ParentsControlList.MathTutor),
                                     pageVisible:settingManager.readhomepagesettings(YEnum.ParentsControlList.MathTutor)})
        }

        // 口算批改
        if (featureMathCalculateEnabled && !settingManager.isPepVersion) {
            mainMenuModel.append({iconFg: "home-calculate", pageIndex: YEnum.PageIndex.Math,
                                     featureid:YEnum.ParentsControlList.Math,
                                     enable:settingManager.readparentcontrols(YEnum.ParentsControlList.Math),
                                     pageVisible:settingManager.readhomepagesettings(YEnum.ParentsControlList.Math)})
        }

        // 单词本
        mainMenuModel.append({iconFg: "home-fav", pageIndex: YEnum.PageIndex.Fav,
                                 featureid:YEnum.ParentsControlList.Fav,
                                 enable:settingManager.readparentcontrols(YEnum.ParentsControlList.Fav),
                                 pageVisible:settingManager.readhomepagesettings(YEnum.ParentsControlList.Fav)})

        // 图书点读
        if (qmlGlobal.checkFeature(YEnum.FEATURE_OID) && !settingManager.isPepVersion) {
            mainMenuModel.append({iconFg: "home-reading", pageIndex: YEnum.PageIndex.Reading,
                                     featureid:YEnum.ParentsControlList.Reading,
                                     enable:settingManager.readparentcontrols(YEnum.ParentsControlList.Reading),
                                     pageVisible:settingManager.readhomepagesettings(YEnum.ParentsControlList.Reading)})
        }

        // plugin menus 喜马拉雅
        if (!settingManager.isPepVersion) {
            const menus = pluginLoader.getPluginMenus()
            if (menus.length > 0) {
                menus.forEach(function(menuItem){
                    mainMenuModel.append({iconBg: menuItem.cover,
                                             iconBgEn: menuItem.coverEn,
                                             iconFg: menuItem.thumbnail,
                                             mainQml: menuItem.mainQml,
                                             domainTitle: menuItem.domainTitle,
                                             pageIndex: menuItem.pageIndex,
                                             featureid:YEnum.ParentsControlList.CooXmly,
                                             enable:settingManager.readparentcontrols(YEnum.ParentsControlList.CooXmly),
                                             pageVisible:settingManager.readhomepagesettings(YEnum.ParentsControlList.CooXmly)
                                         })
                })
            }
        }

        // 听力练习
        if (!settingManager.isPepVersion) {
            mainMenuModel.append({iconFg: "home-audioplayer", pageIndex: YEnum.PageIndex.Audioplayer,
                                     featureid:YEnum.ParentsControlList.Audioplayer,
                                     enable:settingManager.readparentcontrols(YEnum.ParentsControlList.Audioplayer),
                                     pageVisible:settingManager.readhomepagesettings(YEnum.ParentsControlList.Audioplayer)})
        }

        // 历史记录
        mainMenuModel.append({iconFg: "home-history", pageIndex: YEnum.PageIndex.History,
                                 featureid:YEnum.ParentsControlList.History,
                                 enable:settingManager.readparentcontrols(YEnum.ParentsControlList.History),
                                 pageVisible:settingManager.readhomepagesettings(YEnum.ParentsControlList.History)})

        // 插件管理（PenMods，考试模式下隐藏）
        if (typeof antiEmbs === 'undefined' || !antiEmbs.active) {
            mainMenuModel.append({iconFg: "qrc:/images/home/home-plugin.png",
                                  iconBg: "home-mathtutor-bkgd",
                                  iconBgEn: "home-mathtutor-bkgd",
                                  pageIndex: 9900,
                                  featureid: -1,
                                  enable: true,
                                  pageVisible: true})
        }

        // 系统设置
        mainMenuModel.append({iconFg: "home-setting", pageIndex: YEnum.PageIndex.Setting,
                                 featureid:YEnum.ParentsControlList.SystemSettings,
                                 enable:settingManager.readparentcontrols(YEnum.ParentsControlList.SystemSettings),
                                 pageVisible:settingManager.readhomepagesettings(YEnum.ParentsControlList.SystemSettings)})
    }

    YHorizontalListView {
        id: id_main_menu_list_view
        anchors.fill: parent
        anchors.topMargin: 80
        anchors.bottomMargin:  14
        anchors.leftMargin: 10
        anchors.rightMargin: 10
        model: mainMenuModel
        clip: false

        delegate: YHorizontalListViewDelegate {
            id: id_item_delegate
            // width: 232
            height: 160

            width:pageVisible ? 232 : 0
            YImage {
                anchors.centerIn: parent
                width: 220
                height: 160
                visible:pageVisible
                antialiasing: true
                sourceSize: Qt.size(220, 160)
                imageName: {
                    if (typeof iconBg != "undefined") {
                        return qmlTranslator.showLanguage == YEnum.EN_US ? iconBgEn : iconBg
                    }
                    return ("%1-bkgd").arg(iconFg)
                }
                opacity: id_main_menu_icon_button.pressed ? 0.6 : 1

                YImage {
                    id: id_main_menu_icon
                    anchors.left: parent.left
                    anchors.leftMargin: 22
                    anchors.top: parent.top
                    anchors.topMargin: 24
                    sourceSize: Qt.size(60, 60)
                    imageName: iconFg
                }

                YTextMedium {
                    id:feattxt
                    anchors.left: id_main_menu_icon.left
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: 24
                    font.pixelSize: {
                        if (settingManager.uiLanguage === YEnum.ZH_CN) {
                            return 28
                        } else {
                            switch (pageIndex) {
                            case YEnum.PageIndex.Speech:
                            case YEnum.PageIndex.Reading:
                            case YEnum.PageIndex.CooXmly:
                            case YEnum.PageIndex.Article:
                                return 25
                            default:
                                return 26
                            }
                        }
                    }
                    textFormat: YTextBase.RichText
                    font.bold: true
                    text: {
                        switch (pageIndex) {
                        case YEnum.PageIndex.Dict:
                            return YTranslateText.dict
                        case YEnum.PageIndex.UpdateOS:
                            return YTranslateText.updateOS
                        case YEnum.PageIndex.Speech:
                            return (typeof antiEmbs === "object" && antiEmbs !== null && antiEmbs.active)
                                    ? "语言助手"
                                    : "AI 助手"
                        case YEnum.PageIndex.Reading:
                            return YTranslateText.touchreading
                        case YEnum.PageIndex.TextBook:
                            return YTranslateText.textbookSynchronous
                        case YEnum.PageIndex.Math:
                            return YTranslateText.mathCalculate
                        case YEnum.PageIndex.MathTutor:
                            return YTranslateText.mathExercise
                        case YEnum.PageIndex.Fav:
                            return YTranslateText.favoriteWords
                        case YEnum.PageIndex.Audioplayer:
                            return YTranslateText.listeningExercise
                        case YEnum.PageIndex.History:
                            return YTranslateText.history
                        case YEnum.PageIndex.Setting:
                            return YTranslateText.settings
                        case YEnum.PageIndex.Article:
                            return YTranslateText.article
                        case YEnum.PageIndex.CooXmly:
                            return YTranslateText.ximalaya
                        case 9900:
                            return "插件管理"
                        default:
                            return ""
                        }
                    }
                }

                Rectangle{
                    visible: !enable
                    anchors.fill: parent
                    anchors.centerIn: parent
                    color: "transparent"

                    YImage {
                        id: id_main_menu_icon_enable
                        sourceSize: Qt.size(220, 160)
                        imageName: "home-lock"

                    }
                }
                YMouseArea {
                    id: id_main_menu_icon_button
                    anchors.fill: parent
                    objectName: "main.qml_mainMenuListView_pageIndex" + pageIndex
                    onClicked: {
                        if (typeof mainQml != "undefined") {
                            if(!enable)
                            {
                                baseSignals.showToast(YTranslateText.featuredisabledTips.arg(feattxt.text),
                                                      YColors.grayNormal);

                                return;
                            }
                            qmlGlobal.requestShowThirdQML(mainQml)
                            qmlGlobal.currentPageIndex = pageIndex


                        } else {
                            if(!enable)
                            {
                                baseSignals.showToast(YTranslateText.featuredisabledTips.arg(feattxt.text),
                                                      YColors.grayNormal);

                                return;
                            }

                            mainMenuClicked(pageIndex)
                        }
                    }
                }
            }
        }
    }

    ListModel {
        id: mainMenuModel
        Component.onCompleted: {
            updateMainMenuModel()

        }
    }
    Connections
    {
        target: websocketManager
        enabled: loginManager.isLogin && wifiManager.link
        function onEnanle_featureid(featid,fenable)
        {
            console.log("onEnanle_featureid>>>>>>>>>>>",featid)
            for(var i = 0; i< mainMenuModel.count; i++)
            {
                var tempid = mainMenuModel.get(i).featureid
                if(tempid === featid)
                {
                    mainMenuModel.setProperty(i,"enable",fenable)
                }

            }

        }
    }
    Connections
    {
        target: qmlGlobal
        function onSethidehomeItem(pageindex,visible)
        {
            console.log("onSethidehomeItem===",pageindex,visible)
            for(var i = 0; i< mainMenuModel.count; i++)
            {
                var tempid = mainMenuModel.get(i).featureid
                if(pageindex === tempid)
                {
                    mainMenuModel.setProperty(i,"pageVisible",visible)
                }

            }

        }
    }

    Connections {
        target: (typeof antiEmbs !== 'undefined') ? antiEmbs : null
        ignoreUnknownSignals: true
        function onActiveChanged() {
            updateMainMenuModel()
        }
    }

    Connections {
        target: loginManager
        ignoreUnknownSignals: true
        function onStatusChange(event, bSuc) {
            console.warn("YLoginPage.qml===LoginEvent.....: ", event, " bSuc: ", bSuc)
            if (bSuc) {
                updateMainMenuModel();
            }
        }
    }
}

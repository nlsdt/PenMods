import QtQuick 2.12
import com.youdao.pen 1.0

import BaseQml 1.0
import "../components"
import "../i18n"
import "../dicts/YDictKoUtils.js" as YDictKoUtils

YLoader {
    id: id_word_book_page_switch_loader
    anchors.fill: parent

    signal callCardView()

    property bool currentPageEnabled: true

    onLoaded: {
        wordBookManager.loadMore()
        checkEmpty()
    }

    function checkEmpty() {
        if (isLoaded) {
            wordBookManager.queryWordCountInDatabase()
            item.delayCheckEmptyTimer.recheck()
        }
    }

    Connections {
        target: wordBookManager
        ignoreUnknownSignals: true
        function onWordCountInDatabaseChanged(queryId, success, count) {
            console.warn("YWordBookPageSwitchLoader.qml===onWordCountInDatabaseChanged===queryId: ",
                         queryId, ", success:", success, ", count:", count)
            if (success) {
                item.delayCheckEmptyTimer.stop()
                item.delayCheckEmptyTimer.reshow()
            }
        }
    }

    sourceComponent: YBackgroundIgnoreMouseEvent {
        readonly property bool wordsListEmpty:
            (0 === id_word_book_page_switch_listview.count)

        readonly property alias delayCheckEmptyTimer: id_delay_check_empty_timer

        function showFilter() {
            id_word_book_filter_drawer_layer.show()
        }

        YVerticalTitleBar {
            enabled: currentPageEnabled
            onCallBack: {
                active = false
                wordBookManager.wipeData()
                backButtonClicked()
            }

            YIconButton {
                id: id_more_button_bg
                implicitWidth: 44
                implicitHeight: 44
                mouseAreaMargins: -18
                radius: height/2
                anchors.left: parent.left
                anchors.leftMargin: 16
                anchors.bottom: parent.bottom
                sourceSize: Qt.size(36, 36)
                imageName: "commons/more"
                onClicked: {
                    logManager.sendHttpLog("action=wordbook_settings_click")
                    id_word_book_page_switch_loader.item.showFilter()
                    console.log("YWordBookPageSwitchLoader.qml===callFilter")
                }
            }
        }

        YBaseListView {
            id: id_word_book_page_switch_listview
            anchors.fill: parent
            anchors.leftMargin: 90
            model: wordBookManager
            onMovingChanged: {
                if (!moving && atYEnd && wordBookManager.hasMore) {
                    wordBookManager.loadMore()
                }
            }

            delegate: id_normal_delegate
            header: id_header

            Component.onCompleted: {
                id_word_book_page.backButtonClicked.connect(function(){
                    id_word_book_page_switch_listview.header = null
                    id_header.destroy()
                    id_word_book_page_switch_listview.model = null
                    id_normal_delegate.destroy()
                })
            }

            footer: (wordBookManager.itemCount > 0 && wordBookManager.hasMore)
                    ? id_listview_loading_footer : null

            Component {
                id: id_listview_loading_footer

                YListViewLoadMoreFooter {}
            }
        }

        YWordBookPageEmptyTipComponent {
            id: id_empty_tip
            visible: false
            YTimer {
                id: id_delay_check_empty_timer
                interval: 300

                function recheck() {
                    id_empty_tip.visible = false
                    restart()
                }

                function reshow() {
                    id_empty_tip.visible = Qt.binding(function(){
                        return (0 === id_word_book_page_switch_listview.count)
                    })
                }

                onTriggered: {
                    reshow()
                }
                objectName: "YWordBookPageSwitchLoader.qml_id_delay_check_empty_timer"
            }
        }

        YWordBookFilterDrawerLayer {
            id: id_word_book_filter_drawer_layer
            onFilterChanged: {
                settingManager.wbLanguageFilter = langType
                wordBookManager.reload()
            }
        }

        YTimer {
            id: id_delay_pos_beginning_timer
            interval: 120
            onTriggered: {
                id_word_book_page_switch_listview.positionViewAtBeginning()
            }
            objectName: "YWordBookPageSwitchLoader.qml_id_delay_pos_beginning_timer"
        }

        Component.onCompleted: {
            id_delay_check_empty_timer.recheck()
            id_delay_pos_beginning_timer.restart()
        }
    }

    Component {
        id: id_normal_delegate
        YMouseArea {
            id: id_item_delegate
            width: ListView.view.width
            height: 86
            objectName: "YWordBookPageSwitchLoader.qml_itemDelegate_index" + index
            enabled: currentPageEnabled
            readonly property var jsonTranslate: JSON.parse(model.modelData.translate)
            readonly property bool containsDetails: typeof jsonTranslate.tran != "undefined"
            Rectangle {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.rightMargin: 16
                height: 76
                color: YColors.grayNormal
                opacity: parent.pressed ? 0.6 : 1
                radius: 16

                YTextMedium {
                    id: id_word_for_width
                    anchors.left: parent.left
                    anchors.leftMargin: id_word.anchors.leftMargin
                    anchors.verticalCenter: parent.verticalCenter
                    font: id_word.font
                    text: id_word.text
                    width: contentWidth
                    height: contentHeight
                    visible: false
                }

                YTextMedium {
                    id: id_word
                    anchors.left: parent.left
                    anchors.leftMargin: 20
                    anchors.verticalCenter: parent.verticalCenter
                    font.family: qmlGlobal.getFontFamilyNameByLangType(model.modelData.srcLangType)
                    text: model.modelData.content
                    width: Math.min(id_word_for_width.width,
                                    parent.width - 2*id_word_for_width.anchors.leftMargin)
                    height: contentHeight
                    elide: YTextEnUs.ElideRight
                }

                YTextBase {
                    id: id_property
                    anchors.left: id_word.right
                    anchors.leftMargin: 36
                    width: contentWidth
                    anchors.verticalCenter: parent.verticalCenter
                    font.pixelSize: 26
                    font.family: {
                        let ftName = qmlGlobal.getFontFamilyNameByLangType(model.modelData.srcLangType)
                        if (ftName === fontManager.fontFamilyEnUs) {
                            ftName = fontManager.fontFamilyClass
                        }
                        return ftName
                    }
                    font.styleName: model.modelData.srcLangType === YEnum.EN_US
                                    ? "Italic" : "normal"
                    color: YColors.grayText
                    text: jsonTranslate.pos
                }
                FontMetrics {
                    id: id_translate_font_metrics
                    font: id_translate.font
                }
                YTextBase {
                    id: id_translate
                    anchors.left: (id_property.text.length > 0) ? id_property.right : id_word.right
                    anchors.leftMargin: 12
                    anchors.right: parent.right
                    anchors.rightMargin: 20
                    anchors.verticalCenter: parent.verticalCenter
                    font.pixelSize: 26
                    font.family: qmlGlobal.getFontFamilyNameByLangType(model.modelData.dstLangType)
                    color: YColors.grayText
                    visible: (id_word.width + 2*id_word_for_width.anchors.leftMargin
                              + id_translate.anchors.leftMargin
                              + 20 /* too small too ugly*/) < parent.width
                    text: {
                        const elideText = id_translate_font_metrics.elidedText(
                        jsonTranslate.tran, YTextBase.ElideRight, id_translate.width)
                        if (YEnum.KO_KR === model.modelData.dstLangType) {
                            return YDictKoUtils.formattedChineseText(elideText)
                        }
                        return elideText
                    }
                    maximumLineCount: 1
                    elide: YTextEnUs.ElideRight
                    textFormat: YTextBase.RichText
                }
            }

            onClicked: {
                console.log("YWordBookPageSwitchLoader.qml====item_clicked",model.modelData.content,model.modelData.srcLang,model.modelData.dstLang)
                var res = true
                if(settingManager.transLanguage === YEnum.JA_JP){
                    res = resultManager.entryResult(model.modelData.content, "", "", YEnum.PageIndex.Fav, 1, false)
                }else {
                    res = resultManager.entryResult(model.modelData.content,
                                                                             model.modelData.srcLang,
                                                                             model.modelData.dstLang,
                                                                             YEnum.PageIndex.Fav)
                }
                if (!res) {
                    baseSignals.showToast(YTranslateText.queryFaildPleaseTryAgain, "#2D2E33")
                } else {
                    qmlGlobal.showDictPage(YEnum.PageIndex.Fav)
                }
            }
        }

        /*
20:18:05.684 [debg]: [YWordBookManager] YWordEntity to string:content: home
translate: {"phonics":[{"position":[0],"sound":"h"},{"position":[1,3],"sound":"əʊ"},{"position":[2],"sound":"m_back"}],"uk":"həʊm","m":[{"m":"家；住所; 家；家庭; （强调归属感的）家乡，故乡，祖国","pos":"n."},{"m":"到家；向家；在家","pos":"adv."}],"us":"hoʊm"}
srcLang: en
dstLang: zh-CHS
dictType: 0
wordGroupType: 4
languageType: 1
16:08:37.065 [debg]: [YWordBookManager] addToWordBook from db start
16:08:37.066 [debg]: [YWordBookManager] YWordEntity to string:content: 发音
translate: {"antonyms":[],"meanings":[{"pos":"动","value":"发出声音（多指发出乐音或语音）","example":["<b>发音</b>方法不同","<b>发音</b>准确。"]}],"pinyin":["fā","yīn"],"synonyms":[]}
srcLang: zh-CHS
dstLang: en
dictType: 200
wordGroupType: 1
languageType: 0
16:08:37.067 [debg]: [YWordBookManager] YWordEntity to string:content: 系列
translate: {"antonyms":[],"meanings":[{"pos":"名","value":"组合成套的、性质相同或相近而又相关联的事物","example":["同属一个<b>系列</b>","<b>系列</b>产品。"]}],"pinyin":["xì","liè"],"synonyms":[]}
srcLang: zh-CHS
dstLang: en
dictType: 200
wordGroupType: 1
languageType: 0
16:08:37.068 [debg]: [YWordBookManager] YWordEntity to string:content: 笔
translate: {"details":[{"antonyms":[],"end":["铅笔","钢笔","手笔","走笔","着笔","曲笔","落笔","大笔","试笔","彩笔","粉笔","援笔","纸笔","随笔","湖笔","宣笔","败笔","伏笔","提笔","信笔","毛笔","绝笔","亲笔"," 振笔","辍笔","画笔","动笔","几笔","秉笔","文笔","简笔","起笔","妙笔","下笔","水笔","执笔","刀笔"],"idioms":["笔走龙蛇","春秋笔法","神来之笔","生花妙笔","投笔从戎","一笔不苟"],"meanings":[{"value":"用于写字、绘画的工具，古代笔杆用竹制成","example":["钢笔","毛笔","铅笔","笔墨纸砚","提笔忘字"]},{"value":"写，记载，记录，或与写作有关的","example":["代笔","亲笔","笔者","笔名","笔录"]},{"value":"写文章或作画的技巧","example":["文笔","伏笔","笔法","曲笔","大笔点绕"]},{"value":"散文，文章，相对于诗体而言的记叙类文学体裁","example":["笔述","随笔","文笔"]},{"value":"不弯的，如笔般直挺的","example":["笔直","笔挺","笔立"]},{"value":"写下的点、画、文字或其他痕迹","example":["绝笔","笔迹","笔画","笔顺"]},{"value":"指汉字的笔画，即横、直、撇、捺等","example":["起笔","笔形","笔顺","笔脚","末笔"]},{"value":"用作量词，用于计算款项、书画作品或笔画的数量","example":["一笔账","一笔钱","一共五笔","一笔好字"]}],"pinyin":"bǐ","start":["笔记","笔者","笔下","笔墨","笔直","笔记本","笔底","笔杆","笔触","笔挺","笔锋","笔立","笔端","笔名","笔调","笔债","笔意","笔头","笔管","笔力","笔体","笔法"],"synonyms":[]}],"radical":"竹(⺮)","stroke":["丿","一","丶","丿","一","丶","丿","一","一","乚"],"strokeCount":10,"structure":"上下结构"}
srcLang: zh-CHS
dstLang: en
dictType: 200
wordGroupType: 2
languageType: 0
16:08:37.068 [debg]: [YWordBookManager] YWordEntity to string:content: 词典
translate: {"antonyms":[],"meanings":[{"pos":"名","value":"收集词语，按一定顺序编排，加以注音、释义等，供人查阅参考的工具书。","example":[]}],"pinyin":["cí","diǎn"],"synonyms":["辞书"]}
srcLang: zh-CHS
dstLang: en
dictType: 200
wordGroupType: 1
languageType: 0
16:08:37.069 [debg]: [YWordBookManager] addToWordBook from db end
16:08:38.208 [warn]:
        */
    }

    Component {
        id: id_header

        Item {
            id: id_title_bar
            width: ListView.view.width
            implicitHeight: 80
            enabled: currentPageEnabled

            YTabsTitleBar {
                id: id_tab_title_bar
                anchors.top: id_title_bar.top
                anchors.topMargin: 24
                anchors.left: id_title_bar.left
                anchors.leftMargin: 20
                namesArray: settingManager.isPepVersion ? [YTranslateText.word]
                          : workBookTweaks.phraseTab ? [YTranslateText.word, "短语", YTranslateText.sentence]
                          : [YTranslateText.word, YTranslateText.sentence]

                onCurrentIndexChanged: {
                    updateUI()
                    checkEmpty()
                }

                function updateUI() {
                    if (workBookTweaks.phraseTab && !settingManager.isPepVersion) {
                        wordBookManager.tabType = currentIndex === 0 ? 2 : (currentIndex === 1 ? 3 : YEnum.WGT_Sentence);
                        return;
                    }
                    if (currentIndex === 0) {
                        wordBookManager.tabType = YEnum.WGT_Ch_Group;
                    } else if (currentIndex === 1) {
                        wordBookManager.tabType = YEnum.WGT_Sentence;
                        logManager.sendHttpLog("action=wordbook_sentence_click")
                    } else {
                        console.log("index not hold : ", currentIndex)
                    }
                }

                Component.onCompleted: {
                    updateUI()
                }
                Connections {
                    target: workBookTweaks
                    function onPhraseTabChanged() {
                        id_tab_title_bar.currentIndex = 0;
                        id_tab_title_bar.updateUI();
                    }
                }
            }

            YIconLabelButton {
                color: "transparent"
                radius: 0
                implicitHeight: 30
                sourceSize: Qt.size(28, 28)
                imageName: "wordbook/switch"
                anchors.right: id_title_bar.right
                anchors.top: id_title_bar.top
                anchors.topMargin: 25
                pixelSize: 24
                text: YTranslateText.cardModel
                visible: (id_tab_title_bar.currentIndex === 0)
                         && id_word_book_page_switch_loader.active
                         && id_word_book_page_switch_loader.isLoaded
                         && !id_word_book_page_switch_loader.item.wordsListEmpty
                onClicked: {
                    callCardView()
                    console.log("YWordBookPageSwitchLoader.qml===callCardView")
                }
            }
        }

    }

}


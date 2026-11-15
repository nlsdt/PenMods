import QtQuick 2.12
import com.youdao.pen 1.0

import BaseQml 1.0
import "./dicts"
import "./i18n"
import "./components"

YBackButtonPage {
    id: id_dict_detail_page
    objectName: "YPage===YDictDetailPage.qml"

    property int dictType: YEnum.NoDict
    property string content: ""
    property bool isNewShow: false

    function getDictJsonObject(){
        try {
                    let jsonObj = JSON.parse(content)
                    if (typeof jsonObj == "object") {
                        return jsonObj
                    }
                } catch(e) {
                    console.log("YDictDetailPage.qml === getDictJsonObject parse error: ", e)
                }
                return new Object
    }

    YTimer {
        id: id_delay_active
        interval: 6
        onTriggered: {
            isNewShow = true
        }
    }

    onContentChanged: {
        if(content.length) {
            isNewShow = false
            id_delay_active.restart()
            //isNewShow = true
        }
        dictJson = getDictJsonObject()
    }

    property var dictJson: {
        try {
            let jsonObj = JSON.parse(content)
            if (typeof jsonObj == "object") {
                return jsonObj
            }
        } catch(e) {
            console.log("YDictDetailPage.qml === dictJson parse error: ", e)
        }
        return new Object
    }
    property alias title: id_title_text.text
    property bool showPoemTitle: false
    property var showOxfordDetailMeaningblock: false
    property var showOxfordDetailMeaningblockName: ""
    property var backLastPos:null

    Flickable {
        id: id_container_flickable
        anchors.fill: parent
        anchors.leftMargin: 90
        anchors.rightMargin: 16
        z: id_dict_detail_page.z + 1
        contentHeight: id_dict_content_column.height
        interactive: !id_dict_content_loader.moving

        Column {
            id: id_dict_content_column
            anchors.left: parent.left
            anchors.right: parent.right
            spacing: 0

            YText {
                id: id_title_text
                width: parent.width
                height: 80
                //horizontalAlignment: YText.AlignHCenter
                verticalAlignment: YText.AlignVCenter
                font.pixelSize: 26
                color: YColors.grayText
                visible: {
                    if(dictType === YEnum.NetTran) return false
                    return dictType !== YEnum.DtBusinessAnCh
                }
            }

            Rectangle {
                id: id_word_bg
                width: id_poem_title_origin.paintedWidth + 16
                height: id_poem_title_origin.paintedHeight + 6
                color: "#171717"
                radius: 4
                clip: true
                visible: showPoemTitle

                YTextBase {
                    id: id_poem_title_origin
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.leftMargin: 8
                    anchors.top: parent.top
                    anchors.topMargin: 3
                    height: parent.height
                    width: Math.min(228, paintedWidth + 16)
                    font.family: fontManager.fontFamilyZhCn
                    font.letterSpacing: 2
                    font.pixelSize: text.length > 5 ? 22 : 32
                    color: YColors.white
                    text: id_title_text.text
                    wrapMode: text.length > 5 ? YTextBase.Wrap : Text.NoWrap
                } // Text id_poem_title_origin
            }

            YSpacingForColumn {
                implicitHeight: 10
                visible: id_word_rectangle.visible
            }

            Rectangle {
                id: id_word_rectangle
                height: 52
                width: parent.width
                color: "black"
                visible: dictType === YEnum.DtBusinessAnCh
                Row {
                    anchors.fill: parent
                    spacing: 10
                    YText {
                        id: id_title_word
                        height: parent.height
                        verticalAlignment: YText.AlignVCenter
                        font.pixelSize: 26
                        color: YColors.grayText
                        text: id_title_text.text
                    }
                    // YAudioPlayIconLabelHCenterButton {
                    //     height: parent.height
                    //     color: YColors.grayNormal
                    //     textItem.font.pixelSize: 26
                    //     textItem.font.family: fontManager.fontFamilyXinHuaXiHei
                    //     text: model.modelData
                    //     textItem.color: true ? YColors.red : YColors.white
                    //     iconItem.visible: true//isCurrentSelectedPinyin
                    //     width: (iconItem.visible ? iconItem.width : 0) + textItem.width + 20 * 2
                    //     // readonly property bool isCurrentSelectedPinyin : chPinyinSelected === model.modelData

                    //     onValidClicked: {
                    //         console.log("YDictPage.qml === id_dict_ch_pinyin_list.btn.onClicked text: ", text)
                    //         qmlGlobal.audioPlayId = soundCenter.play("chen1 fei2","ch")
                    //         // chPinyinSelected = text
                    //         // resultManager.phoneticSymbolJson = text
                    //         // var nAutoPronType =  YEnum.XinHua
                    //         // if(typeof pinyinNumsList[index] !== "undefined") {
                    //         //     qmlGlobal.audioPlayId = soundCenter.play("chen1,fei2",
                    //         //                                                 "zh",
                    //         //                                                 "chen1,fei2", nAutoPronType + 1)
                    //         // }
                    //         // else
                    //         //     qmlGlobal.soundWGTCh()
                    //     }
                    // }
                }
            }

            YSpacingForColumn {
                implicitHeight: 10
                visible: id_word_rectangle.visible
            }

            YLoader {
                id: id_dict_content_loader
                asynchronous: false

                active: (YEnum.DtChLarge === dictType
                        || YEnum.DtChAncientWord === dictType
                        || YEnum.DtChPoemDict === dictType
                        //英文词典
                        || YEnum.DtOxford === dictType
                        || YEnum.DtSenior === dictType
                        || YEnum.DtWebster === dictType
                        || YEnum.DtEnChKid === dictType
                        //韩文词典
                        || YEnum.DtChKo === dictType
                        || YEnum.DtKoCh === dictType
                        || YEnum.DtChIdiom === dictType)
                        || YEnum.DtBusinessAnCh === dictType
                        || YEnum.NetTran === dictType
                        && JSON.stringify(dictJson) !== '{}'
                        && isNewShow
                sourceComponent: {
                    switch(title){
                    case YTranslateText.fixedCollocation:
                        return id_dt_mango_kid_english_fixed_collocation_component
                    case YTranslateText.synonymsAndSynonyms:
                        return id_dt_mango_kid_english_synonymsAndSynonyms_component
                    case YTranslateText.idiomStory:
                         return id_dt_idiom_story_component
                    case YTranslateText.idiomSource:
                         return id_dt_idiom_source_component

                     }
                    console.log("seven:YEnum:dictType:",dictType)
                    switch (dictType) {
                    case YEnum.DtChLarge:
                        return id_dt_ch_large_component
                    case YEnum.DtChAncientWord:
                        return id_dt_ch_ancientword_component
                    case YEnum.DtChPoemDict:
                        return id_dt_ch_poemdict_component
                    case YEnum.DtSenior:
                        return id_dt_senior_component
                    case YEnum.DtWebster:
                        return id_dt_webster_component
                    case YEnum.DtOxford:
                        return id_dt_oxford_component
                    case YEnum.DtChKo:
                        return id_dt_chko_component
                    case YEnum.DtKoCh:
                        return id_dt_koch_component
                    case YEnum.DtBusinessAnCh:
                        return id_dt_busAnch_component
                    case YEnum.NetTran:
                        console.log("seven:YEnum.NetTran:id_dt_ai_sentence_component")
                        return id_dt_ai_sentence_component
                    default:
                        return null
                    }
                }
                Component {
                    id: id_dt_mango_kid_english_synonymsAndSynonyms_component
                    YDictTypeDtMangoKidEnglishSynonymsAndSynonymsDetail{
                        width: id_dict_content_column.width
                    }
                }
                Component {
                    id: id_dt_mango_kid_english_fixed_collocation_component
                    YDictTypeDtMangoKidEnglishFixedCollocationDetail {
                        width: id_dict_content_column.width
                    }
                }

                Component {
                    id: id_dt_ch_large_component
                    YDictTypeDtChLargeDetail {
                        width: id_dict_content_column.width
                    }
                }

                Component {
                    id: id_dt_ch_ancientword_component
                    YDictTypeDtChAncientWordDetail {
                        width: id_dict_content_column.width
                    }
                }

                Component {
                    id: id_dt_ch_poemdict_component
                    YDictTypeDtChPoemDictDetail {
                        width: id_dict_content_column.width
                    }
                }
                Component {
                    id: id_dt_idiom_story_component
                    YDictTypeDtIdiomStoryDetail {
                        width: id_dict_content_column.width
                    }
                }

                Component {
                    id: id_dt_idiom_source_component
                    YDictTypeDtIdiomSourceDetail {
                        width: id_dict_content_column.width
                    }
                }

                Component {
                    id: id_dt_senior_component
                    YDictTypeDtSeniorDetail {
                        width: id_dict_content_column.width
                    }
                }

                Component {
                    id: id_dt_webster_component
                    YDictTypeDtWebsterDetail {
                        width: id_dict_content_column.width
                    }
                }

                Component {
                    id: id_dt_oxford_component
                    YDictTypeDtOxfordDetail {
                        width: id_dict_content_column.width

                        onShowMeaningblockChanged: {
                            console.log("YDictDetailPage.qml===id_dt_oxford_component.onShowMeaningblockChanged showMeaningblockName:", showMeaningblockName)
                            if (showMeaningblock) {
                                showOxfordDetailMeaningblockName = showMeaningblockName
                                id_container_flickable.contentY = 0
                            } else {
                                showOxfordDetailMeaningblockName = wordText
                            }
                            showOxfordDetailMeaningblock = showMeaningblock
                        }
                    }
                }

                Component {
                    id: id_dt_chko_component
                    YDictTypeDtChKoDetail {
                        width: id_dict_content_column.width
                    }
                }

                Component {
                    id: id_dt_koch_component
                    YDictTypeDtKoChDetail {
                        width: id_dict_content_column.width
                    }
                }

                Component {
                    id: id_dt_busAnch_component;
                    YDictBusinessAnchWordDetail {
                        width: id_dict_content_column.width
                    }
                }

                Component {
                    id: id_dt_ai_sentence_component;
                    YAISentenceAnalysisPage {
                        width: id_dict_content_column.width
                    }
                }

            }

            YSpacingForColumn {
                implicitHeight: 30
            }
        }
    }

    YIconButton {
        id: id_to_top_button
        opacity: mouseAreaItem.pressed || !enabled ? 0.2 : 1
        implicitWidth: 44
        implicitHeight: 44
        radius: height/2
        mouseAreaMargins: -25
        anchors.left: parent.left
        anchors.leftMargin: 16
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 18
        imageName: "dict/to-top"
        visible: id_container_flickable.contentY > id_container_flickable.height * 2
        onValidClicked: {
            id_container_flickable.contentY = 0
        }
    }

    ignoreDefaultBackButtonClicked: true
    onBackButtonClickedCallback: {
        if (showOxfordDetailMeaningblock) {
            if (id_dict_content_loader.isLoaded) {
                id_dict_content_loader.item.meaningblockType = -1
                id_dict_content_loader.item.showMeaningblock = false
                id_container_flickable.contentY = 0
                return
            }
        }
        backButtonClicked()
    }

    onShowOxfordDetailMeaningblockChanged: {
        title = showOxfordDetailMeaningblockName
        console.log("YDictDetailPage.qml===onShowOxfordDetailMeaningblockChanged title:", title)
    }

    Component.onDestruction: {
        console.log("YDictDetailPage.qml===Component.onDestruction===called")
    }

    onVisibleChanged: {
        if (visible) {
            qmlGlobal.currentPageIndex = YEnum.PageIndex.DictDetail
            id_container_flickable.contentY = 0
            if(backLastPos!=null){
                id_container_flickable.contentY = backLastPos
                backLastPos=null
            }
        } else {
            soundCenter.stop()
        }
    }
}


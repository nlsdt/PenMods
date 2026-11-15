import QtQuick 2.12
import com.youdao.pen 1.0

import BaseQml 1.0

YBaseListView {
    id: id_dict_listview
    anchors.left: parent.left
    anchors.right: parent.right
    implicitHeight: headerHeight
    orientation: Qt.Horizontal
    model: resultManager.mainQueryBreakList
    highlightFollowsCurrentItem: false
    focus: true
    delegate: id_delegate
    highlight: displayWords ? id_highlight : null
    currentIndex: tagsIndex
    readonly property var koSpecialChar: ["-", ":", "^"]
    property var headerHeight: 40
    property bool isReturn: !resultManager.isReturnSearch
    onIsReturnChanged: {
        isFirstShow = isReturn
    }
    property bool isFirstShow: !resultManager.isReturnSearch
    property var highLightModel: []
    property var indexStack: []

    header: {
//        if (0 === count) {
//            return null
//        }
//        if (0 === qmlGlobal.scanType) {
//            return id_header_point_scan
//        }
//        switch (resultManager.mainQueryType) {
//        case YEnum.WGT_Sentence:
//        case YEnum.WGT_Ch_Group:
//        case YEnum.WGT_En_Group:
//        case YEnum.WGT_Ko_Group:
//            return id_header
//        default:
            return null
        //}
    }

    Component {
        id: id_delegate
        YMouseArea {
            width: ((index === tagsIndex) ? id_dict_listview.highlightItem.width : id_word_bg.width) + 20/*(displayWords ? 6 : 12)*/
            height: headerHeight
            enabled: id_word_bg.clickable
            //z: id_dict_page.z - 1
            objectName: "YDictPage.qml_id_delegate_index" + index
            property alias word: id_word.text
            property int charType: model.modelData.charType
            property alias wordFontFamily: id_word.font.family
            Rectangle {
                id: id_word_bg
                width: id_word.width + (/*(displayWords && clickable) ? 20 :*/ 0)
                implicitHeight: headerHeight
                color: /*(displayWords && clickable) ? YColors.grayNormal :*/ "transparent"
                radius: 16

                readonly property bool clickable: YEnum.CT_PUNC !== model.modelData.charType

                YTextBase {
                    id: id_word
                    anchors.centerIn: parent
                    font.family: headFontFamily(model.modelData.charType)
                    font.letterSpacing: {
                        switch (model.modelData.charType) {
                        case YEnum.CT_CJK:
                            if (index === tagsIndex) {
                                return 20
                            }
                            return 10
                        default:
                            return 0
                        }
                    }
                    width: contentWidth - id_word.font.letterSpacing
                    font.pixelSize: 30
                    color: YColors.grayText
                    font.weight: Font.Bold
                    text: model.modelData.content
                }
                opacity: isFirstShow && index !== tagsIndex ? 1 : 0
            }
            onClicked: {
                if (index !== tagsIndex) {
                    resultManager.autoSelectIndex = index
                    id_fav_word_button.queryResult(model.modelData.content)
                }
            }
        }
    }

    Component {
        id: id_header
        YDictPageHeaderNormal {
        }
    }

    Component {
        id: id_header_point_scan
        YDictPageHeaderPointScan {
        }
    }

    Component {
        id: id_highlight
        Item {
            width: Math.max(id_word.width + 20, id_repeater_container_row.width)
            implicitHeight: headerHeight
            x: (-1 === tagsIndex || id_dict_listview.currentItem == null) ? 0 : id_dict_listview.currentItem.x
            //z: id_dict_page.z + 1

//            Rectangle {
//                anchors.fill: parent
//                radius: 16
//                gradient: YColors.redDict
//                opacity: id_highlight_view_holder.highlightViewEnabled ? 0 : 1
//            }

            YTextBase {
                id: id_word
                anchors.centerIn: parent
                font.family: (-1 === tagsIndex || id_dict_listview.currentItem == null)
                             ? fontManager.fontFamilyZhCn : id_dict_listview.currentItem.wordFontFamily
                font.pixelSize: 30
                font.letterSpacing: {
                    if (-1 === tagsIndex || id_dict_listview.currentItem == null) {
                        return 0
                    }
                    switch (id_dict_listview.currentItem.charType) {
                    case YEnum.CT_CJK:
                        return 0
                    default:
                        return 0
                    }
                }
                width: contentWidth - id_word.font.letterSpacing
                color: "#FFFFFF"
                font.weight: Font.Bold
                text: (-1 === tagsIndex || id_dict_listview.currentItem == null) ? "" : id_dict_listview.currentItem.word
                opacity: id_highlight_view_holder.highlightViewEnabled ? 0 : 1
            }

            YMouseArea {
                id: id_highlight_view_holder
                anchors.fill: parent
                property int holdIndex: -2
                property var charactersList: null
                readonly property bool highlightViewEnabled: holdIndex === tagsIndex
                enabled: (-1 !== tagsIndex)
                         && ((YEnum.WGT_Ch_Group === resultManager.currentQueryType)
                             ||(YEnum.WGT_En_Group === resultManager.currentQueryType)
                             ||(YEnum.WGT_Ko_Group === resultManager.currentQueryType))
                         && (id_word.text.length > 1)
                onClicked: {
                    isFirstShow = false
                    indexStack.push(tagsIndex)
                    switch (resultManager.currentQueryType) {
                    case YEnum.WGT_En_Group:
                        charactersList = qmlGlobal.englishSentenceToWordsList(id_word.text)
                        break
                    case YEnum.WGT_Ko_Group:
                        charactersList = qmlGlobal.koreanToCharactersList(id_word.text)
                        break
                    case YEnum.WGT_Ch_Group:
                    default:
                        charactersList = qmlGlobal.chineseToCharactersList(id_word.text)
                        break
                    }

                    console.log("*************charactersList::::"+JSON.stringify(charactersList))
                    holdIndex = tagsIndex
                    //highLightModel.push(charactersList)
                    id_repeater.checkedItem(mouseX)
                }
                onHighlightViewEnabledChanged: {
                    if (!highlightViewEnabled) {
                        charactersList = null
                        holdIndex = -2
                    }
                }
                objectName: "YDictPage.qml_id_highlight_view_holder"
                Row {
                    id: id_repeater_container_row
                    anchors.centerIn: parent
                    spacing: 20
                    Repeater {
                        id: id_repeater
                        model: id_highlight_view_holder.highlightViewEnabled ? id_highlight_view_holder.charactersList : null
                        property int curIndex: -1
                        function checkedItem(posX) {
                            if (YEnum.WGT_Ch_Group === resultManager.currentQueryType) {
                                const wordItem = itemAt(0)
                                if (null !== wordItem) {
                                    const repeaterItemWidth = wordItem.width + 6
                                    const touchIndex = Math.floor(posX / repeaterItemWidth)
                                    id_repeater.curIndex = touchIndex.bound(0, id_repeater.count - 1)
                                    id_fav_word_button.queryResult(itemAt(id_repeater.curIndex).itemWord)
                                }
                            } else if (YEnum.WGT_Ko_Group === resultManager.currentQueryType) {
                                const wordKoItem = itemAt(0)
                                if (null !== wordKoItem) {
                                    const repeaterKoItemWidth = wordKoItem.width + 6
                                    let touchKoIndex = Math.floor(posX / repeaterKoItemWidth)
                                    if (koSpecialChar.indexOf(itemAt(id_repeater.curIndex).itemWord) >= 0) {
                                        touchKoIndex += touchKoIndex > 0 ? -1 : 1
                                    }
                                    id_repeater.curIndex = touchKoIndex.bound(0, id_repeater.count - 1)
                                    id_fav_word_button.queryResult(itemAt(touchKoIndex).itemWord)
                                }
                            } else {
                                let startX = 0
                                let maybeIndex = 0
                                while ((startX + itemAt(maybeIndex).width + 6 < posX) && (maybeIndex < count - 1)) {
                                    startX += (itemAt(maybeIndex).width + 6)
                                    ++maybeIndex
                                }
                                id_repeater.curIndex = maybeIndex.bound(0, id_repeater.count - 1)
                                id_fav_word_button.queryResult(itemAt(id_repeater.curIndex).itemWord)
                            }
                        }
                        delegate: Rectangle {
                            id: id_repeater_item_content_bg
                            width: id_repeater_item_content.contentWidth + 0
                            implicitHeight: headerHeight
                            radius: 16
                            color: /*isSpecialChar ?*/ "transparent" /*: YColors.grayNormal*/
                            readonly property bool checked: id_repeater.curIndex === index
                            visible: checked
                            readonly property string itemWord: model.modelData
                            readonly property bool isSpecialChar: koSpecialChar.indexOf(itemWord) >= 0 //韩语词组分词会有此符号，特殊处理
//                            Rectangle {
//                                id: id_repeater_item_highlight_bg
//                                radius: parent.radius
//                                anchors.fill: parent
//                                visible: id_repeater.curIndex === index
//                                gradient: YColors.redDict
//                            }
                            YTextBase {
                                id: id_repeater_item_content
                                anchors.centerIn: parent
                                font.family: (-1 === tagsIndex || id_dict_listview.currentItem == null)
                                             ? fontManager.fontFamilyZhCn : id_dict_listview.currentItem.wordFontFamily
                                font.pixelSize: 30
                                font.weight: Font.Bold
                                font.letterSpacing: {
                                    switch (id_dict_listview.currentItem.charType) {
                                    case YEnum.CT_CJK:
                                        return 0
                                    default:
                                        return 0
                                    }
                                }
                                width: contentWidth - id_repeater_item_content.font.letterSpacing
                                color: id_repeater_item_content_bg.checked ? YColors.white : YColors.grayText
                                text: id_repeater_item_content_bg.itemWord
                            }
                            YMouseArea {
                                id: id_repeater_item_mouse_area
                                anchors.fill: parent
                                anchors.rightMargin: -6
                                onClicked: {
                                    isFirstShow = false
                                    if (id_repeater_item_content_bg.isSpecialChar) return
                                    id_repeater.curIndex = index
                                    indexStack.push(index)
                                    highLightModel.push(id_highlight_view_holder.charactersList)
                                    console.log("************** highLightModel.push:"+JSON.stringify(highLightModel)+"indexStack:"+JSON.stringify(indexStack))
                                    switch (resultManager.currentQueryType) {
                                    case YEnum.WGT_En_Group:
                                        id_highlight_view_holder.charactersList = qmlGlobal.englishSentenceToWordsList(id_word.text)
                                        break
                                    case YEnum.WGT_Ko_Group:
                                        id_highlight_view_holder.charactersList = qmlGlobal.koreanToCharactersList(id_word.text)
                                        break
                                    case YEnum.WGT_Ch_Group:
                                    default:
                                        id_highlight_view_holder.charactersList = qmlGlobal.chineseToCharactersList(id_word.text)
                                        break
                                    }
                                    //holdIndex = tagsIndex
                                    id_repeater.checkedItem(mouseX)
                                    //id_fav_word_button.queryResult(id_repeater_item_content_bg.itemWord)
                                }
                                objectName: "YDictPage.qml_id_repeater_item_mouse_area"
                            }
                        }
                    }
                }
            }
        }
    }

    footer: YSpacing {
        implicitWidth: 10
        implicitHeight: headerHeight
    }
}


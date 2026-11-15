import QtQuick 2.12

import BaseQml 1.0
import "../i18n"

import "./YDictOxfordUtilities.js" as OxfordUtilities
import "./YDictOxfordModel.js" as OxfordModel

Item {
    id: id_dt_oxford_detail_item
    height: id_wordList_column.height

    property var dictJson: id_dict_detail_page.dictJson
    property var oxfordModel: OxfordModel.createOxfordModel()
    property var wordText: ""
    property var wordListCount: 0
    property var currentMeanIdx: 0
    property var posList: []
    property var showMeaningblock: false
    property var showMeaningblockName: wordText
    property var meaningblockType: -1
    readonly property var meanIndex: wordListCount > 1 ? currentMeanIdx : 0
    readonly property var posListCur: posList.length > 0 ? (wordListCount > 1 ? posList[meanIndex] : [posList[meanIndex][currentMeanIdx]]) : []
    readonly property var menuList: OxfordModel.getMenuList(oxfordModel, currentMeanIdx)

    onMeanIndexChanged: {
        console.log("YDictTypeDtOxfordDetail.qml === onMeanIndexChanged")
    }

    onPosListCurChanged: {
        console.log("YDictTypeDtOxfordDetail.qml === onPosListCurChanged")
    }

    onMenuListChanged: {
        console.log("YDictTypeDtOxfordDetail.qml === onMenuListChanged")
    }

    onDictJsonChanged: {
        oxfordModel = OxfordModel.createOxfordModelByJsonData(dictJson)
        wordText = oxfordModel.wordText
        wordListCount = oxfordModel.wordListCount
        posList = oxfordModel.posList
        currentMeanIdx = 0
        showMeaningblock = false
        showMeaningblockName = wordText
        meaningblockType = -1
    }

    Column {
        id: id_wordList_column
        width: parent.width
        spacing: 20

        Row {
            id: id_wordList_hw_row
            spacing: 10
            visible: id_wordList_hw_repeater.count > 1 && !showMeaningblock

            Repeater {
                id: id_wordList_hw_repeater
                model: wordListCount > 1 ? [wordText + '<sup>1</sup>', wordText + '<sup>2</sup>'] : oxfordModel.posList[0]

                YMouseArea {
                    id: id_word_hw_MouseArea
                    width: id_word_hw_background.width
                    height: 52
                    objectName: "YDictTypeDtOxford.qml_wordListhw_index" + index

                    Rectangle {
                        id: id_word_hw_background
                        width: id_word_hw_text.width + 32 * 2
                        height: parent.height
                        color: YColors.grayNormal
                        opacity: parent.pressed ? 0.6 : 1
                        radius: 38

                        YTextMedium {
                            id: id_word_hw_text
                            anchors.centerIn: parent
                            font.family: fontManager.fontFamilyClass
                            font.styleName: "Italic"
                            font.weight: Font.Bold
                            font.pixelSize: 26
                            textFormat: YTextMedium.RichText
                            color: index === currentMeanIdx ? YColors.red : YColors.white
                            width: paintedWidth
                            height: paintedHeight
                            text: model.modelData // pos.remove('*');
                        }

                    }

                    onClicked: {
                        if (currentMeanIdx !== index) {
                            if (wordListCount === 0) {
                                return
                            } else if (wordListCount === 1 && index >= oxfordModel.posList[0].length) {
                                return;
                            } else if (wordListCount > 1 && index >= 2/*MAX_MEAN_GROUP*/) {
                                return;
                            }
                            currentMeanIdx = index;
                        }
                    }
                }
            } // id_wordList_hw_repeater

        } // Row id_wordList_hw_row

        YDictTypeDtOxfordHeader {
            oxfordModel: id_dt_oxford_detail_item.oxfordModel
            currentMeanIdx: id_dt_oxford_detail_item.currentMeanIdx
            isDetailePage: true
            visible: !showMeaningblock
        }

        Grid {
            id: id_button_menu_grid
            columnSpacing: 12
            rowSpacing: 10
            columns: 2
            horizontalItemAlignment: Grid.AlignHCenter
            verticalItemAlignment: Grid.AlignVCenter

            function titleOfType(type) {
                switch (type) {
                case OxfordModel.MeanBlockType.MbtMeaning:
                    return YTranslateText.paraphrase
                case OxfordModel.MeanBlockType.MbtIdiom:
                    return YTranslateText.idioms
                case OxfordModel.MeanBlockType.MbtPhrase:
                    return YTranslateText.mbtPhrase
                case OxfordModel.MeanBlockType.MbtWhichWord:
                    return YTranslateText.mbtWhichWord
                case OxfordModel.MeanBlockType.MbtSynonym:
                    return YTranslateText.mbtSynonym
                case OxfordModel.MeanBlockType.MbtGrammar:
                    return YTranslateText.mbtGrammar
                case OxfordModel.MeanBlockType.MbtMoreAbout:
                    return YTranslateText.mbtMoreAbout
                case OxfordModel.MeanBlockType.MbtVocab:
                    return YTranslateText.mbtVocab
                case OxfordModel.MeanBlockType.MbtBA:
                    return YTranslateText.mbtBA
                case OxfordModel.MeanBlockType.MbtDerivate:
                    return YTranslateText.derivative
                case OxfordModel.MeanBlockType.MbtOrigin:
                    return YTranslateText.etymology
                case OxfordModel.MeanBlockType.MbtWordFamily:
                    return YTranslateText.wordFamily
                default:
                    return ""
                }
            }

            Repeater {
                model: menuList

                YButtonBase {
                    width: (id_wordList_column.width - id_button_menu_grid.columnSpacing) / 2
                    height: 76
                    visible: !showMeaningblock

                    YTextMedium {
                        id: id_button_tip
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.left: parent.left
                        anchors.leftMargin: 20
                        text: id_button_menu_grid.titleOfType(model.modelData.type)
                    }

                    onClicked: {
                        console.log("YDictTypeDtOxfordDetail.qml === id_button_menu.onClicked: ", model.modelData.type)
                        meaningblockType = model.modelData.type
                        showMeaningblockName = id_button_menu_grid.titleOfType(model.modelData.type)
                        showMeaningblock = true
                    }
                }
            }
        }

        YLoader {
            id: id_meaningblock_loader
            asynchronous: false
            active: showMeaningblock && meaningblockType >= 0
            sourceComponent: {
                switch (meaningblockType) {
                case OxfordModel.MeanBlockType.MbtMeaning:
                    return id_meaningblock_MbtMeaning_component
                case OxfordModel.MeanBlockType.MbtIdiom:
                    return id_meaningblock_MbtIdiom_component
                case OxfordModel.MeanBlockType.MbtPhrase:
                    return id_meaningblock_MbtPhrase_component
                case OxfordModel.MeanBlockType.MbtWhichWord:
                    return id_meaningblock_MbtWhichWord_component
                case OxfordModel.MeanBlockType.MbtSynonym:
                    return id_meaningblock_MbtSynonym_component
                case OxfordModel.MeanBlockType.MbtGrammar:
                    return id_meaningblock_MbtGrammar_component
                case OxfordModel.MeanBlockType.MbtMoreAbout:
                    return id_meaningblock_MbtMoreAbout_component
                case OxfordModel.MeanBlockType.MbtVocab:
                    return id_meaningblock_MbtVocab_component
                case OxfordModel.MeanBlockType.MbtBA:
                    return id_meaningblock_MbtBA_component
                case OxfordModel.MeanBlockType.MbtDerivate:
                    return id_meaningblock_MbtDerivate_component
                case OxfordModel.MeanBlockType.MbtOrigin:
                    return id_meaningblock_MbtOrigin_component
                case OxfordModel.MeanBlockType.MbtWordFamily:
                    return id_meaningblock_MbtWordFamily_component
                default:
                    return id_meaningblock_default_component
                }
            }
        }

        YTextBase {
            font.family: fontManager.fontFamily
            font.pixelSize: 24
            lineHeightMode: Text.FixedHeight
            lineHeight: 32
            font.weight: Font.Normal
            color: "#666873"
            wrapMode: YTextBase.Wrap
            textFormat: YTextBase.RichText
            horizontalAlignment: YTextBase.AlignHCenter
            width: parent.width
            text: YTranslateText.oxfordContentComeFrom
        }

        Component {
            id: id_meaningblock_default_component
            // 默认占位用
            Item {
                id: id_meaningblock_MbtIdiom_item
                width: id_wordList_column.width
                height: 0
            }
        }

        Component {
            id: id_meaningblock_MbtMeaning_component // 释义

            Item {
                id: id_meaningblock_MbtMeaning_item
                width: id_wordList_column.width
                height: id_meaningblock_MbtMeaning_column.height

                Column {
                    id: id_meaningblock_MbtMeaning_column
                    width: parent.width
                    spacing: 20
                    readonly property var meanDataPos: {
                        var vPos = []
                        var qslPos = posList[meanIndex]
                        if (oxfordModel.wordListCount > 1) {
                            qslPos.forEach (function(qsPos) {
                                var vData = oxfordModel.vMeanList[meanIndex][qsPos]
                                if (typeof vData == "undefined" || vData.length <= 0) {
                                    return;
                                }
                                vPos.push(qsPos)
                            })
                        } else {
                            vPos.push(qslPos[currentMeanIdx])
                        }
                        return vPos
                    }

                    Repeater {
                        id: id_MbtMeaning_repeater
                        model: id_meaningblock_MbtMeaning_column.meanDataPos
                        Column {
                            id: id_MbtMeaning_repeater_column
                            width:id_meaningblock_MbtMeaning_column.width
                            spacing: 10
                            readonly property var modelModelData: model.modelData

                            YLoader {
                                id: id_meaningblock_loader
                                asynchronous: false
                                active: oxfordModel.wordListCount > 1
                                readonly property var qsPos: id_MbtMeaning_repeater_column.modelModelData
                                sourceComponent: id_word_GlobalA_for_meaningblock_text
                            }

                            Column {
                                width: id_MbtMeaning_repeater_column.width
                                spacing: 20

                                Repeater {
                                    model: oxfordModel.vMeanList.length > 0
                                           ? oxfordModel.vMeanList[meanIndex][id_MbtMeaning_repeater_column.modelModelData] : []

                                    YDictTypeDtOxfordSdgBlock {
                                        meanData: model.modelData
                                        width: id_MbtMeaning_repeater_column.width
                                        bForHeader: false
                                    }
                                }
                            }
                        }
                    }
                }

            }
        }

        Component {
            id: id_meaningblock_MbtIdiom_component // 习语

            Item {
                id: id_meaningblock_MbtIdiom_item
                width: id_wordList_column.width
                height: id_meaningblock_MbtIdiom_column.height

                Column {
                    id: id_meaningblock_MbtIdiom_column
                    width: parent.width
                    spacing: 20
                    readonly property var meanDataPos: {
                        var vPos = []
                        var qslPos = posList[meanIndex]
                        if (oxfordModel.wordListCount > 1) {
                            qslPos.forEach (function(qsPos) {
                                var vData = oxfordModel.vIdiomList[meanIndex][qsPos]
                                if (typeof vData == "undefined" || vData.length <= 0) {
                                    return;
                                }
                                vPos.push(qsPos)
                            })
                        } else {
                            vPos.push(qslPos[currentMeanIdx])
                        }
                        return vPos
                    }

                    Repeater {
                        id: id_MbtIdiom_repeater
                        model: id_meaningblock_MbtIdiom_column.meanDataPos

                        Column {
                            id: id_MbtIdiom_repeater_column
                            width:id_meaningblock_MbtIdiom_column.width
                            spacing: 10
                            readonly property var modelModelData: model.modelData

                            YLoader {
                                id: id_meaningblock_loader
                                asynchronous: false
                                active: oxfordModel.wordListCount > 1
                                readonly property var qsPos: id_MbtIdiom_repeater_column.modelModelData
                                sourceComponent: id_word_GlobalA_for_meaningblock_text
                            }

                            YDictTypeDtOxfordIdiomBlock {
                                qsPos: id_MbtIdiom_repeater_column.modelModelData
                                meanIdiomList: oxfordModel.vIdiomList.length > 0
                                                            ? oxfordModel.vIdiomList[meanIndex][qsPos] : []
                            }
                        }
                    }
                }
            }
        }

        Component {
            id: id_meaningblock_MbtPhrase_component // 动词短语

            Item {
                id: id_meaningblock_MbtPhrase_item
                width: id_wordList_column.width
                height: id_meaningblock_MbtPhrase_column.height

                Column {
                    id: id_meaningblock_MbtPhrase_column
                    width: parent.width
                    spacing: 20
                    readonly property var meanDataPos: {
                        var vPos = []
                        var qslPos = posList[meanIndex]
                        if (oxfordModel.wordListCount > 1) {
                            qslPos.forEach (function(qsPos) {
                                var vData = oxfordModel.vPhraseList[meanIndex][qsPos]
                                if (vData.length <= 0) {
                                    return;
                                }
                                vPos.push(qsPos)
                            })
                        } else {
                            vPos.push(qslPos[currentMeanIdx])
                        }
                        return vPos
                    }

                    Repeater {
                        id: id_MbtPhrase_repeater
                        model: id_meaningblock_MbtPhrase_column.meanDataPos

                        Column {
                            id: id_MbtPhrase_repeater_column
                            width:id_meaningblock_MbtPhrase_column.width
                            spacing: 10
                            readonly property var modelModelData: model.modelData

                            YLoader {
                                id: id_meaningblock_loader
                                asynchronous: false
                                active: oxfordModel.wordListCount > 1
                                readonly property var qsPos: id_MbtPhrase_repeater_column.modelModelData
                                sourceComponent: id_word_GlobalA_for_meaningblock_text
                            }

                            YDictTypeDtOxfordPhraseBlock {
                                qsPos: id_MbtPhrase_repeater_column.modelModelData
                                phraseObjList: oxfordModel.vPhraseList.length > 0
                                                            ? oxfordModel.vPhraseList[meanIndex][qsPos] : []
                            }
                        }
                    }
                }
            }
        }

        Component {
            id: id_meaningblock_MbtWhichWord_component // 词语辨析

            Item {
                id: id_meaningblock_MbtWhichWord_item
                width: id_wordList_column.width
                height: id_meaningblock_MbtWhichWord_column.height

                YDictTypeDtOxfordIllustration {
                    id: id_meaningblock_MbtWhichWord_column
                    width: id_wordList_column.width
                    illObjList: OxfordModel.getWhichWordList(oxfordModel, currentMeanIdx)
                }
            }
        }

        Component {
            id: id_meaningblock_MbtSynonym_component // 同义词辨析

            Item {
                id: id_meaningblock_MbtSynonym_item
                width: id_wordList_column.width
                height: id_meaningblock_MbtSynonym_column.height
                property var synonymsList: OxfordModel.getSynonymsList(oxfordModel, currentMeanIdx)

                Column {
                    id: id_meaningblock_MbtSynonym_column
                    width: parent.width
                    spacing: 20

                    Repeater {
                        model: synonymsList

                        Column {
                            id: id_synonymsObj_info_column
                            width: id_meaningblock_MbtSynonym_column.width
                            spacing: 20
                            readonly property bool needShow: {
                                if (typeof model.modelData.value == "undefined") {
                                    return false
                                }
                                if (OxfordUtilities.isArrayFn(model.modelData.value.para)
                                    && model.modelData.value.para.length > 0) {
                                    return true
                                }
                            }
                            readonly property var synonymsObj: needShow ? model.modelData.value : null
                            readonly property var firstParaObj: {
                                if (needShow) {
                                    if (synonymsObj.para[0].outdent === "n") {
                                        return synonymsObj.para[0]
                                    }
                                }
                                return null
                            }
                            readonly property var patternsObj: {
                                if (synonymsObj !== null) {
                                    if (typeof synonymsObj.patterns != "undefined") {
                                        return synonymsObj.patterns
                                    }
                                }
                                return null
                            }

                            Column {
                                id: id_synonymsObj_first_para_column
                                width: parent.width
                                spacing: 10

                                YTextMedium {
                                    width: parent.width
                                    height: contentHeight
                                    font.family: fontManager.fontFamilyEnUs
                                    font.pixelSize: 28
                                    color: "#FFFFFF"
                                    wrapMode: YTextBase.Wrap
                                    textFormat: YTextBase.RichText
                                    text: {
                                        if (firstParaObj === null || typeof synonymsObj.title == "undefined"
                                            || typeof synonymsObj.title.titled == "undefined") {
                                            return ""
                                        }
                                        return OxfordUtilities.illTitleToFormatted(synonymsObj.title.titled, fontManager.fontFamilyZhCn)
                                    }
                                    visible: text.length > 0
                                }

                                YTextMedium {
                                    width: parent.width
                                    height: contentHeight
                                    font.family: fontManager.fontFamilyEnUs
                                    font.pixelSize: 28
                                    color: "#FFFFFF"
                                    wrapMode: YTextBase.Wrap
                                    textFormat: YTextBase.RichText
                                    text: {
                                        if (firstParaObj === null || typeof firstParaObj.subhead == "undefined") {
                                            return ""
                                        }
                                        return OxfordUtilities.illTitleToFormatted(firstParaObj.subhead, fontManager.fontFamilyZhCn)
                                    }
                                    visible: text.length > 0
                                }

                                YText {
                                    width: parent.width
                                    height: contentHeight
                                    font.family: fontManager.fontFamilyEnUs
                                    font.pixelSize: 28
                                    color: "#FFFFFF"
                                    wrapMode: YTextBase.Wrap
                                    textFormat: YTextBase.RichText
                                    text: {
                                        if (firstParaObj === null || typeof firstParaObj.d == "undefined") {
                                            return ""
                                        }
                                        return OxfordUtilities.illTitleToFormatted(firstParaObj.d, fontManager.fontFamilyZhCn)
                                    }
                                    visible: text.length > 0
                                }

                                YDictTypeDtOxfordIllustrationParaTable {
                                    width: parent.width
                                    tableObj: (firstParaObj !== null && typeof firstParaObj.table != "undefined") ? firstParaObj.table : null
                                }
                            }

                            YDictTypeDtOxfordIllustrationParaList {
                                width: parent.width
                                paraObjList: {
                                    if (id_synonymsObj_info_column.needShow) {
                                        if (id_synonymsObj_info_column.firstParaObj === null) {
                                            return synonymsObj.para
                                        }
                                        // 不取第一个
                                        var paraList = []
                                        synonymsObj.para.forEach(function(paraObj, index){
                                            if (index > 0) {
                                                paraList.push(paraObj)
                                            }
                                        })
                                        return paraList
                                    }
                                    return []
                                }
                            }

                            Column {
                                width: parent.width
                                spacing: 10

                                YTextMedium {
                                    width: parent.width
                                    height: contentHeight
                                    font.family: fontManager.fontFamilyEnUs
                                    font.pixelSize: 28
                                    color: "#FFFFFF"
                                    wrapMode: YTextBase.Wrap
                                    textFormat: YTextBase.RichText
                                    text: patternsObj === null ? "" : "PATTERNS AND COLLOCATIONS"
                                    visible: text.length > 0
                                }

                                Repeater {
                                    model: patternsObj === null ? [] : patternsObj.para

                                    Item {
                                        id: id_synonymsObj_info_patterns_para_item
                                        width: parent.width
                                        height: id_synonymsObj_info_patterns_para_text.height
                                        visible: id_synonymsObj_info_patterns_para_text.visible
                                        readonly property var patternsParaObj: model.modelData

                                        Item {
                                            id: id_synonymsObj_info_patterns_para_icon
                                            width: 43
                                            height: id_synonymsObj_info_patterns_para_text.height
                                            anchors.left: parent.left
                                            visible: id_synonymsObj_info_patterns_para_text.visible
                                            YImage {
                                                imageName: "dict/oxford-block"
                                                anchors.left: parent.left
                                                anchors.top: parent.top
                                                anchors.topMargin: 8
                                            }
                                        }

                                        YText {
                                            id: id_synonymsObj_info_patterns_para_text
                                            anchors.left: id_synonymsObj_info_patterns_para_icon.right
                                            anchors.right: parent.right
                                            height: contentHeight
                                            font.family: fontManager.fontFamilyEnUs
                                            color: YColors.grayText
                                            textFormat: YTextBase.RichText
                                            wrapMode: YTextBase.WordWrap
                                            text: {
                                                if (typeof patternsParaObj.d == "undefined"
                                                    && typeof patternsParaObj.d.content != "string") {
                                                    if (patternsParaObj.d.content.length > 0) {
                                                        return OxfordUtilities.htmlToFormatted(patternsParaObj.d.content)
                                                    }
                                                }
                                                return patternsParaObj.d.content
                                            }
                                            visible: text.length > 0
                                        }

                                    }
                                }
                            }
                        }
                    }
                }
            }
        }

        Component {
            id: id_meaningblock_MbtGrammar_component // 语法说明

            Item {
                id: id_meaningblock_MbtGrammar_item
                width: id_wordList_column.width
                height: id_meaningblock_MbtGrammar_column.height

                YDictTypeDtOxfordIllustration {
                    id: id_meaningblock_MbtGrammar_column
                    width: id_wordList_column.width
                    illObjList: OxfordModel.getGrammarList(oxfordModel, currentMeanIdx)
                }
            }
        }

        Component {
            id: id_meaningblock_MbtMoreAbout_component // 补充说明

            Item {
                id: id_meaningblock_MbtMoreAbout_item
                width: id_wordList_column.width
                height: id_meaningblock_MbtMoreAbout_column.height

                YDictTypeDtOxfordIllustration {
                    id: id_meaningblock_MbtMoreAbout_column
                    width: id_wordList_column.width
                    illObjList: OxfordModel.getMoreAboutList(oxfordModel, currentMeanIdx)
                }
            }
        }

        Component {
            id: id_meaningblock_MbtVocab_component // 词汇扩充

            Item {
                id: id_meaningblock_MbtVocab_item
                width: id_wordList_column.width
                height: id_meaningblock_MbtVocab_column.height

                YDictTypeDtOxfordIllustration {
                    id: id_meaningblock_MbtVocab_column
                    width: id_wordList_column.width
                    illObjList: OxfordModel.getVocabList(oxfordModel, currentMeanIdx)
                }
            }
        }

        Component {
            id: id_meaningblock_MbtBA_component // 英国/美国英语

            Item {
                id: id_meaningblock_MbtBA_item
                width: id_wordList_column.width
                height: id_meaningblock_MbtBA_column.height

                YDictTypeDtOxfordIllustration {
                    id: id_meaningblock_MbtBA_column
                    width: id_wordList_column.width
                    illObjList: OxfordModel.getBAList(oxfordModel, currentMeanIdx)
                }
            }
        }

        Component {
            id: id_meaningblock_MbtDerivate_component // 派生词

            Item {
                id: id_meaningblock_MbtDerivate_item
                width: id_wordList_column.width
                height: id_meaningblock_MbtDerivate_column.height

                Column {
                    id: id_meaningblock_MbtDerivate_column
                    width: parent.width
                    spacing: 20
                    readonly property var meanDataPos: {
                        var vPos = []
                        var qslPos = posList[meanIndex]
                        if (oxfordModel.wordListCount > 1) {
                            qslPos.forEach (function(qsPos) {
                                var vData = oxfordModel.vDerivates[meanIndex][qsPos]
                                if (typeof vData == "undefined" || vData.length <= 0) {
                                    return;
                                }
                                vPos.push(qsPos)
                            })
                        } else {
                            vPos.push(qslPos[currentMeanIdx])
                        }
                        return vPos
                    }

                    Repeater {
                        id: id_MbtDerivate_repeater
                        model: id_meaningblock_MbtDerivate_column.meanDataPos
                        Column {
                            id: id_MbtDerivate_repeater_column
                            width:id_meaningblock_MbtDerivate_column.width
                            spacing: 10
                            readonly property var modelModelData: model.modelData

                            YLoader {
                                id: id_meaningblock_loader
                                asynchronous: false
                                active: oxfordModel.wordListCount > 1
                                readonly property var qsPos: id_MbtDerivate_repeater_column.modelModelData
                                sourceComponent: id_word_GlobalA_for_meaningblock_text
                            }

                            Column {
                                width: id_MbtDerivate_repeater_column.width
                                spacing: 20

                                Repeater {
                                    model: {
                                        if (oxfordModel.vDerivates.length <= 0) {
                                            return []
                                        }
                                        var orgList = oxfordModel.vDerivates[meanIndex][id_MbtDerivate_repeater_column.modelModelData]
                                        var dstList = []
                                        orgList.forEach(function(objData){
                                            if (typeof objData.dr != "undefined") {
                                                dstList.push(objData)
                                            }
                                        })
                                        //OxfordUtilities.outputInfo(dstList, "vDerivates")
                                        return dstList
                                    }

                                    Item {
                                        id: id_derivateObj_item
                                        width: id_MbtDerivate_repeater_column.width
                                        height: id_derivateObj_content.height
                                        readonly property var derivateObj: model.modelData

                                        YText {
                                            id: id_derivateObj_index
                                            width: 43
                                            topPadding: 4
                                            height: id_derivateObj_content.height
                                            anchors.left: parent.left
                                            font.family: fontManager.fontFamilyZhCn
                                            font.pixelSize: 26
                                            color: YColors.grayText
                                            text: "%1.".arg(index + 1)
                                        }

                                        Column {
                                            id: id_derivateObj_content
                                            anchors.left: id_derivateObj_index.right
                                            anchors.right: parent.right
                                            spacing: 6

                                            YTextMedium {
                                                width: parent.width
                                                height: contentHeight
                                                color: YColors.grayText
                                                font.family: fontManager.fontFamilyEnUs
                                                wrapMode: YTextBase.Wrap
                                                textFormat: YTextBase.RichText
                                                text: {
                                                    var vFormatted = OxfordUtilities.derivateToFormatted(derivateObj)
                                                    if (typeof derivateObj["i-g"] != "undefined") {
                                                        vFormatted += OxfordUtilities.phoneticToFormattedText(OxfordModel.phoneticToStringListPair(derivateObj["i-g"]));
                                                    }
                                                    let derExtInfo = OxfordUtilities.derivateExtInfoToFormatted(derivateObj)
                                                    if (derExtInfo.length > 0) {
                                                        if (vFormatted.length > 0) {
                                                            vFormatted += "&nbsp;"
                                                        }
                                                        vFormatted += derExtInfo
                                                    }
                                                    return vFormatted
                                                }
                                            }

                                            Repeater {
                                                id: id_derivateObj_content_x_repeater
                                                model: {
                                                    var exampleListObj = derivateObj.x
                                                    if (typeof exampleListObj == "object") {
                                                        if (OxfordUtilities.isArrayFn(exampleListObj)) {
                                                            return exampleListObj
                                                        } else {
                                                            return [exampleListObj]
                                                        }
                                                    }
                                                    return []
                                                }

                                                YDictTypeDtOxfordExampleBlock {
                                                    width: id_derivateObj_content.width
                                                    meanDataNgX: model.modelData
                                                }
                                            }

                                            YLoader {
                                                id: id_derivateObj_content_help_loader
                                                asynchronous: false
                                                readonly property int componentWidth: id_derivateObj_content.width
                                                readonly property var helpObj: typeof derivateObj.help != "undefined" ? derivateObj.help : null
                                                readonly property bool bHasIcon: true
                                                readonly property var qsCh: OxfordUtilities.helpChToFormatted(helpObj)
                                                readonly property var qslEn: OxfordUtilities.helpEnToFormatted(helpObj)
                                                active: qsCh.length > 0 || qslEn.length > 0
                                                sourceComponent: YDictTypeDtOxfordHelp{}
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }

        Component {
            id: id_meaningblock_MbtOrigin_component // 词源

            YTextMedium {
                id: id_meaningblock_MbtOrigin_text
                width: id_wordList_column.width
                height: contentHeight
                font.family: fontManager.fontFamilyEnUs
                font.pixelSize: 28
                color: "#FFFFFF"
                wrapMode: YTextBase.Wrap
                textFormat: YTextBase.RichText
                text: {
                    let qsPos = posList[meanIndex][currentMeanIdx]
                    let originObj = oxfordModel.vOrigins[meanIndex][qsPos]
                    return OxfordUtilities.illTitleToFormatted(originObj, fontManager.fontFamilyZhCn)
                }
                visible: text.length > 0
            }
        }

        Component {
            id: id_meaningblock_MbtWordFamily_component // 词族

            Item {
                id: id_meaningblock_MbtWordFamily_item
                width: id_wordList_column.width
                height: id_meaningblock_MbtWordFamily_column.height
                readonly property var familyObj: oxfordModel.vFamily[meanIndex][posList[meanIndex][currentMeanIdx]]
                property var familyObjWfwList: []
                property var familyObjWfpList: []
                property var familyObjWfoList: []
                onFamilyObjChanged: {
                    if (typeof familyObj != "undefined") {
                        if (OxfordUtilities.isArrayFn(familyObj.wfw) && familyObj.wfw.length > 0) {
                            familyObjWfwList = familyObj.wfw
                        }
                    }
                    if (familyObjWfwList.length > 0) {
                        familyObjWfpList = typeof familyObj.wfp != "undefined" ? familyObj.wfp : []
                        familyObjWfoList = typeof familyObj.wfo != "undefined" ? familyObj.wfo : []
                    } else {
                        familyObjWfpList = []
                        familyObjWfoList = []
                    }
                }

                Column {
                    id: id_meaningblock_MbtWordFamily_column
                    width: parent.width
                    spacing: 10

                    Repeater {
                        model: id_meaningblock_MbtWordFamily_item.familyObjWfwList

                        Row {
                            height: id_meaningblock_MbtWordFamily_wfw_text.height
                            spacing: 10

                            YTextMedium {
                                id: id_meaningblock_MbtWordFamily_wfw_text
                                width: contentWidth
                                height: contentHeight
                                font.family: fontManager.fontFamilyEnUs
                                font.pixelSize: 28
                                color: "#FFFFFF"
                                text: {
                                    if (typeof model.modelData == "string" && model.modelData.length > 0) {
                                        return model.modelData
                                    }
                                    return ""
                                }
                                visible: text.length > 0
                            }

                            YText {
                                width: contentWidth
                                height: contentHeight
                                font.family: fontManager.fontFamilyEnUs
                                color: YColors.grayText
                                text: {
                                    if (id_meaningblock_MbtWordFamily_wfw_text.visible) {
                                        if (index < familyObjWfpList.length) {
                                            var qsWfp = typeof familyObjWfpList[index].p == "string" ? familyObjWfpList[index].p : ""
                                            if (qsWfp.length > 0) {
                                                return qsWfp + '.'
                                            }
                                        }
                                    }
                                    return ""
                                }
                                visible: text.length > 0
                            }

                            YTextMedium {
                                width: contentWidth
                                height: contentHeight
                                font.family: fontManager.fontFamilyEnUs
                                color: YColors.grayText
                                text: {
                                    if (id_meaningblock_MbtWordFamily_wfw_text.visible) {
                                        if (index < familyObjWfoList.length) {
                                            var qsWfo = typeof familyObjWfoList[index] == "string" ? familyObjWfoList[index] : ""
                                            if (qsWfo.length > 0 && qsWfo !== "no wfo") {
                                                return "(≠" + qsWfo + ")"
                                            }
                                        }
                                    }
                                    return ""
                                }
                                visible: text.length > 0
                            }
                        }
                    }
                }

            }
        }

        Component {
            id: id_word_GlobalA_for_meaningblock_text
            // let qsPos

            YText {
                width: id_wordList_column.width
                height: contentHeight
                font.family: fontManager.fontFamilyEnUs
                color: YColors.grayText
                wrapMode: YTextBase.Wrap
                textFormat: YTextBase.RichText
                text: {
                    if (oxfordModel.wordListCount <= 1) {
                        return ""
                    }
                    var vFormattedText = OxfordUtilities.formatText(qsPos, YColors.red, 400, 28, fontManager.fontFamilyClass) + "&nbsp;&nbsp;"
                    if (posListCur.length > 1) {
                        vFormattedText += OxfordUtilities.aToFormatted(oxfordModel.vGlobalA[meanIndex][qsPos])
                    }
                    vFormattedText += OxfordUtilities.irregularToFormattedText(oxfordModel.vIrregularList[meanIndex][qsPos])
                    return vFormattedText
                }
                visible: text.length > 0
            }
        }

    }
}// Item root


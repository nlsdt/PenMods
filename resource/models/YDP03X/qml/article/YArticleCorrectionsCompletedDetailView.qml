import QtQuick 2.12
import com.youdao.pen 1.0

import BaseQml 1.0
import "../i18n"

YBackgroundIgnoreMouseEvent {
    id: id_article_detail_view
    objectName: "YArticleCorrectionsCompletedDetailView.qml"
    anchors.fill: parent
    visible: false

    function show(uniqueKey) {
        visible = true
//        id_article_submitting_tips.visible = true
        articleManager.parsingResultData(uniqueKey)
    }

    signal backButtonClicked()

    signal errorLinkClicked(int sentId, int errorId)

    property int currentTabIndex: -1

    enum ScoreTabIndex {
        ScoreInstructions,  // 文章评分
        GrammarProblems,    // 语法错误
        WordsRecommended    // 词汇推荐
    }

    Connections {
        target: articleManager
        enabled: visible
        ignoreUnknownSignals: true
        function onParsingResultDataScoreInstructionsFinshed(scoresInfo) {
            id_total_score.text = scoresInfo["totalScore"]
            id_full_score.text = YTranslateText.articleResultFullScoreUnit.arg(scoresInfo["fullScore"])
            id_essay_advice.text = scoresInfo["essayAdvice"]

            const word = scoresInfo["wordAdvice"]
            if (word.length > 0) {
                id_word_advice.text = YTranslateText.articleLablePartStartWord.arg(word)
                id_word_advice.visible = true
            }

            const grammar = scoresInfo["grammarAdvice"]
            if (grammar.length > 0) {
                id_grammar_advice.text = YTranslateText.articleLablePartStartGrammar.arg(grammar)
                id_grammar_advice.visible = true
            }

            const structure = scoresInfo["structureAdvice"]
            if (structure.length > 0) {
                id_structure_advice.text = YTranslateText.articleLablePartStartStructure.arg(structure)
                id_structure_advice.visible = true
            }

            const topic = scoresInfo["topicAdvice"]
            if (topic.length > 0) {
                id_topic_advice.text = YTranslateText.articleLablePartStartTopic.arg(topic)
                id_topic_advice.visible = true
            }

            id_score_instructions_tab.visible = true
        }

        function onParsingResultDataGrammarProblemsFinshed(grammarProblems) {
            const count = grammarProblems["grammarCount"]
            if (count > 0) {
                id_grammar_problems_tab.text = YTranslateText.articleTabGrammarProblems
                        + (" %1").arg(count)
                id_grammar_problems_repeater.model = grammarProblems["grammarArray"]
                id_grammar_problems_tab.visible = true
            } else {
                id_grammar_problems_tab.visible = false
            }
        }

        function onParsingResultDataWordsRecommendedFinshed(wordsRecommended) {
            const count = wordsRecommended["wordCount"]
            if (count > 0) {
                id_words_recommended_tab.text = YTranslateText.articleTabWordsRecommended
                        + (" %1").arg(count)
                id_words_recommended_repeater.model = wordsRecommended["wordsRecommendedArray"]
                id_words_recommended_tab.visible = true
            } else {
                id_words_recommended_tab.visible = false
            }
        }

        function onParsingResultDataRawEssayFinshed(rawEssay) {
            id_article_raw_essay_view.normalText = rawEssay["rawEssay"]
            let errorPosInfosArrayList = rawEssay["errorPosInfosArrayList"]

            let size = 0;
            let errorPosInfo;
            let rawSent;
            let rawSentSize = 0;
            let errorPosInfos;
            let tmpGrammerText = id_article_raw_essay_view.normalText
            errorPosInfosArrayList.forEach(function(grammarJson) {
                rawSent = grammarJson.rawSent
                rawSentSize = rawSent.length
                errorPosInfos = grammarJson.errorPosInfos
                size = errorPosInfos.length
                for (let i=size-1; i >= 0; --i) {
                    errorPosInfo = errorPosInfos[i]
                    rawSent = rawSent.replaceBetween(
                                errorPosInfo.startPos, errorPosInfo.endPos,
                                ("<a href='%1' style='color:\"%2\"'>%3</a>")
                                .arg(grammarJson.sentId + "_" + i).arg(YColors.red).arg(errorPosInfo.orgChunk.replace(" ", "&nbsp;"))
                                )
                }
                tmpGrammerText = tmpGrammerText.replaceBetween(grammarJson.sentStartPos, grammarJson.sentStartPos + rawSentSize, rawSent)
            })
            id_article_raw_essay_view.grammerText = tmpGrammerText

            let synInfoArrayList = rawEssay["synInfoArrayList"]
            let tmpWordsText = id_article_raw_essay_view.normalText
            let synInfo;
            let source;
            let sourceSize = 0;
            let sourceItem;
            synInfoArrayList.forEach(function(wordJson) {
                rawSent = wordJson.rawSent
                rawSentSize = rawSent.length
                synInfo = wordJson.synInfo
                size = synInfo.length
                for (let i=size-1; i >= 0; --i) {
                    source = synInfo[i].source
                    sourceSize = source.length
                    for (let j=sourceSize-1; j >= 0; --j) {
                        sourceItem = source[j]
                        rawSent = rawSent.replaceBetween(
                                    sourceItem.startPos, sourceItem.endPos,
                                    ("<a href='%1' style='color:\"%2\"'>%3</a>")
                                    .arg(wordJson.sentId + "_" + i).arg(YColors.blueText).arg(sourceItem.word)
                                    )
                    }
                }
                tmpWordsText = tmpWordsText.replaceBetween(wordJson.sentStartPos, wordJson.sentStartPos + rawSentSize, rawSent)
            })
            id_article_raw_essay_view.wordsText = tmpWordsText

            id_raw_essay_button.enabled = true
        }

        function onParsingResultDataAllFinshed() {
            if (-1 === currentTabIndex) {
                if (id_grammar_problems_tab.visible) {
                    currentTabIndex = YArticleCorrectionsCompletedDetailView.GrammarProblems
                } else if (id_words_recommended_tab.visible) {
                    currentTabIndex = YArticleCorrectionsCompletedDetailView.WordsRecommended
                } else if (id_score_instructions_tab.visible) {
                    currentTabIndex = YArticleCorrectionsCompletedDetailView.ScoreInstructions
                }
            }
            id_article_submitting_tips.visible = false
        }
    }

    Flickable {
        id: id_flickable
        anchors.fill: parent
        anchors.leftMargin: 90
        anchors.rightMargin: 20
        contentHeight: id_column.height

        Column {
            id: id_column
            anchors.left: parent.left
            anchors.right: parent.right
            spacing: 0

            YSpacingForColumn {
                implicitHeight: 86
                Row {
                    spacing: 16
                    anchors.top: parent.top
                    anchors.topMargin: 18

                    YPressedButton {
                        id: id_grammar_problems_tab
                        width: textItem.paintedWidth + 40
                        implicitHeight: 52
                        clickable: YArticleCorrectionsCompletedDetailView.GrammarProblems !== currentTabIndex
                        checkedIndicatorScale: YArticleCorrectionsCompletedDetailView.GrammarProblems === currentTabIndex
                        visible: false
                        pixelSize: 26
                        text: YTranslateText.articleTabGrammarProblems
                        onValidClicked: {
                            logManager.sendHttpLog("action=essay_result_grammar")
                            currentTabIndex = YArticleCorrectionsCompletedDetailView.GrammarProblems
                        }
                    }

                    YPressedButton {
                        id: id_words_recommended_tab
                        width: textItem.paintedWidth + 40
                        implicitHeight: 52
                        clickable: YArticleCorrectionsCompletedDetailView.WordsRecommended !== currentTabIndex
                        checkedIndicatorScale: YArticleCorrectionsCompletedDetailView.WordsRecommended === currentTabIndex
                        visible: false
                        pixelSize: 26
                        text: YTranslateText.articleTabWordsRecommended
                        onValidClicked: {
                            logManager.sendHttpLog("action=essay_result_word")
                            currentTabIndex = YArticleCorrectionsCompletedDetailView.WordsRecommended
                        }
                    }

                    YPressedButton {
                        id: id_score_instructions_tab
                        width: textItem.paintedWidth + 40
                        implicitHeight: 52
                        clickable: YArticleCorrectionsCompletedDetailView.ScoreInstructions !== currentTabIndex
                        checkedIndicatorScale: YArticleCorrectionsCompletedDetailView.ScoreInstructions === currentTabIndex
                        visible: false
                        pixelSize: 26
                        text: YTranslateText.articleTabScoreInstructions
                        onValidClicked: {
                            logManager.sendHttpLog("action=essay_result_score")
                            currentTabIndex = YArticleCorrectionsCompletedDetailView.ScoreInstructions
                        }
                    }
                }
            }

            YSpacingForColumn {
                id: id_grammar_problems_container
                height: id_grammar_problems_column.height
                visible: YArticleCorrectionsCompletedDetailView.GrammarProblems === currentTabIndex

                Column {
                    id: id_grammar_problems_column
                    anchors.left: parent.left
                    anchors.right: parent.right

                    Repeater {
                        id: id_grammar_problems_repeater
                        YSpacingForColumn {
                            id: id_grammar_problems_item
                            height: id_grammar_problems_item_column.height
                            readonly property int sentId: model.modelData.sentId
                            property var modelModelData: model.modelData

                            Column {
                                id: id_grammar_problems_item_column
                                anchors.left: parent.left
                                anchors.right: parent.right

                                YTextMedium {
                                    id: id_grammar_problems_item_text
                                    anchors.left: parent.left
                                    anchors.right: parent.right
                                    wrapMode: YTextMedium.Wrap
                                    textFormat: YTextMedium.RichText
                                    text: {
                                        let rawSent = model.modelData.rawSent
                                        let rawSentSize = rawSent.length
                                        let errorPosInfos = model.modelData.errorPosInfos
                                        let size = errorPosInfos.length
                                        let errorPosInfo;
                                        for (let i=size-1; i >= 0; --i) {
                                            errorPosInfo = errorPosInfos[i]
                                            rawSent = rawSent.replaceBetween(
                                                        errorPosInfo.startPos, errorPosInfo.endPos,
                                                        ("<a href='%1' style='color:\"%2\"'>%3</a>")
                                                        .arg(id_grammar_problems_item.sentId + "_" + i).arg(YColors.red).arg(errorPosInfo.orgChunk.replace(" ", "&nbsp;"))
                                                        )
                                        }
                                        return rawSent
                                    }
                                    height: paintedHeight
                                    onLinkActivated: {
                                        const sentInfo = link.split("_")
                                        errorLinkClicked(sentInfo[0], sentInfo[1])
                                    }
                                }

                                YSpacingForColumn {
                                    implicitHeight: 14
                                }

                                Repeater {
                                    id: id_grammar_problems_error_repeater
                                    model: id_grammar_problems_item.modelModelData.errorPosInfos

                                    Item {
                                        width: id_grammar_problems_item_column.width
                                        height: id_grammar_problems_error_item_column.height + 14

                                        function doPosition(sentId, errorId) {
                                            if ((id_grammar_problems_item.sentId === sentId) && (errorId === index)) {
                                                const pos = mapToItem(id_column, 0, 0)
                                                id_flickable.contentY = pos.y - 20
                                                id_flickable.returnToBounds()
                                            }
                                        }

                                        Component.onCompleted: {
                                            id_article_detail_view.errorLinkClicked.connect(doPosition)
                                        }

                                        Rectangle {
                                            anchors.left: parent.left
                                            anchors.right: parent.right
                                            color: YColors.grayNormal
                                            radius: 16
                                            height: id_grammar_problems_error_item_column.height

                                            Column {
                                                id: id_grammar_problems_error_item_column
                                                anchors.left: parent.left
                                                anchors.leftMargin: 20
                                                anchors.right: parent.right
                                                anchors.rightMargin: 20

                                                YSpacingForColumn {
                                                    implicitHeight: 20
                                                }

                                                Item {
                                                    id: id_grammar_problems_error_item_title
                                                    anchors.left: parent.left
                                                    anchors.right: parent.right
                                                    height: Math.max(38, id_grammar_problems_error_item_title_content.height)

                                                    Flow {
                                                        id: id_grammar_problems_error_item_title_content
                                                        anchors.left: parent.left
                                                        anchors.right: id_more_button_area.left
                                                        anchors.rightMargin: 30
                                                        spacing: 8

                                                        YText {
                                                            id: id_text_index
                                                            font.pixelSize: 26
                                                            text: ("%1.").arg(index + 1)
                                                            width: paintedWidth
                                                            height: 38
                                                            verticalAlignment: YText.AlignBottom
                                                        }

                                                        YText {
                                                            id: id_del_text_label
                                                            font.pixelSize: 26
                                                            text: YTranslateText.del
                                                            width: paintedWidth + 4
                                                            horizontalAlignment: YText.AlignHCenter
                                                            height: 38
                                                            verticalAlignment: YText.AlignVCenter
                                                            visible: !id_text_right.correctChunkVisible
                                                        }

                                                        YTextMedium {
                                                            id: id_text_error
                                                            color: YColors.red
                                                            text: model.modelData.orgChunk
                                                            width: Math.min(parent.width, paintedWidth)
                                                            height: Math.max(38, paintedHeight)
                                                            verticalAlignment: YTextMedium.AlignVCenter
                                                            wrapMode: YTextMedium.Wrap
                                                        }

                                                        YText {
                                                            id: id_text_label
                                                            font.pixelSize: 26
                                                            text: YTranslateText.articleLableModify
                                                            width: paintedWidth + 8
                                                            horizontalAlignment: YText.AlignHCenter
                                                            height: 38
                                                            verticalAlignment: YText.AlignVCenter
                                                            visible: id_text_right.correctChunkVisible
                                                        }

                                                        YTextMedium {
                                                            id: id_text_right
                                                            color: YColors.green
                                                            readonly property bool errorTypeIsDeleted: '1' === model.modelData.errorTypeId.charAt(2)
                                                            readonly property bool correctChunkVisible: !errorTypeIsDeleted
                                                            visible: correctChunkVisible
                                                            text: model.modelData.correctChunk
                                                            width: Math.min(parent.width, paintedWidth)
                                                            height: Math.max(38, paintedHeight)
                                                            verticalAlignment: YTextMedium.AlignVCenter
                                                            wrapMode: YTextMedium.Wrap
                                                        }
                                                    }

                                                    Rectangle {
                                                        id: id_more_button_area
                                                        color: YColors.grayButton
                                                        width: id_more_button_content.width + 40
                                                        implicitHeight: 38
                                                        radius: height/2
                                                        opacity: id_more_button.pressed ? 0.6 : 1
                                                        anchors.right: parent.right

                                                        Row {
                                                            id: id_more_button_content
                                                            height: 28
                                                            anchors.centerIn: parent
                                                            anchors.horizontalCenterOffset: 5
                                                            spacing: 0

                                                            YText {
                                                                font.pixelSize: 22
                                                                text: YTranslateText.more
                                                                anchors.verticalCenter: parent.verticalCenter
                                                            }

                                                            YImage {
                                                                imageName: "article/history_clickable"
                                                                sourceSize: Qt.size(24, 24)
                                                                anchors.verticalCenter: parent.verticalCenter
                                                            }
                                                        }

                                                        YButtonBaseMouseArea {
                                                            id: id_more_button
                                                            anchors.fill: parent
                                                            anchors.margins: -20
                                                            onValidClicked: {
                                                                logManager.sendHttpLog("action=essay_result_grammar_more")
                                                                grammarProblemsDetail(
                                                                            {
                                                                                "orgChunk": model.modelData.orgChunk,
                                                                                "lableModify": id_text_label.text,
                                                                                "correctChunk": model.modelData.correctChunk,
                                                                                "detailReason": model.modelData.detailReason,
                                                                                "knowledgeExp": model.modelData.knowledgeExp,
                                                                                "exampleCases": model.modelData.exampleCases,
                                                                                "errorTypeIsDeleted": id_text_right.errorTypeIsDeleted
                                                                            })
                                                            }
                                                        }
                                                    }
                                                }

                                                YSpacingForColumn {
                                                    implicitHeight: 14
                                                }

                                                YTextCH {
                                                    anchors.left: parent.left
                                                    anchors.leftMargin: 26
                                                    anchors.right: parent.right
                                                    font.pixelSize: 26
                                                    height: paintedHeight
                                                    wrapMode: YText.Wrap
                                                    textFormat: YText.RichText
                                                    color: YColors.white
                                                    text: {
                                                        let reason = model.modelData.errBaseInfo
                                                        reason = reason.replaceAll("〖", (" <font color=\"%1\">").arg(YColors.red))
                                                        reason = reason.replaceAll("〗", "</font> ")
                                                        reason = reason.replaceAll("【", (" <font color=\"%1\">").arg(YColors.green))
                                                        reason = reason.replaceAll("】", "</font> ")
                                                        return reason
                                                    }
                                                }

                                                YSpacingForColumn {
                                                    implicitHeight: 28
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

            YSpacingForColumn {
                id: id_words_recommended_container
                height: id_words_recommended_column.height
                visible: YArticleCorrectionsCompletedDetailView.WordsRecommended === currentTabIndex

                Column {
                    id: id_words_recommended_column
                    anchors.left: parent.left
                    anchors.right: parent.right

                    Repeater {
                        id: id_words_recommended_repeater
                        YSpacingForColumn {
                            id: id_words_recommended_item
                            height: id_words_recommended_item_column.height
                            readonly property int sentId: model.modelData.sentId
                            property var modelModelData: model.modelData

                            Column {
                                id: id_words_recommended_item_column
                                anchors.left: parent.left
                                anchors.right: parent.right

                                YTextMedium {
                                    id: id_words_recommended_item_text
                                    anchors.left: parent.left
                                    anchors.right: parent.right
                                    wrapMode: YTextMedium.Wrap
                                    textFormat: YTextMedium.RichText
                                    text: {
                                        let rawSent = model.modelData.rawSent
                                        let rawSentSize = rawSent.length
                                        let synInfo = model.modelData.synInfo
                                        let size = synInfo.length
                                        let source;
                                        let sourceSize = 0;
                                        let sourceItem;
                                        for (let i=size-1; i >= 0; --i) {
                                            source = synInfo[i].source
                                            sourceSize = source.length
                                            for (let j=sourceSize-1; j >= 0; --j) {
                                                sourceItem = source[j]
                                                rawSent = rawSent.replaceBetween(
                                                            sourceItem.startPos, sourceItem.endPos,
                                                            ("<a href='%1' style='color:\"%2\"'>%3</a>")
                                                            .arg(id_words_recommended_item.sentId + "_" + i).arg(YColors.blueText).arg(sourceItem.word)
                                                            )
                                            }
                                        }
                                        return rawSent
                                    }
                                    height: paintedHeight
                                    onLinkActivated: {
                                        const sentInfo = link.split("_")
                                        errorLinkClicked(sentInfo[0], sentInfo[1])
                                    }
                                }

                                YSpacingForColumn {
                                    implicitHeight: 14
                                }

                                Repeater {
                                    id: id_words_recommended_error_repeater
                                    model: id_words_recommended_item.modelModelData.synInfo

                                    Item {
                                        id: id_words_recommended_error_item
                                        property var modelModelData: model.modelData
                                        width: id_words_recommended_item_column.width
                                        height: id_words_recommended_error_item_column.height + 10

                                        function doPosition(sentId, errorId) {
                                            if ((id_words_recommended_item.sentId === sentId) && (errorId === index)) {
                                                const pos = mapToItem(id_column, 0, 0)
                                                id_flickable.contentY = pos.y - 20
                                                id_flickable.returnToBounds()
                                            }
                                        }

                                        Component.onCompleted: {
                                            id_article_detail_view.errorLinkClicked.connect(doPosition)
                                        }

                                        Rectangle {
                                            anchors.left: parent.left
                                            anchors.right: parent.right
                                            color: YColors.grayNormal
                                            radius: 16
                                            height: id_words_recommended_error_item_column.height

                                            Column {
                                                id: id_words_recommended_error_item_column
                                                anchors.left: parent.left
                                                anchors.leftMargin: 20
                                                anchors.right: parent.right
                                                anchors.rightMargin: 20

                                                YSpacingForColumn {
                                                    implicitHeight: 20
                                                }

                                                Row {
                                                    spacing: 8
                                                    height: 38

                                                    YText {
                                                        height: 38
                                                        font.pixelSize: 26
                                                        text: ("%1.").arg(index + 1)
                                                        verticalAlignment: YText.AlignBottom
                                                    }

                                                    YTextMedium {
                                                        color: YColors.blueText
                                                        font.family: qmlGlobal.fontFamilyEnUs
                                                        text: {
                                                            let result = ""
                                                            const sources = model.modelData.source
                                                            sources.forEach(function(sourceItem){
                                                                result += sourceItem.word
                                                                result += " ... "
                                                            })
                                                            return result.chop(5)
                                                        }

                                                        anchors.verticalCenter: parent.verticalCenter
                                                    }

                                                    YTextCH {
                                                        width: paintedWidth + 4
                                                        font.pixelSize: 26
                                                        text: YTranslateText.articleLableReplace
                                                        anchors.verticalCenter: parent.verticalCenter
                                                        color: YColors.white
                                                        horizontalAlignment: YTextCH.AlignRight
                                                    }
                                                }

                                                YSpacingForColumn {
                                                    implicitHeight: 10
                                                }

                                                Repeater {
                                                    model: id_words_recommended_error_item.modelModelData.target

                                                    Item {
                                                        width: id_words_recommended_error_item_column.width
                                                        height: id_target_text.height + 6

                                                        YTextMedium {
                                                            id: id_target_text
                                                            anchors.left: parent.left
                                                            anchors.leftMargin: 44
                                                            anchors.right: parent.right
                                                            font.family: qmlGlobal.fontFamilyEnUs
                                                            text: {
                                                                let result = ""
                                                                const targets = model.modelData
                                                                targets.forEach(function(targetItem){
                                                                    result += targetItem.word
                                                                    result += " ... "
                                                                })
                                                                return result.chop(5)
                                                            }

                                                            height: paintedHeight

                                                            Rectangle {
                                                                implicitWidth: 6
                                                                implicitHeight: 6
                                                                radius: 4
                                                                color: YColors.white
                                                                anchors.left: parent.left
                                                                anchors.leftMargin: -9
                                                                anchors.verticalCenter: parent.verticalCenter
                                                            }
                                                        }
                                                    }
                                                }

                                                YSpacingForColumn {
                                                    implicitHeight: 20
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

            YSpacingForColumn {
                id: id_score_instructions_container
                height: id_score_instructions_title.height
                        + id_score_instructions_content.height
                visible: YArticleCorrectionsCompletedDetailView.ScoreInstructions === currentTabIndex

                YSpacingForColumn {
                    id: id_score_instructions_title
                    implicitHeight: 62
                    Row {
                        spacing: 0
                        anchors.bottom: parent.bottom
                        YTextMedium {
                            id: id_total_score
                            font.pixelSize: 50
                            color: YColors.green
                            width: paintedWidth
                            height: paintedHeight
                            anchors.bottom: parent.bottom
                        }
                        YText {
                            id: id_full_score
                            width: paintedWidth
                            height: paintedHeight
                            anchors.bottom: parent.bottom
                            anchors.bottomMargin: 8
                        }
                    }
                }

                Rectangle {
                    id: id_score_instructions_content
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: id_score_instructions_title.bottom
                    color: YColors.grayNormal
                    radius: 16
                    height: id_score_instructions_content_container.height

                    Column {
                        id: id_score_instructions_content_container
                        anchors.left: parent.left
                        anchors.leftMargin: 34
                        anchors.right: parent.right
                        anchors.rightMargin: 20

                        YSpacingForColumn {
                            implicitHeight: 20
                        }

                        YText {
                            color: YColors.grayText
                            font.pixelSize: 22
                            text: YTranslateText.articleLableEssayAdvice
                            height: paintedHeight

                            Rectangle {
                                implicitWidth: 6
                                implicitHeight: 6
                                radius: 4
                                color: YColors.grayText
                                anchors.left: parent.left
                                anchors.leftMargin: -9
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }

                        YSpacingForColumn {
                            implicitHeight: 6
                        }

                        YText {
                            id: id_essay_advice
                            anchors.left: parent.left
                            anchors.right: parent.right
                            font.pixelSize: 22
                            wrapMode: YText.Wrap
                            height: paintedHeight
                        }

                        YSpacingForColumn {
                            implicitHeight: 12
                        }

                        YText {
                            color: YColors.grayText
                            font.pixelSize: 22
                            text: YTranslateText.articleLablePartsAdvice
                            height: paintedHeight

                            Rectangle {
                                implicitWidth: 6
                                implicitHeight: 6
                                radius: 4
                                color: YColors.grayText
                                anchors.left: parent.left
                                anchors.leftMargin: -9
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }

                        YSpacingForColumn {
                            implicitHeight: 6
                            visible: id_word_advice.visible
                        }

                        YText {
                            id: id_word_advice
                            anchors.left: parent.left
                            anchors.right: parent.right
                            font.pixelSize: 22
                            wrapMode: YText.Wrap
                            height: paintedHeight
                            visible: false
                        }

                        YSpacingForColumn {
                            implicitHeight: 6
                            visible: id_grammar_advice.visible
                        }

                        YText {
                            id: id_grammar_advice
                            anchors.left: parent.left
                            anchors.right: parent.right
                            font.pixelSize: 22
                            wrapMode: YText.Wrap
                            height: paintedHeight
                            visible: false
                        }

                        YSpacingForColumn {
                            implicitHeight: 6
                            visible: id_structure_advice.visible
                        }

                        YText {
                            id: id_structure_advice
                            anchors.left: parent.left
                            anchors.right: parent.right
                            font.pixelSize: 22
                            wrapMode: YText.Wrap
                            height: paintedHeight
                            visible: false
                        }

                        YSpacingForColumn {
                            implicitHeight: 6
                            visible: id_topic_advice.visible
                        }

                        YText {
                            id: id_topic_advice
                            anchors.left: parent.left
                            anchors.right: parent.right
                            font.pixelSize: 22
                            wrapMode: YText.Wrap
                            height: paintedHeight
                            visible: false
                        }

                        YSpacingForColumn {
                            implicitHeight: 20
                        }
                    }
                }
            }

            YSpacingForColumn {
                implicitHeight: 20
            }
        }
    }

    YIconButton {
        id: id_raw_essay_button
        opacity: mouseAreaItem.pressed || !enabled ? 0.2 : 1
        implicitWidth: 44
        implicitHeight: 44
        radius: height/2
        mouseAreaMargins: -25
        anchors.left: parent.left
        anchors.leftMargin: 16
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 18
        sourceSize: Qt.size(36, 36)
        enabled: false
        imageName: "article/raw_essay"
        onValidClicked: {
            id_article_raw_essay_view.show()
        }
    }

    YArticleSubmittingTips {
        id: id_article_submitting_tips
        defaultText: YTranslateText.articleParsingTip
    }

    YVerticalTitleBar {
        id: id_title_bar
        onCallBack: {
            backButtonClicked()
        }

        property int incubatorCreateDetailCount: 0
    }

    YArticleCorrectionsCompletedRawEssayView {
        id: id_article_raw_essay_view
    }

    function grammarProblemsDetail(problemsDetail) {
        function newComponentInit(incubatorObject) {
            incubatorObject.backButtonClicked.connect(incubatorObject.destroy)
            systemBase.homeKeyPress.connect(incubatorObject.destroy)
            incubatorObject.show(problemsDetail)
        }

        const newComponent = Qt.createComponent("./YArticleGrammarProblemsDetail.qml")
        const incubator = newComponent.incubateObject(id_article_detail_view)
        if (incubator.status !== Component.Ready) {
            incubator.onStatusChanged = function(status) {
                if (status === Component.Ready) {
                    if (0 === --id_title_bar.incubatorCreateDetailCount) {
                        // 异步重入只显示最后一个创建的对象
                        newComponentInit(incubator.object)
                    } else {
                        incubator.object.destroy()
                    }
                }
            }
            ++id_title_bar.incubatorCreateDetailCount
        } else {
            newComponentInit(incubator.object)
        }
    }

}

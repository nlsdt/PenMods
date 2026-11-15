import QtQuick 2.12

import BaseQml 1.0
import "../i18n"
import "./YDictOxfordUtilities.js" as OxfordUtilities
import "./YDictOxfordModel.js" as OxfordModel

YDictTypeBase {
    id: id_dt_oxford
    title: (YTranslateText.dtOxford).replace("<br/>", " ")
    property var oxfordModel: OxfordModel.createOxfordModel()
    property var wordText: ""
    property var wordListCount: 0
    property var currentMeanIdx: 0
    detail_button_visible: false

    onDictJsonChanged: {
        oxfordModel = OxfordModel.createOxfordModelByJsonData(dictJson)
        wordText = oxfordModel.wordText
        wordListCount = oxfordModel.wordListCount
        currentMeanIdx = 0
        detail_button_visible = OxfordModel.isExpandable(oxfordModel, currentMeanIdx)
    }

    Item {
        width: parent.width
        height: id_for_wordList_column.height

        Column {
            id: id_for_wordList_column
            width: parent.width
            spacing: 20

            Row {
                id: id_wordList_hw_row
                spacing: 10
                visible: id_wordList_hw_repeater.count > 1

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
                                topPadding: 3
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
                oxfordModel: id_dt_oxford.oxfordModel
                currentMeanIdx: id_dt_oxford.currentMeanIdx
            }
        } // Column id_for_wordList_column

    }// Item root

}


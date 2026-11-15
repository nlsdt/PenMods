import QtQuick 2.12

import BaseQml 1.0
import "../i18n"

YDictTypeBase {
    id: id_dt_webster
    title: YTranslateText.dtWebster

    function removeHtmlTag(qsContent){
        let qsResult = qsContent;
        qsResult = qsResult.replace(/<a>/g, "<b>");
        qsResult = qsResult.replace(/<\/a>/g, "</b>");
        qsResult = qsResult.replace(/&lt/g, ("<font color=\"%1\">(").arg(YColors.grayText));
        qsResult = qsResult.replace(/&gt/g, ")</font>");
        return qsResult;
    }

    Item {
        width: parent.width
        height: id_for_wordList_column.height

        Column {
            id: id_for_wordList_column
            width: parent.width
            spacing: 20

            Flickable {
                anchors.left: parent.left
                anchors.right: parent.right
                height: 52
                contentWidth: id_wordList_hw_row.width
                flickableDirection: Flickable.HorizontalFlick
                visible: id_wordList_hw_repeater.count > 1
                clip: true

                Row {
                    id: id_wordList_hw_row
                    spacing: 10

                    Repeater {
                        id: id_wordList_hw_repeater
                        model: dictJson.wordList
                        property int curIndex: 0

                        YMouseArea {
                            id: id_word_hw_MouseArea
                            width: id_word_hw_background.width
                            height: 52
                            objectName: "YDictTypeDtWebster.qml_wordListhw_index" + index

                            Rectangle {
                                id: id_word_hw_background
                                width: id_word_hw_text.width + 32 * 2
                                height: parent.height
                                color: YColors.grayNormal
                                opacity: parent.pressed ? 0.6 : 1
                                radius: 38

                                Text {
                                    id: id_word_hw_text
                                    anchors.centerIn: parent
                                    font.family: fontManager.fontFamilyEnUs
                                    textFormat: YTextBase.RichText
                                    color: index === id_wordList_hw_repeater.curIndex ? YColors.red : YColors.white
                                    font.pixelSize: 24
                                    font.weight: Font.Bold
                                    width: paintedWidth
                                    height: paintedHeight
                                    text: model.modelData.hw
                                }

                            }

                            onClicked: {
                                if (id_wordList_hw_repeater.curIndex !== index)
                                {
                                    id_wordList_hw_repeater.curIndex = index
                                    id_word_def_sensb_Column.modelModelData = dictJson.wordList[index].def.sensb[0]
                                }
                            }
                        }
                    }
                }
            }

            YText {
                id: id_wordList_hw_text
                font.family: fontManager.fontFamilyEnUs
                font.pixelSize: 26
                color: YColors.grayText
                width: parent.width
                height: contentHeight
                text: visible ? dictJson.wordList[0].hw : ""
                visible: dictJson.wordList.length === 1
            }

            Column {
                id: id_word_def_sensb_Column
                spacing: 20
                width: id_for_wordList_column.width
                property var modelModelData: (typeof dictJson.wordList[0].def != "undefined" && typeof dictJson.wordList[0].def.sensb != "undefined")
                                                      ? dictJson.wordList[0].def.sensb[0] : null

                YTextBase {
                    font.family: fontManager.fontFamilyClass
                    font.pixelSize: 26
                    font.weight: Font.Normal
                    color: "#FFFFFF"
                    wrapMode: YTextBase.Wrap
                    textFormat: YTextBase.RichText
                    width: id_for_wordList_column.width
                    height: paintedHeight
                    text:  visible ? '[ <span style="font-style: italic">' + id_word_def_sensb_Column.modelModelData.et + ' </span> ]' : ""
                    visible: typeof id_word_def_sensb_Column.modelModelData.et != "undefined"
                }

                Item {
                    id: id_word_def_sensb_meaning_item
                    width: id_for_wordList_column.width
                    height: id_meaning_content.height
                    readonly property var modelModelData: (typeof id_word_def_sensb_Column.modelModelData.meaning == "undefined")
                                                          ? null : id_word_def_sensb_Column.modelModelData.meaning[0]

                    YTextBase {
                        id: id_meaning_index
                        color: YColors.grayText
                        font.pixelSize: 26
                        font.weight: Font.Normal
                        font.family: fontManager.fontFamilyZhCn
                        width: 40
                        height: id_meaning_content.height
                        text: visible ? "1." : ""//("%1.").arg(index + 1)
                        visible: id_meaning_dt_content.visible || id_meaning_sense_repeater.count > 0
                    }

                    Column {
                        id: id_meaning_content
                        anchors.left: id_meaning_index.right
                        anchors.right: parent.right

                        YTextBase {
                            id: id_meaning_dt_content
                            color: "#FFFFFF"
                            font.pixelSize: 28
                            font.weight: Font.Medium
                            font.family: fontManager.fontFamilyEnUs
                            wrapMode: YTextBase.Wrap
                            textFormat: YTextBase.RichText
                            width: id_meaning_content.width
                            height: paintedHeight
                            text: visible ? removeHtmlTag(id_word_def_sensb_meaning_item.modelModelData.dt.content[0]) : ""
                            visible: (typeof id_word_def_sensb_meaning_item.modelModelData.dt != "undefined")
                                     && (typeof id_word_def_sensb_meaning_item.modelModelData.dt.content != "undefined")
                            //text: dictJson.wordList[0].def.sensb[0].meaning[0].dt.content[0]
                        }

                        Repeater {
                            id: id_meaning_sense_repeater
                            model: (typeof id_word_def_sensb_meaning_item.modelModelData.sense == "undefined") ? null : id_word_def_sensb_meaning_item.modelModelData.sense
                            //model: dictJson.wordList[0].def.sensb[0].meaning[0].sense

                            Column {
                                id: id_meaning_sense_column
                                width: id_meaning_content.width
                                readonly property var modelModelData: model.modelData

                                Item {
                                    id: id_meaning_sense_content_item
                                    width: id_meaning_content.width
                                    height: id_meaning_sense_index.height
                                    visible: id_meaning_sense_index.visible || !id_meaning_sense_content.textIsEmpty

                                    YTextBase {
                                        id: id_meaning_sense_index
                                        color: YColors.grayText
                                        font.pixelSize: 24
                                        font.weight: Font.Normal
                                        font.family: fontManager.fontFamilyEnUs
                                        width: 36
                                        height: id_meaning_sense_content.height
                                        text: ("%1:").arg(String.fromCharCode(97 + index))
                                        visible: !(id_meaning_sense_repeater.count === 1
                                                   && (id_meaning_sense_content.textIsEmpty || id_meaning_sense_subSense_repeater.count < 1))
                                        //text: "a:"
                                    }

                                    YTextBase {
                                        id: id_meaning_sense_content
                                        anchors.left: id_meaning_sense_index.visible ? id_meaning_sense_index.right : parent.left
                                        anchors.right: parent.right
                                        color: "#FFFFFF"
                                        font.pixelSize: 28
                                        font.weight: Font.Normal
                                        font.family: fontManager.fontFamilyEnUs
                                        wrapMode: YTextBase.Wrap
                                        textFormat: YTextBase.RichText
                                        height: paintedHeight
                                        text: textIsEmpty ? "" : removeHtmlTag(id_meaning_sense_column.modelModelData.dt.content[0])
                                        //text: dictJson.wordList[0].def.sensb[0].meaning[0].sense[0].dt.content[0]
                                        readonly property bool textIsEmpty: (typeof id_meaning_sense_column.modelModelData.dt == "undefined"
                                                                            || typeof id_meaning_sense_column.modelModelData.dt.content == "undefined")
                                    }
                                }

                                Repeater {
                                    id: id_meaning_sense_subSense_repeater
                                    model: (typeof id_meaning_sense_column.modelModelData.subSense == "undefined") ? null : id_meaning_sense_column.modelModelData.subSense
                                    //model: dictJson.wordList[0].def.sensb[0].meaning[0].sense[0].subSense[0]

                                    Item {
                                        id: id_meaning_sense_subSense_item
                                        width: id_meaning_content.width
                                        height: id_meaning_sense_subSense_content.height
                                        readonly property var modelModelData: model.modelData

                                        YTextBase {
                                            id: id_meaning_sense_subSense_index
                                            color: YColors.grayText
                                            font.pixelSize: 24
                                            font.weight: Font.Normal
                                            font.family: fontManager.fontFamilyEnUs
                                            width: 36
                                            height: id_meaning_sense_subSense_content.height
                                            text: ("(%1)").arg(index + 1)
                                            visible: id_meaning_sense_subSense_repeater.count > 1
                                        }

                                        YTextBase {
                                            id: id_meaning_sense_subSense_content
                                            anchors.left: id_meaning_sense_subSense_index.visible ? id_meaning_sense_subSense_index.right : parent.left
                                            anchors.right: parent.right
                                            color: "#FFFFFF"
                                            font.pixelSize: 28
                                            font.weight: Font.Normal
                                            font.family: fontManager.fontFamilyEnUs
                                            wrapMode: YTextBase.Wrap
                                            textFormat: YTextBase.RichText
                                            height: paintedHeight
                                            text: visible ? removeHtmlTag(id_meaning_sense_subSense_item.modelModelData.dt.content[0]) : ""
                                            visible: typeof id_meaning_sense_subSense_item.modelModelData.dt != "undefined"
                                                && typeof id_meaning_sense_subSense_item.modelModelData.dt.content != "undefined"
                                            //text: dictJson.wordList[0].def.sensb[0].meaning[0].sense[0].subSense[0].dt.content[0]
                                        }

                                    } // Item

                                } // Repeater id_meaning_sense_subSense_repeater

                            } // Item

                        } // Repeater id_meaning_sense_repeater

                    } // Column id_meaning_content

                } // Item

            } // Column

        } //Column id_for_wordList_column

    }// Item root

}


import QtQuick 2.12

import BaseQml 1.0
import "../i18n"

YDictTypeBase {
    id: id_poem_dict
    title: YTranslateText.dtChPoemDict
    property int poemCount: 0
    property string poemDataSource: dictJson.source
    onDictJsonChanged: {
        poemCount = (typeof dictJson.poems == "undefined") ? 0 : dictJson.poems.length
        poemDataSource = dictJson.source
        detail_button_visible = (/*poemDataSource === "poem_data" || */poemDataSource === "poem_sentence") && poemCount == 1
    }

    YLoader {
        id: id_content_loader
        active: true
        width: parent.width
        height: item.height
        asynchronous: false

        sourceComponent: {
            if (id_poem_dict.poemDataSource === "poem_author")
            {
                return id_poem_author;
            }
            else if (id_poem_dict.poemCount > 1)
            {
                return id_multi_poem;
            }
            else if (id_poem_dict.poemDataSource === "poem_data")
            {
                let jsonPoemData = (id_poem_dict.poemCount === 1)? id_poem_dict.dictJson.poems[0] : null
                id_poem_dict.title =  YTranslateText.dtChPoemDict + " - " + jsonPoemData.detail.title.origin
                return id_poem_data;
            }
            else// if (poemDataSource === "poem_sentence")
            {
                return id_poem_sentence
            }
        }

        Component {
            id: id_poem_author

            YDictTypeDtChPoemAuthor {
                width: id_poem_dict.width
                jsonAuthorData: typeof id_poem_dict.dictJson.author != "undefined" ? id_poem_dict.dictJson.author : null
            }
        }

        Component {
            id: id_multi_poem

            Column {
                width: id_poem_dict.width
                spacing: 16

                Repeater {
                    id: id_poem_repeater
                    model: id_poem_dict.dictJson.poems

                    Column {
                        id: id_poem_column
                        width: id_poem_dict.width
                        spacing: 6
                        property var modelModelData: model.modelData

                        YTextMedium {
                            width: parent.width
                            height: paintedHeight
                            font.family: fontManager.fontFamilyZhCn
                            font.weight: Font.Bold
                            color: YColors.blueText
                            wrapMode: YTextBase.Wrap
                            text: id_poem_column.modelModelData.detail.title.origin

                            YMouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    let newContentObj = {"keyword": id_poem_dict.dictJson.keyword,
                                        "source": "poem_data",
                                        "poems": [id_poem_column.modelModelData]}
                                    id_poem_dict.dictJson.authors.forEach(function(authorObject){
                                        if (authorObject.name === id_poem_column.modelModelData.author)
                                            newContentObj["authors"] = [authorObject]
                                    })
                                    console.log("YDictTypeDtChPoemDict.qml===poem_title.onClicked newContentObj:", JSON.stringify(newContentObj))
                                    qmlGlobal.showDictDetailPage(dictType, JSON.stringify(newContentObj))
                                }
                                objectName: "YDictTypeDtChPoemDict.qml_id_poem_column"
                            }
                        }

                        YText {
                            width: parent.width
                            font.family: fontManager.fontFamilyZhCn
                            color: YColors.grayText
                            wrapMode: YTextBase.Wrap
                            text: {
                                //朝代和作者
                                var qsDynasty = id_poem_column.modelModelData.dynasty
                                var qsAuthor = id_poem_column.modelModelData.author
                                //首句诗词
                                var qsFirstSentence = id_poem_column.modelModelData.detail.content[0].sentences[0].origin

                                return qsDynasty + (qsDynasty.length > 0 ? "/" : "") + qsAuthor + " " + qsFirstSentence
                            }
                            elide: YTextBase.ElideRight
                        }
                    }
                }
            }
        }

        Component {
            id: id_poem_data

            YDictTypeDtChPoemDataGuide {
                width: id_poem_dict.width
                jsonPoemData: (id_poem_dict.poemCount === 1)? id_poem_dict.dictJson.poems[0] : null
                authorIntro: {
                    let qsAuthorIntro = ""
                    if (jsonPoemData) {
                        id_poem_dict.dictJson.authors.forEach(function(authorObject){
                            if (authorObject.name === jsonPoemData.author)
                                qsAuthorIntro += authorObject.author.intro
                        })
                    }
                    return qsAuthorIntro
                }
            }

//            YDictTypeDtChPoemData {
//                width: id_poem_dict.width
//                bSimpleShow: true
//                jsonPoemData: (id_poem_dict.poemCount === 1)? id_poem_dict.dictJson.poems[0] : null
//                authorIntro: {
//                    let qsAuthorIntro = ""
//                    if (jsonPoemData) {
//                        id_poem_dict.dictJson.authors.forEach(function(authorObject){
//                            if (authorObject.name === jsonPoemData.author)
//                                qsAuthorIntro += authorObject.author.intro
//                        })
//                    }
//                    return qsAuthorIntro
//                }

//            }
        }

        Component {
            id: id_poem_sentence

            YDictTypeDtChPoemSentence {
                width: id_poem_dict.width
                jsonPoemData: (id_poem_dict.poemCount === 1) ? id_poem_dict.dictJson.poems[0] : null
                sentenceKeyWord: id_poem_dict.dictJson.keyword
            }
        }
    }
}


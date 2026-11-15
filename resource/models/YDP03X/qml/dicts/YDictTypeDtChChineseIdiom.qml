import QtQuick 2.12
import com.youdao.pen 1.0

import BaseQml 1.0
import "../i18n"
import "../components"

YDictTypeBase {
    id: id_dict_type_ch_chinese_idiom
    title: YTranslateText.dtChIdiom

    Item {
        width: parent.width
        height: id_for_wgt_ch.height

        Column {
            id: id_for_wgt_ch
            spacing: 0
            width: parent.width

            YTextBase {
                id: id_detail_meaning_examples
                wrapMode: YText.Wrap
                color: YColors.white
                font.family: fontManager.fontFamilyZhCn
                font.pixelSize: 28
                width: parent.width
                height: contentHeight
                text: dictJson.meaning
                visible: (typeof dictJson.meaning !== "undefined")
                         && (dictJson.meaning.length > 0)
                textFormat: YTextBase.PlainText
            }

            YSpacingForColumn{
                height: 24
                visible: id_story_word_value.visible
            }

            YVerticalDividingLine {
                visible: id_story_word_value.visible
            }
            YSpacingForColumn{
                height: 24
                visible:id_story_word_value.visible
            }
            YText {
                wrapMode: YText.Wrap
                width: parent.width
                height: contentHeight
                font.family: fontManager.fontFamilyZhCn
                color: YColors.red
                text: YTranslateText.idiomStory
                font.pixelSize: 26
                font.letterSpacing: 2
                visible: id_story_word_value.visible
                Component.onCompleted: {
                    dictNodeCompleted(text, dictType, 1, this);
                }
            }
            YSpacingForColumn{
                height: 10
                visible:id_story_word_value.visible
            }

            YText {
                id: id_story_word_value
                wrapMode: YText.Wrap
                color: YColors.white
                font.family: fontManager.fontFamilyZhCn
                font.pixelSize: 28
                lineHeightMode: Text.FixedHeight
                lineHeight: 37
                width: parent.width
                height: contentHeight
                text: {
                    if(typeof dictJson.story!="undefined" && dictJson.story.length>48)
                    {
                        loadMoreVisible=true
                        return "    "+dictJson.story.substr(0,48).trim()+"..."
                    }else
                    {
                        loadMoreVisible=false
                        return "    "+typeof dictJson.story!="undefined"&&
                                typeof dictJson.story.length!="undefined" && dictJson.story.length ? dictJson.story.trim() : ""
                    }
                }
                visible: typeof dictJson.story!="undefined" && dictJson.story.length?true:false
                property bool loadMoreVisible: false
                font.letterSpacing: 2
                YAudioPlayButton {
                    width: 32
                    implicitHeight: 32
                    sourceSize: Qt.size(32, 32)
                    imageName: "dict/sound"
                    id: id_sound_icon
                    textFontFamily: fontManager.fontFamilyEnUs
                    textFormat: YText.PlainText
                    leftMargin: 0
                    anchors.left: parent.left
                    anchors.top:parent.top
                    anchors.topMargin: 2
                    color: YColors.black
                    text: ""
                    onValidClicked: {
                        if (playing) {
                            logManager.sendHttpLog("action=detail_idiom_story")
                            playWord(dictJson.story.trim(), "zh")
                        }
                    }
                }
            }
            YSpacingForColumn{
                height: 10
                visible:id_story_word_value.loadMoreVisible
            }

            YButton {
                id: id_dict_story_detail_button
                radius: 30
                width: 162
                height: 52
                anchors.left: parent.left
                pixelSize: 26
                text: YTranslateText.loadmore
                color: "#27282C"
                textColor: YColors.grayText
                visible: id_story_word_value.loadMoreVisible
                onValidClicked: {
                    id_dict_page.backContentYPos = id_container_flickable.contentY
                    qmlGlobal.showDictDetailPage(dictType, JSON.stringify({"story":dictJson.story.trim()}), YTranslateText.idiomStory)
                }
            }

            YSpacingForColumn{
                height: 24
                visible: id_source_word_value.visible
            }


            YVerticalDividingLine {
                visible: id_source_word_value.visible
            }
            YSpacingForColumn{
                height: 24
                visible:id_source_word_value.visible
            }

            YText {
                wrapMode: YText.Wrap
                width: parent.width
                height: contentHeight
                font.family: fontManager.fontFamilyZhCn
                color: YColors.red
                text: YTranslateText.idiomSource
                font.pixelSize: 26
                font.letterSpacing: 2
                visible: id_source_word_value.visible
                Component.onCompleted: {
                    dictNodeCompleted(text, dictType, 1, this);
                }
            }
            YSpacingForColumn{
                height: 10
                visible: id_source_word_value.visible
            }

            YTextBase {
                id: id_source_word_value
                property bool loadMoreVisible: false
                wrapMode: YText.Wrap
                color: YColors.white
                font.family: fontManager.fontFamilyZhCn
                font.pixelSize: 28
                lineHeightMode: Text.FixedHeight
                lineHeight: 37
                width: parent.width
                height: contentHeight
                text: {
                    if(dictJson.source.length>48)
                    {
                         loadMoreVisible=true
                        return dictJson.source.substr(0,48)+"..."
                    }else
                    {
                        loadMoreVisible=false
                        return dictJson.source.length ? dictJson.source : ""
                    }
                }
                visible: typeof dictJson.source != "undefined" && dictJson.source.length?true:false
                font.letterSpacing: 2
            }
            YSpacingForColumn{
                height: 10
                visible: id_source_word_value.loadMoreVisible
            }

            YButton {
                id: id_dict_detail_button
                radius: id_dict_story_detail_button.radius
                width: id_dict_story_detail_button.width
                height: id_dict_story_detail_button.height
                anchors.left: parent.left
                text: YTranslateText.loadmore
                color: "#27282C"
                textColor: YColors.grayText
                visible: id_source_word_value.loadMoreVisible
                onValidClicked: {
                    id_dict_page.backContentYPos = id_container_flickable.contentY
                    qmlGlobal.showDictDetailPage(dictType, JSON.stringify({"source":dictJson.source}), YTranslateText.idiomSource)
                }
            }
            YSpacingForColumn{
                height: 24
                visible: id_synonyms_word_value.visible
            }


            YVerticalDividingLine {
                visible: id_synonyms_word_value.visible
            }
            YSpacingForColumn{
                height: 24
                visible: id_synonyms_word_value.visible
            }


            YText {
                wrapMode: YText.Wrap
                width: parent.width
                height: contentHeight
                font.family: fontManager.fontFamilyZhCn
                color: YColors.red
                text: YTranslateText.synonyms
                font.pixelSize: 26
                font.letterSpacing: 2
                visible: id_synonyms_word_value.visible
                Component.onCompleted: {
                    dictNodeCompleted(text, dictType, 1, this);
                }

            }
            YSpacingForColumn{
                height: 10
                visible: id_synonyms_word_value.visible
            }

            Flow{
                //height:
                id:id_synonyms_word_value
                width: 614
                //anchors.top: id_antonyms_pos_txt.bottom
                spacing:0
                visible: typeof dictJson.synonyms != "undefined" && dictJson.synonyms.length
                //readonly property var modelModelData: model.modelData
                Repeater{
                    id:id_synonyms_repeter
                    model: dictJson.synonyms
                    YDictPageClickSearchTextItem{
                        word:model.modelData
                        isCHType: true
                        onClicked: {
                            id_dict_page.clickSearchWord(model.modelData)
                            //id_dict_page.requeryWord(model.modelData, "en", "zh-CHS")
                        }
                    }
                }
            }

            YSpacingForColumn{
                height: 24
                visible: id_antonyms_word_value.visible
            }

            //反义词
            YVerticalDividingLine {
                visible: id_antonyms_word_value.visible
            }
            YSpacingForColumn{
                height: 24
                visible: id_antonyms_word_value.visible
            }

            YText {
                wrapMode: YText.Wrap
                width: parent.width
                height: contentHeight
                font.family: fontManager.fontFamilyZhCn
                color: YColors.red
                text: YTranslateText.antonyms
                font.pixelSize: 26
                font.letterSpacing: 2
                visible: id_antonyms_word_value.visible

                Component.onCompleted: {
                    dictNodeCompleted(text, dictType, 1, this);
                }
            }
            YSpacingForColumn{
                height: 10
                visible: id_antonyms_word_value.visible
            }

            Flow{
                //height:
                id:id_antonyms_word_value
                width: 614
                //anchors.top: id_antonyms_pos_txt.bottom
                spacing:0
                visible: typeof dictJson.antonyms != "undefined" && dictJson.antonyms.length
                //readonly property var modelModelData: model.modelData
                Repeater{
                    id:id_antonyms_repeter
                    model: dictJson.antonyms
                    YDictPageClickSearchTextItem{
                        word:model.modelData
                        isCHType: true
                        onClicked: {
                            id_dict_page.clickSearchWord(model.modelData)
                            //id_dict_page.requeryWord(model.modelData, "en", "zh-CHS")
                        }
                    }
                }
            }
        }
    }
}
/*
一丝不苟
{
    "antonyms":[
        "粗枝大叶",
        "敷衍了事",
        "粗心大意"
    ],
    "meaning":"一点儿也不马虎。形容人做事认真细致。",
    "pinyin":[
        "yì",
        "sī",
        "bù",
        "gǒu"
    ],
    "sentence":[
        {
            "sentence":"她对待工作一丝不苟，认真负责。",
            "source":"",
            "type":"SENTENCE"
        }
    ],
    "source":"清朝吴敬梓的《儒林外史》第四回：“上司访知，见世叔一丝不苟，升迁就在指日。”",
    "story":"　　在明朝，皇帝禁止宰杀用来耕地的牛。有一天，乡绅张静斋与举人范进去拜访汤知县。汤知县招待他们时，有位老人送来了五十斤牛肉。汤知县以前收了老百姓很多礼物，但是皇上有禁令，不允许宰牛，这个老人送来的牛肉，汤知县不知道该怎么办，于是汤知县请教张静斋。张静斋说道：“你可以把那位送礼的老人抓起来，把送来的牛肉堆在大枷上面，贴告示说明他犯的错误。皇上如果知道你办事这样认真，肯定会提拔你的。”汤知县听后，就照着办了。
　　后来，人们用“一丝不苟”这个成语指做事情非常认真仔细。",
    "synonyms":[

    ]
}
  */

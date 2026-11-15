import QtQuick 2.12

import BaseQml 1.0
import "../i18n"
import "../components"

Column {
    id:id_synonymsAndSynonyms
    width: id_dict_content_column.width
    property var idDictPageObject
    spacing: 10
    function showPage(qrcqml, cachePage, properties) {
        if ((typeof cachePage !== undefined) && cachePage) {
            return id_page_pop_helper.cacheShow(qrcqml, false, properties)
        }
        return id_page_pop_helper.show(qrcqml, false, false, properties)
    }
    Repeater {
        id: id_synonymsAndSynonyms_repeater
        model: dictJson
        Item {
            id: id_synonymsAndSynonyms_item
            width: parent.width
            height: id_synonymsAndSynonyms_pos_txt.contentHeight+id_synonyms_flow.height

            readonly property var modelModelData: model.modelData
            YTextBase {
                id: id_synonymsAndSynonyms_pos_txt
                font.pixelSize: 28
                //font.styleName: "italic"
                font.family: fontManager.fontFamilyZhCn
                color: YColors.grayText
                text: ('<span style="font-family:%1; font-style:italic;">').arg(fontManager.fontFamilyClass)
                      + id_synonymsAndSynonyms_item.modelModelData.pos + '</span>' + model.modelData.meaning
                width: 614
                wrapMode: YTextBase.Wrap
                textFormat: YText.RichText
                height: id_synonymsAndSynonyms_pos_txt.contentHeight
                // anchors.bottom: id_sense.bottom
            }

            Flow{
                //height:
                id:id_synonyms_flow

                width: 614
                anchors.top: id_synonymsAndSynonyms_pos_txt.bottom
                spacing:0
                //readonly property var modelModelData: model.modelData
                Repeater{
                    id:id_synonyms_repeter
                    model:id_synonymsAndSynonyms_item.modelModelData.synonyms

                    YDictPageClickSearchTextItem{
                        word: model.modelData
                        isCHType: false
                        onClicked: {
                            qmlGlobal.queryFromDictPage(model.modelData, "en", "zh-CHS")
                            //id_dict_page.requeryWord(model.modelData, "en", "zh-CHS")
                        }
                    }

                }
            }

        }
    }
}


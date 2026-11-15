import QtQuick 2.12

import BaseQml 1.0
import "../i18n"

Column {
    width: id_dict_content_column.width
    spacing: 10
    Repeater {
        id: id_fixed_collocation_repeater
        model: dictJson
        Item {
            id: id_fixed_Collocation_item
            width: parent.width
            height: id_fixed_collocation_key.contentHeight+id_fixed_collocation_value.contentHeight
            readonly property var modelModelData: model.modelData
            YTextBase {
                id: id_fixed_collocation_key
                width: 614
                height: contentHeight
                font.pixelSize: 28
                font.family: fontManager.fontFamilyEnUs
                color: YColors.white
                font.bold: true
                wrapMode: Text.WordWrap
                text: model.modelData.phrase
            }
            YTextBase {
                id: id_fixed_collocation_value
                width: 614
                height: contentHeight
                font.pixelSize: 26
                anchors.top: id_fixed_collocation_key.bottom
                anchors.topMargin: 4
                font.family: fontManager.fontFamilyZhCn
                color: YColors.grayText
                wrapMode: Text.WordWrap
                text: model.modelData.meanings[0]
            }
        }
    }
}

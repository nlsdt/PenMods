import QtQuick 2.12

import BaseQml 1.0

Item {
    id: id_word_dro_item
    height: id_word_dro_content_column.height
    property var modelModelData: null

    YTextBase {
        id: id_word_dro_index
        color: YColors.grayText
        font.pixelSize: 24
        font.weight: Font.Normal
        font.family: fontManager.fontFamilyEnUs
        width: 40
        height: id_word_dro_content_column.height
        text: index + 1
    }

    Column {
        id: id_word_dro_content_column
        anchors.left: id_word_dro_index.right
        anchors.right: parent.right

        YTextBase {
            color: "#FFFFFF"
            font.pixelSize: 28
            font.weight: Font.Bold
            font.family: fontManager.fontFamilyEnUs
            wrapMode: YTextBase.Wrap
            textFormat: YTextBase.RichText
            height: paintedHeight
            width: id_word_dro_content_column.width
            text: visible ? removeHtmlTag(id_word_dro_item.modelModelData.drp) : ""
            visible: null !== id_word_dro_item.modelModelData
        }

        Repeater {
            id: id_word_dro_def_sensb_repeater
            model: null === id_word_dro_item.modelModelData ? null : id_word_dro_item.modelModelData.def.sensb

            Item {
                id: id_word_dro_def_sensb_item
                width: id_word_dro_content_column.width
                height: id_word_dro_def_sensb_content.height
                readonly property var modelModelData: model.modelData

                YTextBase {
                    id: id_word_dro_def_sensb_index
                    color: YColors.grayText
                    font.pixelSize: 24
                    font.weight: Font.Normal
                    font.family: fontManager.fontFamilyEnUs
                    width: 36
                    height: id_word_dro_def_sensb_content.height
                    text: ("(%1)").arg(index + 1)
                }

                YText {
                    id: id_word_dro_def_sensb_content
                    anchors.left: id_word_dro_def_sensb_index.visible ? id_word_dro_def_sensb_index.right : parent.left
                    anchors.right: parent.right
                    color: YColors.grayText
                    font.weight: Font.Normal
                    font.family: fontManager.fontFamilyEnUs
                    wrapMode: YTextBase.Wrap
                    textFormat: YTextBase.RichText
                    height: paintedHeight
                    text: removeHtmlTag(id_word_dro_def_sensb_item.modelModelData.sense.dt)
                }

            } // Item

        } // Repeater id_word_dro_def_sensb_repeater

        Item {
            id: id_word_dro_def_sensb_object_item
            width: id_word_dro_content_column.width
            height: id_word_dro_def_sensb_object_content.height
            visible: id_word_dro_def_sensb_repeater.count < 1

            YText {
                id: id_word_dro_def_sensb_object_content
                color: YColors.grayText
                font.weight: Font.Normal
                font.family: fontManager.fontFamilyEnUs
                wrapMode: YTextBase.Wrap
                textFormat: YTextBase.RichText
                width: parent.width
                height: paintedHeight
                text: visible ? removeHtmlTag(id_word_dro_item.modelModelData.def.sensb.sense.dt) : ""
                visible: null !== id_word_dro_item.modelModelData && id_word_dro_def_sensb_object_item.visible
            }

        } // Item id_word_dro_def_sensb_object_item

    } //Column id_word_dro_content_column

} //Item


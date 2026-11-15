import BaseQml 1.0
import com.youdao.pen 1.0
import QtQuick 2.12

import "../common"
import "../i18n"

/**
 * 自造词典记录的内容视图：把 YDictPenModsBlocks.js 切好的 block 列表排成词典的样子。
 *
 * 词头和例句带发音按钮，见 components/YCustomDictSayButton.qml（走宿主自己的发音接口）。
 *
 * 注意：Row/Column 是 positioner，子项**不能用 anchors**（会被忽略导致整块不显示），
 * 这里统一用显式 height + verticalAlignment 对齐。
 */
Column {
    id: id_custom_dict_content

    property var blocks: []
    width: parent.width
    spacing: 8

    readonly property int buttonSize: 24

    Repeater {
        model: id_custom_dict_content.blocks

        delegate: Loader {
            id: id_block_loader
            width: id_custom_dict_content.width
            property var block: model.modelData

            onLoaded: item.block = block

            sourceComponent: {
                switch (id_block_loader.block ? id_block_loader.block.type : "") {
                case "head":
                    return id_head_component
                case "tags":
                    return id_tags_component
                case "def":
                    return id_def_component
                case "example":
                    return id_example_component
                case "note":
                case "source":
                    return id_note_component
                case "kv":
                    return id_kv_component
                case "raw":
                    return id_raw_component
                case "index":
                    return id_index_component
                }
                return null
            }
        }
    }

    // 词头 + 音标 + 发音按钮
    Component {
        id: id_head_component

        Row {
            property var block: ({})
            spacing: 8

            YText {
                height: id_custom_dict_content.buttonSize
                verticalAlignment: Text.AlignVCenter
                font.pixelSize: 16
                font.weight: Font.DemiBold
                color: YColors.white
                text: block.word
                visible: text.length > 0
            }

            YText {
                height: id_custom_dict_content.buttonSize
                verticalAlignment: Text.AlignVCenter
                font.pixelSize: 13
                color: YColors.grayText
                text: block.phonetic
                visible: text.length > 0
            }

            YCustomDictSayButton {
                text: block.word
                lang: block.lang
                kind: "word"
            }
        }
    }

    Component {
        id: id_tags_component

        YText {
            property var block: ({})
            width: parent.width
            font.pixelSize: 12
            color: YColors.grayText
            wrapMode: YText.Wrap
            text: block.text
        }
    }

    Component {
        id: id_def_component

        Row {
            property var block: ({})
            spacing: 6

            YText {
                id: id_def_pos
                width: 44
                height: id_def_tran.height
                font.pixelSize: 14
                font.italic: true
                color: YColors.grayText
                elide: YText.ElideRight
                text: block.pos
            }

            YText {
                id: id_def_tran
                width: Math.max(0, parent.width - id_def_pos.width - 6)
                font.pixelSize: 14
                lineHeight: 20
                lineHeightMode: YText.FixedHeight
                wrapMode: YText.Wrap
                color: YColors.white
                text: block.tran
            }
        }
    }

    Component {
        id: id_example_component

        Row {
            property var block: ({})
            spacing: 6

            YCustomDictSayButton {
                id: id_example_sound
                text: block.en
                lang: block.lang
                kind: "sentence"
            }

            Column {
                width: Math.max(0, parent.width - id_example_sound.width - 6)
                spacing: 2

                YText {
                    width: parent.width
                    font.pixelSize: 14
                    lineHeight: 20
                    lineHeightMode: YText.FixedHeight
                    wrapMode: YText.Wrap
                    color: YColors.blueText
                    text: block.en
                    visible: text.length > 0
                }

                YText {
                    width: parent.width
                    font.pixelSize: 13
                    lineHeight: 18
                    lineHeightMode: YText.FixedHeight
                    wrapMode: YText.Wrap
                    color: YColors.grayText
                    text: block.zh
                    visible: text.length > 0
                }
            }
        }
    }

    Component {
        id: id_note_component

        YText {
            property var block: ({})
            width: parent.width
            font.pixelSize: 12
            lineHeight: 17
            lineHeightMode: YText.FixedHeight
            wrapMode: YText.Wrap
            color: YColors.grayText
            text: block.text
        }
    }

    Component {
        id: id_kv_component

        Row {
            property var block: ({})
            spacing: 8

            YText {
                id: id_kv_key
                width: 96
                height: id_kv_value.height
                font.pixelSize: 12
                color: YColors.grayText
                elide: YText.ElideRight
                text: block.key
            }

            YText {
                id: id_kv_value
                width: Math.max(0, parent.width - id_kv_key.width - 8)
                font.pixelSize: 13
                lineHeight: 18
                lineHeightMode: YText.FixedHeight
                wrapMode: YText.Wrap
                color: YColors.white
                text: block.value
            }
        }
    }

    Component {
        id: id_raw_component

        YText {
            property var block: ({})
            width: parent.width
            font.pixelSize: 12
            lineHeight: 17
            lineHeightMode: YText.FixedHeight
            wrapMode: YText.Wrap
            color: YColors.grayText
            text: block.text
        }
    }

    Component {
        id: id_index_component

        YText {
            property var block: ({})
            width: parent.width
            font.pixelSize: 13
            font.weight: Font.DemiBold
            color: YColors.grayText
            text: block.text
        }
    }
}

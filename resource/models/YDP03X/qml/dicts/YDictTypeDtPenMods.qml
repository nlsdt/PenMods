import BaseQml 1.0
import com.youdao.pen 1.0
import QtQuick 2.12

import "../common"
import "../components"
import "../i18n"
import "./YDictPenModsBlocks.js" as PenModsBlocks

/**
 * 自造词典在主查询结果页里的渲染器。
 *
 * C++ 侧（src/dict/CustomDict::payloadFor）把命中的记录包成
 *     {"name": 词典名, "word": 词, "record": {...}}
 * （记录不是 JSON 时用 "raw": 文本）。排版见 components/YCustomDictContentView.qml：
 * 推荐 schema 排成内置词典那样（词头/例句带发音按钮），其它 JSON 走键值行。
 */
YDictTypeBase {
    id: id_dt_penmods
    // 自造词典那一段排在结果页最前面，而基类在第一段时不显示自己的标题，
    // 所以词典名由本组件自己画（样式跟基类标题一致：红色 16px）。
    title: ""

    readonly property var contentBlocks: {
        if (dictJson === null || typeof dictJson === "undefined")
            return [];
        if (typeof dictJson.raw === "string")
            return [{"type": "raw", "text": dictJson.raw}];
        return PenModsBlocks.blocks(dictJson.record);
    }

    Item {
        width: parent.width
        height: id_dict_name.height + id_body.height + 12

        YTextBase {
            id: id_dict_name
            width: parent.width
            font.pixelSize: 16
            color: YColors.red
            height: contentHeight
            text: (dictJson && typeof dictJson.name === "string") ? dictJson.name : "自定义词典"
        }

        YCustomDictContentView {
            id: id_body
            anchors.top: id_dict_name.bottom
            anchors.topMargin: 8
            blocks: id_dt_penmods.contentBlocks
        }
    }
}

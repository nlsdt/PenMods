import QtQuick 2.12
import com.github.penuniverse 1.0

import BaseQml 1.0
import "../common"
import "../components"

YBackButtonPage {
    id: root
    objectName: "YPage===ApiCacheStatsPage.qml"

    function rateText(rate) {
        return Number(rate || 0).toFixed(1) + "%";
    }

    // 单价来自 {endpoint}/models 的 pricing（美元 / token），写入时按
    // 「美元 / 百万 token」固化，所以金额显示为美元。
    function costText(cost) {
        return "$" + Number(cost || 0).toFixed(4);
    }

    function tokenText(cached, total) {
        if (!total || total <= 0)
            return "本会话暂无请求";
        return "命中 " + cached + " / 输入 " + total + " tokens";
    }

    Flickable {
        anchors.fill: parent
        anchors.leftMargin: 90
        anchors.rightMargin: 16
        contentHeight: contentColumn.height + 16
        clip: true

        Column {
            id: contentColumn
            anchors.left: parent.left
            anchors.right: parent.right
            spacing: 7

            YSettingItemTitle {
                title: "本会话缓存统计"
            }

            DescribedClickableTextBox {
                title: "命中率 · " + root.rateText(chatbot.apiCacheStats.hitRate)
                describe: root.tokenText(chatbot.apiCacheStats.cachedTokens,
                                         chatbot.apiCacheStats.inputTokens)
                describeItem.width: width - 40
                describeItem.font.pixelSize: 24
                opacityChangableWhenPressed: false
            }

            DescribedClickableTextBox {
                title: "本会话花费 · " + root.costText(chatbot.apiCacheStats.cost)
                describe: "输出 " + (chatbot.apiCacheStats.outputTokens || 0) + " tokens"
                describeItem.width: width - 40
                describeItem.font.pixelSize: 24
                opacityChangableWhenPressed: false
            }

            PenModsSettingRow {
                title: "刷新模型单价"
                value: "内置价目表 · 可刷新"
                onClicked: {
                    chatbot.refreshModelPrices();
                    showToast("正在从模型接口获取单价", 0);
                }
            }
        }
    }
}

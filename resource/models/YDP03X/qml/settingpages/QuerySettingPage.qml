import QtQuick 2.12
import com.youdao.pen 1.0

import BaseQml 1.0
import "../common"
import "../components"
import "../i18n"

YSettingItemPage {
    id: id_setting_item
    objectName: "YPage===QuerySettingPage.qml"

    Flickable {
        id: id_setting_item_view
        anchors.fill: parent
        anchors.leftMargin: 90
        anchors.rightMargin: 16
        contentHeight: id_title_container.height + id_column.height

        YSettingItemTitle {
            id: id_title_container
            title: "扫描查询设置"
        }

        Column {
            id: id_column
            anchors.top: id_title_container.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            spacing: 8

            DescribedSwitchItem {
                title: YTranslateText.continueScan
                description: "一次扫描后，若两秒内再次扫描则视为追加扫描。"
                switchOn: settingManager.isContinueScan
                interval: 0
                onTimerTriggered: {
                    settingManager.isContinueScan = switchOn
                }
            }

            DescribedSwitchItem {
                title: "手动输入内容查询"
                description: "在主菜单点击 \"查词翻译\" 时打开键盘。"
                switchOn: queryTweaks.typeByHand
                interval: 0
                onTimerTriggered: {
                    queryTweaks.typeByHand = switchOn
                }
            }

            DescribedSwitchItem {
                title: "扫描结果转到小写"
                description: ""
                switchOn: queryTweaks.lowerScan
                interval: 0
                onTimerTriggered: {
                    queryTweaks.lowerScan = switchOn
                }
            }

            YSpacingForColumn {
                implicitHeight: 4
            }
        }
    }
}

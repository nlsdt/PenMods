import QtQuick 2.12
import com.youdao.pen 1.0

import BaseQml 1.0
import "../common"
import "../i18n"

YSettingItemPage {
    id: id_setting_item
    objectName: "YPage===LockSceneSettingPage.qml"
    property alias title: id_title_container.title

    Flickable {
        id: id_setting_item_view
        anchors.fill: parent
        anchors.leftMargin: 90
        anchors.rightMargin: 16
        contentHeight: id_title_container.height + id_column.height

        YSettingItemTitle {
            id: id_title_container
            title: "请设置需要使用密码的场景"
        }

        Column {
            id: id_column
            anchors.top: id_title_container.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            spacing: 8

            PenModsSwitchRow {
                title: "设备重启后"
                checked: locker.getScene('restart')
                visible: false // TODO: 与系统重启流程已解耦
                onRowToggled: locker.setScene('restart', checked)
            }

            PenModsSwitchRow {
                title: "点亮屏幕时"
                checked: locker.getScene('screen_on')
                visible: false // TODO
                onRowToggled: locker.setScene('screen_on', checked)
            }

            PenModsSwitchRow {
                title: "取消按键小助手"
                checked: locker.getScene('antiembs_deactivate')
                onRowToggled: locker.setScene('antiembs_deactivate', checked)
            }

            PenModsSwitchRow {
                title: "隐藏文件设置"
                checked: locker.getScene('filemanager')
                onRowToggled: locker.setScene('filemanager', checked)
            }

            PenModsSwitchRow {
                title: "重置选项页面"
                checked: locker.getScene('reset_page')
                onRowToggled: locker.setScene('reset_page', checked)
            }

            PenModsSwitchRow {
                title: "开发者选项页面"
                checked: locker.getScene('dev_setting')
                onRowToggled: locker.setScene('dev_setting', checked)
            }

            YSpacingForColumn {
                implicitHeight: 4
            }
        }
    }
}

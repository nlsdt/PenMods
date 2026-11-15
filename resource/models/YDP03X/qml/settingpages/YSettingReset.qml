import QtQuick 2.12

import BaseQml 1.0
import "../components"
import "../i18n"

YSettingItemPage {
    id: id_setting_item
    objectName: "YPage===YSettingReset.qml"

    Column {
        anchors.left: parent.left
        anchors.leftMargin: 90
        anchors.right: parent.right
        anchors.rightMargin: 16
        spacing: 0

        YSettingItemTitle {
            id: id_title_container
            title: YTranslateText.resetChoice
        }

        YButtonBase {
            implicitHeight: 76
            anchors.left: parent.left
            anchors.right: parent.right
            YTextMedium {
                text: YTranslateText.resetSettings
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.leftMargin: 20
            }
            onClicked: {
                id_reset_settings.show()
            }
        }

        YSpacingForColumn {
            implicitHeight: 10
        }

        YButtonBase {
            implicitHeight: 76
            anchors.left: parent.left
            anchors.right: parent.right
            YTextMedium {
                text: YTranslateText.resetFactory
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.leftMargin: 20
            }
            onClicked: {
                id_reset_factory.show()
            }
        }

        YSpacingForColumn {
            implicitHeight: 12
        }
    }

    YSettingResetSettingsReset {
        id: id_reset_settings
    }

    YSettingResetFactoryReset {
        id: id_reset_factory
    }
}

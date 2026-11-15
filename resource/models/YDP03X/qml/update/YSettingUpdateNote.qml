import QtQuick 2.12
import com.youdao.pen 1.0

import BaseQml 1.0
import "../settingpages"
import "../i18n"

YBackgroundIgnoreMouseEvent {
    id: id_update_os_item
    objectName: "YSettingUpdateNote.qml"
    anchors.fill: parent

    property string tips:  updateManager.updateNote
//    "1. 更多应用，升级后可下载喜马拉雅少儿、网易云音乐等超多应用\n2. 更加流畅，词典笔“黑科技”，又快又稳定\n3. 全新界面，大大改善用户体验"

    signal nextStep()

    YVerticalTitleBarBase {
        objectName: "YVerticalTitleBar.qml"
        YBackButton {
            id: id_back_button
            onClicked: {
                id_setting_update_os_page.subPageCallBack()
            }
            objectName: "YVerticalTitleBar.qml_" + id_title_container.objectName
        }
    }

    Flickable {
        anchors.fill: parent
        anchors.leftMargin: 90
        anchors.rightMargin: 16
        contentHeight: id_update_content_col.height
        boundsBehavior: Flickable.StopAtBounds

        Column {
            id: id_update_content_col

            YSettingItemTitle {
                id: id_title_container
                title: YTranslateText.update
            }

            YTextMedium {
                id: id_update_title
                textFormat: YTextBase.RichText
                font.family: fontManager.fontFamilyZhCn
                text: YTranslateText.freeUpdateOS
            }

            YSpacingForColumn {
                implicitHeight: 20
            }

            YText {
                color: YColors.grayText
                font.pixelSize: 26
                font.family: fontManager.fontFamilyZhCn
                width: 650
                wrapMode: YTextBase.Wrap
                text: tips
                lineHeightMode: Text.FixedHeight
                lineHeight: 34
                verticalAlignment: YText.AlignVCenter
            }

            YSpacingForColumn {
                implicitHeight: 28
            }

            YButton {
                anchors.horizontalCenter: parent.horizontalCenter
                width: 300
                height: 80
                text: YTranslateText.nextStep
                onClicked: {
                    nextStep()
                }
            }

            YSpacingForColumn {
                implicitHeight: 28
            }
        }
    }
}


import QtQuick 2.12
import com.youdao.pen 1.0

import BaseQml 1.0
import "../settingpages"
import "../i18n"

YBackgroundIgnoreMouseEvent {
    id: id_update_os_item
    objectName: "YSettingUpdateNotice.qml"
    anchors.fill: parent

    signal nextStep()

    YVerticalTitleBarBase {
        objectName: "YVerticalTitleBar.qml"
        YBackButton {
            id: id_back_button
            onClicked: {
                id_setting_update_os_page.subPageCallBack()
            }
            objectName: "YVerticalTitleBar.qml_" + id_update_os_item.objectName
        }
    }

    Flickable {
        anchors.fill: parent
        anchors.leftMargin: 90
        anchors.rightMargin: 16
        contentHeight: id_update_notice_col.height
        boundsBehavior: Flickable.StopAtBounds

        Column {
            id: id_update_notice_col

            YSpacingForColumn {
                implicitHeight: 20
            }

            YImage {
                width: 694
                height: {
                    // 三代极速
                    if (qmlGlobal.checkFeature(YEnum.FEATURE_VERSION_X3))
                    {
                        return 305
                    }
                    // 三代其他：标准，x3s等三代笔
                    else
                    {
                        return 345
                    }
                }
                sourceSize: {
                    // 三代极速
                    if (qmlGlobal.checkFeature(YEnum.FEATURE_VERSION_X3))
                    {
                        return Qt.size(694, 305)
                    }
                    // 三代其他：标准，x3s等三代笔
                    else
                    {
                        return Qt.size(694, 345)
                    }
                }
                imageName: {
                    // 三代极速
                    if (qmlGlobal.checkFeature(YEnum.FEATURE_VERSION_X3))
                    {
                        return "update/update_notice_x3"
                    }
                    // 三代其他：标准，x3s等三代笔
                    else
                    {
                        return "update/update_notice"
                    }
                }
            }

            YSpacingForColumn {
                implicitHeight: 28
            }

            Row {
                width: parent.width
                height: 80
                spacing: 14

                YButton {
                    width: 340
                    height: parent.height
                    color: YColors.grayNormal
                    text: YTranslateText.refuseUpdate
                    onClicked: {
                        id_setting_update_os_page.subPageCallBack()
                        settingManager.updateOsRefused = true
                        qmlGlobal.sethidehomeItem(YEnum.PageIndex.UpdateOS, false);
                    }
                }

                YButton {
                    width: 340
                    height: parent.height
                    color: YColors.grayNormal
                    text: YTranslateText.agreeUpdate
                    onClicked: {
                        logManager.sendHttpLog("action=update_agree_click")
                        id_update_confirm_dialog.show()
                    }
                }
            }

            YSpacingForColumn {
                implicitHeight: 28
            }
        }

    }

    YTwoButtonDialog {
        id: id_update_confirm_dialog
        anchors.fill: parent

        tipItem.font.family: fontManager.fontFamilyZhCn
        buttonItemCancel.textFamily: fontManager.fontFamilyZhCn
        buttonItemConfirm.textFamily: fontManager.fontFamilyZhCn

        tipItem.text: YTranslateText.updateConfirm
        buttonItemConfirm.text: YTranslateText.startUpdate
        buttonItemCancel.text: YTranslateText.cancelUpdate
        buttonItemConfirm.color: YColors.grayNormal

        onClickedConfirm: {
            nextStep()
        }
        onClickedCancel: {
            id_update_confirm_dialog.close()
        }
    }
}


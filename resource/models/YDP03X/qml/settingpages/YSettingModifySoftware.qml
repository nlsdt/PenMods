import QtQuick 2.12
import com.youdao.pen 1.0
import "../components"
import BaseQml 1.0
import "../i18n"

YPage  {
    id: id_setting_item
    objectName: "YPage===YSettingOpenLicense.qml"

    property string tips:  "本设备软件系统使用了开源软件代码，您可以修改此部分开源软件代码，但不合适的修改可能会造成本设备无法正常工作，包括但不限于功能不完整、不能正常开机、软件不稳定等。请您在修改之前知晓并同意放弃以下权益:"
    property string noticestr: "<b> 1、同意放弃质保<br>  2、同意放弃售后支持 </b> <br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp"
    property string netstep:  "同意协议，进入<u>下一步</u>"
    property var popcurrentShowPage: null
    signal callback();

    YVerticalTitleBar {
        id: id_title_bar
        onCallBack: {
           // backButtonClicked();
            callback();
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
                title: YTranslateText.modifysoftware
            }
            YText {
                color: YColors.grayText
                font.pixelSize: 28
                font.family: fontManager.fontFamilyZhCn
                width: 694
                wrapMode: YTextBase.Wrap
                text: tips
                lineHeightMode: Text.FixedHeight
                lineHeight: 36
                verticalAlignment: YText.AlignVCenter
            }
            YText {
                color: YColors.grayText
                font.pixelSize: 28
                font.family: fontManager.fontFamilyZhCn
                width: 694
                wrapMode: YTextBase.Wrap
                textFormat: Text.RichText
                text: noticestr
                lineHeightMode: Text.FixedHeight
                lineHeight: 36
                verticalAlignment: YText.AlignVCenter
            }
            YText {
                color: YColors.red
                font.pixelSize: 28
                font.family: fontManager.fontFamilyZhCn
                width: 500
                wrapMode: YTextBase.Wrap
                textFormat: Text.RichText
                text:  netstep //同意协议 下一步
                lineHeightMode: Text.FixedHeight
                lineHeight: 36
                verticalAlignment: YText.AlignVCenter
                MouseArea
                {
                   anchors.fill: parent
                   onClicked:
                   {
                       if (!wifiManager.internetConnect) {
                           baseSignals.showToast(YTranslateText.networkAbnormalPleaseCheck, YColors.grayNormal)
                           return
                       }
                       settingSetupInformation.visible = true;
                   }
                }
            }

        }

    }
    YSettingSetupInformation
    {
        id:settingSetupInformation
        anchors.fill: parent
        visible :false;
        onCallback:
        {
            settingSetupInformation.visible = false;
        }
    }


}

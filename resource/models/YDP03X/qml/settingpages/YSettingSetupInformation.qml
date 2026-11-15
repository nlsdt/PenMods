import QtQuick 2.12
import com.youdao.pen 1.0
import "../components"
import BaseQml 1.0
import "../i18n"

YPage  {
    id: id_setting_ite
    signal callback();
    objectName: "YPage===YSettingOpenLicense.qml"

    property string tips:  "1 <Qt 5.15.2>
a.本机使用了Qt 5.15.2部分技术，操作信息为%1 ，cpu支持的指令集如下:\n
%2

b.使用方法：

1、存储空间预留200Mb，在连接无线网络的状态下，点击下方的启动按钮。\n
2、使用数据线，将设备与电脑连接，在我的电脑中找到DictPen，依次进入MTP文件夹、Qtlib文件夹。\n
3、传入自定义库到Qtlib文件夹中，传输完成后重启设备。\n\n"

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
        anchors.horizontalCenter: parent
        contentHeight: id_update_content_col.height
        boundsBehavior: Flickable.StopAtBounds
        Column {
            id: id_update_content_col

            YSettingItemTitle {
                id: id_title_container
                title: YTranslateText.setupInformation
            }
            YText {
                color: YColors.grayText
                font.pixelSize: 28
                font.family: fontManager.fontFamilyZhCn
                width: 694
                wrapMode: YTextBase.Wrap
                // textFormat: YText.RichText
                text: tips.arg(settingManager.linuxVersionNumber).arg(settingManager.cpuCommandText)
                //text:settingManager.linuxVersionNumber
                lineHeightMode: Text.FixedHeight
                lineHeight: 36
                verticalAlignment: YText.AlignVCenter

            }
            YButton {
                id: id_content_button
                width:300
                anchors.horizontalCenter: parent.horizontalCenter
                text: settingManager.isMtpOpened ? "已开启" : "启动"
                color: settingManager.isMtpOpened ? YColors.grayNormal : YColors.red
                clickable: !settingManager.isMtpOpened
                textColor: settingManager.isMtpOpened ? YColors.grayText : YColors.white
                onClicked: {
                    if (!wifiManager.internetConnect) {
                        baseSignals.showToast(YTranslateText.networkAbnormalPleaseCheck, YColors.grayNormal)
                        return
                    }
                    else
                    {
                        settingManager.getenableEditMode();
                    }

                }
            }

        }

    }

    onVisibleChanged: {
        if (visible) {
            settingManager.checkEditModeStatus();
        }
    }

    YBackground {
        id: id_back_mask
        visible:id_ch_dict_loading.visible
        anchors.fill: parent
    }

    YImage {
        id: id_ch_dict_loading
        anchors.centerIn: parent
        fillMode: YImage.PreserveAspectCrop
        imageName: "settings/loading"
        visible: settingManager.isMtpLoading
        RotationAnimator {
            id: id_ch_dict_animation
            target: id_ch_dict_loading
            from: 0
            to: 360
            duration: 1000
            running: false
            loops: Animation.Infinite
        }
        onVisibleChanged:{
            if (visible) {
                id_ch_dict_animation.start()
            } else {
                id_ch_dict_animation.stop()
            }
        }
    }
    
    Connections
    {
        target: settingManager
        ignoreUnknownSignals: true
        function onGetenableEditSesponse(issucess)
        {
            if(issucess)
            {
              //  baseSignals.showToast("启动成功", YColors.grayNormal)
                settingManager.openmtp();
            }
            else
            {
                baseSignals.showToast("启动失败,请检查网络稍后重试！", YColors.grayNormal)
            }
        }
    }
}

import QtQuick 2.12
import com.youdao.pen 1.0
import BaseQml 1.0
import "../components"
import "../i18n"

YSettingItemPage {
    id: id_setting_item
    objectName: "YPage===YSettingUploadCrase.qml.qml"
    // readonly property int updateSeconds: 8 * 60 + Math.floor(Math.random() * 120) //升级基准时长
    readonly property int updateSeconds: 1000*60 //升级基准时长

    Component.onCompleted:
    {
        id_reset_settings.show();

    }
    YOneButtonDialog {
        id: id_reset_settings
        anchors.fill: parent
        tipItem.textFormat: Text.RichText
        tipItem.text: YTranslateText.uploadcrashtips
        buttonItem.text: YTranslateText.uploadconfirm
        onClicked: {
            if(!wifiManager.link)
            {
                networkerror.show();
                return ;
            }
            uploadprocess.show();
            uploadcrash.startuploadcrash();

        }
        onClosed:
        {

            id_setting_item.backButtonClicked();
        }
    }

    YOneButtonDialog {
        id: uploadprocess
        buttonItem.visible : false
        anchors.fill: parent

        Column {
            anchors.left: parent.left
            anchors.right: parent.right
            spacing: 0


            YSpacingForColumn {
                implicitHeight: 65
            }

            YText {
                anchors.horizontalCenter: parent.horizontalCenter
                font.pixelSize: 28
                font.family: fontManager.fontFamilyZhCn
                lineHeightMode: Text.FixedHeight
                lineHeight: 37
                text: "%1%".arg(Math.floor((id_progress_foredground_rect.width / id_progress_background_rect.width) * 100))
            }

            YSpacingForColumn {
                implicitHeight: 10
            }

            Rectangle {
                id: id_progress_background_rect
                anchors.horizontalCenter: parent.horizontalCenter
                width: 400
                height: 10
                radius: height / 2
                color: YColors.grayNormal

                Rectangle {
                    id: id_progress_foredground_rect
                    width: parent.width
                    height: 10
                    radius: height / 2
                    color: YColors.white
                }
            }

            YSpacingForColumn {
                implicitHeight: 33
            }

            YText {
                id: id_update_doing_tip_text
                anchors.horizontalCenter: parent.horizontalCenter
                width: 520
                font.pixelSize: 28
                font.family: fontManager.fontFamilyZhCn
                lineHeightMode: Text.FixedHeight
                lineHeight: 34
                horizontalAlignment: YText.AlignHCenter
                verticalAlignment: YText.AlignVCenter
                wrapMode: YText.Wrap
                color: YColors.grayText
                text: YTranslateText.uploadprocess
            }
        }
        onClosed:
        {
             uploadcrash.stopuploadcrash();
            id_setting_item.backButtonClicked();
        }
    }

    YTimer {
        id: id_network_check_timer
        interval: 5000
        running: uploadprocess
        repeat: true
        onTriggered: {
            console.log("YSettingUploadCrase.qml===network", wifiManager.internetConnect)
            if (!wifiManager.internetConnect) {

              networkerror.show();
            }
        }

        objectName: "YSettingUploadCrase.qml_id_network_check_timer"
    }


    YOneButtonDialog {
        id:networkerror
        anchors.fill: parent
        tipItem.text: YTranslateText.uploadneterror
        buttonItem.text: YTranslateText.configWifi
        onClicked: {
            qmlGlobal.requestSettingPage(YEnum.SettingIndex.Network)
            closed()
        }
       onClosed:
       {
        id_setting_item.backButtonClicked();
       }
    }
    NumberAnimation {
        id: id_pep_update_animation
        target: id_progress_foredground_rect
        property: "width"
        duration: updateSeconds  //* 1000
        easing.type: Easing.InOutQuad
        from: 0
        to: id_progress_background_rect.width
        running: uploadprocess
        onFinished: {
            id_setting_item.backButtonClicked();
            baseSignals.showToast(YTranslateText.uploadsucess, YColors.grayNormal)
        }
    }

}

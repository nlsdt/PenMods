import QtQuick 2.12
import com.youdao.pen 1.0

import BaseQml 1.0
import "../i18n"

YLoader {
    anchors.fill: parent
    active: wifiManager.internetConnect
            && (((30 > batteryManager.power) && !batteryManager.charging)
                || (YEnum.UPDATE_ERROR_LOW_BATTERY === otaStatus))
    readonly property bool battaryChanging: batteryManager.charging

    sourceComponent: YDialog {
        anchors.fill: parent

        Item {
            anchors.centerIn: parent
            width: 600
            height: 110

            YText {
                id: id_tip_text
                font.pixelSize: 28
                font.family: fontManager.fontFamilyZhCn
                width: parent.width
                anchors.centerIn: parent
                horizontalAlignment: YText.AlignHCenter
                verticalAlignment: YText.AlignVCenter
                wrapMode: YText.Wrap
                textFormat: Text.RichText
                text: YTranslateText.lowPowerTip
            }
        }

        YIconButton {
            id: id_close_button
            implicitWidth: 44
            implicitHeight: 44
            radius: height/2
            color: YColors.grayNormal
            mouseAreaMargins: -22
            imageName: "commons/close"
            anchors.top: parent.top
            anchors.topMargin: 18
            anchors.left: parent.left
            anchors.leftMargin: 16
            enabled: !uploadDoing
            onClicked: {
                closeSettingUpdatePage()
                close()
            }
        }
    }
    onLoaded: {
        item.show()
    }
}

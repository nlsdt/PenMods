import QtQuick 2.12
import com.youdao.pen 1.0

import BaseQml 1.0
import "../i18n"

YOneButtonDialog {
    anchors.fill: parent
    YText {
        font.pixelSize: 30
        anchors.verticalCenter: parent.verticalCenter
        width: parent.width
        horizontalAlignment: YText.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        textFormat: Text.RichText
        text: YTranslateText.dictNavigationTip.arg(YColors.yellow)
    }
    buttonItem.visible : false
     YImage {
        id: navigationicons
        anchors.verticalCenter: parent.verticalCenter
        anchors.right: parent.right
        sourceSize: Qt.size(97, 61.5)
        imageName: "dict/navigationTip"
        visible: !id_qrcode_icon.visible
    }
    YImage {
        id: navigationicons2
         anchors.top: navigationicons.bottom
         anchors.right: parent.right
        sourceSize: Qt.size(49, 62)
        imageName: "dict/navigationTip-right"
        visible: !id_qrcode_icon.visible
    }
    onClosed:{
        settingManager.setNotIsFirstEnterDictPage();
    }

}

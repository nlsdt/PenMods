import QtQuick 2.12
import com.youdao.pen 1.0
import QtQuick.Shapes 1.14
import QtGraphicalEffects 1.14
import BaseQml 1.0
import "../i18n"
YPage {
    id: id_ai_sentence_analusis
    anchors.fill: parent
    YVerticalTitleBar {
        id: id_title_bar
        onCallBack: {
             backButtonClicked()
        }
    }

    YText {
        id: id_tip
        font.pixelSize: 28
        anchors.left: parent.left
        anchors.leftMargin: 100
        anchors.right: parent.right
        anchors.rightMargin: 100
        anchors.top: parent.top
        anchors.topMargin: 30
        height: 110
        horizontalAlignment: YText.AlignHCenter
        verticalAlignment: YText.AlignVCenter
        wrapMode: YText.Wrap
        text: "此功能需要联网使用，请联网"
    }

    YButton {
        id: id_button
        implicitWidth: 320
        anchors.top: id_tip.bottom
        anchors.topMargin: 10
        anchors.horizontalCenter: parent.horizontalCenter
        color: YColors.red
        text: "去联网"
        onClicked: {
            qmlGlobal.requestSettingPage(YEnum.SettingIndex.Network)
            backButtonClicked()
        }
    }
}


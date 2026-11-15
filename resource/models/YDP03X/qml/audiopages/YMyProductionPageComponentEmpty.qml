import QtQuick 2.12
import com.youdao.pen 1.0

import BaseQml 1.0
import "../components"
import "../i18n"

YItem {
    id: id_container_index

    YText {
        anchors.top: parent.top
        anchors.topMargin: 22
        anchors.left: parent.left
        anchors.leftMargin: 90
        anchors.right: parent.right
        anchors.rightMargin: 20
        wrapMode: YText.Wrap
        text: YTranslateText.myProductionAudiosTip
        font.family: fontManager.fontFamilyZhCn
        font.pixelSize: {
            switch (settingManager.uiLanguage) {
            case YEnum.EN_US:
                return 26
            }
            return 28
        }
    }

    YTextBase {
        anchors.left: parent.left
        anchors.leftMargin: 90
        anchors.right: parent.right
        anchors.rightMargin: 20
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 22
        font.family: fontManager.fontFamilyZhCn
        wrapMode: YTextBase.Wrap
        color: YColors.grayText
        font.pixelSize: 24
        text: YTranslateText.myProductionAudiosMethods.arg("https://ting.youdao.com")
    }
}

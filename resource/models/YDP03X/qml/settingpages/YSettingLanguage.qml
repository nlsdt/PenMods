import QtQuick 2.12
import com.youdao.pen 1.0

import BaseQml 1.0
import "../components"
import "../i18n"

YSettingItemPage {
    id: id_setting_item
    objectName: "YPage===YSettingLanguage.qml"

    readonly property string state_zh_cn: "简体中文"
    readonly property string state_zh_tw: "繁體中文"
    readonly property string state_en_us: "English"
    readonly property string state_ja_jp: "日本语"
    readonly property string state_ko_kr: "한국어"
    function getStateLangNameByType(langType) {
        switch (langType) {
        case YEnum.ZH_TW:
            return state_zh_tw
        case YEnum.JA_JP:
            return state_ja_jp
        case YEnum.KO_KR:
            return state_ko_kr
        case YEnum.EN_US:
            return state_en_us
        case YEnum.ZH_CN:
        default:
            return state_zh_cn
        }
    }

    Flickable {
        id: id_setting_item_view
        anchors.fill: parent
        anchors.leftMargin: 90
        anchors.rightMargin: 16
        contentHeight: 254 // change if add more for six languages

        YSettingItemTitle {
            id: id_title_container
            title: YTranslateText.languageSwitch
        }

        YPressedButton {
            id: id_chinese_button
            anchors.top: id_title_container.bottom
            implicitWidth: 341
            clickable: settingManager.uiLanguage !== YEnum.ZH_CN
            checkedIndicatorScale: settingManager.uiLanguage === YEnum.ZH_CN
            textItem.font.family: fontManager.fontFamilyZhCn
            text: state_zh_cn
            onClicked: {
                id_tip_dialog.language = YEnum.ZH_CN
                id_tip_dialog.show()
            }
        }

        YPressedButton {
            id: id_english_button
            implicitWidth: 341
            anchors.left: id_chinese_button.right
            anchors.leftMargin: 12
            anchors.verticalCenter: id_chinese_button.verticalCenter
            clickable: settingManager.uiLanguage !== YEnum.EN_US
            checkedIndicatorScale: settingManager.uiLanguage === YEnum.EN_US
            textItem.font.family: fontManager.fontFamilyEnUs
            text: state_en_us
            onClicked: {
                id_tip_dialog.language = YEnum.EN_US
                id_tip_dialog.show()
            }
        }
    }

    YOneButtonDialog {
        id: id_tip_dialog
        anchors.fill: parent

        property int language: YEnum.EN_US
        property var langName: getStateLangNameByType(language)
        property var fontFamilyName: qmlGlobal.getFontFamilyNameByLangType(language)
        property var languageText: '<span style="font-family:' + fontFamilyName + '">' + langName + '</span>'

        tipItem.textFormat: Text.RichText
        tipItem.text: YTranslateText.languageSwitchTip.arg(languageText).arg(YColors.red)
        buttonItem.text:  YTranslateText.languageSwitchButton.arg(languageText)
        onClicked: {
            qmlTranslator.loadLanguage(language)
            id_tip_dialog.close()
        }
    }
}

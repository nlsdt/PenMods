import QtQuick 2.12
import com.youdao.pen 1.0

import BaseQml 1.0
import "../components"
import "../i18n"

YSettingItemPage {
    id: id_setting_item
    objectName: "YPage===YSettingTranslate.qml"

    enum FeatureStatus {
        FS_NONE,
        FS_PRO,
        FS_KOKR,
        FS_ENUS
    }

    readonly property int currentFeatureStatus: {
        if (qmlGlobal.checkFeature(YEnum.FEATURE_SKU_KO)) {
            return YSettingTranslate.FeatureStatus.FS_KOKR
        } else if (qmlGlobal.checkFeature(YEnum.FEATURE_SKU_ES)) {
            return YSettingTranslate.FeatureStatus.FS_ENUS
        } else if (qmlGlobal.checkFeature(YEnum.FEATURE_VERSION_PRO)) {
            return YSettingTranslate.FeatureStatus.FS_PRO
        }
        return YSettingTranslate.FeatureStatus.FS_NONE
    }

    Item {
        id: id_setting_item_view
        anchors.fill: parent
        anchors.leftMargin: 90
        anchors.rightMargin: 16

        YSettingItemTitle {
            id: id_title_container
            title: YTranslateText.priorityTranslationLanguageChoice
        }

        Grid {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: id_title_container.bottom
            columns: 3
            spacing: 12

            // 国内专业版
            YPressedButton {
                implicitWidth: 223
                clickable: settingManager.transLanguage !== YEnum.EN_US
                checkedIndicatorScale: settingManager.transLanguage === YEnum.EN_US
                text: YTranslateText.english
                visible: currentFeatureStatus === YSettingTranslate.FeatureStatus.FS_PRO
                onClicked: {
                    settingManager.transLanguage = YEnum.EN_US
                }
            }

            YPressedButton {
                implicitWidth: 224
                clickable: settingManager.transLanguage !== YEnum.KO_KR
                checkedIndicatorScale: settingManager.transLanguage === YEnum.KO_KR
                text: YTranslateText.korean
                visible: currentFeatureStatus === YSettingTranslate.FeatureStatus.FS_PRO
                onClicked: {
                    settingManager.transLanguage = YEnum.KO_KR
                }
            }

            YPressedButton {
                implicitWidth: 223
                clickable: settingManager.transLanguage !== YEnum.JA_JP
                checkedIndicatorScale: settingManager.transLanguage === YEnum.JA_JP
                text: YTranslateText.japanese
                visible: currentFeatureStatus === YSettingTranslate.FeatureStatus.FS_PRO
                onClicked: {
                    settingManager.transLanguage = YEnum.JA_JP
                }
            }


            // 韩国版
            YPressedButton {
                implicitWidth: 223
                clickable: settingManager.transLanguage !== YEnum.EN_US
                checkedIndicatorScale: settingManager.transLanguage === YEnum.EN_US
                text: YTranslateText.english
                visible: currentFeatureStatus === YSettingTranslate.FeatureStatus.FS_KOKR
                onClicked: {
                    settingManager.transLanguage = YEnum.EN_US
                }
            }

            YPressedButton {
                implicitWidth: 224
                clickable: settingManager.transLanguage !== YEnum.ZH_CN
                checkedIndicatorScale: settingManager.transLanguage === YEnum.ZH_CN
                text: YTranslateText.chinese
                visible: currentFeatureStatus === YSettingTranslate.FeatureStatus.FS_KOKR
                onClicked: {
                    settingManager.transLanguage = YEnum.ZH_CN
                }
            }

            YPressedButton {
                implicitWidth: 223
                clickable: settingManager.transLanguage !== YEnum.JA_JP
                checkedIndicatorScale: settingManager.transLanguage === YEnum.JA_JP
                text: YTranslateText.japanese
                visible: currentFeatureStatus === YSettingTranslate.FeatureStatus.FS_KOKR
                onClicked: {
                    settingManager.transLanguage = YEnum.JA_JP
                }
            }

            // 北美众筹版
            YPressedButton {
                implicitWidth: 224
                clickable: settingManager.transLanguage !== YEnum.ZH_CN
                checkedIndicatorScale: settingManager.transLanguage === YEnum.ZH_CN
                text: YTranslateText.chinese
                visible: currentFeatureStatus === YSettingTranslate.FeatureStatus.FS_ENUS
                onClicked: {
                    settingManager.transLanguage = YEnum.ZH_CN
                }
            }

            YPressedButton {
                implicitWidth: 223
                clickable: settingManager.transLanguage !== YEnum.JA_JP
                checkedIndicatorScale: settingManager.transLanguage === YEnum.JA_JP
                text: YTranslateText.japanese
                visible: currentFeatureStatus === YSettingTranslate.FeatureStatus.FS_ENUS
                onClicked: {
                    settingManager.transLanguage = YEnum.JA_JP
                }
            }

            YPressedButton {
                implicitWidth: 224
                clickable: settingManager.transLanguage !== YEnum.KO_KR
                checkedIndicatorScale: settingManager.transLanguage === YEnum.KO_KR
                text: YTranslateText.korean
                visible: currentFeatureStatus === YSettingTranslate.FeatureStatus.FS_ENUS
                onClicked: {
                    settingManager.transLanguage = YEnum.KO_KR
                }
            }

            YPressedButton {
                implicitWidth: 224
                clickable: settingManager.transLanguage !== YEnum.ES_ES
                checkedIndicatorScale: settingManager.transLanguage === YEnum.ES_ES
                text: YTranslateText.spanish
                visible: currentFeatureStatus === YSettingTranslate.FeatureStatus.FS_ENUS
                pixelSize: 26
                onClicked: {
                    settingManager.transLanguage = YEnum.ES_ES
                }
            }
        }

    }
}

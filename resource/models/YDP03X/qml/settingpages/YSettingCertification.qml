import QtQuick 2.12
import com.youdao.pen 1.0

import BaseQml 1.0
import "../i18n"

YSettingItemPage {
    id: id_setting_item
    objectName: "YPage===YSettingCertification.qml"

    Item {
        id: id_setting_item_view
        anchors.fill: parent
        anchors.leftMargin: 90
        anchors.rightMargin: 16

        YSettingItemTitle {
            id: id_title_container
            title: YTranslateText.certification
        }

        YImage {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: id_title_container.bottom
            imageName:{
                if (qmlGlobal.checkFeature(YEnum.FEATURE_VERSION_X3))
                {
                    if(settingManager.devCompanyId() === 1)
                        return "settings/certificationX3new"
                    else
                        return "settings/certificationX3"

                }
                else if (qmlGlobal.checkFeature(YEnum.FEATURE_SERIAL_X3S))
                {     if(settingManager.devCompanyId() === 1)
                    {
                        return "settings/newcertificationX3S"
                    }
                    else
                    {
                        return "settings/certificationX3S"
                    }
                }
                else if (qmlGlobal.checkFeature(YEnum.FEATURE_SERIAL_P3))
                {
                    if(settingManager.devCompanyId() === 1)
                    {
                        return "settings/newcertificationP3"
                    }
                    else{
                        return "settings/certificationP3"
                    }
                }
                else if (qmlGlobal.checkFeature(YEnum.FEATURE_SKU_PEP))
                {
                    if(settingManager.devCompanyId() === 1)
                    {
                        return "settings/newcertificationPEP"
                    }
                    else{
                        return "settings/certificationPEP"
                    }
                }
                else
                {
                    if(settingManager.devCompanyId() === 1)
                    {
                        return "settings/certificationnew"
                    }
                    else
                    {
                        return "settings/certification"
                    }



                }


            }
        }
    }

    YClickedCountMouseArea {
        anchors.fill: parent
        anchors.topMargin: id_title_container.height
        onTriggered: {
            settingManager.openAdb()
        }
        objectName: "YSettingCertification.qml_id_open_adb_button"
    }
}

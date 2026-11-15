import QtQuick 2.12
import com.youdao.pen 1.0

import BaseQml 1.0
import "../components"
import "../i18n"

YSettingItemPage {
    id: id_setting_item
    objectName: "YPage===YSettingDict.qml"

    Flickable {
        id: id_setting_item_view_pep
        anchors.fill: parent
        anchors.leftMargin: 90
        anchors.rightMargin: 16
        contentHeight: parent.height
        visible: {
            return settingManager.isPepVersion
        }

        YText {
            id: id_label_en_pep
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.topMargin: 24
            font.pixelSize: 26
            color: YColors.grayText
            textFormat: YText.RichText
            text: YTranslateText.dictionaryFirstWhenScanEnglish
        }

        Flow {
            id: id_en_flow_pep
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: id_label_en_pep.bottom
            anchors.topMargin: 22
            spacing: 12

            Repeater {
                model: id_pep_model

                YPressedButton {
                    implicitWidth: 341
                    clickable: dictIndex !== settingManager.topShowDict
                    checkedIndicatorScale: dictIndex === settingManager.topShowDict
                    textFormat: Text.RichText
                    onClicked: {
                        settingManager.topShowDict = dictIndex
                    }
                    text: {
                        switch (dictIndex) {
                        case YEnum.DtSimple:
                            return YTranslateText.dtSimple
                        case YEnum.DtEnChKid:
                            return YTranslateText.dtEnChKid
                        case YEnum.DtSenior:
                            return qmlGlobal.skuRegion() === YEnum.SKU_PEP
                                    ? YTranslateText.dtYDSenior : YTranslateText.dtSenior
                        case YEnum.DtWebster:
                            return YTranslateText.dtWebsterSetting
                        case YEnum.DtOxford:
                            return YTranslateText.dtOxford
                        case YEnum.DtSSAT:
                            return YTranslateText.dtSSAT
                        case YEnum.DtSAT:
                            return YTranslateText.dtSAT
                        case YEnum.DtGRE:
                            return YTranslateText.dtGRE
                        case YEnum.DtTOEFL:
                            return YTranslateText.dtTOEFL
                        case YEnum.DtIELTS:
                            return YTranslateText.dtIELTS
                        case YEnum.DtPEPPrim:
                            return YTranslateText.dtPEPPrimDict
                        case YEnum.DtPinYin:
                            return YTranslateText.dtPinYinDict
                        default:
                            return ""
                        }
                    }
                    pixelSize: currentPixelSize

                    YImage {
                        id: id_dict_loading
                        anchors.right: parent.right
                        anchors.top: parent.top
                        anchors.topMargin: 24
                        imageName: "settings/loading"
                        visible: {
                            var show = settingManager.dictRemoedList.contains(srcName);
                            if (show) {
                                id_dict_animation.start()
                            } else {
                                id_dict_animation.stop()
                            }
                            return show;
                        }
                        RotationAnimator {
                            id: id_dict_animation
                            target: id_dict_loading
                            from: 0
                            to: 360
                            duration: 1000
                            running: false
                            loops: Animation.Infinite
                        }
                    }
                }
            }
        }
    }


    Flickable {
        id: id_setting_item_view
        anchors.fill: parent
        anchors.leftMargin: 90
        anchors.rightMargin: 16
        contentHeight: {
            var height = 80 + id_ch_flow.height + 36 + id_label_en.contentHeight
                       + 20 + id_en_flow.height + 30 + id_switch_state_button_rect.height + id_label_ch.height
            return height
        }


        visible: !settingManager.isPepVersion
        YSettingItemTitle {
            id: id_label
            title: YTranslateText.onlineSearchwordsTitle
        }

        YSettingSwitchItem {
            id: id_switch_state_button_rect
            implicitHeight: settingManager.uiLanguage === YEnum.ZH_CN ? 76 : 99
            anchors.top: id_label.bottom
            title: YTranslateText.onlineSearchwordsSwitchTitle
            switchOn: settingManager.onlineSearchWordsSwitch
            interval: 0
            onTimerTriggered: {
                settingManager.onlineSearchWordsSwitch = id_switch_state_button_rect.switchOn
                console.log("======chenfei:",settingManager.onlineSearchWordsSwitch)
            }
        }

        YSettingItemTitle {
            id: id_label_ch
            anchors.top: id_switch_state_button_rect.bottom
            title: YTranslateText.dictionaryFirstWhenScanChinese
        }

        Flow {
            id: id_ch_flow
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: id_label_ch.bottom
            spacing: 12

            Repeater {
                model: settingManager.uiLanguage === YEnum.ZH_CN ? id_ch_model : id_ch_model_en

                YPressedButton {
                    implicitWidth: 341
                    clickable: dictIndex !== settingManager.topShowChDict
                    checkedIndicatorScale: dictIndex === settingManager.topShowChDict
                    onClicked: {
                        settingManager.topShowChDict = dictIndex
                    }
                    text: {
                        switch (dictIndex) {
                        case YEnum.DtChEnglish:
                            return YTranslateText.dtChEnglish
//                        case YEnum.DtChEnKid:
//                            return YTranslateText.dtChEnKid
                        case YEnum.DtChChinese:
                            return YTranslateText.dtChChinese
                        case YEnum.DtChLarge:
                            return YTranslateText.dtChLarge
                        case YEnum.DtChAncientWord:
                            return YTranslateText.dtChAncientWord
                        case YEnum.DtChPoemDict:
                            return YTranslateText.dtChPoemDict
                        case YEnum.DtChIdiom:
                            return YTranslateText.dtChIdiom
//                       case YEnum.DtXinHua:
//                            return YTranslateText.dtChXinHua
//                        case YEnum.DtBusinessAnCh:
//                            return YTranslateText.dtBusinessAnCh
//                        case YEnum.DtBusIdiomCh:
//                            return YTranslateText.dtBusIdiomCh
                        case YEnum.DtOnline:
                            return YTranslateText.dtOnlineTitle
                        case YEnum.DtChToJap:
                            return YTranslateText.dtYoudaoChToJap
                        case YEnum.DtJapToCh:
                            return YTranslateText.dtYoudaoJapToCh
                        default:
                            return ""
                        }
                    }
                    pixelSize: currentPixelSize

                    YImage {
                        id: id_ch_dict_loading
                        anchors.right: parent.right
                        anchors.top: parent.top
                        anchors.topMargin: 24
                        imageName: "settings/loading"
                        visible: {
                            var show = settingManager.dictRemoedList.contains(srcName);
                            if (show) {
                                id_ch_dict_animation.start()
                            } else {
                                id_ch_dict_animation.stop()
                            }
                            return show;
                        }
                        RotationAnimator {
                            id: id_ch_dict_animation
                            target: id_ch_dict_loading
                            from: 0
                            to: 360
                            duration: 1000
                            running: false
                            loops: Animation.Infinite
                        }
                    }
                }
            }
        }

        YText {
            id: id_label_en
            anchors.left: parent.left
            anchors.top: id_ch_flow.bottom
            anchors.topMargin: 36
            font.pixelSize: 26
            color: YColors.grayText
            textFormat: YText.RichText
            text: YTranslateText.dictionaryFirstWhenScanEnglish
        }

        Flow {
            id: id_en_flow
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: id_label_en.bottom
            anchors.topMargin: 20
            spacing: 12

            Repeater {
                model: settingManager.uiLanguage === YEnum.ZH_CN ? id_en_model : id_en_model_en

                YPressedButton {
                    implicitWidth: 341
                    clickable: dictIndex !== settingManager.topShowDict
                    checkedIndicatorScale: dictIndex === settingManager.topShowDict
                    textFormat: Text.RichText
                    onClicked: {
                        settingManager.topShowDict = dictIndex
                    }
                    text: {
                        switch (dictIndex) {
                        case YEnum.DtSimple:
                            return YTranslateText.dtSimple
                        case YEnum.DtEnChKid:
                            return YTranslateText.dtEnChKid
                        case YEnum.DtSenior:
                            return qmlGlobal.skuRegion() === YEnum.SKU_PEP
                                    ? YTranslateText.dtYDSenior : YTranslateText.dtSenior
                        case YEnum.DtWebster:
                            return YTranslateText.dtWebsterSetting
                        case YEnum.DtOxford:
                            return YTranslateText.dtOxford
                        case YEnum.DtSSAT:
                            return YTranslateText.dtSSAT
                        case YEnum.DtSAT:
                            return YTranslateText.dtSAT
                        case YEnum.DtGRE:
                            return YTranslateText.dtGRE
                        case YEnum.DtTOEFL:
                            return YTranslateText.dtTOEFL
                        case YEnum.DtIELTS:
                            return YTranslateText.dtIELTS
                        case YEnum.DtPEPPrim:
                            return YTranslateText.dtPEPPrimDict
                        case YEnum.DtPinYin:
                            return YTranslateText.dtPinYinDict
                        case YEnum.DtCollinsPrimary:
                            return YTranslateText.dtCollinsPrimary
                        default:
                            return ""
                        }
                    }
                    pixelSize: currentPixelSize

                    YImage {
                        id: id_dict_loading
                        anchors.right: parent.right
                        anchors.top: parent.top
                        anchors.topMargin: 24
                        imageName: "settings/loading"
                        visible: {
                            var show = settingManager.dictRemoedList.contains(srcName);
                            if (show) {
                                id_dict_animation.start()
                            } else {
                                id_dict_animation.stop()
                            }
                            return show;
                        }
                        RotationAnimator {
                            id: id_dict_animation
                            target: id_dict_loading
                            from: 0
                            to: 360
                            duration: 1000
                            running: false
                            loops: Animation.Infinite
                        }
                    }
                }
            }
        }
    }

    ListModel {
        id: id_ch_model

        Component.onCompleted: {
            //新华词典
           //  append({"dictIndex": YEnum.DtXinHua, "currentPixelSize": 25, "srcName": "xinhuaV2.dat"})
            if (qmlGlobal.checkFeature(YEnum.FEATURE_DICT_ChENKID)) {
               // append({"dictIndex": YEnum.DtChEnKid, "currentPixelSize": 25, "srcName": "cekidV2.dat"})
            }
            if (qmlGlobal.checkFeature(YEnum.FEATURE_DICT_CHCHINESE)) {
                append({"dictIndex": YEnum.DtChChinese, "currentPixelSize": 25, "srcName": "charV2.dat"})
            }
            if (qmlGlobal.checkFeature(YEnum.FEATURE_DICT_CHLARGE)) {
                append({"dictIndex": YEnum.DtChLarge, "currentPixelSize": 23, "srcName": "ce-largeV2.dat"})
            }
            if (qmlGlobal.checkFeature(YEnum.FEATURE_ANCIENTPOEM)) {
                append({"dictIndex": YEnum.DtChAncientWord, "currentPixelSize": 25, "srcName": "ancientwordV2.dat"})
                append({"dictIndex": YEnum.DtChPoemDict, "currentPixelSize": 25, "srcName": "poem_dataV2.dat"})
            }
            append({"dictIndex": YEnum.DtChIdiom, "currentPixelSize": 25, "srcName": "idiomV2.dat"})
            //有道汉英释义
            append({"dictIndex": YEnum.DtChEnglish, "currentPixelSize": 25, "srcName": "ceV2.dat"})
            //append({"dictIndex": YEnum.DtBusinessAnCh, "currentPixelSize": 25, "srcName": "xinhuaV2.dat"})
            //append({"dictIndex": YEnum.DtBusIdiomCh, "currentPixelSize": 25, "srcName": "BusIdiomCh.dat"})
            if(qmlGlobal.checkFeature(YEnum.FEATURE_DICT_CHTOJAP))
                append({"dictIndex": YEnum.DtChToJap, "currentPixelSize": 25, "srcName": "chTojap.dat"})
            if(qmlGlobal.checkFeature(YEnum.FEATURE_DICT_JAPTOCH))
                append({"dictIndex": YEnum.DtJapToCh, "currentPixelSize": 25, "srcName": "japToch.dat"})
        }
    }

    ListModel {
        id: id_ch_model_en

        Component.onCompleted: {
            //新华词典
           // append({"dictIndex": YEnum.DtXinHua, "currentPixelSize": 25, "srcName": "xinhuaV2.dat"})
            if (qmlGlobal.checkFeature(YEnum.FEATURE_DICT_ChENKID)) {
               // append({"dictIndex": YEnum.DtChEnKid, "currentPixelSize": 23, "srcName": "cekidV2.dat"})
            }
            if (qmlGlobal.checkFeature(YEnum.FEATURE_DICT_CHCHINESE)) {
                append({"dictIndex": YEnum.DtChChinese, "currentPixelSize": 23, "srcName": "charV2.dat"})
            }
            if (qmlGlobal.checkFeature(YEnum.FEATURE_DICT_CHLARGE)) {
                append({"dictIndex": YEnum.DtChLarge, "currentPixelSize": 25, "srcName": "ce-largeV2.dat"})
            }
            if (qmlGlobal.checkFeature(YEnum.FEATURE_ANCIENTPOEM)) {
                append({"dictIndex": YEnum.DtChAncientWord, "currentPixelSize": 23, "srcName": "ancientwordV2.dat"})
                append({"dictIndex": YEnum.DtChPoemDict, "currentPixelSize": 23, "srcName": "poem_dataV2.dat"})
            }
            append({"dictIndex": YEnum.DtChIdiom, "currentPixelSize": 25, "srcName": "idiomV2.dat"})
            //有道汉英释义
            append({"dictIndex": YEnum.DtChEnglish, "currentPixelSize": 23, "srcName": "ceV2.dat"})
            //append({"dictIndex": YEnum.DtBusinessAnCh, "currentPixelSize": 22, "srcName": "xinhuaV2.dat"})
           // append({"dictIndex": YEnum.DtBusIdiomCh, "currentPixelSize": 24, "srcName": "BusIdiomCh.dat"})
            if(qmlGlobal.checkFeature(YEnum.FEATURE_DICT_CHTOJAP)){
                append({"dictIndex": YEnum.DtChToJap, "currentPixelSize": 25, "srcName": "chTojap.dat"})

            }
            if(qmlGlobal.checkFeature(YEnum.FEATURE_DICT_JAPTOCH)){
                append({"dictIndex": YEnum.DtJapToCh, "currentPixelSize": 25, "srcName": "japToch.dat"})
            }


        }
    }

    ListModel {
        id: id_en_model

        Component.onCompleted: {
            append({"dictIndex": YEnum.DtSimple, "currentPixelSize": 25, "srcName": "ecV2.dat"})
            append({"dictIndex": YEnum.DtEnChKid, "currentPixelSize": 25, "srcName": "eckidV2.dat"})
            if (qmlGlobal.checkFeature(YEnum.FEATURE_DICT_SENIOR)) {
                append({"dictIndex": YEnum.DtSenior, "currentPixelSize": 25, "srcName": "seniordictV2.dat"})
            }
            if (qmlGlobal.checkFeature(YEnum.FEATURE_WEBSTER)) {
                append({"dictIndex": YEnum.DtWebster, "currentPixelSize": 25, "srcName": "websterV2.dat"})
            }
            if (qmlGlobal.checkFeature(YEnum.FEATURE_OXFORD)) {
                append({"dictIndex": YEnum.DtOxford, "currentPixelSize": 23, "srcName": "oxfordV2.dat"})
            }

            append({"dictIndex": YEnum.DtCollinsPrimary, "currentPixelSize": 25, "srcName": "collins_primaryV2.dat"})

            if (qmlGlobal.checkFeature(YEnum.FEATURE_DICT_SSAT)) {
                append({"dictIndex": YEnum.DtSSAT, "currentPixelSize": 23, "srcName": "ssatV2.dat"})
            }
            if (qmlGlobal.checkFeature(YEnum.FEATURE_DICT_SAT)) {
                append({"dictIndex": YEnum.DtSAT, "currentPixelSize": 23, "srcName": "satV2.dat"})
            }
            if (qmlGlobal.checkFeature(YEnum.FEATURE_DICT_GRE)) {
                append({"dictIndex": YEnum.DtGRE, "currentPixelSize": 23, "srcName": "greV2.dat"})
            }

            if (qmlGlobal.checkFeature(YEnum.FEATURE_DICT_TOEFL)) {
                append({"dictIndex": YEnum.DtTOEFL, "currentPixelSize": 25, "srcName": "toeflV2.dat"})
            }
            if (qmlGlobal.checkFeature(YEnum.FEATURE_DICT_IELTS)) {
                append({"dictIndex": YEnum.DtIELTS, "currentPixelSize": 25, "srcName": "ieltsV2.dat"})
            }
            if (qmlGlobal.checkFeature(YEnum.FEATURE_SKU_PEP)) {
                append({"dictIndex": YEnum.DtPEPPrim, "currentPixelSize": 18, "srcName": "PEPPrimV2.dat"})
            }
            append({"dictIndex": YEnum.DtPinYin, "currentPixelSize": 25, "srcName": "pinyinV2.dat"})
        }
    }

    ListModel {
        id: id_en_model_en

        Component.onCompleted: {
            append({"dictIndex": YEnum.DtSimple, "currentPixelSize": 23, "srcName": "ecV2.dat"})
            append({"dictIndex": YEnum.DtEnChKid, "currentPixelSize": 23, "srcName": "eckidV2.dat"})
            if (qmlGlobal.checkFeature(YEnum.FEATURE_DICT_SENIOR)) {
                append({"dictIndex": YEnum.DtSenior, "currentPixelSize": 25, "srcName": "seniordictV2.dat"})
            }
            if (qmlGlobal.checkFeature(YEnum.FEATURE_WEBSTER)) {
                append({"dictIndex": YEnum.DtWebster, "currentPixelSize": 23, "srcName": "websterV2.dat"})
            }
            if (qmlGlobal.checkFeature(YEnum.FEATURE_OXFORD)) {
                append({"dictIndex": YEnum.DtOxford, "currentPixelSize": 25, "srcName": "oxfordV2.dat"})
            }
            append({"dictIndex": YEnum.DtCollinsPrimary, "currentPixelSize": 25, "srcName": "collins_primaryV2.dat"})
            if (qmlGlobal.checkFeature(YEnum.FEATURE_DICT_SSAT)) {
                append({"dictIndex": YEnum.DtSSAT, "currentPixelSize": 25, "srcName": "ssatV2.dat"})
            }
            if (qmlGlobal.checkFeature(YEnum.FEATURE_DICT_SAT)) {
                append({"dictIndex": YEnum.DtSAT, "currentPixelSize": 25, "srcName": "satV2.dat"})
            }
            if (qmlGlobal.checkFeature(YEnum.FEATURE_DICT_GRE)) {
                append({"dictIndex": YEnum.DtGRE, "currentPixelSize": 25, "srcName": "greV2.dat"})
            }

            if (qmlGlobal.checkFeature(YEnum.FEATURE_DICT_TOEFL)) {
                append({"dictIndex": YEnum.DtTOEFL, "currentPixelSize": 25, "srcName": "toeflV2.dat"})
            }
            if (qmlGlobal.checkFeature(YEnum.FEATURE_DICT_IELTS)) {
                append({"dictIndex": YEnum.DtIELTS, "currentPixelSize": 25, "srcName": "ieltsV2.dat"})
            }
            if (qmlGlobal.checkFeature(YEnum.FEATURE_SKU_PEP)) {
                append({"dictIndex": YEnum.DtPEPPrim, "currentPixelSize": 18, "srcName": "PEPPrimV2.dat"})
            }
            append({"dictIndex": YEnum.DtPinYin, "currentPixelSize": 25, "srcName": "pinyinV2.dat"})
        }
    }

    ListModel {
        id: id_pep_model

        Component.onCompleted: {
            append({"dictIndex": YEnum.DtPEPPrim, "currentPixelSize": 18, "srcName": "PEPPrimV2.dat"})
        }
    }
}



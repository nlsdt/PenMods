import QtQuick 2.12
import com.youdao.pen 1.0
import BaseQml 1.0
import "../i18n"

YLoader {
    id: id_phonetic_symbol_loader
    active: (resultManager.currentQueryType === YEnum.WGT_En_Group || resultManager.currentQueryType === YEnum.WGT_En) && 0 === qmlGlobal.scanOldType
            && systemBase.isButtonRelease
    visible: active
    sourceComponent: id_multiphone_component
    asynchronous: true

    Component {
        id: id_multiphone_component
        YMultiPhoneButton{
            id: id_multiphone_button
            //anchors.left: parent.left
            //anchors.right: parent.right
            visible:  resultManager.currentQueryType === YEnum.WGT_En_Group || resultManager.currentQueryType === YEnum.WGT_En
            //property alias flowHeight: id_dict_listview.childrenRect.height
            Connections {
                target: resultManager
                ignoreUnknownSignals: true
                function onCurrentQueryChanged() {
                    id_multiphone_button.textContent = YTranslateText.pronunciation
                    id_multiphone_button.textStyle = '<span style="font-family: %1; font-weight: 500">%2</span>'
                    id_multiphone_button.isWrap = false
                    id_multiphone_button.isUk = 0
                    //Qt.callLater(resultManager.queryEnPolyPhone,resultManager.currentQuery)
                }
            }

            Connections {
                target: settingManager
                ignoreUnknownSignals: true
                function onAutoPronounceTypeChanged() {
                    if(isUk !== 0) {
                        isUk = settingManager.autoPronounceType === YEnum.UK ? 1 : 2
                    }
                }
            }

            function getPhoneticText () {
                let jsonObjTmp = null
                try {
                    jsonObjTmp = JSON.parse(resultManager.phoneticSymbolJson)
                } catch(e) { }

                //人教使用人教的发音
                if (settingManager.isPepVersion && resultManager.phoneticSymbolJson.length > 0) {
                    isUk = 0
                    textContent = resultManager.phoneticSymbolJson.replace(/\//g, "")
                    textStyle = '<span style="font-family: %1; font-weight: 500">%2</span>'
                }
                else {
                    if(jsonObjTmp !== null && resultManager.currentQueryType === YEnum.WGT_En) {
                        if(settingManager.autoPronounceType === YEnum.UK) {
                            if (typeof jsonObjTmp.uk !== "undefined"  && jsonObjTmp.uk.length > 0) {
                                textContent = jsonObjTmp.uk
                                isUk = 1
                                textStyle = '<span style="font-family: %1; font-weight: 500">%2</span>'
                            } else if (typeof jsonObjTmp.us !== "undefined"  && jsonObjTmp.us.length > 0) {
                                textContent = jsonObjTmp.us
                                isUk = 2
                                textStyle = '<span style="font-family: %1; font-weight: 500">%2</span>'
                            }

                        } else {
                            if (typeof jsonObjTmp.us !== "undefined"  && jsonObjTmp.us.length > 0) {
                                textContent = jsonObjTmp.us
                                isUk = 2
                                textStyle = '<span style="font-family: %1; font-weight: 500">%2</span>'
                            } else if (typeof jsonObjTmp.uk !== "undefined"  && jsonObjTmp.uk.length > 0) {
                                textContent = jsonObjTmp.uk
                                isUk = 1
                                textStyle = '<span style="font-family: %1; font-weight: 500">%2</span>'
                            }
                        }
                    }
                    if(resultManager.currentQueryType === YEnum.WGT_En_Group) {
                        textContent = YTranslateText.pronunciation
                        textStyle = '<span style="font-family: %1; font-weight: 500">%2</span>'
                    }
                }
            }

            property var phoneticJson: resultManager.phoneticSymbolJson

            onPhoneticJsonChanged: {
                isUk = 0
                Qt.callLater(getPhoneticText)
            }

            onMultiPhoneButtonClick: {
                logManager.sendHttpLog("action=detail_multiphonetic_click")
                //resultManager.queryEnPolyPhone(resultManager.currentQuery)
                //if (resultManager.enPolyPhone.length > 0) {
                    qmlGlobal.showDictDetailPage("", "", YTranslateText.polyPhone)
                // } else {
                //     baseSignals.showToast(YTranslateText.noMuiltiPhone, YColors.grayNormal)
                // }
            }

            onPhoneticClick: {
                if (settingManager.isPepVersion) {
                    if (soundCenter.hasPepSound(resultManager.currentQuery)) {
                        qmlGlobal.soundWGTPep(resultManager.currentQuery)
                    }
                    return
                }
                if (settingManager.autoPronounceType === YEnum.UK) {
                    qmlGlobal.soundWGTEn(resultManager.currentQuery,YEnum.UK)
                } else {
                    qmlGlobal.soundWGTEn(resultManager.currentQuery, YEnum.US)
                }
            }
        }

    }
}

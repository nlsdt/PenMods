import QtQuick 2.12
import com.youdao.pen 1.0

import BaseQml 1.0
import "../i18n"

YDrawerLayer {
    id: id_drawer_layer
    indicatorLeftMargin: 16
    indicatorRightMargin: 50
    drawerContainerRightMargin: 30
    containerWidth: id_flickable.width

    property int currentIndex: settingManager.wbLanguageFilter
    signal filterChanged(int langType)

    property bool currentFilterWordsList: true

    Flickable {
        id: id_flickable
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        width: 558
        contentHeight: id_column.height

        Column {
            id: id_column
            anchors.left: parent.left
            anchors.right: parent.right

            YSpacingForColumn {
                implicitHeight: 24
            }



            YTextBase {
                id: id_title
                color: YColors.grayText
                font.pixelSize: 26
                anchors.left: parent.left
                text: YTranslateText.switchLanguage
                visible: currentFilterWordsList
            }

            YSpacingForColumn {
                implicitHeight: 16
                visible: currentFilterWordsList
            }

            Grid {
                anchors.left: parent.left
                anchors.right: parent.right
                visible: currentFilterWordsList
                columns: {
                    switch(settingManager.uiLanguage){
                        // todo other language
                    case YEnum.ZH_CN:
                    default:
                        return 3
                    }
                }
                spacing: 12
                Repeater {
                    model: id_filter_model
                    YButton {
                        implicitWidth: {
                            switch(settingManager.uiLanguage){
                                // todo other language
                            case YEnum.ZH_CN:
                            default:
                                return 178
                            }
                        }
                        color: langType === currentIndex ? YColors.red : "#2D2E33"
                        mouseAreaMargins: -4
                        text: {
                            switch (langType) {
                            case YEnum.ZH_CN:
                                return YTranslateText.chinese
                            case YEnum.EN_US:
                                return YTranslateText.english
                            case YEnum.JA_JP:
                                return YTranslateText.japanese
                            case YEnum.KO_KR:
                                return YTranslateText.korean
                            case YEnum.LT_NUM:
                            default:
                                return YTranslateText.all
                            }
                        }

                        onClicked: {
                            if (currentIndex !== langType) {
                                currentIndex = langType
                                filterChanged(currentIndex)
                                hide()
                            }
                        }
                    }
                }
            }

            YSpacingForColumn {
                implicitHeight: 32
                visible: currentFilterWordsList
            }

            YTextBase {
                id: id_setting
                color: YColors.grayText
                font.pixelSize: 26
                anchors.left: parent.left
                text: YTranslateText.playSettings
                visible: !currentFilterWordsList
            }

            YSpacingForColumn {
                implicitHeight: 13
                visible: !currentFilterWordsList
            }

            YSettingSwitchItem {
                color: "#2D2E33"
                switchItem.offColor: "#515259"
                title: YTranslateText.autoReadAloud
                switchOn: settingManager.isWbAutoPronounce
                interval: 0
                onTimerTriggered: {
                    settingManager.isWbAutoPronounce = switchOn
                }
                visible: !currentFilterWordsList && !settingManager.isPepVersion
            }

            YSpacingForColumn {
                implicitHeight: 13
                visible: !currentFilterWordsList
            }

            YSettingSwitchItem {
                color: "#2D2E33"
                switchItem.offColor: "#515259"
                title: YTranslateText.autoPlay
                switchOn: settingManager.isWbAutoPlay
                interval: 0
                onTimerTriggered: {
                    settingManager.isWbAutoPlay = switchOn
                }
                visible: !currentFilterWordsList
            }

            YTextBase {
                id: id_autoAddWb
                color: YColors.grayText
                font.pixelSize: 26
                anchors.left: parent.left
                text: YTranslateText.addWbSetting
                visible: currentFilterWordsList
            }

            YSpacingForColumn {
                implicitHeight: 16
                visible: currentFilterWordsList
            }

            YSettingSwitchItem {
                color: "#2D2E33"
                switchItem.offColor: "#515259"
                title: YTranslateText.autoCollectAfterScan
                switchOn: settingManager.isAutoAddWb
                interval: 0
                onTimerTriggered: {
                    settingManager.isAutoAddWb = switchOn
                    if (switchOn){
                        logManager.sendHttpLog("action=wordbook_scan_on_click")
                    } else {
                        logManager.sendHttpLog("action=wordbook_scan_off_click")
                    }
                }
                visible: currentFilterWordsList
            }

            YSpacingForColumn {
                implicitHeight: 32
                visible: currentFilterWordsList
            }

            YTextBase {
                id: id_sync
                color: YColors.grayText
                font.pixelSize: 26
                anchors.left: parent.left
                text: YTranslateText.wordbookSyncTime
                visible: currentFilterWordsList
            }

            YSpacingForColumn {
                implicitHeight: 16
                visible: currentFilterWordsList
            }

            YSettingItemBackground {
                enabled: YEnum.SYS_SYNCING !== wordBookManager.syncState
                color: "#2D2E33"
                opacity: id_sync_button.pressed || !enabled ? 0.6 : 1
                visible: currentFilterWordsList
                YTextMedium {
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.leftMargin: 20
                    font.family: wordBookManager.lastSyncTime <= 0 ?
                                     fontManager.fontFamily : fontManager.fontFamilyEnUs
                    text: {
                        console.log("YWordBookFilterDrawerLayer.qml====wordBookManager.lastSyncTime: ",
                                    wordBookManager.lastSyncTime)
                        if (wordBookManager.lastSyncTime <= 0) {
                            return YTranslateText.clickToSync
                        }
                        return Qt.formatDateTime(new Date(wordBookManager.lastSyncTime),
                                                 "yyyy.MM.dd   hh:mm")
                    }
                }

                YImage {
                    anchors.right: parent.right
                    anchors.rightMargin: 26
                    anchors.verticalCenter: parent.verticalCenter
                    sourceSize: Qt.size(36, 36)
                    imageName: {
                        switch(wordBookManager.syncState) {
                        case YEnum.SYS_SYNCED:
                            return "wordbook/wb-synced"
                        case YEnum.SYS_SYNCING:
                            return "wordbook/wb-syncing"
                        case YEnum.SYS_UNSYNCED:
                        default:
                            return "wordbook/wb-unsync"
                        }
                    }
                }

                YMouseArea {
                    id: id_sync_button
                    anchors.fill: parent
                    onClicked : {
                        if (wifiManager.isOnline()) {
                            if (loginManager.isLogin) {
                                logManager.sendHttpLog("action=wordbook_refresh_click")
                                wordBookManager.startSync()
                            } else {
                                baseSignals.showToast(YTranslateText.accountHasUnbundling, YColors.grayNormal)
                            }
                        } else {
                            baseSignals.showToast(YTranslateText.networkAbnormalPleaseCheck, YColors.grayNormal)
                        }
                    }
                    objectName: "YWordBookFilterDrawerLayer.qml_YMouseArea"
                }
            }

            Connections
            {
                target: wordBookManager
                ignoreUnknownSignals: true
                enabled: id_drawer_layer.visible

                function onSyncStateChanged(m_handcliked) {
                   if(wordBookManager.syncState === YEnum.SYS_SYNCED && m_handcliked === 0)
                   {
                        baseSignals.showToast(YTranslateText.synchronizedsuccessfully, YColors.grayNormal)
                   }
                }
            }
            YSpacingForColumn {
                implicitHeight: 30
            }

            YSettingItemBackground {
                enabled: YEnum.SYS_SYNCING !== wordBookManager.syncState
                color: "#2D2E33"
                opacity: id_syncall_button.pressed || !enabled ? 0.6 : 1
                visible: currentFilterWordsList
                YTextMedium {
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.leftMargin: 20
                    font.family: qmlGlobal.fontFamily
                    color: YColors.blueText
                    text: YTranslateText.uploadAllItemsWordBook
                }

                YMouseArea {
                    id: id_syncall_button
                    anchors.fill: parent
                    onClicked : {
                        if (wifiManager.isOnline()) {
                            if (loginManager.isLogin) {
                                wordBookManager.syncAllItems()
                            } else {
                                baseSignals.showToast(YTranslateText.accountHasUnbundling, YColors.grayNormal)
                            }
                        } else {
                            baseSignals.showToast(YTranslateText.networkAbnormalPleaseCheck, YColors.grayNormal)
                        }
                    }
                }
            }

            YSpacingForColumn {
                implicitHeight: 30
            }
        }
    }

    ListModel {
        id: id_filter_model

        Component.onCompleted: {
            append({langType: YEnum.LT_NUM})
            append({langType: YEnum.ZH_CN})
            append({langType: YEnum.EN_US})
            if (qmlGlobal.checkFeature(YEnum.FEATURE_KOJN)) {
                append({langType: YEnum.JA_JP})
                append({langType: YEnum.KO_KR})
            }
        }
    }
}


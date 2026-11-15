import QtQuick 2.12
import com.youdao.pen 1.0

import BaseQml 1.0
import "../components"
import "../i18n"

YBackgroundIgnoreMouseEvent {
    id: id_youdao_audio_page_column_view_root
    visible: false
    state: "close"

    function show() {
        state = "show"
        visible = true
    }

    function close() {
        state = "close"
        visible = false
        id_youdao_audio_page_column_view.model = null
        mediaManager.wipeData()
        id_youdao_audio_page_column_view_root.closed()
    }

    signal closed()

    property string columnTitle: ""
    property alias model: id_youdao_audio_page_column_view.model

    property int currentDownloadState: YEnum.DS_ALL

    readonly property bool isDownloadManagerView: YEnum.DS_ALL !== currentDownloadState

    readonly property alias count: id_youdao_audio_page_column_view.count

    function playAudio(modelDataColumnId, modelDataId) {
        if (columnManager.columnIsScanning(modelDataColumnId).length > 0) {
            logManager.sendHttpLog("action=listening_make_broadcasting_view")
        }
        mediaManager.clickMedia(modelDataId)
        baseSignals.showAudioPlayer()
        if (YEnum.PLAYING !== mediaPlayerManager.playState) {
            mediaPlayerManager.onClickedPlay()
        }
        qmlGlobal.audioPlayingColomnId = modelDataColumnId
    }

    function downloadAudio(modelDataId) {
        logManager.sendHttpLog("action=listening_download_click")
        if (wifiManager.internetConnect) {
            if(usedStorage() >= parseInt(settingManager.memoryStorage))
                baseSignals.showToast(YTranslateText.lowStorageSimTip, "#2D2E33")
            else
                mediaManager.download(modelDataId)

        } else {
            baseSignals.showToast(YTranslateText.networkAbnormalPleaseCheck, YColors.grayNormal)
        }
    }

    readonly property real spaceUnit: 1024.0
    function usedStorage() {
        let fSystemSize = settingManager.storageFirmware / spaceUnit
        let fOtherSize = (settingManager.storageUser + settingManager.storageResource) / spaceUnit
        return (fSystemSize + fOtherSize).toFixed(2)
    }

    YBaseListView {
        id: id_youdao_audio_page_column_view
        anchors.fill: parent
        onMovingChanged: {
            if (!moving && atYEnd && mediaManager.hasMore) {
                mediaManager.loadMore(currentDownloadState)
            }
        } // todo 细化 loadMore 逻辑

        header: id_header_component

        Component {
            id: id_header_component
            Item {
                width: id_youdao_audio_page_column_view.width
                implicitHeight: 80

                YTextBase {
                    color: YColors.grayText
                    font.pixelSize: 26
                    font.family: fontManager.fontFamilyZhCn
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.right: id_download_manager_label.visible ? id_download_manager_label.left : parent.right
                    anchors.rightMargin: id_download_manager_label.visible ? 30 : 20
                    elide: YTextBase.ElideRight
                    text: columnTitle
                }

                YTextBase {
                    id: id_download_manager_label
                    color: YColors.blueText
                    font.pixelSize: 24
                    anchors.verticalCenter: parent.verticalCenter
                    text: id_downloading_count_bg.visible ?
                              YTranslateText.downloading : YTranslateText.downloadAll
                    anchors.right: id_downloading_count_bg.visible ? id_downloading_count_bg.left : parent.right
                    anchors.rightMargin: 6
                    width: paintedWidth
                    height: paintedHeight
                    //enabled: wifiManager.internetConnect
                    visible: !isDownloadManagerView && columnManager.currentOpenColumnIsAuthorized
                    opacity: id_download_manager_button.pressed ? 0.6 : 1
                }

                Rectangle {
                    id: id_downloading_count_bg
                    width: Math.max(id_downloading_count.width + 12, 36)
                    visible: id_download_manager_label.visible && (mediaManager.downloadingCount > 0)
                    implicitHeight: 26
                    radius: 14
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.right: parent.right
                    gradient: Gradient {
                        GradientStop { position: 0.0; color: "#4DA0FF" }
                        GradientStop { position: 1.0; color: "#457AE5" }
                    }
                    opacity: id_download_manager_label.opacity
                    YTextBase {
                        id: id_downloading_count
                        font.family: fontManager.fontFamilyEnUs
                        color: "#FFFFFF"
                        font.pixelSize: 20
                        anchors.centerIn: parent
                        text: mediaManager.downloadingCount
                        width: paintedWidth
                    }
                }

                YMouseArea {
                    id: id_download_manager_button
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    anchors.left: id_download_manager_label.left
                    anchors.leftMargin: -30
                    anchors.right: parent.right
                    anchors.rightMargin: -16
                    visible: id_download_manager_label.visible
                    //enabled: id_download_manager_label.enabled
                    onClicked: {
                        if (wifiManager.internetConnect){
                            if(usedStorage() >= parseInt(settingManager.memoryStorage))
                                baseSignals.showToast(YTranslateText.lowStorageSimTip, "#2D2E33")
                            else
                                mediaManager.downloadAll()
                        }
                        else
                            baseSignals.showToast(YTranslateText.networkAbnormalPleaseCheck, YColors.grayNormal)
                    }
                    objectName: "YMouseArea_id_download_manager_button"
                }
            }
        }

        delegate: Item {
            width: id_youdao_audio_page_column_view.width
            implicitHeight: 86
            YYoudaoAudioPageColumnViewItem {
                implicitHeight: 76
                title: (index + 1) + ". " + model.modelData.title
                titleFontFamily: fontManager.fontFamilyZhCn
                value: model.modelData.mmssString
                isDownloadManagerView: id_youdao_audio_page_column_view_root.isDownloadManagerView

                onClicked: {
                    if (isDownloadManagerView) {
                        if (editing) {
                            mediaManager.removeMedia(model.modelData.id)
                            id_check_editing_after_remove_timer.restart()
                        } else {
                           playAudio(model.modelData.columnId, model.modelData.id)
                        }
                    } else {
                        switch (downloadState) {
                        case YEnum.DS_SUCCEED:
                            playAudio(model.modelData.columnId, model.modelData.id)
                            break
                        case YEnum.DS_NOT:
                        case YEnum.DS_FAILURE:
                            if (!wifiManager.internetConnect) {
                                baseSignals.showToast(YTranslateText.networkAbnormalPleaseCheck, YColors.grayNormal)
                            }
                            if (!columnManager.currentOpenColumnIsAuthorized) {
                                id_authorized_tip_drawer_layer.callbackFunction = downloadAudio
                                if (settingManager.isAuthorizedTipShow()) {
                                    id_authorized_tip_drawer_layer.show()
                                } else {
                                    downloadAudio(model.modelData.id)
                                }
                            } else {
                                downloadAudio(model.modelData.id)
                            }
                            break
                        case YEnum.DS_ING:
                        default:
                            break
                        }
                    }
                }

                onDownloadStateChanged: {
                    if ((YEnum.DS_SUCCEED === downloadState)
                            && (null !== id_authorized_tip_drawer_layer.callbackFunction)) {
                        playAudio(model.modelData.columnId, model.modelData.id)
                        id_authorized_tip_drawer_layer.callbackFunction = null
                    }
                }
            }
        }

        footer: (mediaManager.itemCount > 0 && mediaManager.hasMore)
                ? id_listview_loading_footer : id_listview_loaded_footer

        Component {
            id: id_listview_loading_footer

            YListViewLoadMoreFooter {}
        }

        Component {
            id: id_listview_loaded_footer

            YSpacing {
                width: id_youdao_audio_page_column_view.width
                implicitHeight: 12
            }
        }

        onBusyingChanged: {
            if (!busying) {
                positionViewAtBeginning()
            }
        }

        YItem {
            id: id_result_empty_tip_container
            width: id_youdao_audio_page_column_view.width
            height: id_youdao_audio_page_column_view.height
            visible: !id_youdao_audio_page_column_view.busying
                     && id_youdao_audio_page_column_view.empty
            YTextMedium {
                id: id_result_empty_tip
                font.pixelSize: 28
                textFormat: YTextMedium.RichText
                text: YTranslateText.downloadYdListeninTip.arg(YColors.blueText)
                anchors.centerIn: parent
                width: paintedWidth
                height: paintedHeight

                YMouseArea {
                    anchors.fill: parent
                    anchors.margins: -10
                    onClicked: {
                        const currentColumnId = mediaManager.currentColumnId
                        mediaManager.wipeData()
                        columnManager.wipeData()
                        columnManager.loadMore(false, columnManager.domainNameYdListen)
                        lastIsDownloadManagerView = id_youdao_audio_page_component_root.isDownloadManagerView
                        id_youdao_audio_page_component_root.isDownloadManagerView = false
                        mediaManager.entryColumn(currentColumnId, false)
                        currentDownloadState = YEnum.DS_ALL
                    }
                    objectName: "YYoudaoAudioPageColumnView.qml_id_result_empty_tip"
                }
            }
        }
    }

    YTimer {
        id: id_check_editing_after_remove_timer
        interval: 600
        onTriggered: {
            if (id_result_empty_tip_container.visible) {
                editing = false
            }
        }
        objectName: "YYoudaoAudioPageColumnView.qml_id_check_editing_after_remove_timer"
    }

    Component.onCompleted: {
             settingManager.updateStorageInfo()
    }
}


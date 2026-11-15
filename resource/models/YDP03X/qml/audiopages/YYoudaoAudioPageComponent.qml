import QtQuick 2.12
import com.youdao.pen 1.0
import QtGraphicalEffects 1.14

import BaseQml 1.0
import "../components"
import "../i18n"

YBackButtonAudioPage {
    id: id_youdao_audio_page_component_root
    defaultTitleBar.visible: false

    property int checkedIndex: -1

    property bool isDownloadManagerView: false
    property bool editing: false
    property var lastIsDownloadManagerView: undefined

    function loadColumnData() {
        let domains = [columnManager.domainNameYdListen]
        if (isDownloadManagerView) {
            domains.push(columnManager.domainNameMyProduction)
        }
        columnManager.loadMore(isDownloadManagerView, domains.join(","))
    }

    onEnabledChanged: {
        console.log("ZDS===YYoudaoAudioPageComponent.qml===mediaManager.allDownloadingCount:", mediaManager.allDownloadingCount)
    }

    YYoudaoAudioPageColumnView {
        id: id_youdao_audio_page_column_view
        anchors.fill: parent
        anchors.leftMargin: 90
        anchors.rightMargin: 16
        columnTitle: id_title_bar_holder.columnTitle
    }

    Item {
        id: id_youdao_audio_page_view_container
        anchors.fill: parent
        anchors.leftMargin: 90
        anchors.rightMargin: 16

        YHorizontalListView {
            id: id_youdao_audio_page_view
            anchors.fill: parent
            anchors.topMargin: 16
            anchors.bottomMargin: 16
            model: columnManager
            clip: false
            interactive: -1 === checkedIndex
            opacity: (checkedIndex !== -1) ? 0 : 1
            visible: opacity > 0.1
            onMovingChanged: {
                if (!moving && atXEnd && columnManager.hasMore) {
                    loadColumnData()
                }
            } // todo 细化 loadMore 逻辑

            delegate: YHorizontalListViewDelegate {
                id: id_delegate_item
                implicitWidth: 212
                height: id_youdao_audio_page_view.height

                YClickabledImage {
                    id: id_delegate_item_bg
                    sourceSize: Qt.size(200, 222)
                    mouseAreaMargins: -10
                    source: {
                        if (qmlGlobal.fileExists(model.modelData.icon)) {
                            return model.modelData.icon
                        }
                        if (model.modelData.isScanPackage || (model.modelData.domain === columnManager.domainNameMyProduction)) {
                            return "image://icons/audioplayer/bg/scanning.png"
                        }
                        return ("image://icons/audioplayer/columnId/%1.png").arg(model.modelData.columnId)
                    }

                    opacity: id_delete_column_tip_loader.active ? 0.6 : 1

                    YShadowText {
                        id: id_item_title
                        anchors.top: parent.top
                        anchors.topMargin: 30
                        anchors.left: parent.left
                        anchors.leftMargin: 20
                        width: 160
                        height: 70
                        font.pixelSize: 26
                        font.family: fontManager.fontFamilyZhCn
                        text: model.modelData.title
                        wrapMode: YText.WrapAnywhere
                        elide: YText.ElideRight
                    }

                    YText {
                        id: id_item_total
                        anchors.left: parent.left
                        anchors.leftMargin: 20
                        anchors.bottom: parent.bottom
                        anchors.bottomMargin: 26
                        font.pixelSize: 22
                        text: model.modelData.size + YTranslateText.pieces1
                    }

                    onClicked: {
                        if (isDownloadManagerView) {
                            if (editing) {
                                id_remove_column_drawer_layer.columnTitle = model.modelData.title
                                id_remove_column_drawer_layer.columnId = model.modelData.columnId
                                id_remove_column_drawer_layer.show()
                                return
                            } else if (model.modelData.isScanPackage) {
                                return
                            }
                        }

                        id_title_bar_holder.columnTitle = model.modelData.title
                        id_youdao_audio_page_column_view.currentDownloadState
                                = (isDownloadManagerView ? YEnum.DS_SUCCEED : YEnum.DS_ALL)
                        id_youdao_audio_page_column_view.model = mediaManager
                        mediaManager.entryColumn(model.modelData.columnId, isDownloadManagerView)
                        checkedIndex = index
                    }
                }

                YLoader {
                    id: id_delete_column_tip_loader
                    anchors.right: id_delegate_item_bg.right
                    anchors.rightMargin: -4
                    anchors.top: id_delegate_item_bg.top
                    anchors.topMargin: -4
                    active: id_youdao_audio_page_view.visible && isDownloadManagerView && editing
                    sourceComponent: YImage {
                        sourceSize: Qt.size(36, 36)
                        imageName: "audioplayer/delete_indicator"
                    }
                }
            }

            footer: (columnManager.itemCount > 0 && columnManager.hasMore)
                    ? id_listview_loading_footer : null

            Component {
                id: id_listview_loading_footer

                YListViewLoadMoreFooter {}
            }
        }

        YTextMedium {
            id: id_result_empty_tip

            visible: {
                if (id_youdao_audio_page_view.busying) {
                    return false
                }
                if (isDownloadManagerView) {
                    return id_youdao_audio_page_view.empty
                }
                return id_youdao_audio_page_view.empty
                        && !wifiManager.internetConnect
            }
            font.pixelSize: 28
            textFormat: YTextMedium.RichText
            text: {
                if (isDownloadManagerView) {
                    return YTranslateText.downloadYdListeninTip.arg(YColors.blueText)
                }
                return YTranslateText.ydListeningNetworkError.arg(YColors.blueText)
            }
            anchors.centerIn: parent
            width: paintedWidth
            height: paintedHeight

            YButtonBaseMouseArea {
                anchors.fill: parent
                anchors.margins: -40
                onValidClicked: {
                    if (isDownloadManagerView) {
                        backButtonClicked()
                        columnManager.wipeData()
                        qmlGlobal.quicklyEnterYDListening()
                    } else {
                        qmlGlobal.requestSettingPage(YEnum.SettingIndex.Network)
                    }
                }
                objectName: "YYoudaoAudioPageComponent.qml_id_result_empty_tip"
            }
        }

    }

    Item {
        id: id_title_bar_holder
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        implicitWidth: 80

        property string columnTitle: ""

        ShaderEffectSource {
            id: id_effect_source
            anchors.fill: parent
            sourceItem: id_youdao_audio_page_view_container
            sourceRect: Qt.rect(x - 90, y , width, height)
        }

        FastBlur {
            anchors.fill: parent
            source: id_effect_source
            radius: 32
        }

        Rectangle {
            anchors.fill: parent
            color: "#4D000000"
            anchors.top: parent.top
            anchors.bottom: parent.bottom
        }
    }

    onCheckedIndexChanged: {
        if (-1 === checkedIndex){
            id_youdao_audio_page_column_view.close()
        } else {
            id_youdao_audio_page_column_view.show()
        }
    }

    YVerticalTitleBar {
        id: id_title_bar
        iconButtonBackgroundItem.color: id_youdao_audio_page_view.contentX > 30 ? "#991A1B1F" : YColors.grayNormal
        onCallBack: {
            if (isDownloadManagerView && editing) {
                editing = false
                return
            }
            if (-1 !== checkedIndex) {
                checkedIndex = -1
                if (typeof lastIsDownloadManagerView != "undefined") {
                    isDownloadManagerView = lastIsDownloadManagerView
                }
//                if (isDownloadManagerView) {
//                    qmlGlobal.reinitAudiosDownloadManager()
//                } else {
//                    columnManager.wipeData(false)
//                    columnManager.loadMore(false, columnManager.domainNameYdListen)
//                    //qmlGlobal.reinitYDListening()
//                }
            } else {
                backButtonClicked()
                columnManager.wipeData()
            }
        }

        YIconButton {
            width: 44
            height: 44
            anchors.left: parent.left
            anchors.leftMargin: 16
            anchors.bottom: parent.bottom
            radius: height/2
            color: id_youdao_audio_page_view.contentX > 30 ? "#991A1B1F" : YColors.grayNormal
            sourceSize: Qt.size(36, 36)
            enabled: {
                if (isDownloadManagerView) {
                    return (id_youdao_audio_page_view.visible
                            && (id_youdao_audio_page_view.count > 0))
                           || (id_youdao_audio_page_column_view.count > 0)
                } else {
                    return true
                }
            }
            imageName: {
                if (isDownloadManagerView) {
                    return (editing && enabled ? "input/ic_selected" : "ic_delete")
                }
                if (-1 === checkedIndex) {
                    return "commons/more"
                }
                return "commons/download"
            }
//            visible: isDownloadManagerView || (-1 === checkedIndex)
//                     || columnManager.currentOpenColumnIsAuthorized

            mouseAreaMargins: -18
            mouseAreaTopMargin: -60

            onClicked: {
                if (isDownloadManagerView) {
                    editing = !editing
                } else {
                    if (-1 === checkedIndex) {
                        id_youdao_audio_filter_drawer_layer.show()
                    } else {
                        backButtonClicked()
                        columnManager.wipeData()
                        qmlGlobal.quicklyEnterAudiosDownloadManager()
                    }
                }
            }
        }
        objectName: "YYoudaoAudioPageComponent.qml_" + id_youdao_audio_page_component_root.objectName
    }

    YYoudaoAudioFilterDrawerLayer {
        id: id_youdao_audio_filter_drawer_layer
        visible: !isDownloadManagerView
        onFilterChanged: {
            settingManager.setColumnFilter(filterString)
            columnManager.reload()
        }
    }

    YRemoveColumnDrawerLayer {
        id: id_remove_column_drawer_layer
    }

    YAuthorizedTipDrawerLayer {
        id: id_authorized_tip_drawer_layer
    }
}


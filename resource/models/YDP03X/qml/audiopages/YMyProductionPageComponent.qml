import QtQuick 2.12
import com.youdao.pen 1.0

import BaseQml 1.0
import "../components"
import "../i18n"

YBackButtonAudioPage {
    id: id_container_index

    property bool isScanPage: true
    property string searchCode: ""
    property int incubatorCreateCount: 0

    function showKeyboard(keyBoardPage) {
        keyBoardPage.backButtonClicked.connect(function(){
            keyBoardPage.todoDestroy()
            YInputProperty.inputPageShowing = false
            keyBoardPage = null
        })
        keyBoardPage.inputFinished.connect(function(pwd){
            id_container_index.searchCode = pwd.toUpperCase()
            if (pwd.length > 0) {
                logManager.sendHttpLog("action=listening_make_searchcode_click")
                columnManager.queryCourseByCode(pwd)
            }
        })
        keyBoardPage.placeHolderText = YTranslateText.inputTip
        keyBoardPage.visible = true
        YInputProperty.inputPageShowing = true
    }

    function requestKeyboard() {
        const component = qmlCreateComponent("input/YInputPage")
        if (Component.Ready === component.status) {
            let incubator = component.incubateObject(id_keyboard_container);
            if (incubator.status !== Component.Ready) {
                incubator.onStatusChanged = function(status) {
                    if (status === Component.Ready) {
                        if (0 === --incubatorCreateCount) {
                            showKeyboard(incubator.object)
                        } else {
                            incubator.object.destroy()
                        }
                    }
                }
                ++incubatorCreateCount
            } else {
                console.log("Object", incubator.object, "is ready immediately!");
                showKeyboard(incubator.object)
            }
        }
    }

    YIconButton {
        implicitWidth: 44
        implicitHeight: 44
        anchors.left: parent.left
        anchors.leftMargin: 16
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 18
        radius: height/2
        sourceSize: Qt.size(36, 36)
        imageName: "audioplayer/search_hw"
        mouseAreaMargins: -25
        onClicked: {
            requestKeyboard()
        }
    }

    YMyProductionPageComponentEmpty {
        anchors.fill: parent
        visible: !id_my_production_result_list_view.busying
                 && id_my_production_result_list_view.empty
    }

    YBaseListView {
        id: id_my_production_result_list_view
        anchors.fill: parent
        anchors.leftMargin: 90
        anchors.rightMargin: 16
        busyingInterval: 60
        onMovingChanged: {
            if (!moving && atYEnd && columnManager.hasMore) {
                columnManager.loadMore(true, columnManager.domainNameMyProduction)
            }
        } // todo 细化 loadMore 逻辑
        visible: !empty
        model: columnManager

        header: YSpacing {
            width: id_my_production_result_list_view.width
            implicitHeight: 80
            YTitle {
                id: id_title
                anchors.verticalCenter: parent.verticalCenter
                text: YTranslateText.myProductionAudios
            }
        }

        delegate: Item {
            width: id_my_production_result_list_view.width
            implicitHeight: 86

            YMyProductionPageComponentViewItem {
                implicitHeight: 76
                title: (index + 1) + ". " + model.modelData.title
                titleFontFamily: fontManager.fontFamilyZhCn
                value: ""
                isDefaultScan: model.modelData.columnId === settingManager.curScannigColumn

                onLeftClicked: {
                    console.log("YMyProductionPageComponent.qml===entryMyProduct")
                    id_youdao_audio_page_column_view.columnTitle = model.modelData.title
                    id_youdao_audio_page_column_view.currentDownloadState = YEnum.DS_SUCCEED
                    id_youdao_audio_page_column_view.model = mediaManager
                    mediaManager.entryColumn(model.modelData.columnId, true)
                    id_youdao_audio_page_column_view.show()
                }

                onRightClicked: {
                    console.log("YMyProductionPageComponent.qml===setDefaultScanning")
                    confirmDefaultLayer.columnId = model.modelData.columnId
                    confirmDefaultLayer.columnTitle = model.modelData.title
                    confirmDefaultLayer.show()
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

    Item {
        anchors.fill: parent

        YYoudaoAudioPageColumnView {
            id: id_youdao_audio_page_column_view
            anchors.fill: parent
            anchors.leftMargin: 90
            anchors.rightMargin: 16

            readonly property bool editing: false

            YAuthorizedTipDrawerLayer {
                id: id_authorized_tip_drawer_layer
            }
        }

        YVerticalTitleBar {
            id: id_title_bar
            visible: id_youdao_audio_page_column_view.visible
            onCallBack: {
                id_youdao_audio_page_column_view.close()
            }
        }
    }

    YMyProductionPageComponentSearchResultView {
        id: id_search_result_view
        anchors.fill: parent
    }

    Item {
        id: id_keyboard_container
        anchors.fill: parent
    }

    Connections {
        target: columnManager
        ignoreUnknownSignals: true
        enabled: id_container_index.visible

        function onCourseCodeError(errCode, errMsg) {
            console.warn("YMyProductionPageComponent.qml===onCourseCodeError ", errMsg)
            baseSignals.showToast(errMsg, YColors.grayNormal)
        }

        function onCourseCodeResult(columnId, mediaId, title, downloadState) {
            console.log("YMyProductionPageComponent.qml===onCourseCodeResult ", columnId, title, downloadState)
            id_search_result_view.searchCode = id_container_index.searchCode
            id_search_result_view.courseTitle = title
            id_search_result_view.downloadState = downloadState
            id_search_result_view.show()
        }

        function onDownloadProgress(columnId, mediaId, progress) {
            if (columnId === id_container_index.searchCode) {
                console.log("YMyProductionPageComponent.qml===onDownloadProgress ", columnId, progress)
                if (progress < 0) {
                    id_search_result_view.downloadState = YEnum.DS_FAILURE
                    if (-progress === YEnum.DET_STORAGEINVALID) {
                        baseSignals.showToast(YTranslateText.downloadErrorStorageInvalid, YColors.yellow)
                    }
                }
                else if (progress >= 100) {
                    id_search_result_view.downloadState = YEnum.DS_SUCCEED
                    id_search_result_view.progress = progress
                }
                else {
                    id_search_result_view.downloadState = YEnum.DS_ING
                    id_search_result_view.progress = progress
                }
            }
        }
        function onProductionCountChanged() {
            if (columnManager.productionCount > 0) {
                columnManager.wipeData()
                columnManager.loadMore(true, columnManager.domainNameMyProduction)
            }
        }
    }

    onBackButtonClicked: {
        columnManager.wipeData()
    }
}


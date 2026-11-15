import QtQuick 2.12
import com.youdao.pen 1.0

import BaseQml 1.0
import "../components"
import "../i18n"

YBackgroundIgnoreMouseEvent {
    id: id_my_production_result
    visible: false

    property alias searchCode: id_title_search_code.text
    property alias courseTitle: id_my_production_result_item.title
    property alias progress: id_my_production_result_item.progress
    property alias downloadState: id_my_production_result_item.downloadState

    function show() {
        id_mask_area.state = "show"
        visible = true
    }

    function close() {
        id_mask_area.state = "close"
        visible = false
    }

    YBackground {
        id: id_mask_area
        anchors.fill: parent
        state: "close"
    }

    YVerticalTitleBar {
        id: id_title_bar_holder
        onCallBack: {
            // columnManager.clearCourseCode()
            close()
        }
    }

    Item {
        id: id_content_container
        anchors.fill: parent
        anchors.leftMargin: 90
        anchors.rightMargin: 16

        YTextBase {
            id: id_title_search_code
            color: YColors.grayText
            font.pixelSize: 26
            anchors.top: parent.top
            horizontalAlignment: Text.AlignLeft
            verticalAlignment: Text.AlignVCenter
            elide: YTextBase.ElideRight
            height: 80
        }

        YMyProductionPageComponentSearchResultViewItem {
            id: id_my_production_result_item
            anchors.top: id_title_search_code.bottom
            implicitHeight: 76
            value: ""

            function downloadCourse() {
                columnManager.downloadCourse(id_title_search_code.text)
            }

            onClicked: {
                if (!wifiManager.internetConnect) {
                    baseSignals.showToast(YTranslateText.networkAbnormalPleaseCheck, YColors.grayNormal)
                    return
                }

                switch (downloadState) {
                case YEnum.DS_NOT:
                case YEnum.DS_FAILURE:
                    downloadCourse()
                    break
                case YEnum.DS_SUCCEED:
                case YEnum.DS_ING:
                default:
                    break
                }
            }

            onDownloadStateChanged: {
                if (YEnum.DS_SUCCEED === downloadState) {
                    baseSignals.showToast(YTranslateText.myProductionAudiosDownloaded, YColors.grayNormal)
                }
            }

            onVisibleChanged: {
                if (visible) {
                    baseSignals.showToast(YTranslateText.myProductionAudiosUploadInfo, YColors.grayNormal)
                }
            }
        }
    }


}

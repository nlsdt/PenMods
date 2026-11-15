import QtQuick 2.12
import com.youdao.pen 1.0

import BaseQml 1.0

Item {
    id: id_youdao_audio_page_column_view_item_status
    implicitWidth: 36
    implicitHeight: 36
    state: "DS_NOT"

    property int downloadState: 0
    property int progress: 0
    property bool isAuthorized: true
    property int mediaId: 0

    onProgressChanged: {
        if (0 === progress) {
            if ("DS_NOT" !== state) {
                state = "DS_NOT"
            }
        } else if (progress <= 10) {
            if ("DS_PRE_ING" !== state) {
                state = "DS_PRE_ING"
            }
            return
        } else if (progress > 10 && (state === "DS_PRE_ING")) {
            if ("DS_ING" !== state) {
                state = "DS_ING"
            }
        } else if (100 === progress) {
            if ("DS_SUCCEED" !== state) {
                state = "DS_SUCCEED"
            }
        }
    }

    onDownloadStateChanged: {
        console.log("YYoudaoAudioPageColumnViewItemStatus.qml===onDownloadStateChanged ", downloadState)
        switch (downloadState) {
        case YEnum.DS_SUCCEED:
            state = "DS_SUCCEED"
            break
        case YEnum.DS_ING:
            state = "DS_PRE_ING"
            break
        case YEnum.DS_NOT:
        case YEnum.DS_FAILURE:
        default:
            state = "DS_NOT"
            break
        }
    }

    YImage {
        anchors.centerIn: parent
        sourceSize: Qt.size(36, 36)
        visible: ("DS_NOT" === id_youdao_audio_page_column_view_item_status.state)
                 || ("DS_SUCCEED" === id_youdao_audio_page_column_view_item_status.state)

        imageName: {
            switch (id_youdao_audio_page_column_view_item_status.state) {
            case "DS_NOT":
                return isAuthorized ? "commons/download" : "audioplayer/authorized_play"
            case "DS_SUCCEED":
                return "audioplayer/audioplayer_downloaded"
            default:
                return ""
            }
        }
    }

    YCircularProgressBar {
        id: id_progress_bar
        anchors.centerIn: parent
        mediaIdValue: mediaId
        progressValue: {
            switch (id_youdao_audio_page_column_view_item_status.state) {
            case "DS_PRE_ING":
                return 45
            case "DS_ING":
                return progress
            default:
                return 0
            }
        }
        visible: ("DS_PRE_ING" === id_youdao_audio_page_column_view_item_status.state)
                 || ("DS_ING" === id_youdao_audio_page_column_view_item_status.state)

        NumberAnimation on rotation {
            from: 0
            to: 360
            duration: 1920
            running: "DS_PRE_ING" === id_youdao_audio_page_column_view_item_status.state
            loops: NumberAnimation.Infinite
            alwaysRunToEnd: true
        }
    }
}

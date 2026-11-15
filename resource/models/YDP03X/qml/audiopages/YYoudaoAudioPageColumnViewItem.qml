import QtQuick 2.12
import com.youdao.pen 1.0

import BaseQml 1.0
import "../components"
import "../animations"

YSettingAboutClickableItem {
    id: id_youdao_audio_page_column_view_item

    property bool isDownloadManagerView: false

    valueRightMargin: (isDownloadManagerView && !editing) ?  20 : (20 + 36 + 20)
    readonly property int downloadState: model.modelData.downloadState
    readonly property int progress: model.modelData.progress
    readonly property bool isPlaying: (YEnum.PLAYING === mediaPlayerManager.playState)
                                      && (mediaManager.playingMediaId === model.modelData.id)

    iconComponent: {
        if (isDownloadManagerView) {
            if (editing) {
                return id_download_manager_component
            }
            return null
        }
        if (isPlaying) {
            return id_playing_icon_component
        }
        return id_normal_icon_component
    }

    titleColor: isPlaying ? YColors.red : YColors.white

    Component {
        id: id_normal_icon_component
        YYoudaoAudioPageColumnViewItemStatus {
            downloadState: id_youdao_audio_page_column_view_item.downloadState
            progress: id_youdao_audio_page_column_view_item.progress
            isAuthorized: columnManager.currentOpenColumnIsAuthorized
            mediaId: model.modelData.id
        }
    }

    Component {
        id: id_playing_icon_component
        YYoudaoAudioPageColumnViewItemAnimation {
            running: isPlaying && iconLoaded
        }
    }

    Component {
        id: id_download_manager_component
        YImage {
            sourceSize: Qt.size(36, 36)
            imageName: "audioplayer/delete_indicator"
        }
    }

    titlePixelSize: 26
    valuePixelSize: 24
}

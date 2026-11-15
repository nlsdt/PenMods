import QtQuick 2.12

import BaseQml 1.0
import "../components"

YSettingAboutClickableItem {
    id: id_my_production_search_result_view_item

    valueRightMargin: 20 + 36 + 20
    property int downloadState: 0 //todo model.modelData.downloadState
    property int progress: 0 //todo model.modelData.progress

    iconComponent: YYoudaoAudioPageColumnViewItemStatus {
        downloadState: id_my_production_search_result_view_item.downloadState
        progress: id_my_production_search_result_view_item.progress
        isAuthorized: true
    }

    titlePixelSize: 26
    valuePixelSize: 24
}

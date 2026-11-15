import QtQuick 2.12

import BaseQml 1.0
import "../components"

YSettingAboutClickableItem {
    id: id_my_import_page_component_view_item

    readonly property bool isDir: model.modelData.isDir

    valueRightMargin: 20
    imageName: isDir ? "settings/info_more_arrow" : ""

    titlePixelSize: 26
    valuePixelSize: 24
}

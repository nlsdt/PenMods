import QtQuick 2.12
import com.youdao.pen 1.0

import "../common"
import "../components"

// 行控件：官方 2 代「我的导入」文件管理页样式
// 左侧为文件类型图标（qrc:/images/format/suffix-*.png，自 2 代 qrc 移植），
// 右侧为模式指示图标（由 FileManagerPageComponent 通过 source 指定）。
YSettingAboutClickableItem {
    id: id_filemgr_page_component_view_item

    readonly property bool isDir: model.isDir

    YImage {
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        anchors.leftMargin: 10
        asynchronous: true
        source: model.extIcon
    }

    valueRightMargin: 10
    titleLeftMargin: 43

    titlePixelSize: 16
    valuePixelSize: 14
}

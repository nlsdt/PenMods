import QtQuick 2.12
import com.youdao.pen 1.0

import BaseQml 1.0
import "../common"
import "../components"

// =====================================================================
// 文件管理页 —— 按官方 2 代「我的导入」页（FileManagerPageComponent）移植
//
// 外观：YBackButtonPage(含竖排返回栏) + 左侧工具栏(重命名/删除) +
//       文件列表(行=类型图标+文件名+大小+右侧箭头) + 删除确认 + 重命名键盘
//
// 能力范围：音频/视频、图片/文本查看。
//   - 目录浏览 / 返回上级
//   - 音频(mp3/flac/m4a/wav/ogg/aac) → MusicPlayer → 系统音频播放器
//   - 视频(avi/mp4/mov/flv/mkv/webm) → 内嵌 FFmpeg，失败时回退 MPV
//   - 删除（确认对话框）/ 重命名（YInputPage 键盘）
// =====================================================================

YBackButtonPage {
    id: id_container_index
    objectName: "YPage===FileManagerPageComponent.qml"

    readonly property int kNormal: 0
    readonly property int kDelete: 1
    readonly property int kRename: 2
    property int currentMode: kNormal
    property string operatingFileName: ""
    property bool operatingIsDir: false
    // 图片/文本查看器是否正在展示（展示期间隐藏左侧编辑/删除工具栏）
    property bool viewerShowing: false
    property int videoRequestId: 0

    // 扩展名 → 处理类型查找表
    readonly property var fileHandlers: {
        "mp3": "play",
        "flac": "play",
        "m4a": "play",
        "wav": "play",
        "ogg": "play",
        "aac": "play",
        "avi": "video",
        "mp4": "video",
        "mov": "video",
        "flv": "video",
        "mkv": "video",
        "webm": "video",
        "txt": "text",
        "md": "text",
        "log": "text",
        "png": "image",
        "jpg": "image",
        "jpeg": "image",
        "gif": "image",
        "bmp": "image",
        "webp": "image"
    }

    // 按扩展名分发（音频→系统播放器；视频→FFmpeg；文本/图片→内置查看器）
    function openByType(fileName, extName) {
        let type = fileHandlers[extName.toLowerCase()];
        if (type === "play") {
            fileManager.playFromView(fileName);
        } else if (type === "video") {
            id_video_loader.active = false;
            externalPlayer.open(fileName);
            videoRequestId = externalPlayer.requestId;
            viewerShowing = true;
            id_video_loader.active = true;
        } else if (type === "text") {
            textReader.open(fileName);
            id_container_index.showViewer("PenModsTextViewer");
        } else if (type === "image") {
            imageViewer.open(fileName);
            id_container_index.showViewer("PenModsImageViewer");
        } else {
            baseSignals.showToast("暂不支持该格式", YColors.yellow);
        }
    }

    Loader {
        id: id_video_loader
        anchors.fill: parent
        z: 100
        active: false
        source: "ExternalPlayer.qml"
        onLoaded: {
            // The Loader owns this page and releases it by setting active=false.
            item.destroyOnBack = false;
            item.backButtonClicked.connect(function () {
                id_video_loader.active = false;
                id_container_index.viewerShowing = false;
            });
            item.show();
        }
        onStatusChanged: {
            if (status === Loader.Error && id_container_index.visible) {
                externalPlayer.fallbackToMpv(id_container_index.videoRequestId, "Cannot load playback page");
                if (externalPlayer.fallbackError.length)
                    baseSignals.showToast(externalPlayer.fallbackError, YColors.yellow);
                active = false;
                id_container_index.viewerShowing = false;
            }
        }
    }

    onVisibleChanged: {
        if (!visible) {
            id_video_loader.active = false;
            viewerShowing = false;
        }
    }

    // 通用查看器弹出（参照 showKeyboard 的 incubate 模式）
    property int incubatorCreateViewerCount: 0

    function showViewer(page) {
        id_container_index.viewerShowing = true;
        const component = qmlCreateComponent("audiopages/" + page);
        if (Component.Ready === component.status) {
            const incubator = component.incubateObject(id_container_index);
            if (incubator.status !== Component.Ready) {
                incubator.onStatusChanged = function (status) {
                    if (status === Component.Ready) {
                        if (0 === --id_container_index.incubatorCreateViewerCount) {
                            id_container_index.initViewer(incubator.object);
                        } else {
                            incubator.object.destroy();
                        }
                    }
                };
                ++id_container_index.incubatorCreateViewerCount;
            } else {
                id_container_index.initViewer(incubator.object);
            }
        }
    }

    function initViewer(viewerPage) {
        viewerPage.backButtonClicked.connect(function () {
            id_container_index.viewerShowing = false;
            viewerPage.todoDestroy();
        });
        viewerPage.show();
    }

    function showKeyboard() {
        let component = qmlCreateComponent("input/YInputPage");
        if (Component.Ready === component.status) {
            var incubator = component.incubateObject(id_page_pop_helper.containerItem);
            if (incubator.status !== Component.Ready) {
                incubator.onStatusChanged = function (status) {
                    if (status === Component.Ready) {
                        id_page_pop_helper.inputPageCreated(incubator.object);
                    }
                };
            } else {
                id_page_pop_helper.inputPageCreated(incubator.object);
            }
        }
    }

    ignoreDefaultBackButtonClicked: true

    onBackButtonClickedCallback: {
        id_error_tip.visible = false;
        if (visible && fileManager.canCdUp()) {
            fileManager.changeDir('..');
            currentMode = kNormal;
        } else {
            backButtonClicked();
            fileManager.reset();
        }
    }

    Component.onCompleted: {
        fileManager.changeDir("");
        // 返回按钮左移一点（仅本页生效：80px 竖排栏内的返回图标左移 8px）
        id_container_index.defaultTitleBar.iconButtonBackgroundItem.anchors.horizontalCenterOffset = -8;
    }

    YBaseListView {
        id: id_files_view
        anchors.fill: parent
        anchors.leftMargin: 54
        anchors.rightMargin: 10
        spacing: 8
        model: fileManager

        cacheBuffer: 200

        onMovingChanged: {
            if (!moving && atYEnd && fileManager.hasMore)
                fileManager.loadMore();
        }
        header: id_header_component
        footer: fileManager.hasMore ? id_listview_loading_footer : id_listview_loaded_footer
        onBusyingChanged: {
            if (!busying)
                id_files_view.positionViewAtBeginning();
        }

        Component {
            id: id_header_component
            Item {
                width: id_files_view.width
                implicitHeight: 50
                YTextBase {
                    color: YColors.grayText
                    font.pixelSize: 16
                    anchors.verticalCenter: parent.verticalCenter
                    width: parent.width
                    visible: !id_error_tip.visible
                    elide: YTextBase.ElideLeft
                    text: fileManager.currentTitle
                    textFormat: Text.RichText
                }
            }
        }

        Component {
            id: id_listview_loading_footer
            YListViewLoadMoreFooter {}
        }

        Component {
            id: id_listview_loaded_footer
            YSpacing {
                width: id_files_view.width
                implicitHeight: 12
            }
        }

        delegate: Item {
            width: id_files_view.width
            implicitHeight: 50

            FileManagerPageComponentViewItem {
                implicitHeight: parent.implicitHeight
                title: model.fileName
                value: (currentMode == kNormal && !isDir) ? model.sizeStr : ''

                // 右侧指示图标：删除/重命名模式 → 模式图标；普通模式目录 → 箭头
                source: {
                    if (currentMode === kDelete)
                        return "audioplayer/delete_indicator";
                    if (currentMode === kRename)
                        return "edit-indicator";
                    return isDir ? "settings/info_more_arrow" : '';
                }

                onClicked: {
                    operatingFileName = model.fileName;
                    operatingIsDir = isDir;

                    if (currentMode == kDelete) {
                        id_delete_file_dialog.show();
                        return;
                    }
                    if (currentMode == kRename) {
                        showKeyboard();
                        return;
                    }

                    if (isDir) {
                        fileManager.changeDir(model.fileName);
                        currentMode = kNormal;
                    } else if (model.isSymLink) {
                        // 软链接：先尝试进入（C++ 内部解析链接指向的目录），失败则按文件处理
                        if (!fileManager.changeDir(model.fileName)) {
                            if (model.isExecutable) {
                                fileManager.executeFile(model.fileName);
                            } else {
                                id_container_index.openByType(model.fileName, model.extName);
                            }
                        } else {
                            currentMode = kNormal;
                        }
                    } else if (model.isExecutable) {
                        fileManager.executeFile(model.fileName);
                    } else {
                        id_container_index.openByType(model.fileName, model.extName);
                    }
                }
            }
        }
    }

    // 删除确认对话框（官方样式）
    YOneButtonDialog {
        id: id_delete_file_dialog
        z: parent.z + 1
        anchors.fill: parent
        tipItem.text: {
            let name = operatingFileName.length > 25 ? operatingFileName.substring(0, 24) + '...' : operatingFileName;
            let typeStr = operatingIsDir ? '文件夹' : '文件';
            return "确定要删除" + typeStr + " <i>\"" + name + "\"</i> 吗?";
        }
        tipItem.textFormat: YText.RichText
        buttonItem.text: "确定"
        onClicked: {
            fileManager.remove(operatingFileName);
            close();
        }
    }

    // 重命名键盘
    YPagePopHelper {
        id: id_page_pop_helper

        function inputPageCreated(keyboardPage) {
            keyboardPage.backButtonClicked.connect(function () {
                YInputProperty.inputPageShowing = false;
                keyboardPage.todoDestroy();
                keyboardPage = null;
            });
            keyboardPage.inputFinished.connect(function (content) {
                if (content.length > 0) {
                    fileManager.rename(operatingFileName, content);
                } else {
                    baseSignals.showToast("文件名不能为空", YColors.yellow);
                }
            });
            keyboardPage.initialText = operatingFileName;
            keyboardPage.placeHolderText = "请输入新文件" + (operatingIsDir ? "夹" : "") + "名";
            keyboardPage.show();
            YInputProperty.inputPageShowing = true;
        }
        isShowing: YInputProperty.inputPageShowing
        objectName: "from_FileManagerPageComponent.qml"
    }

    // 左侧工具栏（重命名 / 删除）——查看器或键盘打开时隐藏
    Item {
        z: parent.z + 1
        visible: !YInputProperty.inputPageShowing && !id_container_index.viewerShowing
        anchors.fill: parent
        anchors.topMargin: 100
        anchors.leftMargin: 0

        YIconButton {
            id: id_setting
            width: 44
            height: 44
            anchors.top: parent.top
            anchors.topMargin: 12
            anchors.left: parent.left
            anchors.leftMargin: 10
            radius: 10
            source: "settings/info_more_arrow"
            sourceSize: Qt.size(26, 26)
            onValidClicked: {
                id_container_index.showViewer("FileManagerDrawerLayer");
            }
        }

        YIconButton {
            id: id_rename
            width: 44
            height: 44
            anchors.top: id_setting.bottom
            anchors.topMargin: 12
            anchors.left: parent.left
            anchors.leftMargin: 10
            radius: 10
            enabled: id_files_view.count > 0 && (currentMode == kNormal || currentMode == kRename)
            source: currentMode == kRename ? "textbook/select-check" : "textbook/guid-scan"
            sourceSize: Qt.size(26, 26)
            onValidClicked: {
                currentMode = (currentMode != kRename) ? kRename : kNormal;
            }
        }

        YIconButton {
            id: id_delete
            width: 44
            height: 44
            anchors.top: id_rename.bottom
            anchors.topMargin: 12
            anchors.left: parent.left
            anchors.leftMargin: 10
            radius: 10
            enabled: id_files_view.count > 0 && (currentMode == kNormal || currentMode == kDelete)
            source: currentMode == kDelete ? "textbook/select-check" : "ic_delete"
            sourceSize: Qt.size(26, 26)
            onValidClicked: {
                currentMode = (currentMode != kDelete) ? kDelete : kNormal;
            }
        }
    }

    // 错误提示（C++ 异常，如目录读取失败）
    YText {
        id: id_error_tip
        anchors.centerIn: parent
        color: YColors.white
        visible: false
        font.pixelSize: 20
        textFormat: Text.PlainText

        Connections {
            target: fileManager
            function onException(msg) {
                id_error_tip.visible = true;
                id_error_tip.text = msg;
            }
        }
    }

    // 目录内容变化提示
    YOneButtonDialog {
        id: id_reload_dialog
        z: parent.z + 1
        anchors.fill: parent
        tipItem.text: "当前文件夹内容发生变化"
        buttonItem.text: "重新加载"
        onClicked: {
            currentMode = kNormal;
            fileManager.reload();
            close();
        }

        Connections {
            target: fileManager
            function onDirectoryChanged() {
                if (!id_reload_dialog.isShowing && fileManager.shouldNotifyDirChanged())
                    id_reload_dialog.show();
            }
        }
    }
}

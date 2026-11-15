import QtQuick 2.12
import com.youdao.pen 1.0

import BaseQml 1.0
import "../common"
import "../components"
import "../i18n"

// =====================================================================
// 文件选择器（单选 / 多选）—— 由 chat、壁纸等挂载使用。
// 数据源：`fileManager`（QAbstractListModel），与 FileManagerPage 共用。
//
// 公开属性：
//   allowMultiSelect   是否多选
//   fileExtensions     允许的扩展名（小写），空数组 = 全部文件
// 公开信号：
//   fileSelected(path)         单选 / 多选确认（多选以 ";" 连接）
//   fileSelectionCancelled()   用户取消选择
// =====================================================================
YPage {
    id: id_container_index

    // ---- 对外属性 ----
    property string selectedFilePath: ""
    property string selectedFileName: ""
    property bool allowMultiSelect: false
    property var selectedFiles: []
    property var fileExtensions: [] // 允许的文件扩展名，空表示所有文件
    signal fileSelected(string filePath)
    signal fileSelectionCancelled()

    // 文件管理模式（本页固定为普通浏览模式）
    readonly property int kNormal: 0
    readonly property int kDelete: 1
    readonly property int kRename: 2
    property int currentMode: kNormal
    property string operatingFileName: ""
    property bool operatingIsDir: false
    // 是否已成功选出文件（避免完成后再次触发 fileSelectionCancelled）
    property bool _completed: false

    Component.onCompleted: {
        _completed = false;
        fileManager.changeDir("");
    }

    // 选中状态切换：重新赋值 selectedFiles 以触发委托内绑定重算，
    // 避免使用 2 代脆弱的 model.data(...roles.ExtensionIcon) 刷新技巧。
    function toggleSelect(fileName) {
        var idx = selectedFiles.indexOf(fileName);
        var arr = selectedFiles.slice();
        if (idx === -1) arr.push(fileName);
        else arr.splice(idx, 1);
        selectedFiles = arr;
    }

    function acceptExt(ext) {
        return fileExtensions.length === 0 || fileExtensions.indexOf(ext) !== -1;
    }

    function chooseFile(fileName, extName) {
        if (!acceptExt(extName)) {
            baseSignals.showToast("不支持的文件格式", YColors.yellow);
            return;
        }
        if (allowMultiSelect) {
            toggleSelect(fileName);
        } else {
            selectedFilePath = fileManager.getCurrentPathString() + "/" + fileName;
            _completed = true;
            fileSelected(selectedFilePath);
            backButtonClicked();
        }
    }

    // 用户按返回键 / 主页键关闭时通知取消（不覆盖 YPage 默认的关闭行为）
    Connections {
        target: id_container_index
        function onBackButtonClicked() {
            if (!_completed)
                fileSelectionCancelled();
        }
    }

    YVerticalTitleBar {
        id: id_title_bar
        onCallBack: {
            id_error_tip.visible = false;
            if (visible && fileManager.canCdUp()) {
                fileManager.changeDir('..');
            } else {
                fileSelectionCancelled();
                backButtonClicked();
            }
        }
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
                    text: "选择文件"
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
                value: isDir ? '' : model.sizeStr

                // 右侧指示：已选 → 选中勾；目录 → 进入箭头
                source: {
                    if (selectedFiles.indexOf(model.fileName) !== -1)
                        return "textbook/select-check";
                    return isDir ? "settings/info_more_arrow" : '';
                }

                onClicked: {
                    operatingFileName = model.fileName;
                    operatingIsDir = isDir;

                    if (isDir) {
                        fileManager.changeDir(model.fileName);
                    } else if (model.isSymLink) {
                        // 软链接：先尝试进入（C++ 内部解析链接指向的目录），失败则按文件处理
                        if (!fileManager.changeDir(model.fileName)) {
                            id_container_index.chooseFile(model.fileName, model.extName);
                        }
                    } else {
                        id_container_index.chooseFile(model.fileName, model.extName);
                    }
                }
            }
        }
    }

    // 底部操作栏 —— 仅在多选模式下显示
    Item {
        id: id_bottom_toolbar
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        height: 50
        visible: allowMultiSelect

        Rectangle {
            anchors.fill: parent
            color: "#2B3A4A"
        }

        Row {
            anchors.centerIn: parent
            spacing: 20

            YButton {
                text: "取消"
                width: 80
                height: 36
                radius: 6
                color: "#5A6B7D"
                textColor: "#FFFFFF"
                onClicked: {
                    fileSelectionCancelled();
                    backButtonClicked();
                }
            }

            YButton {
                text: "确认 (" + selectedFiles.length + ")"
                width: 120
                height: 36
                radius: 6
                color: "#2B5278"
                textColor: "#FFFFFF"
                enabled: selectedFiles.length > 0
                onClicked: {
                    if (selectedFiles.length > 0) {
                        var paths = [];
                        for (var i = 0; i < selectedFiles.length; i++)
                            paths.push(fileManager.getCurrentPathString() + "/" + selectedFiles[i]);
                        selectedFilePath = paths.join(";");
                        _completed = true;
                        fileSelected(selectedFilePath);
                        backButtonClicked();
                    }
                }
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
        showClose: false
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

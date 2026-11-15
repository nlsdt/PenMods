import QtQuick 2.12

import BaseQml 1.0

// =====================================================================
// 插件管理页（替换原「扫读音频」页面）
//
// 数据源：QML 上下文中的 `pluginManager`（QmlPluginWrapper）：
//   getPluginCount() / getPluginInfo(i) / setPluginEnabled() /
//   uninstallPlugin() / requestPluginList()，并监听 pluginListUpdated
//   与 pluginStateChanged 信号。
//
// 插件目录：/userdisk/PenMods/plugins（每个子目录一个插件，含 metadata.json）
// =====================================================================

YBackButtonPage {
    id: id_plugin_manager_page
    objectName: "YPage===YPluginManagerPage.qml"

    property bool usingLiveData: false
    property int pendingUninstallIndex: -1
    property var iconPalette: ["#644FEC", "#509DEB", "#13B876", "#E9900C",
                               "#F03043", "#5B7FFF", "#FF8B20", "#5687FF"]

    ListModel {
        id: id_plugin_model
    }

    // ---------------- 数据逻辑 ----------------

    // 统一日志前缀。与 PenMods2 的 PluginManager.qml 一致：启动路径上的 console.*
    // 无条件输出，是否可见由日志级别决定——LoggerMonitor 把 QML console 输出（Qt 默认
    // 消息处理器 → fprintf(stderr)）转发到 spdlog 的 debug 级别，因此：
    //   - debug 级别（PL_DEBUG 编译 / PENMODS3_LOG_LEVEL=debug）：详细日志全部可见
    //   - info 及以上：自动静默，不影响日常日志
    function pluginLog(msg) {
        console.log("[PluginManager] " + msg)
    }

    // 只读刷新：从 C++ 侧读取当前插件列表。
    // 注意：这里不能调用 requestPluginList()（会触发 scanAndLoadAll → pluginsChanged
    // → pluginListUpdated → 本函数，造成无限递归，列表会叠加出几十上百个重复项）。
    function refresh() {
        id_plugin_model.clear()
        if (typeof pluginManager !== "object" || pluginManager === null) {
            usingLiveData = false
            console.warn("[PluginManager] pluginManager 上下文属性不可用，页面进入演示模式")
            return
        }
        usingLiveData = true
        try {
            var n = pluginManager.getPluginCount()
            pluginLog("刷新插件列表: count=" + n)
            for (var i = 0; i < n; ++i) {
                var info = pluginManager.getPluginInfo(i)
                if (!info) continue
                pluginLog("  插件[" + i + "] id=" + info.id
                          + " name=" + info.name
                          + " mainQml=" + info.mainQmlUrl
                          + " enabled=" + info.isEnabled
                          + " loaded=" + info.isLoaded)
                id_plugin_model.append({
                    pid: info.id !== undefined ? info.id : "",
                    pname: (info.name !== undefined && info.name !== "")
                           ? info.name : "未命名插件",
                    pversion: info.version !== undefined ? info.version : "",
                    pauthor: info.author !== undefined ? info.author : "",
                    pdesc: info.description !== undefined ? info.description : "",
                    picon: info.icon !== undefined ? info.icon : "",
                    isEnabled: info.isEnabled === undefined ? true : !!info.isEnabled,
                    isLoaded: !!info.isLoaded
                })
            }
        } catch (e) {
            console.warn("[PluginManager] pluginManager error: " + e)
        }
    }

    // 重新扫描插件目录（由「刷新」按钮触发；扫描结果通过 pluginListUpdated 信号
    // 回调到 refresh()，因此这里不要自己再调 refresh()）
    function rescan() {
        pluginLog("请求重新扫描插件目录")
        if (typeof pluginManager === "object" && pluginManager !== null) {
            try {
                if (typeof pluginManager.requestPluginList === "function") {
                    pluginManager.requestPluginList()
                }
            } catch (e) {
                console.warn("[PluginManager] requestPluginList error: " + e)
            }
        } else {
            refresh()
        }
    }

    function togglePlugin(rowIndex, newState) {
        if (!usingLiveData) return
        var pid = id_plugin_model.get(rowIndex).pid
        var pname = id_plugin_model.get(rowIndex).pname
        pluginLog("切换插件开关: name=" + pname + " id=" + pid + " -> " + newState)
        try {
            if (pluginManager.setPluginEnabled(pid, newState)) {
                pluginLog("切换成功: " + pname + " -> " + newState)
                baseSignals.showToast(newState ? "已启用「" + pname + "」" : "已停用「" + pname + "」",
                                      YColors.green)
            } else {
                pluginLog("切换失败（后端返回 false，已回滚 UI）: " + pname + " -> " + newState)
                id_plugin_model.setProperty(rowIndex, "isEnabled", !newState)
                baseSignals.showToast("修改失败：插件不存在或加载失败", YColors.yellow)
            }
        } catch (e) {
            console.warn("[PluginManager] setPluginEnabled error: " + e)
            id_plugin_model.setProperty(rowIndex, "isEnabled", !newState)
            baseSignals.showToast("修改失败：" + e, YColors.yellow)
        }
    }

    function launchPlugin(rowIndex) {
        if (!usingLiveData) {
            pluginLog("忽略启动请求：pluginManager 不可用（演示模式）")
            return
        }
        var pid   = id_plugin_model.get(rowIndex).pid
        var pname = id_plugin_model.get(rowIndex).pname
        pluginLog("启动插件: name=" + pname + " id=" + pid)

        var mainQml = ""
        try {
            if (typeof pluginManager.getPluginMainQml === "function") {
                mainQml = pluginManager.getPluginMainQml(pid)
            } else {
                console.warn("[PluginManager] pluginManager 未暴露 getPluginMainQml()")
            }
        } catch (e) {
            console.warn("[PluginManager] getPluginMainQml error: " + e)
        }
        pluginLog("mainQml=" + mainQml)
        if (mainQml === "" || mainQml === "file://") {
            console.warn("[PluginManager] 插件没有 QML 入口: " + pname + " (" + pid + ")")
            baseSignals.showToast("该插件没有 QML 入口", YColors.yellow)
            return
        }
        id_plugin_manager_page.launchQml(mainQml)
    }

    // 用插件的 main.qml（file:// URL）创建页面并弹出；返回按钮关闭插件。
    // 状态机覆盖三种情况：同步 Ready / 同步 Error / 异步 Loading→Ready|Error。
    // 注意：同步 Error 时 statusChanged 永远不会触发，必须在这里单独处理，
    // 否则插件 QML 加载失败会被静默吞掉——旧版只连 statusChanged，插件 QML
    // 出错时一条日志、一个提示都没有，这正是「插件系统 QML 日志不存在」的根因。
    function launchQml(mainQml) {
        pluginLog("Creating component (no cache): " + mainQml)
        var component = Qt.createComponent(mainQml)

        if (component.status === Component.Ready) {
            pluginLog("Component ready immediately: " + mainQml)
            id_plugin_manager_page.finishLaunch(component, mainQml)
            return
        }

        if (component.status === Component.Error) {
            id_plugin_manager_page.onComponentLoadError(component, mainQml)
            return
        }

        // 异步加载中（file:// 本地文件通常是同步的，这里兜底网络/远程 URL）
        pluginLog("Component loading (async), waiting statusChanged: " + mainQml)
        component.statusChanged.connect(function () {
            pluginLog("Component statusChanged -> " + component.status + " (" + mainQml + ")")
            if (component.status === Component.Ready) {
                id_plugin_manager_page.finishLaunch(component, mainQml)
            } else if (component.status === Component.Error) {
                id_plugin_manager_page.onComponentLoadError(component, mainQml)
            }
        })
    }

    // 组件加载失败：打印完整 errorString（含 file:line 与具体错误），弹窗展示，销毁组件。
    function onComponentLoadError(component, mainQml) {
        var err = (typeof component.errorString === "function")
                  ? component.errorString() : "未知错误"
        console.error("[PluginManager] 插件页面加载失败: " + mainQml + "\n" + err)
        id_plugin_error_dialog.tipItem.text = "插件页面加载失败：\n" + err
        id_plugin_error_dialog.show()
        component.destroy()
    }

    function finishLaunch(component, mainQml) {
        pluginLog("Plugin component ready, creating object...")
        var obj = component.createObject(id_plugin_manager_page)
        component.destroy()
        if (obj === null) {
            console.error("[PluginManager] createObject 返回 null: " + mainQml)
            baseSignals.showToast("插件启动失败", YColors.yellow)
            return
        }
        pluginLog("Plugin object created: " + String(obj)
                  + " size=" + obj.width + "x" + obj.height)
        // 插件根为固定小尺寸（未用 anchors.fill 填满）时，等比放大适配屏幕
        var rootFill = (obj.anchors && obj.anchors.fill) ? obj.anchors.fill : null
        if (!rootFill && obj.width > 0 && obj.height > 0) {
            var pw = id_plugin_manager_page.width
            var ph = id_plugin_manager_page.height
            var s = Math.min(pw / obj.width, ph / obj.height)
            if (s > 1.0 && s < 8.0) {
                obj.scale = s
                obj.transformOrigin = Qt.point(0, 0)
                obj.x = Math.max(0, (pw - obj.width * s) / 2)
            }
        }
        // 插件根对象通常自带 backButtonClicked 信号（自绘工具栏返回钮）
        if (obj.backButtonClicked && typeof obj.backButtonClicked.connect === "function") {
            obj.backButtonClicked.connect(function () {
                obj.destroy()
            })
        } else {
            console.warn("[PluginManager] 插件没有 backButtonClicked 信号，返回按钮不可用: " + mainQml)
        }
        if (typeof obj.show === "function") {
            obj.show()
        } else {
            obj.visible = true
        }
    }

    function requestUninstall(rowIndex) {
        pendingUninstallIndex = rowIndex
        id_uninstall_dialog.tipItem.text = "确定卸载插件「"
                + id_plugin_model.get(rowIndex).pname + "」？\n"
                + "卸载会删除其插件目录，操作不可恢复。"
        id_uninstall_dialog.show()
    }

    function doUninstall() {
        var i = pendingUninstallIndex
        if (i < 0 || i >= id_plugin_model.count) {
            id_uninstall_dialog.close()
            return
        }
        var pid = id_plugin_model.get(i).pid
        try {
            if (pluginManager.uninstallPlugin(pid)) {
                id_plugin_model.remove(i)
                baseSignals.showToast("插件已卸载", YColors.green)
            } else {
                baseSignals.showToast("卸载失败", YColors.yellow)
            }
        } catch (e) {
            baseSignals.showToast("卸载失败：" + e, YColors.yellow)
        }
        id_uninstall_dialog.close()
    }

    Component.onCompleted: {
        pluginLog("插件管理页加载完成")
        if (typeof pluginManager === "object" && pluginManager !== null) {
            try {
                pluginManager.pluginListUpdated.connect(refresh)
                pluginManager.pluginStateChanged.connect(function(name, state) {
                    for (var i = 0; i < id_plugin_model.count; ++i) {
                        var item = id_plugin_model.get(i)
                        if (item.pid === name || item.pname === name) {
                            id_plugin_model.setProperty(i, "isEnabled", !!state)
                            break
                        }
                    }
                })
            } catch (e) {
                console.warn("[PluginManager] signal connect failed: " + e)
            }
        }
        refresh()
    }

    // ---------------- 界面 ----------------

    Item {
        id: id_content
        anchors.fill: parent
        anchors.leftMargin: 90
        anchors.rightMargin: 16
        anchors.topMargin: 16
        anchors.bottomMargin: 16

        // 页头（单行）
        Item {
            id: id_header
            width: parent.width
            height: 44

            YTextMedium {
                id: id_header_title
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                font.pixelSize: 26
                color: YColors.white
                font.family: fontManager.fontFamilyZhCn
                text: "插件管理"
            }

            YText {
                id: id_header_count
                anchors.left: id_header_title.right
                anchors.leftMargin: 14
                anchors.verticalCenter: parent.verticalCenter
                font.pixelSize: 18
                color: YColors.grayText
                font.family: fontManager.fontFamilyZhCn
                text: "已启用 " + enabledCount() + " / 共 " + id_plugin_model.count
            }

            // PenMods 设置入口（最右侧）
            YIconButton {
                id: id_settings_button
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                implicitWidth: 44
                implicitHeight: 44
                radius: 22
                color: YColors.buttonNormal
                imageName: "settings/ic_about"
                sourceSize: Qt.size(26, 26)
                onClicked: {
                    let component = qmlCreateComponent("settingpages/PenModsSettingPage")
                    if (Component.Ready === component.status) {
                        let incubator = component.incubateObject(id_plugin_manager_page)
                        if (incubator.status !== Component.Ready) {
                            incubator.onStatusChanged = function(status) {
                                if (status === Component.Ready) {
                                    incubator.object.show()
                                }
                            }
                        } else {
                            incubator.object.show()
                        }
                    } else {
                        baseSignals.showToast("设置页加载失败", YColors.yellow)
                    }
                }
            }

            function enabledCount() {
                var c = 0
                for (var i = 0; i < id_plugin_model.count; ++i) {
                    if (id_plugin_model.get(i).isEnabled) c++
                }
                return c
            }

            // 刷新按钮（在设置按钮左侧，不遮挡）
            Item {
                id: id_refresh_button
                anchors.right: id_settings_button.left
                anchors.rightMargin: 12
                anchors.verticalCenter: parent.verticalCenter
                width: id_refresh_text.width + 24
                height: 44

                YText {
                    id: id_refresh_text
                    anchors.centerIn: parent
                    font.pixelSize: 20
                    color: YColors.blueText
                    font.family: fontManager.fontFamilyZhCn
                    text: "刷新"
                }
                YMouseArea {
                    anchors.fill: parent
                    onClicked: {
                        id_plugin_manager_page.rescan()
                    }
                }
            }
        }

        // 插件列表
        YBaseListView {
            id: id_plugin_list
            anchors.top: id_header.bottom
            anchors.topMargin: 10
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            clip: true
            spacing: 12
            model: id_plugin_model
            delegate: id_plugin_row
        }

        // 空状态
        Item {
            anchors.fill: id_plugin_list
            visible: id_plugin_model.count === 0

            YText {
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: parent.top
                anchors.topMargin: 80
                font.pixelSize: 26
                color: YColors.white
                font.family: fontManager.fontFamilyZhCn
                text: "还没有安装插件"
            }
            YText {
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: parent.top
                anchors.topMargin: 124
                font.pixelSize: 20
                color: YColors.grayText
                font.family: fontManager.fontFamilyZhCn
                text: "把插件文件夹放入 /userdisk/PenMods/plugins"
            }
            YText {
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: parent.top
                anchors.topMargin: 152
                font.pixelSize: 20
                color: YColors.grayText
                font.family: fontManager.fontFamilyZhCn
                text: "返回后重进本页即可生效"
            }
        }
    }

    // 卸载确认对话框
    YTwoButtonDialog {
        id: id_uninstall_dialog
        anchors.fill: parent
        onClickedConfirm: {
            id_plugin_manager_page.doUninstall()
        }
        onClickedCancel: {
            close()
        }
    }

    // 插件加载错误对话框（显示真实 errorString，方便排查）
    YOneButtonDialog {
        id: id_plugin_error_dialog
        anchors.fill: parent
        tipItem.text: ""
        tipItem.height: 200
        tipItem.font.pixelSize: 22
        buttonItem.text: "确定"
        onClicked: {
            close()
        }
    }

    // ---------------- 列表行 ----------------

    Component {
        id: id_plugin_row

        Rectangle {
            id: id_row
            width: id_plugin_list.width
            implicitHeight: 208
            color: YColors.grayNormal
            radius: 16

            // 插件图标：优先显示 icon.png（file:// URL）；加载失败或没有图标时
            // 才回退到「首字符 + 彩色圆角块」占位
            Item {
                id: id_icon
                width: 56
                height: 56
                anchors.left: parent.left
                anchors.leftMargin: 14
                anchors.top: parent.top
                anchors.topMargin: 14

                Image {
                    id: id_icon_img
                    anchors.fill: parent
                    source: model.picon !== "" ? model.picon : ""
                    fillMode: Image.PreserveAspectFit
                    visible: source.toString() !== "" && status === Image.Ready
                    clip: true
                    onStatusChanged: {
                        visible = (source.toString() !== "" && status === Image.Ready)
                    }
                }

                Rectangle {
                    id: id_icon_fallback
                    anchors.fill: parent
                    radius: 16
                    visible: !id_icon_img.visible
                    color: id_plugin_manager_page.iconPalette[
                                index % id_plugin_manager_page.iconPalette.length]

                    YText {
                        anchors.centerIn: parent
                        font.pixelSize: 28
                        color: YColors.white
                        font.family: fontManager.fontFamilyZhCn
                        text: model.pname.length > 0 ? model.pname.charAt(0) : "?"
                    }
                }
            }

            // 开关（右上角）
            Item {
                id: id_switch_area
                anchors.right: parent.right
                anchors.rightMargin: 10
                anchors.top: parent.top
                anchors.topMargin: 10
                width: 100
                height: 56

                YMouseArea {
                    anchors.fill: parent
                    onClicked: {
                        var newState = !model.isEnabled
                        id_plugin_model.setProperty(index, "isEnabled", newState)
                        id_plugin_manager_page.togglePlugin(index, newState)
                    }
                }
                YSwitch {
                    id: id_switch
                    anchors.centerIn: parent
                    switchOn: model.isEnabled
                }
            }

            // 插件名
            Item {
                id: id_name_row
                anchors.left: id_icon.right
                anchors.leftMargin: 12
                anchors.right: id_switch_area.left
                anchors.rightMargin: 8
                anchors.top: parent.top
                anchors.topMargin: 18
                height: 32

                YTextMedium {
                    id: id_name
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    font.pixelSize: 26
                    color: YColors.white
                    font.family: fontManager.fontFamilyZhCn
                    elide: Text.ElideRight
                    text: model.pname
                }
            }

            // 插件说明（中间，最多两行）
            YText {
                id: id_desc
                anchors.left: id_icon.right
                anchors.leftMargin: 12
                anchors.right: parent.right
                anchors.rightMargin: 16
                anchors.top: id_name_row.bottom
                anchors.topMargin: 16
                font.pixelSize: 20
                color: YColors.grayText
                font.family: fontManager.fontFamilyZhCn
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                maximumLineCount: 2
                elide: Text.ElideRight
                lineHeightMode: YText.FixedHeight
                lineHeight: 26
                text: model.pdesc
            }

            // 版本 + 作者（v1.0.0 by 某某某）
            YText {
                id: id_author
                anchors.left: id_icon.right
                anchors.leftMargin: 12
                anchors.right: id_buttons.left
                anchors.rightMargin: 8
                anchors.top: id_desc.bottom
                anchors.topMargin: 14
                height: 24
                font.pixelSize: 18
                color: YColors.grayText
                font.family: fontManager.fontFamilyZhCn
                elide: Text.ElideRight
                verticalAlignment: Text.AlignVCenter
                text: {
                    var parts = []
                    if (model.pversion !== "") parts.push("v" + model.pversion)
                    if (model.pauthor !== "") parts.push("by " + model.pauthor)
                    return parts.join(" ")
                }
                visible: text !== ""
            }

            // 右下：启动 / 卸载
            Row {
                id: id_buttons
                anchors.right: parent.right
                anchors.rightMargin: 12
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 10
                spacing: 10

                YButton {
                    implicitWidth: 100
                    implicitHeight: 44
                    pixelSize: 20
                    color: YColors.red
                    text: "启动"
                    onClicked: {
                        id_plugin_manager_page.launchPlugin(index)
                    }
                }

                YButton {
                    implicitWidth: 100
                    implicitHeight: 44
                    pixelSize: 20
                    color: YColors.red
                    text: "卸载"
                    onClicked: {
                        id_plugin_manager_page.requestUninstall(index)
                    }
                }
            }
        }
    }
}

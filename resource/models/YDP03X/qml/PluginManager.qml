import QtQuick 2.12
import com.youdao.pen 1.0

import BaseQml 1.0
import "./common"
import "./components"
import "./settingpages"
import "./i18n"

YBackButtonPage {
    id: pluginManagerPage
    objectName: "YPage===PluginManager.qml"

    ListModel { id: pluginListModel }

    // --- 动态加载器（插件启动用；三代无 YDynamicPageStack，改用 incubator） ---
    Item {
        id: id_pop_container
        anchors.fill: parent
        z: 500
        property int _activePopups: 0
        visible: id_pop_container._activePopups > 0

        // 事件屏障：仅在弹窗存在时拦截未被弹窗处理的事件，防止穿透到下层列表。
        // 退出插件后 _activePopups 归零 → 屏障 disabled 且容器隐藏，不再挡住列表点击。
        MouseArea {
            id: id_pop_event_barrier
            anchors.fill: parent
            z: -1
            enabled: id_pop_container._activePopups > 0
            onPressed:  { mouse.accepted = true }
            onReleased: { mouse.accepted = true }
            onClicked:  { mouse.accepted = true }
        }

        function _syncVisible() {
            id_pop_container.visible = id_pop_container._activePopups > 0
        }

        function show(tpage, properties) {
            var componentPath = tpage
            if (tpage.indexOf("://") < 0 && tpage.indexOf(":/") < 0 && tpage.indexOf("file:") < 0) {
                componentPath = tpage.indexOf(".qml") === -1 ? tpage + ".qml" : tpage
            }
            var newComponent = Qt.createComponent(componentPath)
            var newComponentInit = function (incubatorObject) {
                var closed = false
                function closeThis() {
                    if (closed) return
                    closed = true
                    if (typeof incubatorObject.destroy === 'function') incubatorObject.destroy()
                    id_pop_container._activePopups--
                    id_pop_container._syncVisible()
                }
                // 插件自身声明的返回/关闭信号（YBackButtonPage.backButtonClicked / close）
                try {
                    if (typeof incubatorObject.backButtonClicked !== 'undefined' && incubatorObject.backButtonClicked)
                        incubatorObject.backButtonClicked.connect(closeThis)
                } catch (e) {}
                try {
                    if (typeof incubatorObject.closed !== 'undefined' && incubatorObject.closed)
                        incubatorObject.closed.connect(closeThis)
                } catch (e) {}
                // home 键兜底关闭
                if (typeof systemBase !== 'undefined' && systemBase) {
                    try {
                        if (typeof systemBase.homeKeyRelease !== 'undefined' && systemBase.homeKeyRelease)
                            systemBase.homeKeyRelease.connect(closeThis)
                        if (typeof systemBase.homeKeyLongPress !== 'undefined' && systemBase.homeKeyLongPress)
                            systemBase.homeKeyLongPress.connect(closeThis)
                    } catch (e) {}
                }
                if (typeof incubatorObject.show === 'function') incubatorObject.show()
                else if (typeof incubatorObject.visible !== 'undefined') incubatorObject.visible = true
                id_pop_container._activePopups++
                id_pop_container._syncVisible()
            }
            var incubator = newComponent.incubateObject(id_pop_container, properties || {})
            if (incubator.status !== Component.Ready) {
                incubator.onStatusChanged = function (s) {
                    if (s === Component.Ready) newComponentInit(incubator.object)
                }
            } else {
                newComponentInit(incubator.object)
            }
        }

        function closeAll() {
            for (var i = id_pop_container.children.length - 1; i >= 0; i--) {
                var c = id_pop_container.children[i]
                if (c !== id_pop_event_barrier && typeof c.destroy === 'function') {
                    try { c.destroy() } catch (e) {}
                }
            }
            id_pop_container._activePopups = 0
            id_pop_container._syncVisible()
        }
    }
    // ------------------

    // 确认卸载对话框
    YTwoButtonDialog {
        id: confirmUninstallDialog
        anchors.fill: parent
        property string targetName: ""
        property string pluginId: ""

        tipItem.text: "确定要卸载插件 \"" + targetName + "\" 吗？\n此操作将删除相关文件。"

        onClickedConfirm: {
            if (typeof pluginManager !== 'undefined') {
                try { pluginManager.uninstallPlugin(pluginId) } catch (e) {}
                try {
                    if (typeof pluginManager.requestPluginList === "function") pluginManager.requestPluginList()
                } catch (e) {}
            }
            close()
        }

        onClickedCancel: { close() }
    }

    YSettingItemTitle {
        id: titleContainer
        title: "插件管理器"
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.leftMargin: 50
        anchors.right: parent.right
    }

    ListView {
        id: pluginListView
        anchors.top: titleContainer.bottom
        anchors.left: parent.left
        anchors.leftMargin: 40
        anchors.right: parent.right
        anchors.rightMargin: 20
        anchors.bottom: parent.bottom
        model: pluginListModel
        spacing: 12
        clip: true

        footer: Item { width: parent.width; height: 20 }

        header: Item {
            width: parent.width
            height: pluginListModel.count === 0 ? 100 : 0
            visible: pluginListModel.count === 0
            YText {
                text: "未发现已安装的插件"
                font.pixelSize: 16
                color: YColors.grayText
                anchors.centerIn: parent
            }
        }

        delegate: Rectangle {
            id: pluginItem
            width: pluginListView.width
            height: contentColumn.height + 55
            radius: 12
            color: YColors.grayNormal
            border.color: YColors.grayButton
            border.width: 1

            Column {
                id: contentColumn
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.margins: 15
                spacing: 10

                // 头部区域：图标 + 名称 + 开关
                Item {
                    width: parent.width
                    height: 40

                    Item {
                        id: pluginIcon
                        width: 32
                        height: 32
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.left: parent.left

                        Image {
                            id: pluginIconImg
                            anchors.fill: parent
                            source: (model.icon && model.icon !== "") ? model.icon : "qrc:/images/home/home-plugin.png"
                            fillMode: Image.PreserveAspectFit
                            visible: status === Image.Ready
                            clip: true
                        }

                        Rectangle {
                            anchors.fill: parent
                            radius: 8
                            color: "#509DEB"
                            visible: !pluginIconImg.visible
                            YText {
                                anchors.centerIn: parent
                                font.pixelSize: 18
                                color: YColors.white
                                text: model.name.length > 0 ? model.name.charAt(0) : "?"
                            }
                        }
                    }

                    YTextMedium {
                        id: pluginName
                        text: model.name
                        font.pixelSize: 18
                        elide: Text.ElideRight
                        color: YColors.white
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.left: pluginIcon.right
                        anchors.leftMargin: 12
                        anchors.right: enableSwitch.left
                        anchors.rightMargin: 10
                    }

                    YSwitch {
                        id: enableSwitch
                        switchOn: model.enabled
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.right: parent.right

                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                var targetState = !enableSwitch.switchOn
                                if (pluginManagerPage.pluginReady() && pluginManager.setPluginEnabled(model.id, targetState)) {
                                    pluginListModel.setProperty(index, "enabled", targetState)
                                } else {
                                    pluginListModel.setProperty(index, "enabled", !targetState)
                                }
                            }
                        }
                    }
                }

                // 描述区域
                YText {
                    id: pluginDescription
                    width: parent.width
                    text: model.description
                    font.pixelSize: 14
                    color: YColors.grayText
                    wrapMode: Text.Wrap
                    maximumLineCount: 2
                    elide: Text.ElideRight
                }

                // 底部信息与操作（与二代一致：信息行在上、按钮行在下）
                Item {
                    width: parent.width
                    height: 40

                    Row {
                        id: basic_plugin_info
                        anchors.left: parent.left
                        spacing: 10
                        anchors.verticalCenter: parent.verticalCenter
                        YText { text: "v" + model.version; font.pixelSize: 12; color: YColors.grayText }
                        YText { text: "by " + model.author; font.pixelSize: 12; color: YColors.grayText }
                    }

                    Row {
                        anchors.top: basic_plugin_info.bottom
                        anchors.topMargin: 10
                        anchors.right: parent.right
                        spacing: 10

                        YButton {
                            text: "打开"
                            width: 60; height: 28; pixelSize: 12
                            visible: model.enabled && model.loaded
                            onClicked: {
                                if (model.mainQmlUrl && model.mainQmlUrl !== "")
                                    id_pop_container.show(model.mainQmlUrl, { "pluginName": model.name })
                                else
                                    baseSignals.showToast("该插件没有 QML 入口", YColors.yellow)
                            }
                        }

                        YButton {
                            text: "卸载"
                            width: 60; height: 28; pixelSize: 12
                            onClicked: {
                                confirmUninstallDialog.targetName = model.name
                                confirmUninstallDialog.pluginId = model.id
                                confirmUninstallDialog.show()
                            }
                        }
                    }
                }
            }
        }
    }

    function pluginReady() {
        return typeof pluginManager !== "undefined" && pluginManager !== null
    }

    Component.onCompleted: {
        if (!pluginReady()) return
        try { pluginManager.pluginListUpdated.connect(refresh) } catch (e) {}
        refresh()
    }

    function refresh() {
        pluginListModel.clear()
        if (!pluginReady()) return
        var count = pluginManager.getPluginCount()
        for (var i = 0; i < count; i++) {
            var info = pluginManager.getPluginInfo(i)
            if (info) pluginListModel.append(info)
        }
    }

    Connections {
        target: (typeof pluginManager !== 'undefined') ? pluginManager : null
        ignoreUnknownSignals: true
        function onPluginListUpdated() {
            pluginManagerPage.refresh()
        }
        function onPluginStateChanged(pluginName, newState) {
            for (var i = 0; i < pluginListModel.count; i++) {
                if (pluginListModel.get(i).name === pluginName) {
                    pluginListModel.setProperty(i, "enabled", newState)
                    break
                }
            }
        }
    }
}

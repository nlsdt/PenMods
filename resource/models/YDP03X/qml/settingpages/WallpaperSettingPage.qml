import "../common"
import "../components"
import "../i18n"
import QtQuick 2.12
import com.youdao.pen 1.0

YSettingItemPage {
    id: id_setting_item
    objectName: "YPage===WallpaperSettingPage.qml"

    // wallpaperManager 在三代 C++（PenMods3）中并非总是已接线；缺省时整页降级提示。
    readonly property bool _wallpaperAvailable: (typeof wallpaperManager !== 'undefined')

    Flickable {
        anchors.fill: parent
        anchors.leftMargin: 90
        anchors.rightMargin: 16
        contentHeight: id_content.height + 20

        Item {
            id: id_content
            width: parent.width
            height: Math.max(id_wallpaper.height, id_fallback.height)

            Loader {
                id: id_wallpaper
                width: parent.width
                height: id_wallpaper.height
                active: id_setting_item._wallpaperAvailable
                sourceComponent: Component {
                    Column {
                        width: id_wallpaper.width
                        spacing: 8

                        YSettingItemTitle { title: "壁纸模式" }

                        // 模式选择：无壁纸
                        YSettingItemBackground {
                            implicitHeight: 44
                            opacity: id_mouse_none.pressed ? 0.6 : 1.0
                            property bool isSelected: wallpaperManager.wallpaperMode === 0
                            YText {
                                text: "不使用壁纸"
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.left: parent.left; anchors.leftMargin: 20
                                color: parent.isSelected ? YColors.blueText : YColors.white
                            }
                            Rectangle {
                                width: 18; height: 18; radius: 9
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.right: parent.right; anchors.rightMargin: 20
                                border.width: parent.isSelected ? 0 : 2
                                border.color: "#5A6B7D"
                                color: parent.isSelected ? "#2B5278" : "transparent"
                                Rectangle {
                                    width: 8; height: 8; radius: 4
                                    anchors.centerIn: parent
                                    color: parent.parent.isSelected ? YColors.blueText : "transparent"
                                }
                            }
                            YMouseArea {
                                id: id_mouse_none
                                anchors.fill: parent
                                onClicked: { wallpaperManager.wallpaperMode = 0 }
                            }
                        }

                        // 模式选择：单张自定义
                        YSettingItemBackground {
                            implicitHeight: 44
                            opacity: id_mouse_single.pressed ? 0.6 : 1.0
                            property bool isSelected: wallpaperManager.wallpaperMode === 1
                            YText {
                                text: "单张自定义"
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.left: parent.left; anchors.leftMargin: 20
                                color: parent.isSelected ? YColors.blueText : YColors.white
                            }
                            Rectangle {
                                width: 18; height: 18; radius: 9
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.right: parent.right; anchors.rightMargin: 20
                                border.width: parent.isSelected ? 0 : 2
                                border.color: "#5A6B7D"
                                color: parent.isSelected ? "#2B5278" : "transparent"
                                Rectangle {
                                    width: 8; height: 8; radius: 4
                                    anchors.centerIn: parent
                                    color: parent.parent.isSelected ? YColors.blueText : "transparent"
                                }
                            }
                            YMouseArea {
                                id: id_mouse_single
                                anchors.fill: parent
                                onClicked: { wallpaperManager.wallpaperMode = 1 }
                            }
                        }

                        // 模式选择：随机循环
                        YSettingItemBackground {
                            implicitHeight: 44
                            opacity: id_mouse_cycle.pressed ? 0.6 : 1.0
                            property bool isSelected: wallpaperManager.wallpaperMode === 2
                            YText {
                                text: "随机循环"
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.left: parent.left; anchors.leftMargin: 20
                                color: parent.isSelected ? YColors.blueText : YColors.white
                            }
                            Rectangle {
                                width: 18; height: 18; radius: 9
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.right: parent.right; anchors.rightMargin: 20
                                border.width: parent.isSelected ? 0 : 2
                                border.color: "#5A6B7D"
                                color: parent.isSelected ? "#2B5278" : "transparent"
                                Rectangle {
                                    width: 8; height: 8; radius: 4
                                    anchors.centerIn: parent
                                    color: parent.parent.isSelected ? YColors.blueText : "transparent"
                                }
                            }
                            YMouseArea {
                                id: id_mouse_cycle
                                anchors.fill: parent
                                onClicked: { wallpaperManager.wallpaperMode = 2 }
                            }
                        }

                        YSettingItemTitle { title: "当前壁纸"; visible: wallpaperManager.wallpaperMode !== 0 }

                        Loader {
                            width: parent.width; height: 80
                            active: wallpaperManager.currentWallpaper.length > 0 && wallpaperManager.wallpaperMode !== 0
                            sourceComponent: Rectangle {
                                width: parent.width; height: 80; radius: 8
                                color: "#182533"; border.width: 1; border.color: "#2B3A4A"
                                YImage {
                                    anchors.fill: parent; anchors.margins: 4
                                    fillMode: Image.PreserveAspectCrop
                                    source: "file://" + wallpaperManager.currentWallpaper
                                    sourceSize: Qt.size(parent.width, parent.height)
                                }
                            }
                        }

                        YText {
                            width: parent.width; height: 80
                            verticalAlignment: Text.AlignVCenter; horizontalAlignment: Text.AlignHCenter
                            text: "暂无壁纸"; color: YColors.grayText; font.pixelSize: 14
                            visible: wallpaperManager.currentWallpaper.length === 0 && wallpaperManager.wallpaperMode !== 0
                        }

                        // 选择图片（单张模式）
                        Item {
                            width: parent.width
                            height: id_single_section.height
                            visible: wallpaperManager.wallpaperMode === 1
                            Column {
                                id: id_single_section
                                anchors.left: parent.left; anchors.right: parent.right
                                spacing: 8
                                YSettingItemBackground {
                                    implicitHeight: 44
                                    opacity: id_mouse_pick.pressed ? 0.6 : 1.0
                                    YText {
                                        text: "选择图片"
                                        anchors.verticalCenter: parent.verticalCenter
                                        anchors.left: parent.left; anchors.leftMargin: 20
                                    }
                                    YText {
                                        text: "浏览"
                                        anchors.verticalCenter: parent.verticalCenter
                                        anchors.right: parent.right; anchors.rightMargin: 20
                                        color: YColors.grayText; font.pixelSize: 14
                                    }
                                    YMouseArea {
                                        id: id_mouse_pick
                                        anchors.fill: parent
                                        onClicked: { id_setting_item.openFileSelector() }
                                    }
                                }
                                YText {
                                    text: wallpaperManager.customImagePath.length > 0
                                          ? "当前: " + wallpaperManager.customImagePath : "尚未选择图片"
                                    color: YColors.grayText; font.pixelSize: 11
                                    anchors.left: parent.left; anchors.leftMargin: 4
                                    anchors.right: parent.right; wrapMode: Text.Wrap; elide: Text.ElideMiddle
                                }
                            }
                        }

                        // 循环模式：选择文件夹 + 间隔
                        Item {
                            width: parent.width
                            height: id_cycle_section.height
                            visible: wallpaperManager.wallpaperMode === 2
                            Column {
                                id: id_cycle_section
                                anchors.left: parent.left; anchors.right: parent.right
                                spacing: 8
                                YSettingItemBackground {
                                    implicitHeight: 44
                                    opacity: id_mouse_folder.pressed ? 0.6 : 1.0
                                    YText {
                                        text: "选择壁纸文件夹"
                                        anchors.verticalCenter: parent.verticalCenter
                                        anchors.left: parent.left; anchors.leftMargin: 20
                                    }
                                    YText {
                                        text: "浏览"
                                        anchors.verticalCenter: parent.verticalCenter
                                        anchors.right: parent.right; anchors.rightMargin: 20
                                        color: YColors.grayText; font.pixelSize: 14
                                    }
                                    YMouseArea {
                                        id: id_mouse_folder
                                        anchors.fill: parent
                                        onClicked: { id_setting_item.openFileSelector() }
                                    }
                                }
                                YText {
                                    text: wallpaperManager.wallpaperFolder.length > 0
                                          ? "文件夹: " + wallpaperManager.wallpaperFolder : "尚未选择文件夹"
                                    color: YColors.grayText; font.pixelSize: 11
                                    anchors.left: parent.left; anchors.leftMargin: 4
                                    anchors.right: parent.right; wrapMode: Text.Wrap; elide: Text.ElideMiddle
                                }

                                YText {
                                    text: "切换间隔"; color: YColors.grayText; font.pixelSize: 16
                                    anchors.left: parent.left; anchors.leftMargin: 4
                                }

                                Row {
                                    anchors.left: parent.left; anchors.leftMargin: 4
                                    spacing: 8
                                    Repeater {
                                        model: [
                                            { "label": "30 秒", "value": 30 },
                                            { "label": "1 分",  "value": 60 },
                                            { "label": "5 分",  "value": 300 },
                                            { "label": "10 分", "value": 600 },
                                            { "label": "30 分", "value": 1800 }
                                        ]
                                        Rectangle {
                                            width: 48; height: 28; radius: 6
                                            color: wallpaperManager.cycleInterval === modelData.value ? "#2B5278" : "#2C2C2E"
                                            border.width: wallpaperManager.cycleInterval === modelData.value ? 1 : 0
                                            border.color: YColors.blueText
                                            YText {
                                                anchors.centerIn: parent
                                                text: modelData.label
                                                color: wallpaperManager.cycleInterval === modelData.value ? YColors.blueText : "#8A9BAE"
                                                font.pixelSize: 11
                                            }
                                            YMouseArea {
                                                anchors.fill: parent
                                                onClicked: { wallpaperManager.cycleInterval = modelData.value }
                                            }
                                        }
                                    }
                                }
                            }
                        }

                        YSpacingForColumn { implicitHeight: 16 }
                    }
                }
            }

            // 降级提示：C++ 未接线 wallpaperManager
            YText {
                id: id_fallback
                width: parent.width
                height: 80
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
                text: "壁纸功能需要 C++ 侧支持"
                color: YColors.grayText
                font.pixelSize: 16
                visible: !id_setting_item._wallpaperAvailable
            }
        }
    }

    // 文件选择器容器
    Item {
        id: id_selector_container
        anchors.fill: parent
        z: 1000
    }

    function openFileSelector() {
        var component = Qt.createComponent("../audiopages/FileManagerSelector.qml")
        if (component.status === Component.Ready) {
            createSelector(component)
        } else if (component.status === Component.Error) {
            console.error("Failed to load FileManagerSelector:", component.errorString())
        } else {
            component.statusChanged.connect(function() {
                if (component.status === Component.Ready) createSelector(component)
            })
        }
    }

    function createSelector(component) {
        var props = {}
        if (wallpaperManager.wallpaperMode === 1) {
            props.fileExtensions = ["png", "jpg", "jpeg", "bmp"]
        }
        var selector = component.createObject(id_selector_container, props)
        if (!selector) return
        selector.fileSelected.connect(onFileSelected)
        selector.fileSelectionCancelled.connect(function() { selector.destroy() })
        selector.backButtonClicked.connect(function() { selector.destroy() })
        selector.show()
    }

    function onFileSelected(path) {
        if (wallpaperManager.wallpaperMode === 1) {
            wallpaperManager.customImagePath = path
        } else if (wallpaperManager.wallpaperMode === 2) {
            var lastSlash = path.lastIndexOf("/")
            if (lastSlash > 0) wallpaperManager.wallpaperFolder = path.substring(0, lastSlash)
        }
        for (var i = id_selector_container.children.length - 1; i >= 0; i--) {
            try { id_selector_container.children[i].destroy() } catch (e) {}
        }
    }
}

import QtQuick 2.12
import com.youdao.pen 1.0

import BaseQml 1.0
import "./components"
import "./i18n"

YPage {
    id: id_setting_page
    objectName: "YPage===YSettingPage.qml"

    property int currentShowIndex: -1

    function showSettingPage(settingPage) {
        id_pop_container.show(settingPage)
    }

    Item {
        id: id_setting_views
        anchors.fill: parent

        GridView {
            id: id_setting_gridview
            anchors.fill: parent
            anchors.leftMargin: 90
            anchors.rightMargin: 4
            clip: true
            cellWidth: 353
            cellHeight: 86
            model: id_setting_model
            cacheBuffer: 1000
            readonly property bool isMoveToUp: (verticalVelocity > 0)

            delegate: YMouseArea {
                id: id_item_delegate

                width: id_setting_gridview.cellWidth
                height: id_setting_gridview.cellHeight
                objectName: "YSettingPage.qml_delegate_index" + index
                Rectangle {
                    width: id_setting_gridview.cellWidth - 12
                    height: 76
                    color: YColors.grayNormal
                    opacity: parent.pressed ? 0.6 : 1
                    radius: 12

                    YImage {
                        id: id_icon
                        anchors.left: parent.left
                        anchors.leftMargin: 20
                        anchors.verticalCenter: parent.verticalCenter
                        imageName: settingIcon
                        sourceSize: Qt.size(36, 36)
                    }

                    YTextMedium {
                        id: id_label
                        anchors.left: id_icon.right
                        anchors.leftMargin: 16
                        anchors.right: parent.right
                        anchors.rightMargin: 20
                        anchors.verticalCenter: parent.verticalCenter
                        text: {
                            switch (settingIndex) {
                            case YEnum.SettingIndex.Network:
                                return YTranslateText.network
                            case YEnum.SettingIndex.Bluetooth:
                                return YTranslateText.bluetooth
                            case YEnum.SettingIndex.Volume:
                                return YTranslateText.volume
                            case YEnum.SettingIndex.Brightness:
                                return YTranslateText.brightness
                            case YEnum.SettingIndex.Translate:
                                return YTranslateText.translate
                            case YEnum.SettingIndex.Dict:
                                return YTranslateText.dictionary
                            case YEnum.SettingIndex.Homepage:
                            return YTranslateText.customhomepage
                            case YEnum.SettingIndex.Pronunc:
                                return YTranslateText.pronunc
                            case YEnum.SettingIndex.Handedness:
                                return YTranslateText.handedness
                            case YEnum.SettingIndex.Language:
                                return YTranslateText.deviceLanguage
                            case YEnum.SettingIndex.MultiLines:
                                return YTranslateText.multi
                            case YEnum.SettingIndex.Update:
                                return YTranslateText.update
                            case YEnum.SettingIndex.About:
                                return YTranslateText.about
                            case YEnum.SettingIndex.VAS:
                                return YTranslateText.vas
                            case 999:
                                return "PenMods 设置"

                            default:
                                return ""
                            }
                        }
                        elide: YText.ElideRight
                    }
                }

                onClicked: {
                    settingItemClicked(settingIndex)
                }
            }

            header: YSpacing {
                width: id_setting_gridview.width
                implicitHeight: 18
            }

            footer: YSpacing {
                width: id_setting_gridview.width
                implicitHeight: 8
            }
        }
    }

    YVerticalTitleBar {
        id: id_title_bar
        onCallBack: {
            backButtonClicked()
        }

        YButtonBase {
            id: id_portrait_icon_bg
            implicitWidth: 44
            implicitHeight: 44
            mouseAreaMargins: -25
            anchors.left: parent.left
            anchors.leftMargin: 16
            anchors.bottom: parent.bottom
            color: pressed ? "#111216" : YColors.grayNormal
            radius: height/2

            onClicked: {
                if (loginManager.isLogin)
                    logManager.sendHttpLog("action=settings_account_click")
                else
                    logManager.sendHttpLog("action=settings_login_click")
                qmlGlobal.showLoginPage()
            }
        }

        YUserPortrait {
            id: id_portrait_icon
            width: 44
            height: 44
            anchors.centerIn: id_portrait_icon_bg
            sourceSize: Qt.size(44, 44)
            defaultIconSource: "image://icons/portrait.png"
            borderColor: YColors.black
        }
    }

    onBackButtonClicked: {
        id_pop_container.popItemObject = null
    }

    Item {
        id: id_pop_container
        anchors.fill: parent

        property bool parentPopWithChild: false
        property var popItemObject: null
        property int incubatorCreateCount: 0

        signal closeSameItem(string popStackId)

        function updateStackInfo() {
            if (id_pop_container.children.length > 1) {
                const lastChild = id_pop_container.children[id_pop_container.children.length - 2]
                popItemObject = lastChild
            } else {
                popItemObject = null
            }
        }

        function show(settingPage) {
            closeSameItem(settingPage)
            function newComponentInit(incubatorObject) {
                Object.defineProperty(incubatorObject, 'popStackId', {
                                          enumerable: false, configurable: false,
                                          writable: false, value: settingPage
                                      })
                popItemObject = incubatorObject
                qmlGlobal.requestShowPage.connect(function(index, cachePage) {
                    if ((YEnum.PageIndex.Setting !== index)
                            && (typeof incubatorObject.destroy != "undefined")) {
                        updateStackInfo()
                        incubatorObject.destroy()
                        incubatorObject = null
                    }
                })
                incubatorObject.backButtonClicked.connect(function() {
                    if (typeof incubatorObject.destroy != "undefined") {
                        if (id_pop_container.parentPopWithChild) {
                            id_pop_container.parentPopWithChild = false
                            id_setting_page.backButtonClicked()
                        }
                        closeSameItem(incubatorObject.popStackId)
                        updateStackInfo()
                        incubatorObject.destroy()
                        incubatorObject = null
                    }
                })
                id_pop_container.closeSameItem.connect(function(popStackId) {
                    if ((null !== incubatorObject)
                            && (popStackId === incubatorObject.popStackId)
                            && (typeof incubatorObject.destroy != "undefined")) {
                        incubatorObject.destroy()
                        incubatorObject = null
                    }
                })
                systemBase.homeKeyRelease.connect(incubatorObject.destroy)
                systemBase.homeKeyLongPress.connect(incubatorObject.destroy)
                incubatorObject.show()

                if ("settingpages/YSettingUpdate" === settingPage
                        && wifiManager.internetConnect
                        && null !== id_pop_container.popItemObject) {
                    id_pop_container.popItemObject.checkUpdate()
                }
            }

            const newComponent = Qt.createComponent(("./%1.qml").arg(settingPage))
            const incubator = newComponent.incubateObject(id_pop_container)
            if (incubator.status !== Component.Ready) {
                incubator.onStatusChanged = function(status) {
                    if (status === Component.Ready) {
                        if (0 === --incubatorCreateCount) {
                            newComponentInit(incubator.object)
                        } else {
                            incubator.object.destroy()
                        }
                    }
                }
                ++incubatorCreateCount
            } else {
                newComponentInit(incubator.object)
            }
        }
    }

    function settingItemClicked(index, popThisPage = false) {
        id_pop_container.parentPopWithChild = popThisPage
        console.log("YSettingPage.qml===settingItemClicked===index: ", index)
        currentShowIndex = index
        let component = null
        switch (index) {
        case YEnum.SettingIndex.Network:
            logManager.sendHttpLog("action=settings_network_click")
            showSettingPage("settingpages/YSettingWifi")
            break;
        case YEnum.SettingIndex.Bluetooth:
            logManager.sendHttpLog("action=settings_bluetooth_click")
            showSettingPage("settingpages/YSettingBluetooth")
            break;
        case YEnum.SettingIndex.Volume:
            logManager.sendHttpLog("action=settings_sound_click")
            settingManager.updateVolumeAndLcd()
            showSettingPage("settingpages/YSettingVolume")
            break;
        case YEnum.SettingIndex.Brightness:
            logManager.sendHttpLog("action=settings_brightness_click")
            settingManager.updateVolumeAndLcd()
            showSettingPage("settingpages/YSettingBrightness")
            break;
        case YEnum.SettingIndex.Translate:
            logManager.sendHttpLog("action=settings_translate_click")
            showSettingPage("settingpages/YSettingTranslate")
            break;
        case YEnum.SettingIndex.Dict:
            logManager.sendHttpLog("action=settings_dict_click")
            showSettingPage("settingpages/YSettingDict")
            break;
        case YEnum.SettingIndex.Homepage:
            logManager.sendHttpLog("action=settings_homepage_click")
            showSettingPage("settingpages/YSettingHomePage")
            break;
        case YEnum.SettingIndex.Pronunc:
            logManager.sendHttpLog("action=settings_pronounce_click")
            showSettingPage("settingpages/YSettingPronunc")
            break;
        case YEnum.SettingIndex.Handedness:
            logManager.sendHttpLog("action=settings_direction_click")
            showSettingPage("settingpages/YSettingHandedness")
            break;
        case YEnum.SettingIndex.Language:
            logManager.sendHttpLog("action=settings_language_click")
            showSettingPage("settingpages/YSettingLanguage")
            break;
        case YEnum.SettingIndex.MultiLines:
            logManager.sendHttpLog("action=settings_multiline_click")
            showSettingPage("settingpages/YSettingMultiLines")
            break;
        case YEnum.SettingIndex.Update:
            logManager.sendHttpLog("action=settings_update_click")
            showSettingPage("settingpages/YSettingUpdate")
            break;
        case YEnum.SettingIndex.About:
            logManager.sendHttpLog("action=settings_about_click")
            showSettingPage("settingpages/YSettingAbout")
            break;
        case YEnum.SettingIndex.VAS:
            showSettingPage("components/YPepVersionUpdatePage")
            break;
        case 999:
            showSettingPage("settingpages/PenModsSettingPage")
            break;
        }
    }

    ListModel {
        id: id_setting_model

        Component.onCompleted: {
            id_setting_page.refreshSettingModel()
        }
    }

    // 可重建的设置列表模型。PenMods 入口（999）在考试模式（antiEmbs.active）下隐藏。
    function refreshSettingModel() {
        id_setting_model.clear()
        id_setting_model.append({settingIndex: YEnum.SettingIndex.Network,       settingIcon: "settings/ic_network"})
        id_setting_model.append({settingIndex: YEnum.SettingIndex.Bluetooth,     settingIcon: "settings/ic_bluetooth"})
        id_setting_model.append({settingIndex: YEnum.SettingIndex.Volume,        settingIcon: "settings/ic_sounds"})
        id_setting_model.append({settingIndex: YEnum.SettingIndex.Brightness,    settingIcon: "settings/ic_brightness"})
        if (qmlGlobal.checkFeature(YEnum.FEATURE_VERSION_PRO)) {
            id_setting_model.append({settingIndex: YEnum.SettingIndex.Translate, settingIcon: "settings/ic_translate"})
        }
        if (settingManager.isPepVersion) {
            id_setting_model.append({settingIndex: YEnum.SettingIndex.VAS,      settingIcon: "settings/ic_vas"})
        }
        id_setting_model.append({settingIndex: YEnum.SettingIndex.Dict,          settingIcon: "settings/ic_dict"})
        if (!settingManager.isPepVersion) {
            id_setting_model.append({settingIndex: YEnum.SettingIndex.Homepage,       settingIcon: "settings/ic_union"})
        }
        id_setting_model.append({settingIndex: YEnum.SettingIndex.Pronunc,       settingIcon: "settings/ic_pronunc"})
        id_setting_model.append({settingIndex: YEnum.SettingIndex.Handedness,    settingIcon: "settings/ic_handedness"})
        if (!settingManager.isPepVersion) {
            id_setting_model.append({settingIndex: YEnum.SettingIndex.Language,      settingIcon: "settings/ic_language"})
        }
        id_setting_model.append({settingIndex: YEnum.SettingIndex.MultiLines,    settingIcon: "settings/ic_multi"})
        id_setting_model.append({settingIndex: YEnum.SettingIndex.Update,        settingIcon: "settings/ic_update"})
        id_setting_model.append({settingIndex: YEnum.SettingIndex.About,         settingIcon: "settings/ic_about"})
        if (!(typeof fileManager === "object" && fileManager !== null && fileManager.hiddenAll)
                && !(typeof antiEmbs !== 'undefined' && antiEmbs.active)) {
            id_setting_model.append({settingIndex: 999, settingIcon: "settings/ic_about"})
        }
    }

    Connections {
        target: (typeof antiEmbs !== 'undefined') ? antiEmbs : null
        ignoreUnknownSignals: true
        function onActiveChanged() {
            id_setting_page.refreshSettingModel()
        }
    }

    Component.onDestruction: {
        console.log("YSettingPage.qml===Component.onDestruction===called")
    }

    onVisibleChanged: {
        if (visible) {
            qmlGlobal.currentPageIndex = YEnum.PageIndex.Setting
        }
    }
}

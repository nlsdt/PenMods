import QtQuick 2.12
import QtQuick.Window 2.15
import com.youdao.pen 1.0

import BaseQml 1.0
import "./i18n"
import "./settingpages"

YWindow {
    id: id_main_window
    default property alias content: id_inner_item.data

    property bool isVideoPlayerShowing: false
    property bool isUpdateOSShowing: false

    readonly property int battaryPercentage: batteryManager.power
    readonly property bool battaryChanging: batteryManager.charging
    readonly property bool quickSettingOpening: id_quick_setting_layer.isOpening
    readonly property bool isVerifiyFinished: settingManager.isVerified && (qmlGlobal.currentPageIndex !== YEnum.PageIndex.Verify)

    property bool thirdQmlContainerShowing: false

    function closeQuickSetting() {
        if (id_quick_setting_layer.isOpening) {
            id_quick_setting_layer.forceClose()
            return true
        }
        return false
    }

    function openQuickSetting() {
        if (!id_quick_setting_layer.isOpening) {
            id_quick_setting_layer.open()
        }
    }

    onQuickSettingOpeningChanged: {
        qmlGlobal.quickSettingStateChanged(quickSettingOpening)
    }

    signal closeSpeechNeedNetworkDialog()

    function delayInitMainWindow() {
        id_toast_loader.source = "qrc:/qml/common/YToast.qml"
        id_toast_loader.active = true
    }

    Item {
        id: id_mask_source
        anchors.fill: parent

        Item {
            id: id_inner_item
            anchors.fill: parent
        }

        ShaderEffectSource {
            id: id_effect_source
            anchors.fill: parent
            sourceItem: id_inner_item
            sourceRect: Qt.rect(0 , 0, width, height)
            visible: false
        }

        YQuickSettingLayer {
            id: id_quick_setting_layer
            fastBlurTarget: id_effect_source
        }

        YMouseArea {
            id: id_drag_show_quick_setting
            anchors.left: parent.left
            // 只保留屏幕顶部中央约三分之一、较窄的一条作为下拉判定区，
            // 避免与页面顶部的可点按内容冲突。
            anchors.leftMargin: parent.width / 3
            anchors.right: parent.right
            anchors.rightMargin: parent.width / 3
            height: 20
            drag.target: id_quick_setting_layer.dragTarget
            drag.axis: Drag.YAxis
            drag.minimumY: - YBaseEnum.Screen.Height
            drag.maximumY: 0
            enabled: isVerifiyFinished && !isVideoPlayerShowing
                     && !qmlGlobal.qweInputWidgetShowing
                     && !isUpdateOSShowing
            objectName: "YMainWindow.qml_id_drag_show_quick_setting"

            property real pressedY: 0

            onPressed: {
                pressedY = mouseY
                id_check_timer.restart()
            }

            onPositionChanged: {
                id_quick_setting_layer.height = mouseY
            }

            onReleased: {
                doReleased(mouseY)
            }

            onCanceled: {
                doReleased(mouseY)
            }

            YTimer {
                id: id_check_timer
                objectName: "YMainWindow.qml_id_check_timer"
                interval: 500
            }

            function doReleased(positionY) {
                if (id_quick_setting_layer.height > YBaseEnum.Screen.Height * 4 / 5
                        || (id_check_timer.running
                            && (id_quick_setting_layer.height - pressedY > 10))) {
                    id_quick_setting_layer.reopen()
                } else {
                    id_quick_setting_layer.forceClose()
                }
            }
        }
    }

    Connections {
        target: qmlGlobal
        ignoreUnknownSignals: true
        function onRequestSpeechNeedNetWork() {
            function newComponentInit(incubatorObject) {
                incubatorObject.closed.connect(incubatorObject.destroy)
                id_main_window.closeSpeechNeedNetworkDialog.connect(
                            incubatorObject.destroy)
                systemBase.homeKeyPress.connect(incubatorObject.destroy)
                incubatorObject.show()
            }

            const newComponent = Qt.createComponent(
                                   "./components/YSpeechNeedNetworkTip.qml")
            const incubator = newComponent.incubateObject(id_main_window)
            if (incubator.status !== Component.Ready) {
                incubator.onStatusChanged = function(status) {
                    if (status === Component.Ready) {
                        if (0 === --incubatorCreateSpeechNeedNetWorkCount) {
                            // 异步重入只显示最后一个创建的对象
                            newComponentInit(incubator.object)
                        } else {
                            incubator.object.destroy()
                        }
                    }
                }
                ++incubatorCreateSpeechNeedNetWorkCount
            } else {
                newComponentInit(incubator.object)
            }
        }

        function onRequestShowScanGuide() {
            if (null === id_scan_guide_container.scanGuideItem) {
                function newComponentInit(incubatorObject) {
                    if (null === id_scan_guide_container.scanGuideItem) {
                        incubatorObject.callBack.connect(id_scan_guide_container.closeScanGuide)
                        systemBase.homeKeyPress.connect(id_scan_guide_container.closeScanGuide)
                        systemBase.homeKeyLongPress.connect(id_scan_guide_container.closeScanGuide)
                        readingBookManager.noDataAreaDetect.connect(id_scan_guide_container.closeScanGuide)
                        id_scan_words_result_loader.ocrStart.connect(id_scan_guide_container.closeScanGuide)
                        id_scan_guide_container.closeAllScanGuide.connect(incubatorObject.stop)
                        id_scan_guide_container.scanGuideItem = incubatorObject
                    }
                    id_scan_guide_container.showScanGuide()
                }

                const incubator = id_scan_guide_component.incubateObject(id_scan_guide_container)
                if (incubator.status !== Component.Ready) {
                    incubator.onStatusChanged = function(status) {
                        if (status === Component.Ready) {
                            if (0 === --incubatorCreateScanGuideCount) {
                                // 异步重入只显示最后一个创建的对象
                                newComponentInit(incubator.object)
                            } else {
                                incubator.object.destroy()
                            }
                        }
                    }
                    ++incubatorCreateScanGuideCount
                } else {
                    newComponentInit(incubator.object)
                }
            } else {
                id_scan_guide_container.showScanGuide()
            }
        }
        property int incubatorCreateScanGuideCount: 0
        property int incubatorCreateSpeechNeedNetWorkCount: 0

        function onShownavigationTips() {

            function newComponentInit(incubatorObject) {
                incubatorObject.closed.connect(incubatorObject.destroy)
                incubatorObject.show()
            }
            const newComponent = Qt.createComponent(
                                   "./components/YDictNavigationTip.qml")
            const incubator = newComponent.incubateObject(id_main_window)
            if (incubator.status !== Component.Ready) {
                incubator.onStatusChanged = function(status) {
                    if (status === Component.Ready) {
                        if (0 === --incubatorCreatenavigationTipsCount) {
                            // 异步重入只显示最后一个创建的对象
                            newComponentInit(incubator.object)
                        } else {
                            incubator.object.destroy()
                        }
                    }
                }
                ++incubatorCreatenavigationTipsCount
            } else {
                newComponentInit(incubator.object)
            }
        }
        property int incubatorCreatenavigationTipsCount: 0

        function onQuickSettingDragEntry(positionY) {
            id_drag_show_quick_setting.pressedY = positionY
            id_check_timer.restart()
        }

        function onQuickSettingDragExit(positionY) {
            id_drag_show_quick_setting.doReleased(positionY)
        }

        function onQuickSettingDragUpdate(positionY) {
            id_quick_setting_layer.height = positionY
        }

        function onRequestShowUpdateOSPage() {
            const updateOSPage = showPage("YUpdateOSPage")
            isUpdateOSShowing = true
            id_scan_words_result_loader.hidden()
            closeQuickSetting()
            closeAudioPlayer()
            id_video_player.hidden()
            id_globe_audio_player.close()
            if (!id_stack_view.visible) {
                id_stack_view.visible = true
            }
        }
    }

    Connections {
        target: batteryManager
        ignoreUnknownSignals: true
        function onLowPower(power) {
            if (!battaryChanging) {
                function newComponentInit(incubatorObject) {
                    incubatorObject.closed.connect(incubatorObject.destroy)
                    systemBase.homeKeyPress.connect(incubatorObject.destroy)
                    incubatorObject.show()
                }

                const newComponent = Qt.createComponent(
                                       "./components/YBatteryPowerLowTip.qml")
                const incubator = newComponent.incubateObject(
                                    id_main_window, {
                                        "battaryPower": power
                                    })
                if (incubator.status !== Component.Ready) {
                    incubator.onStatusChanged = function(status) {
                        if (status === Component.Ready) {
                            if (0 === --incubatorCreateCount) {
                                // 异步重入只显示最后一个创建的对象
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
        property int incubatorCreateCount: 0
    }

    Connections {
        target: systemBase
        ignoreUnknownSignals: true
        function onPowerKeyLongPress() {
            // main.qml and YVerifyPage.qml share this interface
            function newComponentInit(incubatorObject) {
                incubatorObject.show()
            }
            const newComponent = Qt.createComponent("./YPowerOffPage.qml")
            const incubator = newComponent.incubateObject(id_main_window)
            if (incubator.status !== Component.Ready) {
                incubator.onStatusChanged = function(status) {
                    if (status === Component.Ready) {
                        if (0 === --incubatorCreateCount) {
                            // 异步重入只显示最后一个创建的对象
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
        property int incubatorCreateCount: 0
    }

    Item {
        id: id_scan_guide_container
        anchors.fill: parent
        visible: false
        property var scanGuideItem: null
        signal closeAllScanGuide()
        function closeScanGuide() {
            if (null !== scanGuideItem) {
                visible = false
                scanGuideItem.stop()
                closeAllScanGuide()
            }
        }
        function showScanGuide() {
            if (null !== scanGuideItem) {
                scanGuideItem.play()
                visible = true
            }
        }
    }

    Component {
        id: id_scan_guide_component
        YScanGuidePage {
        }
    }

    PenModsAntiEmbsUnlock {
        anchors.fill: parent
    }

    YLoader {
        id: id_toast_loader
        anchors.fill: parent
    }

    // above is virtual
    YMap {
        id: id_global_map
        Component.onCompleted: {
            YUtils.globalMap = id_global_map
        }
    }

    YMap {
        id: id_stack_map
        Component.onCompleted: {
            YUtils.stackMap = id_stack_map
        }
    }

}

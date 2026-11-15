import QtQuick 2.12
import com.youdao.pen 1.0

import BaseQml 1.0
import "../components"
import "../i18n"

YSettingItemPage {
    id: id_setting_item
    objectName: "YPage===YSettingAbout.qml"
    property int clickCount: 0

    signal showuploaddialog();

    Flickable {
        id: id_setting_item_view
        anchors.fill: parent
        anchors.leftMargin: 90
        anchors.rightMargin: 16
        contentHeight: id_title_container.height + id_column.height

        YSettingItemTitle {
            id: id_title_container
            title: YTranslateText.about

            YClickedCountMouseArea {
                anchors.fill: parent
                onTriggered: {
                    logManager.uploadUserActionLog()
                }
                objectName: "YSettingAbout.qml_uploadUserActionLog"
            }
        }

        Column {
            id: id_column
            anchors.top: id_title_container.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            spacing: 10

            YSettingAboutItem {
                title: YTranslateText.model
                value: settingManager.sysDevName + " " +settingManager.sysRegionInfo;
            }

            YSettingAboutItem {
                title: YTranslateText.version
                value: settingManager.sysVersion
            }

            YSettingAboutClickableItem {
                title: YTranslateText.memoryStorage
                value: settingManager.memoryStorage + "GB"
                imageName: "settings/info_more_arrow"
                onClicked: {
                    settingManager.updateSystemInfo()
                    id_pop_container.show("YSettingStorageInfo")
                }
            }

            YSettingAboutItem {
                title: YTranslateText.sysSn
                value: settingManager.sysSn
            }

            YSettingAboutItem {
                title: YTranslateText.pepVerifyCode
                value: settingManager.pepVerifyCode
                visible: qmlGlobal.skuRegion() === YEnum.SKU_PEP
            }

            YSettingAboutItem {
                title: "ISBN"
                value: "978-7-89518-377-3/G·377"
                visible: qmlGlobal.skuRegion() === YEnum.SKU_PEP
            }

            YSettingAboutItem {
                title: YTranslateText.macAddress
                value: settingManager.sysMac
            }

            YSettingAboutItem {
                visible: !qmlGlobal.checkFeature(YEnum.FEATURE_SKU_KO)
                         && !qmlGlobal.checkFeature(YEnum.FEATURE_SKU_EN)
                title: YTranslateText.serviceHotline
                value: qmlGlobal.checkFeature(YEnum.FEATURE_SKU_TW)
                       ? "0800-000150" : "400-800-4163"
//                MouseArea
//                {
//                    anchors.fill: parent
//                    onClicked:
//                    {
//                       settingManager.docrash()
//                    }
//                }
            }

            YSettingAboutClickableItem {
                title: YTranslateText.certification
                value: ""
                imageName: "settings/info_more_arrow"
                onClicked: {
                    id_pop_container.show("YSettingCertification")
                }
            }
            // //开源软件使用许可
            // YSettingAboutClickableItem {
            //     title: YTranslateText.opensourcelicense
            //     value: ""
            //     imageName: "settings/info_more_arrow"
            //     onClicked: {
            //         id_pop_container.show("YSettingOpenLicense")
            //     }
            // }

            //崩溃上报
            YSettingAboutClickableItem {
                title: YTranslateText.uploadcrash
                value: ""
                imageName: "settings/info_more_arrow"
                onClicked: {
                    if(!uploadcrash.isExitCrashFiles())
                    {
                     baseSignals.showToast(YTranslateText.nocrashupload, YColors.grayNormal);
                     return ;
                    }
                    if(uploadcrash.isThreadRunning())
                    {
                        baseSignals.showToast(YTranslateText.crashuploading, YColors.grayNormal);
                        return ;
                    }

                    id_pop_container.show("YSettingUploadCrase");

                }
            }
            YSettingAboutClickableItem {
                title: YTranslateText.resetChoice
                value: ""
                imageName: "settings/info_more_arrow"
                onClicked: {
                    id_setting_item.showPage("YSettingReset", true, "reset_page")
                }
            }

            YSpacingForColumn {
                implicitHeight: 20
            }
        }
    }





    // PenMods 锁屏门控：needPasswd && locker.enabled && 场景开启 时先要求输入密码。
    function showPage(page, needPasswd, scene) {
        if (needPasswd && (typeof locker !== 'undefined' && locker !== null) && locker.enabled
                && !(scene && !locker.getScene(scene))) {
            requestKeyboard(page)
            return null
        }
        id_pop_container.show(page)
    }

    function requestKeyboard(page) {
        let component = qmlCreateComponent("input/YInputPage")
        if (Component.Ready === component.status) {
            var incubator = component.incubateObject(id_page_pop_helper.containerItem)
            if (incubator.status !== Component.Ready) {
                incubator.onStatusChanged = function(status) {
                    if (status === Component.Ready) {
                        id_page_pop_helper.inputPageCreated(incubator.object, page)
                    }
                }
            } else {
                id_page_pop_helper.inputPageCreated(incubator.object, page)
            }
        }
    }

    YPagePopHelper {
        id: id_page_pop_helper
        isShowing: YInputProperty.inputPageShowing
        objectName: "from_YSettingAbout.qml"
        function inputPageCreated(keyboardPage, page) {
            keyboardPage.backButtonClicked.connect(function () {
                YInputProperty.inputPageShowing = false
                keyboardPage.todoDestroy()
                keyboardPage = null
            })
            keyboardPage.inputFinished.connect(function (content) {
                if (content === locker.password) {
                    id_setting_item.showPage(page)
                } else {
                    baseSignals.showToast("密码错误，请重试", YColors.yellow)
                    requestKeyboard(page)
                }
            })
            keyboardPage.placeHolderText = "请输入密码..."
            keyboardPage.show()
            YInputProperty.inputPageShowing = true
        }
    }

    Item {
        id: id_pop_container
        anchors.fill: parent
        property int incubatorCreateCount: 0

        signal closeSameItem(string popStackId)

        function show(aboutPage) {
            closeSameItem(aboutPage)
            function newComponentInit(incubatorObject) {
                Object.defineProperty(incubatorObject, 'popStackId', {
                                          enumerable: false, configurable: false,
                                          writable: false, value: aboutPage
                                      })
                qmlGlobal.requestShowPage.connect(function(index, cachePage) {
                    if ((YEnum.PageIndex.Setting !== index)
                            && (typeof incubatorObject.destroy != "undefined")) {
                        incubatorObject.destroy()
                        incubatorObject = null
                    }
                })
                incubatorObject.backButtonClicked.connect(function() {
                    if (typeof incubatorObject.destroy != "undefined") {
                        closeSameItem(incubatorObject.popStackId)
                        incubatorObject.destroy()
                        incubatorObject = null
                    }
                })
                id_pop_container.closeSameItem.connect(function(popStackId) {
                    if ((popStackId === incubatorObject.popStackId)
                            && (typeof incubatorObject.destroy != "undefined")) {
                        incubatorObject.destroy()
                        incubatorObject = null
                    }
                })
                systemBase.homeKeyRelease.connect(incubatorObject.destroy)
                systemBase.homeKeyLongPress.connect(incubatorObject.destroy)
                incubatorObject.show()
            }

            const newComponent = Qt.createComponent(("./%1.qml").arg(aboutPage))
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
}

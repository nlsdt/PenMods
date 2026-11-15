import QtQuick 2.12
import com.youdao.pen 1.0
import BaseQml 1.0
import "./qml/components"
import "./qml/settingpages"
import "./qml/i18n"
import "./qml"

YMainWindow {
    id: id_verify_page

    property int verifyState: YEnum.Verify_UILanguageSelect
    property int lastVerifyState: YEnum.Verify_UILanguageSelect
    property bool checkWifiState: true
    property bool isPepUpdateDoing: false // pep升级过程中断网后，记录下升级状态，以便再次进入时直接展示升级进度
    property bool enablecheck : false

    function showPageByVerfyState(state) {
        console.log("YVerifyPage.qml showPageByVerfyState === verifyState", state)
        if (state > YEnum.Verify_ConfigWifi) {
            checkWifiState = false
        }
        if (id_verify_page.verifyState == YEnum.Verify_UILanguageSelect
                || id_verify_page.verifyState == YEnum.Verify_NetworkFailed
                || id_verify_page.verifyState == YEnum.Verify_VerifyFailed) {
            id_verify_page.lastVerifyState = id_verify_page.verifyState
        } else if (state === YEnum.Verify_ConfigWifi) {
            id_verify_page.lastVerifyState = qmlGlobal.skuRegion() === YEnum.SKU_PEP ? YEnum.Verify_ConfigWifi : YEnum.Verify_UILanguageSelect

            checkWifiState = true
        }
        if (state === YEnum.Verify_Login) {
            id_verify_page.lastVerifyState = YEnum.Verify_ConfigWifi
        }
        id_verify_page.verifyState = state
    }

    function startWifiConfig() {
        if (!wifiManager.onoff) {
            showPageByVerfyState(YEnum.Verify_WaitQrWifiConfig)
            wifiManager.turnOn()
        }
        else {
            showPageByVerfyState(YEnum.Verify_ConfigWifi)
        }
    }

    YBackgroundIgnoreMouseEvent {
        anchors.fill: parent
    }

    YLoader {
        id: id_verify_content_loader
        width: id_verify_page.width
        height: id_verify_page.height
        active: true
        sourceComponent: {

            switch (id_verify_page.verifyState) {
            case YEnum.Verify_WaitQrWifiConfig:
            case YEnum.Verify_Verifying:
                return id_waiting_text_component
            case YEnum.Verify_ConfigWifi:
                return id_config_wifi_component
            case YEnum.Verify_Login:
                return id_login_component
            case YEnum.Verify_NetworkFailed:
                return id_network_error_component
            case YEnum.Verify_VerifyFailed:
                return id_verify_faile_component
            case YEnum.Verify_VerifySuccess:
                return id_introduction_component
            case YEnum.Verify_PEPUpdate:
                return id_pepupdate_component
            case YEnum.Verify_UILanguageSelect:
            default:
                return id_language_select_component
            }
        }
        onSourceComponentChanged: {
            console.log("YVerifyPage.qml === id_verify_content_loader.onSourceComponentChanged: ", id_verify_page.verifyState)
            if (id_verify_page.verifyState === YEnum.Verify_PEPUpdate && isPepUpdateDoing) {
                item.updateNow() // pep升级过程中断网后，记录下升级状态，以便再次进入时直接展示升级进度
            }
        }
    }

    YStackView {
        id: id_stack_view
        onCurrentPopIdValidChanged: {
            if (!currentPopIdValid) {
                qmlGlobal.currentPageIndex = YEnum.PageIndex.NonePage
            }
        }
    }

    YPopLayer {
        id: id_page_pop_helper
    }

    Component {
        id: id_pepupdate_component

        YPepVersionUpdatePage {
            width: id_verify_page.width
            height: id_verify_page.height
            visible: true

            onBackButtonClicked: {
                showPageByVerfyState(YEnum.Verify_VerifySuccess)
            }
            onPepVerifyUpdateDone: {
                if (pepNeedVerifyUpdate) {
                    verifyManager.openMainPage()
                }
                else {
                    showPageByVerfyState(YEnum.Verify_VerifySuccess)
                }
            }

            onConfigNetwork: {
                isPepUpdateDoing = true // pep升级过程中断网后，记录下升级状态，以便再次进入时直接展示升级进度
                startWifiConfig()
                id_verify_page.lastVerifyState = YEnum.Verify_ConfigWifi
            }
        }
    }

    Component {
        id: id_language_select_component

        Item {
            width: id_verify_page.width
            height: id_verify_page.height

            GridView {
                id: id_language_gridview
                anchors.fill: parent
                anchors.leftMargin: 8
                anchors.rightMargin: 8
                clip: true
                cellWidth: 392
                cellHeight: 102
                model: id_language_model
                opacity: 1
                cacheBuffer: 600

                delegate: YMouseArea {
                    id: id_language_item_delegate
                    width: id_language_gridview.cellWidth
                    height: id_language_gridview.cellHeight
                    objectName: "YVerifyPage.qml_language_delegate_" + languageName

                    Rectangle {
                        width: id_language_gridview.cellWidth - 16
                        height: id_language_gridview.cellHeight - 12
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.verticalCenter: parent.verticalCenter
                        color: YColors.grayNormal
                        opacity: parent.pressed ? 0.8 : 1
                        radius: height * 0.5

                        YTextMedium {
                            id: id_label
                            anchors.fill: parent
                            horizontalAlignment: YTextMedium.AlignHCenter
                            verticalAlignment: YTextMedium.AlignVCenter
                            text: {
                                switch (languageEnum) {
                                case YEnum.ZH_CN:
                                    return YTranslateText.languageZhCN
                                //case YEnum.ZH_TW:
                                //    return YTranslateText.languageZhTW
                                //case YEnum.JA_JP:
                                //    return YTranslateText.languageJaJP
                                //case YEnum.KO_KR:
                                //    return YTranslateText.languageKoKR
                                case YEnum.EN_US:
                                default:
                                    return YTranslateText.languageEnUS
                                }
                            }

                            font.family: {
                                switch(languageEnum) {
                                case YEnum.ZH_CN:
                                    return fontManager.fontFamilyZhCn
                                case YEnum.EN_US:
                                default:
                                    return fontManager.fontFamilyEnUs
                                }
                            }
                        }
                    }

                    onClicked: {
                        console.log("YVerifyPage.qml === id_language_select_component.language.onClicked, wifi onoff = ", wifiManager.onoff)
                        settingManager.uiLanguage = languageEnum
                        qmlTranslator.loadLanguage(languageEnum)
                        if (!wifiManager.onoff) {
                            showPageByVerfyState(YEnum.Verify_WaitQrWifiConfig)
                            wifiManager.turnOn()
                        } else if (wifiManager.internetConnect && qmlGlobal.skuRegion() != YEnum.SKU_PEP) {
                            showPageByVerfyState(YEnum.Verify_Login)
                        } else {
                            showPageByVerfyState(YEnum.Verify_ConfigWifi)
                        }
                    }
                }

                header: Item {
                    id: id_language_title_bar
                    width: id_language_gridview.width
                    implicitHeight: 110

                    property int clickCount: 0

                    YTextMedium {
                        id: id_language_title_text
                        anchors.fill: parent
                        verticalAlignment: YTextMedium.AlignVCenter
                        horizontalAlignment: YTextMedium.AlignHCenter
                        text: YTranslateText.pleaseSelectDeviceLanguage
                    }

                    YClickedCountMouseArea {
                        anchors.fill: parent
                        onTriggered: {
                            id_page_pop_helper.show("settingpages/YSettingAbout")
                        }
                        objectName: "YVerifyPage.qml_createAndShowAboutPage"
                    }
                }
            }

            ListModel {
                id: id_language_model

                ListElement {
                    languageName: "Ch"
                    languageEnum: YEnum.ZH_CN
                }

                //ListElement {
                //    languageName: "Cht"
                //    languageEnum: YEnum.ZH_TW
                //}

                ListElement {
                    languageName: "En"
                    languageEnum: YEnum.EN_US
                }

                //ListElement {
                //    languageName: "Ja"
                //    languageEnum: YEnum.JA_JP
                //}

                //ListElement {
                //    languageName: "Ko"
                //    languageEnum: YEnum.KO_KR
                //}
            }
        }
    }

    Component {
        id: id_waiting_text_component

        Item {
            width: id_verify_page.width
            height: id_verify_page.height

            YTextMedium {
                anchors.centerIn: parent
                text: {
                    switch (id_verify_page.verifyState) {
                    case YEnum.Verify_WaitQrWifiConfig:
                        return YTranslateText.openingWifi
                    case YEnum.Verify_VerifySuccess:
                        return YTranslateText.verifySuccess
                    case YEnum.Verify_Verifying:
                    default:
                        return YTranslateText.verifying
                    }
                }
            }
        }
    }

    Component {
        id: id_login_component

        YBackButtonPage {
            visible: true
            YLoginPageScanQrcodeLoader {
                id: id_not_login_loader
                visible: true
                onRequestLoginPageScanQrcodeLoginTip: {
                    id_login_page_scan_qrcode_login_tip.show()
                }
                onQrCodeChanged:
                {
                   if(qrCode.length > 0)
                       enablecheck = true ;
                }
            }
            YLoginPageScanQrcodeLoginTip {
                id: id_login_page_scan_qrcode_login_tip
            }
            onBackButtonClicked: {
                console.log("YVerifyPage.qml === id_login_component.onBackButtonClicked")
                console.log("Test1---",id_not_login_loader.qrCode.length)
                showPageByVerfyState(id_verify_page.lastVerifyState)
                if(!enablecheck)
                {
                    checkWifiState = false
                    id_deley_check_timer.start()
                }

            }
        }

    }

    YTimer {
        id: id_deley_check_timer
         interval: 8000
         onTriggered: {
           checkWifiState = true

         }
    }
    Component {
        id: id_network_error_component

        Item {
            width: id_verify_page.width
            height: id_verify_page.height

            Column {
                width: parent.width
                spacing: 0

                YSpacingForColumn {
                    implicitHeight: 50
                }

                YTextMedium {
                    width: parent.width
                    height: 34
                    horizontalAlignment: YTextMedium.AlignHCenter
                    verticalAlignment: YTextMedium.AlignVCenter
                    text: YTranslateText.verifyFaildForNetwork
                }

                YSpacingForColumn {
                    implicitHeight: 8
                }

                YTextBase {
                    width: parent.width
                    height: 32
                    horizontalAlignment: YTextMedium.AlignHCenter
                    verticalAlignment: YTextMedium.AlignVCenter
                    color: YColors.grayText
                    font.pixelSize: 26
                    text: YTranslateText.customerServiceHotline
                }

                YSpacingForColumn {
                    implicitHeight: 20
                }

                Row {
                    width: parent.width
                    height: 80

                    YSpacing {
                        anchors.top: parent.top
                        anchors.bottom: parent.bottom
                        implicitWidth: 112
                    }

                    YButton {
                        width: 280
                        height: parent.height
                        color: YColors.grayNormal
                        text: YTranslateText.reVerify
                        onClicked: {
                            console.log("YVerifyPage.qml === id_network_error_component.reverify.onClicked")
                            showPageByVerfyState(YEnum.Verify_Verifying)
                            verifyManager.startVerify()
                        }
                    }

                    YSpacing {
                        anchors.top: parent.top
                        anchors.bottom: parent.bottom
                        implicitWidth: 16
                    }

                    YButton {
                        width: 280
                        height: parent.height
                        color: YColors.red
                        text: YTranslateText.switchNetwork
                        onClicked: {
                            console.log("YVerifyPage.qml === id_network_error_component.switchwifi.onClicked")
                            startWifiConfig()
                        }
                    }
                }
            }
        }
    }

    Component {
        id: id_verify_faile_component

        Item {
            width: id_verify_page.width
            height: id_verify_page.height

            Column {
                width: parent.width
                spacing: 0

                YSpacingForColumn {
                    implicitHeight: 50
                }

                YTextMedium {
                    width: parent.width
                    height: 34
                    horizontalAlignment: YTextMedium.AlignHCenter
                    verticalAlignment: YTextMedium.AlignVCenter
                    text: YTranslateText.verifyFaild
                }

                YSpacingForColumn {
                    implicitHeight: 8
                }

                YTextBase {
                    width: parent.width
                    height: 32
                    horizontalAlignment: YTextMedium.AlignHCenter
                    verticalAlignment: YTextMedium.AlignVCenter
                    color: YColors.grayText
                    font.pixelSize: 26
                    text: YTranslateText.customerServiceHotline
                }

                YSpacingForColumn {
                    implicitHeight: 20
                }

                YButton {
                    width: 280
                    height: 80
                    anchors.horizontalCenter: parent.horizontalCenter
                    color: YColors.red
                    text: YTranslateText.reVerify
                    visible: qmlGlobal.skuRegion() !== YEnum.SKU_PEP
                    onClicked: {
                        console.log("YVerifyPage.qml === id_verify_faile_component.reverify.onClicked")
                        showPageByVerfyState(YEnum.Verify_Verifying)
                        verifyManager.startVerify()
                    }
                }

                Row {
                    width: parent.width
                    height: 80
                    visible: qmlGlobal.skuRegion() === YEnum.SKU_PEP

                    YSpacing {
                        anchors.top: parent.top
                        anchors.bottom: parent.bottom
                        implicitWidth: 112
                    }

                    YButton {
                        width: 280
                        height: parent.height
                        color: YColors.red
                        text: YTranslateText.reVerify
                        onClicked: {
                            console.log("YVerifyPage.qml === id_verify_faile_component.reverify.onClicked")
                            showPageByVerfyState(YEnum.Verify_Verifying)
                            verifyManager.startVerify()
                        }
                    }

                    YSpacing {
                        anchors.top: parent.top
                        anchors.bottom: parent.bottom
                        implicitWidth: 16
                    }

                    YButton {
                        width: 280
                        height: parent.height
                        color: YColors.grayNormal
                        text: YTranslateText.switchNetwork
                        onClicked: {
                            console.log("YVerifyPage.qml === id_verify_faile_component.switchwifi.onClicked")
                            startWifiConfig()
                        }
                    }
                }
            }
        }
    }

    Component {
        id: id_config_wifi_component

        YSettingWifi {
            id: id_setting_wifi_view
            width: id_verify_page.width
            height: id_verify_page.height
            visible: true
            defaultTitleBar.backButtonItem.visible: settingManager.pepNeedVerifyUpdate || id_verify_page.lastVerifyState !== id_verify_page.verifyState

            onBackButtonClicked: {
                if (settingManager.pepNeedVerifyUpdate) {
                    settingManager.pepNeedVerifyUpdate = false
                    verifyManager.openMainPage()
                    return
                }

                showPageByVerfyState(id_verify_page.lastVerifyState)
            }

            YTimer {
                id: id_check_wifi_state_timer
                interval: 500
                repeat: true
                running: checkWifiState
                onTriggered: {
                    if (wifiManager.internetConnect) {
                        if (qmlGlobal.skuRegion() == YEnum.SKU_PEP) {
                            showPageByVerfyState(YEnum.Verify_Verifying)
                            verifyManager.startVerify()
                        }
                        else {
                            id_check_wifi_state_timer.stop()
                            showPageByVerfyState(YEnum.Verify_Login)
                        }
                    }
                }
            }

            Component.onCompleted: {
                if (checkWifiState) {
                    id_check_wifi_state_timer.start()
                }
            }
        }
    }
    
    Component {
        id: id_introduction_component

        YImage {
            id: id_introduction_item
            width: id_verify_page.width
            height: id_verify_page.height
            property int intrImageIndex: 1
            imageName: {
                if (qmlGlobal.skuRegion() === YEnum.SKU_PEP && settingManager.isPepVersion) {
                    return "introduction/introduction" + intrImageIndex + "-pep"
                } else if (settingManager.uiLanguage === YEnum.EN_US) {
                    return "introduction/introduction" + intrImageIndex + "-en"
                }
                return "introduction/introduction" + intrImageIndex
            }

            MouseArea {
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right
                height: parent.height/2
                onClicked: {
                    if (mouseY <= height) {
                        if (mouseX <= width/3) {
                            if (id_introduction_item.intrImageIndex > 1) {
                                id_introduction_item.intrImageIndex -= 1
                            }
                        } else if (mouseX >= width*2/3) {
                            if (id_introduction_item.intrImageIndex < 4) {
                                id_introduction_item.intrImageIndex += 1
                            } else {
                                settingManager.isVerified = true
                                verifyManager.openMainPage()
                            }
                        }
                    }


                }
            }
        }
    }

    Connections {
        target: verifyManager
        ignoreUnknownSignals: true
        function onVerifyStateChanged(state) {
            console.log("YVerifyPage.qml === verifyManager.onVerifyStateChanged state: ", state)
            if (state === YEnum.Verify_VerifySuccess) { // 请求服务器激活后，则认为已经激活，无需再次请求服务器api
                settingManager.isVerified = true
            }

            if (state === YEnum.Verify_VerifySuccess && qmlGlobal.skuRegion() === YEnum.SKU_PEP) {
                showPageByVerfyState(YEnum.Verify_PEPUpdate)
            } else {
                showPageByVerfyState(state)
            }
        }
    }

    Connections {
        target: wifiManager
        ignoreUnknownSignals: true
        enabled: id_verify_page.verifyState !== YEnum.Verify_UILanguageSelect
        function onOnoffChanged() {
            if (wifiManager.onoff) {
                showPageByVerfyState(YEnum.Verify_ConfigWifi)
            }
        }
        function onConnectFinished(ssid, bSuc) {
            console.log("YVerifyPage.qml wifiManager.onWifiConnectFinished === ", bSuc)
            if (bSuc) {
                if (qmlGlobal.skuRegion() === YEnum.SKU_PEP)  {
                    showPageByVerfyState(YEnum.Verify_Verifying)
                    verifyManager.startVerify()
                } else {
                    showPageByVerfyState(YEnum.Verify_Login)
                }
            }
        }
    }

    Connections {
        target: loginManager
        ignoreUnknownSignals: true
        function onStatusChange(event, bSuc) {
            console.warn("YVerifyPage.qml===LoginEvent: ", event, " bSuc: ", bSuc)
            switch (event) {
            case YEnum.Login:
                if (bSuc) {
                    showPageByVerfyState(YEnum.Verify_Verifying)
                    verifyManager.startVerify()
                } else {
                    baseSignals.showToast(YTranslateText.loginFaildPleaseCheckNetwork, YColors.grayNormal)
                }
                break
            }
        }
    }

    Component.onCompleted: {
        console.log("YVerifyPage.qml===Component.onCompleted")
        qmlGlobal.currentPageIndex = YEnum.PageIndex.Verify
        if (qmlGlobal.skuRegion() === YEnum.SKU_PEP) {
            startWifiConfig()
            id_verify_page.lastVerifyState = YEnum.Verify_ConfigWifi
        }
        delayInitMainWindow()
    }

    Component.onDestruction: {
        soundCenter.suspend()
    }
}


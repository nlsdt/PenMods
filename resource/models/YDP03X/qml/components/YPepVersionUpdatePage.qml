import QtQuick 2.12
import com.youdao.pen 1.0

import BaseQml 1.0
import "../i18n"

YPage {
    id: id_pep_version_update_page
    objectName: "YPepVersionUpdatePage.qml"

    readonly property alias defaultTitleBar: id_title_bar

    property bool updateDoing: false
    property bool isNeedShowDeclaimerTip: false
    readonly property int updateSeconds: 8 * 60 + Math.floor(Math.random() * 120) //升级基准时长

    function updateNow() {
        if (qmlGlobal.currentPageIndex === YEnum.PageIndex.Verify) {
            isNeedShowDeclaimerTip = false
            updateDoing = true
        }
        else {

            if (!wifiManager.internetConnect) {
                id_update_need_network_loader.setActive()
            }
            else
            {
                systemBase.startPepVerifyUpdate()
            }


        }
    }

    function refuseUpdate() {
        let pepNeedVerifyUpdate = settingManager.pepNeedVerifyUpdate
        settingManager.pepNeedVerifyUpdate = false
        isNeedShowDeclaimerTip = false
        updateDoing = false

        if (pepNeedVerifyUpdate) {
            pepVerifyUpdateDone(pepNeedVerifyUpdate)
        } else {
            backButtonClicked()
        }
    }

    signal pepVerifyUpdateDone(bool pepNeedVerifyUpdate)
    signal configNetwork()

    YVerticalTitleBar {
        id: id_title_bar
        visible: !updateDoing
        onCallBack: {
            refuseUpdate()
        }
        objectName: "YBackButtonPage.qml_" + id_pep_version_update_page.objectName
    }

    YIconButton {
        id: id_close_button
        anchors.top: parent.top
        anchors.topMargin: 18
        anchors.left: parent.left
        anchors.leftMargin: 16
        implicitWidth: 44
        implicitHeight: 44
        radius: height/2
        color: YColors.grayNormal
        mouseAreaMargins: -22
        imageName: "commons/close"
        visible: updateDoing
        onClicked: {
            refuseUpdate()
        }
    }

    Item {
        id: id_vaule_added_service
        anchors.fill: parent
        anchors.leftMargin: 90
        anchors.rightMargin: 90
        visible: !updateDoing && !isNeedShowDeclaimerTip
        Column {
            width: parent.width

            YSpacingForColumn {
                implicitHeight: 30
            }

            YText {
                id: id_title_text
                width: parent.width
                font.pixelSize: 28
                font.weight: Font.Medium
                font.family: fontManager.fontFamilyZhCn
                lineHeightMode: Text.FixedHeight
                lineHeight: 34
                horizontalAlignment: YText.AlignHCenter
                verticalAlignment: YText.AlignVCenter
                wrapMode: YText.Wrap
                text: YTranslateText.pepVersionUpdateTitle
            }

            YSpacingForColumn {
                implicitHeight: 8
            }

            YText {
                id: id_tip_text
                width: parent.width
                font.pixelSize: 28
                font.weight: Font.Medium
                font.family: fontManager.fontFamilyZhCn
                lineHeightMode: Text.FixedHeight
                lineHeight: 34
                horizontalAlignment: YText.AlignHCenter
                verticalAlignment: YText.AlignVCenter
                wrapMode: YText.Wrap
                color: YColors.grayText
                text: YTranslateText.pepVersionUpdateTip
            }

            YSpacingForColumn {
                implicitHeight: 10
            }

            Row {
                spacing: 16
                height: 80
                anchors.horizontalCenter: parent.horizontalCenter

                YButton {
                    id: id_button_cancel
                    implicitWidth: 240
                    color: YColors.grayNormal
                    textFamily: fontManager.fontFamilyZhCn
                    text: YTranslateText.pepVersionUpdateNotyet
                    onClicked: {
                        refuseUpdate()
                    }
                }

                YButton {
                    id: id_button_confirm
                    implicitWidth: 240
                    color: YColors.red
                    textFamily: fontManager.fontFamilyZhCn
                    text: YTranslateText.pepVersionUpdateNow
                    onClicked: {
                        isNeedShowDeclaimerTip = true
                    }
                }

            }

        }
    }

    Item {
        id: id_disclaimer_item
        anchors.fill: parent
        anchors.leftMargin: 90
        anchors.right: parent.right
        anchors.rightMargin: 90
        visible: !updateDoing && isNeedShowDeclaimerTip

        Flickable {
            anchors.fill: parent
            contentHeight: id_disclaimer_item_column.height
            Column {
                id: id_disclaimer_item_column
                width: parent.width

                YSpacingForColumn {
                    implicitHeight: 30
                }

                YText {
                    width: parent.width
                    font.pixelSize: 28
                    font.weight: Font.Medium
                    font.family: fontManager.fontFamilyZhCn
                    lineHeightMode: Text.FixedHeight
                    lineHeight: 34
                    horizontalAlignment: YText.AlignHCenter
                    verticalAlignment: YText.AlignVCenter
                    wrapMode: YText.Wrap
                    text: YTranslateText.pepVersionDisclaimerTitle
                }

                YSpacingForColumn {
                    implicitHeight: 8
                }

                YText {
                    width: parent.width
                    font.pixelSize: 28
                    font.weight: Font.Medium
                    font.family: fontManager.fontFamilyZhCn
                    lineHeightMode: Text.FixedHeight
                    lineHeight: 34
                    horizontalAlignment: YText.AlignHCenter
                    verticalAlignment: YText.AlignVCenter
                    textFormat: YText.RichText
                    wrapMode: YText.Wrap
                    color: YColors.grayText
                    text:
                    {
                        if(settingManager.devCompanyId() === 1)
                        {
                            return    YTranslateText.newpepVersionDisclaimerTip
                        }
                        else{
                            return YTranslateText.pepVersionDisclaimerTip
                        }

                    }
                }
                YSpacingForColumn {
                    implicitHeight: 10
                }

                Row {
                    spacing: 16
                    height: 80
                    anchors.horizontalCenter: parent.horizontalCenter

                    YButton {
                        implicitWidth: 240
                        color: YColors.grayNormal
                        textFamily: fontManager.fontFamilyZhCn
                        text: YTranslateText.pepVersionRefuse
                        onClicked: {
                            refuseUpdate()
                        }
                    }

                    YButton {
                        implicitWidth: 240
                        color: YColors.red
                        textFamily: fontManager.fontFamilyZhCn
                        text: YTranslateText.pepVersionAccept
                        onClicked: {
                            updateNow()
                        }
                    }

                }

            }
        }
    }


    Column {
        visible: updateDoing

        anchors.left: parent.left
        anchors.right: parent.right
        spacing: 0

        YSpacingForColumn {
            implicitHeight: 65
        }

        YText {
            anchors.horizontalCenter: parent.horizontalCenter
            font.pixelSize: 28
            font.family: fontManager.fontFamilyZhCn
            lineHeightMode: Text.FixedHeight
            lineHeight: 37
            text: "%1%".arg(Math.floor((id_progress_foredground_rect.width / id_progress_background_rect.width) * 100))
        }

        YSpacingForColumn {
            implicitHeight: 10
        }

        Rectangle {
            id: id_progress_background_rect
            anchors.horizontalCenter: parent.horizontalCenter
            width: 400
            height: 10
            radius: height / 2
            color: YColors.grayNormal

            Rectangle {
                id: id_progress_foredground_rect
                width: parent.width
                height: 10
                radius: height / 2
                color: YColors.white
            }
        }

        YSpacingForColumn {
            implicitHeight: 33
        }

        YText {
            id: id_update_doing_tip_text
            anchors.horizontalCenter: parent.horizontalCenter
            width: 520
            font.pixelSize: 28
            font.family: fontManager.fontFamilyZhCn
            lineHeightMode: Text.FixedHeight
            lineHeight: 34
            horizontalAlignment: YText.AlignHCenter
            verticalAlignment: YText.AlignVCenter
            wrapMode: YText.Wrap
            color: YColors.grayText
            text: YTranslateText.pepVersionUpdateDoing
        }
    }

    YTimer {
        id: id_network_check_timer
        interval: 5000
        running: updateDoing
        repeat: true
        onTriggered: {
            console.log("YPepVersionUpdatePage.qml===network", wifiManager.internetConnect)
            if (!wifiManager.internetConnect) {
                id_network_check_timer.stop()
                id_pep_update_animation.stop()
                id_update_need_network_loader.setActive()
            }
        }

        objectName: "YPepVersionUpdatePage.qml_id_network_check_timer"
    }

    YLoader {
        id: id_update_need_network_loader
        anchors.fill: parent
        sourceComponent: YOneButtonDialog {
            tipItem.text: YTranslateText.pepVersionNeedNet
            buttonItem.text: YTranslateText.configWifi
            onClicked: {
                qmlGlobal.requestSettingPage(YEnum.SettingIndex.Network);
                id_update_need_network_loader.setInactive()
            }
            onClosed: {
                id_update_need_network_loader.setInactive()
                refuseUpdate()
            }
        }
        onLoaded: {
            item.show()
        }
    }

    NumberAnimation {
        id: id_pep_update_animation
        target: id_progress_foredground_rect
        property: "width"
        duration: updateSeconds * 1000
        easing.type: Easing.InOutQuad
        from: 0
        to: id_progress_background_rect.width
        running: updateDoing
        onFinished: {
            console.log("YPepVersionUpdatePage.qml===update finished")
            id_network_check_timer.stop()
            settingManager.isPepVersion = false
            settingManager.topShowDict = YEnum.DtSimple
            settingManager.topShowChDict = YEnum.DtChEnglish
            pepVerifyUpdateDone(settingManager.pepNeedVerifyUpdate)
        }
    }

    onVisibleChanged: {
        updateDoing = settingManager.pepNeedVerifyUpdate
    }
}


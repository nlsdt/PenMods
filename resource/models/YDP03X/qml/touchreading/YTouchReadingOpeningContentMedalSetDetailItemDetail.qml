import QtQuick 2.12

import BaseQml 1.0
import "../components"
import "../i18n"

YTouchReadingPageOpeningItemBase {
    id: id_opening_item
    anchors.fill: parent
    color: "#1F2261"

    property string onlyId: ""
    property string title: ""
    property alias instructions: id_instructions.text
    property bool isLighted: false

    function initData(paramsObj) {
        isLighted = paramsObj.isLighted
        title = paramsObj.medalTitle
        id_medal.source = isLighted ? paramsObj.lightedMedalRectLocal.toLoadFileUrl()
                                    : paramsObj.darkMedalRectLocal.toLoadFileUrl()
        id_medal_icon.source = isLighted ? paramsObj.lightedMedalRoundLocal.toLoadFileUrl()
                                         : paramsObj.darkMedalRoundLocal.toLoadFileUrl()
        instructions = isLighted ? paramsObj.lightedMedalTip
                                 : paramsObj.darkMedalTip
    }


    YImage {
        id: id_medal
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        anchors.leftMargin: 54
        sourceSize: Qt.size(248, 182)
    }

    YImage {
        id: id_medal_icon
        anchors.top: parent.top
        anchors.topMargin: 47
        anchors.left: parent.left
        anchors.leftMargin: 364
        width: 28
        height: 28
    }

    YTextBase {
        font.pixelSize: 28
        font.family: fontManager.fontFamilyZhCn
        color: "#4BFFF4"
        anchors.left: id_medal_icon.right
        anchors.leftMargin: 4
        anchors.verticalCenter: id_medal_icon.verticalCenter
        text: ("%1%2").arg(isLighted ? YTranslateText.unlockSuccess : YTranslateText.notUnlock).arg(title)
        opacity: isLighted ? 1 : 0.7
    }

    Flickable {
        width: 366
        height: 90
        clip: true
        anchors.right: parent.right
        anchors.rightMargin: 68
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 38
        contentHeight: id_instructions.height
        YTextMedium {
            id: id_instructions
            anchors.left: parent.left
            anchors.right: parent.right
            height: paintedHeight
            wrapMode: YTextMedium.Wrap
            font.pixelSize: 22
            opacity: isLighted ? 1 : 0.6
            font.family: fontManager.fontFamilyZhCn
        }
    }


    highlightStartWidth: 120
    highlightStartHeight: 120
    highlightStartY: 80
    backButtonObject: id_back_button
    backButtonHideValue: id_back_button.backButtonHideValue
    backButtonShowValue: id_back_button.backButtonShowValue

    YFastBlurRectangle {
        id: id_back_button
        anchors.top: parent.top
        anchors.topMargin: showMargin
        anchors.right: parent.right
        anchors.rightMargin: showMargin
        implicitWidth: 115
        implicitHeight: 115
        z: parent.z + 1

        opacity: id_back_button_ma.pressed ? 0.6 : 1
        enabled: id_opening_item.opacity > 0.9
        visible: backButtonEnabled
        property int showMargin: -115

        function backButtonHideValue() {
            return -115
        }

        function backButtonShowValue() {
            return backButtonEnabled ? -52 : -115
        }

        YImage {
            anchors.top: parent.top
            anchors.topMargin: 60
            anchors.right: parent.right
            anchors.rightMargin: 60
            sourceSize: Qt.size(38, 38)
            imageName: "touchreading/medal_set_close"
        }

        YBackButtonBase {
            id: id_back_button_ma
            anchors.fill: parent
            anchors.bottomMargin: -60
            anchors.leftMargin: -60
            objectName: "YTouchReadingPageIndex.qml_id_back_button"
            enabled: (id_opening_item.opacity > 0.9)
            onTriggered: {
                backButtonClicked()
            }
        }
    }

    onBackButtonClicked: {
        id_opening_item.hide()
        id_opening_item.destroy()
    }

    Component {
        id: id_bg_component
        YImage {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            anchors.topMargin: 19
            sourceSize: Qt.size(736, 216)
            imageName: isLighted ? "touchreading/medal_card_bg"
                                 : "touchreading/medal_card_off_bg"
        }
    }

    property int incubatorCreateCount: 0
    Component.onCompleted: {
        const incubator = id_bg_component.incubateObject(backgroundItem);
        if (incubator.status !== Component.Ready) {
            incubator.onStatusChanged = function(status) {
                if (status === Component.Ready) {
                    if (0 !== --incubatorCreateCount) {
                        incubator.object.destroy()
                    }
                }
            }
            ++incubatorCreateCount
        }
    }
}
